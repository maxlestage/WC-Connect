import Foundation

/// Bilan des dernières semaines, destiné à une consultation.
///
/// Un CSV se lit mal en cabinet. Ce bilan tient sur une page : fréquence,
/// jours sans visite, consistance, symptômes. Il ne conclut rien — c'est au
/// professionnel de le faire.
public struct MedicalReport: Hashable, Sendable {
    public let from: Date
    public let to: Date
    public let daysCovered: Int
    public let visits: Int
    public let daysWithVisit: Int
    /// Plus longue série de jours consécutifs sans visite sur la période.
    public let longestGapDays: Int
    public let averageDuration: TimeInterval
    public let byBristol: [Bristol: Int]
    public let bySymptom: [Symptom: Int]
    public let averageEffort: Double?

    public init(
        from: Date,
        to: Date,
        daysCovered: Int,
        visits: Int,
        daysWithVisit: Int,
        longestGapDays: Int,
        averageDuration: TimeInterval,
        byBristol: [Bristol: Int],
        bySymptom: [Symptom: Int],
        averageEffort: Double?
    ) {
        self.from = from
        self.to = to
        self.daysCovered = daysCovered
        self.visits = visits
        self.daysWithVisit = daysWithVisit
        self.longestGapDays = longestGapDays
        self.averageDuration = averageDuration
        self.byBristol = byBristol
        self.bySymptom = bySymptom
        self.averageEffort = averageEffort
    }

    public var isEmpty: Bool { visits == 0 }

    /// Visites par semaine, sur la période couverte.
    public var visitsPerWeek: Double {
        guard daysCovered > 0 else { return 0 }
        return Double(visits) / Double(daysCovered) * 7
    }

    /// Symptômes notés qui justifient un avis médical.
    public var notableSymptoms: [Symptom] {
        Symptom.allCases.filter { $0.needsAdvice && (bySymptom[$0] ?? 0) > 0 }
    }

    /// Répartition de la consistance par tendance, pour un résumé en une ligne.
    public func count(of tendency: Bristol.Tendency) -> Int {
        byBristol.reduce(0) { total, paire in
            paire.key.tendency == tendency ? total + paire.value : total
        }
    }
}

public enum MedicalReportEngine {

    /// Fenêtre par défaut : un mois, la durée qu'un praticien demande.
    public static let windowDays = 30

    public static func build(
        sessions: [ToiletSession],
        days: Int = windowDays,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> MedicalReport {
        let fenetre = max(1, days)
        let finDeJournee = calendar.startOfDay(for: now)
        let debut = calendar.date(byAdding: .day, value: -(fenetre - 1), to: finDeJournee) ?? finDeJournee

        let retenues = sessions.filter {
            $0.endedAt != nil && $0.startedAt >= debut && $0.startedAt <= now
        }

        var byBristol: [Bristol: Int] = [:]
        var bySymptom: [Symptom: Int] = [:]
        var effortTotal = 0
        var effortCompte = 0
        for visite in retenues {
            if let bristol = visite.bristol { byBristol[bristol, default: 0] += 1 }
            for symptome in visite.symptomList { bySymptom[symptome, default: 0] += 1 }
            if let effort = visite.effort {
                effortTotal += effort
                effortCompte += 1
            }
        }

        let durees = retenues.compactMap(\.finalDuration)
        let jours = Set(retenues.map { calendar.startOfDay(for: $0.startedAt) })

        return MedicalReport(
            from: debut,
            to: now,
            daysCovered: fenetre,
            visits: retenues.count,
            daysWithVisit: jours.count,
            longestGapDays: longestGap(days: jours, from: debut, to: finDeJournee, calendar: calendar),
            averageDuration: durees.isEmpty ? 0 : durees.reduce(0, +) / Double(durees.count),
            byBristol: byBristol,
            bySymptom: bySymptom,
            averageEffort: effortCompte > 0 ? Double(effortTotal) / Double(effortCompte) : nil
        )
    }

    /// Plus longue suite de jours consécutifs sans visite dans la fenêtre,
    /// bornes comprises : un trou avant la première visite compte autant qu'un
    /// trou au milieu. Parcours jour par jour — la fenêtre est courte, et le
    /// calcul reste lisible.
    private static func longestGap(
        days jours: Set<Date>,
        from debut: Date,
        to fin: Date,
        calendar: Calendar
    ) -> Int {
        var maximum = 0
        var courant = 0
        var jour = debut

        while jour <= fin {
            if jours.contains(jour) {
                courant = 0
            } else {
                courant += 1
                maximum = max(maximum, courant)
            }
            guard let suivant = calendar.date(byAdding: .day, value: 1, to: jour) else { break }
            // Un changement d'heure peut décaler l'instant : on recale sur minuit.
            jour = calendar.startOfDay(for: suivant)
        }

        return maximum
    }
}
