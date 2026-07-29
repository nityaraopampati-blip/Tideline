import Foundation

struct Badge: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let isEarned: () -> Bool
}
