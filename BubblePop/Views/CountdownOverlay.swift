import SwiftUI

struct CountdownOverlay: View {
    let value: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            Text(value > 0 ? "\(value)" : "Go!")
                .font(.system(size: 80, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    CountdownOverlay(value: 3)
}
