/// Responsible for persisting and querying player high scores.
///
/// Abstracting storage behind a protocol lets GameViewModel remain
/// ignorant of how or where scores are saved (DIP), and makes the
/// store trivially replaceable (e.g. CloudKit, CoreData) without
/// touching any other class.
protocol ScoreStoring {
    /// Saves `score` for `name`, keeping only the player's highest score.
    func save(name: String, score: Int)

    /// Returns all recorded scores, sorted descending.
    func loadAll() -> [PlayerScore]

    /// Convenience: the single highest score across all players, or 0.
    func highest() -> Int
}
