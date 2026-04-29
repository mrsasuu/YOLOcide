import Foundation

// MARK: - Response models

struct BackendUser: Codable {
    let id: String
    let appleUserId: String?
    let googleUserId: String?
    let email: String?
    let name: String?
    let createdAt: Date
    let updatedAt: Date
    let lastLoginAt: Date?
}

struct SessionResponse: Codable {
    let token: String
    let expiresAt: Date
    let user: BackendUser
}

// MARK: - Error

enum BackendError: LocalizedError {
    case httpError(Int, String)

    var errorDescription: String? {
        switch self {
        case .httpError(_, let msg): return msg
        }
    }

    static func from(data: Data, response: URLResponse) -> BackendError {
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if let json = try? JSONDecoder().decode([String: String].self, from: data),
           let msg = json["message"] {
            return .httpError(status, msg)
        }
        return .httpError(status, "Request failed (\(status))")
    }
}

// MARK: - Client

final class BackendClient {
    // Update for production before release.
    #if DEBUG
    private let baseURL = URL(string: "http://localhost:8080")!
    #else
    private let baseURL = URL(string: "https://yolocide.onrender.com")!
    #endif

    private let session: URLSession
    private let decoder: JSONDecoder

    init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        session = URLSession(configuration: cfg)

        // Backend emits camelCase JSON + ISO 8601 dates (with optional fractional seconds).
        let d = JSONDecoder()
        let fmtFrac = ISO8601DateFormatter()
        fmtFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime]
        d.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            let s = try c.decode(String.self)
            if let date = fmtFrac.date(from: s) ?? fmt.date(from: s) { return date }
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid date: \(s)")
        }
        self.decoder = d
    }

    // MARK: - Auth

    private struct AppleSignInBody: Encodable {
        let identityToken: String
        let email: String?
        let name: String?
    }

    func signInWithApple(identityToken: String, email: String?, name: String?) async throws -> SessionResponse {
        try await post("/auth/apple", body: AppleSignInBody(identityToken: identityToken, email: email, name: name))
    }

    // MARK: - Internals

    private func post<B: Encodable, R: Decodable>(_ path: String, body: B) async throws -> R {
        var req = URLRequest(url: baseURL.appending(path: path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw BackendError.from(data: data, response: response)
        }
        return try decoder.decode(R.self, from: data)
    }
}
