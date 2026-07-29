import Foundation

enum ScanMethod: String, Codable {
    case barcode
    case photo
    case search
}

struct ScanHistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    let itemName: String
    let timestamp: Date
    let scanMethod: ScanMethod

    init(id: String = UUID().uuidString, itemName: String, timestamp: Date = Date(), scanMethod: ScanMethod) {
        self.id = id
        self.itemName = itemName
        self.timestamp = timestamp
        self.scanMethod = scanMethod
    }
}
