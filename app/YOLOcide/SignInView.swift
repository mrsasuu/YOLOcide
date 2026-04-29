import SwiftUI
import AuthenticationServices

struct SignInView: View {
    let onClose: () -> Void
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var authStore: AuthStore
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ActionSheetContainer(onClose: onClose) {
            if authStore.isSignedIn {
                accountContent
            } else {
                signInContent
            }
        }
    }

    // MARK: - Sign-in form

    private var signInContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(settings.t("signin.title"))
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.44)
                .foregroundStyle(Color(.label))
                .padding(.top, 16)

            Text(settings.t("signin.subtitle"))
                .font(.system(size: 15))
                .foregroundStyle(Color(.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
                .padding(.bottom, 28)

            if let error = authStore.error {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemRed))
                    .padding(.bottom, 12)
            }

            SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.email, .fullName]
            }, onCompletion: { result in
                switch result {
                case .success(let auth):
                    guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
                    Task { await authStore.signInWithApple(credential: credential) }
                case .failure(let err):
                    // Ignore user-initiated cancellation.
                    if (err as? ASAuthorizationError)?.code != .canceled {
                        authStore.error = err.localizedDescription
                    }
                }
            })
            .signInWithAppleButtonStyle(scheme == .dark ? .white : .black)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(authStore.isLoading)
            .opacity(authStore.isLoading ? 0.6 : 1)
            .padding(.bottom, 12)

            if authStore.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.bottom, 12)
            }

            googleButton
                .padding(.bottom, 16)

            Button(action: onClose) {
                Text(settings.t("signin.later"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.bottom, 34)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Account card (shown when signed in)

    private var accountContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.ycPurple)

                VStack(alignment: .leading, spacing: 3) {
                    if let name = authStore.currentUser?.name, !name.isEmpty {
                        Text(name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(.label))
                    }
                    if let email = authStore.currentUser?.email, !email.isEmpty {
                        Text(email)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    if authStore.currentUser?.name == nil && authStore.currentUser?.email == nil {
                        Text(settings.t("signin.signedin"))
                            .font(.system(size: 15))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }

                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 28)

            PrimaryButton(label: settings.t("signin.signout"), disabled: false) {
                authStore.signOut()
                onClose()
            }
            .padding(.bottom, 34)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Google button

    private var googleButton: some View {
        Button {
            Task { await authStore.signInWithGoogle() }
        } label: {
            HStack(spacing: 10) {
                Text("G")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(hex: "#4285F4"))
                    .frame(width: 20, height: 20)
                Text(settings.t("signin.google"))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(.label))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(scheme == .dark ? Color.white.opacity(0.10) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                scheme == .dark
                                    ? Color.white.opacity(0.15)
                                    : Color.black.opacity(0.15),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(authStore.isLoading)
        .opacity(authStore.isLoading ? 0.6 : 1)
    }
}
