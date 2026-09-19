import Foundation

/// Réglages destinés à rendre une visite moins pesante.
///
/// Un chronomètre qui monte pendant qu'on attend n'aide personne : il mesure,
/// donc il juge. Ces réglages permettent de garder l'enregistrement — les
/// statistiques et le bilan pour le médecin continuent de fonctionner — tout
/// en retirant de l'écran ce qui met la pression.
public enum CalmSettings {

    private enum Key {
        static let serenity = "serenityMode"
        static let nightLight = "nightLightEnabled"
        static let nightStart = "nightLightStartHour"
        static let nightEnd = "nightLightEndHour"
        static let autoSoundscape = "autoSoundscape"
        static let autoBreathing = "autoBreathing"
    }

    // MARK: - Mode serein

    /// Pendant une visite : aucun chiffre, aucun objectif, aucune barre qui se
    /// remplit. La durée reste enregistrée, elle n'est simplement pas montrée.
    public static var serenity: Bool {
        get { AppGroup.defaults.bool(forKey: Key.serenity) }
        set { AppGroup.defaults.set(newValue, forKey: Key.serenity) }
    }

    // MARK: - Veilleuse

    /// La nuit, l'écran passe en affichage sombre et chaud : on ne se réveille
    /// pas complètement pour aller aux toilettes à trois heures du matin.
    public static var nightLight: Bool {
        get { AppGroup.defaults.bool(forKey: Key.nightLight) }
        set { AppGroup.defaults.set(newValue, forKey: Key.nightLight) }
    }

    public static var nightStartHour: Int {
        get { (AppGroup.defaults.object(forKey: Key.nightStart) as? Int) ?? 22 }
        set { AppGroup.defaults.set(newValue, forKey: Key.nightStart) }
    }

    public static var nightEndHour: Int {
        get { (AppGroup.defaults.object(forKey: Key.nightEnd) as? Int) ?? 7 }
        set { AppGroup.defaults.set(newValue, forKey: Key.nightEnd) }
    }

    /// Vrai si l'heure donnée tombe dans le créneau de nuit.
    ///
    /// Le créneau traverse minuit dans le cas courant (22 h → 7 h) : c'est
    /// exactement là que l'intervalle se lit à l'envers, et la raison d'être de
    /// cette fonction séparée.
    public static func isNight(
        at date: Date,
        start: Int,
        end: Int,
        calendar: Calendar = .current
    ) -> Bool {
        let heure = calendar.component(.hour, from: date)
        let debut = min(max(start, 0), 23)
        let fin = min(max(end, 0), 23)
        if debut == fin { return false }
        // Créneau qui traverse minuit : on est dedans avant minuit ou après.
        if debut > fin { return heure >= debut || heure < fin }
        return heure >= debut && heure < fin
    }

    /// Veilleuse active à cet instant, réglages compris.
    public static func nightLightActive(at date: Date = Date(), calendar: Calendar = .current) -> Bool {
        nightLight && isNight(at: date, start: nightStartHour, end: nightEndHour, calendar: calendar)
    }

    // MARK: - Ambiance et respiration au démarrage

    /// Ambiance lancée d'elle-même au début d'une visite, s'il y en a une.
    public static var autoSoundscape: Soundscape? {
        get {
            guard let brut = AppGroup.defaults.string(forKey: Key.autoSoundscape) else { return nil }
            return Soundscape(rawValue: brut)
        }
        set { AppGroup.defaults.set(newValue?.rawValue, forKey: Key.autoSoundscape) }
    }

    /// Ouvre la respiration guidée dès le début de la visite.
    public static var autoBreathing: Bool {
        get { AppGroup.defaults.bool(forKey: Key.autoBreathing) }
        set { AppGroup.defaults.set(newValue, forKey: Key.autoBreathing) }
    }
}
