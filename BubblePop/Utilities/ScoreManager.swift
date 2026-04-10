import Foundation

/// Manages persistent storage of player high scores using a JSON file
/// in the app's documents directory.
final class ScoreManager {
    static let shared = ScoreManager()

    private let fileName = "highscores.json"

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }

    private init() {}

    // MARK: - Public API

    /// Returns all saved scores sorted descending by score.
    func loadScores() -> [PlayerScore] {
        guard let data = try? Data(contentsOf: fileURL),
              let scores = try? JSONDecoder().decode([PlayerScore].self, from: data)
        else { return [] }
        return scores.sorted { $0.score > $1.score }
    }

    /// Saves a player's score. If the player already has a record,
    /// keeps only the higher score (core functionality 10).
    func saveScore(name: String, score: Int) {
        var scores = loadScoresRaw()

        if let idx = scores.firstIndex(where: { $0.name == name }) {
            // Keep the higher score
            if score > scores[idx].score {
                scores[idx] = PlayerScore(name: name, score: score)
            }
        } else {
            scores.append(PlayerScore(name: name, score: score))
        }

        persist(scores)
    }

    /// The highest score ever recorded, or 0 if none.
    func highestScore() -> Int {
        loadScores().first?.score ?? 0
    }

    // MARK: - Private helpers

    private func loadScoresRaw() -> [PlayerScore] {
        guard let data = try? Data(contentsOf: fileURL),
              let scores = try? JSONDecoder().decode([PlayerScore].self, from: data)
        else { return [] }
        return scores
    }

    private func persist(_ scores: [PlayerScore]) {
        guard let data = try? JSONEncoder().encode(scores) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
