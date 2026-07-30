import SwiftUI

/// A polished, evite-style invitation card for a cleanup event — rendered
/// to an image and shared via ShareLink, rather than a plain text message.
struct EventInviteCard: View {
    let event: CleanupEvent

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: event.type.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                Text("YOU'RE INVITED")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(2.5)
                    .foregroundStyle(.white.opacity(0.92))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(
                LinearGradient(colors: [TideTheme.seafoam, TideTheme.deep], startPoint: .topLeading, endPoint: .bottomTrailing)
            )

            VStack(alignment: .leading, spacing: 16) {
                Text(event.name)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(TideTheme.ink)

                VStack(alignment: .leading, spacing: 12) {
                    inviteRow(icon: "calendar", text: event.date.formatted(date: .complete, time: .omitted))
                    inviteRow(
                        icon: "clock.fill",
                        text: "\(event.date.formatted(date: .omitted, time: .shortened)) – \(event.endDate.formatted(date: .omitted, time: .shortened))"
                    )
                    inviteRow(icon: "mappin.circle.fill", text: event.location)
                    inviteRow(icon: "tag.fill", text: event.type.rawValue)
                }

                if !event.notes.isEmpty {
                    Divider()
                    Text(event.notes)
                        .font(.system(size: 14))
                        .foregroundStyle(TideTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(TideTheme.tide)
                    Text("Shared via Tideline")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(TideTheme.inkSoft)
                }
            }
            .padding(26)
        }
        .frame(width: 380)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func inviteRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(TideTheme.tide)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(TideTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    EventInviteCard(
        event: CleanupEvent(
            name: "Sunset Beach Sweep",
            location: "Sunset Beach",
            type: .beachCleanup,
            date: Date(),
            endDate: Date().addingTimeInterval(7200),
            notes: "Bring gloves and a reusable water bottle."
        )
    )
    .padding()
}
