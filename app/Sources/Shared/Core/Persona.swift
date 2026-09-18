import Foundation

/// Profil attribué à l'utilisateur d'après ses habitudes. Aucune base
/// scientifique, une certaine base statistique.
public struct Persona: Hashable, Sendable {
    public let title: String
    public let detail: String
    public let symbol: String
}

public enum PersonaEngine {

    /// Tranche horaire dominante.
    public enum Moment: String, CaseIterable, Sendable {
        case matin, midi, apresMidi, soir, nuit

        static func from(hour: Int) -> Moment {
            switch hour {
            case 5..<11: return .matin
            case 11..<14: return .midi
            case 14..<18: return .apresMidi
            case 18..<23: return .soir
            default: return .nuit
            }
        }

        var label: String {
            switch self {
            case .matin: return "du matin".wcLocalized
            case .midi: return "de la pause déjeuner".wcLocalized
            case .apresMidi: return "de l'après-midi".wcLocalized
            case .soir: return "du soir".wcLocalized
            case .nuit: return "de la nuit".wcLocalized
            }
        }
    }

    /// Rythme dominant.
    public enum Tempo: String, CaseIterable, Sendable {
        case eclair, regulier, contemplatif

        static func from(averageDuration: TimeInterval) -> Tempo {
            if averageDuration < 2 * 60 { return .eclair }
            if averageDuration > 8 * 60 { return .contemplatif }
            return .regulier
        }
    }

    public static func persona(
        sessions: [ToiletSession],
        calendar: Calendar = .current
    ) -> Persona {
        let finished = sessions.filter { $0.endedAt != nil }
        guard !finished.isEmpty else {
            return Persona(
                title: "Profil vierge".wcLocalized,
                detail: "Aucune visite enregistrée : votre légende reste à écrire.".wcLocalized,
                symbol: "person.fill.questionmark"
            )
        }

        let stats = StatsEngine.compute(sessions: finished, calendar: calendar)
        let moment = Moment.from(hour: stats.busiestHour ?? 9)
        let tempo = Tempo.from(averageDuration: stats.averageDuration)

        return Persona(
            title: title(moment: moment, tempo: tempo),
            detail: detail(moment: moment, tempo: tempo, stats: stats),
            symbol: symbol(tempo: tempo, moment: moment)
        )
    }

    // MARK: - Privé

    private static func title(moment: Moment, tempo: Tempo) -> String {
        let noun: String
        switch tempo {
        case .eclair: noun = "Le Sprinteur".wcLocalized
        case .regulier: noun = "L'Habitué".wcLocalized
        case .contemplatif: noun = "Le Philosophe".wcLocalized
        }

        if moment == .nuit {
            switch tempo {
            case .eclair: return "Le Fantôme nocturne".wcLocalized
            case .regulier: return "Le Veilleur".wcLocalized
            case .contemplatif: return "L'Ermite de la nuit".wcLocalized
            }
        }
        return "%@ %@".wcLocalized(noun, moment.label)
    }

    private static func detail(moment: Moment, tempo: Tempo, stats: Stats) -> String {
        let duration = WCFormat.duration(stats.averageDuration)
        let hour = stats.busiestHour.map { "\($0) h" } ?? "une heure indéterminée".wcLocalized

        switch tempo {
        case .eclair:
            return "Vous expédiez l'affaire en %@, surtout vers %@. Efficace, presque suspect.".wcLocalized(duration, hour)
        case .regulier:
            return "%@ en moyenne, avec une préférence marquée pour %@. Une horloge.".wcLocalized(duration, hour)
        case .contemplatif:
            return "%@ en moyenne : vous ne venez pas seulement pour la fonction, mais aussi pour la réflexion. Surtout vers %@.".wcLocalized(duration, hour)
        }
    }

    private static func symbol(tempo: Tempo, moment: Moment) -> String {
        if moment == .nuit { return "moon.stars.fill" }
        switch tempo {
        case .eclair: return "hare.fill"
        case .regulier: return "clock.fill"
        case .contemplatif: return "brain.head.profile"
        }
    }
}
