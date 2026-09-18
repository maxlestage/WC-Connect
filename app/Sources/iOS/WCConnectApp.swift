import AppIntents
import SwiftUI

@main
struct WCConnectApp: App {
    @StateObject private var store = SessionStore.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(WCTheme.accent)
                .task { configure() }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    // Une visite peut avoir été lancée depuis un widget,
                    // Siri ou la Watch pendant que l'app était en arrière-plan.
                    store.reload()
                }
        }
    }

    @MainActor
    private func configure() {
        store.liveActivity = LiveActivityController.shared
        LiveActivityController.shared.adopt(activeSession: store.active)
        store.attachWatchSync()
    }
}

/// Raccourcis proposés par Siri sans configuration de l'utilisateur.
struct WCShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartVisitIntent(),
            phrases: [
                "Je vais aux toilettes avec \(.applicationName)",
                "Démarre une visite \(.applicationName)",
                "Nouvelle visite \(.applicationName)"
            ],
            shortTitle: "Démarrer une visite",
            systemImageName: "toilet.fill"
        )
        AppShortcut(
            intent: StopVisitIntent(),
            phrases: [
                "J'ai fini avec \(.applicationName)",
                "Termine ma visite \(.applicationName)"
            ],
            shortTitle: "Terminer la visite",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
