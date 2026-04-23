import CoreGraphics

/// Concrete implementation of `BubblePlacing`.
///
/// Single responsibility: decide which bubbles exist and where they sit.
/// All geometry maths lives here; nothing outside this file needs to know
/// how overlap-free positions are found.
final class BubblePlacementService: BubblePlacing {

    private let bubbleRadius: CGFloat = 25
    private let maxPlacementAttempts = 100

    // MARK: - BubblePlacing

    func generate(maxCount: Int, in size: CGSize) -> [Bubble] {
        let count = Int.random(in: 0...maxCount)
        return makeBubbles(count: count, startingFrom: [], in: size)
    }

    func refresh(existing: [Bubble], maxCount: Int, in size: CGSize) -> [Bubble] {
        var bubbles = existing

        // Remove a random subset of survivors (never touches already-popped bubbles,
        // which have been removed from `existing` by the ViewModel before this call).
        let removeCount = Int.random(in: 0...max(1, bubbles.count / 2))
        for _ in 0..<removeCount {
            guard !bubbles.isEmpty else { break }
            bubbles.remove(at: Int.random(in: 0..<bubbles.count))
        }

        // Top up to a random total within the allowed maximum.
        guard bubbles.count <= maxCount else { return bubbles }
        let target = Int.random(in: bubbles.count...maxCount)
        let toAdd  = target - bubbles.count

        return makeBubbles(count: toAdd, startingFrom: bubbles, in: size)
    }

    // MARK: - Private helpers

    /// Appends `count` new non-overlapping bubbles to `seed` and returns the result.
    private func makeBubbles(count: Int, startingFrom seed: [Bubble], in size: CGSize) -> [Bubble] {
        var bubbles = seed
        for _ in 0..<count {
            if let pos = nonOverlappingPosition(existing: bubbles, in: size) {
                bubbles.append(Bubble(bubbleColor: .randomWeighted(), position: pos))
            }
        }
        return bubbles
    }

    /// Tries up to `maxPlacementAttempts` random positions and returns the first
    /// that does not overlap any existing bubble, or `nil` if the area is too full.
    private func nonOverlappingPosition(existing: [Bubble], in size: CGSize) -> CGPoint? {
        let r = bubbleRadius
        guard size.width > r * 2, size.height > r * 2 else { return nil }

        for _ in 0..<maxPlacementAttempts {
            let candidate = CGPoint(
                x: CGFloat.random(in: r...(size.width  - r)),
                y: CGFloat.random(in: r...(size.height - r))
            )
            let overlaps = existing.contains { other in
                let dx = candidate.x - other.position.x
                let dy = candidate.y - other.position.y
                return (dx * dx + dy * dy).squareRoot() < (r + other.radius)
            }
            if !overlaps { return candidate }
        }
        return nil
    }
}
