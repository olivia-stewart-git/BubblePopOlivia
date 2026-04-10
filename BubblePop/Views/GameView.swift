import SwiftUI

/// The main gameplay screen.
struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    init(playerName: String, gameTime: Int, maxBubbles: Int) {
        _viewModel = StateObject(wrappedValue: GameViewModel(
            playerName: playerName,
            gameTime: gameTime,
            maxBubbles: maxBubbles
        ))
    }

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top HUD: timer, score, high score (core 2, 3; extended 3)
                hudBar

                // Play area
                GeometryReader { geo in
                    ZStack {
                        Color.clear
                            .onAppear {
                                viewModel.playAreaSize = geo.size
                                viewModel.startCountdown()
                            }
                            .onChange(of: geo.size) { _, newSize in
                                viewModel.playAreaSize = newSize
                            }

                        // Bubbles
                        ForEach(viewModel.bubbles) { bubble in
                            BubbleView(bubble: bubble) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    viewModel.popBubble(bubble)
                                }
                            }
                        }

                        // Score popups (extended feature 2: animations)
                        ForEach(viewModel.scorePopups) { popup in
                            ScorePopupView(popup: popup)
                        }
                    }
                }
            }

            // Countdown overlay (extended feature 2)
            if viewModel.isCountingDown {
                CountdownOverlay(value: viewModel.countdownValue)
            }

            // Game over overlay
            if viewModel.isGameOver {
                gameOverOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isGameOver {
                    Button("Home") { dismiss() }
                }
            }
        }
    }

    // MARK: - Sub-views

    private var hudBar: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.timeRemaining)")
                    .font(.title.bold().monospacedDigit())
                    .foregroundStyle(viewModel.timeRemaining <= 10 ? .red : .primary)
            }

            Spacer()

            VStack {
                Text("High Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(max(viewModel.allTimeHighScore, viewModel.score))")
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(.orange)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.score)")
                    .font(.title.bold().monospacedDigit())
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Game Over!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("\(viewModel.playerName)")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))

                Text("Score: \(viewModel.score)")
                    .font(.title.bold())
                    .foregroundStyle(.yellow)

                NavigationLink(destination: HighScoreView()) {
                    Text("View High Scores")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange)
                        )
                }

                Button {
                    dismiss()
                } label: {
                    Text("Back to Home")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.7))
            )
        }
        .transition(.opacity)
    }
}

// MARK: - Bubble view

struct BubbleView: View {
    let bubble: Bubble
    let onTap: () -> Void

    @State private var scale: CGFloat = 0.1

    var body: some View {
        ZStack {
            Circle()
                .fill(bubble.bubbleColor.color.gradient)
                .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                .shadow(color: bubble.bubbleColor.color.opacity(0.5), radius: 4)

            // Show point value
            Text("\(bubble.bubbleColor.points)")
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .scaleEffect(scale)
        .position(bubble.position)
        .onTapGesture {
            withAnimation(.easeIn(duration: 0.15)) {
                scale = 1.4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onTap()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
    }
}

// MARK: - Score popup animation (extended feature 2)

struct ScorePopupView: View {
    let popup: ScorePopup

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Text(popup.isCombo ? "+\(popup.points) COMBO!" : "+\(popup.points)")
            .font(popup.isCombo ? .title2.bold() : .headline.bold())
            .foregroundStyle(popup.isCombo ? .orange : .green)
            .shadow(radius: 2)
            .position(popup.position)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offsetY = -60
                    opacity = 0
                }
            }
    }
}

#Preview {
    NavigationStack {
        GameView(playerName: "Test", gameTime: 60, maxBubbles: 15)
    }
}
