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

    /// Nudges brightness up or down while preserving hue/saturation — used to
    /// turn a single tint into a punchy two-stop gradient for buttons.
    func brightened(by delta: Double) -> Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: min(1, s * 1.05), brightness: max(0, min(1, b + delta)), opacity: a)
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

/// Primary call-to-action button style, matching `.cta-btn` — a punchy
/// two-tone gradient with a soft colored glow instead of a flat fill, bold
/// white label, fully rounded corners.
struct TideCTAButtonStyle: ButtonStyle {
    var tint: Color = TideTheme.tide

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [tint.brightened(by: 0.08), tint.brightened(by: -0.1)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: tint.opacity(configuration.isPressed ? 0.2 : 0.4), radius: configuration.isPressed ? 4 : 10, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Outline variant, matching `.cta-btn.outline` — now with a light tint wash
/// behind the border so it doesn't disappear against the background.
struct TideOutlineButtonStyle: ButtonStyle {
    var tint: Color = TideTheme.tide

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(tint)
            .background(tint.opacity(configuration.isPressed ? 0.16 : 0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(tint, lineWidth: 1.8)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
