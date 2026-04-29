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
        // Show cached display info immediately, then refresh from the backend.
        let name  = UserDefaults.standard.string(forKey: Self.displayNameKey)
        let email = UserDefaults.standard.string(forKey: Self.displayEmailKey)
        if name != nil || email != nil {
            currentUser = BackendUser(
                id: "", appleUserId: nil, googleUserId: nil,
                email: email, name: name,
                createdAt: Date(), updatedAt: Date(), lastLoginAt: nil
            )
        }
        Task { await refreshCurrentUser() }
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

    // MARK: - Google

    func signInWithGoogle() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let idToken = try await GoogleSignInHandler.shared.signIn()
            let response = try await client.signInWithGoogle(idToken: idToken)
            persist(response: response)
        } catch let err as GoogleSignInError {
            if case .cancelled = err { return }
            self.error = err.localizedDescription
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

    func refreshCurrentUser() async {
        guard let token = sessionToken else { return }
        do {
            let user = try await client.me(token: token)
            currentUser = user
            if let name = user.name {
                UserDefaults.standard.set(name, forKey: Self.displayNameKey)
            }
            if let email = user.email {
                UserDefaults.standard.set(email, forKey: Self.displayEmailKey)
            }
        } catch let err as BackendError {
            if case .httpError(401, _) = err { signOut() }
            // Other errors (offline, server down): keep showing cached data.
        } catch {
            // Network errors: silently ignore.
        }
    }

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
        Task { await refreshCurrentUser() }
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
