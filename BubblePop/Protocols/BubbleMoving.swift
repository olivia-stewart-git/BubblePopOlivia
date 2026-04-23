import CoreGraphics

/// Responsible for advancing bubble positions each frame and culling
/// bubbles that have drifted off-screen.
protocol BubbleMoving {
    /// Applies one frame of movement to every bubble in `bubbles`.
    /// Returns the updated array with off-screen bubbles removed.
    ///
    /// - Parameters:
    ///   - bubbles: Current on-screen bubbles (may be mutated by value).
    ///   - elapsed: Seconds elapsed since game start (drives speed ramp-up).
    ///   - totalTime: Total game duration in seconds.
    ///   - size: Play-area dimensions used for off-screen culling.
    func move(_ bubbles: [Bubble], elapsed: Double, totalTime: Double, in size: CGSize) -> [Bubble]

    /// Returns a random initial velocity vector for a newly spawned bubble.
    func randomVelocity() -> CGVector
}
