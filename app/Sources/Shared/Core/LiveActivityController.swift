import Foundation

#if canImport(ActivityKit) && os(iOS)
import ActivityKit

/// Pilote la Live Activity « visite en cours » : écran verrouillé, Dynamic
/// Island et Smart Stack de l'Apple Watch (relayé automatiquement par iOS).
@MainActor
public final class LiveActivityController: LiveActivityCoordinating {
    public static let shared = LiveActivityController()

    private var activity: Activity<WCActivityAttributes>?

    /// Durée au bout de laquelle iOS considère l'activité comme périmée.
    private let staleAfter: TimeInterval = 60 * 60

    public init() {}

    /// L'utilisateur peut refuser les Live Activities dans Réglages.
    public var isAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    public func startActivity(for session: ToiletSession) {
        guard isAvailable else { return }
        endAllActivities()

        let content = ActivityContent(
            state: WCActivityAttributes.ContentState(session: session),
            staleDate: session.startedAt.addingTimeInterval(staleAfter)
        )
        do {
            activity = try Activity.request(
                attributes: WCActivityAttributes(sessionID: session.id),
                content: content,
                pushType: nil
            )
        } catch {
            // Une Live Activity refusée ne doit jamais empêcher le suivi.
            activity = nil
        }
    }

    public func updateActivity(for session: ToiletSession) {
        guard let activity else {
            startActivity(for: session)
            return
        }
        let content = ActivityContent(
            state: WCActivityAttributes.ContentState(session: session),
            staleDate: session.startedAt.addingTimeInterval(staleAfter)
        )
        Task { await activity.update(content) }
    }

    public func endActivity(for session: ToiletSession) {
        let content = ActivityContent(
            state: WCActivityAttributes.ContentState(session: session),
            staleDate: nil
        )
        let ending = activity
        activity = nil
        Task {
            await ending?.end(content, dismissalPolicy: .after(Date().addingTimeInterval(10)))
            // Filet de sécurité : une activité orpheline (app tuée puis
            // relancée) n'est plus référencée mais reste affichée.
            for orphan in Activity<WCActivityAttributes>.activities where orphan.id != ending?.id {
                await orphan.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    /// Reprend le suivi de l'activité existante au lancement de l'app, et
    /// aligne l'affichage sur la visite réellement en cours.
    public func adopt(activeSession: ToiletSession?) {
        let existing = Activity<WCActivityAttributes>.activities
        guard let activeSession else {
            endAllActivities()
            return
        }
        if let match = existing.first(where: { $0.attributes.sessionID == activeSession.id }) {
            activity = match
            updateActivity(for: activeSession)
        } else {
            startActivity(for: activeSession)
        }
    }

    private func endAllActivities() {
        let all = Activity<WCActivityAttributes>.activities
        activity = nil
        guard !all.isEmpty else { return }
        Task {
            for item in all {
                await item.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
#endif
