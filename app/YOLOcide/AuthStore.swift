import AuthenticationServices
import Foundation

@MainActor
final class AuthStore: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUser: BackendUser?
    @Published var isLoading = false
    @Published var error: String?

    private let client = BackendClient()
    private let keychain = KeychainStore()

    private static let sessionKey = "yolocide_session_jwt"
    private static let displayNameKey = "yolocide_user_display_name"
    private static let displayEmailKey = "yolocide_user_display_email"

    init() {
        guard keychain.read(key: Self.sessionKey) != nil else { return }
        isSignedIn = true
        // Restore cached display info so the account card shows without a network call.
        let name  = UserDefaults.standard.string(forKey: Self.displayNameKey)
        let email = UserDefaults.standard.string(forKey: Self.displayEmailKey)
        if name != nil || email != nil {
            currentUser = BackendUser(
                id: "", appleUserId: nil, googleUserId: nil,
                email: email, name: name,
                createdAt: Date(), updatedAt: Date(), lastLoginAt: nil
            )
        }
    }

    // MARK: - Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        guard let tokenData = credential.identityToken,
              let identityToken = String(data: tokenData, encoding: .utf8) else {
            error = "Could not read the Apple identity token."
            return
        }

        isLoading = true
        error = nil
        defer { isLoading = false }

        let email = credential.email
        let name: String? = {
            guard let fn = credential.fullName else { return nil }
            return [fn.givenName, fn.familyName]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
                .nonEmpty
        }()

        do {
            let response = try await client.signInWithApple(
                identityToken: identityToken,
                email: email,
                name: name
            )
            persist(response: response)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Sign out

    func signOut() {
        keychain.delete(key: Self.sessionKey)
        UserDefaults.standard.removeObject(forKey: Self.displayNameKey)
        UserDefaults.standard.removeObject(forKey: Self.displayEmailKey)
        currentUser = nil
        isSignedIn = false
        error = nil
    }

    // MARK: - Token access (for future authenticated requests)

    var sessionToken: String? {
        keychain.read(key: Self.sessionKey)
    }

    // MARK: - Internals

    private func persist(response: SessionResponse) {
        keychain.save(key: Self.sessionKey, value: response.token)
        if let name = response.user.name {
            UserDefaults.standard.set(name, forKey: Self.displayNameKey)
        }
        if let email = response.user.email {
            UserDefaults.standard.set(email, forKey: Self.displayEmailKey)
        }
        currentUser = response.user
        isSignedIn = true
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
