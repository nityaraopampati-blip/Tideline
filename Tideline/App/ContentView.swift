import SwiftUI

/// Routes between the sign-in flow, the once-only baseline quiz, and the
/// main app, based on where the user is in that sequence.
struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if !appState.isSignedIn {
                WelcomeView()
            } else if !appState.hasPromptedBaselineQuiz {
                BaselineQuizView()
            } else {
                MainTabView()
            }
        }
        .sheet(item: $appState.pendingInvite) { invite in
            JoinEventPromptView(
                event: invite,
                onJoin: { appState.acceptPendingInvite() },
                onDismiss: { appState.dismissPendingInvite() }
            )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
