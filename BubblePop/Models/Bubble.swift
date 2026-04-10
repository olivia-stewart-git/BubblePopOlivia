import SwiftUI

/// Represents the colour of a bubble with associated game points and spawn probability.
enum BubbleColor: String, CaseIterable, Codable {
    case red, pink, green, blue, black

    /// Points awarded for popping a bubble of this colour.
    var points: Int {
        switch self {
        case .red:   return 1
        case .pink:  return 2
        case .green: return 5
        case .blue:  return 8
        case .black: return 10
        }
    }

    /// Probability of this colour appearing (must sum to 1.0 across all cases).
    var probability: Double {
        switch self {
        case .red:   return 0.40
        case .pink:  return 0.30
        case .green: return 0.15
        case .blue:  return 0.10
        case .black: return 0.05
        }
    }

    /// SwiftUI colour used for rendering.
    var color: Color {
        switch self {
        case .red:   return .red
        case .pink:  return .pink
        case .green: return .green
        case .blue:  return .blue
        case .black: return .black
        }
    }

    /// Pick a random colour weighted by the probability table.
    static func randomWeighted() -> BubbleColor {
        let roll = Double.random(in: 0..<1)
        var cumulative = 0.0
        for c in BubbleColor.allCases {
            cumulative += c.probability
            if roll < cumulative { return c }
        }
        return .red // fallback
    }
}

/// A single bubble on the game screen.
struct Bubble: Identifiable {
    let id = UUID()
    let bubbleColor: BubbleColor
    var position: CGPoint
    let radius: CGFloat = 25

    /// Velocity used for the extended "moving bubbles" feature.
    var velocity: CGVector = .zero
}
