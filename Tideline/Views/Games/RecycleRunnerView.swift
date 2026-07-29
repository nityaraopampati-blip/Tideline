import SwiftUI
import Combine

struct RecycleRunnerView: View {
    @State private var phase: Phase = .start
    @State private var score = 0
    @State private var lives = 3
    @State private var lane = 1
    @State private var jumpTicksRemaining = 0
    @State private var invulnTicksRemaining = 0
    @State private var objects: [RunnerObject] = []
    @State private var speed: CGFloat = 3.2
    @State private var spawnTicksRemaining = 18

    private enum Phase {
        case start
        case playing
        case finished
    }

    private let fieldWidth: CGFloat = 340
    private let fieldHeight: CGFloat = 420
    private var playerRowY: CGFloat { fieldHeight - 90 }
    private var laneWidth: CGFloat { fieldWidth / 3 }
    private var isJumping: Bool { jumpTicksRemaining > 0 }
    private var bestScore: Int? { LocalStore.shared.bestScore(for: .recycleRunner) }

    private let trashEmoji = ["🧴", "🥤", "🍾", "🥫", "🛍️", "🍟", "🥡", "🧃"]
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
        .navigationTitle("Recycle Runner")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in tick() }
    }

    // MARK: - Start

    private var startCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "figure.run")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: 0xE8A93B))
            Text("Recycle Runner")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text("Switch lanes to collect trash, jump over the bins. Three lives — how high can you score?")
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
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0xE8A93B)))
        }
    }

    // MARK: - Playing

    private var playingView: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Score: \(score)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(TideTheme.deep)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i < lives ? Color(hex: 0xE8A93B) : TideTheme.line)
                            .frame(width: 9, height: 9)
                    }
                }
            }
            .frame(width: fieldWidth)

            playfield

            HStack(spacing: 10) {
                controlButton(icon: "chevron.left") { moveLane(-1) }
                Button("JUMP") { jump() }
                    .buttonStyle(TideCTAButtonStyle(tint: TideTheme.coral))
                controlButton(icon: "chevron.right") { moveLane(1) }
            }
            .frame(width: fieldWidth)
        }
    }

    private var playfield: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: 0x7CC576))
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { i in
                    if i > 0 {
                        Rectangle().fill(Color.white.opacity(0.35)).frame(width: 2)
                    }
                    Spacer()
                }
            }
            ForEach(objects) { object in
                if !object.collected {
                    runnerObjectView(object)
                        .position(x: laneWidth * (CGFloat(object.lane) + 0.5), y: object.y)
                }
            }
            Text("🏃")
                .font(.system(size: 34))
                .scaleEffect(isJumping ? 1.15 : 1)
                .offset(y: isJumping ? -22 : 0)
                .position(x: laneWidth * (CGFloat(lane) + 0.5), y: playerRowY)
                .opacity(invulnTicksRemaining > 0 && invulnTicksRemaining % 6 < 3 ? 0.4 : 1)
        }
        .frame(width: fieldWidth, height: fieldHeight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }

    private func runnerObjectView(_ object: RunnerObject) -> some View {
        Group {
            if object.kind == .obstacle {
                VStack(spacing: 1) {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(.white)
                    Text("BIN").font(.system(size: 8, weight: .bold)).foregroundStyle(.white)
                }
                .frame(width: 44, height: 40)
                .background(TideTheme.deep)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                Text(object.emoji).font(.system(size: 26))
            }
        }
    }

    private func controlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(TideTheme.surface2)
                .foregroundStyle(TideTheme.deep)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(TidePressableStyle())
    }

    // MARK: - Game loop

    private func startGame() {
        score = 0
        lives = 3
        lane = 1
        jumpTicksRemaining = 0
        invulnTicksRemaining = 0
        objects = []
        speed = 3.2
        spawnTicksRemaining = 18
        phase = .playing
    }

    private func moveLane(_ delta: Int) {
        guard phase == .playing else { return }
        lane = max(0, min(2, lane + delta))
    }

    private func jump() {
        guard phase == .playing, jumpTicksRemaining == 0 else { return }
        jumpTicksRemaining = 14
    }

    private func tick() {
        guard phase == .playing else { return }

        speed += 0.006
        if jumpTicksRemaining > 0 { jumpTicksRemaining -= 1 }
        if invulnTicksRemaining > 0 { invulnTicksRemaining -= 1 }

        spawnTicksRemaining -= 1
        if spawnTicksRemaining <= 0 {
            spawnObject()
            spawnTicksRemaining = max(14, Int(32 - speed * 1.5))
        }

        for i in objects.indices {
            objects[i].y += speed
        }

        for i in objects.indices {
            let object = objects[i]
            guard !object.collected, object.lane == lane else { continue }
            guard object.y > playerRowY - 26, object.y < playerRowY + 26 else { continue }

            if object.kind == .trash {
                objects[i].collected = true
                score += 10
            } else if isJumping {
                objects[i].collected = true
            } else if invulnTicksRemaining <= 0 {
                objects[i].collected = true
                lives -= 1
                invulnTicksRemaining = 24
                if lives <= 0 {
                    endGame()
                    return
                }
            }
        }

        objects.removeAll { $0.y > fieldHeight + 40 || $0.collected }
    }

    private func spawnObject() {
        let lane = Int.random(in: 0..<3)
        let isTrash = Double.random(in: 0...1) < 0.6
        let emoji = isTrash ? trashEmoji.randomElement()! : ""
        objects.append(RunnerObject(lane: lane, y: -30, kind: isTrash ? .trash : .obstacle, emoji: emoji))
    }

    private func endGame() {
        LocalStore.shared.recordScore(score, for: .recycleRunner)
        phase = .finished
    }

    // MARK: - Finished

    private var resultView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: 0xE8A93B))
            Text("\(score)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text("points")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
            Spacer()
            Button("Play Again") { startGame() }
                .buttonStyle(TideCTAButtonStyle(tint: Color(hex: 0xE8A93B)))
            Button("Done") { phase = .start }
                .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.inkSoft))
        }
    }
}

#Preview {
    NavigationStack { RecycleRunnerView() }
}
