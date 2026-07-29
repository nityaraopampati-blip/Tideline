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
    var date: Date
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
        self.notes = notes
        self.isHostedByMe = isHostedByMe
        self.hasJoined = hasJoined
        self.goingCount = goingCount
    }

    var isUpcoming: Bool {
        date >= Calendar.current.startOfDay(for: Date())
    }
}
