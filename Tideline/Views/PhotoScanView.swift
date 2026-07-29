import SwiftUI

struct PhotoScanView: View {
    var body: some View {
        ContentUnavailableView(
            "Photo Scanning",
            systemImage: "camera.fill",
            description: Text("Coming in the next build step.")
        )
        .navigationTitle("Take Photo")
    }
}

#Preview {
    NavigationStack { PhotoScanView() }
}
