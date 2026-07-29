import Foundation

struct PlasticItem: Codable, Identifiable, Equatable, Hashable {
    var id: String { name }

    let name: String
    let materialCode: String
    let recyclability: String
    let alternatives: String
    let whereToGetAlternative: String
    let plasticFootprint: String
    let microplasticRisk: String
    let decompositionTime: String
    let environmentalImpact: String
    let bestAction: String
    let practicalTip: String
    var source: String = "database"
    /// Typical single-use weight in grams, used to compute the Phase 2
    /// impact dashboard (plastic logged, estimated CO2, Tide Score). Not
    /// part of the original spreadsheet — estimated from typical packaging
    /// weights (several pulled directly from the prototype's own item data
    /// where names matched).
    var typicalWeightGrams: Double = 10
}
