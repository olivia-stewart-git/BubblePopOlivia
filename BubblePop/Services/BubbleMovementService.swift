import CoreGraphics

/// Concrete implementation of `BubbleMoving`.
///
/// Single responsibility: advance bubble positions each frame and remove
/// any bubble that has drifted fully off the play area.
/// Speed ramping is encapsulated here so the ViewModel has no knowledge
/// of how velocity or difficulty scaling work.
final class BubbleMovementService: BubbleMoving {

    private let bubbleRadius: CGFloat = 25
    /// Speed multiplier range: 1× at the start, up to 4× at game end.
    private let minSpeedFactor: Double = 1.0
    private let maxSpeedFactor: Double = 4.0

    // MARK: - BubbleMoving

    func move(_ bubbles: [Bubble], elapsed: Double, totalTime: Double, in size: CGSize) -> [Bubble] {
        guard size.width > 0, size.height > 0, totalTime > 0 else { return bubbles }

        let speed = speedFactor(elapsed: elapsed, totalTime: totalTime)
        let r = bubbleRadius

        return bubbles
            .map { bubble in
                var b = bubble
                b.position.x += b.velocity.dx * speed
                b.position.y += b.velocity.dy * speed
                return b
            }
            .filter { b in
                b.position.x > -r && b.position.x < size.width  + r &&
                b.position.y > -r && b.position.y < size.height + r
            }
    }

    func randomVelocity() -> CGVector {
        let speed = Double.random(in: 0.15...0.5)
        let angle = Double.random(in: 0..<(.pi * 2))
        return CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
    }

    // MARK: - Private helpers

    /// Linearly ramps the speed multiplier from `minSpeedFactor` to
    /// `maxSpeedFactor` as `elapsed` approaches `totalTime`.
    private func speedFactor(elapsed: Double, totalTime: Double) -> Double {
        let progress = min(elapsed / totalTime, 1.0)
        return minSpeedFactor + progress * (maxSpeedFactor - minSpeedFactor)
    }
}
