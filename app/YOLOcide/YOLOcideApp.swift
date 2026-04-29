import SwiftUI

@main
struct YOLOcideApp: App {
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var settings = SettingsStore()
    @StateObject private var authStore = AuthStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(historyStore)
                .environmentObject(settings)
                .environmentObject(authStore)
                .preferredColorScheme(settings.appearance.colorScheme)
        }
    }
}
