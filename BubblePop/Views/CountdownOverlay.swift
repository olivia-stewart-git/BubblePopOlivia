import SwiftUI

/// Full-screen countdown overlay shown before gameplay begins (extended feature 2).
struct CountdownOverlay: View {
    let value: Int

    @State private var scale: CGFloat = 2.0
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            Text(value > 0 ? "\(value)" : "Go!")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    animate()
                }
                .onChange(of: value) { _, _ in
                    animate()
                }
        }
    }

    private func animate() {
        scale = 2.0
        opacity = 0.0
        withAnimation(.easeOut(duration: 0.5)) {
            scale = 1.0
            opacity = 1.0
        }
        withAnimation(.easeIn(duration: 0.3).delay(0.6)) {
            opacity = 0.0
        }
    }
}

#Preview {
    CountdownOverlay(value: 3)
}
