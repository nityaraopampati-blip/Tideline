import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            TideTheme.background.ignoresSafeArea()

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

                Button(action: signIn) {
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
    }

    private func signIn() {
        appState.signIn(displayName: nil)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
}
