import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    private var recentScans: [ScanHistoryEntry] {
        Array(appState.scanHistory.prefix(5))
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

                    VStack(spacing: 14) {
                        actionCard(
                            destination: .barcode, icon: "barcode.viewfinder",
                            title: "Scan Barcode", subtitle: "Point your camera at a barcode",
                            tint: TideTheme.tide
                        )
                        actionCard(
                            destination: .photo, icon: "camera.fill",
                            title: "Take Photo", subtitle: "Snap a photo of an item",
                            tint: TideTheme.coral
                        )
                        actionCard(
                            destination: .search, icon: "magnifyingglass",
                            title: "Search by Name", subtitle: "Type in what you're holding",
                            tint: Color(hex: 0xE8A93B)
                        )
                    }

                    if !recentScans.isEmpty {
                        recentSection
                    }
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            EyebrowText(text: "Home")
            Text(greeting)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
        }
        .padding(.top, 8)
    }

    private func actionCard(destination: HomeDestination, icon: String, title: String, subtitle: String, tint: Color) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(tint)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(TideTheme.ink)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(TideTheme.inkSoft)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(TideTheme.inkSoft.opacity(0.6))
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: TideTheme.cardShadow, radius: 8, y: 3)
        }
        .buttonStyle(TidePressableStyle())
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Scans")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(TideTheme.ink)

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
                .foregroundStyle(TideTheme.tide)
                .frame(width: 24)
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
