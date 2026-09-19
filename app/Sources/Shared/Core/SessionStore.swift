import Combine
import Foundation

/// Pont vers ActivityKit (implémenté côté iOS uniquement) afin que le store
/// reste compilable sur watchOS et dans l'extension de widgets.
@MainActor
public protocol LiveActivityCoordinating: AnyObject {
    func startActivity(for session: ToiletSession)
    func updateActivity(for session: ToiletSession)
    func endActivity(for session: ToiletSession)
}

/// Pont vers WatchConnectivity.
public protocol SessionSyncing: AnyObject {
    func sendState(_ state: SessionState)
}

/// Source de vérité de l'app : visite en cours + historique.
@MainActor
public final class SessionStore: ObservableObject {
    /// Instance partagée par l'app, ses App Intents et la Live Activity :
    /// tous s'exécutent dans le processus de l'app.
    public static let shared = SessionStore()

    /// Visites terminées, de la plus récente à la plus ancienne.
    @Published public private(set) var sessions: [ToiletSession] = []
    /// Visite en cours, le cas échéant.
    @Published public private(set) var active: ToiletSession?

    public weak var liveActivity: LiveActivityCoordinating?
    public weak var syncer: SessionSyncing?

    private let storage: SessionStorage
    private var updatedAt: Date

    public init(storage: SessionStorage = .shared) {
        self.storage = storage
        let state = storage.load()
        self.sessions = Self.sort(state.sessions)
        self.active = state.active
        self.updatedAt = state.updatedAt
    }

    // MARK: - Cycle de vie d'une visite

    /// Démarre une visite. Si une visite est déjà en cours, elle est clôturée
    /// d'abord pour éviter deux chronomètres concurrents.
    @discardableResult
    public func start(
        kind: SessionKind = .standard,
        place: Place = .home,
        source: SessionSource = .phone,
        at date: Date = Date()
    ) -> ToiletSession {
        if active != nil {
            stop(at: date)
        }
        let session = ToiletSession(startedAt: date, kind: kind, place: place, source: source)
        active = session
        persist()
        liveActivity?.startActivity(for: session)
        return session
    }

    /// Clôture la visite en cours et l'ajoute à l'historique.
    @discardableResult
    public func stop(comfort: Int? = nil, note: String? = nil, at date: Date = Date()) -> ToiletSession? {
        guard var session = active else { return nil }
        session.endedAt = max(date, session.startedAt)
        session.comfort = comfort
        session.note = note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        active = nil
        sessions = Self.sort(sessions + [session])
        persist()
        liveActivity?.endActivity(for: session)
        return session
    }

    /// Abandonne la visite en cours sans rien enregistrer.
    public func cancel() {
        guard let session = active else { return }
        active = nil
        persist()
        liveActivity?.endActivity(for: session)
    }

    /// Rejoue l'affichage de la visite en cours sans toucher aux données.
    /// Nécessaire quand un réglage change ce que la Live Activity montre —
    /// le mode serein, par exemple — alors qu'une visite est déjà lancée.
    public func refreshActivity() {
        guard let session = active else { return }
        liveActivity?.updateActivity(for: session)
    }

    public func updateActive(kind: SessionKind? = nil, place: Place? = nil) {
        guard var session = active else { return }
        if let kind { session.kind = kind }
        if let place { session.place = place }
        active = session
        persist()
        liveActivity?.updateActivity(for: session)
    }

    // MARK: - Historique

    public func delete(_ session: ToiletSession) {
        sessions.removeAll { $0.id == session.id }
        persist()
    }

    public func delete(at offsets: IndexSet, in list: [ToiletSession]) {
        let ids = offsets.compactMap { list.indices.contains($0) ? list[$0].id : nil }
        sessions.removeAll { ids.contains($0.id) }
        persist()
    }

