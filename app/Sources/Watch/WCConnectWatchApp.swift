import SwiftUI

@main
struct WCConnectWatchApp: App {
    @StateObject private var store = SessionStore.shared

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(store)
                .tint(WCTheme.accent)
                .task {
                    store.attachWatchSync()
                }
        }
    }
}
