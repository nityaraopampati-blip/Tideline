import Foundation

enum ScanMethod: String, Codable {
    case barcode
    case photo
    case search
}

struct ScanHistoryEntry: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let itemName: String
    let timestamp: Date
    let scanMethod: ScanMethod
    /// A snapshot of the full result shown at scan time, so tapping back into
    /// history works even for AI-estimated items that aren't in the seeded
    /// database (and so results don't change retroactively if the seed data
    /// is later updated).
    let cachedItem: PlasticItem?

    init(id: String = UUID().uuidString, itemName: String, timestamp: Date = Date(), scanMethod: ScanMethod, cachedItem: PlasticItem?) {
        self.id = id
        self.itemName = itemName
        self.timestamp = timestamp
        self.scanMethod = scanMethod
        self.cachedItem = cachedItem
    }
}
