import Foundation

/// Répartition des rappels d'hydratation dans la journée.
///
/// Logique pure, isolée du service de notifications pour rester testable :
/// l'environnement de test n'embarque que `Sources/Shared/Core`.
public enum HydrationSchedule {

    /// Bornes acceptées par les réglages.
    public static let countRange = 2...8
    public static let hourRange = 0...23

    /// Heures auxquelles les rappels tombent, réparties régulièrement dans la
    /// plage demandée. La première heure est toujours `startHour`, la
    /// dernière `endHour` : ce qui est demandé est ce qui est programmé.
    public static func hours(count: Int, startHour: Int, endHour: Int) -> [Int] {
        let debut = min(max(startHour, hourRange.lowerBound), hourRange.upperBound)
        let fin = min(max(endHour, debut + 1), hourRange.upperBound)
        let nombre = min(max(count, countRange.lowerBound), countRange.upperBound)

        // Plage trop étroite pour le nombre demandé : on ne programme pas deux
        // rappels à la même heure.
        let maximum = fin - debut + 1
        let effectif = min(nombre, maximum)
        guard effectif > 1 else { return [debut] }

        let pas = Double(fin - debut) / Double(effectif - 1)
        let heures = (0..<effectif).map { debut + Int((Double($0) * pas).rounded()) }
        return Array(Set(heures)).sorted()
    }
}
