import SwiftUI

@main
struct YOLOcideApp: App {
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(historyStore)
                .environmentObject(settings)
                .preferredColorScheme(settings.appearance.colorScheme)
        }
    }
}
