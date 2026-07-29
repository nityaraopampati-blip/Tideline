import SwiftUI

/// Tideline's visual design system, matching the original design prototype
/// (tideline-project/index.html): a deep-green/seafoam palette with coral
/// and sand accents, Poppins-style bold headings, and soft rounded cards.
enum TideTheme {
    // MARK: Palette (hex values match the prototype's CSS custom properties)

    static let ink = Color(hex: 0x1F2A24)
    static let inkSoft = Color(hex: 0x6B8072)
    static let deep = Color(hex: 0x2E7D32)
    static let tide = Color(hex: 0x43A047)
    static let seafoam = Color(hex: 0x66BB6A)
    static let seafoamLight = Color(hex: 0xE8F5E9)
    static let surface2 = Color(hex: 0xF1F8F2)
    static let sand = Color(hex: 0xFFE0B2)
    static let coral = Color(hex: 0xFF7043)
    static let coralLight = Color(hex: 0xFFE0D6)
    static let line = Color(hex: 0xE3EDE5)

    static let background = LinearGradient(
        colors: [seafoamLight.opacity(0.6), Color(.systemBackground)],
        startPoint: .top, endPoint: .bottom
    )

    static let cardShadow = Color(hex: 0x2E7D32).opacity(0.08)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Small uppercase, letter-spaced label used above headings throughout the
/// prototype (e.g. "HOME", "TIDE SCORE").
struct EyebrowText: View {
    let text: String
    var color: Color = TideTheme.tide

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .tracking(1.6)
            .foregroundStyle(color)
    }
}

/// The rounded, softly-shadowed white card used for every grouped section.
struct TideCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: TideTheme.cardShadow, radius: 8, y: 3)
    }
}

/// Primary call-to-action button style, matching `.cta-btn` — solid tide
/// green, bold white label, fully rounded corners.
struct TideCTAButtonStyle: ButtonStyle {
    var tint: Color = TideTheme.tide

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(tint)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Outline variant, matching `.cta-btn.outline`.
struct TideOutlineButtonStyle: ButtonStyle {
    var tint: Color = TideTheme.tide

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(tint)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(tint, lineWidth: 1.4)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Cards that gently scale down on tap, matching the prototype's tactile
/// press feedback on every interactive row.
struct TidePressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
