import Foundation

/// Familles de conseils.
public enum TipCategory: String, CaseIterable, Identifiable, Hashable, Sendable {
    case posture
    case breathing
    case relax
    case habits
    case food
    case movement

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .posture: return "Posture"
        case .breathing: return "Respiration"
        case .relax: return "Détente"
        case .habits: return "Habitudes"
        case .food: return "Boire et manger"
        case .movement: return "Bouger"
        }
    }

    public var symbol: String {
        switch self {
        case .posture: return "figure.seated.side"
        case .breathing: return "wind"
        case .relax: return "leaf.fill"
        case .habits: return "clock.arrow.circlepath"
        case .food: return "drop.fill"
        case .movement: return "figure.walk"
        }
    }
}

public struct Tip: Identifiable, Hashable, Sendable {
    public let id: String
    public let category: TipCategory
    public let title: String
    public let detail: String
    /// Conseil utile dans l'instant, pendant une visite qui s'éternise.
    public let isImmediate: Bool

    public init(id: String, category: TipCategory, title: String, detail: String, isImmediate: Bool = false) {
        self.id = id
        self.category = category
        self.title = title
        self.detail = detail
        self.isImmediate = isImmediate
    }
}

/// Conseils d'hygiène de vie pour les visites difficiles.
///
/// Rien ici ne relève du soin : ce sont des repères courants, et
/// `redFlags` renvoie vers un professionnel dès que la situation le demande.
public enum TipLibrary {

    public static let disclaimer = """
    WC Connect n'est pas un dispositif médical et ne remplace pas l'avis d'un \
    professionnel de santé. Ces conseils sont des repères d'hygiène de vie.
    """

