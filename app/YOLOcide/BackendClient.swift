import Foundation

// MARK: - Response models

struct RemoteOption: Codable {
    let name: String
    let colorHex: String
}

struct RemoteResult: Codable {
    let name: String
    let colorHex: String
    let rank: Int
}

struct RemoteSpinSession: Codable {
    let id: String
    let spunAt: Date
    let isRanked: Bool
    let wheelOptions: [RemoteOption]
    let results: [RemoteResult]

    func toSpinSession() -> SpinSession {
        SpinSession(
            id: UUID(uuidString: id) ?? UUID(),
            timestamp: spunAt,
            winners: results.sorted { $0.rank < $1.rank }.map { SessionOption(name: $0.name, colorHex: $0.colorHex) },
            wheelOptions: wheelOptions.map { SessionOption(name: $0.name, colorHex: $0.colorHex) },
            isRankSession: isRanked,
            isSynced: true
        )
    }
}

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
    private let encoder: JSONEncoder

    init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 60
        session = URLSession(configuration: cfg)

        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        encoder = e

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
        try await withRetry {
            try await post("/auth/apple", body: AppleSignInBody(identityToken: identityToken, email: email, name: name))
        }
    }

    private struct GoogleSignInBody: Encodable {
        let idToken: String
    }

    func signInWithGoogle(idToken: String) async throws -> SessionResponse {
        try await withRetry {
            try await post("/auth/google", body: GoogleSignInBody(idToken: idToken))
        }
    }

    func me(token: String) async throws -> BackendUser {
        try await get("/me", token: token)
    }

    func fetchSessions(token: String) async throws -> [RemoteSpinSession] {
        try await get("/sessions", token: token)
    }

    func syncSession(_ spinSession: SpinSession, token: String) async throws {
        struct Option: Encodable { let name: String; let colorHex: String }
        struct Result: Encodable { let name: String; let colorHex: String; let rank: Int }
        struct Body: Encodable {
            let spunAt: Date
            let isRanked: Bool
            let wheelOptions: [Option]
            let results: [Result]
        }
        let body = Body(
            spunAt: spinSession.timestamp,
            isRanked: spinSession.isRankSession,
            wheelOptions: spinSession.wheelOptions.map { Option(name: $0.name, colorHex: $0.colorHex) },
            results: spinSession.winners.enumerated().map { Result(name: $0.element.name, colorHex: $0.element.colorHex, rank: $0.offset + 1) }
        )
        var req = URLRequest(url: baseURL.appending(path: "/sessions"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = try encoder.encode(body)
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw BackendError.from(data: data, response: response)
        }
    }

    // MARK: - Internals

    // Retries on transient network failures and 5xx responses (e.g. Render cold-start wakeup).
    private func withRetry<T>(maxAttempts: Int = 3, delay: Double = 2.0, operation: () async throws -> T) async throws -> T {
        var lastError: Error?
        for attempt in 0..<maxAttempts {
            if attempt > 0 {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            do {
                return try await operation()
            } catch let error as URLError {
                lastError = error
            } catch let error as BackendError {
                switch error {
                case .httpError(let status, _) where status >= 500:
                    lastError = error
                default:
                    throw error
                }
            }
        }
        throw lastError!
    }

    private func get<R: Decodable>(_ path: String, token: String) async throws -> R {
        var req = URLRequest(url: baseURL.appending(path: path))
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw BackendError.from(data: data, response: response)
        }
        return try decoder.decode(R.self, from: data)
    }

    private func post<B: Encodable, R: Decodable>(_ path: String, body: B) async throws -> R {
        var req = URLRequest(url: baseURL.appending(path: path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw BackendError.from(data: data, response: response)
        }
        return try decoder.decode(R.self, from: data)
    }
}
