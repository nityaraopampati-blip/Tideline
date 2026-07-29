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
            ChallengesView()
                .tabItem { Label("Challenges", systemImage: "trophy.fill") }
            CommunityView()
                .tabItem { Label("Community", systemImage: "person.3.fill") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
