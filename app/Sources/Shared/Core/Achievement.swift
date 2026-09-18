import Foundation

/// Hauts faits débloqués par l'historique. Totalement inutiles, donc
/// indispensables.
public enum Achievement: String, CaseIterable, Identifiable, Hashable, Sendable {
    case debut
    case eclair
    case marathonien
    case noctambule
    case avantLeCoq
    case globeTrotteur
    case horlogeSuisse
    case semaineParfaite
    case centurion
    case penseur
    case cinqEtoiles
    case double
    case journeeChargee
    case bureauDiscret

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .debut: return "Première fois"
        case .eclair: return "Éclair"
        case .marathonien: return "Marathonien"
        case .noctambule: return "Noctambule"
        case .avantLeCoq: return "Avant le coq"
        case .globeTrotteur: return "Globe-trotteur"
        case .horlogeSuisse: return "Horloge suisse"
        case .semaineParfaite: return "Semaine parfaite"
        case .centurion: return "Centurion"
        case .penseur: return "Le Penseur"
        case .cinqEtoiles: return "Cinq étoiles"
        case .double: return "Doublé"
        case .journeeChargee: return "Journée chargée"
        case .bureauDiscret: return "Discrétion au bureau"
        }
    }

    public var detail: String {
        switch self {
        case .debut: return "Enregistrer sa première visite."
        case .eclair: return "Une visite bouclée en moins de 45 secondes."
        case .marathonien: return "Une visite de plus de vingt minutes. Respect, et attention au périnée."
        case .noctambule: return "Une visite entre 2 h et 5 h du matin."
        case .avantLeCoq: return "Une visite avant 6 h."
        case .globeTrotteur: return "Les trois lieux — maison, travail, dehors — le même jour."
        case .horlogeSuisse: return "Trois jours de suite à la même heure, à un quart d'heure près."
        case .semaineParfaite: return "Sept jours consécutifs avec au moins une visite."
        case .centurion: return "Cent visites enregistrées."
        case .penseur: return "Plus d'un quart d'heure, et un confort de 5 sur 5."
        case .cinqEtoiles: return "Dix visites notées 5 sur 5."
        case .double: return "Deux visites en moins de trente minutes."
        case .journeeChargee: return "Cinq visites dans la même journée."
        case .bureauDiscret: return "Vingt visites au travail. Personne n'a rien remarqué."
        }
    }

    public var symbol: String {
        switch self {
        case .debut: return "sparkles"
        case .eclair: return "bolt.fill"
        case .marathonien: return "figure.run"
        case .noctambule: return "moon.stars.fill"
        case .avantLeCoq: return "sunrise.fill"
        case .globeTrotteur: return "airplane"
        case .horlogeSuisse: return "clock.badge.checkmark.fill"
        case .semaineParfaite: return "calendar.badge.checkmark"
        case .centurion: return "100.square.fill"
        case .penseur: return "brain.head.profile"
        case .cinqEtoiles: return "star.circle.fill"
        case .double: return "arrow.triangle.2.circlepath"
        case .journeeChargee: return "flame.fill"
        case .bureauDiscret: return "building.2.fill"
        }
    }
}

/// Évaluation des hauts faits sur l'historique. Calculs purs, donc testables.
public enum AchievementEngine {

    public static func isUnlocked(
        _ achievement: Achievement,
        sessions: [ToiletSession],
        calendar: Calendar = .current
    ) -> Bool {
        let finished = sessions.filter { $0.endedAt != nil }
        guard !finished.isEmpty else { return false }

        switch achievement {
        case .debut:
            return true

        case .eclair:
            return finished.contains { ($0.finalDuration ?? .infinity) < 45 }

        case .marathonien:
            return finished.contains { ($0.finalDuration ?? 0) > 20 * 60 }

        case .noctambule:
            return finished.contains {
                let hour = calendar.component(.hour, from: $0.startedAt)
                return hour >= 2 && hour < 5
            }

        case .avantLeCoq:
            return finished.contains { calendar.component(.hour, from: $0.startedAt) < 6 }

        case .globeTrotteur:
            let byDay = Dictionary(grouping: finished) { calendar.startOfDay(for: $0.startedAt) }
            return byDay.values.contains { Set($0.map(\.place)).count == Place.allCases.count }

        case .horlogeSuisse:
            return hasThreeDaysAtSameTime(finished, calendar: calendar)

        case .semaineParfaite:
            return StatsEngine.streak(sessions: finished, now: latestDate(finished), calendar: calendar) >= 7

        case .centurion:
            return finished.count >= 100

        case .penseur:
            return finished.contains { ($0.finalDuration ?? 0) > 15 * 60 && ($0.comfort ?? 0) == 5 }

        case .cinqEtoiles:
            return finished.filter { $0.comfort == 5 }.count >= 10

        case .double:
            let starts = finished.map(\.startedAt).sorted()
            return zip(starts, starts.dropFirst()).contains { $1.timeIntervalSince($0) < 30 * 60 }

        case .journeeChargee:
            let byDay = Dictionary(grouping: finished) { calendar.startOfDay(for: $0.startedAt) }
            return byDay.values.contains { $0.count >= 5 }

        case .bureauDiscret:
            return finished.filter { $0.place == .work }.count >= 20
        }
    }

    public static func unlocked(
        sessions: [ToiletSession],
        calendar: Calendar = .current
    ) -> [Achievement] {
        Achievement.allCases.filter { isUnlocked($0, sessions: sessions, calendar: calendar) }
    }

    /// Titre honorifique attribué selon le nombre de hauts faits.
    public static func rank(unlockedCount count: Int) -> String {
        switch count {
        case 0: return "Anonyme des toilettes"
        case 1...2: return "Apprenti"
        case 3...5: return "Habitué"
        case 6...8: return "Vétéran du trône"
        case 9...11: return "Maître du transit"
        default: return "Légende vivante"
        }
    }

    // MARK: - Privé

    private static func latestDate(_ sessions: [ToiletSession]) -> Date {
        sessions.map(\.startedAt).max() ?? Date()
    }

    /// Trois jours consécutifs comportant une visite à la même heure, à quinze
    /// minutes près.
    private static func hasThreeDaysAtSameTime(_ sessions: [ToiletSession], calendar: Calendar) -> Bool {
        let tolerance: TimeInterval = 15 * 60

        // Minutes depuis minuit, par jour.
        var minutesByDay: [Date: [Double]] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.startedAt)
            let minutes = session.startedAt.timeIntervalSince(day) / 60
            minutesByDay[day, default: []].append(minutes)
        }

        let days = minutesByDay.keys.sorted()
        for day in days {
            guard
                let next = calendar.date(byAdding: .day, value: 1, to: day),
                let third = calendar.date(byAdding: .day, value: 2, to: day),
                let first = minutesByDay[day],
                let second = minutesByDay[next],
                let last = minutesByDay[third]
            else { continue }

            for reference in first {
                let matchesSecond = second.contains { abs($0 - reference) * 60 <= tolerance }
                let matchesThird = last.contains { abs($0 - reference) * 60 <= tolerance }
                if matchesSecond && matchesThird { return true }
            }
        }
        return false
    }
}
