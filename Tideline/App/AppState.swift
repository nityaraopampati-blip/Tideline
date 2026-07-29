import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var profile: UserProfile?
    @Published private(set) var hasPromptedBaselineQuiz: Bool
    @Published private(set) var scanHistory: [ScanHistoryEntry]
    @Published private(set) var quizResults: [QuizResult]

    private let store = LocalStore.shared

    var isSignedIn: Bool { profile != nil }
    var baselineQuizScore: QuizResult? { quizResults.first { $0.type == .baseline } }

    init() {
        profile = store.profile
        quizResults = store.quizResults
        scanHistory = store.scanHistory
        hasPromptedBaselineQuiz = store.hasPromptedBaselineQuiz
    }

    /// Signs the user in. `displayName` is only ever supplied by Apple on a
    /// person's very first Sign in with Apple, so it's preserved across
    /// future sign-ins once captured.
    func signIn(displayName: String?) {
        let existing = store.profile
        let newProfile = UserProfile(
            id: existing?.id ?? UUID().uuidString,
            displayName: displayName ?? existing?.displayName,
            createdAt: existing?.createdAt ?? Date()
        )
        store.profile = newProfile
        profile = newProfile
    }

    func signOut() {
        store.signOut()
        profile = nil
        quizResults = []
        scanHistory = []
        hasPromptedBaselineQuiz = false
    }

    func recordBaselineQuiz(score: Int, totalQuestions: Int) {
        let result = QuizResult(type: .baseline, score: score, totalQuestions: totalQuestions)
        var results = store.quizResults
        results.append(result)
        store.quizResults = results
        quizResults = results
        markBaselineQuizPrompted()
    }

    func markBaselineQuizPrompted() {
        store.hasPromptedBaselineQuiz = true
        hasPromptedBaselineQuiz = true
    }

    func recordScan(item: PlasticItem, method: ScanMethod) {
        let entry = ScanHistoryEntry(itemName: item.name, scanMethod: method, cachedItem: item)
        store.addScanHistoryEntry(entry)
        scanHistory = store.scanHistory
    }
}
