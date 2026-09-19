import Foundation

/// Familles de conseils.
public enum TipCategory: String, CaseIterable, Identifiable, Hashable, Sendable {
    case posture
    case breathing
    case relax
    case habits
    case food
    case movement
    /// Pour qui ne se lève pas : fauteuil roulant, transfert, intestin
    /// neurogène. Plusieurs conseils des autres familles — « levez-vous »,
    /// « marchez », « allez-y quand l'envie vient » — ne s'y appliquent pas.
    case seated

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .posture: return "Posture".wcLocalized
        case .breathing: return "Respiration".wcLocalized
        case .relax: return "Détente".wcLocalized
        case .habits: return "Habitudes".wcLocalized
        case .food: return "Boire et manger".wcLocalized
        case .movement: return "Bouger".wcLocalized
        case .seated: return "Sans se lever".wcLocalized
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
        case .seated: return "figure.roll"
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

    public static var disclaimer: String { "WC Connect n'est pas un dispositif médical et ne remplace pas l'avis d'un professionnel de santé. Ces conseils sont des repères d'hygiène de vie.".wcLocalized }

    public static let all: [Tip] = [
        // Posture
        Tip(
            id: "posture-footstool",
            category: .posture,
            title: "Surélevez les pieds".wcLocalized,
            detail: "Un tabouret, un marchepied ou même une pile de livres suffit. Genoux plus haut que les hanches : le passage s'ouvre et l'effort diminue nettement.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "posture-lean",
            category: .posture,
            title: "Penchez-vous vers l'avant".wcLocalized,
            detail: "Coudes sur les cuisses, dos droit plutôt qu'arrondi. Cette inclinaison aligne le rectum et fait le travail à votre place.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "posture-feet",
            category: .posture,
            title: "Pieds à plat, jambes écartées".wcLocalized,
            detail: "Gardez les deux pieds posés et les genoux un peu écartés : sur la pointe des pieds, tout le bassin se crispe.".wcLocalized,
            isImmediate: true
        ),

        // Respiration
        Tip(
            id: "breathing-no-valsalva",
            category: .breathing,
            title: "Ne bloquez pas votre souffle".wcLocalized,
            detail: "Pousser en retenant sa respiration fait monter la pression et fatigue le périnée, sans faire avancer les choses. Continuez à respirer, toujours.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "breathing-belly",
            category: .breathing,
            title: "Respirez par le ventre".wcLocalized,
            detail: "Inspirez en gonflant le ventre, expirez lentement par la bouche, bien plus longtemps que l'inspiration. C'est le diaphragme qui pousse, en douceur.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "breathing-candle",
            category: .breathing,
            title: "Soufflez comme sur une bougie".wcLocalized,
            detail: "Expirez par la bouche entrouverte comme pour faire vaciller une flamme sans l'éteindre : la pression reste basse et régulière.".wcLocalized,
            isImmediate: true
        ),

        // Détente
        Tip(
            id: "relax-release",
            category: .relax,
            title: "Relâchez ce qui se crispe".wcLocalized,
            detail: "Épaules, mâchoire, plancher pelvien : serrer ferme le passage. Passez-les en revue un par un et laissez-les tomber.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "relax-six-breaths",
            category: .relax,
            title: "Six respirations avant de réessayer".wcLocalized,
            detail: "Plutôt que de forcer, comptez six respirations lentes. L'exercice guidé de l'app est fait pour ça.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "relax-leave",
            category: .relax,
            title: "Au bout de cinq minutes, levez-vous".wcLocalized,
            detail: "Si rien ne vient, revenez plus tard : rester assis à pousser irrite et n'accélère rien. L'envie repassera.".wcLocalized,
            isImmediate: true
        ),

        // Habitudes
        Tip(
            id: "habits-answer",
            category: .habits,
            title: "Allez-y quand l'envie vient".wcLocalized,
            detail: "Repousser l'envie laisse le temps à l'eau d'être réabsorbée : les selles durcissent et la fois suivante est plus difficile.".wcLocalized
        ),
        Tip(
            id: "habits-after-meal",
            category: .habits,
            title: "Profitez de l'après-repas".wcLocalized,
            detail: "Manger déclenche un réflexe qui met le colon en mouvement. Essayez vingt à trente minutes après un repas, à heure régulière.".wcLocalized
        ),
        Tip(
            id: "habits-short",
            category: .habits,
            title: "Des visites courtes".wcLocalized,
            detail: "Cinq à dix minutes suffisent. Au-delà, on pousse par habitude plus que par besoin — et l'écran fait perdre la notion du temps.".wcLocalized
        ),

        // Boire et manger
        Tip(
            id: "food-water",
            category: .food,
            title: "Buvez tout au long de la journée".wcLocalized,
            detail: "L'eau est ce qui rend les fibres efficaces. Augmenter les fibres sans boire davantage peut même aggraver les choses.".wcLocalized
        ),
        Tip(
            id: "food-fiber",
            category: .food,
            title: "Plus de fibres, mais progressivement".wcLocalized,
            detail: "Fruits, légumes, légumineuses, céréales complètes : montez en douceur sur une à deux semaines, sinon ça ballonne.".wcLocalized
        ),
        Tip(
            id: "food-classics",
            category: .food,
            title: "Les classiques qui aident".wcLocalized,
            detail: "Pruneaux, kiwis, poires, figues : connus pour faciliter le transit. Un verre d'eau tiède au réveil met souvent la machine en route.".wcLocalized
        ),

        // Bouger
        Tip(
            id: "movement-walk",
            category: .movement,
            title: "Marchez dix à quinze minutes".wcLocalized,
            detail: "L'activité physique, même modeste, stimule le transit. Une marche après le repas vaut mieux qu'un long moment assis.".wcLocalized
        ),
        Tip(
            id: "movement-massage",
            category: .movement,
            title: "Massez-vous le ventre".wcLocalized,
            detail: "À plat, avec la paume, dans le sens des aiguilles d'une montre : en bas à droite, puis le long des côtes, puis en bas à gauche. Quelques minutes, sans appuyer fort.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "movement-stretch",
            category: .movement,
            title: "Étirez le bas du dos".wcLocalized,
            detail: "Torsion assise, genoux ramenés vers la poitrine, position de l'enfant : ces étirements détendent la ceinture abdominale.".wcLocalized
        ),

        // Sans se lever
        //
        // Rien ici ne relève du soin : aucune technique n'est décrite, et le
        // programme intestinal reste celui établi avec l'équipe soignante.
        // L'app aide à le tenir, elle ne le remplace pas.
        Tip(
            id: "seated-transfer",
            category: .seated,
            title: "Un transfert stable avant tout".wcLocalized,
            detail: "Freins bloqués, repose-pieds dégagés, appui à portée de main. Une chute lors du transfert fait plus de dégâts qu'une visite ratée : si l'installation n'est pas sûre, rien d'autre ne compte.".wcLocalized
        ),
        Tip(
            id: "seated-pressure",
            category: .seated,
            title: "Soulagez la pression régulièrement".wcLocalized,
            detail: "Une lunette concentre tout le poids sur une petite surface, bien plus qu'un coussin. Penchez-vous d'un côté puis de l'autre, ou prenez appui pour vous soulever quelques secondes, toutes les deux ou trois minutes.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "seated-duration",
            category: .seated,
            title: "Fixez-vous une limite de temps".wcLocalized,
            detail: "Sans sensation, on reste facilement trop longtemps. Le rappel de temps assis de l'app sert exactement à ça : au-delà de dix minutes, le risque de rougeur puis d'escarre augmente, et le résultat ne s'améliore plus.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "seated-massage",
            category: .seated,
            title: "Massez le ventre dans le sens du côlon".wcLocalized,
            detail: "À plat de main, en remontant à droite, en traversant sous les côtes, puis en descendant à gauche. Lentement, plusieurs fois. C'est faisable assis, et c'est l'un des rares gestes qui aide sans se lever.".wcLocalized,
            isImmediate: true
        ),
        Tip(
            id: "seated-routine",
            category: .seated,
            title: "Toujours à la même heure, après un repas".wcLocalized,
            detail: "Quand l'envie ne se fait plus sentir, c'est l'horaire qui prend le relais. Vingt à trente minutes après un repas, l'intestin se met en mouvement de lui-même : le rappel de régularité de l'app se cale sur ce créneau.".wcLocalized
        ),
        Tip(
            id: "seated-program",
            category: .seated,
            title: "Votre programme reste celui de votre équipe".wcLocalized,
            detail: "Suppositoire, stimulation, irrigation : ces gestes se décident et s'apprennent avec un professionnel, et l'app n'en décrit aucun. Elle sert à tenir le rythme convenu et à noter ce qui se passe, pour en reparler avec lui.".wcLocalized
        )
    ]

