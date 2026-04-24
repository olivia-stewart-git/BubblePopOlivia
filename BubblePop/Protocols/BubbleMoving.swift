import CoreGraphics

protocol BubbleMoving {
    func move(_ bubbles: [Bubble], elapsed: Double, totalTime: Double, in size: CGSize) -> [Bubble]

    func randomVelocity() -> CGVector
}
