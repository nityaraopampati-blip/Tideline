import Foundation

/// On-device persistence for cleanup events. Note: since Tideline doesn't
/// yet have a shared backend (see Section 3 of the build brief — this
/// unlocks once CloudKit is fully configured), events created here are only
/// visible on this device, not actually shared with other real users yet.
final class CommunityStore {
    static let shared = CommunityStore()
    private let defaults = UserDefaults.standard
    private let key = "tideline.communityEvents"

    var events: [CleanupEvent] {
        get {
            guard let data = defaults.data(forKey: key) else { return [] }
            return (try? JSONDecoder().decode([CleanupEvent].self, from: data)) ?? []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(data, forKey: key)
        }
    }

    @discardableResult
    func addEvent(_ event: CleanupEvent) -> CleanupEvent {
        events.append(event)
        return event
    }

    func toggleJoin(_ id: String) {
        guard var event = events.first(where: { $0.id == id }) else { return }
        event.hasJoined.toggle()
        event.goingCount = max(0, event.goingCount + (event.hasJoined ? 1 : -1))
        update(event)
    }

    func deleteEvent(_ id: String) {
        events.removeAll { $0.id == id }
    }

    private func update(_ event: CleanupEvent) {
        var all = events
        guard let index = all.firstIndex(where: { $0.id == event.id }) else { return }
        all[index] = event
        events = all
    }
}
