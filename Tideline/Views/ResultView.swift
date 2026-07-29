import SwiftUI

struct ResultView: View {
    let item: PlasticItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                recyclabilityBanner
                specimenCard
                factBox
                actionBox
                alternativeCard
                acknowledgment
                sourceNote
            }
            .padding()
        }
        .background(TideTheme.background.ignoresSafeArea())
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Banner

    private var recyclabilityTone: (gradient: [Color], label: String) {
        let level = Self.leadingWord(in: item.recyclability)?.lowercased()
        switch level {
        case "high": return ([TideTheme.seafoam, TideTheme.deep], "Highly Recyclable")
        case "medium": return ([Color(hex: 0xFFCA28), Color(hex: 0xE8A93B)], "Sometimes Recyclable")
        case "low": return ([TideTheme.coral, Color(hex: 0xC0452A)], "Rarely Recyclable")
        default: return ([TideTheme.seafoam, TideTheme.deep], "Recyclability")
        }
    }

    private var recyclabilityBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: bannerIcon)
                .font(.system(size: 30))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(recyclabilityTone.label)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Text("Material: \(item.materialCode)")
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .opacity(0.92)
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(
            LinearGradient(colors: recyclabilityTone.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var bannerIcon: String {
        switch Self.leadingWord(in: item.recyclability)?.lowercased() {
        case "high": return "checkmark.circle.fill"
        case "medium": return "exclamationmark.circle.fill"
        case "low": return "xmark.circle.fill"
        default: return "arrow.3.trianglepath"
        }
    }

    // MARK: - Specimen card (name + quick facts)

    private var specimenCard: some View {
        TideCard(padding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(TideTheme.surface2).frame(width: 54, height: 54)
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(TideTheme.tide)
                    }
                    Text(item.name)
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundStyle(TideTheme.ink)
                }

                HStack(spacing: 8) {
                    quickFact(icon: "arrow.3.trianglepath", label: "Recyclability", value: Self.firstClause(of: item.recyclability))
                    quickFact(icon: "drop.fill", label: "Microplastic Risk", value: Self.firstClause(of: item.microplasticRisk))
                    quickFact(icon: "clock.fill", label: "Decomposition", value: item.decompositionTime)
                }
            }
        }
    }

    private func quickFact(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(TideTheme.tide)
            Text(label.uppercased())
                .font(.system(size: 7.5, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(value)
                .font(.system(size: 11.5, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(TideTheme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Fact box (environmental impact)

    private var factBox: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("🌍").font(.system(size: 18))
            Text(item.environmentalImpact.isEmpty ? "Not available" : item.environmentalImpact)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: 0x5A4415))
                .lineSpacing(3)
        }
        .padding(14)
        .background(TideTheme.sand)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Action box (best action)

    private var actionBox: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("BEST ACTION")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .opacity(0.85)
            Text(item.bestAction.isEmpty ? "Not available" : item.bestAction)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TideTheme.deep)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Alternative card

    private var alternativeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Reusable Alternative")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                Spacer()
                Text("BEST SWAP")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.4)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(TideTheme.coral)
                    .clipShape(Capsule())
            }
            Text(item.alternatives.isEmpty ? "Not available" : item.alternatives)
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.ink)
            if !item.whereToGetAlternative.isEmpty {
                Text("Where to get it: \(item.whereToGetAlternative)")
                    .font(.system(size: 11.5))
                    .foregroundStyle(TideTheme.inkSoft)
            }
            if let shopURL = Self.shopSearchURL(for: item.alternatives) {
                Link(destination: shopURL) {
                    Label("Shop for this alternative", systemImage: "cart.fill")
                        .font(.system(size: 12.5, weight: .semibold))
                }
                .foregroundStyle(TideTheme.tide)
                .padding(.top, 2)
            }
            if !item.practicalTip.isEmpty {
                Divider().padding(.vertical, 2)
                Label(item.practicalTip, systemImage: "lightbulb.fill")
                    .font(.system(size: 11.5))
                    .foregroundStyle(TideTheme.tide)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(TideTheme.seafoam, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var acknowledgment: some View {
        Text("Nice work checking that before tossing it!")
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(TideTheme.deep)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 6)
    }

    private var sourceNote: some View {
        Text(item.source == "database" ? "From Tideline's verified database" : "AI-generated estimate")
            .font(.caption)
            .foregroundStyle(TideTheme.inkSoft.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Parsing helpers

    /// Our data fields commonly follow a "Level – detail" convention, e.g.
    /// "High – PET is the most widely recycled...". Extracts "High".
    private static func leadingWord(in text: String) -> String? {
        let separators = [" – ", " - "]
        for separator in separators {
            if let range = text.range(of: separator) {
                return String(text[..<range.lowerBound])
            }
        }
        return text.split(separator: " ").first.map(String.init)
    }

    /// Extracts the short "Level" clause before the dash for compact display;
    /// falls back to the full text if the field doesn't follow that pattern.
    private static func firstClause(of text: String) -> String {
        let separators = [" – ", " - "]
        for separator in separators {
            if let range = text.range(of: separator) {
                return String(text[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
        return text
    }

    /// Builds an Amazon search link for the alternative's name, rather than
    /// guessing a specific product URL (which the data doesn't have and
    /// could easily be wrong or dead).
    private static func shopSearchURL(for alternativeText: String) -> URL? {
        guard !alternativeText.isEmpty else { return nil }
        guard let encoded = alternativeText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://www.amazon.com/s?k=\(encoded)")
    }
}

#Preview {
    NavigationStack {
        ResultView(item: PlasticItemLibrary.shared.items.first!)
    }
}
