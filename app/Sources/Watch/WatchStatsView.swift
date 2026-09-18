import SwiftUI

struct WatchStatsView: View {
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        let stats = store.stats
        return List {
            row("Aujourd'hui", "\(stats.today)", "sun.max.fill")
            row("Par jour", stats.total > 0 ? String(format: "%.1f", stats.averagePerDay) : "—", "calendar")
            row("Moyenne", stats.total > 0 ? WCFormat.duration(stats.averageDuration) : "—", "timer")
            row("Série", stats.streakDays > 0 ? "\(stats.streakDays) j" : "—", "flame.fill")
            row("Total", "\(stats.total)", "number")
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
