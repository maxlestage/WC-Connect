import Charts
import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: SessionStore

    private var stats: Stats { store.stats }
    private var hours: [HourBucket] { StatsEngine.hourBuckets(sessions: store.sessions) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    tiles
                    trophyLink
                    weekChart
                    hourChart
                    placeBreakdown
                }
                .padding(20)
            }
            .navigationTitle("Statistiques")
        }
    }

    // MARK: - Chiffres clés

    private var tiles: some View {
        LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 2), spacing: 12) {
            StatTile(value: "\(stats.total)", label: "Visites enregistrées", symbol: "number")
            StatTile(
                value: stats.total > 0 ? String(format: "%.1f", stats.averagePerDay) : "—",
                label: "Visites par jour",
                symbol: "calendar",
                color: WCTheme.mint
            )
            StatTile(
                value: stats.total > 0 ? WCFormat.duration(stats.averageDuration) : "—",
                label: "Durée moyenne",
                symbol: "timer"
            )
            StatTile(
                value: stats.total > 0 ? WCFormat.duration(stats.longestDuration) : "—",
                label: "Visite la plus longue",
                symbol: "tortoise.fill",
                color: WCTheme.warn
            )
            StatTile(
                value: stats.busiestHour.map { WCFormat.hourLabel($0) } ?? "—",
                label: "Créneau favori",
                symbol: "clock.fill"
            )
            StatTile(
                value: stats.averageComfort.map { String(format: "%.1f/5", $0) } ?? "—",
                label: "Confort moyen",
                symbol: "star.fill",
                color: WCTheme.warn
            )
        }
    }

    private var trophyLink: some View {
        NavigationLink {
            TrophyView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rosette")
                    .foregroundStyle(WCTheme.warn)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Palmarès")
                        .font(.body.weight(.semibold))
                    Text("Hauts faits, chiffres absurdes et certificat officiel.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Graphiques

    private var weekChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Visites des 7 derniers jours")
                .font(.headline)
            Chart(stats.week) { bucket in
                BarMark(
                    x: .value("Jour", bucket.date, unit: .day),
                    y: .value("Visites", bucket.count),
                    width: .fixed(22)
                )
                .cornerRadius(4)
                .foregroundStyle(Calendar.current.isDateInToday(bucket.date) ? WCTheme.accent : WCTheme.accent.opacity(0.45))
                .annotation(position: .top) {
                    if bucket.count > 0 {
                        Text("\(bucket.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityLabel(bucket.date.formatted(.dateTime.weekday(.wide)))
                .accessibilityValue("\(bucket.count) visites")
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3))
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .frame(height: 170)
        }
        .padding(16)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var hourChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Répartition sur la journée")
                .font(.headline)
            Text("Par créneaux de 3 heures")
                .font(.caption)
                .foregroundStyle(.secondary)
            Chart(hours) { bucket in
                BarMark(
                    x: .value("Créneau", "\(bucket.hour)h"),
                    y: .value("Visites", bucket.count)
                )
                .cornerRadius(4)
                .foregroundStyle(WCTheme.accentDeep.opacity(0.7))
                .accessibilityLabel("\(bucket.hour) heures")
                .accessibilityValue("\(bucket.count) visites")
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3))
            }
            .frame(height: 160)
        }
        .padding(16)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Répartition par lieu

    private var placeBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Par lieu")
                .font(.headline)
            ForEach(Place.allCases, id: \.self) { place in
                let count = stats.byPlace[place] ?? 0
                let share = stats.total > 0 ? Double(count) / Double(stats.total) : 0
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label(place.title, systemImage: place.symbol)
                            .font(.subheadline)
                        Spacer()
                        Text("\(count)")
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: share)
                        .tint(WCTheme.accent)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    StatsView().environmentObject(SessionStore.preview)
}
