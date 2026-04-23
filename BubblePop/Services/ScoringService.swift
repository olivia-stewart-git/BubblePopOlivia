/// Concrete implementation of `ScoreCalculating`.
///
/// Single responsibility: determine how many points a pop earns.
/// Combo state (last colour, consecutive count) lives entirely here,
/// so neither the ViewModel nor any view needs to track it.
final class ScoringService: ScoreCalculating {

    private let comboMultiplier: Double = 1.5
    private var lastPoppedColor: BubbleColor?
    private var comboCount: Int = 0

    // MARK: - ScoreCalculating

    func points(for color: BubbleColor) -> PopResult {
        let isCombo = (color == lastPoppedColor)

        if isCombo {
            comboCount += 1
        } else {
            comboCount = 1
        }
        lastPoppedColor = color

        let base   = Double(color.points)
        let earned = isCombo ? Int(round(base * comboMultiplier)) : color.points

        return PopResult(points: earned, isCombo: isCombo)
    }

    func reset() {
        lastPoppedColor = nil
        comboCount = 0
    }
}
