import SwiftUI

enum GameDestination: Hashable {
    case trueFalseQuiz
    case sortThePlastic
    case recycleRunner
    case plasticGo
}

struct LearnHubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    GameCard(
                        destination: .trueFalseQuiz,
                        icon: "checkmark.circle.fill",
                        gradient: [Color(hex: 0xFFE1D5), Color(hex: 0xFF6B4A)],
                        title: "True or False",
                        subtitle: "Test what you actually know about plastic and recycling.",
                        bestLabel: bestLabel(for: .trueFalseQuiz, suffix: "/8")
                    )
                    GameCard(
                        destination: .sortThePlastic,
                        icon: "arrow.3.trianglepath",
                        gradient: [Color(hex: 0xE8F5E9), TideTheme.deep],
                        title: "Sort the Plastic",
                        subtitle: "Drag each item into the right bin before time's up.",
                        bestLabel: bestLabel(for: .sortThePlastic, suffix: "/10")
                    )
                    GameCard(
                        destination: .recycleRunner,
                        icon: "figure.run",
                        gradient: [Color(hex: 0xFFE9B0), Color(hex: 0xE8A93B)],
                        title: "Recycle Runner",
                        subtitle: "Dodge the bins, collect the trash, beat your best score.",
                        bestLabel: bestLabel(for: .recycleRunner, suffix: nil)
                    )
                    GameCard(
                        destination: .plasticGo,
                        icon: "camera.viewfinder",
                        gradient: [Color(hex: 0xD6E4FF), Color(hex: 0x3B5FE8)],
                        title: "Plastic-Go",
                        subtitle: "Log and photograph plastic you spot while out and about.",
                        bestLabel: nil
                    )
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: GameDestination.self) { destination in
                switch destination {
                case .trueFalseQuiz:
                    TrueFalseQuizView()
                case .sortThePlastic:
                    SortThePlasticView()
                case .recycleRunner:
                    RecycleRunnerView()
                case .plasticGo:
                    PlasticGoView()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            EyebrowText(text: "Play & Learn")
            Text("Pick a Game")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
        }
        .padding(.top, 8)
    }

    private func bestLabel(for game: LocalStore.GameID, suffix: String?) -> String {
        guard let best = LocalStore.shared.bestScore(for: game) else { return "Not played yet" }
        if let suffix {
            return "Best: \(best)\(suffix)"
        }
        return "Best score: \(best)"
    }
}

private struct GameCard: View {
    let destination: GameDestination
    let icon: String
    let gradient: [Color]
    let title: String
    let subtitle: String
    let bestLabel: String?

    var body: some View {
        NavigationLink(value: destination) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(TideTheme.ink)
                    Text(subtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(TideTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    if let bestLabel {
                        Text(bestLabel.uppercased())
                            .font(.system(size: 9.5, weight: .semibold))
                            .tracking(0.4)
                            .foregroundStyle(TideTheme.tide)
                            .padding(.top, 2)
                    }
                }
                Spacer()
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TideTheme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(TidePressableStyle())
    }
}

#Preview {
    LearnHubView()
        .environmentObject(AppState())
}
