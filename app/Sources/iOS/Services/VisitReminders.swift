import Foundation
import UserNotifications

/// Trois rappels utiles, programmés localement.
///
/// - **Régularité** : aller à heure fixe est la première recommandation contre
///   la constipation. L'heure proposée vient de votre propre historique.
/// - **Absence** : au-delà de quelques jours sans visite, l'app le signale une
///   fois et renvoie vers un avis médical.
/// - **Temps assis** : rester longtemps assis à pousser fatigue les veines.
///   Un rappel pendant la visite vaut mieux qu'un haut fait.
///
/// Rien ne sort de l'appareil : ce sont des notifications locales.
@MainActor
final class VisitReminders: ObservableObject {
    static let shared = VisitReminders()

    private enum Key {
        static let routineEnabled = "routineReminderEnabled"
        static let routineHour = "routineReminderHour"
        static let absenceEnabled = "absenceReminderEnabled"
        static let absenceDays = "absenceReminderDays"
        static let sittingEnabled = "sittingReminderEnabled"
        static let sittingMinutes = "sittingReminderMinutes"
    }

    private enum Prefix {
        static let routine = "wc-connect.routine"
        static let absence = "wc-connect.absence"
        static let sitting = "wc-connect.sitting"
    }

    /// Bornes proposées dans les réglages.
    static let sittingRange = 5...20

    private let center = UNUserNotificationCenter.current()

    @Published var routineEnabled: Bool {
        didSet {
            AppGroup.defaults.set(routineEnabled, forKey: Key.routineEnabled)
            Task { await rescheduleRoutine() }
        }
    }

    @Published var routineHour: Int {
        didSet {
            AppGroup.defaults.set(routineHour, forKey: Key.routineHour)
            Task { await rescheduleRoutine() }
        }
    }

    @Published var absenceEnabled: Bool {
        didSet { AppGroup.defaults.set(absenceEnabled, forKey: Key.absenceEnabled) }
    }

    @Published var absenceDays: Int {
        didSet { AppGroup.defaults.set(absenceDays, forKey: Key.absenceDays) }
    }

    @Published var sittingEnabled: Bool {
        didSet { AppGroup.defaults.set(sittingEnabled, forKey: Key.sittingEnabled) }
    }

    @Published var sittingMinutes: Int {
        didSet { AppGroup.defaults.set(sittingMinutes, forKey: Key.sittingMinutes) }
    }

    init() {
        let defaults = AppGroup.defaults
        routineEnabled = defaults.bool(forKey: Key.routineEnabled)
        routineHour = (defaults.object(forKey: Key.routineHour) as? Int) ?? RoutineSuggestion.fallbackHour
        absenceEnabled = defaults.bool(forKey: Key.absenceEnabled)
        absenceDays = (defaults.object(forKey: Key.absenceDays) as? Int) ?? AbsenceEngine.defaultThresholdDays
        sittingEnabled = defaults.bool(forKey: Key.sittingEnabled)
        sittingMinutes = (defaults.object(forKey: Key.sittingMinutes) as? Int) ?? 10
    }

    // MARK: - Autorisation

    /// Demande l'autorisation ; le système ne la demande qu'une fois, quel que
    /// soit le rappel qui l'appelle.
    private func authorized() async -> Bool {
        let etat = await center.notificationSettings().authorizationStatus
        switch etat {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        default:
            return false
        }
    }

    // MARK: - Régularité

    /// Active le rappel de régularité en proposant l'heure de l'historique.
    func enableRoutine(sessions: [ToiletSession]) async {
        guard await authorized() else {
            routineEnabled = false
            return
        }
        routineHour = RoutineSuggestion.hour(sessions: sessions)
        routineEnabled = true
    }

    private func rescheduleRoutine() async {
        center.removePendingNotificationRequests(withIdentifiers: [Prefix.routine])
        guard routineEnabled, await authorized() else { return }

        let contenu = UNMutableNotificationContent()
        contenu.title = "Le moment de votre visite".wcLocalized
        contenu.body = "Prendre le temps, sans pousser. Si rien ne vient, revenez plus tard.".wcLocalized
        contenu.sound = .default

        var composants = DateComponents()
        composants.hour = min(max(routineHour, 0), 23)
        composants.minute = 0

        try? await center.add(UNNotificationRequest(
            identifier: Prefix.routine,
            content: contenu,
            trigger: UNCalendarNotificationTrigger(dateMatching: composants, repeats: true)
        ))
    }

    // MARK: - Absence prolongée

    /// Reprogramme l'alerte d'absence d'après l'historique. À appeler à chaque
    /// changement : la date dépend de la dernière visite.
    func rescheduleAbsence(sessions: [ToiletSession], now: Date = Date()) async {
        center.removePendingNotificationRequests(withIdentifiers: [Prefix.absence])
        guard absenceEnabled, await authorized() else { return }
        guard let date = AbsenceEngine.nextAlert(
            sessions: sessions, thresholdDays: absenceDays, now: now
        ) else { return }

        let contenu = UNMutableNotificationContent()
        contenu.title = "Rien depuis %@ jours".wcLocalized(String(absenceDays))
        contenu.body = "Buvez, bougez, mangez des fibres. Si ça dure, un avis médical vaut mieux qu'un remède maison.".wcLocalized
        contenu.sound = .default

        let composants = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        try? await center.add(UNNotificationRequest(
            identifier: Prefix.absence,
            content: contenu,
            trigger: UNCalendarNotificationTrigger(dateMatching: composants, repeats: false)
        ))
    }

    /// Active l'alerte puis la programme.
    func enableAbsence(sessions: [ToiletSession]) async {
        guard await authorized() else {
            absenceEnabled = false
            return
        }
        absenceEnabled = true
        await rescheduleAbsence(sessions: sessions)
    }

    // MARK: - Temps assis

    /// Programme le rappel de la visite en cours. Sans effet si la visite est
    /// déjà plus longue que la limite : mieux vaut se taire que sonner aussitôt.
    func scheduleSitting(startedAt debut: Date, now: Date = Date()) async {
        await cancelSitting()
        guard sittingEnabled, await authorized() else { return }

        let limite = TimeInterval(min(max(sittingMinutes, Self.sittingRange.lowerBound), Self.sittingRange.upperBound) * 60)
        let restant = limite - now.timeIntervalSince(debut)
        guard restant > 1 else { return }

        let contenu = UNMutableNotificationContent()
        contenu.title = "%@ minutes, c'est assez".wcLocalized(String(sittingMinutes))
        contenu.body = "Changez d'appui, ou levez-vous si vous le pouvez. Rester assis fatigue les veines et met la peau sous pression.".wcLocalized
        contenu.sound = .default

        try? await center.add(UNNotificationRequest(
            identifier: Prefix.sitting,
            content: contenu,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: restant, repeats: false)
        ))
    }

    /// Annule le rappel : la visite est terminée, ou abandonnée.
    func cancelSitting() async {
        center.removePendingNotificationRequests(withIdentifiers: [Prefix.sitting])
        center.removeDeliveredNotifications(withIdentifiers: [Prefix.sitting])
    }

    /// Active la limite de temps, en demandant l'autorisation au besoin.
    func enableSitting() async {
        guard await authorized() else {
            sittingEnabled = false
            return
        }
        sittingEnabled = true
    }
}
