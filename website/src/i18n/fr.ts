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
      { href: "#serenite", label: "Sérénité" },
      { href: "#aide", label: "Aide" },
      { href: "#sans-se-lever", label: "Sans se lever" },
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
    eyebrow: "iPhone · Apple Watch · rien à compter",
    titleLine1: "Prenez votre temps.",
    titleLine2: "L'app s'occupe du reste.",
    lead: "WC Connect note vos passages aux toilettes d'un seul geste, puis se tait. En mode serein, ni chiffre ni objectif ni barre qui se remplit : juste un souffle, sur le téléphone comme au poignet. Tout reste enregistré pour les statistiques et pour votre médecin — simplement, vous n'êtes pas obligé de le regarder.",
    primary: "Découvrir l'app",
    secondary: "Voir le mode serein",
    facts: [
      { value: "0 chiffre", label: "sous les yeux, si vous voulez" },
      { value: "0 donnée", label: "envoyée en ligne" },
      { value: "2 appareils", label: "synchronisés" },
    ],
    phoneAlt: "Écran verrouillé d'un iPhone en mode serein : aucun chronomètre, seulement « Prenez votre temps »",
    watchAlt: "Apple Watch en mode serein : un souffle qui bat lentement, sans aucun chiffre",
    activityLabel: "Visite en cours",
    activityTitle: "Prenez votre temps",
    activityMeta: "Rien ne presse",
    islandLabel: "Mode serein",
    nightLabel: "Veilleuse",
    nightValue: "22 h → 7 h",
    lockTime: "9:41",
    lockDate: "mercredi 18 mars",
    watchPlace: "Maison",
    watchCalm: "Respirez",
    watchButton: "Terminer",
  },

  calm: {
    eyebrow: "Sérénité",
    title: "Rien ne compte pendant que vous attendez",
    body: "Un chronomètre qui monte pendant qu'on attend ne rend service à personne : il mesure, donc il juge. Le mode serein le retire partout — écran principal, montre, écran verrouillé, Dynamic Island — et le remplace par un souffle qui bat lentement. La durée, elle, continue d'être enregistrée : vos statistiques et le bilan pour le médecin ne perdent rien.",
    demoAlt: "Écran de visite en mode serein : un halo qui respire, sans aucun chiffre",
    demoTitle: "Prenez votre temps",
    demoMeta: "Rien ne presse, rien ne compte",
    cards: [
      {
        title: "Mode serein",
        description: "Ni chiffre, ni objectif, ni barre qui se remplit, nulle part. Un interrupteur dans les réglages, et l'app arrête de vous montrer le temps qui passe — sans arrêter de le noter.",
      },
      {
        title: "Veilleuse",
        description: "Entre 22 h et 7 h par défaut, l'écran passe en ambre très sombre. De quoi trouver son chemin à trois heures du matin sans se réveiller tout à fait. Les heures se règlent.",
      },
      {
        title: "Ambiance au démarrage",
        description: "Choisissez une fois pour toutes la boucle sonore qui se lance d'elle-même au début d'une visite : pluie, bruit brun, souffle, ou rien du tout.",
      },
      {
        title: "Respiration au démarrage",
        description: "La respiration guidée peut s'ouvrir seule dès que la visite commence, pour que la première chose à l'écran soit un souffle et non une mesure.",
      },
      {
        title: "Sans objectifs",
        description: "L'objectif de la semaine et la série de jours suivis disparaissent de l'app. Une série qui se casse fait plus de mal qu'une série qui dure ne fait de bien.",
      },
    ],
  },

  features: {
    title: "Tout ce qu'il faut, rien de plus",
    lead: "Seize fonctions, et pas une qui vous presse : l'app s'ouvre, s'utilise et se referme en moins de trois secondes.",
    cards: [
      {
        title: "Mode serein",
        description: "Un interrupteur retire tous les chiffres de l'écran, de la montre et de l'écran verrouillé, et les remplace par un souffle. La durée reste enregistrée, elle n'est simplement plus montrée.",
      },
      {
        title: "Veilleuse",
        description: "La nuit, l'écran passe en ambre très sombre entre les heures que vous choisissez. Assez pour y voir, pas assez pour se réveiller pour de bon.",
      },
      {
        title: "Démarrer d'un geste",
        description: "Un bouton, et c'est parti. Type de visite et lieu sont mémorisés d'une fois sur l'autre. L'anneau de progression ne s'affiche que si vous le voulez bien.",
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
        description: "« Dis Siri, je vais aux toilettes. » Le suivi démarre, même écran verrouillé, sans ouvrir l'app.",
      },
      {
        title: "Sans se lever",
        description: "Une famille de conseils pour qui reste en fauteuil : transfert stable, appuis à soulager toutes les deux ou trois minutes, limite de temps assis, et les signes d'une dysréflexie autonome à reconnaître tout de suite.",
      },
      {
        title: "Tout reste sur l'appareil",
        description: "Aucun compte, aucun serveur, aucune analyse d'usage. Les visites vivent dans un groupe d'app partagé entre l'iPhone, la montre et les widgets, et nulle part ailleurs.",
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
      "En mode serein, ni chronomètre ni barre : une feuille et « Prenez votre temps »",
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

  seated: {
    eyebrow: "Sans se lever",
    title: "Quand on ne se lève pas, la moitié des conseils ne servent à rien",
    body: "« Levez-vous au bout de cinq minutes. » « Marchez dix à quinze minutes. » « Allez-y quand l'envie vient. » Ces conseils, l'app les donne toujours — mais ils ne s'appliquent pas à tout le monde. En fauteuil roulant, après une lésion médullaire, avec un intestin neurogène, la sensation d'envie peut ne plus exister et le temps passé assis devient un risque en soi. Une famille de conseils leur est consacrée, et elle ne demande jamais de se mettre debout.",
    points: [
      "Un transfert stable d'abord : freins, repose-pieds, appui à portée de main",
      "Soulager la pression toutes les deux ou trois minutes — une lunette concentre le poids sur une surface bien plus petite qu'un coussin",
      "Une limite de temps, parce que sans sensation on reste facilement trop longtemps",
      "Le massage abdominal, l'un des rares gestes qui aide assis",
      "L'horaire qui remplace l'envie : vingt à trente minutes après un repas",
    ],
    programTitle: "Ce que l'app ne fait pas",
    programBody: "Suppositoire, stimulation, irrigation : ces gestes se décident et s'apprennent avec un professionnel. L'app n'en décrit aucun. Elle sert à tenir le rythme convenu avec votre équipe, à limiter le temps assis, et à noter ce qui se passe pour en reparler.",
    urgentTitle: "Un signal qui ne se discute pas",
    urgentBody: "Après une lésion médullaire : maux de tête violents et soudains, sueurs ou rougeurs au-dessus du niveau de la lésion, vision trouble, nez bouché. Ces signes peuvent être une dysréflexie autonome, qu'un intestin plein suffit à déclencher. C'est une urgence vitale : se redresser et appeler les secours. L'app l'affiche en tête de ses signaux d'alerte.",
    reminderTitle: "Le rappel de temps assis compte double",
    reminderBody: "Au-delà d'une dizaine de minutes, le risque de rougeur puis d'escarre augmente, et le résultat ne s'améliore plus. Le rappel arrive pendant la visite et disparaît dès qu'elle se termine ; il se règle de 5 à 20 minutes.",
    handsTitle: "Démarrer et terminer sans toucher l'écran",
    handsBody: "« Dis Siri, je vais aux toilettes » lance le chronomètre, écran verrouillé. Le bouton « Terminer » est dans la Live Activity et sur la montre. Rien n'oblige à sortir le téléphone ni à viser une cible à l'écran.",
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
          { href: "#serenite", label: "Mode serein" },
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
