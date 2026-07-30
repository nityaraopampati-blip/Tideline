import SwiftUI
import Charts

/// "Your plastic log" section: Day/Week/Month/Year range picker plus a bar
/// chart, matching the prototype's rangepick + chart styling. All bars are
/// computed from real scan history (see ImpactStats).
struct PlasticLogSection: View {
    @Binding var selectedRange: LogRange
    let buckets: [ChartBucket]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Your Plastic Log")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(TideTheme.ink)

            rangePicker

            Chart(buckets) { bucket in
                BarMark(
                    x: .value("Period", bucket.label),
                    y: .value("Grams", bucket.grams)
                )
                .foregroundStyle(
                    LinearGradient(colors: [TideTheme.seafoam, TideTheme.tide], startPoint: .bottom, endPoint: .top)
                )
                .cornerRadius(4)
            }
            .chartYAxis(.hidden)
            .frame(height: 110)
            .padding(14)
            .background(TideTheme.surface2)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var rangePicker: some View {
        HStack(spacing: 4) {
            ForEach(LogRange.allCases) { range in
                Button {
                    selectedRange = range
                } label: {
                    Text(range.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(selectedRange == range ? TideTheme.deep : TideTheme.inkSoft)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(selectedRange == range ? Color(.systemBackground) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(TideTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    PlasticLogSection(
        selectedRange: .constant(.week),
        buckets: [
            ChartBucket(label: "Mon", grams: 22),
            ChartBucket(label: "Tue", grams: 0),
            ChartBucket(label: "Wed", grams: 14),
            ChartBucket(label: "Thu", grams: 5),
            ChartBucket(label: "Fri", grams: 30),
            ChartBucket(label: "Sat", grams: 0),
            ChartBucket(label: "Sun", grams: 8),
        ]
    )
    .padding()
    .background(TideTheme.background)
}
