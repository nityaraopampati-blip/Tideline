import SwiftUI

struct RecycleRunnerView: View {
    var body: some View {
        ContentUnavailableView(
            "Recycle Runner",
            systemImage: "figure.run",
            description: Text("Coming in the next build step.")
        )
        .navigationTitle("Recycle Runner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { RecycleRunnerView() }
}
