import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        TabView {
            TimerView()
                .tabItem { Label("Visite", systemImage: "toilet.fill") }

            RelaxView()
                .tabItem { Label("Détente", systemImage: "leaf.fill") }

            HistoryView()
                .tabItem { Label("Historique", systemImage: "list.bullet.rectangle") }

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("Réglages", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    RootView().environmentObject(SessionStore.preview)
}
