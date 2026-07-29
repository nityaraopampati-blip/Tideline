import Foundation

/// On-device persistence for Phase 1. Stands in for Apple CloudKit sync
/// until the "iCloud" and "Sign in with Apple" capabilities are enabled in
/// Xcode (Signing & Capabilities) with a signed-in Apple Developer account.
/// See Section 3 of the build brief.
final class LocalStore {
    static let shared = LocalStore()
    private let defaults = UserDefaults.standard

    private enum Key {
        static let profile = "tideline.profile"
        static let quizResults = "tideline.quizResults"
        static let scanHistory = "tideline.scanHistory"
        static let hasPromptedBaselineQuiz = "tideline.hasPromptedBaselineQuiz"
        static let gameBestScores = "tideline.gameBestScores"
    }

    enum GameID: String {
        case trueFalseQuiz
        case sortThePlastic
        case recycleRunner
    }

    var profile: UserProfile? {
        get { decode(Key.profile) }
        set { encode(newValue, forKey: Key.profile) }
    }

    var quizResults: [QuizResult] {
        get { decode(Key.quizResults) ?? [] }
        set { encode(newValue, forKey: Key.quizResults) }
    }

    var scanHistory: [ScanHistoryEntry] {
        get { decode(Key.scanHistory) ?? [] }
        set { encode(newValue, forKey: Key.scanHistory) }
    }

    var hasPromptedBaselineQuiz: Bool {
        get { defaults.bool(forKey: Key.hasPromptedBaselineQuiz) }
        set { defaults.set(newValue, forKey: Key.hasPromptedBaselineQuiz) }
    }

    func addScanHistoryEntry(_ entry: ScanHistoryEntry) {
        scanHistory.insert(entry, at: 0)
    }

    private var gameBestScores: [String: Int] {
        get { decode(Key.gameBestScores) ?? [:] }
        set { encode(newValue, forKey: Key.gameBestScores) }
    }

    func bestScore(for game: GameID) -> Int? {
        gameBestScores[game.rawValue]
    }

    /// Records a score, keeping only the best one seen so far.
    func recordScore(_ score: Int, for game: GameID) {
        let current = gameBestScores[game.rawValue] ?? Int.min
        guard score > current else { return }
        gameBestScores[game.rawValue] = score
    }

    func signOut() {
        defaults.removeObject(forKey: Key.profile)
        defaults.removeObject(forKey: Key.quizResults)
        defaults.removeObject(forKey: Key.scanHistory)
        defaults.removeObject(forKey: Key.hasPromptedBaselineQuiz)
        defaults.removeObject(forKey: Key.gameBestScores)
    }

    private func decode<T: Decodable>(_ key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func encode<T: Encodable>(_ value: T?, forKey key: String) {
        guard let value else {
            defaults.removeObject(forKey: key)
            return
        }
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
