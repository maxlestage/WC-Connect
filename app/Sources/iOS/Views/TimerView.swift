import SwiftUI

/// Écran principal : chronomètre de la visite en cours ou bouton de démarrage.
struct TimerView: View {
    @EnvironmentObject private var store: SessionStore

    @AppStorage("defaultKind", store: AppGroup.defaults) private var defaultKindRaw = SessionKind.standard.rawValue
    @AppStorage("defaultPlace", store: AppGroup.defaults) private var defaultPlaceRaw = Place.home.rawValue

    @State private var sessionToAnnotate: ToiletSession?

    private var kind: SessionKind {
        get { SessionKind(rawValue: defaultKindRaw) ?? .standard }
        nonmutating set { defaultKindRaw = newValue.rawValue }
    }

    private var place: Place {
        get { Place(rawValue: defaultPlaceRaw) ?? .home }
        nonmutating set { defaultPlaceRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    chronometer
                    controls
                    quickStats
                    if let last = store.lastSession, store.active == nil {
                        lastVisitCard(last)
                    }
                }
                .padding(20)
            }
            .background(backdrop)
            .navigationTitle("WC Connect")
            .sheet(item: $sessionToAnnotate) { session in
                EndVisitSheet(session: session) { updated in
                    store.update(updated)
                }
            }
        }
    }

    // MARK: - Chronomètre

    private var chronometer: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let session = store.active
            let elapsed = session?.duration(now: context.date) ?? 0
            let goal = session?.kind.goal ?? kind.goal
            let color = WCTheme.color(for: session?.kind ?? kind)

            ZStack {
                ProgressRing(progress: goal > 0 ? elapsed / goal : 0, color: color)
                VStack(spacing: 6) {
                    Text(session == nil ? "Prêt" : WCFormat.clock(elapsed))
                        .font(.system(size: session == nil ? 40 : 52, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text(subtitle(for: session))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if session != nil {
                        Label("Live Activity active", systemImage: "bolt.horizontal.circle.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(color)
                            .padding(.top, 4)
                    }
                }
            }
            .frame(height: 260)
            .animation(.default, value: store.active?.id)
        }
    }

    private func subtitle(for session: ToiletSession?) -> String {
        guard let session else { return "Aucune visite en cours" }
        return "\(session.kind.title) · \(session.place.title)"
    }

    // MARK: - Commandes

    @ViewBuilder
    private var controls: some View {
        if store.active == nil {
            VStack(spacing: 16) {
                Picker("Type", selection: Binding(get: { kind }, set: { kind = $0 })) {
                    ForEach(SessionKind.allCases, id: \.self) { value in
                        Text(value.title).tag(value)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Lieu", selection: Binding(get: { place }, set: { place = $0 })) {
                    ForEach(Place.allCases, id: \.self) { value in
                        Label(value.title, systemImage: value.symbol).tag(value)
                    }
                }
                .pickerStyle(.segmented)

                Button {
                    store.start(kind: kind, place: place, source: .phone)
                } label: {
                    Label("Démarrer la visite", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        } else {
            VStack(spacing: 12) {
                Button {
                    sessionToAnnotate = store.stop()
                } label: {
                    Label("Terminer", systemImage: "checkmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(role: .destructive) {
                    store.cancel()
                } label: {
                    Label("Annuler la visite", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Résumés

    private var quickStats: some View {
        let stats = store.stats
        return HStack(spacing: 12) {
            StatTile(value: "\(store.todayCount)", label: "Aujourd'hui", symbol: "sun.max.fill", color: WCTheme.warn)
            StatTile(
                value: stats.total > 0 ? WCFormat.duration(stats.averageDuration) : "—",
                label: "Durée moyenne",
                symbol: "timer"
            )
            StatTile(
                value: stats.streakDays > 0 ? "\(stats.streakDays) j" : "—",
                label: "Série en cours",
                symbol: "flame.fill",
                color: WCTheme.mint
            )
        }
    }

    private func lastVisitCard(_ session: ToiletSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dernière visite")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            SessionRow(session: session)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var backdrop: some View {
        LinearGradient(
            colors: [WCTheme.accent.opacity(store.active == nil ? 0.05 : 0.18), .clear],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
    }
}

#Preview {
    TimerView().environmentObject(SessionStore.preview)
}
