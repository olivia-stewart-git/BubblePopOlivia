/// Responsible for computing points earned when a bubble is popped,
/// including consecutive-colour combo bonuses.
///
/// Owns the combo state so the ViewModel doesn't have to.
protocol ScoreCalculating {
    /// Returns the points earned for popping `color` and whether a combo
    /// multiplier was applied. The service tracks previous colour internally.
    func points(for color: BubbleColor) -> PopResult

    /// Resets combo tracking (call at game start / game over).
    func reset()
}

/// The result of a single bubble pop.
struct PopResult {
    let points: Int
    let isCombo: Bool
}
