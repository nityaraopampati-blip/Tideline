import Foundation

struct PlasticItem: Codable, Identifiable, Equatable {
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
}
