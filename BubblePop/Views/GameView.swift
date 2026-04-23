import SwiftUI

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
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // HUD
                HStack {
                    Text("Time: \(viewModel.timeRemaining)")
                    Spacer()
                    Text("Best: \(max(viewModel.allTimeHighScore, viewModel.score))")
                    Spacer()
                    Text("Score: \(viewModel.score)")
                }
                .font(.system(.body, design: .monospaced))
                .padding(6)
                .background(Color(uiColor: .systemGray5))

                Divider()

                // Play area
                GeometryReader { geo in
                    ZStack {
                        Color(uiColor: .systemGray6)
                            .onAppear {
                                viewModel.playAreaSize = geo.size
                                viewModel.startCountdown()
                            }
                            .onChange(of: geo.size) { _, newSize in
                                viewModel.playAreaSize = newSize
                            }

                        ForEach(viewModel.bubbles) { bubble in
                            BubbleView(bubble: bubble) {
                                viewModel.popBubble(bubble)
                            }
                        }

                        ForEach(viewModel.scorePopups) { popup in
                            ScorePopupView(popup: popup)
                        }
                    }
                }
            }

            if viewModel.isCountingDown {
                CountdownOverlay(value: viewModel.countdownValue)
            }

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

    private var gameOverOverlay: some View {
        VStack(spacing: 8) {
            Text("GAME OVER")
                .font(.system(.title, design: .monospaced).bold())

            Text("Player: \(viewModel.playerName)")
                .font(.system(.body, design: .monospaced))

            Text("Final Score: \(viewModel.score)")
                .font(.system(.title2, design: .monospaced))

            NavigationLink(destination: HighScoreView()) {
                Text("View High Scores")
            }
            .buttonStyle(.borderedProminent)

            Button("Back to Home") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .overlay(
            Rectangle()
                .strokeBorder(Color.black, lineWidth: 2)
        )
    }
}

// MARK: - Bubble view

struct BubbleView: View {
    let bubble: Bubble
    let onTap: () -> Void

    var body: some View {
        Circle()
            .fill(bubble.bubbleColor.color)
            .frame(width: bubble.radius * 2, height: bubble.radius * 2)
            .overlay(
                Text("\(bubble.bubbleColor.points)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            )
            .position(bubble.position)
            .onTapGesture { onTap() }
    }
}

// MARK: - Score popup

struct ScorePopupView: View {
    let popup: ScorePopup

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Text(popup.isCombo ? "+\(popup.points) combo" : "+\(popup.points)")
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(popup.isCombo ? .orange : .black)
            .position(popup.position)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 0.8)) {
                    offsetY = -50
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
