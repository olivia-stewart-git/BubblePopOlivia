import SwiftUI

/// Settings screen for adjusting game time and maximum bubbles (core 4 & 5).
struct SettingsView: View {
    @AppStorage(GameSettings.gameTimeKey) private var gameTime = GameSettings.defaultGameTime
    @AppStorage(GameSettings.maxBubblesKey) private var maxBubbles = GameSettings.defaultMaxBubbles

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Game Time: \(gameTime) seconds")
                        .font(.headline)

                    Slider(
                        value: Binding(
                            get: { Double(gameTime) },
                            set: { gameTime = Int($0) }
                        ),
                        in: Double(GameSettings.minGameTime)...Double(GameSettings.maxGameTime),
                        step: 1
                    )

                    Text("Range: \(GameSettings.minGameTime)–\(GameSettings.maxGameTime) seconds")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Timer")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Max Bubbles: \(maxBubbles)")
                        .font(.headline)

                    Slider(
                        value: Binding(
                            get: { Double(maxBubbles) },
                            set: { maxBubbles = Int($0) }
                        ),
                        in: Double(GameSettings.minMaxBubbles)...Double(GameSettings.maxMaxBubbles),
                        step: 1
                    )

                    Text("Range: \(GameSettings.minMaxBubbles)–\(GameSettings.maxMaxBubbles) bubbles")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Bubbles")
            }

            Section {
                Button("Reset to Defaults") {
                    gameTime = GameSettings.defaultGameTime
                    maxBubbles = GameSettings.defaultMaxBubbles
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
