import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    private var recentScans: [ScanHistoryEntry] {
        Array(appState.scanHistory.prefix(5))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(value: HomeDestination.barcode) {
                        actionRow(icon: "barcode.viewfinder", title: "Scan Barcode", subtitle: "Point your camera at a barcode")
                    }
                    NavigationLink(value: HomeDestination.photo) {
                        actionRow(icon: "camera.fill", title: "Take Photo", subtitle: "Snap a photo of an item")
                    }
                    NavigationLink(value: HomeDestination.search) {
                        actionRow(icon: "magnifyingglass", title: "Search by Name", subtitle: "Type in what you're holding")
                    }
                }

                if !recentScans.isEmpty {
                    Section("Recent Scans") {
                        ForEach(recentScans) { entry in
                            NavigationLink(value: HomeDestination.historyEntry(entry)) {
                                HistoryRow(entry: entry)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tideline")
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .barcode:
                    BarcodeScanView()
                case .photo:
                    PhotoScanView()
                case .search:
                    SearchView()
                case .historyEntry(let entry):
                    if let item = entry.cachedItem {
                        ResultView(item: item)
                    } else {
                        UnavailableResultView(itemName: entry.itemName)
                    }
                }
            }
        }
    }

    private func actionRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

enum HomeDestination: Hashable {
    case barcode
    case photo
    case search
    case historyEntry(ScanHistoryEntry)
}

struct HistoryRow: View {
    let entry: ScanHistoryEntry

    var body: some View {
        HStack {
            Image(systemName: icon(for: entry.scanMethod))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.itemName)
                Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func icon(for method: ScanMethod) -> String {
        switch method {
        case .barcode: return "barcode.viewfinder"
        case .photo: return "camera.fill"
        case .search: return "magnifyingglass"
        }
    }
}

/// Shown when a history entry predates result caching, or its cached data
/// couldn't be decoded — keeps the app from crashing on old/corrupt entries.
struct UnavailableResultView: View {
    let itemName: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Details for \"\(itemName)\" aren't saved anymore.")
                .multilineTextAlignment(.center)
            Text("Try searching for it again.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle(itemName)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
