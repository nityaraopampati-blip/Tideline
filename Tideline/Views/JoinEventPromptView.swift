import SwiftUI

/// Shown when a `tideline://join` link is opened — lets the person Accept
/// or Decline before anything is added to their own Community list. This
/// only ever updates their own device; there's no shared backend, so the
/// original host's "going" count doesn't change either way.
struct JoinEventPromptView: View {
    let event: CleanupEvent
    let onJoin: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            EyebrowText(text: "You're Invited")
            EventInviteCard(event: event)
                .padding(.horizontal, 12)

            Text("Accepting adds this cleanup to your own Community tab. Tideline doesn't have shared accounts yet, so the host won't see whether you accepted or declined.")
                .font(.system(size: 12))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            HStack(spacing: 12) {
                Button("✕ Decline") { onDismiss() }
                    .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.coral))
                Button("✓ Accept") { onJoin() }
                    .buttonStyle(TideCTAButtonStyle(tint: TideTheme.tide))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(TideTheme.background.ignoresSafeArea())
    }
}

#Preview {
    JoinEventPromptView(
        event: CleanupEvent(
            name: "Sunset Beach Sweep",
            location: "Sunset Beach",
            type: .beachCleanup,
            date: Date(),
            endDate: Date().addingTimeInterval(7200),
            notes: "Bring gloves and a reusable water bottle."
        ),
        onJoin: {},
        onDismiss: {}
    )
}
