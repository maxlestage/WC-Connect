/** Contenu éditorial du site, typé et séparé des composants. */

export interface NavLink {
  readonly href: string;
  readonly label: string;
}

export interface Feature {
  readonly title: string;
  readonly description: string;
}

export interface Question {
  readonly question: string;
  readonly answer: string;
}

export const navLinks: readonly NavLink[] = [
  { href: "#fonctions", label: "Fonctions" },
  { href: "#aide", label: "Quand ça coince" },
  { href: "#detente", label: "Détente" },
  { href: "#live", label: "Live Activity" },
  { href: "#watch", label: "Watch" },
  { href: "#suivi", label: "Suivi" },
  { href: "#faq", label: "FAQ" },
];

export const features: readonly Feature[] = [
  {
    title: "Chronomètre d'un geste",
    description:
      "Un bouton, un anneau de progression, et c'est parti. Type de visite et lieu sont mémorisés d'une fois sur l'autre.",
  },
  {
    title: "Live Activity",
    description:
      "Le temps écoulé reste visible sur l'écran verrouillé et dans la Dynamic Island, avec un bouton « Terminer » directement dedans.",
  },
  {
    title: "Apple Watch",
    description:
      "App native au poignet : démarrer, terminer, consulter l'historique et les stats, avec retour haptique.",
  },
  {
    title: "Widgets & complications",
    description:
      "Visites du jour sur l'écran d'accueil, chronomètre sur l'écran verrouillé et sur le cadran de la montre.",
  },
  {
    title: "Quand ça coince",
    description:
      "Au bout de quelques minutes, l'app propose des gestes concrets — posture, pieds surélevés, ne pas pousser en bloquant sa respiration — et dit quand il vaut mieux consulter.",
  },
  {
    title: "Respiration guidée",
    description:
      "Trois rythmes animés, dont un sans apnée pensé pour le trône, avec un retour haptique au poignet pour garder les yeux fermés.",
  },
  {
    title: "Ambiances & musique",
    description:
      "Trois boucles sonores embarquées qui se superposent à votre musique sans l'interrompre, et les commandes de lecture de votre bibliothèque dans l'app.",
  },
  {
    title: "Statistiques claires",
    description:
      "Durée moyenne, créneau favori, répartition maison / travail / dehors, série de jours suivis et graphiques sur 7 jours.",
  },
  {
    title: "Siri & raccourcis",
    description:
      "« Dis Siri, je vais aux toilettes. » Le chronomètre démarre, même écran verrouillé, sans ouvrir l'app.",
  },
];

export const liveActivityPoints: readonly string[] = [
  "Bouton « Terminer » interactif, sans déverrouiller l'app",
  "Barre de progression vers la durée cible du type de visite",
  "Reprise automatique de l'activité si l'app est relancée",
  "Reprise sur la pile intelligente de l'Apple Watch",
];

export const watchPoints: readonly string[] = [
  "Chronomètre plein écran avec anneau de progression",
  "Respiration guidée au poignet, rythmée par les haptiques",
  "Historique et statistiques par défilement vertical",
  "Complications : cercle, rectangle, coin et ligne",
  "Retour haptique au démarrage et à la fin",
];

export const privacyTags: readonly string[] = [
  "0 tracker",
  "0 requête réseau",
  "Export CSV",
  "Suppression immédiate",
];

export const questions: readonly Question[] = [
  {
    question: "Faut-il un iPhone récent ?",
    answer:
      "WC Connect demande iOS 17 et watchOS 10. La Dynamic Island s'affiche sur les modèles qui en disposent ; sur les autres, la Live Activity reste visible sur l'écran verrouillé.",
  },
  {
    question: "L'app fonctionne-t-elle sans iPhone à proximité ?",
    answer:
      "Oui. L'app Watch enregistre la visite localement et l'envoie à l'iPhone dès qu'il redevient joignable. Les doublons sont fusionnés automatiquement.",
  },
  {
    question: "La Live Activity consomme-t-elle de la batterie ?",
    answer:
      "Très peu : le chronomètre est rendu par le système à partir d'une date de départ. L'app n'est pas réveillée pour l'animer.",
  },
  {
    question: "Faut-il un abonnement musique ?",
    answer:
      "Non. L'app ne diffuse aucun catalogue : elle pilote la lecture de votre bibliothèque ou de Musique, et ses trois ambiances sonores sont embarquées dans l'app. Les commandes fonctionnent même si vous refusez l'accès à la bibliothèque — seul l'affichage du titre en cours a besoin de cette autorisation.",
  },
  {
    question: "Les conseils remplacent-ils un médecin ?",
    answer:
      "Non, et l'app le dit. Ce sont des repères d'hygiène de vie — posture, respiration, hydratation, mouvement. L'app liste aussi les situations qui justifient un avis médical plutôt que des exercices : sang dans les selles, douleur intense, vomissements, ou une constipation qui dure plus d'une semaine.",
  },
  {
    question: "Puis-je récupérer mes données ?",
    answer:
      "Un export CSV est disponible dans les réglages : date de début, date de fin, durée, type, lieu, confort, appareil et note.",
  },
  {
    question: "C'est sérieux, ce truc ?",
    answer:
      "À moitié. Le sujet fait sourire, le code est sérieux : logique testée, données locales, interface native. À vous de voir dans quelle moitié vous vous situez.",
  },
];

