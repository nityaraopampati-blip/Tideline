import SwiftUI

struct SortThePlasticView: View {
    @State private var phase: Phase = .start
    @State private var items: [SortableItem] = []
    @State private var index = 0
    @State private var score = 0

    @State private var dragOffset: CGSize = .zero
    @State private var cardScale: CGFloat = 1
    @State private var cardOpacity: Double = 1
    @State private var currentDragLocation: CGPoint?
    @State private var recycleBinFrame: CGRect = .zero
    @State private var landfillBinFrame: CGRect = .zero
    @State private var toast: Toast?

    private enum Phase {
        case start
        case playing
        case finished
    }

    private struct Toast: Identifiable {
        let id = UUID()
        let correct: Bool
        let text: String
    }

    private let totalRounds = 10
    private var bestScore: Int? { LocalStore.shared.bestScore(for: .sortThePlastic) }

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
        .navigationTitle("Sort the Plastic")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Start

    private var startCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "arrow.3.trianglepath")
                .font(.system(size: 48))
                .foregroundStyle(TideTheme.deep)
            Text("Sort the Plastic")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text("Drag each item into the right bin — Recycle or Landfill. 10 items, one point each.")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            if let bestScore {
                Text("Best: \(bestScore)/\(totalRounds)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TideTheme.tide)
            }
            Spacer()
            Button("Play") { startGame() }
                .buttonStyle(TideCTAButtonStyle(tint: TideTheme.deep))
        }
    }

    // MARK: - Playing

    private var playingView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(min(index + 1, items.count))/\(items.count)")
                Spacer()
                Text("Score: \(score)")
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(TideTheme.inkSoft)

            Spacer()

            ZStack {
                if index < items.count {
                    itemCard(items[index])
                        .offset(dragOffset)
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                        .gesture(dragGesture)
                }
                if let toast {
                    toastView(toast)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 160)

            Spacer()

            HStack(spacing: 12) {
                binView(
                    label: "Recycle", icon: "arrow.3.trianglepath", tint: TideTheme.tide,
                    isOver: currentDragLocation.map { recycleBinFrame.contains($0) } ?? false
                )
                .background(frameReader($recycleBinFrame))
                binView(
                    label: "Landfill", icon: "trash.fill", tint: TideTheme.coral,
                    isOver: currentDragLocation.map { landfillBinFrame.contains($0) } ?? false
                )
                .background(frameReader($landfillBinFrame))
            }
        }
        .coordinateSpace(name: "board")
    }

    private func itemCard(_ item: SortableItem) -> some View {
        VStack(spacing: 10) {
            Text(item.emoji).font(.system(size: 46))
            Text(item.name)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
                .multilineTextAlignment(.center)
            Text(item.subtitle)
                .font(.system(size: 11))
                .foregroundStyle(TideTheme.inkSoft)
        }
        .padding(20)
        .frame(width: 190)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: TideTheme.cardShadow, radius: 10, y: 4)
    }

    private func binView(label: String, icon: String, tint: Color, isOver: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
            Text(label)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(isOver ? tint.opacity(0.22) : tint.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(tint, lineWidth: isOver ? 2.5 : 1.5))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.easeOut(duration: 0.15), value: isOver)
    }

    private func toastView(_ toast: Toast) -> some View {
        Text(toast.text)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(toast.correct ? TideTheme.tide : TideTheme.coral)
            .clipShape(Capsule())
            .transition(.scale.combined(with: .opacity))
    }

    private func frameReader(_ binding: Binding<CGRect>) -> some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { binding.wrappedValue = geo.frame(in: .named("board")) }
                .onChange(of: geo.size) { _, _ in binding.wrappedValue = geo.frame(in: .named("board")) }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .named("board"))
            .onChanged { value in
                dragOffset = value.translation
                currentDragLocation = value.location
            }
            .onEnded { value in
                let dropPoint = value.location
                if recycleBinFrame.contains(dropPoint) {
                    handleDrop(bin: true)
                } else if landfillBinFrame.contains(dropPoint) {
                    handleDrop(bin: false)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { dragOffset = .zero }
                }
                currentDragLocation = nil
            }
    }

    private func handleDrop(bin: Bool) {
        guard index < items.count else { return }
        let item = items[index]
        let correct = bin == item.recyclable
        if correct { score += 1 }
        toast = Toast(
            correct: correct,
            text: correct ? "Correct!" : "Actually \(item.recyclable ? "recyclable" : "landfill")"
        )

        withAnimation(.easeOut(duration: 0.25)) {
            cardScale = 0.4
            cardOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            index += 1
            dragOffset = .zero
            cardScale = 1
            cardOpacity = 1
            if index >= items.count {
                LocalStore.shared.recordScore(score, for: .sortThePlastic)
                let perfectBonus = score == items.count ? 20 : 0
                LocalStore.shared.addXP(score * 5 + perfectBonus)
                phase = .finished
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation { toast = nil }
        }
    }

    // MARK: - Finished

    private var resultView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(TideTheme.deep)
            Text("\(score)/\(items.count)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
            Text(resultMessage)
                .font(.system(size: 14))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
            Button("Play Again") { startGame() }
                .buttonStyle(TideCTAButtonStyle(tint: TideTheme.deep))
            Button("Done") { phase = .start }
                .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.inkSoft))
        }
    }

    private var resultMessage: String {
        if score == items.count {
            return "Flawless sorting — the recycling truck salutes you."
        } else if Double(score) >= Double(items.count) * 0.6 {
            return "Good instincts — a couple of tricky ones slipped through."
        } else {
            return "Recycling rules can be sneaky. Give it another pass."
        }
    }

    private func startGame() {
        items = Array(GameContent.sortPool.shuffled().prefix(totalRounds))
        index = 0
        score = 0
        dragOffset = .zero
        cardScale = 1
        cardOpacity = 1
        toast = nil
        phase = .playing
    }
}

#Preview {
    NavigationStack { SortThePlasticView() }
}
