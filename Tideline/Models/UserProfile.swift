import Foundation

struct UserProfile: Codable, Equatable {
    let id: String
    var displayName: String?
    let createdAt: Date
}
