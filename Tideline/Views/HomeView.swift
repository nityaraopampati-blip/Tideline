import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedRange: LogRange = .week
    @State private var showFullHistory = false
    @State private var showProfile = false

    private var recentScans: [ScanHistoryEntry] {
        Array(appState.scanHistory.prefix(5))
    }

    private var tideScoreState: TideScoreState {
        ImpactStats.tideScore(history: appState.scanHistory)
    }

    private var weeklySummary: WeeklySummary {
        ImpactStats.weeklySummary(history: appState.scanHistory)
    }

    private var rangeSummary: RangeSummary {
        ImpactStats.rangeSummary(history: appState.scanHistory, range: selectedRange)
    }

    private var chartBuckets: [ChartBucket] {
        ImpactStats.chartBuckets(history: appState.scanHistory, range: selectedRange)
    }

    private var rangeCaption: String {
        switch selectedRange {
        case .day: return "TODAY'S TOTALS"
        case .week: return "THIS WEEK'S TOTALS"
        case .month: return "LAST 4 WEEKS' TOTALS"
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 0..<12: timeOfDay = "Good morning"
        case 12..<17: timeOfDay = "Good afternoon"
        default: timeOfDay = "Good evening"
        }
        guard let name = appState.profile?.displayName,
              let firstName = name.split(separator: " ").first, !firstName.isEmpty else {
            return "\(timeOfDay)!"
        }
        return "\(timeOfDay), \(firstName)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    TideScoreCard(state: tideScoreState)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(rangeCaption)
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.4)
                            .foregroundStyle(TideTheme.inkSoft)
                        StatsGrid(rangeSummary: rangeSummary, goalDays: weeklySummary.goalDays)
                    }

                    PlasticLogSection(selectedRange: $selectedRange, buckets: chartBuckets)

                    ScanActionList()

                    if !recentScans.isEmpty {
                        recentSection
                    }
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .withScanDestinations()
            .sheet(isPresented: $showFullHistory) {
                HistoryView()
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                EyebrowText(text: "Home")
                Text(greeting)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
            }
            Spacer()
            Button {
                showProfile = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(.secondarySystemGroupedBackground))
                        .frame(width: 40, height: 40)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(TideTheme.deep)
                }
            }
            .buttonStyle(TidePressableStyle())
        }
        .padding(.top, 8)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🕓 Recent Scans")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                Spacer()
                Button("Full History ›") { showFullHistory = true }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TideTheme.tide)
            }

            VStack(spacing: 10) {
                ForEach(recentScans) { entry in
                    NavigationLink(value: HomeDestination.historyEntry(entry)) {
                        HistoryRow(entry: entry)
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(TidePressableStyle())
                }
            }
        }
    }
}

struct HistoryRow: View {
    let entry: ScanHistoryEntry

    var body: some View {
        HStack {
            ZStack {
                Circle().fill(color(for: entry.scanMethod).opacity(0.15)).frame(width: 32, height: 32)
                Image(systemName: icon(for: entry.scanMethod))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color(for: entry.scanMethod))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.itemName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(TideTheme.ink)
                Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundStyle(TideTheme.inkSoft)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(TideTheme.inkSoft.opacity(0.5))
        }
    }

    private func icon(for method: ScanMethod) -> String {
        switch method {
        case .barcode: return "barcode.viewfinder"
        case .photo: return "camera.fill"
        case .search: return "magnifyingglass"
        }
    }

    private func color(for method: ScanMethod) -> Color {
        switch method {
        case .barcode: return TideTheme.tide
        case .photo: return TideTheme.coral
        case .search: return Color(hex: 0xE8A93B)
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
