import SwiftUI

/// Full-screen celebration burst shown when a challenge is completed — a mix
/// of colorful confetti squares plus bottle/turtle emoji, tying the "recycle
/// less plastic" theme into the celebration itself.
struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var pieces: [ConfettiPiece] = []
    @State private var fallen = false

    private let colors: [Color] = [
        TideTheme.tide, TideTheme.coral, TideTheme.seafoam,
        Color(hex: 0xE8A93B), Color(hex: 0x3B5FE8), TideTheme.deep,
    ]
    private let emoji = ["🧴", "🐢"]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    pieceView(piece)
                        .position(
                            x: piece.xFraction * geo.size.width,
                            y: fallen ? geo.size.height + 60 : -60
                        )
                        .rotationEffect(.degrees(fallen ? piece.rotation : 0))
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: fallen
                        )
                }
            }
            .allowsHitTesting(false)
            .onChange(of: isActive) { _, newValue in
                if newValue { fire(in: geo.size) }
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func pieceView(_ piece: ConfettiPiece) -> some View {
        switch piece.kind {
        case .square(let color):
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 9 * piece.scale, height: 14 * piece.scale)
        case .emoji(let symbol):
            Text(symbol)
                .font(.system(size: 22 * piece.scale))
        }
    }

    private func fire(in size: CGSize) {
        fallen = false
        var newPieces: [ConfettiPiece] = (0..<28).map { _ in
            ConfettiPiece(
                kind: .square(colors.randomElement() ?? TideTheme.tide),
                xFraction: .random(in: 0...1),
                delay: .random(in: 0...0.3),
                duration: .random(in: 1.6...2.6),
                rotation: .random(in: -280...280),
                scale: .random(in: 0.8...1.3)
            )
        }
        newPieces += (0..<8).map { _ in
            ConfettiPiece(
                kind: .emoji(emoji.randomElement() ?? "🧴"),
                xFraction: .random(in: 0.06...0.94),
                delay: .random(in: 0...0.3),
                duration: .random(in: 1.9...2.7),
                rotation: .random(in: -50...50),
                scale: .random(in: 0.9...1.4)
            )
        }
        pieces = newPieces

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            fallen = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            isActive = false
            pieces = []
            fallen = false
        }
    }
}

private struct ConfettiPiece: Identifiable {
    enum Kind {
        case square(Color)
        case emoji(String)
    }

    let id = UUID()
    let kind: Kind
    let xFraction: CGFloat
    let delay: Double
    let duration: Double
    let rotation: Double
    let scale: CGFloat
}
