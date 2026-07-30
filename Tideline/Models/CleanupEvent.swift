import Foundation

enum CleanupEventType: String, Codable, CaseIterable, Identifiable {
    case beachCleanup = "Beach cleanup"
    case riverCleanup = "River cleanup"
    case parkCleanup = "Park cleanup"
    case neighborhoodPickup = "Neighborhood pickup"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .beachCleanup: return "beach.umbrella.fill"
        case .riverCleanup: return "water.waves"
        case .parkCleanup: return "tree.fill"
        case .neighborhoodPickup: return "house.fill"
        }
    }
}

struct CleanupEvent: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var location: String
    var type: CleanupEventType
    /// Start date and time.
    var date: Date
    /// End date and time — same calendar day as `date`.
    var endDate: Date
    var notes: String
    /// True if this device's user created the event.
    var isHostedByMe: Bool
    /// True if this device's user has joined (not applicable if hosting).
    var hasJoined: Bool
    /// Local-only attendee count — there's no shared backend yet, so this
    /// only reflects this device's own join/leave, not other real users.
    var goingCount: Int

    init(
        id: String = UUID().uuidString,
        name: String,
        location: String,
        type: CleanupEventType,
        date: Date,
        endDate: Date,
        notes: String,
        isHostedByMe: Bool = true,
        hasJoined: Bool = false,
        goingCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.type = type
        self.date = date
        self.endDate = endDate
        self.notes = notes
        self.isHostedByMe = isHostedByMe
        self.hasJoined = hasJoined
        self.goingCount = goingCount
    }

    /// Stays visible until the event's end time passes, not just the day.
    var isUpcoming: Bool {
        endDate >= Date()
    }

    var timeRangeText: String {
        let dateStr = date.formatted(date: .abbreviated, time: .omitted)
        let startStr = date.formatted(date: .omitted, time: .shortened)
        let endStr = endDate.formatted(date: .omitted, time: .shortened)
        return "\(dateStr) · \(startStr)–\(endStr)"
    }
}
