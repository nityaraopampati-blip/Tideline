import Foundation

/// Static challenge/badge catalog, matching the prototype's content.
/// Badge earned-conditions are computed from real app data (not just
/// always false/true placeholders) wherever the feature they depend on
/// already exists — "Cleanup Hero" stays unearned until Community ships.
enum ChallengeCatalog {
    static let featured = Challenge(
        id: "reusable-bags",
        name: "Use 3 reusable bags",
        goal: 3,
        xpReward: 20,
        buttonLabel: "Log a reusable bag used",
        isFeatured: true
    )

    static let more: [Challenge] = [
        Challenge(id: "skip-straw", name: "Skip the straw", goal: 7, xpReward: 10, buttonLabel: "+ Log progress", isFeatured: false),
        Challenge(id: "plastic-free-lunch", name: "Plastic-free lunch", goal: 5, xpReward: 10, buttonLabel: "+ Log progress", isFeatured: false),
        Challenge(id: "refill-bottle", name: "Refill your bottle", goal: 7, xpReward: 10, buttonLabel: "+ Log progress", isFeatured: false),
    ]

    static func badges(scanHistory: [ScanHistoryEntry], levelState: LevelState) -> [Badge] {
        [
            Badge(
                id: "first-scan",
                name: "First Scan",
                icon: "checkmark.seal.fill",
                colorHex: 0x43A047, // tide
                description: "Log your very first item — scan a barcode, take a photo, or search for something from the Scan tab.",
                isEarned: { !scanHistory.isEmpty }
            ),
            Badge(
                id: "cleanup-hero",
                name: "Cleanup Hero",
                icon: "figure.wave",
                colorHex: 0x3B5FE8, // blue
                description: "Join or host a community cleanup event from the Community tab.",
                isEarned: { hasJoinedOrHostedEvent() }
            ),
            Badge(
                id: "week-warrior",
                name: "Week Warrior",
                icon: "flame.fill",
                colorHex: 0xFF7043, // coral
                description: "Log at least one item every day for 7 days in a row.",
                isEarned: { hasSevenDayStreak(scanHistory) }
            ),
            Badge(
                id: "eco-star",
                name: "Eco Star",
                icon: "star.fill",
                colorHex: 0xE8A93B, // amber
                description: "Reach Level 5 by earning XP from logging items, playing games, and completing challenges.",
                isEarned: { levelState.levelNumber >= 5 }
            ),
        ]
    }

    private static func hasJoinedOrHostedEvent() -> Bool {
        CommunityStore.shared.events.contains { $0.isHostedByMe || $0.hasJoined }
    }

    private static func hasSevenDayStreak(_ history: [ScanHistoryEntry]) -> Bool {
        let calendar = Calendar.current
        let days = Set(history.map { calendar.startOfDay(for: $0.timestamp) }).sorted()
        guard days.count >= 7 else { return false }

        var streak = 1
        for i in 1..<days.count {
            let dayGap = calendar.dateComponents([.day], from: days[i - 1], to: days[i]).day ?? 0
            if dayGap == 1 {
                streak += 1
                if streak >= 7 { return true }
            } else if dayGap > 1 {
                streak = 1
            }
        }
        return false
    }
}
