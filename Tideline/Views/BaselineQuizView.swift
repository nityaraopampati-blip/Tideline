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
            .background(TideTheme.background.ignoresSafeArea())
            .navigationTitle("Quick Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showFinishedAcknowledgment {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Skip") { showSkipConfirmation = true }
                            .foregroundStyle(TideTheme.inkSoft)
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
            progressRow

            TideCard(padding: 22) {
                Text(currentQuestion.question)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                    .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
            }

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
                .buttonStyle(TideCTAButtonStyle())
            }
        }
    }

    private var progressRow: some View {
        HStack(spacing: 5) {
            ForEach(0..<questions.count, id: \.self) { index in
                Capsule()
                    .fill(segmentColor(for: index))
                    .frame(height: 5)
            }
        }
        .padding(.top, 4)
    }

    private func segmentColor(for index: Int) -> Color {
        if index < currentIndex { return TideTheme.seafoam }
        if index == currentIndex { return TideTheme.tide }
        return TideTheme.line
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
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                if selectedChoice != nil && isCorrectChoice {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(TideTheme.tide)
                } else if isSelected {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(TideTheme.coral)
                }
            }
            .padding()
            .background(choiceBackground(isSelected: isSelected, isCorrectChoice: isCorrectChoice))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .foregroundStyle(TideTheme.ink)
        .disabled(selectedChoice != nil)
        .buttonStyle(TidePressableStyle())
    }

    private func choiceBackground(isSelected: Bool, isCorrectChoice: Bool) -> Color {
        guard selectedChoice != nil else { return TideTheme.surface2 }
        if isCorrectChoice { return TideTheme.seafoamLight }
        if isSelected { return TideTheme.coralLight }
        return TideTheme.surface2
    }

    private func explanationView(selected: String) -> some View {
        let wasCorrect = letterForChoice(selected) == currentQuestion.correctAnswer
        return VStack(alignment: .leading, spacing: 6) {
            Text(wasCorrect ? "Correct!" : "Not quite")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(wasCorrect ? TideTheme.deep : TideTheme.coral)
            Text(currentQuestion.explanation)
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
        }
        .padding()
        .background(wasCorrect ? TideTheme.seafoamLight : TideTheme.coralLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                .foregroundStyle(TideTheme.tide)
            Text(wasSkipped ? "No worries — you can jump right in!" : "Quiz done — thanks for learning with Tideline!")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
                .multilineTextAlignment(.center)
            if let finalScore {
                Text("You scored \(finalScore) out of \(questions.count).")
                    .foregroundStyle(TideTheme.inkSoft)
            }
            Spacer()
            Button("Continue to Tideline") { confirmFinish() }
                .buttonStyle(TideCTAButtonStyle())
        }
        .padding()
    }
}

#Preview {
    BaselineQuizView()
        .environmentObject(AppState())
}
