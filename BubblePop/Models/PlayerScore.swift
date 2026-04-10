import Foundation

/// A single entry in the high-score table.
struct PlayerScore: Codable, Identifiable {
    var id: String { name }
    let name: String
    let score: Int
}
