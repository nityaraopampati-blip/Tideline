import Foundation

struct SortableItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let emoji: String
    let recyclable: Bool
}
