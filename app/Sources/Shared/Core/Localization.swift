import Foundation

/// Traduction des chaînes du modèle.
///
/// Le français sert de clé : les vues SwiftUI cherchent déjà leurs littéraux
/// dans la table `Localizable`, et ce prolongement fait la même chose pour les
/// chaînes calculées, qui ne passent pas par `LocalizedStringKey`.
///
/// La table vit dans `Support/Localization/<langue>.lproj/Localizable.strings`
/// et est embarquée dans chaque cible applicative. Clé absente ou table
/// absente : la clé — donc le français — est renvoyée telle quelle.
public extension String {
    var wcLocalized: String {
        NSLocalizedString(self, bundle: .main, comment: "")
    }

    /// Variante à paramètres, pour les chaînes à trous (`%@`).
    func wcLocalized(_ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, bundle: .main, comment: ""), arguments: arguments)
    }
}
