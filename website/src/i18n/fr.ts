/**
 * Version française : c'est la source de vérité du contenu du site.
 * Le type `Dictionary` en est déduit, ce qui force la traduction anglaise à
 * couvrir exactement les mêmes clés.
 */
export const fr = {
  code: "fr",
  htmlLang: "fr",
  documentTitle: "WC Connect — le suivi de vos pauses, sur iPhone et Apple Watch",

  nav: {
    label: "Navigation principale",
    skip: "Aller au contenu",
    cta: "Disponibilité",
    open: "Ouvrir le menu",
    close: "Fermer le menu",
    languageLabel: "Langue",
    links: [
      { href: "#fonctions", label: "Fonctions" },
      { href: "#aide", label: "Aide" },
      { href: "#detente", label: "Détente" },
      { href: "#live", label: "Live Activity" },
      { href: "#watch", label: "Watch" },
      { href: "#suivi", label: "Suivi" },
      { href: "#journal", label: "Journal" },
      { href: "#palmares", label: "Palmarès" },
      { href: "#meteo", label: "Météo" },
      { href: "#faq", label: "FAQ" },
    ],
  },

  /* Chaque langue est nommée dans sa propre langue, dans les deux
     dictionnaires : c'est l'usage, et c'est ce qui permet de revenir en
     arrière quand on est tombé sur la mauvaise. */
  languages: { fr: "Français", en: "English" },
  languageCodes: { fr: "FR", en: "EN" },

  theme: {
    label: "Thème",
    light: "Clair",
    dark: "Sombre",
    auto: "Automatique",
    hint: "« Automatique » suit le réglage de votre appareil, y compris son passage au sombre le soir.",
  },

  hero: {
    eyebrow: "iPhone · Apple Watch · Live Activity",
    titleLine1: "Chaque pause",
    titleLine2: "compte vraiment.",
    lead: "WC Connect chronomètre vos passages aux toilettes d'un seul geste, affiche le temps écoulé sur l'écran verrouillé et dans la Dynamic Island, et vous laisse tout piloter depuis votre poignet. Sans compte, sans serveur, sans jugement.",
    primary: "Découvrir l'app",
    secondary: "Voir la Live Activity",
    facts: [
      { value: "1 geste", label: "pour démarrer" },
      { value: "0 donnée", label: "envoyée en ligne" },
      { value: "2 appareils", label: "synchronisés" },
    ],
    phoneAlt: "Écran verrouillé d'un iPhone affichant la Live Activity de WC Connect",
    watchAlt: "Apple Watch affichant le chronomètre WC Connect",
    activityLabel: "Visite en cours",
    activityMeta: "Standard · Maison",
    lockTime: "9:41",
    lockDate: "mercredi 18 mars",
    watchPlace: "Maison",
    watchButton: "Terminer",
  },

  features: {
    title: "Tout ce qu'il faut, rien de plus",
    lead: "Une app qui s'ouvre, s'utilise et se referme en moins de trois secondes.",
    cards: [
      {
        title: "Chronomètre d'un geste",
        description: "Un bouton, un anneau de progression, et c'est parti. Type de visite et lieu sont mémorisés d'une fois sur l'autre.",
      },
      {
        title: "Live Activity",
        description: "Le temps écoulé reste visible sur l'écran verrouillé et dans la Dynamic Island, avec un bouton « Terminer » directement dedans.",
      },
      {
        title: "Apple Watch",
        description: "App native au poignet : démarrer, terminer, consulter l'historique et les stats, avec retour haptique.",
      },
      {
        title: "Widgets & complications",
        description: "Visites du jour sur l'écran d'accueil, chronomètre sur l'écran verrouillé et sur le cadran de la montre.",
      },
      {
        title: "Quand ça coince",
        description: "Au bout de quelques minutes, l'app propose des gestes concrets — posture, pieds surélevés, ne pas pousser en bloquant sa respiration — et dit quand il vaut mieux consulter.",
      },
      {
        title: "Respiration guidée",
        description: "Trois rythmes animés, dont un sans apnée pensé pour le trône, avec un retour haptique au poignet pour garder les yeux fermés.",
      },
      {
        title: "Ambiances & musique",
        description: "Quatre boucles sonores embarquées qui se superposent à votre musique sans l'interrompre, et les commandes de lecture de votre bibliothèque dans l'app.",
      },
      {
        title: "Statistiques claires",
        description: "Durée moyenne, créneau favori, répartition maison / travail / dehors, série de jours suivis et graphiques sur 7 jours — avec, en tête, l'avancement de votre objectif de la semaine.",
      },
      {
        title: "Journal des symptômes",
        description: "Consistance sur l'échelle de Bristol, effort ressenti et symptômes notés en fin de visite. De quoi montrer une évolution à un professionnel, et l'exporter vers Santé si vous le voulez.",
      },
      {
        title: "Quatre rappels utiles",
        description: "Boire, y aller à heure fixe, ne pas s'éterniser assis, et une alerte après plusieurs jours sans rien. Chacun adossé à une recommandation réelle, chacun programmé localement, chacun désactivable seul.",
      },
      {
        title: "Bilan pour le médecin",
        description: "Une page sur 30, 60 ou 90 jours : fréquence, plus longue absence, durée moyenne, consistance et symptômes notés. À partager comme une image — un CSV se lit mal en cabinet.",
      },
      {
        title: "Siri & raccourcis",
        description: "« Dis Siri, je vais aux toilettes. » Le chronomètre démarre, même écran verrouillé, sans ouvrir l'app.",
      },
    ],
  },

  help: {
    eyebrow: "Quand ça coince",
    title: "Des gestes concrets, au moment où ça bloque",
    body: "Au bout de quelques minutes — avant les cinq minutes à partir desquelles il vaut mieux se relever — l'app propose trois gestes applicables assis, la respiration guidée et une ambiance sonore. La carte se masque d'un geste si vous n'en voulez pas.",
    cardAlt: "Carte de conseils affichée par l'app pendant une visite",
    cardTitle: "Ça coince ?",
    immediate: ["Surélevez les pieds", "Penchez-vous vers l'avant", "Ne bloquez pas votre souffle"],
    actions: { breathe: "Respirer", sound: "Ambiance" },
    warningTitle: "Quand consulter",
    redFlags: [
      "Du sang dans les selles",
      "Une douleur intense ou persistante",
      "Des vomissements",
      "Plus d'une semaine sans amélioration",
    ],
    disclaimer: "WC Connect n'est pas un dispositif médical et ne remplace pas l'avis d'un professionnel de santé. Les conseils de l'app sont des repères d'hygiène de vie, et elle indique les situations où il vaut mieux consulter.",
    families: [
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
    ],
  },

  breath: {
    eyebrow: "Détente",
    title: "Respirer plutôt que pousser",
    body: "Retenir son souffle pour pousser fait monter la pression et fatigue le périnée. L'app guide trois rythmes ; celui proposé pendant une visite est sans apnée, et la montre marque chaque phase d'un tapotement — de quoi suivre les yeux fermés.",
    demoAlt: "Démonstration de la respiration guidée, rythme 4-6",
    inhale: "Inspirez",
    exhale: "Expirez",
    caption: "Rythme réel de l'app : 4 secondes d'inspiration, 6 d'expiration.",
    recommended: "sur le trône",
    rhythms: [
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
        recommended: false,
      },
      {
        title: "Détente",
        rhythm: "4-7-8",
        detail: "Expiration longue, pour relâcher les épaules et la mâchoire.",
        recommended: false,
      },
    ],
  },

  sound: {
    eyebrow: "Ambiances & musique",
    title: "Votre musique, plus un fond sonore",
    body: "WC Connect ne diffuse aucun catalogue : elle télécommande ce que vous écoutez déjà, Apple Music comprise. Et elle ajoute quatre ambiances synthétisées, qui se mélangent au morceau en cours sans l'interrompre.",
    playerAlt: "Lecteur de l'app : morceau en cours et ambiances sonores",
    trackTitle: "Votre morceau",
    trackSubtitle: "Depuis votre bibliothèque",
    points: [
      "Une ambiance « Réunion » — brouhaha et clavier — pour brouiller les pistes",
      "Une couverture sonore en un geste : la Réunion, à plein volume",
      "Les ambiances se superposent à votre musique au lieu de la couper",
      "Elles continuent quand l'écran se verrouille",
      "Lecture, pause et piste suivante de votre bibliothèque depuis l'app",
      "Aucun catalogue diffusé, aucun abonnement requis : c'est votre musique",
    ],
    soundscapes: [
      { title: "Pluie", detail: "Couvre les bruits alentour" },
      { title: "Bruit brun", detail: "Grave et régulier, très masquant" },
      { title: "Souffle", detail: "Respire sur dix secondes" },
      { title: "Réunion", detail: "Brouhaha de bureau et clavier" },
    ],
  },

  live: {
    eyebrow: "Live Activity",
    title: "Le chronomètre là où vous regardez déjà",
    body: "Dès que la visite démarre, iOS affiche une Live Activity : écran verrouillé, Dynamic Island compacte, vue étendue au toucher. Le chronomètre est animé par le système — l'app reste fermée, la batterie ne bouge pas.",
    points: [
      "Bouton « Terminer » interactif, sans déverrouiller l'app",
      "Barre de progression vers la durée cible du type de visite",
      "Reprise automatique de l'activité si l'app est relancée",
      "Reprise sur la pile intelligente de l'Apple Watch",
    ],
    kind: "Standard",
    place: "Maison",
    action: "Terminer",
  },

  watch: {
    eyebrow: "Apple Watch",
    title: "Le poignet suffit",
    body: "L'app Watch est autonome : lancez la visite depuis le cadran, terminez-la d'un tapotement. Tout se resynchronise avec l'iPhone dès qu'il est à portée, y compris une visite démarrée hors de portée.",
    points: [
      "Chronomètre plein écran avec anneau de progression",
      "Respiration guidée au poignet, rythmée par les haptiques",
      "Historique et statistiques par défilement vertical",
      "Complications : cercle, rectangle, coin et ligne",
      "Retour haptique au démarrage et à la fin",
    ],
    complicationTitle: "Visite en cours",
    complicationPlace: "Maison",
    complicationInline: "WC · 3 aujourd'hui",
  },

  tracking: {
    eyebrow: "Suivi",
    title: "De quoi voir ce qui se passe vraiment",
    body: "Chaque visite enregistrée alimente un historique et des statistiques lisibles : durée moyenne, créneau favori, série de jours suivis. De quoi repérer une tendance — ou montrer quelque chose de concret à un médecin.",
    points: [
      "Historique groupé par jour, filtrable par lieu",
      "Confort noté de 1 à 5 et note libre en fin de visite",
      "Répartition maison / travail / dehors",
      "Export CSV complet, et suppression immédiate",
    ],
    chartTitle: "Visites des 7 derniers jours",
    visitOne: "visite",
    visitMany: "visites",
    days: ["L", "M", "M", "J", "V", "S", "D"],
    tiles: [
      { value: "4 min 12 s", label: "Durée moyenne" },
      { value: "8 h", label: "Créneau favori" },
      { value: "12 j", label: "Série en cours" },
      { value: "2,4", label: "Visites par jour" },
    ],
  },

  journal: {
    eyebrow: "Journal, rappels & objectifs",
    title: "Des notes qui préparent une vraie consultation",
    body: "En fin de visite, l'app propose de noter la consistance sur l'échelle de Bristol, l'effort ressenti et les symptômes. Rien n'est obligatoire, rien n'est un diagnostic : c'est un journal, à garder pour soi ou à montrer à un professionnel. Autour, quatre rappels qui servent vraiment à quelque chose, et un bilan d'une page à emmener en consultation.",
    points: [
      "Échelle de Bristol des types 1 à 7, avec la tendance associée",
      "Six symptômes en un geste, effort ressenti de 0 à 5",
      "Un rappel d'avis médical dès qu'un symptôme le justifie",
      "Quatre rappels locaux : boire, y aller à heure fixe, ne pas s'éterniser, et l'alerte après plusieurs jours sans rien",
      "Un bilan d'une page — fréquence, absences, consistance, symptômes — à partager avec un médecin",
      "Export facultatif vers Santé, et colonnes ajoutées à l'export CSV",
    ],
    cardAlt: "Journal d'une visite : consistance, effort et symptômes",
    scaleTitle: "Consistance",
    scaleFoot: "Classification usuelle. Les types 1-2 tirent vers la constipation, 6-7 vers la diarrhée.",
    scale: [
      { value: "1", label: "Dures" },
      { value: "2", label: "Grumeaux" },
      { value: "3", label: "Fissures" },
      { value: "4", label: "Lisse" },
      { value: "5", label: "Morceaux" },
      { value: "6", label: "Flocons" },
      { value: "7", label: "Liquide" },
    ],
    selected: "4",
    selectedLabel: "Dans la norme",
    effortLabel: "Effort ressenti",
    effortValue: "2 / 5",
    symptomsTitle: "Symptômes",
    symptoms: ["Ballonnements", "Crampes", "Urgence", "Sensation incomplète", "Effort important", "Présence de sang"],
    active: ["Ballonnements"],
    disclaimer: "L'app ne diagnostique rien. Un symptôme signalé renvoie vers un avis médical, jamais vers un verdict.",
    tiles: [
      { title: "Rappels d'hydratation", value: "9 h · 13 h · 16 h · 20 h", detail: "Boire est ce qui rend les fibres efficaces. De 2 à 8 rappels par jour, dans votre créneau." },
      { title: "Rappel de régularité", value: "Chaque jour à 8 h", detail: "Y aller à heure fixe est le premier conseil contre la constipation. L'heure vient de votre historique." },
      { title: "Alerte d'absence", value: "Au-delà de 3 jours", detail: "Le repère usuel de la constipation. Signalé une fois, avec un renvoi vers un avis médical." },
      { title: "Temps assis", value: "Rappel après 10 min", detail: "Rester assis à pousser fatigue les veines. Le rappel disparaît dès la fin de la visite." },
      { title: "Bilan pour le médecin", value: "30, 60 ou 90 jours", detail: "Fréquence, plus longue absence, consistance, symptômes. Une page à partager." },
      { title: "Objectif & Santé", value: "5 jours sur 7", detail: "Un objectif hebdomadaire modeste, et un export facultatif des symptômes vers Santé." },
    ],
  },

  fun: {
    eyebrow: "Inutile, donc indispensable",
    title: "Un palmarès pour un sujet qui n'en méritait pas",
    body: "Dix-neuf hauts faits calculés sur vos vraies visites, dont cinq qui ne se dévoilent qu'au déblocage, des équivalences rigoureusement absurdes, un titre honorifique et un certificat à faire circuler auprès de gens qui ne l'ont pas demandé.",
    badgesAlt: "Exemples de hauts faits à débloquer",
    points: [
      "Un titre honorifique qui évolue, d'« Anonyme des toilettes » à « Divinité des latrines »",
      "Cinq hauts faits secrets, qui ne se dévoilent qu'au déblocage",
      "Un haïku composé à la fin de chaque visite, d'après sa durée et son heure",
      "Une fanfare et un bandeau quand un haut fait tombe",
      "Un certificat officiel à partager, sans aucune valeur légale",
      "Une carte de défi à envoyer : votre rang, votre série, et rien pour arbitrer",
      "Un mode trône caché : appuyez longuement sur le chronomètre",
      "Quatorze hauts faits annoncés, plus cinq secrets : dix-neuf en tout",
    ],
    badges: [
      { title: "Éclair", detail: "Une visite en moins de 45 secondes" },
      { title: "Marathonien", detail: "Plus de vingt minutes. Respect." },
      { title: "Noctambule", detail: "Une visite entre 2 h et 5 h" },
      { title: "Globe-trotteur", detail: "Maison, travail et dehors le même jour" },
      { title: "Horloge suisse", detail: "Trois jours de suite à la même heure" },
      { title: "Le Penseur", detail: "Un quart d'heure, et un confort de 5 sur 5" },
    ],
    haiku: {
      title: "Haïku de la visite",
      lines: ["Le carrelage froid", "le temps s'étire paisiblement", "le café attendra"],
      foot: "Composé d'après la durée, l'heure et le lieu. Personne ne l'avait demandé.",
    },
    absurdTitle: "Votre temps, en unités plus parlantes",
    absurdFoot: "Exemple pour quelques heures d'historique.",
    equivalences: [
      { value: "7", label: "épisodes de série regardés assis" },
      { value: "45", label: "chansons écoutées en entier" },
      { value: "1,38", label: "trajets Paris – Lyon en TGV" },
      { value: "13,3 km", label: "parcourus si vous aviez marché" },
    ],
  },

  weather: {
    eyebrow: "Météo intestinale",
    title: "Un bulletin que personne n'avait demandé",
    body: "L'app compare la semaine écoulée à la précédente et en tire un bulletin complet : pression, risque d'averse, visibilité, vent. Aucune valeur prédictive, une vraie méthode de calcul. Elle en déduit aussi votre profil et l'heure de votre prochain passage.",
    cardAlt: "Bulletin météo intestinal affiché par l'app",
    kicker: "Météo intestinale",
    points: [
      "Un bulletin calculé sur la semaine écoulée, comparée à la précédente",
      "Pression, risque d'averse, visibilité et vent — aucun sens, une vraie méthode",
      "Un profil déduit de vos habitudes, du Sprinteur du matin à l'Ermite de la nuit",
      "Une prévision de votre prochaine visite, avec une fiabilité honnêtement basse",
      "Un widget d'écran d'accueil, pour consulter le bulletin sans ouvrir l'app",
    ],
    forecast: {
      condition: "Variable",
      summary: "Éclaircies alternant avec quelques passages nuageux. Rien d'alarmant.",
      wind: "vent modéré de secteur sud",
      rows: [
        { label: "Pression", value: "1021 hPa" },
        { label: "Averses", value: "34 %" },
        { label: "Visibilité", value: "correcte" },
      ],
      personaTitle: "L'Habitué du matin",
      personaDetail: "4 min 12 s en moyenne, avec une préférence marquée pour 8 h. Une horloge.",
      prediction: "Prochaine visite prévue vers 8 h — fiabilité 37 %",
      lifetime: "À ce rythme, vous y passerez 4,3 mois de votre vie. Assis.",
    },
  },

  privacy: {
    eyebrow: "Confidentialité",
    title: "Vos pauses ne regardent personne",
    lead: "Aucun compte, aucune analyse, aucun serveur. L'historique vit dans un espace partagé entre l'app, les widgets et la montre, sur vos appareils uniquement. La synchronisation iPhone ↔ Watch passe par WatchConnectivity, en direct, d'appareil à appareil. Les rappels — boire, régularité, absence, temps assis — sont des notifications programmées localement, et l'export vers Santé ne part que si vous l'activez : l'app y écrit, elle ne lit rien.",
    tags: ["0 tracker", "0 requête réseau", "Santé en écriture seule", "Export CSV", "Suppression immédiate"],
  },

  faq: {
    title: "Questions fréquentes",
    questions: [
      {
        question: "Faut-il un iPhone récent ?",
        answer: "WC Connect demande iOS 17 et watchOS 10. La Dynamic Island s'affiche sur les modèles qui en disposent ; sur les autres, la Live Activity reste visible sur l'écran verrouillé.",
      },
      {
        question: "L'app fonctionne-t-elle sans iPhone à proximité ?",
        answer: "Oui. L'app Watch enregistre la visite localement et l'envoie à l'iPhone dès qu'il redevient joignable. Les doublons sont fusionnés automatiquement.",
      },
      {
        question: "La Live Activity consomme-t-elle de la batterie ?",
        answer: "Très peu : le chronomètre est rendu par le système à partir d'une date de départ. L'app n'est pas réveillée pour l'animer.",
      },
      {
        question: "Faut-il un abonnement musique ?",
        answer: "Non. L'app ne diffuse aucun catalogue : elle pilote la lecture de votre bibliothèque ou de Musique, et ses quatre ambiances sonores sont embarquées dans l'app. Les commandes fonctionnent même si vous refusez l'accès à la bibliothèque — seul l'affichage du titre en cours a besoin de cette autorisation.",
      },
      {
        question: "Une ambiance « Réunion », vraiment ?",
        answer: "Vraiment. Un brouhaha de bureau avec quelques frappes de clavier, à lancer depuis les toilettes du travail. Comme les autres ambiances, elle est synthétisée et embarquée dans l'app. Ce que vous en faites ne nous regarde pas.",
      },
      {
        question: "Les conseils remplacent-ils un médecin ?",
        answer: "Non, et l'app le dit. Ce sont des repères d'hygiène de vie — posture, respiration, hydratation, mouvement. L'app liste aussi les situations qui justifient un avis médical plutôt que des exercices : sang dans les selles, douleur intense, vomissements, ou une constipation qui dure plus d'une semaine.",
      },
      {
        question: "Puis-je récupérer mes données ?",
        answer: "Un export CSV est disponible dans les réglages : date de début, date de fin, durée, type, lieu, confort, consistance, effort, symptômes, appareil et note.",
      },
      {
        question: "Qu'est-ce que le bilan pour le médecin ?",
        answer: "Une page calculée sur 30, 60 ou 90 jours : nombre de visites, jours avec visite, plus longue absence, durée moyenne, répartition de la consistance et symptômes notés. Un CSV se lit mal en cabinet ; ce bilan se partage comme une image. Il ne conclut rien — l'interprétation revient au professionnel.",
      },
      {
        question: "À quoi sert l'échelle de Bristol ?",
        answer: "C'est la classification usuelle de la consistance des selles, des types 1 à 7. Notée en fin de visite, elle sert à suivre une évolution sur plusieurs semaines — pas à poser un diagnostic. L'app en tire une tendance, et vous pouvez exporter les symptômes vers Santé pour les montrer à un professionnel.",
      },
      {
        question: "Un haïku, sérieusement ?",
        answer: "Sérieusement. Trois vers composés à la fin de chaque visite, choisis d'après sa durée, son heure et son lieu — donc toujours les mêmes pour un même passage. Trente vers en stock, dans les deux langues. C'est la fonction la plus inutile de l'app, et elle y reste.",
      },
      {
        question: "C'est sérieux, ce truc ?",
        answer: "À moitié. Le sujet fait sourire, le code est sérieux : logique testée, données locales, interface native. À vous de voir dans quelle moitié vous vous situez.",
      },
    ],
  },

  cta: {
    title: "Bientôt dans votre poche",
    body: "WC Connect est en cours de développement, en privé. L'app arrivera sur iPhone et Apple Watch ; d'ici là, la bêta se fait sur invitation.",
    action: "Revoir les fonctions",
    legal: "Projet indépendant, non affilié à Apple. iPhone, Apple Watch, Siri et Dynamic Island sont des marques d'Apple Inc.",
  },

  footer: {
    tagline: "Fait avec sérieux pour un sujet qui ne l'est pas.",
    description:
      "Le suivi discret de vos pauses, sur iPhone et Apple\u00a0Watch. Aucune donnée ne quitte vos appareils.",
    columns: [
      {
        title: "Le produit",
        links: [
          { href: "#fonctions", label: "Fonctions" },
          { href: "#live", label: "Live Activity" },
          { href: "#watch", label: "Apple Watch" },
          { href: "#suivi", label: "Suivi et statistiques" },
        ],
      },
      {
        title: "Bien-être",
        links: [
          { href: "#aide", label: "Quand ça coince" },
          { href: "#detente", label: "Respiration guidée" },
          { href: "#son", label: "Ambiances et musique" },
        ],
      },
      {
        title: "En savoir plus",
        links: [
          { href: "#palmares", label: "Palmarès" },
          { href: "#meteo", label: "Météo intestinale" },
          { href: "#confidentialite", label: "Confidentialité" },
          { href: "#faq", label: "Questions fréquentes" },
        ],
      },
    ],
    creditsTitle: "Crédits",
    credits: "Conçu et développé par %@.",
    author: "Maxime Nathan Lestage",
    statusTitle: "Disponibilité",
    status: "En développement privé. Bêta sur invitation.",
    backToTop: "Haut de page",
    copyright: "© %@ WC Connect. Tous droits réservés.",
    legal:
      "Projet indépendant, non affilié à Apple. iPhone, Apple\u00a0Watch, Siri, Apple\u00a0Music et Dynamic Island sont des marques d'Apple\u00a0Inc.",
    medical:
      "WC Connect n'est pas un dispositif médical et ne remplace pas l'avis d'un professionnel de santé.",
  },
};

/** Forme du dictionnaire : toute traduction doit couvrir exactement ces clés. */
export type Dictionary = typeof fr;
