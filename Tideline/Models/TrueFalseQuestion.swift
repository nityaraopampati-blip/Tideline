import Foundation

struct TrueFalseQuestion: Identifiable {
    let id = UUID()
    let statement: String
    let answer: Bool
    let explanation: String
}
