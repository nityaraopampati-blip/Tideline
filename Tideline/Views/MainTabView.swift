import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            ScanView()
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
            LearnHubView()
                .tabItem { Label("Learn", systemImage: "gamecontroller.fill") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
