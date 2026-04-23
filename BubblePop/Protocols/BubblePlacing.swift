import CoreGraphics

/// Responsible for generating and refreshing the set of bubbles on screen.
///
/// Separating this contract from GameViewModel means placement logic can be
/// swapped or tested without touching game-loop or scoring code (ISP / DIP).
protocol BubblePlacing {
    /// Produces an initial set of up to `maxCount` non-overlapping bubbles
    /// laid out within `size`.
    func generate(maxCount: Int, in size: CGSize) -> [Bubble]

    /// Given the bubbles currently on screen, randomly removes some and
    /// replaces them with newly positioned bubbles, keeping the total within
    /// `maxCount`. Popped bubbles must already be absent from `existing`.
    func refresh(existing: [Bubble], maxCount: Int, in size: CGSize) -> [Bubble]
}