    public func update(_ session: ToiletSession) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[index] = session
        sessions = Self.sort(sessions)
        persist()
    }

    /// Ajoute une visite passée saisie à la main.
    public func add(_ session: ToiletSession) {
        guard session.endedAt != nil else { return }
        sessions = Self.sort(sessions.filter { $0.id != session.id } + [session])
        persist()
    }

    public func removeAll() {
        sessions = []
        if let session = active {
            liveActivity?.endActivity(for: session)
        }
        active = nil
        persist()
    }

    // MARK: - Dérivés

    public var stats: Stats {
        StatsEngine.compute(sessions: sessions)
    }

    public var todayCount: Int {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.startedAt) }.count
    }

    public var lastSession: ToiletSession? { sessions.first }

    /// Historique groupé par jour, du jour le plus récent au plus ancien.
    public var groupedByDay: [(day: Date, sessions: [ToiletSession])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: sessions) { calendar.startOfDay(for: $0.startedAt) }
        return groups
            .map { (day: $0.key, sessions: Self.sort($0.value)) }
            .sorted { $0.day > $1.day }
    }

    public func exportCSV() -> String {
        var lines = ["debut,fin,duree_secondes,type,lieu,confort,bristol,effort,symptomes,appareil,note"]
        for session in sessions.reversed() {
            let start = ISO8601DateFormatter().string(from: session.startedAt)
            let end = session.endedAt.map { ISO8601DateFormatter().string(from: $0) } ?? ""
            let duration = session.finalDuration.map { String(Int($0.rounded())) } ?? ""
            let comfort = session.comfort.map(String.init) ?? ""
            let note = (session.note ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            let bristol = session.bristol.map { String($0.rawValue) } ?? ""
            let effort = session.effort.map(String.init) ?? ""
            let symptomes = session.symptomList.map(\.rawValue).joined(separator: " ")
            lines.append("\(start),\(end),\(duration),\(session.kind.rawValue),\(session.place.rawValue),\(comfort),\(bristol),\(effort),\(symptomes),\(session.source.rawValue),\"\(note)\"")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Synchronisation

    /// Applique un état reçu de l'autre appareil. Fusion par identifiant :
    /// une visite terminée l'emporte toujours sur la même visite en cours.
    public func apply(remote: SessionState) {
        let previous = active
        var merged: [UUID: ToiletSession] = [:]
        for session in sessions + remote.sessions {
            if let existing = merged[session.id] {
                merged[session.id] = existing.endedAt != nil ? existing : session
            } else {
                merged[session.id] = session
            }
        }

        if remote.updatedAt > updatedAt {
            active = remote.active
            updatedAt = remote.updatedAt
        }
        // Une visite clôturée à distance ne doit pas rester active localement.
        if let current = active, merged[current.id]?.endedAt != nil {
            active = nil
        }
        sessions = Self.sort(Array(merged.values).filter { $0.endedAt != nil })
        storage.save(SessionState(sessions: sessions, active: active, updatedAt: updatedAt))
        syncLiveActivity(previous: previous, finishedVersions: merged)
        WidgetRefresher.reload()
    }

    /// Recharge depuis le disque (ex. retour au premier plan après une action
    /// déclenchée par un widget).
    public func reload() {
        let state = storage.load()
        guard state.updatedAt > updatedAt else { return }
        let previous = active
        sessions = Self.sort(state.sessions)
        active = state.active
        updatedAt = state.updatedAt
        syncLiveActivity(previous: previous, finishedVersions: [:])
    }

    /// Aligne la Live Activity après une modification venue d'ailleurs (Watch,
    /// widget, Siri) : c'est ce qui la fait disparaître quand la visite est
    /// clôturée depuis la montre.
    private func syncLiveActivity(previous: ToiletSession?, finishedVersions: [UUID: ToiletSession]) {
        switch (previous, active) {
        case (nil, nil):
            break
        case (nil, .some(let started)):
            liveActivity?.startActivity(for: started)
        case (.some(let ended), nil):
            liveActivity?.endActivity(for: finishedVersions[ended.id] ?? ended)
        case (.some(let old), .some(let new)):
            if old.id != new.id {
                liveActivity?.endActivity(for: finishedVersions[old.id] ?? old)
                liveActivity?.startActivity(for: new)
            } else if old != new {
                liveActivity?.updateActivity(for: new)
            }
        }
    }

    public var snapshot: SessionState {
        SessionState(sessions: sessions, active: active, updatedAt: updatedAt)
    }

    // MARK: - Privé

    private func persist() {
        updatedAt = Date()
        let state = snapshot
        storage.save(state)
        syncer?.sendState(state)
        WidgetRefresher.reload()
    }

    private static func sort(_ sessions: [ToiletSession]) -> [ToiletSession] {
        sessions.sorted { $0.startedAt > $1.startedAt }
    }
}

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