    /// Signaux qui justifient un avis médical plutôt que des conseils.
    public static var redFlags: [String] { [
        // La dysréflexie autonome est une urgence vitale, déclenchée entre
        // autres par un intestin plein, chez les personnes ayant une lésion
        // médullaire haute. Elle figure en tête parce qu'elle ne se traite pas
        // avec des conseils d'hygiène de vie.
        "Après une lésion médullaire : maux de tête violents et soudains, sueurs ou rougeurs au-dessus du niveau de la lésion, vision trouble, nez bouché — ces signes peuvent être une dysréflexie autonome, déclenchée par un intestin plein. C'est une urgence : redressez-vous et appelez les secours",
        "Du sang dans les selles, ou des selles noires",
        "Une douleur abdominale intense, ou qui ne passe pas",
        "Des vomissements avec l'impossibilité d'aller à la selle ou d'émettre des gaz",
        "Une constipation qui dure plus d'une semaine malgré ces gestes",
        "Un changement durable et inexpliqué de votre transit, ou une perte de poids",
        "De la fièvre associée aux douleurs",
        "Chez un enfant, une personne âgée, pendant une grossesse, ou avec un traitement en cours : demandez conseil sans attendre",
        "Une rougeur qui ne s'efface pas, une peau abîmée au niveau des appuis après une visite : montrez-la sans attendre"
    ].map(\.wcLocalized) }

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
