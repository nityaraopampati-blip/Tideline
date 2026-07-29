import FoundationModels

/// Uses Apple's on-device Foundation Models framework to estimate a full
/// environmental profile for an item that wasn't found in Tideline's
/// verified PlasticItems.json database. Requires iOS 26 and iPhone 15 Pro
/// or newer (Apple's hardware requirement for this framework) — callers
/// must check PhotoScanCapability.isAvailable() before using this.
@available(iOS 26.0, *)
enum AIEstimateService {
    @Generable
    struct Estimate {
        @Guide(description: "A short, clean name for the item, e.g. 'Plastic yogurt lid'")
        var name: String
        @Guide(description: "Recycling code if guessable, e.g. 'PET (#1)', or 'Unknown' if not")
        var materialCode: String
        @Guide(description: "How recyclable it is and why, one short sentence")
        var recyclability: String
        @Guide(description: "A reasonable reusable alternative to this item")
        var alternatives: String
        @Guide(description: "Where someone could typically buy that alternative")
        var whereToGetAlternative: String
        @Guide(description: "Roughly how much plastic this item uses, one short phrase")
        var plasticFootprint: String
        @Guide(description: "Its microplastic shedding risk, one short phrase")
        var microplasticRisk: String
        @Guide(description: "A rough estimate of how long it takes to decompose")
        var decompositionTime: String
        @Guide(description: "Its environmental impact, one short sentence")
        var environmentalImpact: String
        @Guide(description: "The single best action a person can take with this item")
        var bestAction: String
        @Guide(description: "One short, practical tip a teenager would find useful")
        var practicalTip: String
    }

    static func estimate(for label: String) async throws -> PlasticItem {
        let session = LanguageModelSession(
            instructions: "You are an encouraging, factual environmental-education assistant inside the Tideline app. Keep every field short — one sentence or phrase, never preachy."
        )
        let prompt = "Estimate the plastic/environmental profile of this everyday item, identified from a photo as: \"\(label)\"."
        let response = try await session.respond(to: prompt, generating: Estimate.self)
        let estimate = response.content

        return PlasticItem(
            name: estimate.name,
            materialCode: estimate.materialCode,
            recyclability: estimate.recyclability,
            alternatives: estimate.alternatives,
            whereToGetAlternative: estimate.whereToGetAlternative,
            plasticFootprint: estimate.plasticFootprint,
            microplasticRisk: estimate.microplasticRisk,
            decompositionTime: estimate.decompositionTime,
            environmentalImpact: estimate.environmentalImpact,
            bestAction: estimate.bestAction,
            practicalTip: estimate.practicalTip,
            source: "on-device-ai-estimate"
        )
    }
}
