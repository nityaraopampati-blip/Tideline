import SwiftUI

struct PlasticGoView: View {
    var body: some View {
        ContentUnavailableView(
            "Plastic-Go",
            systemImage: "camera.viewfinder",
            description: Text("Coming in the next build step.")
        )
        .navigationTitle("Plastic-Go")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { PlasticGoView() }
}
