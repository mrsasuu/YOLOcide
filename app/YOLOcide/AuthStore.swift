import AuthenticationServices
import Foundation
import Network

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

    private weak var historyStore: HistoryStore?
    private var networkMonitor: NWPathMonitor?
    private let monitorQueue = DispatchQueue(label: "com.yolocide.network")
    private var isSyncing = false

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

    // MARK: - Store wiring

    /// Called once from YOLOcideApp after both stores are initialised.
    func configure(historyStore: HistoryStore) {
        self.historyStore = historyStore
        guard networkMonitor == nil else { return }
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else { return }
            Task { @MainActor [weak self] in await self?.syncPending() }
        }
        monitor.start(queue: monitorQueue)
        networkMonitor = monitor
        if isSignedIn {
            Task { await fetchAndMergeHistory() }
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

    // MARK: - Session sync

    func syncSession(_ spinSession: SpinSession) {
        guard let token = sessionToken else { return }
        Task {
            do {
                try await client.syncSession(spinSession, token: token)
                historyStore?.markSynced(id: spinSession.id)
            } catch {
                // Will be retried by syncPending() on next network restore.
            }
        }
    }

    func syncPending() async {
        guard !isSyncing, let token = sessionToken, let historyStore else { return }
        let pending = historyStore.sessions.filter { !$0.isSynced }
        guard !pending.isEmpty else { return }
        isSyncing = true
        defer { isSyncing = false }
        for spinSession in pending {
            do {
                try await client.syncSession(spinSession, token: token)
                historyStore.markSynced(id: spinSession.id)
            } catch {
                break // first failure likely means offline; stop and wait for next restore
            }
        }
    }

    // MARK: - Account deletion

    func deleteAccount() async {
        guard let token = sessionToken else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            try await client.deleteAccount(token: token)
        } catch let err as BackendError {
            // 404 means the account was already deleted — proceed with local cleanup.
            if case .httpError(let status, _) = err, status != 404 {
                self.error = err.localizedDescription
                return
            }
        } catch {
            self.error = error.localizedDescription
            return
        }
        historyStore?.clearAll()
        signOut()
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

    // MARK: - Token access

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
        } catch {
            // Network errors: keep showing cached data.
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
        Task { await fetchAndMergeHistory() }
        Task { await syncPending() }
    }

    func fetchAndMergeHistory() async {
        guard let token = sessionToken, let historyStore else { return }
        do {
            let remote = try await client.fetchSessions(token: token)
            historyStore.merge(remote: remote.map { $0.toSpinSession() })
        } catch {
            // Non-fatal: local history is still shown if fetch fails.
        }
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
