import SwiftUI

struct BaselineQuizView: View {
    @EnvironmentObject private var appState: AppState

    private let questions = PlasticItemLibrary.shared.quizQuestions
    @State private var currentIndex = 0
    @State private var selectedChoice: String?
    @State private var score = 0
    @State private var showFinishedAcknowledgment = false
    @State private var showSkipConfirmation = false
    @State private var wasSkipped = false
    @State private var finalScore: Int?

    var body: some View {
        NavigationStack {
            VStack {
                if showFinishedAcknowledgment {
                    finishedView
                } else if questions.isEmpty {
                    // Data failed to load — don't block the user from the app.
                    Color.clear.onAppear { finish(skipped: true) }
                } else {
                    quizContent
                }
            }
            .padding()
            .navigationTitle("Quick Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showFinishedAcknowledgment {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Skip") { showSkipConfirmation = true }
                    }
                }
            }
            .confirmationDialog(
                "Skip the quiz for now?",
                isPresented: $showSkipConfirmation,
                titleVisibility: .visible
            ) {
                Button("Skip Quiz", role: .destructive) { finish(skipped: true) }
                Button("Keep Going", role: .cancel) {}
            } message: {
                Text("You can't retake this baseline quiz later, so your \"before\" score will be missing. You can still skip if you'd rather jump right in.")
            }
        }
    }

    private var currentQuestion: QuizQuestion { questions[currentIndex] }

    private var quizContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Question \(currentIndex + 1) of \(questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(currentQuestion.question)
                .font(.title3.bold())

            VStack(spacing: 12) {
                ForEach(currentQuestion.choices, id: \.self) { choice in
                    choiceButton(choice)
                }
            }

            if let selectedChoice {
                explanationView(selected: selectedChoice)
            }

            Spacer()

            if selectedChoice != nil {
                Button(currentIndex == questions.count - 1 ? "Finish" : "Next Question") {
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func choiceButton(_ choice: String) -> some View {
        let letter = letterForChoice(choice)
        let isCorrectChoice = letter == currentQuestion.correctAnswer
        let isSelected = selectedChoice == choice

        return Button {
            guard selectedChoice == nil else { return }
            selectedChoice = choice
            if isCorrectChoice { score += 1 }
        } label: {
            HStack {
                Text(choice)
                Spacer()
                if selectedChoice != nil && isCorrectChoice {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if isSelected {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
            }
            .padding()
            .background(choiceBackground(isSelected: isSelected, isCorrectChoice: isCorrectChoice))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .foregroundStyle(.primary)
        .disabled(selectedChoice != nil)
    }

    private func choiceBackground(isSelected: Bool, isCorrectChoice: Bool) -> Color {
        guard selectedChoice != nil else { return Color(.secondarySystemBackground) }
        if isCorrectChoice { return Color.green.opacity(0.15) }
        if isSelected { return Color.red.opacity(0.15) }
        return Color(.secondarySystemBackground)
    }

    private func explanationView(selected: String) -> some View {
        let wasCorrect = letterForChoice(selected) == currentQuestion.correctAnswer
        return VStack(alignment: .leading, spacing: 6) {
            Text(wasCorrect ? "Correct!" : "Not quite")
                .font(.subheadline.bold())
                .foregroundStyle(wasCorrect ? .green : .orange)
            Text(currentQuestion.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func letterForChoice(_ choice: String) -> String {
        guard let index = currentQuestion.choices.firstIndex(of: choice) else { return "" }
        return String("ABCD"[String.Index(utf16Offset: index, in: "ABCD")])
    }

    private func advance() {
        selectedChoice = nil
        if currentIndex == questions.count - 1 {
            finish(skipped: false)
        } else {
            currentIndex += 1
        }
    }

    private func finish(skipped: Bool) {
        // Show the acknowledgment screen first; only commit to AppState (which
        // triggers navigation away from the quiz) once the user taps Continue,
        // so the "thanks" message doesn't get swapped out before it's seen.
        wasSkipped = skipped
        finalScore = skipped ? nil : score
        showFinishedAcknowledgment = true
    }

    private func confirmFinish() {
        if wasSkipped {
            appState.markBaselineQuizPrompted()
        } else {
            appState.recordBaselineQuiz(score: score, totalQuestions: questions.count)
        }
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
            Text(wasSkipped ? "No worries — you can jump right in!" : "Quiz done — thanks for learning with Tideline!")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
            if let finalScore {
                Text("You scored \(finalScore) out of \(questions.count).")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Continue to Tideline") { confirmFinish() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    BaselineQuizView()
        .environmentObject(AppState())
}
