import SwiftUI

struct BarcodeScanView: View {
    var body: some View {
        ContentUnavailableView(
            "Barcode Scanning",
            systemImage: "barcode.viewfinder",
            description: Text("Coming in the next build step.")
        )
        .navigationTitle("Scan Barcode")
    }
}

#Preview {
    NavigationStack { BarcodeScanView() }
}
