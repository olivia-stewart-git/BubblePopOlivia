import CoreGraphics

protocol BubblePlacing {
    func generate(maxCount: Int, in size: CGSize) -> [Bubble]

    func refresh(existing: [Bubble], maxCount: Int, in size: CGSize) -> [Bubble]
}
