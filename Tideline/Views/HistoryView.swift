import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            Group {
                if appState.scanHistory.isEmpty {
                    ContentUnavailableView(
                        "No Scans Yet",
                        systemImage: "clock",
                        description: Text("Scan a barcode, take a photo, or search for an item to see it here.")
                    )
                } else {
                    List(appState.scanHistory) { entry in
                        NavigationLink(value: entry) {
                            HistoryRow(entry: entry)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationDestination(for: ScanHistoryEntry.self) { entry in
                if let item = entry.cachedItem {
                    ResultView(item: item)
                } else {
                    UnavailableResultView(itemName: entry.itemName)
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppState())
}
