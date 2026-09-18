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
  { href: "#live", label: "Live Activity" },
  { href: "#watch", label: "Apple Watch" },
  { href: "#confidentialite", label: "Confidentialité" },
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
