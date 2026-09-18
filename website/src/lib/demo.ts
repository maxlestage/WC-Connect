/** Réglages des maquettes animées, indépendants de la langue. */

/** Durée cible d'une visite « Standard », en secondes. */
export const DEMO_GOAL_SECONDS = 300;

/** Rythme de la respiration guidée, identique à celui de l'app. */
export const DEMO_BREATH = { inhale: 4, exhale: 6 } as const;

/** Semaine de démonstration du graphique de suivi. */
export const WEEK_VALUES: readonly number[] = [2, 3, 1, 2, 4, 2, 3];

/** Indice du jour mis en avant dans le graphique. */
export const WEEK_TODAY_INDEX = 6;
