import Foundation

/// Loads the bundled seed data (PlasticItems.json, QuizQuestions.json) and
/// provides loose-matching lookups against the verified item database.
final class PlasticItemLibrary {
    static let shared = PlasticItemLibrary()

    let items: [PlasticItem]
    let quizQuestions: [QuizQuestion]

    private init() {
        items = Self.load("PlasticItems", as: [PlasticItem].self) ?? []
        quizQuestions = Self.load("QuizQuestions", as: [QuizQuestion].self) ?? []
    }

    private static func load<T: Decodable>(_ resource: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            assertionFailure("Missing bundled resource: \(resource).json")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            assertionFailure("Failed to decode \(resource).json: \(error)")
            return nil
        }
    }

    /// Loosely matches free-text input (from search, barcode lookup, or photo
    /// recognition) against the seeded item names. Matching is case-insensitive
    /// and tolerant of partial phrases in either direction, e.g. "plastic
    /// drinking straw" and "straw" both match "Plastic straw".
    func match(query: String) -> PlasticItem? {
        let normalized = Self.normalize(query)
        guard !normalized.isEmpty else { return nil }

        if let exact = items.first(where: { Self.normalize($0.name) == normalized }) {
            return exact
        }

        let normalizedWords = Set(normalized.split(separator: " ").map(String.init))

        let scored: [(item: PlasticItem, score: Int)] = items.compactMap { item in
            let itemNormalized = Self.normalize(item.name)
            let itemWords = Set(itemNormalized.split(separator: " ").map(String.init))

            if itemNormalized.contains(normalized) || normalized.contains(itemNormalized) {
                return (item, 1000 + itemNormalized.count)
            }

            let overlap = itemWords.intersection(normalizedWords)
            guard !overlap.isEmpty else { return nil }
            return (item, overlap.count)
        }

        return scored.max(by: { $0.score < $1.score })?.item
    }

    private static func normalize(_ text: String) -> String {
        let lowered = text.lowercased()
        let stopWords: Set<String> = ["a", "an", "the", "of", "plastic"]
        let cleaned = lowered.unicodeScalars.map { scalar -> Character in
            CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : " "
        }
        let collapsed = String(cleaned)
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }

        // Keep "plastic" as a stop word only when there are other words to match on,
        // so a bare search for "plastic" doesn't collapse to an empty query.
        let withoutStopWords = collapsed.filter { !stopWords.contains($0) }
        let result = withoutStopWords.isEmpty ? collapsed : withoutStopWords
        return result.joined(separator: " ")
    }
}
