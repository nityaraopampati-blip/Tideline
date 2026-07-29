import SwiftUI

/// Placeholder for the Community phase (cleanup events, invites via
/// WhatsApp/iMessage/Instagram) — not built yet. Reserving the tab now so
/// the navigation shape is ready for it.
struct CommunityView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "person.3.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(TideTheme.tide)
                Text("Community")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)
                Text("Cleanup events and invites are coming in a future update.")
                    .font(.system(size: 13))
                    .foregroundStyle(TideTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .padding()
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    CommunityView()
        .environmentObject(AppState())
}
