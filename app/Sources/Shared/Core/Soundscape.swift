import Foundation

/// Ambiances sonores livrées avec l'app.
///
/// Les boucles sont synthétisées (voir `Support/Tools/make_soundscapes.py`),
/// donc libres de droits, et se mélangent à votre musique plutôt que de
/// l'interrompre.
public enum Soundscape: String, CaseIterable, Identifiable, Hashable, Sendable {
    case rain = "pluie"
    case brown = "bruit-brun"
    case swell = "souffle"
    case meeting = "reunion"

    public var id: String { rawValue }

    /// Nom du fichier embarqué, sans extension.
    public var resourceName: String { rawValue }

    public var fileExtension: String { "wav" }

    public var title: String {
        switch self {
        case .rain: return "Pluie"
        case .brown: return "Bruit brun"
        case .swell: return "Souffle"
        case .meeting: return "Réunion"
        }
    }

    public var subtitle: String {
        switch self {
        case .rain: return "Couvre les bruits alentour"
        case .brown: return "Grave et régulier, très masquant"
        case .swell: return "Respire sur dix secondes"
        case .meeting: return "Brouhaha de bureau et clavier, pour brouiller les pistes"
        }
    }

    public var symbol: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .brown: return "waveform"
        case .swell: return "wind"
        case .meeting: return "person.3.fill"
        }
    }
}
