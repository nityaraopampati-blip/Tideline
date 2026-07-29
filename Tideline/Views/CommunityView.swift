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
            Text("Events you create are saved on this device for now. Use the share button on any event to invite friends — it opens Messages, WhatsApp, Instagram, or whatever you've got installed.")
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
                    Circle().fill(TideTheme.seafoamLight).frame(width: 44, height: 44)
                    Image(systemName: event.type.icon)
                        .foregroundStyle(TideTheme.deep)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(event.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(TideTheme.ink)
                    Text("\(event.type.rawValue) · \(event.location) · \(event.date.formatted(date: .abbreviated, time: .omitted))")
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

                ShareLink(item: shareText(for: event)) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TideTheme.deep)
                        .padding(8)
                        .background(TideTheme.surface2)
                        .clipShape(Circle())
                }

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

    private func shareText(for event: CleanupEvent) -> String {
        "Join me for \(event.name) — a \(event.type.rawValue.lowercased()) at \(event.location) on \(event.date.formatted(date: .abbreviated, time: .omitted)). Logged on Tideline 🌊"
    }
}

#Preview {
    CommunityView()
        .environmentObject(AppState())
}
