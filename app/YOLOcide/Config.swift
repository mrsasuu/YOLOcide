enum AppConfig {
    static let googleClientID = "772915971259-i9pn649pg0h1q15j3vs45km9n7lagp55.apps.googleusercontent.com"

    static var googleCallbackScheme: String {
        googleClientID.components(separatedBy: ".").reversed().joined(separator: ".")
    }
}
