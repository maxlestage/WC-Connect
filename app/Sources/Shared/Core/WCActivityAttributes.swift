import Foundation

#if canImport(ActivityKit)
import ActivityKit

/// Données de la Live Activity « visite en cours » (écran verrouillé, Dynamic
/// Island et Smart Stack de l'Apple Watch).
public struct WCActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var startedAt: Date
        public var kind: SessionKind
        public var place: Place
        /// Objectif indicatif en secondes, pour la barre de progression.
        public var goal: TimeInterval

        public init(startedAt: Date, kind: SessionKind, place: Place, goal: TimeInterval) {
            self.startedAt = startedAt
            self.kind = kind
            self.place = place
            self.goal = goal
        }

        public init(session: ToiletSession) {
            self.init(
                startedAt: session.startedAt,
                kind: session.kind,
                place: session.place,
                goal: session.kind.goal
            )
        }

        /// Intervalle passé à `Text(timerInterval:)` pour un chronomètre animé
        /// sans réveiller l'app.
        public var timerRange: ClosedRange<Date> {
            let end = startedAt.addingTimeInterval(max(goal, 60))
            return startedAt...max(end, startedAt.addingTimeInterval(1))
        }
    }

    /// Identifiant de la visite, pour retrouver la Live Activity au relancement.
    public var sessionID: UUID

    public init(sessionID: UUID) {
        self.sessionID = sessionID
    }
}
#endif
