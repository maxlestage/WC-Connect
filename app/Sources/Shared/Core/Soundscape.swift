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

    public var id: String { rawValue }

    /// Nom du fichier embarqué, sans extension.
    public var resourceName: String { rawValue }

    public var fileExtension: String { "wav" }

    public var title: String {
        switch self {
        case .rain: return "Pluie"
        case .brown: return "Bruit brun"
        case .swell: return "Souffle"
        }
    }

    public var subtitle: String {
        switch self {
        case .rain: return "Couvre les bruits alentour"
        case .brown: return "Grave et régulier, très masquant"
        case .swell: return "Respire sur dix secondes"
        }
    }

    public var symbol: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .brown: return "waveform"
        case .swell: return "wind"
        }
    }
}
