import SwiftUI

/// A "Paper Toss"-style basketball game — swipe up on the plastic item to
/// arc it into the recycle bin. Distance and direction of the swipe set the
/// shot's power and aim; simple projectile physics carry it the rest of the
/// way.
struct RecycleHoopsView: View {
    @State private var phase: Phase = .start
    @State private var shotNumber = 0
    @State private var score = 0
    @State private var streak = 0
    @State private var makes = 0

    @State private var ballEmoji = "🧴"
    @State private var ballPos: CGPoint = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isFlying = false
    @State private var velocity: CGVector = .zero
    @State private var hoopCenterX: CGFloat = 170
    @State private var toast: Toast?
    @State private var ballRotation: Double = 0

    private enum Phase {
        case start
        case playing
        case finished
    }

    private struct Toast: Identifiable {
        let id = UUID()
        let text: String
        let made: Bool
    }

    private let totalShots = 8
    private let fieldWidth: CGFloat = 340
    private let fieldHeight: CGFloat = 460
    private let hoopY: CGFloat = 92
    private let hoopBandHeight: CGFloat = 36
    private let hoopHalfWidth: CGFloat = 34
    private let gravity: CGFloat = 0.55
    private var floorY: CGFloat { fieldHeight - 66 }
    private var restingBallPos: CGPoint { CGPoint(x: fieldWidth / 2, y: floorY) }
    private var bestScore: Int? { LocalStore.shared.bestScore(for: .recycleHoops) }

    private let trashEmoji = ["🧴", "🥤", "🍾", "🥫", "🛍️", "🧃", "🥡"]
    private let timer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

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
        .navigationTitle("Recycle Hoops")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in tick() }
    }

    // MARK: - Start

    private var startCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "basketball.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: 0xFF7043))
            Text("Recycle Hoops")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text("Swipe up on the plastic to shoot it into the bin. \(totalShots) shots — chain makes together for a streak bonus.")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            if let bestScore {
                Text("Best score: \(bestScore)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TideTheme.tide)
            }
            Spacer()
            Button("Play") { startGame() }
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0xFF7043)))
        }
    }

    // MARK: - Playing

    private var playingView: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Shot \(min(shotNumber + 1, totalShots))/\(totalShots)")
                Spacer()
                if streak >= 2 {
                    Text("🔥 Streak x\(streak)")
                        .foregroundStyle(Color(hex: 0xE8A93B))
                }
                Spacer()
                Text("Score: \(score)")
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(TideTheme.inkSoft)
            .frame(width: fieldWidth)

            court

            Text(isDragging || isFlying ? " " : "👆 Swipe up on the item to shoot")
                .font(.system(size: 12))
                .foregroundStyle(TideTheme.inkSoft)
        }
    }

    private var court: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [TideTheme.seafoamLight, Color(.systemBackground)], startPoint: .top, endPoint: .bottom))

            binView

            if let toast {
                toastView(toast)
                    .position(x: hoopCenterX, y: hoopY + hoopBandHeight + 20)
            }

            Color.clear
                .frame(width: 120, height: 120)
                .contentShape(Rectangle())
                .position(ballPos)
                .gesture(shotGesture)

            Text(ballEmoji)
                .font(.system(size: 34))
                .rotationEffect(.degrees(ballRotation))
                .position(ballPos)
                .allowsHitTesting(false)
        }
        .frame(width: fieldWidth, height: fieldHeight)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    private var binView: some View {
        VStack(spacing: 0) {
            ZStack {
                Ellipse()
                    .fill(TideTheme.deep)
                    .frame(width: hoopHalfWidth * 2, height: 16)
                Ellipse()
                    .fill(Color(.systemBackground))
                    .frame(width: hoopHalfWidth * 2 - 10, height: 9)
            }
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(TideTheme.tide)
                .frame(width: hoopHalfWidth * 2 - 6, height: 46)
                .overlay(Text("♻️").font(.system(size: 18)))
        }
        .position(x: hoopCenterX, y: hoopY + 20)
    }

    private func toastView(_ toast: Toast) -> some View {
        Text(toast.text)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(toast.made ? TideTheme.tide : TideTheme.coral)
            .clipShape(Capsule())
            .transition(.scale.combined(with: .opacity))
    }

    private var shotGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                guard !isFlying else { return }
                isDragging = true
                dragOffset = value.translation
                ballPos = CGPoint(x: restingBallPos.x + value.translation.width, y: restingBallPos.y + value.translation.height)
            }
            .onEnded { value in
                guard !isFlying else { return }
                isDragging = false
                shoot(translation: value.translation)
            }
    }

    // MARK: - Physics

    private func shoot(translation: CGSize) {
        let upSwipe = max(0, -translation.height)
        let power = min(1.15, max(0.28, upSwipe / 220))
        let vy = -(6 + power * 13)
        let vx = max(-6, min(6, translation.width * 0.045))

        ballPos = restingBallPos
        velocity = CGVector(dx: vx, dy: vy)
        isFlying = true
    }

    private func tick() {
        guard isFlying else { return }

        velocity.dy += gravity
        ballPos.x += velocity.dx
        ballPos.y += velocity.dy
        ballRotation += 12

        let inHoopBand = ballPos.y >= hoopY && ballPos.y <= hoopY + hoopBandHeight
        let inHoopX = abs(ballPos.x - hoopCenterX) <= hoopHalfWidth - 12
        if velocity.dy > 0 && inHoopBand && inHoopX {
            resolveShot(made: true)
            return
        }

        if ballPos.y >= floorY && velocity.dy > 0 {
            resolveShot(made: false)
        }
    }

    private func resolveShot(made: Bool) {
        isFlying = false
        if made {
            makes += 1
            streak += 1
            let streakBonus = min(streak - 1, 4) * 5
            score += 10 + streakBonus
            toast = Toast(text: streakBonus > 0 ? "SWISH! +\(10 + streakBonus)" : "SWISH! +10", made: true)
        } else {
            streak = 0
            toast = Toast(text: "Miss", made: false)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation { toast = nil }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            advance()
        }
    }

    private func advance() {
        shotNumber += 1
        if shotNumber >= totalShots {
            endGame()
        } else {
            setUpShot()
        }
    }

    private func endGame() {
        LocalStore.shared.recordScore(score, for: .recycleHoops)
        let perfectBonus = makes == totalShots ? 20 : 0
        LocalStore.shared.addXP(makes * 8 + perfectBonus)
        phase = .finished
    }

    // MARK: - Setup

    private func setUpShot() {
        ballEmoji = trashEmoji.randomElement() ?? "🧴"
        hoopCenterX = CGFloat.random(in: fieldWidth * 0.32...fieldWidth * 0.68)
        ballPos = restingBallPos
        dragOffset = .zero
        ballRotation = 0
        velocity = .zero
        isFlying = false
        isDragging = false
    }

    private func startGame() {
        shotNumber = 0
        score = 0
        streak = 0
        makes = 0
        toast = nil
        setUpShot()
        phase = .playing
    }

    // MARK: - Finished

    private var resultView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: 0xFF7043))
            Text("\(score)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text("\(makes)/\(totalShots) shots made")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
            Spacer()
            Button("Play Again") { startGame() }
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0xFF7043)))
            Button("Done") { phase = .start }
                .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.inkSoft))
        }
    }
}

#Preview {
    NavigationStack { RecycleHoopsView() }
}
