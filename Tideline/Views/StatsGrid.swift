import SwiftUI

/// One 2x2 stat tile, matching the prototype's `.tile` style.
struct StatTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(TideTheme.inkSoft)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.deep)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TideTheme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct StatsGrid: View {
    let summary: WeeklySummary

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            StatTile(label: "Items Logged", value: "\(summary.itemsLogged)")
            StatTile(label: "Plastic, g", value: "\(Int(summary.grams.rounded()))")
            StatTile(label: "CO₂ Saved, kg", value: String(format: "%.1f", summary.co2Kg))
            StatTile(label: "Goal Days", value: "\(summary.goalDays)/7")
        }
    }
}

#Preview {
    StatsGrid(summary: WeeklySummary(itemsLogged: 4, grams: 58, co2Kg: 0.13, goalDays: 3))
        .padding()
        .background(TideTheme.background)
}
