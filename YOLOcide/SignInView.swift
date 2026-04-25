import SwiftUI
import AuthenticationServices

struct SignInView: View {
    let onClose: () -> Void
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ActionSheetContainer(onClose: onClose) {
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

                SignInWithAppleButton(.signIn, onRequest: { _ in }, onCompletion: { _ in })
                    .signInWithAppleButtonStyle(scheme == .dark ? .white : .black)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.bottom, 12)

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
    }

    private var googleButton: some View {
        Button {} label: {
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
    }
}
