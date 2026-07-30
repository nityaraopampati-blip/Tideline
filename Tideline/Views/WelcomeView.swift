import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var phase: Phase = .intro
    @State private var nameInput = ""
    @FocusState private var nameFieldFocused: Bool

    private enum Phase {
        case intro
        case nameEntry
    }

    var body: some View {
        ZStack {
            TideTheme.background.ignoresSafeArea()

            switch phase {
            case .intro:
                introView
            case .nameEntry:
                nameEntryView
            }
        }
    }

    private var introView: some View {
        VStack(spacing: 22) {
            Spacer()

            Text("🌊")
                .font(.system(size: 56))

            Text("Welcome to Tideline")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.deep)

            Text("Scan products, cut plastic, and see the difference you're making.")
                .font(.system(size: 14))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                phase = .nameEntry
            } label: {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Sign in with Apple")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)

            Text("Placeholder sign-in — real Sign in with Apple turns on once iCloud capabilities are enabled in Xcode.")
                .font(.caption2)
                .foregroundStyle(TideTheme.inkSoft.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private var nameEntryView: some View {
        VStack(spacing: 22) {
            Spacer()

            Text("👋")
                .font(.system(size: 56))

            Text("What should we call you?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(TideTheme.deep)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("We'll use it to say hi on your home screen.")
                .font(.system(size: 14))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            TextField("Your name", text: $nameInput)
                .font(.system(size: 17, weight: .medium))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($nameFieldFocused)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 32)
                .submitLabel(.done)
                .onSubmit(finishSignIn)

            Spacer()

            Button("Continue") { finishSignIn() }
                .buttonStyle(TideCTAButtonStyle(tint: TideTheme.tide))
                .padding(.horizontal, 32)
                .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)

            Button("Skip for now") { appState.signIn(displayName: nil) }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(TideTheme.inkSoft)

            Spacer()
        }
        .onAppear { nameFieldFocused = true }
    }

    private func finishSignIn() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        appState.signIn(displayName: trimmed.isEmpty ? nil : trimmed)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
}
