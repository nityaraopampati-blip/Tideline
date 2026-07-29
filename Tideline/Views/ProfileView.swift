import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent("Name", value: appState.profile?.displayName ?? "Tideline User")
                    LabeledContent("Account ID", value: shortID(appState.profile?.id))
                    if let createdAt = appState.profile?.createdAt {
                        LabeledContent("Member Since", value: createdAt.formatted(date: .abbreviated, time: .omitted))
                    }
                }

                Section("Baseline Quiz") {
                    if let result = appState.baselineQuizScore {
                        LabeledContent("Score", value: "\(result.score) / \(result.totalQuestions)")
                        LabeledContent("Taken", value: result.takenAt.formatted(date: .abbreviated, time: .omitted))
                    } else {
                        Text("You skipped the baseline quiz.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Points & Badges") {
                    Text("Coming soon in a future update!")
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button("Log Out", role: .destructive) {
                        showSignOutConfirmation = true
                    }
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog(
                "Log out of Tideline?",
                isPresented: $showSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) { appState.signOut() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func shortID(_ id: String?) -> String {
        guard let id else { return "—" }
        return String(id.prefix(8))
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
