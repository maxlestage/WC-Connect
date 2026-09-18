import Foundation

/// Objectif hebdomadaire, volontairement modeste : de la régularité et des
/// visites qui ne s'éternisent pas.
public struct WeeklyGoal: Codable, Hashable, Sendable {
    /// Nombre de jours avec au moins une visite, sur sept.
    public var activeDays: Int
    /// Durée moyenne à ne pas dépasser.
    public var maxAverageDuration: TimeInterval

    public init(activeDays: Int = 5, maxAverageDuration: TimeInterval = 6 * 60) {
        self.activeDays = min(max(activeDays, 1), 7)
        self.maxAverageDuration = max(60, maxAverageDuration)
    }

    public static let `default` = WeeklyGoal()

    private static let key = "weeklyGoal"

    /// Objectif enregistré dans l'espace partagé, ou celui par défaut.
    public static var stored: WeeklyGoal {
        get {
            guard
                let data = AppGroup.defaults.data(forKey: key),
                let goal = try? JSONDecoder().decode(WeeklyGoal.self, from: data)
            else { return .default }
            return goal
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            AppGroup.defaults.set(data, forKey: key)
        }
    }
}

/// Avancement sur les sept derniers jours.
public struct GoalProgress: Hashable, Sendable {
    public let daysWithVisit: Int
    public let targetDays: Int
    public let averageDuration: TimeInterval
    public let maxAverageDuration: TimeInterval

    /// Part de l'objectif de régularité atteinte, de 0 à 1.
    public var regularity: Double {
        guard targetDays > 0 else { return 1 }
        return min(Double(daysWithVisit) / Double(targetDays), 1)
    }

    public var isRegular: Bool { daysWithVisit >= targetDays }

    /// Vrai si la durée moyenne tient dans l'objectif, ou si rien n'est encore
    /// mesurable.
    public var isBrief: Bool {
        averageDuration == 0 || averageDuration <= maxAverageDuration
    }

    public var isReached: Bool { isRegular && isBrief }

    public var summary: String {
        if isReached {
            return "Objectif tenu : %@ jours sur %@, et des visites courtes.".wcLocalized(
                String(daysWithVisit), String(targetDays)
            )
        }
        if !isRegular {
            return "%@ jours sur %@ cette semaine. Continuez.".wcLocalized(
                String(daysWithVisit), String(targetDays)
            )
        }
        return "Régularité tenue, mais les visites s'allongent : %@ en moyenne.".wcLocalized(
            WCFormat.duration(averageDuration)
        )
    }
}

public enum GoalEngine {

    public static func progress(
        sessions: [ToiletSession],
        goal: WeeklyGoal = .default,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> GoalProgress {
        let debut = now.addingTimeInterval(-7 * 86_400)
        let recentes = sessions.filter { $0.endedAt != nil && $0.startedAt > debut && $0.startedAt <= now }

        let jours = Set(recentes.map { calendar.startOfDay(for: $0.startedAt) })
        let durees = recentes.compactMap(\.finalDuration)
        let moyenne = durees.isEmpty ? 0 : durees.reduce(0, +) / Double(durees.count)

        return GoalProgress(
            daysWithVisit: jours.count,
            targetDays: goal.activeDays,
            averageDuration: moyenne,
            maxAverageDuration: goal.maxAverageDuration
        )
    }
}
