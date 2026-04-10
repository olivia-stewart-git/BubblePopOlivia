import SwiftUI
import Combine

/// Drives the BubblePop game logic, including timer, bubble lifecycle,
/// scoring with combo multiplier, and movement (extended feature).
final class GameViewModel: ObservableObject {

    // MARK: - Published state

    @Published var bubbles: [Bubble] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int
    @Published var isGameOver = false
    @Published var isCountingDown = true
    @Published var countdownValue: Int = 3

    /// Floating score labels that animate on pop (extended feature).
    @Published var scorePopups: [ScorePopup] = []

    // MARK: - Configuration

    let playerName: String
    let gameTime: Int
    let maxBubbles: Int
    let allTimeHighScore: Int

    // MARK: - Internal state

    private var lastPoppedColor: BubbleColor?
    private var comboCount: Int = 0
    private var gameTimer: Timer?
    private var countdownTimer: Timer?
    private var moveTimer: Timer?

    /// Area available for placing bubbles (set by the view).
    var playAreaSize: CGSize = .zero

    // MARK: - Init

    init(playerName: String, gameTime: Int, maxBubbles: Int) {
        self.playerName = playerName
        self.gameTime = gameTime
        self.maxBubbles = maxBubbles
        self.timeRemaining = gameTime
        self.allTimeHighScore = ScoreManager.shared.highestScore()
    }

    // MARK: - Game lifecycle

    func startCountdown() {
        countdownValue = 3
        isCountingDown = true

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            if self.countdownValue > 1 {
                self.countdownValue -= 1
            } else {
                timer.invalidate()
                self.countdownTimer = nil
                self.isCountingDown = false
                self.startGame()
            }
        }
    }

    func startGame() {
        score = 0
        timeRemaining = gameTime
        lastPoppedColor = nil
        comboCount = 0
        isGameOver = false
        generateBubbles()

        // Main 1-second game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.endGame()
            } else {
                self.refreshBubbles()
            }
        }

        // Movement timer for extended feature (variable speed)
        startMovementTimer()
    }

    func endGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        moveTimer?.invalidate()
        moveTimer = nil
        isGameOver = true
        ScoreManager.shared.saveScore(name: playerName, score: score)
    }

    // MARK: - Bubble tapping (core 8)

    func popBubble(_ bubble: Bubble) {
        guard let idx = bubbles.firstIndex(where: { $0.id == bubble.id }) else { return }

        let color = bubble.bubbleColor
        var earnedPoints = color.points

        // Combo: same colour popped consecutively → 1.5× multiplier
        if color == lastPoppedColor {
            comboCount += 1
            earnedPoints = Int(round(Double(color.points) * 1.5))
        } else {
            comboCount = 1
        }
        lastPoppedColor = color

        score += earnedPoints

        // Add floating score label (extended feature)
        let popup = ScorePopup(
            points: earnedPoints,
            position: bubble.position,
            isCombo: comboCount > 1
        )
        scorePopups.append(popup)

        // Remove after animation
        let popupID = popup.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.scorePopups.removeAll { $0.id == popupID }
        }

        bubbles.remove(at: idx)
    }

    // MARK: - Bubble generation (core 6 & 7)

    func generateBubbles() {
        let count = Int.random(in: 0...maxBubbles)
        var newBubbles: [Bubble] = []
        let radius: CGFloat = 25

        for _ in 0..<count {
            if let pos = findNonOverlappingPosition(radius: radius, existing: newBubbles) {
                let color = BubbleColor.randomWeighted()
                var bubble = Bubble(bubbleColor: color, position: pos)
                bubble.velocity = randomVelocity()
                newBubbles.append(bubble)
            }
        }

        bubbles = newBubbles
    }

    /// Refresh: randomly remove some, add some new ones (core 9).
    func refreshBubbles() {
        // Remove a random subset (0 to half)
        let removeCount = Int.random(in: 0...max(1, bubbles.count / 2))
        for _ in 0..<removeCount {
            guard !bubbles.isEmpty else { break }
            let idx = Int.random(in: 0..<bubbles.count)
            bubbles.remove(at: idx)
        }

        // Decide new total count (up to maxBubbles)
        let currentCount = bubbles.count
        guard currentCount <= maxBubbles else { return }
        let targetCount = Int.random(in: currentCount...maxBubbles)
        let toAdd = targetCount - currentCount
        let radius: CGFloat = 25

        for _ in 0..<toAdd {
            if let pos = findNonOverlappingPosition(radius: radius, existing: bubbles) {
                let color = BubbleColor.randomWeighted()
                var bubble = Bubble(bubbleColor: color, position: pos)
                bubble.velocity = randomVelocity()
                bubbles.append(bubble)
            }
        }
    }

    // MARK: - Movement (extended 1)

    private func startMovementTimer() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.moveBubbles()
        }
    }

    private func moveBubbles() {
        guard playAreaSize.width > 0, playAreaSize.height > 0 else { return }

        // Speed multiplier increases as game progresses
        let elapsed = Double(gameTime - timeRemaining)
        let totalTime = Double(gameTime)
        let speedFactor = 1.0 + (elapsed / totalTime) * 3.0 // up to 4× speed at end

        let radius: CGFloat = 25
        var indicesToRemove: [Int] = []

        for i in bubbles.indices {
            bubbles[i].position.x += bubbles[i].velocity.dx * speedFactor
            bubbles[i].position.y += bubbles[i].velocity.dy * speedFactor

            let pos = bubbles[i].position
            // Remove if fully off screen
            if pos.x < -radius || pos.x > playAreaSize.width + radius ||
               pos.y < -radius || pos.y > playAreaSize.height + radius {
                indicesToRemove.append(i)
            }
        }

        // Remove off-screen bubbles in reverse to preserve indices
        for i in indicesToRemove.reversed() {
            bubbles.remove(at: i)
        }
    }

    private func randomVelocity() -> CGVector {
        let speed = Double.random(in: 0.15...0.5)
        let angle = Double.random(in: 0..<(.pi * 2))
        return CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
    }

    // MARK: - Positioning helpers

    private func findNonOverlappingPosition(radius: CGFloat, existing: [Bubble]) -> CGPoint? {
        let width = playAreaSize.width
        let height = playAreaSize.height
        guard width > radius * 2, height > radius * 2 else { return nil }

        let maxAttempts = 100
        for _ in 0..<maxAttempts {
            let x = CGFloat.random(in: radius...(width - radius))
            let y = CGFloat.random(in: radius...(height - radius))
            let candidate = CGPoint(x: x, y: y)

            let overlaps = existing.contains { other in
                let dx = candidate.x - other.position.x
                let dy = candidate.y - other.position.y
                let dist = sqrt(dx * dx + dy * dy)
                return dist < (radius + other.radius)
            }

            if !overlaps {
                return candidate
            }
        }
        return nil // could not find valid position
    }
}

// MARK: - Score popup model for animated "+X" labels

struct ScorePopup: Identifiable {
    let id = UUID()
    let points: Int
    let position: CGPoint
    let isCombo: Bool
}
