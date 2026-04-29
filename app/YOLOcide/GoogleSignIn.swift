import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

// MARK: - Errors

enum GoogleSignInError: LocalizedError {
    case missingCode
    case noIDToken
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .missingCode: return "Google did not return an authorization code."
        case .noIDToken:   return "Google did not return an identity token."
        case .cancelled:   return nil
        case .unknown:     return "Google sign-in failed."
        }
    }
}

// MARK: - Handler

/// Drives the Google OAuth2 PKCE flow via ASWebAuthenticationSession.
/// No third-party SDK — uses only AuthenticationServices and CryptoKit.
@MainActor
final class GoogleSignInHandler {
    static let shared = GoogleSignInHandler()

    private var activeSession: ASWebAuthenticationSession?
    private let contextProvider = PresentationContext()

    /// Returns a verified Google ID token string, ready to post to /auth/google.
    func signIn() async throws -> String {
        let clientID      = AppConfig.googleClientID
        let scheme        = AppConfig.googleCallbackScheme
        let redirectURI   = "\(scheme):/oauth2redirect"

        let verifier  = PKCE.generateVerifier()
        let challenge = PKCE.challenge(for: verifier)

        var comps = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        comps.queryItems = [
            URLQueryItem(name: "client_id",             value: clientID),
            URLQueryItem(name: "redirect_uri",          value: redirectURI),
            URLQueryItem(name: "response_type",         value: "code"),
            URLQueryItem(name: "scope",                 value: "openid email profile"),
            URLQueryItem(name: "code_challenge",        value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state",                 value: UUID().uuidString),
        ]

        let callbackURL: URL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            let session = ASWebAuthenticationSession(
                url: comps.url!,
                callbackURLScheme: scheme
            ) { url, error in
                if let error {
                    let code = (error as? ASWebAuthenticationSessionError)?.code
                    if code == .canceledLogin {
                        continuation.resume(throwing: GoogleSignInError.cancelled)
                    } else {
                        continuation.resume(throwing: error)
                    }
                } else if let url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: GoogleSignInError.unknown)
                }
            }
            session.presentationContextProvider = contextProvider
            session.prefersEphemeralWebBrowserSession = false
            activeSession = session
            session.start()
        }
        activeSession = nil

        guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value
        else { throw GoogleSignInError.missingCode }

        return try await exchangeCode(code, verifier: verifier, clientID: clientID, redirectURI: redirectURI)
    }

    // MARK: - Token exchange

    private func exchangeCode(
        _ code: String,
        verifier: String,
        clientID: String,
        redirectURI: String
    ) async throws -> String {
        var req = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params: [String: String] = [
            "grant_type":    "authorization_code",
            "code":          code,
            "client_id":     clientID,
            "redirect_uri":  redirectURI,
            "code_verifier": verifier,
        ]
        req.httpBody = params
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: req)

        struct TokenResponse: Decodable { let id_token: String? }
        let tokens = try JSONDecoder().decode(TokenResponse.self, from: data)
        guard let idToken = tokens.id_token else { throw GoogleSignInError.noIDToken }
        return idToken
    }
}

// MARK: - Presentation context

private final class PresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .keyWindow
            ?? UIWindow()
    }
}

// MARK: - PKCE helpers

private enum PKCE {
    static func generateVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncoded()
    }

    static func challenge(for verifier: String) -> String {
        Data(SHA256.hash(data: Data(verifier.utf8))).base64URLEncoded()
    }
}

private extension Data {
    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
