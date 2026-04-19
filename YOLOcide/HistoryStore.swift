//
//  HistoryStore.swift
//  YOLOcide
//

import SwiftUI

final class HistoryStore: ObservableObject {
    @Published private(set) var sessions: [SpinSession] = []

    private let storageKey = "yolocide_history_v1"

    init() { load() }

    func add(_ session: SpinSession) {
        sessions.insert(session, at: 0)
        save()
    }

    func remove(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        save()
    }

    func clearAll() {
        sessions = []
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SpinSession].self, from: data)
        else { return }
        sessions = decoded
    }
}
