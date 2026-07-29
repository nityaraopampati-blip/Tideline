import SwiftUI

/// Temporary root view for the scaffolding milestone. This confirms the
/// bundled seed data loads correctly; it will be replaced by the real
/// Welcome / Sign-in flow in the next milestone.
struct ContentView: View {
    private let library = PlasticItemLibrary.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Tideline")
                .font(.largeTitle.bold())
            Text("Scaffolding check")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(library.items.count) plastic items loaded")
            Text("\(library.quizQuestions.count) quiz questions loaded")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
