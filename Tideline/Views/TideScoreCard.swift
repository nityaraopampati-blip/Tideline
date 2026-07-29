import SwiftUI

/// The Home screen's circular "Tide Score" gauge, matching the prototype's
/// gauge-card — score and message are real, computed from scan history
/// (see ImpactStats); "Receding nicely" is a fixed tagline in the original
/// design, shown regardless of score.
struct TideScoreCard: View {
    let state: TideScoreState

    private var scoreText: String {
        if case .scored(let score, _) = state { return "\(score)" }
        return "—"
    }

    private var progress: Double {
        if case .scored(let score, _) = state { return Double(score) / 100 }
        return 0
    }

    private var message: String {
        switch state {
        case .noHistory:
            return "No items logged yet — scan or add your first product to start tracking your footprint."
        case .scored(_, let message):
            return message
        }
    }

    var body: some View {
        TideCard(padding: 20) {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(TideTheme.line, lineWidth: 9)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: [TideTheme.deep, TideTheme.seafoam], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.7), value: progress)
                    VStack(spacing: 0) {
                        Text(scoreText)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(TideTheme.ink)
                        Text("SCORE")
                            .font(.system(size: 8, weight: .semibold))
                            .tracking(0.5)
                            .foregroundStyle(TideTheme.inkSoft)
                    }
                }
                .frame(width: 90, height: 90)

                VStack(alignment: .leading, spacing: 4) {
                    EyebrowText(text: "Tide Score")
                    Text("Receding nicely")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(TideTheme.ink)
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundStyle(TideTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TideScoreCard(state: .noHistory)
        TideScoreCard(state: .scored(score: 82, message: "Your plastic footprint is well below average this week — the tide's going out. Keep it up."))
    }
    .padding()
    .background(TideTheme.background)
}
