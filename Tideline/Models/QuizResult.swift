import Foundation

enum QuizType: String, Codable {
    case baseline
    case followup
}

struct QuizResult: Codable, Identifiable, Equatable {
    let id: String
    let type: QuizType
    let score: Int
    let totalQuestions: Int
    let takenAt: Date

    init(id: String = UUID().uuidString, type: QuizType, score: Int, totalQuestions: Int, takenAt: Date = Date()) {
        self.id = id
        self.type = type
        self.score = score
        self.totalQuestions = totalQuestions
        self.takenAt = takenAt
    }
}
