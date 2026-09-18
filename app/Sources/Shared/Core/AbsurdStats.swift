import Foundation

/// Une équivalence rigoureusement inutile.
public struct Equivalence: Identifiable, Hashable, Sendable {
    public let id: String
    public let value: String
    public let label: String
    public let symbol: String

    public init(id: String, value: String, label: String, symbol: String) {
        self.id = id
        self.value = value
        self.label = label
        self.symbol = symbol
    }
}

/// Conversions du temps passé assis en unités plus parlantes.
public enum AbsurdStats {

    /// Durée de référence de quelques activités, en secondes.
    private enum Unit {
        static let episode: TimeInterval = 22 * 60
        static let song: TimeInterval = 3 * 60 + 30
        static let tgv: TimeInterval = 116 * 60          // Paris – Lyon
        static let marathon: TimeInterval = 2 * 3600 + 35 // record du monde, à peu près
        static let softBoiledEgg: TimeInterval = 3 * 60
        static let laundry: TimeInterval = 2 * 3600 + 15 * 60
    }

    public static func equivalences(totalDuration: TimeInterval, visitCount: Int) -> [Equivalence] {
        let total = max(0, totalDuration)

        return [
            Equivalence(
                id: "episodes",
                value: count(total / Unit.episode),
                label: "épisodes de série regardés assis",
                symbol: "tv.fill"
            ),
            Equivalence(
                id: "songs",
                value: count(total / Unit.song),
                label: "chansons écoutées en entier",
                symbol: "music.note"
            ),
            Equivalence(
                id: "eggs",
                value: count(total / Unit.softBoiledEgg),
                label: "œufs à la coque, minutés à la perfection",
                symbol: "oval.portrait.fill"
            ),
            Equivalence(
                id: "tgv",
                value: decimal(total / Unit.tgv),
                label: "trajets Paris – Lyon en TGV",
                symbol: "tram.fill"
            ),
            Equivalence(
                id: "laundry",
                value: decimal(total / Unit.laundry),
                label: "cycles de lave-linge",
                symbol: "washer.fill"
            ),
            Equivalence(
                id: "marathon",
                value: decimal(total / Unit.marathon),
                label: "records du monde du marathon",
                symbol: "figure.run"
            ),
            Equivalence(
                id: "walk",
                value: distance(total),
                label: "parcourus si vous aviez marché plutôt qu'attendu",
                symbol: "figure.walk"
            ),
            Equivalence(
                id: "paper",
                value: paper(visitCount),
                label: "de papier déroulé, à vue de nez",
                symbol: "scroll.fill"
            )
        ]
    }

    /// Phrase de synthèse, à ressortir en société.
    public static func headline(totalDuration: TimeInterval) -> String {
        let hours = totalDuration / 3600
        if hours < 1 {
            return "Vous avez passé \(WCFormat.duration(totalDuration)) sur le trône. C'est un début."
        }
        if hours < 24 {
            return String(format: "Vous avez passé %.1f heures sur le trône. Un bon film, quoi.", hours)
        }
        return String(format: "Vous avez passé %.1f jours entiers sur le trône. Assumez.", hours / 24)
    }

    // MARK: - Mise en forme

    private static func count(_ value: Double) -> String {
        "\(Int(value.rounded(.down)))"
    }

    private static func decimal(_ value: Double) -> String {
        String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }

    /// Marche de loisir : 5 km/h.
    private static func distance(_ seconds: Double) -> String {
        let km = seconds / 3600 * 5
        if km < 1 {
            return "\(Int((km * 1000).rounded())) m"
        }
        return String(format: "%.1f km", km).replacingOccurrences(of: ".", with: ",")
    }

    /// Estimation très approximative : cinq feuilles de 12 cm par visite.
    private static func paper(_ visits: Int) -> String {
        let meters = Double(max(0, visits)) * 5 * 0.12
        if meters < 1_000 {
            return String(format: "%.1f m", meters).replacingOccurrences(of: ".", with: ",")
        }
        return String(format: "%.2f km", meters / 1_000).replacingOccurrences(of: ".", with: ",")
    }
}
