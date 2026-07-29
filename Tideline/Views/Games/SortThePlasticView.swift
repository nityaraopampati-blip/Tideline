import SwiftUI

struct SortThePlasticView: View {
    var body: some View {
        ContentUnavailableView(
            "Sort the Plastic",
            systemImage: "arrow.3.trianglepath",
            description: Text("Coming in the next build step.")
        )
        .navigationTitle("Sort the Plastic")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SortThePlasticView() }
}
