import Foundation

/// Symptômes notables d'une visite. Rien d'un diagnostic : un journal, que
/// l'on peut montrer à un professionnel.
public enum Symptom: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
    case bloating
    case cramps
    case urgency
    case incomplete
    case straining
    case blood

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .bloating: return "Ballonnements".wcLocalized
        case .cramps: return "Crampes".wcLocalized
        case .urgency: return "Urgence".wcLocalized
        case .incomplete: return "Sensation incomplète".wcLocalized
        case .straining: return "Effort important".wcLocalized
        case .blood: return "Présence de sang".wcLocalized
        }
    }

    public var symbol: String {
        switch self {
        case .bloating: return "wind"
        case .cramps: return "bolt.fill"
        case .urgency: return "exclamationmark.2"
        case .incomplete: return "ellipsis.circle"
        case .straining: return "figure.strengthtraining.traditional"
        case .blood: return "drop.fill"
        }
    }

    /// Certains symptômes ne relèvent pas du confort : ils justifient un avis
    /// médical, et l'app le dit sans dramatiser.
    public var needsAdvice: Bool {
        self == .blood
    }
}

/// Échelle de Bristol : la classification usuelle de la consistance des selles,
/// du type 1 (constipation) au type 7 (diarrhée).
public enum Bristol: Int, CaseIterable, Identifiable, Codable, Hashable, Sendable {
    case one = 1, two, three, four, five, six, seven

    public var id: Int { rawValue }

    public var title: String {
        "Type %@".wcLocalized(String(rawValue))
    }

    public var detail: String {
        switch self {
        case .one: return "Billes dures et séparées".wcLocalized
        case .two: return "En saucisse, grumeleuse".wcLocalized
        case .three: return "En saucisse, avec des craquelures".wcLocalized
        case .four: return "En saucisse, lisse et souple".wcLocalized
        case .five: return "Morceaux mous aux bords nets".wcLocalized
        case .six: return "Morceaux floconneux, bords déchiquetés".wcLocalized
        case .seven: return "Entièrement liquide".wcLocalized
        }
    }

    public enum Tendency: String, Sendable {
        case constipation
        case ideal
        case loose

        public var title: String {
            switch self {
            case .constipation: return "Tendance constipation".wcLocalized
            case .ideal: return "Dans la norme".wcLocalized
            case .loose: return "Tendance diarrhée".wcLocalized
            }
        }
    }

    public var tendency: Tendency {
        switch self {
        case .one, .two: return .constipation
        case .three, .four, .five: return .ideal
        case .six, .seven: return .loose
        }
    }

    /// Couleur indicative, du plus dur au plus liquide.
    public var isNotable: Bool {
        tendency != .ideal
    }
}
