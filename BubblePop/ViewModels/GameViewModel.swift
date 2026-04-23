import SwiftUI

/// Coordinates the game loop and owns published state consumed by the views.
///
/// All domain logic is delegated to injected services:
///   - `BubblePlacing`   — where bubbles go
///   - `BubbleMoving`    — how bubbles move each frame
///   - `ScoreCalculating`— how many points a pop earns
///   - `ScoreStoring`    — persistence
///
/// GameViewModel's only responsibility is orchestrating those services and
/// driving the timers. Adding a new rule (e.g. power-ups) means writing a
/// new service, not editing this file (OCP).
final class GameViewModel: ObservableObject {

    // MARK: - Published state

    @Published var bubbles: [Bubble] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int
    @Published var isGameOver = false
    @Published var isCountingDown = true
    @Published var countdownValue: Int = 3
    @Published var scorePopups: [ScorePopup] = []

    // MARK: - Configuration

    let playerName: String
    let gameTime: Int
    let maxBubbles: Int
    let allTimeHighScore: Int

    // MARK: - Injected services

    private let placement: BubblePlacing
    private let movement: BubbleMoving
    private let scoring: ScoreCalculating
    private let store: ScoreStoring

    // MARK: - Timers

    private var gameTimer: Timer?
    private var countdownTimer: Timer?
    private var moveTimer: Timer?

    // MARK: - Play-area size (set by the view via GeometryReader)

    var playAreaSize: CGSize = .zero

    // MARK: - Init

    /// Production initialiser: uses default concrete services.
    convenience init(playerName: String, gameTime: Int, maxBubbles: Int) {
        self.init(
            playerName: playerName,
            gameTime: gameTime,
            maxBubbles: maxBubbles,
            placement: BubblePlacementService(),
            movement: BubbleMovementService(),
            scoring: ScoringService(),
            store: ScoreManager()
        )
    }

    /// Full initialiser: allows injecting alternative service implementations
    /// (e.g. mocks during testing — DIP).
    init(
        playerName: String,
        gameTime: Int,
        maxBubbles: Int,
        placement: BubblePlacing,
        movement: BubbleMoving,
        scoring: ScoreCalculating,
        store: ScoreStoring
    ) {
        self.playerName = playerName
        self.gameTime = gameTime
        self.maxBubbles = maxBubbles
        self.timeRemaining = gameTime
        self.placement = placement
        self.movement = movement
        self.scoring = scoring
        self.store = store
        self.allTimeHighScore = store.highest()
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
                self.countdownValue = 0   // triggers "Go!" in the overlay
                timer.invalidate()
                self.countdownTimer = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    self?.isCountingDown = false
                    self?.startGame()
                }
            }
        }
    }

    func startGame() {
        score = 0
        timeRemaining = gameTime
        isGameOver = false
        scoring.reset()
        bubbles = placement.generate(maxCount: maxBubbles, in: playAreaSize)
                           .map(assignVelocity)

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        startMovementTimer()
    }

    func endGame() {
        gameTimer?.invalidate(); gameTimer = nil
        moveTimer?.invalidate(); moveTimer = nil
        isGameOver = true
        store.save(name: playerName, score: score)
    }

    // MARK: - Bubble tapping

    func popBubble(_ bubble: Bubble) {
        guard bubbles.contains(where: { $0.id == bubble.id }) else { return }

        let result = scoring.points(for: bubble.bubbleColor)
        score += result.points

        let popup = ScorePopup(points: result.points, position: bubble.position, isCombo: result.isCombo)
        scorePopups.append(popup)
        let popupID = popup.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.scorePopups.removeAll { $0.id == popupID }
        }

        bubbles.removeAll { $0.id == bubble.id }
    }

    // MARK: - Private helpers

    private func tick() {
        timeRemaining -= 1
        if timeRemaining <= 0 {
            endGame()
        } else {
            let refreshed = placement.refresh(existing: bubbles, maxCount: maxBubbles, in: playAreaSize)
            // Assign velocities only to the newly added bubbles (those without a velocity).
            bubbles = refreshed.map { bubble in
                bubble.velocity == .zero ? assignVelocity(bubble) : bubble
            }
        }
    }

    private func startMovementTimer() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.advanceMovement()
        }
    }

    private func advanceMovement() {
        let elapsed = Double(gameTime - timeRemaining)
        bubbles = movement.move(bubbles, elapsed: elapsed, totalTime: Double(gameTime), in: playAreaSize)
    }

    /// Returns a copy of `bubble` with a random initial velocity assigned.
    private func assignVelocity(_ bubble: Bubble) -> Bubble {
        var b = bubble
        b.velocity = movement.randomVelocity()
        return b
    }
}

// MARK: - Score popup model

struct ScorePopup: Identifiable {
    let id = UUID()
    let points: Int
    let position: CGPoint
    let isCombo: Bool
}
