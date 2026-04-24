/// Responsible for computing points earned when a bubble is popped,
protocol ScoreCalculating {
    func points(for color: BubbleColor) -> PopResult

    func reset()
}

struct PopResult {
    let points: Int
    let isCombo: Bool
}
