import SwiftUI

struct HighScoreView: View {
    @State private var scores: [PlayerScore] = []

    var body: some View {
        Group {
            if scores.isEmpty {
                Text("no scores yet")
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(Array(scores.enumerated()), id: \.element.name) { index, entry in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 36, alignment: .leading)
                            Text(entry.name)
                            Spacer()
                            Text("\(entry.score)")
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }
        }
        .navigationTitle("High Scores")
        .onAppear {
            scores = ScoreManager.shared.loadScores()
        }
    }
}

#Preview {
    NavigationStack {
        HighScoreView()
    }
}
