import Foundation

@MainActor
public extension SessionStore {
    /// Branche la synchronisation WatchConnectivity sur le store.
    func attachWatchSync(_ service: WatchSyncService = .shared) {
        syncer = service
        service.onRemoteState = { [weak self] state in
            Task { @MainActor in
                self?.apply(remote: state)
            }
        }
        service.activate()
        service.sendState(snapshot)
    }
}
