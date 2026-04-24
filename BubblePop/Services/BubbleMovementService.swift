import CoreGraphics

final class BubbleMovementService: BubbleMoving {

    private let bubbleRadius: CGFloat = 25
    
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
    private func speedFactor(elapsed: Double, totalTime: Double) -> Double {
        let progress = min(elapsed / totalTime, 1.0)
        return minSpeedFactor + progress * (maxSpeedFactor - minSpeedFactor)
    }
}
