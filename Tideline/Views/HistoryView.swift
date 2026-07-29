import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if appState.scanHistory.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 10) {
                            ForEach(appState.scanHistory) { entry in
                                NavigationLink(value: entry) {
                                    HistoryRow(entry: entry)
                                        .padding(14)
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .shadow(color: TideTheme.cardShadow, radius: 6, y: 2)
                                }
                                .buttonStyle(TidePressableStyle())
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: ScanHistoryEntry.self) { entry in
                if let item = entry.cachedItem {
                    ResultView(item: item)
                } else {
                    UnavailableResultView(itemName: entry.itemName)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            EyebrowText(text: "History")
            Text("Your Scans")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
        }
        .padding(.top, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 40))
                .foregroundStyle(TideTheme.inkSoft.opacity(0.5))
            Text("No Scans Yet")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text("Scan a barcode, take a photo, or search for an item to see it here.")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppState())
}
