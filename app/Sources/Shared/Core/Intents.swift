import Foundation

// Les intents pilotent la Live Activity : ils ne concernent que iOS.
#if canImport(AppIntents) && os(iOS)
import AppIntents

// MARK: - Énumérations exposées à Siri et aux raccourcis

extension Place: AppEnum {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Lieu")
    }

    public static var caseDisplayRepresentations: [Place: DisplayRepresentation] {
        [
            .home: DisplayRepresentation(title: "Maison"),
            .work: DisplayRepresentation(title: "Travail"),
            .outside: DisplayRepresentation(title: "Dehors")
        ]
    }
}

extension SessionKind: AppEnum {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Type de visite")
    }

    public static var caseDisplayRepresentations: [SessionKind: DisplayRepresentation] {
        [
            .quick: DisplayRepresentation(title: "Express"),
            .standard: DisplayRepresentation(title: "Standard"),
            .long: DisplayRepresentation(title: "Longue")
        ]
    }
}

// MARK: - Intents

/// « Dis Siri, je vais aux toilettes. »
///
/// `LiveActivityIntent` garantit une exécution dans le processus de l'app :
/// c'est ce qui permet de démarrer la Live Activity depuis un widget, un
/// raccourci ou le bouton Action.
public struct StartVisitIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Démarrer une visite"

    public static var description = IntentDescription("Lance le chronomètre WC Connect et affiche la Live Activity.")

    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Type", default: SessionKind.standard)
    public var kind: SessionKind

    @Parameter(title: "Lieu", default: Place.home)
    public var place: Place

    public init() {}

    public init(kind: SessionKind, place: Place) {
        self.kind = kind
        self.place = place
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = SessionStore.shared
        store.reload()
        #if canImport(ActivityKit) && os(iOS)
        store.liveActivity = LiveActivityController.shared
        #endif
        store.start(kind: kind, place: place, source: .widget)
        return .result(dialog: "Chronomètre lancé. Bonne visite !")
    }
}

/// Clôture la visite en cours.
public struct StopVisitIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Terminer la visite"

    public static var description = IntentDescription("Arrête le chronomètre et enregistre la visite dans l'historique.")

    public static var openAppWhenRun: Bool = false

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = SessionStore.shared
        store.reload()
        #if canImport(ActivityKit) && os(iOS)
        store.liveActivity = LiveActivityController.shared
        #endif
        guard let session = store.stop() else {
            return .result(dialog: "Aucune visite en cours.")
        }
        let duration = WCFormat.duration(session.finalDuration ?? 0)
        return .result(dialog: "Visite enregistrée : \(duration).")
    }
}

/// Bascule démarrer/terminer, pratique pour un seul bouton de widget.
public struct ToggleVisitIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Démarrer ou terminer une visite"

    public static var description = IntentDescription("Lance le chronomètre s'il est à l'arrêt, l'arrête sinon.")

    public static var openAppWhenRun: Bool = false

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = SessionStore.shared
        store.reload()
        #if canImport(ActivityKit) && os(iOS)
        store.liveActivity = LiveActivityController.shared
        #endif
        if let session = store.stop() {
            return .result(dialog: "Visite enregistrée : \(WCFormat.duration(session.finalDuration ?? 0)).")
        }
        store.start(source: .widget)
        return .result(dialog: "Chronomètre lancé.")
    }
}

/// Enregistre une visite déjà terminée (durée indicative), sans chronomètre.
public struct LogVisitIntent: AppIntent {
    public static var title: LocalizedStringResource = "Noter une visite"

    public static var description = IntentDescription("Ajoute une visite à l'historique sans lancer le chronomètre.")

    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Durée en minutes", default: 4, inclusiveRange: (1, 60))
    public var minutes: Int

    @Parameter(title: "Lieu", default: Place.home)
    public var place: Place

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = SessionStore.shared
        store.reload()
        let end = Date()
        let session = ToiletSession(
            startedAt: end.addingTimeInterval(-Double(minutes) * 60),
            endedAt: end,
            kind: minutes <= 2 ? .quick : (minutes >= 10 ? .long : .standard),
            place: place,
            source: .widget
        )
        store.add(session)
        return .result(dialog: "Visite de \(minutes) min enregistrée.")
    }
}
#endif
