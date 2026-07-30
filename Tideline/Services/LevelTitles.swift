import Foundation

/// A fun, animal-themed identity for a level — name, emoji, and a color so
/// the level badge looks like a little creature instead of a plain number.
struct LevelPersona {
    let name: String
    let emoji: String
    let colorHex: UInt32
}

enum LevelTitles {
    private static let personas: [LevelPersona] = [
        LevelPersona(name: "Baby Sea Turtle", emoji: "🐢", colorHex: 0x43A047),
        LevelPersona(name: "Busy Crab", emoji: "🦀", colorHex: 0xFF7043),
        LevelPersona(name: "Playful Otter", emoji: "🦦", colorHex: 0x8D6E63),
        LevelPersona(name: "Swift Dolphin", emoji: "🐬", colorHex: 0x3B5FE8),
        LevelPersona(name: "Clever Octopus", emoji: "🐙", colorHex: 0x8E24AA),
        LevelPersona(name: "Puffed-Up Pufferfish", emoji: "🐡", colorHex: 0xE8A93B),
        LevelPersona(name: "Sleek Seal", emoji: "🦭", colorHex: 0x546E7A),
        LevelPersona(name: "Shimmering Fish", emoji: "🐠", colorHex: 0xFDD835),
        LevelPersona(name: "Mighty Squid", emoji: "🦑", colorHex: 0xAB47BC),
        LevelPersona(name: "Gentle Jellyfish", emoji: "🪼", colorHex: 0xEC80C4),
        LevelPersona(name: "Bold Shark", emoji: "🦈", colorHex: 0x37474F),
        LevelPersona(name: "Majestic Whale", emoji: "🐋", colorHex: 0x1E88E5),
        LevelPersona(name: "Roaming Lobster", emoji: "🦞", colorHex: 0xE53935),
        LevelPersona(name: "Guardian Orca", emoji: "🐳", colorHex: 0x263238),
        LevelPersona(name: "Tideline Legend", emoji: "🌊", colorHex: 0x2E7D32),
    ]

    static func persona(for level: Int) -> LevelPersona {
        guard level >= 1 else { return personas[0] }
        if level <= personas.count {
            return personas[level - 1]
        }
        let legend = personas[personas.count - 1]
        let tier = level - personas.count + 1
        return LevelPersona(name: "\(legend.name) (Tier \(tier))", emoji: legend.emoji, colorHex: legend.colorHex)
    }

    static func name(for level: Int) -> String {
        persona(for: level).name
    }
}
