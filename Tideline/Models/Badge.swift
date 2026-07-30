import Foundation

struct Badge: Identifiable {
    let id: String
    let name: String
    let icon: String
    /// Hex color for this badge's icon/circle, kept as a raw value so this
    /// model doesn't need to import SwiftUI.
    let colorHex: UInt32
    let description: String
    let isEarned: () -> Bool
}
