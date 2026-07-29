import SwiftUI

/// Dedicated "Scan" tab — quick access to barcode/photo/search without
/// scrolling down through the Home dashboard first.
struct ScanView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    ScanActionList()
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .withScanDestinations()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            EyebrowText(text: "Log an Item")
            Text("Scan or Add")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
        }
        .padding(.top, 8)
    }
}

#Preview {
    ScanView()
        .environmentObject(AppState())
}
