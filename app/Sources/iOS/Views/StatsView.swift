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
                    goalCard
                    ForecastCard(
                        forecast: ForecastEngine.forecast(sessions: store.sessions),
                        nextVisit: ForecastEngine.nextVisit(sessions: store.sessions),
                        persona: PersonaEngine.persona(sessions: store.sessions)
                    )
                    tiles
                    journalCard
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
            StatTile(value: "\(stats.total)", label: "Visites enregistrées".wcLocalized, symbol: "number")
            StatTile(
                value: stats.total > 0 ? String(format: "%.1f", stats.averagePerDay) : "—",
                label: "Visites par jour".wcLocalized,
                symbol: "calendar",
                color: WCTheme.mint
            )
            StatTile(
                value: stats.total > 0 ? WCFormat.duration(stats.averageDuration) : "—",
                label: "Durée moyenne".wcLocalized,
                symbol: "timer"
            )
            StatTile(
                value: stats.total > 0 ? WCFormat.duration(stats.longestDuration) : "—",
                label: "Visite la plus longue".wcLocalized,
                symbol: "tortoise.fill",
                color: WCTheme.warn
            )
            StatTile(
                value: stats.busiestHour.map { WCFormat.hourLabel($0) } ?? "—",
                label: "Créneau favori".wcLocalized,
                symbol: "clock.fill"
            )
            StatTile(
                value: stats.averageComfort.map { String(format: "%.1f/5", $0) } ?? "—",
                label: "Confort moyen".wcLocalized,
                symbol: "star.fill",
                color: WCTheme.warn
            )
        }
    }

    /// Objectif hebdomadaire : régularité et visites courtes.
    private var goalCard: some View {
        let progres = GoalEngine.progress(sessions: store.sessions, goal: WeeklyGoal.stored)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Objectif de la semaine", systemImage: "target")
                    .font(.headline)
                Spacer()
                if progres.isReached {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(WCTheme.mint)
                }
            }
            ProgressView(value: progres.regularity)
                .tint(progres.isReached ? WCTheme.mint : WCTheme.accent)
            Text(progres.summary)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// Journal : consistance et symptômes, quand ils ont été renseignés.
    @ViewBuilder
    private var journalCard: some View {
        let bristol = stats.byBristol
        let symptomes = stats.bySymptom

        if !bristol.isEmpty || !symptomes.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Label("Journal", systemImage: "list.clipboard.fill")
                    .font(.headline)

                if !bristol.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Consistance")
                            .font(.subheadline.weight(.semibold))
                        ForEach(Bristol.allCases) { type in
                            let compte = bristol[type] ?? 0
                            let total = max(bristol.values.reduce(0, +), 1)
                            if compte > 0 {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("\(type.title) · \(type.detail)")
                                            .font(.caption)
                                        Spacer()
                                        Text("\(compte)")
                                            .font(.caption.weight(.semibold))
                                            .monospacedDigit()
                                            .foregroundStyle(.secondary)
                                    }
                                    ProgressView(value: Double(compte) / Double(total))
                                        .tint(type.isNotable ? WCTheme.warn : WCTheme.accent)
                                }
                            }
                        }
                    }
                }

                if !symptomes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Symptômes notés")
                            .font(.subheadline.weight(.semibold))
                        ForEach(Symptom.allCases) { symptome in
                            let compte = symptomes[symptome] ?? 0
                            if compte > 0 {
                                HStack {
                                    Label(symptome.title, systemImage: symptome.symbol)
                                        .font(.caption)
                                        .foregroundStyle(symptome.needsAdvice ? WCTheme.warn : .primary)
                                    Spacer()
                                    Text("\(compte)")
                                        .font(.caption.weight(.semibold))
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                if let effort = stats.averageEffort {
                    Text("Effort moyen : %@/5".wcLocalized(String(format: "%.1f", effort)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if symptomes.keys.contains(where: \.needsAdvice) {
                    Text("Un symptôme noté justifie un avis médical. L'app ne diagnostique rien : montrez ce journal à un professionnel.")
                        .font(.caption2)
                        .foregroundStyle(WCTheme.warn)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
                .accessibilityValue("%@ visites".wcLocalized(String(bucket.count)))
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
                .accessibilityLabel("%@ heures".wcLocalized(String(bucket.hour)))
                .accessibilityValue("%@ visites".wcLocalized(String(bucket.count)))
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
