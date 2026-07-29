import SwiftUI
import UIKit

struct PhotoScanView: View {
    @EnvironmentObject private var appState: AppState
    @State private var phase: Phase = .idle
    @State private var matchedItem: PlasticItem?
    @State private var showCamera = false

    private enum Phase: Equatable {
        case idle
        case classifying
        case estimating
        case notRecognized
    }

    private let isSupported = PhotoScanCapability.isAvailable()

    var body: some View {
        content
            .navigationTitle("Take Photo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $matchedItem) { item in
                ResultView(item: item)
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraCaptureRepresentable(onCapture: handleCapture, onCancel: { showCamera = false })
                    .ignoresSafeArea()
            }
    }

    @ViewBuilder
    private var content: some View {
        if !isSupported {
            unsupportedView
        } else {
            switch phase {
            case .idle:
                idleView
            case .classifying:
                ProgressView("Looking at your photo…")
            case .estimating:
                ProgressView("Asking Tideline's on-device AI…")
            case .notRecognized:
                notRecognizedView
            }
        }
    }

    private var idleView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Snap a photo of a plastic item and Tideline will identify it.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Open Camera") { showCamera = true }
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }

    private var unsupportedView: some View {
        ContentUnavailableView(
            "Photo Scanning Unavailable",
            systemImage: "camera.fill",
            description: Text("Photo scanning needs an iPhone 15 Pro or newer — try Barcode or Search instead.")
        )
    }

    private var notRecognizedView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "questionmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("We couldn't recognize that item.")
                .font(.headline)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                Button("Try Again") {
                    phase = .idle
                    showCamera = true
                }
                .buttonStyle(.bordered)
                NavigationLink("Search Instead") { SearchView() }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
    }

    private func handleCapture(_ image: UIImage) {
        showCamera = false
        phase = .classifying
        Task {
            let label = await PhotoClassifierService.classify(image)
            guard let label else {
                await MainActor.run { phase = .notRecognized }
                return
            }

            if let localItem = PlasticItemLibrary.shared.match(query: label) {
                await MainActor.run {
                    appState.recordScan(item: localItem, method: .photo)
                    matchedItem = localItem
                }
                return
            }

            // Not in the verified local database — ask the on-device AI for
            // a clearly-labeled estimate instead.
            await MainActor.run { phase = .estimating }
            if #available(iOS 26.0, *) {
                do {
                    let estimate = try await AIEstimateService.estimate(for: label)
                    await MainActor.run {
                        appState.recordScan(item: estimate, method: .photo)
                        matchedItem = estimate
                    }
                } catch {
                    await MainActor.run { phase = .notRecognized }
                }
            } else {
                await MainActor.run { phase = .notRecognized }
            }
        }
    }
}

#Preview {
    NavigationStack { PhotoScanView() }
        .environmentObject(AppState())
}
