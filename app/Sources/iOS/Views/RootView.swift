import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: SessionStore
    @StateObject private var reminders = VisitReminders.shared

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
        // Les rappels sont branchés ici, et non sur les boutons : une visite
        // peut aussi démarrer depuis un widget, Siri ou la montre.
        .task {
            await reminders.rescheduleAbsence(sessions: store.sessions)
            await synchroniserTempsAssis()
        }
        .onChange(of: store.active?.id) { _, _ in
            Task { await synchroniserTempsAssis() }
        }
        .onChange(of: store.sessions.count) { _, _ in
            Task { await reminders.rescheduleAbsence(sessions: store.sessions) }
        }
    }

    /// Le rappel de temps assis suit la visite en cours, d'où qu'elle vienne.
    private func synchroniserTempsAssis() async {
        if let active = store.active {
            await reminders.scheduleSitting(startedAt: active.startedAt)
        } else {
            await reminders.cancelSitting()
        }
    }
}

#Preview {
    RootView().environmentObject(SessionStore.preview)
}
