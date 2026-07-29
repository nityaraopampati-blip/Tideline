import SwiftUI

enum HomeDestination: Hashable {
    case barcode
    case photo
    case search
    case historyEntry(ScanHistoryEntry)
}

/// One tappable action row (Scan Barcode / Take Photo / Search by Name),
/// shared between the Home dashboard and the dedicated Scan tab.
struct ScanActionCard: View {
    let destination: HomeDestination
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
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
}

/// The three scan entry points, in the standard order/colors used
/// throughout the app.
struct ScanActionList: View {
    var body: some View {
        VStack(spacing: 14) {
            ScanActionCard(
                destination: .barcode, icon: "barcode.viewfinder",
                title: "Scan Barcode", subtitle: "Point your camera at a barcode",
                tint: TideTheme.tide
            )
            ScanActionCard(
                destination: .photo, icon: "camera.fill",
                title: "Take Photo", subtitle: "Snap a photo of an item",
                tint: TideTheme.coral
            )
            ScanActionCard(
                destination: .search, icon: "magnifyingglass",
                title: "Search by Name", subtitle: "Type in what you're holding",
                tint: Color(hex: 0xE8A93B)
            )
        }
    }
}

extension View {
    /// Attaches the shared destination mapping for `HomeDestination` — used
    /// by every screen that presents a `ScanActionList` inside its own
    /// NavigationStack (Home and the dedicated Scan tab).
    func withScanDestinations() -> some View {
        navigationDestination(for: HomeDestination.self) { destination in
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
