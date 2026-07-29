import SwiftUI
import VisionKit

struct BarcodeScanView: View {
    @EnvironmentObject private var appState: AppState
    @State private var phase: Phase = .scanning
    @State private var matchedItem: PlasticItem?

    private let lookupService = BarcodeLookupService()

    private enum Phase: Equatable {
        case scanning
        case lookingUp
        case notFound(String)
    }

    var body: some View {
        content
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $matchedItem) { item in
                ResultView(item: item)
            }
    }

    @ViewBuilder
    private var content: some View {
        if !DataScannerViewController.isSupported || !DataScannerViewController.isAvailable {
            unsupportedView
        } else {
            switch phase {
            case .scanning:
                scanningView
            case .lookingUp:
                ProgressView("Looking up product…")
            case .notFound(let barcode):
                notFoundView(barcode: barcode)
            }
        }
    }

    private var scanningView: some View {
        ZStack(alignment: .top) {
            BarcodeScannerRepresentable(onScan: handleScan)
                .ignoresSafeArea()
            Text("Point your camera at a barcode")
                .font(.footnote.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.top, 12)
        }
    }

    private var unsupportedView: some View {
        ContentUnavailableView(
            "Barcode Scanning Unavailable",
            systemImage: "barcode.viewfinder",
            description: Text("This device (or the Simulator, which has no camera) doesn't support live barcode scanning. Try Search instead.")
        )
    }

    private func notFoundView(barcode: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "questionmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("We couldn't identify that barcode.")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Barcode: \(barcode)")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Button("Scan Again") { phase = .scanning }
                    .buttonStyle(.bordered)
                NavigationLink("Search Instead") { SearchView() }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
    }

    private func handleScan(_ barcode: String) {
        guard phase == .scanning else { return }
        phase = .lookingUp
        Task {
            let name = await lookupService.lookupProductName(barcode: barcode)
            await MainActor.run {
                if let name, let item = PlasticItemLibrary.shared.match(query: name) {
                    appState.recordScan(item: item, method: .barcode)
                    matchedItem = item
                } else {
                    phase = .notFound(barcode)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { BarcodeScanView() }
        .environmentObject(AppState())
}
