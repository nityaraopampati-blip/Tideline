import SwiftUI

struct CommunityView: View {
    @State private var events: [CleanupEvent] = CommunityStore.shared.events
    @State private var showCreateForm = false
    @State private var pendingDeleteID: String?

    private var upcomingEvents: [CleanupEvent] {
        events.filter(\.isUpcoming).sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    tipBox

                    HStack {
                        Text("Upcoming Cleanups")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(TideTheme.ink)
                        Spacer()
                        Button("+ Create Event") { showCreateForm = true }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(TideTheme.tide)
                    }

                    if upcomingEvents.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(upcomingEvents) { event in
                                eventCard(event)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear { events = CommunityStore.shared.events }
            .sheet(isPresented: $showCreateForm) {
                CreateEventSheet { newEvent in
                    CommunityStore.shared.addEvent(newEvent)
                    events = CommunityStore.shared.events
                }
            }
            .confirmationDialog(
                "Delete this event?",
                isPresented: Binding(
                    get: { pendingDeleteID != nil },
                    set: { if !$0 { pendingDeleteID = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let id = pendingDeleteID {
                        CommunityStore.shared.deleteEvent(id)
                        events = CommunityStore.shared.events
                    }
                    pendingDeleteID = nil
                }
                Button("Cancel", role: .cancel) { pendingDeleteID = nil }
            } message: {
                Text("This can't be undone.")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            EyebrowText(text: "Community")
            Text("Cleanups")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
        }
        .padding(.top, 8)
    }

    private var tipBox: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("📍").font(.system(size: 16))
            Text("Heads up: events don't automatically show up for other people — creating one only saves it on your device. Tap the share icon on your event to send an invite through Messages, WhatsApp, Instagram, or whatever you've got, so friends know to come.")
                .font(.system(size: 12.5))
                .foregroundStyle(Color(hex: 0x0D3A32))
        }
        .padding(12)
        .background(TideTheme.seafoamLight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.wave")
                .font(.system(size: 34))
                .foregroundStyle(TideTheme.inkSoft.opacity(0.4))
            Text("No cleanups yet — be the first to create one for your community.")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func eventCard(_ event: CleanupEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle().fill(eventTypeColor(event.type).opacity(0.16)).frame(width: 44, height: 44)
                    Image(systemName: event.type.icon)
                        .foregroundStyle(eventTypeColor(event.type))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(event.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(TideTheme.ink)
                    Text("\(event.type.rawValue) · \(event.location)")
                        .font(.system(size: 11))
                        .foregroundStyle(TideTheme.inkSoft)
                    Text(event.timeRangeText)
                        .font(.system(size: 11))
                        .foregroundStyle(TideTheme.inkSoft)
                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.system(size: 11.5))
                            .foregroundStyle(TideTheme.inkSoft)
                            .padding(.top, 2)
                    }
                    Text("👥 \(event.goingCount) going")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(TideTheme.tide)
                        .padding(.top, 2)
                }
                Spacer()
            }

            if event.isHostedByMe {
                Text("📤 Share to invite people — they won't see this event automatically.")
                    .font(.system(size: 10.5))
                    .foregroundStyle(TideTheme.inkSoft)
            }

            HStack(spacing: 10) {
                if event.isHostedByMe {
                    Text("HOSTING")
                        .font(.system(size: 9.5, weight: .bold))
                        .tracking(0.4)
                        .foregroundStyle(TideTheme.tide)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(TideTheme.seafoamLight)
                        .clipShape(Capsule())
                } else {
                    Button(event.hasJoined ? "Going ✓" : "Join") {
                        CommunityStore.shared.toggleJoin(event.id)
                        events = CommunityStore.shared.events
                    }
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(event.hasJoined ? TideTheme.seafoamLight : TideTheme.tide)
                    .foregroundStyle(event.hasJoined ? TideTheme.deep : .white)
                    .clipShape(Capsule())
                }

                shareButton(for: event)

                Spacer()

                Button {
                    pendingDeleteID = event.id
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundStyle(TideTheme.coral)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// Renders the evite-style card to an image for sharing — a proper
    /// invite instead of a plain text message.
    @MainActor
    private func inviteImage(for event: CleanupEvent) -> Image {
        let renderer = ImageRenderer(content: EventInviteCard(event: event))
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }

    /// Shares a `tideline://join` link (with the evite as its preview
    /// image) so that anyone who taps it and also has Tideline installed
    /// can add the event to their own Community list. Falls back to
    /// sharing just the image if the link can't be built.
    @ViewBuilder
    private func shareButton(for event: CleanupEvent) -> some View {
        let label = Image(systemName: "square.and.arrow.up")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(TideTheme.deep)
            .padding(8)
            .background(TideTheme.surface2)
            .clipShape(Circle())

        if let inviteURL = EventDeepLink.url(for: event) {
            ShareLink(item: inviteURL, preview: SharePreview(event.name, image: inviteImage(for: event))) {
                label
            }
        } else {
            ShareLink(item: inviteImage(for: event), preview: SharePreview(event.name, image: inviteImage(for: event))) {
                label
            }
        }
    }

    private func eventTypeColor(_ type: CleanupEventType) -> Color {
        switch type {
        case .beachCleanup: return Color(hex: 0x3B5FE8)
        case .riverCleanup: return TideTheme.tide
        case .parkCleanup: return TideTheme.deep
        case .neighborhoodPickup: return Color(hex: 0xE8A93B)
        }
    }
}

#Preview {
    CommunityView()
        .environmentObject(AppState())
}
