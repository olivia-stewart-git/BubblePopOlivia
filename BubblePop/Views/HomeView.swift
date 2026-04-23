import SwiftUI

struct HomeView: View {
    @State private var playerName: String = ""
    @State private var navigateToGame = false
    @State private var navigateToHighScores = false
    @State private var navigateToSettings = false

    @AppStorage(GameSettings.gameTimeKey) private var gameTime = GameSettings.defaultGameTime
    @AppStorage(GameSettings.maxBubblesKey) private var maxBubbles = GameSettings.defaultMaxBubbles

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("BubblePop")
                    .font(.largeTitle)

                Text("a bubble popping game")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                Text("Player Name:")
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)

                Button("PLAY") {
                    navigateToGame = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)

                Button("High Scores") {
                    navigateToHighScores = true
                }
                .buttonStyle(.bordered)

                Button("Settings") {
                    navigateToSettings = true
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Main Menu")
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
