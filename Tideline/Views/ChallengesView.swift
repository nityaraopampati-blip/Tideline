import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var challengeProgress: [String: Int] = LocalStore.shared.challengeProgress
    @State private var levelState: LevelState = LocalStore.shared.levelState
    @State private var selectedBadge: Badge?

    private var badges: [Badge] {
        ChallengeCatalog.badges(scanHistory: appState.scanHistory, levelState: levelState)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    levelCard
                    featuredCard
                    moreChallengesSection
                    badgesSection
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                challengeProgress = LocalStore.shared.challengeProgress
                levelState = LocalStore.shared.levelState
            }
        }
        .sheet(item: $selectedBadge) { badge in
            badgeDetail(badge)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            EyebrowText(text: "This Week")
            Text("Challenges & Badges")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
        }
        .padding(.top, 8)
    }

    // MARK: - Level

    private var levelCard: some View {
        TideCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [TideTheme.seafoam, TideTheme.deep], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 46, height: 46)
                    Text("\(levelState.levelNumber)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Level \(levelState.levelNumber)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(TideTheme.ink)
                    ProgressBar(progress: Double(levelState.xp) / Double(levelState.cap))
                    Text("\(levelState.xp) / \(levelState.cap) XP")
                        .font(.system(size: 10.5))
                        .foregroundStyle(TideTheme.inkSoft)
                }
            }
        }
    }

    // MARK: - Featured challenge

    private var featuredCard: some View {
        let challenge = ChallengeCatalog.featured
        let have = challengeProgress[challenge.id] ?? 0
        let done = have >= challenge.goal

        return VStack(alignment: .leading, spacing: 10) {
            EyebrowText(text: "This Week's Challenge")
            HStack {
                Text(challenge.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                Spacer()
                Text(done ? "Completed ✓" : "\(have) / \(challenge.goal)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(TideTheme.tide)
            }
            ProgressBar(progress: Double(have) / Double(challenge.goal))
            Button(done ? "✓ Completed this week" : challenge.buttonLabel) {
                bump(challenge)
            }
            .buttonStyle(TideCTAButtonStyle(tint: done ? TideTheme.inkSoft : TideTheme.tide))
            .disabled(done)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [TideTheme.seafoamLight, TideTheme.surface2], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - More challenges

    private var moreChallengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More Challenges")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            VStack(spacing: 10) {
                ForEach(ChallengeCatalog.more) { challenge in
                    moreChallengeCard(challenge)
                }
            }
        }
    }

    private func moreChallengeCard(_ challenge: Challenge) -> some View {
        let have = challengeProgress[challenge.id] ?? 0
        let done = have >= challenge.goal
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(challenge.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                Spacer()
                Text(done ? "Completed ✓" : "\(have) / \(challenge.goal)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(TideTheme.tide)
            }
            ProgressBar(progress: Double(have) / Double(challenge.goal))
            Button(done ? "✓ Completed" : "+ Log progress") { bump(challenge) }
                .buttonStyle(TideOutlineButtonStyle(tint: done ? TideTheme.inkSoft : TideTheme.tide))
                .disabled(done)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func bump(_ challenge: Challenge) {
        let updated = LocalStore.shared.bumpChallenge(challenge.id, goal: challenge.goal, xpReward: challenge.xpReward)
        challengeProgress[challenge.id] = updated
        levelState = LocalStore.shared.levelState
    }

    // MARK: - Badges

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Badges")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 14) {
                ForEach(badges) { badge in
                    Button {
                        selectedBadge = badge
                    } label: {
                        VStack(spacing: 6) {
                            badgeCircle(badge, size: 52, iconSize: 20)
                            Text(badge.name)
                                .font(.system(size: 9))
                                .foregroundStyle(TideTheme.inkSoft)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func badgeCircle(_ badge: Badge, size: CGFloat, iconSize: CGFloat) -> some View {
        let earned = badge.isEarned()
        return ZStack {
            Circle()
                .fill(
                    earned
                        ? AnyShapeStyle(LinearGradient(colors: [TideTheme.seafoam, TideTheme.tide], startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(TideTheme.surface2)
                )
                .frame(width: size, height: size)
            Image(systemName: badge.icon)
                .font(.system(size: iconSize))
                .foregroundStyle(earned ? .white : TideTheme.inkSoft.opacity(0.5))
        }
    }

    private func badgeDetail(_ badge: Badge) -> some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 8)
            badgeCircle(badge, size: 74, iconSize: 30)
            Text(badge.name)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text(badge.isEarned() ? "✓ Earned" : "Not earned yet")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(badge.isEarned() ? TideTheme.tide : TideTheme.inkSoft)
            Text(badge.description)
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            Spacer()
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}

/// Shared thin progress bar for challenges and level XP.
private struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(TideTheme.line)
                Capsule()
                    .fill(LinearGradient(colors: [TideTheme.seafoam, TideTheme.tide], startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * min(1, max(0, progress)))
            }
        }
        .frame(height: 8)
    }
}

#Preview {
    ChallengesView()
        .environmentObject(AppState())
}
