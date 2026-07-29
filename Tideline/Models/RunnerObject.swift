import Foundation

struct RunnerObject: Identifiable {
    enum Kind {
        case trash
        case obstacle
    }

    let id = UUID()
    let lane: Int
    var y: CGFloat
    let kind: Kind
    let emoji: String
    var collected = false
}
