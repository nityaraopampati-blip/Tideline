import Foundation

/// One logged sighting for Plastic-Go — the simple photo-log version
/// specified for the first build (the full real-time map game is a later
/// stretch goal).
struct PlasticGoEntry: Codable, Identifiable, Equatable {
    let id: String
    let imageFileName: String
    let note: String
    let timestamp: Date

    init(id: String = UUID().uuidString, imageFileName: String, note: String, timestamp: Date = Date()) {
        self.id = id
        self.imageFileName = imageFileName
        self.note = note
        self.timestamp = timestamp
    }
}
