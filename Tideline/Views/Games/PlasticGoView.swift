import SwiftUI

/// Plastic-Go, Phase 1 version: a simple photo log of plastic spotted while
/// out and about. Per the build brief, this ships first — the full
/// real-time map game is a stretch goal for later.
struct PlasticGoView: View {
    @State private var entries: [PlasticGoEntry] = PlasticGoStore.shared.entries
    @State private var showCamera = false
    @State private var pendingImage: UIImage?
    @State private var noteText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                tipBox

                Button {
                    showCamera = true
                } label: {
                    Label("Log a Sighting", systemImage: "camera.viewfinder")
                }
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0x3B5FE8)))

                if entries.isEmpty {
                    emptyState
                } else {
                    logList
                }
            }
            .padding(20)
        }
        .background(TideTheme.background.ignoresSafeArea())
        .navigationTitle("Plastic-Go")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureRepresentable(
                onCapture: { image in
                    showCamera = false
                    pendingImage = image
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .sheet(item: pendingImageWrapper) { wrapper in
            noteSheet(for: wrapper.image)
        }
    }

    // MARK: - Pending image sheet wrapper (UIImage isn't Identifiable)

    private struct ImageWrapper: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    private var pendingImageWrapper: Binding<ImageWrapper?> {
        Binding(
            get: { pendingImage.map(ImageWrapper.init) },
            set: { newValue in pendingImage = newValue?.image }
        )
    }

    private func noteSheet(for image: UIImage) -> some View {
        VStack(spacing: 16) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("Add a note (optional)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TideTheme.inkSoft)
                TextField("e.g. \"Bottle caps on the beach\"", text: $noteText)
                    .padding(12)
                    .background(TideTheme.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Spacer()

            Button("Save to Log") { saveEntry(image: image) }
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0x3B5FE8)))
            Button("Discard") {
                pendingImage = nil
                noteText = ""
            }
            .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.inkSoft))
        }
        .padding(20)
        .presentationDetents([.medium])
    }

    private func saveEntry(image: UIImage) {
        PlasticGoStore.shared.addEntry(image: image, note: noteText)
        entries = PlasticGoStore.shared.entries
        pendingImage = nil
        noteText = ""
    }

    // MARK: - Content

    private var tipBox: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("💡").font(.system(size: 16))
            Text("Spot plastic litter while you're out? Snap a photo and log it here — no map, just a simple record of what you've found.")
                .font(.system(size: 12.5))
                .foregroundStyle(Color(hex: 0x0D3A32))
        }
        .padding(12)
        .background(TideTheme.seafoamLight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 34))
                .foregroundStyle(TideTheme.inkSoft.opacity(0.4))
            Text("No sightings logged yet.")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var logList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Log")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(TideTheme.ink)

            ForEach(entries) { entry in
                logRow(entry)
            }
        }
    }

    private func logRow(_ entry: PlasticGoEntry) -> some View {
        HStack(spacing: 12) {
            if let image = PlasticGoStore.shared.image(for: entry) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(TideTheme.surface2)
                    .frame(width: 54, height: 54)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.note.isEmpty ? "Plastic sighting" : entry.note)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(TideTheme.ink)
                Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundStyle(TideTheme.inkSoft)
            }
            Spacer()
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NavigationStack { PlasticGoView() }
}
