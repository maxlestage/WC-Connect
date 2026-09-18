import SwiftUI

/// Écran principal : chronomètre de la visite en cours ou bouton de démarrage.
struct TimerView: View {
    @EnvironmentObject private var store: SessionStore

    @AppStorage("defaultKind", store: AppGroup.defaults) private var defaultKindRaw = SessionKind.standard.rawValue
    @AppStorage("defaultPlace", store: AppGroup.defaults) private var defaultPlaceRaw = Place.home.rawValue
    @AppStorage("royalMode", store: AppGroup.defaults) private var royalMode = false

    @State private var sessionToAnnotate: ToiletSession?
    @State private var showBreathing = false
    @State private var showTips = false
    @State private var nudgeDismissed = false
    @State private var unlockedBadge: Achievement?

    @StateObject private var soundscapes = SoundscapePlayer.shared

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
                    helpNudge
                    quickStats
                    abstinence
                    if let last = store.lastSession, store.active == nil {
                        lastVisitCard(last)
                    }
                }
                .padding(20)
            }
            .background(backdrop)
            .overlay(alignment: .top) {
                if let unlockedBadge {
                    badgeBanner(unlockedBadge)
                }
            }
            .sensoryFeedback(.success, trigger: unlockedBadge)
            .navigationTitle("WC Connect")
            .sheet(item: $sessionToAnnotate) { session in
                EndVisitSheet(session: session) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showBreathing) {
                BreathingView(pattern: .belly)
            }
            .sheet(isPresented: $showTips) {
                NavigationStack {
                    TipsView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Fermer") { showTips = false }
                            }
                        }
                }
            }
            .onChange(of: store.active?.id) { _, _ in
                nudgeDismissed = false
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
                    if royalMode {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                            .foregroundStyle(WCTheme.warn)
                    }
                    Text(session == nil ? "Prêt".wcLocalized : WCFormat.clock(elapsed))
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
            // Appui long sur le chronomètre : couronnement.
            .onLongPressGesture(minimumDuration: 0.8) {
                royalMode.toggle()
            }
            .sensoryFeedback(royalMode ? .success : .impact, trigger: royalMode)
        }
    }

    private func subtitle(for session: ToiletSession?) -> String {
        guard let session else {
            return royalMode ? "Le trône vous attend, Majesté".wcLocalized : "Aucune visite en cours".wcLocalized
        }
        if royalMode {
            return "Sa Majesté siège · %@".wcLocalized(session.place.title)
        }
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

                coverButton
            }
        } else {
            VStack(spacing: 12) {
                Button {
                    let previous = store.sessions
                    sessionToAnnotate = store.stop()
                    celebrate(previous: previous)
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

    // MARK: - Haut fait débloqué

    /// Félicite au bon moment : un haut fait gagné à la visite précédente
    /// déclenche fanfare, vibration et bandeau.
    private func celebrate(previous: [ToiletSession]) {
        guard let badge = AchievementEngine.newlyUnlocked(
            previous: previous,
            current: store.sessions
        ).first else { return }

        unlockedBadge = badge
        soundscapes.playFanfare()
        Task {
            try? await Task.sleep(for: .seconds(5))
            if unlockedBadge == badge {
                unlockedBadge = nil
            }
        }
    }

    private func badgeBanner(_ badge: Achievement) -> some View {
        HStack(spacing: 12) {
            Image(systemName: badge.symbol)
                .font(.title3)
                .foregroundStyle(WCTheme.warn)
            VStack(alignment: .leading, spacing: 2) {
                Text("Haut fait débloqué")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(badge.title)
                    .font(.subheadline.weight(.bold))
            }
            Spacer(minLength: 0)
            Image(systemName: "xmark")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(WCTheme.warn.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .shadow(radius: 12, y: 6)
        .onTapGesture { unlockedBadge = nil }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(duration: 0.4), value: unlockedBadge)
    }

    // MARK: - Coup de pouce

    /// Au bout de quelques minutes, l'app propose de souffler plutôt que de
    /// pousser. Le seuil reste en deçà des cinq minutes conseillées pour se
    /// relever.
    private func nudgeThreshold(for kind: SessionKind) -> TimeInterval {
        min(kind.goal, 4 * 60)
    }

    @ViewBuilder
    private var helpNudge: some View {
        if let session = store.active, !nudgeDismissed {
            TimelineView(.periodic(from: .now, by: 5)) { context in
                if session.duration(now: context.date) >= nudgeThreshold(for: session.kind) {
                    nudgeCard(seed: session.id.hashValue)
                }
            }
        }
    }

    private func nudgeCard(seed: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(WCTheme.warn)
                Text("Ça coince ?")
                    .font(.headline)
                Spacer()
                Button {
                    nudgeDismissed = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Masquer les conseils")
            }

            ForEach(TipLibrary.suggestions(seed: seed)) { tip in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: tip.category.symbol)
                        .font(.caption)
                        .foregroundStyle(WCTheme.accent)
                        .frame(width: 16)
                    Text(tip.title)
                        .font(.subheadline)
                }
            }

            HStack(spacing: 10) {
                Button {
                    showBreathing = true
                } label: {
                    Label("Respirer", systemImage: "wind")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    soundscapes.toggle(.rain)
                } label: {
                    Label(
                        soundscapes.current == .rain ? "Couper".wcLocalized : "Ambiance".wcLocalized,
                        systemImage: soundscapes.current == .rain ? "pause.fill" : "cloud.rain.fill"
                    )
                    .font(.subheadline)
                }
                .buttonStyle(.bordered)

                Button {
                    showTips = true
                } label: {
                    Label("Conseils", systemImage: "list.bullet")
                        .font(.subheadline)
                        .labelStyle(.iconOnly)
                        .padding(.horizontal, 4)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Tous les conseils")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WCTheme.warn.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    /// Couverture sonore : une réunion de bureau, à plein volume, en un geste.
    private var coverButton: some View {
        Button {
            if soundscapes.current == .meeting {
                soundscapes.stop()
            } else {
                soundscapes.volume = 1
                soundscapes.play(.meeting)
            }
        } label: {
            Label(
                soundscapes.current == .meeting ? "Couper la couverture" : "Couverture sonore",
                systemImage: soundscapes.current == .meeting ? "speaker.slash.fill" : "person.3.fill"
            )
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(WCTheme.mint)
    }

    /// Temps écoulé depuis la dernière visite, commenté.
    @ViewBuilder
    private var abstinence: some View {
        if store.active == nil, let last = store.lastSession, let fin = last.endedAt {
            Text(AbsurdStats.abstinence(Date().timeIntervalSince(fin)))
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Résumés

    private var quickStats: some View {
        let stats = store.stats
        return HStack(spacing: 12) {
            StatTile(value: "\(store.todayCount)", label: "Aujourd'hui".wcLocalized, symbol: "sun.max.fill", color: WCTheme.warn)
            StatTile(
                value: stats.total > 0 ? WCFormat.duration(stats.averageDuration) : "—",
                label: "Durée moyenne".wcLocalized,
                symbol: "timer"
            )
            StatTile(
                value: stats.streakDays > 0 ? "\(stats.streakDays) j" : "—",
                label: "Série en cours".wcLocalized,
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
