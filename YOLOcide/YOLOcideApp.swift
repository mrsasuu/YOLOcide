//
//  YOLOcideApp.swift
//  YOLOcide
//
//  Created by Antonio Javier Benítez Guijarro on 18/04/2026.
//

import SwiftUI

@main
struct YOLOcideApp: App {
    @StateObject private var historyStore = HistoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(historyStore)
        }
    }
}
