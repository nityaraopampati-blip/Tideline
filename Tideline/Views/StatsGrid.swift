import SwiftUI

/// One 2x2 stat tile, matching the prototype's `.tile` style, with a
/// colored icon badge so each stat reads as its own little moment instead
/// of a uniform block of green text.
struct StatTile: View {
    let icon: String
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle().fill(tint.opacity(0.15)).frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tint)
            }
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(TideTheme.inkSoft)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TideTheme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct StatsGrid: View {
    /// Totals for the currently selected chart range (Day/Week/Month/Year).
    let rangeSummary: RangeSummary
    /// Always weekly — "Goal Days" is a 7-day habit tracker, not tied to
    /// whichever range the chart happens to be showing.
    let goalDays: Int

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            StatTile(icon: "checkmark.circle.fill", label: "Items Logged", value: "\(rangeSummary.itemsLogged)", tint: TideTheme.tide)
            StatTile(icon: "cube.fill", label: "Plastic, g", value: "\(Int(rangeSummary.grams.rounded()))", tint: TideTheme.coral)
            StatTile(icon: "leaf.fill", label: "CO₂ Saved, kg", value: String(format: "%.1f", rangeSummary.co2Kg), tint: Color(hex: 0x3B5FE8))
            StatTile(icon: "flame.fill", label: "Goal Days", value: "\(goalDays)/7", tint: Color(hex: 0xE8A93B))
        }
    }
}

#Preview {
    StatsGrid(rangeSummary: RangeSummary(itemsLogged: 4, grams: 58, co2Kg: 0.13), goalDays: 3)
        .padding()
        .background(TideTheme.background)
}
