import SwiftUI

final class HistoryStore: ObservableObject {
    @Published private(set) var sessions: [SpinSession] = []

    private let storageKey = "yolocide_history_v1"

    init() { load() }

    func add(_ session: SpinSession) {
        sessions.insert(session, at: 0)
        save()
    }

    func markSynced(id: UUID) {
        guard let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[idx].isSynced = true
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

    /// Merges sessions fetched from the backend into the local store.
    /// Remote sessions (already synced) replace local synced sessions.
    /// Local unsynced sessions are preserved unless their timestamp matches a remote one.
    func merge(remote: [SpinSession]) {
        let pending = sessions.filter { !$0.isSynced }
        let trulyPending = pending.filter { local in
            !remote.contains { abs($0.timestamp.timeIntervalSince(local.timestamp)) < 2 }
        }
        sessions = (remote + trulyPending).sorted { $0.timestamp > $1.timestamp }
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
