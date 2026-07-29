import Foundation

struct QuizQuestion: Codable, Identifiable, Equatable {
    let id: Int
    let format: String
    let question: String
    let choices: [String]
    let correctAnswer: String
    let explanation: String

    /// Choices are stored as "A", "B", "C", "D" in the data; this maps that
    /// letter to the actual choice text so answers can be compared and displayed.
    var correctChoiceText: String? {
        guard let index = "ABCD".firstIndex(of: Character(correctAnswer)) else { return nil }
        let offset = "ABCD".distance(from: "ABCD".startIndex, to: index)
        guard choices.indices.contains(offset) else { return nil }
        return choices[offset]
    }
}
