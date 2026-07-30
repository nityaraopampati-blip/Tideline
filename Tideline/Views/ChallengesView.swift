import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var challengeProgress: [String: Int] = LocalStore.shared.challengeProgress
    @State private var levelState: LevelState = LocalStore.shared.levelState
    @State private var selectedBadge: Badge?
    @State private var showConfetti = false
    @State private var pendingProofChallenge: Challenge?
    @State private var showCamera = false

    private var badges: [Badge] {
        ChallengeCatalog.badges(scanHistory: appState.scanHistory, levelState: levelState)
    }

    private func isDone(_ challenge: Challenge) -> Bool {
        (challengeProgress[challenge.id] ?? 0) >= challenge.goal
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
        .overlay(ConfettiView(isActive: $showConfetti))
        .sheet(item: $selectedBadge) { badge in
            badgeDetail(badge)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureRepresentable(
                onCapture: { _ in handleProofCaptured() },
                onCancel: { showCamera = false; pendingProofChallenge = nil }
            )
            .ignoresSafeArea()
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
        let persona = LevelTitles.persona(for: levelState.levelNumber)
        let tint = Color(hex: persona.colorHex)
        return TideCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [tint.opacity(0.16), tint.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 46, height: 46)
                    Text(persona.emoji)
                        .font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Level \(levelState.levelNumber) · \(persona.name)")
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

    @ViewBuilder
    private var featuredCard: some View {
        let challenge = ChallengeCatalog.featured
        if isDone(challenge) {
            completedBanner(name: challenge.name)
        } else {
            let have = challengeProgress[challenge.id] ?? 0
            VStack(alignment: .leading, spacing: 10) {
                EyebrowText(text: "This Week's Challenge")
                HStack {
                    Text(challenge.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(TideTheme.ink)
                    Spacer()
                    Text("\(have) / \(challenge.goal)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(TideTheme.tide)
                }
                ProgressBar(progress: Double(have) / Double(challenge.goal))
                Text("📸 Snap a quick photo each time to confirm you actually did it.")
                    .font(.system(size: 10.5))
                    .foregroundStyle(TideTheme.inkSoft)
                Button(challenge.buttonLabel) {
                    requestProof(for: challenge)
                }
                .buttonStyle(TideCTAButtonStyle(tint: TideTheme.tide))
            }
            .padding(16)
            .background(
                LinearGradient(colors: [TideTheme.seafoamLight, TideTheme.surface2], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func completedBanner(name: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(TideTheme.tide)
            Text("\(name) — completed this week! 🎉")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(TideTheme.deep)
        }
        .padding(14)
        .background(TideTheme.seafoamLight)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - More challenges

    private var remainingMoreChallenges: [Challenge] {
        ChallengeCatalog.more.filter { !isDone($0) }
    }

    @ViewBuilder
    private var moreChallengesSection: some View {
        if !remainingMoreChallenges.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("More Challenges")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                VStack(spacing: 10) {
                    ForEach(remainingMoreChallenges) { challenge in
                        moreChallengeCard(challenge)
                    }
                }
            }
        }
    }

    private func moreChallengeCard(_ challenge: Challenge) -> some View {
        let have = challengeProgress[challenge.id] ?? 0
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(challenge.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                Spacer()
                Text("\(have) / \(challenge.goal)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(TideTheme.tide)
            }
            ProgressBar(progress: Double(have) / Double(challenge.goal))
            Button("📸 Log progress") { requestProof(for: challenge) }
                .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.tide))
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// Requires a photo before logging progress, so a challenge can't be
    /// bumped without actually showing proof it happened.
    private func requestProof(for challenge: Challenge) {
        pendingProofChallenge = challenge
        showCamera = true
    }

    private func handleProofCaptured() {
        showCamera = false
        if let challenge = pendingProofChallenge {
            bump(challenge)
        }
        pendingProofChallenge = nil
    }

    private func bump(_ challenge: Challenge) {
        let wasDone = (challengeProgress[challenge.id] ?? 0) >= challenge.goal
        let updated = LocalStore.shared.bumpChallenge(challenge.id, goal: challenge.goal, xpReward: challenge.xpReward)
        challengeProgress[challenge.id] = updated
        levelState = LocalStore.shared.levelState
        if !wasDone && updated >= challenge.goal {
            showConfetti = true
        }
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
        let tint = Color(hex: badge.colorHex)
        return ZStack {
            Circle()
                .fill(
                    earned
                        ? AnyShapeStyle(LinearGradient(colors: [tint.opacity(0.85), tint], startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(tint.opacity(0.14))
                )
                .frame(width: size, height: size)
            Image(systemName: badge.icon)
                .font(.system(size: iconSize))
                .foregroundStyle(earned ? .white : tint.opacity(0.55))
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