/** Durée cible de la démo, en secondes (visite « Standard »). */
export const DEMO_GOAL_SECONDS = 300;

// --- Quand ça coince -------------------------------------------------------

export interface TipFamily {
  readonly title: string;
  readonly examples: readonly string[];
}

export const tipFamilies: readonly TipFamily[] = [
  {
    title: "Posture",
    examples: [
      "Surélever les pieds : genoux plus haut que les hanches",
      "Se pencher vers l'avant, coudes sur les cuisses",
      "Pieds à plat, genoux un peu écartés",
    ],
  },
  {
    title: "Respiration",
    examples: [
      "Ne jamais bloquer son souffle pour pousser",
      "Gonfler le ventre à l'inspiration",
      "Expirer longuement, comme sur une bougie",
    ],
  },
  {
    title: "Détente",
    examples: [
      "Relâcher épaules, mâchoire, plancher pelvien",
      "Six respirations lentes avant de réessayer",
      "Au bout de cinq minutes, se relever",
    ],
  },
  {
    title: "Habitudes",
    examples: [
      "Y aller dès que l'envie se présente",
      "Profiter du réflexe d'après-repas",
      "Des visites courtes, cinq à dix minutes",
    ],
  },
  {
    title: "Boire et manger",
    examples: [
      "Boire régulièrement dans la journée",
      "Monter en fibres progressivement",
      "Pruneaux, kiwis, poires",
    ],
  },
  {
    title: "Bouger",
    examples: [
      "Marcher dix à quinze minutes",
      "Masser le ventre dans le sens des aiguilles",
      "Étirer le bas du dos",
    ],
  },
];

/** Trois des conseils applicables assis, tels que l'app les propose. */
export const immediateTips: readonly string[] = [
  "Surélevez les pieds",
  "Penchez-vous vers l'avant",
  "Ne bloquez pas votre souffle",
];

export const redFlags: readonly string[] = [
  "Du sang dans les selles",
  "Une douleur intense ou persistante",
  "Des vomissements",
  "Plus d'une semaine sans amélioration",
];

export const medicalDisclaimer =
  "WC Connect n'est pas un dispositif médical et ne remplace pas l'avis d'un professionnel de santé. Les conseils de l'app sont des repères d'hygiène de vie, et elle indique les situations où il vaut mieux consulter.";

// --- Détente ---------------------------------------------------------------

export interface BreathingRhythm {
  readonly title: string;
  readonly rhythm: string;
  readonly detail: string;
  readonly recommended?: boolean;
}

export const breathingRhythms: readonly BreathingRhythm[] = [
  {
    title: "Ventre",
    rhythm: "4-6",
    detail: "Sans apnée : celui à utiliser sur le trône, puisque retenir son souffle revient à pousser.",
    recommended: true,
  },
  {
    title: "Carré",
    rhythm: "4-4-4-4",
    detail: "Quatre temps égaux, pour calmer le rythme et se recentrer.",
  },
  {
    title: "Détente",
    rhythm: "4-7-8",
    detail: "Expiration longue, pour relâcher les épaules et la mâchoire.",
  },
];

/** Rythme de la démonstration animée, identique à celui de l'app. */
export const DEMO_BREATH = { inhale: 4, exhale: 6 } as const;

// --- Son -------------------------------------------------------------------

export interface SoundscapeInfo {
  readonly title: string;
  readonly detail: string;
}

export const soundscapes: readonly SoundscapeInfo[] = [
  { title: "Pluie", detail: "Couvre les bruits alentour" },
  { title: "Bruit brun", detail: "Grave et régulier, très masquant" },
  { title: "Souffle", detail: "Respire sur dix secondes" },
];

export const soundPoints: readonly string[] = [
  "Les ambiances se superposent à votre musique au lieu de la couper",
  "Elles continuent quand l'écran se verrouille",
  "Lecture, pause et piste suivante de votre bibliothèque depuis l'app",
  "Aucun catalogue diffusé, aucun abonnement requis : c'est votre musique",
];

// --- Suivi -----------------------------------------------------------------

export interface DayBar {
  readonly label: string;
  readonly value: number;
  readonly today?: boolean;
}

/** Semaine de démonstration affichée par le graphique du suivi. */
export const weekBars: readonly DayBar[] = [
  { label: "L", value: 2 },
  { label: "M", value: 3 },
  { label: "M", value: 1 },
  { label: "J", value: 2 },
  { label: "V", value: 4 },
  { label: "S", value: 2 },
  { label: "D", value: 3, today: true },
];

export interface StatTile {
  readonly value: string;
  readonly label: string;
}

export const statTiles: readonly StatTile[] = [
  { value: "4 min 12 s", label: "Durée moyenne" },
  { value: "8 h", label: "Créneau favori" },
  { value: "12 j", label: "Série en cours" },
  { value: "2,4", label: "Visites par jour" },
];

export const trackingPoints: readonly string[] = [
  "Historique groupé par jour, filtrable par lieu",
  "Confort noté de 1 à 5 et note libre en fin de visite",
  "Répartition maison / travail / dehors",
  "Export CSV complet, et suppression immédiate",
];
