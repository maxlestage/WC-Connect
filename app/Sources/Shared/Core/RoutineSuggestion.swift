import Foundation

/// Heure conseillée pour une visite régulière.
///
/// Aller à heure fixe est la première recommandation contre la constipation :
/// l'intestin se réveille après un repas, et le réflexe est le plus franc le
/// matin. L'app ne choisit pas à votre place — elle propose l'heure qui
/// ressort déjà de votre historique.
public enum RoutineSuggestion {

    /// Créneau du matin, où le réflexe gastro-colique est le plus marqué.
    public static let morning = 5...11

    /// À défaut d'historique : après le petit-déjeuner.
    public static let fallbackHour = 8

    public static func hour(
        sessions: [ToiletSession],
        calendar: Calendar = .current
    ) -> Int {
        let heures = sessions
            .filter { $0.endedAt != nil }
            .map { calendar.component(.hour, from: $0.startedAt) }

        if let matin = mode(heures.filter { morning.contains($0) }) { return matin }
        if let toutes = mode(heures) { return toutes }
        return fallbackHour
    }

    /// Heure la plus fréquente ; en cas d'égalité, la plus tôt, pour rester
    /// stable d'un calcul à l'autre.
    private static func mode(_ heures: [Int]) -> Int? {
        guard !heures.isEmpty else { return nil }
        var comptes: [Int: Int] = [:]
        for heure in heures { comptes[heure, default: 0] += 1 }
        return comptes
            .sorted { ($0.value, -$0.key) > ($1.value, -$1.key) }
            .first?.key
    }
}
