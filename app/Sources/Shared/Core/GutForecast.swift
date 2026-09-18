import Foundation

/// Bulletin météo intestinal. Rigoureusement sans valeur prédictive, mais
/// calculé sur vos vraies données : la semaine écoulée, comparée à la
/// précédente.
public struct GutForecast: Hashable, Sendable {
    public let symbol: String
    public let title: String
    public let summary: String
    /// Pression fantaisiste, en hectopascals.
    public let pressure: Int
    public let wind: String
    public let visibility: String
    /// Risque d'averse, en pourcentage.
    public let showerRisk: Int

    public static let unknown = GutForecast(
        symbol: "questionmark.circle",
        title: "Bulletin indisponible",
        summary: "Pas encore assez de visites pour établir des prévisions. Revenez après quelques passages.",
        pressure: 1013,
        wind: "vent nul",
        visibility: "nulle",
        showerRisk: 0
    )
}

public enum ForecastEngine {

    /// Établit le bulletin à partir des sept derniers jours, comparés aux sept
    /// précédents.
    public static func forecast(
        sessions: [ToiletSession],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> GutForecast {
        let finished = sessions.filter { $0.endedAt != nil }
        guard finished.count >= 3 else { return .unknown }

        let weekAgo = now.addingTimeInterval(-7 * 86_400)
        let twoWeeksAgo = now.addingTimeInterval(-14 * 86_400)

        let recent = finished.filter { $0.startedAt > weekAgo && $0.startedAt <= now }
        let previous = finished.filter { $0.startedAt > twoWeeksAgo && $0.startedAt <= weekAgo }

        let recentAverage = average(of: recent)
        let previousAverage = average(of: previous)
        let comfort = averageComfort(of: recent.isEmpty ? finished : recent)
        let durationRatio = previousAverage > 0 ? recentAverage / previousAverage : 1
        let countRatio = previous.isEmpty ? 1 : Double(recent.count) / Double(previous.count)

        let condition = self.condition(averageDuration: recentAverage, comfort: comfort)

        return GutForecast(
            symbol: condition.symbol,
            title: condition.title,
            summary: condition.summary,
            pressure: pressure(comfort: comfort, durationRatio: durationRatio),
            wind: wind(countRatio: countRatio),
            visibility: visibility(comfort: comfort),
            showerRisk: showerRisk(countRatio: countRatio, comfort: comfort)
        )
    }

    // MARK: - Conditions

    private struct Condition {
        let symbol: String
        let title: String
        let summary: String
    }

    private static func condition(averageDuration: TimeInterval, comfort: Double?) -> Condition {
        let rating = comfort ?? 3

        if averageDuration > 12 * 60 || rating <= 2 {
            return Condition(
                symbol: "cloud.bolt.rain.fill",
                title: "Tempête",
                summary: "Conditions difficiles. Surélevez les pieds, respirez, et ne forcez pas : l'accalmie viendra."
            )
        }
        if averageDuration > 7 * 60 || rating < 3 {
            return Condition(
                symbol: "cloud.rain.fill",
                title: "Perturbé",
                summary: "Le passage s'annonce laborieux. Une marche et un verre d'eau amélioreraient le front."
            )
        }
        if rating >= 4 && averageDuration <= 5 * 60 {
            return Condition(
                symbol: "sun.max.fill",
                title: "Grand beau",
                summary: "Ciel dégagé sur l'ensemble du territoire. Profitez-en, ça ne durera pas."
            )
        }
        return Condition(
            symbol: "cloud.sun.fill",
            title: "Variable",
            summary: "Éclaircies alternant avec quelques passages nuageux. Rien d'alarmant."
        )
    }

    // MARK: - Indicateurs

    /// 1013 hPa de référence, corrigé par le confort et la tendance des durées.
    private static func pressure(comfort: Double?, durationRatio: Double) -> Int {
        let base = 1013.0
        let comfortEffect = ((comfort ?? 3) - 3) * 8
        let durationEffect = (min(max(durationRatio, 0.5), 2.0) - 1) * -12
        return Int(min(max(base + comfortEffect + durationEffect, 980), 1035).rounded())
    }

    private static func wind(countRatio: Double) -> String {
        switch countRatio {
        case ..<0.7: return "vent faible, tendance au calme"
        case ..<1.3: return "vent modéré de secteur sud"
        case ..<2.0: return "vent soutenu, rafales possibles"
        default: return "vent de tempête, avis aux navigateurs"
        }
    }

    private static func visibility(comfort: Double?) -> String {
        switch comfort ?? 3 {
        case ..<2.5: return "réduite, brouillard persistant"
        case ..<4: return "correcte, quelques bancs de brume"
        default: return "excellente, dix kilomètres"
        }
    }

    private static func showerRisk(countRatio: Double, comfort: Double?) -> Int {
        let fromCount = (min(max(countRatio, 0.4), 2.5) - 0.4) / 2.1 * 70
        let fromComfort = (5 - (comfort ?? 3)) * 6
        return Int(min(max(fromCount + fromComfort, 5), 95).rounded())
    }

    // MARK: - Prévision de la prochaine visite

    /// Prochaine visite « prévue », avec une fiabilité qu'il ne faut surtout pas
    /// prendre au sérieux.
    public static func nextVisit(
        sessions: [ToiletSession],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> (date: Date, reliability: Int)? {
        let finished = sessions.filter { $0.endedAt != nil }
        guard finished.count >= 3 else { return nil }

        var counts: [Int: Int] = [:]
        for session in finished {
            counts[calendar.component(.hour, from: session.startedAt), default: 0] += 1
        }
        guard let favourite = counts.sorted(by: { ($0.value, -$0.key) > ($1.value, -$1.key) }).first else {
            return nil
        }

        let share = Double(favourite.value) / Double(finished.count)
        let reliability = Int(min(max(share * 100, 3), 80).rounded())

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = favourite.key
        components.minute = 0
        guard let candidate = calendar.date(from: components) else { return nil }

        let date = candidate > now ? candidate : calendar.date(byAdding: .day, value: 1, to: candidate) ?? candidate
        return (date, reliability)
    }

    // MARK: - Privé

    private static func average(of sessions: [ToiletSession]) -> TimeInterval {
        let durations = sessions.compactMap(\.finalDuration)
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }

    private static func averageComfort(of sessions: [ToiletSession]) -> Double? {
        let ratings = sessions.compactMap(\.comfort)
        guard !ratings.isEmpty else { return nil }
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }
}
