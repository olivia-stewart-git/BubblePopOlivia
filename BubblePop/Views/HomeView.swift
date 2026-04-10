import SwiftUI

/// The landing screen: enter player name, navigate to game, settings, or high scores.
struct HomeView: View {
    @State private var playerName: String = ""
    @State private var navigateToGame = false
    @State private var navigateToHighScores = false
    @State private var navigateToSettings = false

    @AppStorage(GameSettings.gameTimeKey) private var gameTime = GameSettings.defaultGameTime
    @AppStorage(GameSettings.maxBubblesKey) private var maxBubbles = GameSettings.defaultMaxBubbles

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Title
                    Text("🫧 BubblePop")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)

                    Text("Pop bubbles. Score points. Have fun!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))

                    Spacer()

                    // Name entry (core 1)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Player Name")
                            .font(.headline)
                            .foregroundStyle(.white)

                        TextField("Enter your name", text: $playerName)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                    }
                    .padding(.horizontal, 40)

                    // Play button
                    Button {
                        navigateToGame = true
                    } label: {
                        Text("Play")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(playerName.trimmingCharacters(in: .whitespaces).isEmpty
                                          ? Color.gray
                                          : Color.green)
                            )
                    }
                    .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 40)

                    // High Scores button
                    Button {
                        navigateToHighScores = true
                    } label: {
                        Text("High Scores")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orange)
                            )
                    }
                    .padding(.horizontal, 40)

                    // Settings button
                    Button {
                        navigateToSettings = true
                    } label: {
                        Text("Settings")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue)
                            )
                    }
                    .padding(.horizontal, 40)

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(
                    playerName: playerName.trimmingCharacters(in: .whitespaces),
                    gameTime: gameTime,
                    maxBubbles: maxBubbles
                )
            }
            .navigationDestination(isPresented: $navigateToHighScores) {
                HighScoreView()
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    HomeView()
}
