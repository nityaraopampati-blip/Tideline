import SwiftUI

struct TrueFalseQuizView: View {
    @State private var phase: Phase = .start
    @State private var questions: [TrueFalseQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: Bool?
    @State private var score = 0

    private enum Phase {
        case start
        case playing
        case finished
    }

    private var bestScore: Int? { LocalStore.shared.bestScore(for: .trueFalseQuiz) }

    var body: some View {
        Group {
            switch phase {
            case .start:
                startCard
            case .playing:
                playingView
            case .finished:
                resultView
            }
        }
        .padding()
        .background(TideTheme.background.ignoresSafeArea())
        .navigationTitle("True or False")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var startCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: 0xFF6B4A))
            Text("True or False")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text("8 quick statements about plastic and recycling. Answer true or false, and we'll explain the real answer either way.")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            if let bestScore {
                Text("Best: \(bestScore)/8")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TideTheme.tide)
            }
            Spacer()
            Button("Play") { startGame() }
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0xFF6B4A)))
        }
    }

    private var playingView: some View {
        VStack(alignment: .leading, spacing: 20) {
            progressRow

            TideCard(padding: 24) {
                Text(questions[currentIndex].statement)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            }

            HStack(spacing: 12) {
                answerButton(label: "True", value: true)
                answerButton(label: "False", value: false)
            }

            if let selectedAnswer {
                explanationCard(selected: selectedAnswer)
            }

            Spacer()

            if selectedAnswer != nil {
                Button(currentIndex == questions.count - 1 ? "See Results" : "Next Question") {
                    advance()
                }
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0xFF6B4A)))
            }
        }
    }

    private var progressRow: some View {
        HStack(spacing: 5) {
            ForEach(0..<questions.count, id: \.self) { index in
                Capsule()
                    .fill(index < currentIndex ? TideTheme.seafoam : (index == currentIndex ? Color(hex: 0xFF6B4A) : TideTheme.line))
                    .frame(height: 5)
            }
        }
    }

    private func answerButton(label: String, value: Bool) -> some View {
        let question = questions[currentIndex]
        let isCorrectChoice = value == question.answer
        let isSelected = selectedAnswer == value

        return Button {
            guard selectedAnswer == nil else { return }
            selectedAnswer = value
            if isCorrectChoice { score += 1 }
        } label: {
            Text(label)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(answerBackground(isSelected: isSelected, isCorrectChoice: isCorrectChoice))
                .foregroundStyle(TideTheme.ink)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(selectedAnswer != nil)
        .buttonStyle(TidePressableStyle())
    }

    private func answerBackground(isSelected: Bool, isCorrectChoice: Bool) -> Color {
        guard selectedAnswer != nil else { return TideTheme.surface2 }
        if isCorrectChoice { return TideTheme.seafoamLight }
        if isSelected { return TideTheme.coralLight }
        return TideTheme.surface2
    }

    private func explanationCard(selected: Bool) -> some View {
        let question = questions[currentIndex]
        let wasCorrect = selected == question.answer
        return VStack(alignment: .leading, spacing: 6) {
            Text(wasCorrect ? "Correct!" : "Actually, \(question.answer ? "true" : "false")")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(wasCorrect ? TideTheme.deep : TideTheme.coral)
            Text(question.explanation)
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
        }
        .padding()
        .background(wasCorrect ? TideTheme.seafoamLight : TideTheme.coralLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var resultView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: 0xFF6B4A))
            Text("\(score)/\(questions.count)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text(resultMessage)
                .font(.system(size: 14))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
            Button("Play Again") { startGame() }
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0xFF6B4A)))
            Button("Done") { phase = .start }
                .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.inkSoft))
        }
    }

    private var resultMessage: String {
        if score == questions.count {
            return "Perfect score — you know your microplastics."
        } else if Double(score) >= Double(questions.count) * 0.6 {
            return "Solid grasp of the basics, with a little more to learn."
        } else {
            return "Worth a replay — a few surprising facts in there."
        }
    }

    private func startGame() {
        questions = Array(GameContent.trueFalsePool.shuffled().prefix(8))
        currentIndex = 0
        selectedAnswer = nil
        score = 0
        phase = .playing
    }

    private func advance() {
        if currentIndex == questions.count - 1 {
            LocalStore.shared.recordScore(score, for: .trueFalseQuiz)
            let perfectBonus = score == questions.count ? 20 : 0
            LocalStore.shared.addXP(score * 5 + perfectBonus)
            phase = .finished
        } else {
            currentIndex += 1
            selectedAnswer = nil
        }
    }
}

#Preview {
    NavigationStack { TrueFalseQuizView() }
}
