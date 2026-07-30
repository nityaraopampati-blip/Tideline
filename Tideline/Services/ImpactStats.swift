import Foundation

struct ChartBucket: Identifiable {
    let id = UUID()
    let label: String
    let grams: Double
}

enum LogRange: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    var id: String { rawValue }
}

struct WeeklySummary {
    let itemsLogged: Int
    let grams: Double
    let co2Kg: Double
    let goalDays: Int // out of 7
}

struct RangeSummary {
    let itemsLogged: Int
    let grams: Double
    let co2Kg: Double
}

enum TideScoreState {
    case noHistory
    case scored(score: Int, message: String)
}

/// Computes the Phase 2 impact-dashboard numbers from real scan history —
/// same formulas as the original prototype (tideline-project/index.html),
/// so "Tide Score", weekly stats, and the plastic log chart all match what
/// was designed there. The one deliberate change: the prototype's "day"
/// chart view filled empty hours with `Math.random()` for demo polish; here
/// every bucket, in every range, is computed from real scan timestamps.
enum ImpactStats {
    private static func weight(for entry: ScanHistoryEntry) -> Double {
        if let cached = entry.cachedItem { return cached.typicalWeightGrams }
        return PlasticItemLibrary.shared.match(query: entry.itemName)?.typicalWeightGrams ?? 10
    }

    /// Monday-based start of week, matching the prototype's Mon–Sun week.
    static func startOfWeek(containing date: Date, calendar: Calendar = .current) -> Date {
        var cal = calendar
        cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }

    static func weeklySummary(history: [ScanHistoryEntry], now: Date = Date()) -> WeeklySummary {
        let sow = startOfWeek(containing: now)
        let weekItems = history.filter { $0.timestamp >= sow }
        let grams = weekItems.reduce(0) { $0 + weight(for: $1) }
        let co2 = grams * 0.06 / 1000 * 38
        let daysWithLog = Set(weekItems.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
        return WeeklySummary(itemsLogged: weekItems.count, grams: grams, co2Kg: co2, goalDays: min(daysWithLog, 7))
    }

    /// Totals for whichever range is selected on the plastic-log chart
    /// (Day/Week/Month/Year), so the stat tiles above the chart actually
    /// match what the chart is showing instead of always being weekly.
    static func rangeSummary(history: [ScanHistoryEntry], range: LogRange, now: Date = Date()) -> RangeSummary {
        let calendar = Calendar.current
        let windowStart: Date

        switch range {
        case .day:
            windowStart = calendar.startOfDay(for: now)
        case .week:
            windowStart = startOfWeek(containing: now)
        case .month:
            windowStart = calendar.date(byAdding: .day, value: -27, to: calendar.startOfDay(for: now)) ?? now
        }

        let itemsInRange = history.filter { $0.timestamp >= windowStart }
        let grams = itemsInRange.reduce(0) { $0 + weight(for: $1) }
        let co2 = grams * 0.06 / 1000 * 38
        return RangeSummary(itemsLogged: itemsInRange.count, grams: grams, co2Kg: co2)
    }

    static func tideScore(history: [ScanHistoryEntry], now: Date = Date()) -> TideScoreState {
        guard !history.isEmpty else { return .noHistory }
        let summary = weeklySummary(history: history, now: now)
        guard summary.itemsLogged > 0 else {
            return .scored(
                score: scoreValue(grams: 0),
                message: "Nothing logged this week yet. Scan or add an item to update your score."
            )
        }
        let score = scoreValue(grams: summary.grams)
        let message: String
        if score >= 75 {
            message = "Your plastic footprint is well below average this week — the tide's going out. Keep it up."
        } else if score >= 50 {
            message = "Steady progress. A couple more reusable swaps would push your score into the 80s."
        } else {
            message = "This week ran heavier on single-use items. Try logging a few swaps to bring the score back down."
        }
        return .scored(score: score, message: message)
    }

    private static func scoreValue(grams: Double) -> Int {
        max(20, min(97, Int((100 - grams / 6).rounded())))
    }

    static func chartBuckets(history: [ScanHistoryEntry], range: LogRange, now: Date = Date()) -> [ChartBucket] {
        let calendar = Calendar.current

        switch range {
        case .day:
            let labels = ["12am", "4am", "8am", "12pm", "4pm", "8pm"]
            let todays = history.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
            return labels.enumerated().map { index, label in
                let hourStart = index * 4
                let hourEnd = hourStart + 4
                let grams = todays.filter {
                    let hour = calendar.component(.hour, from: $0.timestamp)
                    return hour >= hourStart && hour < hourEnd
                }.reduce(0) { $0 + weight(for: $1) }
                return ChartBucket(label: label, grams: grams)
            }

        case .week:
            let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            let sow = startOfWeek(containing: now)
            return labels.enumerated().map { index, label in
                guard let day = calendar.date(byAdding: .day, value: index, to: sow) else {
                    return ChartBucket(label: label, grams: 0)
                }
                let grams = history.filter { calendar.isDate($0.timestamp, inSameDayAs: day) }
                    .reduce(0) { $0 + weight(for: $1) }
                return ChartBucket(label: label, grams: grams)
            }

        case .month:
            return (0..<4).map { weekIndex in
                let weeksAgo = 3 - weekIndex
                guard let end = calendar.date(byAdding: .day, value: -weeksAgo * 7, to: now),
                      let start = calendar.date(byAdding: .day, value: -6, to: end) else {
                    return ChartBucket(label: "W\(weekIndex + 1)", grams: 0)
                }
                let grams = history.filter { $0.timestamp >= calendar.startOfDay(for: start) && $0.timestamp <= end }
                    .reduce(0) { $0 + weight(for: $1) }
                let dateFormat = Date.FormatStyle.dateTime.month(.defaultDigits).day()
                let label = "\(start.formatted(dateFormat))–\(end.formatted(dateFormat))"
                return ChartBucket(label: label, grams: grams)
            }
        }
    }
}
