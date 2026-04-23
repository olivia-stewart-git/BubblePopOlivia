import SwiftUI

struct SettingsView: View {
    @AppStorage(GameSettings.gameTimeKey) private var gameTime = GameSettings.defaultGameTime
    @AppStorage(GameSettings.maxBubblesKey) private var maxBubbles = GameSettings.defaultMaxBubbles

    var body: some View {
        Form {
            Section("Timer") {
                Text("Game Time: \(gameTime)s")
                Slider(
                    value: Binding(get: { Double(gameTime) }, set: { gameTime = Int($0) }),
                    in: Double(GameSettings.minGameTime)...Double(GameSettings.maxGameTime),
                    step: 1
                )
                Text("(\(GameSettings.minGameTime)–\(GameSettings.maxGameTime) seconds)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Bubbles") {
                Text("Max Bubbles: \(maxBubbles)")
                Slider(
                    value: Binding(get: { Double(maxBubbles) }, set: { maxBubbles = Int($0) }),
                    in: Double(GameSettings.minMaxBubbles)...Double(GameSettings.maxMaxBubbles),
                    step: 1
                )
                Text("(\(GameSettings.minMaxBubbles)–\(GameSettings.maxMaxBubbles) bubbles)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
