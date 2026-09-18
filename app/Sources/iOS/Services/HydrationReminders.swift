import Foundation
import UserNotifications

/// Rappels d'hydratation : des notifications locales, à heures régulières.
///
/// Boire régulièrement est le conseil le plus déterminant de la liste, et le
/// plus facile à oublier. Rien ne sort de l'appareil : ce sont des
/// notifications programmées localement.
@MainActor
final class HydrationReminders: ObservableObject {
    static let shared = HydrationReminders()

    private enum Key {
        static let enabled = "hydrationEnabled"
        static let count = "hydrationCount"
        static let startHour = "hydrationStartHour"
        static let endHour = "hydrationEndHour"
    }

    private let identifierPrefix = "wc-connect.hydration."
    private let center = UNUserNotificationCenter.current()

    @Published private(set) var authorization: UNAuthorizationStatus = .notDetermined

    @Published var isEnabled: Bool {
        didSet {
            AppGroup.defaults.set(isEnabled, forKey: Key.enabled)
            Task { await reschedule() }
        }
    }

    /// Nombre de rappels par jour, de 2 à 8.
    @Published var count: Int {
        didSet {
            AppGroup.defaults.set(count, forKey: Key.count)
            Task { await reschedule() }
        }
    }

    /// Plage horaire des rappels.
    @Published var startHour: Int {
        didSet {
            AppGroup.defaults.set(startHour, forKey: Key.startHour)
            Task { await reschedule() }
        }
    }

    @Published var endHour: Int {
        didSet {
            AppGroup.defaults.set(endHour, forKey: Key.endHour)
            Task { await reschedule() }
        }
    }

    init() {
        let defaults = AppGroup.defaults
        isEnabled = defaults.bool(forKey: Key.enabled)
        count = (defaults.object(forKey: Key.count) as? Int) ?? 4
        startHour = (defaults.object(forKey: Key.startHour) as? Int) ?? 9
        endHour = (defaults.object(forKey: Key.endHour) as? Int) ?? 20
    }

    func refreshAuthorization() async {
        authorization = await center.notificationSettings().authorizationStatus
    }

    /// Demande l'autorisation, puis programme si elle est accordée.
    func enable() async {
        do {
            let accorde = try await center.requestAuthorization(options: [.alert, .sound])
            await refreshAuthorization()
            isEnabled = accorde
        } catch {
            await refreshAuthorization()
            isEnabled = false
        }
    }

    /// Heures auxquelles les rappels tombent, réparties dans la plage.
    var hours: [Int] {
        HydrationSchedule.hours(count: count, startHour: startHour, endHour: endHour)
    }

    /// Reprogramme la série complète : on efface avant d'ajouter, pour ne pas
    /// accumuler des rappels fantômes à chaque changement de réglage.
    func reschedule() async {
        let anciens = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: anciens)

        guard isEnabled else { return }
        await refreshAuthorization()
        guard authorization == .authorized || authorization == .provisional else { return }

        let contenu = UNMutableNotificationContent()
        contenu.title = "Un verre d'eau ?".wcLocalized
        contenu.body = "L'eau est ce qui rend les fibres efficaces. Deux minutes, et c'est fait.".wcLocalized
        contenu.sound = .default

        for heure in hours {
            var composants = DateComponents()
            composants.hour = heure
            composants.minute = 0
            let requete = UNNotificationRequest(
                identifier: "\(identifierPrefix)\(heure)",
                content: contenu,
                trigger: UNCalendarNotificationTrigger(dateMatching: composants, repeats: true)
            )
            try? await center.add(requete)
        }
    }
}
