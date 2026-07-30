import Foundation

/// Fun ocean-themed title for each level, shown alongside the level number
/// so leveling up feels like a milestone instead of just a bigger integer.
enum LevelTitles {
    private static let names: [String] = [
        "Tide Pool Rookie",
        "Wave Watcher",
        "Current Rider",
        "Reef Ranger",
        "Kelp Forest Explorer",
        "Current Champion",
        "Coral Guardian",
        "Beachcomber Pro",
        "Tide Turner",
        "Deep Sea Defender",
        "Ocean Steward",
        "Blue Wave Hero",
        "Plastic-Free Pioneer",
        "Reef Legend",
        "Tideline Master",
    ]

    static func name(for level: Int) -> String {
        guard level >= 1 else { return names[0] }
        if level <= names.count {
            return names[level - 1]
        }
        return "Tide Legend \(level - names.count)"
    }
}
