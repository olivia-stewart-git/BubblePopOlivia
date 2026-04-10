import SwiftUI

/// Displays ranked high scores (core 11).
struct HighScoreView: View {
    @State private var scores: [PlayerScore] = []

    var body: some View {
        ZStack {
            if scores.isEmpty {
                ContentUnavailableView(
                    "No Scores Yet",
                    systemImage: "trophy",
                    description: Text("Play a game to see scores here!")
                )
            } else {
                List {
                    ForEach(Array(scores.enumerated()), id: \.element.name) { index, entry in
                        HStack {
                            // Rank
                            rankBadge(index + 1)

                            VStack(alignment: .leading) {
                                Text(entry.name)
                                    .font(.headline)
                            }

                            Spacer()

                            Text("\(entry.score)")
                                .font(.title3.bold().monospacedDigit())
                                .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("High Scores")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            scores = ScoreManager.shared.loadScores()
        }
    }

    @ViewBuilder
    private func rankBadge(_ rank: Int) -> some View {
        ZStack {
            Circle()
                .fill(rankColor(rank))
                .frame(width: 32, height: 32)

            Text("\(rank)")
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue.opacity(0.5)
        }
    }
}

#Preview {
    NavigationStack {
        HighScoreView()
    }
}
