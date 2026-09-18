import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

/// Synchronisation iPhone <-> Apple Watch de l'état des visites.
///
/// L'`applicationContext` de WatchConnectivity transporte toujours le dernier
/// état connu (il écrase le précédent), ce qui correspond exactement à notre
/// modèle : un instantané daté que l'autre appareil fusionne.
public final class WatchSyncService: NSObject, SessionSyncing {
    public static let shared = WatchSyncService()

    /// Appelé sur le thread principal quand l'autre appareil envoie un état.
    public var onRemoteState: ((SessionState) -> Void)?

    /// Nombre maximum de visites transmises, pour rester sous la limite de
    /// taille des messages WatchConnectivity.
    private let transferLimit = 250

    #if canImport(WatchConnectivity)
    private var connectivity: WCSession? {
        WCSession.isSupported() ? WCSession.default : nil
    }
    #endif

    public var isSupported: Bool {
        #if canImport(WatchConnectivity)
        return WCSession.isSupported()
        #else
        return false
        #endif
    }

    public var isCounterpartReachable: Bool {
        #if canImport(WatchConnectivity)
        return connectivity?.isReachable ?? false
        #else
        return false
        #endif
    }

    /// À appeler une fois au lancement de l'app (iPhone et Watch).
    public func activate() {
        #if canImport(WatchConnectivity)
        guard let connectivity else { return }
        connectivity.delegate = self
        if connectivity.activationState != .activated {
            connectivity.activate()
        }
        #endif
    }

    // MARK: - SessionSyncing

    public func sendState(_ state: SessionState) {
        #if canImport(WatchConnectivity)
        guard let connectivity, connectivity.activationState == .activated else { return }
        let trimmed = SessionState(
            sessions: Array(state.sessions.prefix(transferLimit)),
            active: state.active,
            updatedAt: state.updatedAt
        )
        guard let data = SessionStorage.encode(trimmed) else { return }

        // Chemin rapide quand l'autre appareil est à l'écran.
        if connectivity.isReachable {
            connectivity.sendMessageData(data, replyHandler: nil) { _ in
                try? connectivity.updateApplicationContext(["state": data])
            }
        } else {
            try? connectivity.updateApplicationContext(["state": data])
        }
        #endif
    }

    // MARK: - Privé

    private func handle(data: Data?) {
        guard let data, let state = SessionStorage.decode(data) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.onRemoteState?(state)
        }
    }
}

#if canImport(WatchConnectivity)
extension WatchSyncService: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated, error == nil else { return }
        handle(data: session.receivedApplicationContext["state"] as? Data)
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        handle(data: applicationContext["state"] as? Data)
    }

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(data: userInfo["state"] as? Data)
    }

    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        handle(data: messageData)
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}

    public func sessionDidDeactivate(_ session: WCSession) {
        // Réactivation nécessaire après un changement de montre appairée.
        session.activate()
    }
    #endif
}
#endif
