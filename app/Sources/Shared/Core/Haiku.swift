import Foundation

/// Haïku de visite : trois vers choisis d'après la durée, l'heure et le lieu.
///
/// Déterministe pour une visite donnée — le même passage donne toujours le même
/// poème, ce qui est la moindre des choses pour une œuvre.
public struct Haiku: Hashable, Sendable {
    public let first: String
    public let second: String
    public let third: String

    public var lines: [String] { [first, second, third] }
    public var text: String { lines.joined(separator: "\n") }
}

public enum HaikuEngine {

    /// Premiers vers : le décor.
    private static let openings = [
        "Le carrelage froid",
        "La porte se referme",
        "Un souffle retenu",
        "Lumière blafarde",
        "Le silence s'installe",
        "Loin du bruit du monde"
    ]

    /// Deuxièmes vers, choisis selon la durée : c'est là que vit la donnée.
    private static let middles: [SessionKind: [String]] = [
        .quick: [
            "l'affaire est réglée en un souffle",
            "le devoir accompli sans attendre",
            "une parenthèse à peine ouverte"
        ],
        .standard: [
            "le temps s'étire paisiblement",
            "les minutes coulent sans hâte",
            "un moment volé à la journée"
        ],
        .long: [
            "le temps semble avoir renoncé",
            "les civilisations s'effondrent",
            "on médite sur le sens des choses"
        ]
    ]

    /// Troisièmes vers : la chute, selon le moment de la journée.
    private static let closings: [PersonaEngine.Moment: [String]] = [
        .matin: ["la journée peut commencer", "le café attendra", "l'aube est complice"],
        .midi: ["le déjeuner refroidit", "la pause s'achève", "midi sonne ailleurs"],
        .apresMidi: ["le travail patiente", "l'après-midi s'allonge", "personne n'a remarqué"],
        .soir: ["la nuit tombe dehors", "le canapé appelle", "le jour se referme"],
        .nuit: ["les étoiles témoignent", "nul ne saura jamais", "la lune est discrète"]
    ]

    /// Compose le haïku d'une visite terminée.
    public static func haiku(for session: ToiletSession, calendar: Calendar = .current) -> Haiku {
        let graine = seed(for: session)
        let heure = calendar.component(.hour, from: session.startedAt)
        let moment = PersonaEngine.Moment.from(hour: heure)

        let premiers = openings
        let deuxiemes = middles[session.kind] ?? middles[.standard] ?? []
        let troisiemes = closings[moment] ?? closings[.matin] ?? []

        return Haiku(
            first: choix(premiers, graine: graine).wcLocalized,
            second: choix(deuxiemes, graine: graine / 7 + 1).wcLocalized,
            third: choix(troisiemes, graine: graine / 13 + 2).wcLocalized
        )
    }

    /// Toutes les combinaisons possibles, pour les tests et l'inventaire.
    public static var verseCount: Int {
        openings.count + middles.values.reduce(0) { $0 + $1.count } + closings.values.reduce(0) { $0 + $1.count }
    }

    // MARK: - Privé

    /// Graine stable : l'identifiant de la visite, pas l'horloge.
    private static func seed(for session: ToiletSession) -> Int {
        var total = 0
        for octet in session.id.uuidString.utf8 {
            total = (total + Int(octet) * 31) % 1_000_003
        }
        return total
    }

    private static func choix(_ vers: [String], graine: Int) -> String {
        guard !vers.isEmpty else { return "" }
        return vers[abs(graine) % vers.count]
    }
}
