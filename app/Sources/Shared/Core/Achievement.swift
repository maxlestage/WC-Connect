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
    // Secrets : masqués dans l'interface tant qu'ils ne sont pas débloqués.
    case coupDeMinuit
    case reveillon
    case nombrePi
    case triple
    case jourSansFin

    public var id: String { rawValue }

    /// Un haut fait secret ne dévoile son intitulé qu'une fois obtenu.
    public var isSecret: Bool {
        switch self {
        case .coupDeMinuit, .reveillon, .nombrePi, .triple, .jourSansFin: return true
        default: return false
        }
    }

    public var title: String {
        switch self {
        case .debut: return "Première fois".wcLocalized
        case .eclair: return "Éclair".wcLocalized
        case .marathonien: return "Marathonien".wcLocalized
        case .noctambule: return "Noctambule".wcLocalized
        case .avantLeCoq: return "Avant le coq".wcLocalized
        case .globeTrotteur: return "Globe-trotteur".wcLocalized
        case .horlogeSuisse: return "Horloge suisse".wcLocalized
        case .semaineParfaite: return "Semaine parfaite".wcLocalized
        case .centurion: return "Centurion".wcLocalized
        case .penseur: return "Le Penseur".wcLocalized
        case .cinqEtoiles: return "Cinq étoiles".wcLocalized
        case .double: return "Doublé".wcLocalized
        case .journeeChargee: return "Journée chargée".wcLocalized
        case .bureauDiscret: return "Discrétion au bureau".wcLocalized
        case .coupDeMinuit: return "Le Coup de minuit".wcLocalized
        case .reveillon: return "Réveillon".wcLocalized
        case .nombrePi: return "3,14".wcLocalized
        case .triple: return "Triplé".wcLocalized
        case .jourSansFin: return "Jour sans fin".wcLocalized
        }
    }

    public var detail: String {
        switch self {
        case .debut: return "Enregistrer sa première visite.".wcLocalized
        case .eclair: return "Une visite bouclée en moins de 45 secondes.".wcLocalized
        case .marathonien: return "Une visite de plus de vingt minutes. Respect, et attention au périnée.".wcLocalized
        case .noctambule: return "Une visite entre 2 h et 5 h du matin.".wcLocalized
        case .avantLeCoq: return "Une visite avant 6 h.".wcLocalized
        case .globeTrotteur: return "Les trois lieux — maison, travail, dehors — le même jour.".wcLocalized
        case .horlogeSuisse: return "Trois jours de suite à la même heure, à un quart d'heure près.".wcLocalized
        case .semaineParfaite: return "Sept jours consécutifs avec au moins une visite.".wcLocalized
        case .centurion: return "Cent visites enregistrées.".wcLocalized
        case .penseur: return "Plus d'un quart d'heure, et un confort de 5 sur 5.".wcLocalized
        case .cinqEtoiles: return "Dix visites notées 5 sur 5.".wcLocalized
        case .double: return "Deux visites en moins de trente minutes.".wcLocalized
        case .journeeChargee: return "Cinq visites dans la même journée.".wcLocalized
        case .bureauDiscret: return "Vingt visites au travail. Personne n'a rien remarqué.".wcLocalized
        case .coupDeMinuit: return "Une visite dans les cinq premières minutes d'un jour nouveau.".wcLocalized
        case .reveillon: return "Une visite le 31 décembre ou le 1er janvier. Bonne année.".wcLocalized
        case .nombrePi: return "Une visite de 3 minutes et 14 secondes. Au hasard, évidemment.".wcLocalized
        case .triple: return "Trois visites en moins d'une heure. Tout va bien ?".wcLocalized
        case .jourSansFin: return "Deux visites de durée rigoureusement identique, à la seconde.".wcLocalized
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
        case .coupDeMinuit: return "clock.badge.exclamationmark.fill"
        case .reveillon: return "party.popper.fill"
        case .nombrePi: return "function"
        case .triple: return "3.circle.fill"
        case .jourSansFin: return "repeat.circle.fill"
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

        case .coupDeMinuit:
            return finished.contains {
                let heure = calendar.component(.hour, from: $0.startedAt)
                let minute = calendar.component(.minute, from: $0.startedAt)
                return heure == 0 && minute < 5
            }

        case .reveillon:
            return finished.contains {
                let jour = calendar.component(.day, from: $0.startedAt)
                let mois = calendar.component(.month, from: $0.startedAt)
                return (mois == 12 && jour == 31) || (mois == 1 && jour == 1)
            }

        case .nombrePi:
            return finished.contains { Int(($0.finalDuration ?? 0).rounded()) == 194 }

        case .triple:
            let debuts = finished.map(\.startedAt).sorted()
            guard debuts.count >= 3 else { return false }
            return (0...(debuts.count - 3)).contains { index in
                debuts[index + 2].timeIntervalSince(debuts[index]) < 3_600
            }

        case .jourSansFin:
            let durees = finished.compactMap { $0.finalDuration.map { Int($0.rounded()) } }
            return Set(durees).count < durees.count
        }
    }

    public static func unlocked(
        sessions: [ToiletSession],
        calendar: Calendar = .current
    ) -> [Achievement] {
        Achievement.allCases.filter { isUnlocked($0, sessions: sessions, calendar: calendar) }
    }

    /// Hauts faits gagnés entre deux états de l'historique, pour féliciter au
    /// bon moment.
    public static func newlyUnlocked(
        previous: [ToiletSession],
        current: [ToiletSession],
        calendar: Calendar = .current
    ) -> [Achievement] {
        let before = Set(unlocked(sessions: previous, calendar: calendar))
        return unlocked(sessions: current, calendar: calendar).filter { !before.contains($0) }
    }

    /// Titre honorifique attribué selon le nombre de hauts faits.
    public static func rank(unlockedCount count: Int) -> String {
        switch count {
        case 0: return "Anonyme des toilettes".wcLocalized
        case 1...2: return "Apprenti".wcLocalized
        case 3...5: return "Habitué".wcLocalized
        case 6...8: return "Vétéran du trône".wcLocalized
        case 9...11: return "Maître du transit".wcLocalized
        case 12...15: return "Légende vivante".wcLocalized
        default: return "Divinité des latrines".wcLocalized
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
