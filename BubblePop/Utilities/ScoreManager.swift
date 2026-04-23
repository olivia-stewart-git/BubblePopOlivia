import Foundation

/// Concrete implementation of `ScoreStoring` that persists scores as a
/// JSON file in the app's Documents directory.
///
/// Callers depend on the `ScoreStoring` protocol, not this class, so the
/// storage mechanism can be replaced (e.g. CloudKit, CoreData) without
/// modifying any other file (DIP / OCP).
final class ScoreManager: ScoreStoring {

    private let fileName: String

    /// Designated initialiser — pass a custom filename for testing.
    init(fileName: String = "highscores.json") {
        self.fileName = fileName
    }

    private var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    // MARK: - ScoreStoring

    func save(name: String, score: Int) {
        var scores = loadRaw()

        if let idx = scores.firstIndex(where: { $0.name == name }) {
            if score > scores[idx].score {
                scores[idx] = PlayerScore(name: name, score: score)
            }
        } else {
            scores.append(PlayerScore(name: name, score: score))
        }

        persist(scores)
    }

    func loadAll() -> [PlayerScore] {
        loadRaw().sorted { $0.score > $1.score }
    }

    func highest() -> Int {
        loadAll().first?.score ?? 0
    }

    // MARK: - Private helpers

    private func loadRaw() -> [PlayerScore] {
        guard let data   = try? Data(contentsOf: fileURL),
              let scores = try? JSONDecoder().decode([PlayerScore].self, from: data)
        else { return [] }
        return scores
    }

    private func persist(_ scores: [PlayerScore]) {
        guard let data = try? JSONEncoder().encode(scores) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
