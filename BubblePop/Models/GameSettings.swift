import Foundation

/// Persisted game settings. Uses @AppStorage-compatible keys.
struct GameSettings {
    static let defaultGameTime = 60
    static let defaultMaxBubbles = 15

    static let minGameTime = 10
    static let maxGameTime = 120

    static let minMaxBubbles = 1
    static let maxMaxBubbles = 30

    // Keys for @AppStorage
    static let gameTimeKey = "gameTime"
    static let maxBubblesKey = "maxBubbles"
}
