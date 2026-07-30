import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showResetConfirmation = false
    @State private var showNewAccountConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHead

                    TideCard {
                        VStack(spacing: 0) {
                            settingRow(label: "Account ID", value: shortID(appState.profile?.id))
                            if let createdAt = appState.profile?.createdAt {
                                settingRow(label: "Member Since", value: createdAt.formatted(date: .abbreviated, time: .omitted), showDivider: false)
                            }
                        }
                    }

                    TideCard {
                        VStack(alignment: .leading, spacing: 10) {
                            EyebrowText(text: "Baseline Quiz")
                            if let result = appState.baselineQuizScore {
                                HStack {
                                    Text("\(result.score) / \(result.totalQuestions)")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(TideTheme.deep)
                                    Spacer()
                                    Text(result.takenAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 12))
                                        .foregroundStyle(TideTheme.inkSoft)
                                }
                            } else {
                                Text("You skipped the baseline quiz.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(TideTheme.inkSoft)
                            }
                        }
                    }

                    if !appState.switchableAccounts.isEmpty {
                        switchAccountCard
                    }

                    VStack(spacing: 10) {
                        Button("Create Another Account") {
                            showNewAccountConfirmation = true
                        }
                        .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.deep))

                        Button("Reset Account", role: .destructive) {
                            showResetConfirmation = true
                        }
                        .buttonStyle(TideOutlineButtonStyle(tint: TideTheme.coral))
                    }
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .confirmationDialog(
                "Reset your account?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Account", role: .destructive) { appState.resetAccount() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This erases all your scans, XP, levels, badges, challenges, and community events, and takes you back to the very beginning. This can't be undone.")
            }
            .confirmationDialog(
                "Create another account?",
                isPresented: $showNewAccountConfirmation,
                titleVisibility: .visible
            ) {
                Button("Continue") { appState.createAnotherAccount() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Tideline only keeps one account signed in at a time, so \(appState.profile?.displayName ?? "this account") will be set aside — nothing is lost, and you can switch back from Settings anytime. Then whoever's holding the phone can sign in and start their own account.")
            }
        }
    }

    private var switchAccountCard: some View {
        TideCard {
            VStack(alignment: .leading, spacing: 12) {
                EyebrowText(text: "Switch Account")
                VStack(spacing: 0) {
                    ForEach(Array(appState.switchableAccounts.enumerated()), id: \.element.id) { index, account in
                        Button {
                            appState.switchAccount(to: account.id)
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(TideTheme.seafoamLight)
                                        .frame(width: 34, height: 34)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(TideTheme.deep)
                                }
                                Text(account.displayName ?? "Tideline User")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(TideTheme.ink)
                                Spacer()
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(TideTheme.tide)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(TidePressableStyle())
                        if index < appState.switchableAccounts.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var profileHead: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [TideTheme.seafoam, TideTheme.deep], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 74, height: 74)
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
            Text(appState.profile?.displayName ?? "Tideline User")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(TideTheme.ink)
        }
        .padding(.top, 12)
    }

    private func settingRow(label: String, value: String, showDivider: Bool = true) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(TideTheme.inkSoft)
                Spacer()
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(TideTheme.ink)
            }
            .padding(.vertical, 10)
            if showDivider {
                Divider()
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
