import Foundation

struct Challenge: Identifiable {
    let id: String
    let name: String
    let goal: Int
    let xpReward: Int
    let buttonLabel: String
    /// True for the single featured challenge shown at the top of the screen.
    let isFeatured: Bool
}
