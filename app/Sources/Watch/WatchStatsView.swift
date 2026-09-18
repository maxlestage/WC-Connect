import SwiftUI

struct WatchStatsView: View {
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        let stats = store.stats
        let persona = PersonaEngine.persona(sessions: store.sessions)
        return List {
            Section {
                VStack(alignment: .leading, spacing: 2) {
                    Text(persona.title)
                        .font(.caption.weight(.semibold))
                    Text(AchievementEngine.rank(
                        unlockedCount: AchievementEngine.unlocked(sessions: store.sessions).count
                    ))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
            row("Aujourd'hui".wcLocalized, "\(stats.today)", "sun.max.fill")
            row("Par jour".wcLocalized, stats.total > 0 ? String(format: "%.1f", stats.averagePerDay) : "—", "calendar")
            row("Moyenne".wcLocalized, stats.total > 0 ? WCFormat.duration(stats.averageDuration) : "—", "timer")
            row("Série".wcLocalized, stats.streakDays > 0 ? "\(stats.streakDays) j" : "—", "flame.fill")
            row("Total".wcLocalized, "\(stats.total)", "number")
        }
        .navigationTitle("Stats")
    }

    private func row(_ title: String, _ value: String, _ symbol: String) -> some View {
        HStack {
            Label(title, systemImage: symbol)
                .font(.caption)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