    public static let all: [Tip] = [
        // Posture
        Tip(
            id: "posture-footstool",
            category: .posture,
            title: "Surélevez les pieds",
            detail: """
            Un tabouret, un marchepied ou même une pile de livres suffit. \
            Genoux plus haut que les hanches : le passage s'ouvre et l'effort \
            diminue nettement.
            """,
            isImmediate: true
        ),
        Tip(
            id: "posture-lean",
            category: .posture,
            title: "Penchez-vous vers l'avant",
            detail: """
            Coudes sur les cuisses, dos droit plutôt qu'arrondi. Cette \
            inclinaison aligne le rectum et fait le travail à votre place.
            """,
            isImmediate: true
        ),
        Tip(
            id: "posture-feet",
            category: .posture,
            title: "Pieds à plat, jambes écartées",
            detail: """
            Gardez les deux pieds posés et les genoux un peu écartés : sur la \
            pointe des pieds, tout le bassin se crispe.
            """,
            isImmediate: true
        ),

        // Respiration
        Tip(
            id: "breathing-no-valsalva",
            category: .breathing,
            title: "Ne bloquez pas votre souffle",
            detail: """
            Pousser en retenant sa respiration fait monter la pression et \
            fatigue le périnée, sans faire avancer les choses. Continuez à \
            respirer, toujours.
            """,
            isImmediate: true
        ),
        Tip(
            id: "breathing-belly",
            category: .breathing,
            title: "Respirez par le ventre",
            detail: """
            Inspirez en gonflant le ventre, expirez lentement par la bouche, \
            bien plus longtemps que l'inspiration. C'est le diaphragme qui \
            pousse, en douceur.
            """,
            isImmediate: true
        ),
        Tip(
            id: "breathing-candle",
            category: .breathing,
            title: "Soufflez comme sur une bougie",
            detail: """
            Expirez par la bouche entrouverte comme pour faire vaciller une \
            flamme sans l'éteindre : la pression reste basse et régulière.
            """,
            isImmediate: true
        ),

        // Détente
        Tip(
            id: "relax-release",
            category: .relax,
            title: "Relâchez ce qui se crispe",
            detail: """
            Épaules, mâchoire, plancher pelvien : serrer ferme le passage. \
            Passez-les en revue un par un et laissez-les tomber.
            """,
            isImmediate: true
        ),
        Tip(
            id: "relax-six-breaths",
            category: .relax,
            title: "Six respirations avant de réessayer",
            detail: """
            Plutôt que de forcer, comptez six respirations lentes. L'exercice \
            guidé de l'app est fait pour ça.
            """,
            isImmediate: true
        ),
        Tip(
            id: "relax-leave",
            category: .relax,
            title: "Au bout de cinq minutes, levez-vous",
            detail: """
            Si rien ne vient, revenez plus tard : rester assis à pousser \
            irrite et n'accélère rien. L'envie repassera.
            """,
            isImmediate: true
        ),

        // Habitudes
        Tip(
            id: "habits-answer",
            category: .habits,
            title: "Allez-y quand l'envie vient",
            detail: """
            Repousser l'envie laisse le temps à l'eau d'être réabsorbée : les \
            selles durcissent et la fois suivante est plus difficile.
            """
        ),
        Tip(
            id: "habits-after-meal",
            category: .habits,
            title: "Profitez de l'après-repas",
            detail: """
            Manger déclenche un réflexe qui met le colon en mouvement. Essayez \
            vingt à trente minutes après un repas, à heure régulière.
            """
        ),
        Tip(
            id: "habits-short",
            category: .habits,
            title: "Des visites courtes",
            detail: """
            Cinq à dix minutes suffisent. Au-delà, on pousse par habitude plus \
            que par besoin — et l'écran fait perdre la notion du temps.
            """
        ),

        // Boire et manger
        Tip(
            id: "food-water",
            category: .food,
            title: "Buvez tout au long de la journée",
            detail: """
            L'eau est ce qui rend les fibres efficaces. Augmenter les fibres \
            sans boire davantage peut même aggraver les choses.
            """
        ),
        Tip(
            id: "food-fiber",
            category: .food,
            title: "Plus de fibres, mais progressivement",
            detail: """
            Fruits, légumes, légumineuses, céréales complètes : montez en \
            douceur sur une à deux semaines, sinon ça ballonne.
            """
        ),
        Tip(
            id: "food-classics",
            category: .food,
            title: "Les classiques qui aident",
            detail: """
            Pruneaux, kiwis, poires, figues : connus pour faciliter le \
            transit. Un verre d'eau tiède au réveil met souvent la machine en \
            route.
            """
        ),

        // Bouger
        Tip(
            id: "movement-walk",
            category: .movement,
            title: "Marchez dix à quinze minutes",
            detail: """
            L'activité physique, même modeste, stimule le transit. Une marche \
            après le repas vaut mieux qu'un long moment assis.
            """
        ),
        Tip(
            id: "movement-massage",
            category: .movement,
            title: "Massez-vous le ventre",
            detail: """
            À plat, avec la paume, dans le sens des aiguilles d'une montre : \
            en bas à droite, puis le long des côtes, puis en bas à gauche. \
            Quelques minutes, sans appuyer fort.
            """,
            isImmediate: true
        ),
        Tip(
            id: "movement-stretch",
            category: .movement,
            title: "Étirez le bas du dos",
            detail: """
            Torsion assise, genoux ramenés vers la poitrine, position de \
            l'enfant : ces étirements détendent la ceinture abdominale.
            """
        )
    ]

    /// Signaux qui justifient un avis médical plutôt que des conseils.
    public static let redFlags: [String] = [
        "Du sang dans les selles, ou des selles noires",
        "Une douleur abdominale intense, ou qui ne passe pas",
        "Des vomissements avec l'impossibilité d'aller à la selle ou d'émettre des gaz",
        "Une constipation qui dure plus d'une semaine malgré ces gestes",
        "Un changement durable et inexpliqué de votre transit, ou une perte de poids",
        "De la fièvre associée aux douleurs",
        "Chez un enfant, une personne âgée, pendant une grossesse, ou avec un traitement en cours : demandez conseil sans attendre"
    ]

    public static func tips(for category: TipCategory) -> [Tip] {
        all.filter { $0.category == category }
    }

    /// Conseils actionnables dans l'instant, pour une visite qui s'éternise.
    public static var immediate: [Tip] {
        all.filter(\.isImmediate)
    }

    /// Sélection tournante de conseils immédiats, stable pour une même visite.
    public static func suggestions(seed: Int, count: Int = 3) -> [Tip] {
        let pool = immediate
        guard !pool.isEmpty else { return [] }
        // `magnitude` plutôt que `abs` : abs(Int.min) plante, et la graine vient
        // d'un hashValue.
        let start = Int(seed.magnitude % UInt(pool.count))
        return (0..<min(count, pool.count)).map { pool[(start + $0) % pool.count] }
    }
}
