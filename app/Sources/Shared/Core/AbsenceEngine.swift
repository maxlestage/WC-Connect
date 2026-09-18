import Foundation

/// Suivi des jours sans visite.
///
/// Trois jours sans selles est le repère usuel de la constipation. L'app le
/// signale une fois, sans alarmisme, et renvoie vers un avis médical plutôt
/// que vers un remède maison.
public enum AbsenceEngine {

    /// Seuil par défaut, en jours.
    public static let defaultThresholdDays = 3

    /// Bornes proposées dans les réglages.
    public static let thresholdRange = 2...7

    /// L'alerte tombe en fin d'après-midi : ni au réveil, ni la nuit.
    public static let alertHour = 18

    /// Dernière visite terminée, à `now` au plus tard.
    public static func lastVisit(sessions: [ToiletSession], before now: Date = Date()) -> Date? {
        sessions.compactMap(\.endedAt).filter { $0 <= now }.max()
    }

    /// Nombre de jours entiers écoulés depuis la dernière visite, `nil` si
    /// l'historique est vide.
    public static func daysSinceLastVisit(
        sessions: [ToiletSession],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int? {
        guard let derniere = lastVisit(sessions: sessions, before: now) else { return nil }
        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: derniere),
            to: calendar.startOfDay(for: now)
        ).day
    }

    /// Date à laquelle prévenir, si elle est encore devant nous. `nil` s'il
    /// n'y a rien à programmer : pas d'historique, ou seuil déjà dépassé.
    public static func nextAlert(
        sessions: [ToiletSession],
        thresholdDays: Int = defaultThresholdDays,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Date? {
        guard let derniere = lastVisit(sessions: sessions, before: now) else { return nil }
        let jours = min(max(thresholdDays, thresholdRange.lowerBound), thresholdRange.upperBound)
        guard
            let jour = calendar.date(byAdding: .day, value: jours, to: calendar.startOfDay(for: derniere)),
            let date = calendar.date(bySettingHour: alertHour, minute: 0, second: 0, of: jour)
        else { return nil }
        return date > now ? date : nil
    }

    /// Phrase affichée quand le seuil est franchi.
    public static func summary(days: Int) -> String {
        "Rien depuis %@ jours. Au-delà de trois jours, un avis médical vaut mieux qu'un remède maison.".wcLocalized(String(days))
    }
}
