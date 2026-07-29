import Foundation

/// XP/leveling state, matching the prototype's `level` object exactly:
/// each level-up consumes the current cap and grows the next cap by 15%.
struct LevelState: Codable, Equatable {
    var xp: Int = 0
    var levelNumber: Int = 1
    var cap: Int = 500

    mutating func addXP(_ amount: Int) {
        xp += amount
        while xp >= cap {
            xp -= cap
            levelNumber += 1
            cap = Int((Double(cap) * 1.15).rounded())
        }
    }
}
