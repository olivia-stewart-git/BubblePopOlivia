import Foundation

protocol ScoreStoring {
    func save(name: String, score: Int)
    func loadAll() -> [PlayerScore]
    func highest() -> Int
}
