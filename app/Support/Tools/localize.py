#!/usr/bin/env python3
"""Génère les tables de traduction de l'app depuis une correspondance unique.

Le français sert de clé : les vues SwiftUI cherchent déjà leurs littéraux dans
la table `Localizable`, et `String.wcLocalized` fait de même pour les chaînes
calculées. Ce script écrit :

  Support/Localization/fr.lproj/Localizable.strings   (identité)
  Support/Localization/en.lproj/Localizable.strings   (traduction)

et signale toute clé présente dans le code mais absente de la table.

Usage : python3 Support/Tools/localize.py [--check]
"""
import pathlib
import re
import sys

TRANSLATIONS = {
    # --- Onglets, écrans, actions ---
    "WC Connect": "WC Connect",
    "Visite": "Visit",
    "Détente": "Unwind",
    "Historique": "History",
    "Stats": "Stats",
    "Statistiques": "Statistics",
    "Réglages": "Settings",
    "Conseils": "Tips",
    "Palmarès": "Trophies",
    "Respirer": "Breathe",
    "Commencer": "Start",
    "Démarrer": "Start",
    "Démarrer la visite": "Start visit",
    "Terminer": "Finish",
    "Terminer la visite": "Finish visit",
    "Arrêter": "Stop",
    "Recommencer": "Start again",
    "Annuler": "Cancel",
    "Annuler la visite": "Cancel visit",
    "Fermer": "Close",
    "Enregistrer": "Save",
    "Ignorer": "Skip",
    "Supprimer": "Delete",
    "Effacer": "Erase",
    "Effacer l'historique": "Erase history",
    "Effacer tout l'historique ?": "Erase the whole history?",
    "Cette action est définitive.": "This cannot be undone.",
    "Filtrer": "Filter",
    "Prêt": "Ready",
    "Pause": "Pause",
    "Masquer les conseils": "Hide the tips",
    "Tous les conseils": "All tips",
    "Tous les lieux": "All places",
    "Par lieu": "By place",
    "Par défaut": "Defaults",
    "Appareils": "Devices",
    "Données": "Data",
    "Version": "Version",
    "Crédits": "Credits",
    "Conçu et développé par": "Designed and developed by",
    "En cours": "In progress",
    "Dernière visite": "Last visit",
    "Aucune visite": "No visits",
    "Aucune visite en cours": "No visit in progress",
    "Aucune visite en cours.": "No visit in progress.",
    "Aucune visite enregistrée": "No visits recorded",
    "Visite en cours": "Visit in progress",
    "Visite enregistrée": "Visit recorded",
    "Visites enregistrées": "Recorded visits",
    "C'est noté": "Noted",
    "Confort": "Comfort",
    "Note": "Note",
    "Optionnel": "Optional",
    "Durée": "Duration",
    "Durée en minutes": "Duration in minutes",
    "Lieu": "Place",
    "Type": "Type",
    "Type de visite": "Visit type",
    "Live Activity": "Live Activity",
    "Live Activity active": "Live Activity running",
    "Autorisée": "Allowed",
    "Désactivée dans Réglages": "Turned off in Settings",
    "Appairée": "Paired",
    "Indisponible": "Unavailable",
    "Apple Watch": "Apple Watch",
    "Retour haptique sur la Watch": "Haptic feedback on the Watch",
    "Exporter en CSV": "Export as CSV",
    "Partager le CSV": "Share the CSV",
    "La Live Activity s'affiche sur l'écran verrouillé, dans la Dynamic Island et dans la pile intelligente de l'Apple Watch. Elle s'active automatiquement au démarrage d'une visite.":
        "The Live Activity appears on the Lock Screen, in the Dynamic Island and in the Apple Watch Smart Stack. It starts automatically with a visit.",
    "Toutes les données restent sur vos appareils : stockage local partagé entre l'app, les widgets et la Watch. Aucun compte, aucun serveur.":
        "All data stays on your devices: local storage shared between the app, the widgets and the Watch. No account, no server.",
    "Les visites enregistrées depuis l'iPhone, la Watch ou un widget apparaîtront ici.":
        "Visits recorded from the iPhone, the Watch or a widget will show up here.",

    # --- Types de visite, lieux, appareils ---
    "Express": "Express",
    "Standard": "Standard",
    "Longue": "Long",
    "Maison": "Home",
    "Travail": "Work",
    "Dehors": "Out",
    "iPhone": "iPhone",
    "Widget": "Widget",

    # --- Statistiques ---
    "Aujourd'hui": "Today",
    "Hier": "Yesterday",
    "Durée moyenne": "Average duration",
    "Série en cours": "Current streak",
    "Visites par jour": "Visits per day",
    "Visite la plus longue": "Longest visit",
    "Créneau favori": "Favourite slot",
    "Confort moyen": "Average comfort",
    "Visites des 7 derniers jours": "Visits over the last 7 days",
    "Répartition sur la journée": "Spread across the day",
    "Par créneaux de 3 heures": "In 3-hour slots",
    "Jour": "Day",
    "Visites": "Visits",
    "Créneau": "Slot",
    "Total": "Total",
    "Moyenne": "Average",
    "Par jour": "Per day",
    "Temps total": "Total time",
    "Record": "Record",
    "Série": "Streak",

    # --- Respiration ---
    "Inspirez": "Breathe in",
    "Retenez": "Hold",
    "Expirez": "Breathe out",
    "Ventre 4-6": "Belly 4-6",
    "Carré 4-4-4-4": "Box 4-4-4-4",
    "Détente 4-7-8": "Relax 4-7-8",
    "Sans apnée : la plus indiquée sur le trône, elle relâche le ventre et le périnée.":
        "No breath hold: the best one on the throne, it releases the belly and the pelvic floor.",
    "Quatre temps égaux pour calmer le rythme et se recentrer.":
        "Four equal counts to slow things down and settle.",
    "Expiration longue, pour relâcher les épaules et la mâchoire.":
        "A long exhale, to release the shoulders and the jaw.",
    "Respiration guidée": "Guided breathing",
    "Respirer lentement relâche le ventre et le périnée. Ne bloquez jamais votre souffle pour pousser.":
        "Breathing slowly releases the belly and the pelvic floor. Never hold your breath to push.",
    "Six respirations de plus si besoin — sans jamais pousser en retenant votre souffle.":
        "Six more breaths if needed — never pushing while holding your breath.",
    "Rythme": "Rhythm",
    "Cycles": "Cycles",
    "conseillé": "recommended",
    "Terminé": "Done",

    # --- Ambiances et musique ---
    "Ambiances": "Soundscapes",
    "Pluie": "Rain",
    "Bruit brun": "Brown noise",
    "Souffle": "Breath",
    "Réunion": "Meeting",
    "Couvre les bruits alentour": "Covers the noises around you",
    "Grave et régulier, très masquant": "Deep and steady, very masking",
    "Respire sur dix secondes": "Swells over ten seconds",
    "Brouhaha de bureau et clavier, pour brouiller les pistes":
        "Office chatter and keyboard, to cover your tracks",
    "Boucles embarquées, qui se superposent à votre musique sans l'interrompre.":
        "Built-in loops that layer over your music without interrupting it.",
    "Votre musique": "Your music",
    "Musique": "Music",
    "Autoriser l'accès": "Allow access",
    "Autorisez l'accès à votre bibliothèque pour voir le morceau en cours. Les commandes de lecture fonctionnent sans autorisation.":
        "Allow access to your library to see the current track. Playback controls work without it.",
    "Rien en cours de lecture. Choisissez un morceau dans Musique, puis revenez ici.":
        "Nothing playing. Pick a track in Music, then come back here.",
    "Lancez un morceau depuis Musique, puis pilotez-le d'ici.":
        "Start a track in Music, then control it from here.",
    "Titre inconnu": "Unknown title",
    "Ambiance": "Sound",
    "Couper": "Mute",

    # --- Aide ---
    "Ça coince ?": "Stuck?",
    "Dans l'instant": "Right now",
    "Ces gestes-là s'appliquent tout de suite, assis.": "These apply straight away, sitting down.",
    "Quand consulter": "When to see a doctor",
    "Posture": "Posture",
    "Respiration": "Breathing",
    "Habitudes": "Habits",
    "Boire et manger": "Food & drink",
    "Bouger": "Moving",
    "Posture, respiration, habitudes — et quand consulter.":
        "Posture, breathing, habits — and when to see a doctor.",
}

TRANSLATIONS.update({
    # --- Conseils ---
    "Surélevez les pieds": "Raise your feet",
    "Un tabouret, un marchepied ou même une pile de livres suffit. Genoux plus haut que les hanches : le passage s'ouvre et l'effort diminue nettement.":
        "A stool, a step or even a stack of books will do. Knees above your hips: the passage opens and the effort drops noticeably.",
    "Penchez-vous vers l'avant": "Lean forward",
    "Coudes sur les cuisses, dos droit plutôt qu'arrondi. Cette inclinaison aligne le rectum et fait le travail à votre place.":
        "Elbows on your thighs, back straight rather than rounded. That tilt lines up the rectum and does the work for you.",
    "Pieds à plat, jambes écartées": "Feet flat, legs apart",
    "Gardez les deux pieds posés et les genoux un peu écartés : sur la pointe des pieds, tout le bassin se crispe.":
        "Keep both feet down and your knees slightly apart: on tiptoe, the whole pelvis tightens.",
    "Ne bloquez pas votre souffle": "Don't hold your breath",
    "Pousser en retenant sa respiration fait monter la pression et fatigue le périnée, sans faire avancer les choses. Continuez à respirer, toujours.":
        "Pushing while holding your breath raises the pressure and tires the pelvic floor, without moving anything along. Keep breathing, always.",
    "Respirez par le ventre": "Breathe with your belly",
    "Inspirez en gonflant le ventre, expirez lentement par la bouche, bien plus longtemps que l'inspiration. C'est le diaphragme qui pousse, en douceur.":
        "Breathe in letting your belly expand, breathe out slowly through your mouth, for much longer than the inhale. The diaphragm does the pushing, gently.",
    "Soufflez comme sur une bougie": "Blow as if onto a candle",
    "Expirez par la bouche entrouverte comme pour faire vaciller une flamme sans l'éteindre : la pression reste basse et régulière.":
        "Breathe out through slightly parted lips, as if making a flame flicker without blowing it out: the pressure stays low and steady.",
    "Relâchez ce qui se crispe": "Release what tightens",
    "Épaules, mâchoire, plancher pelvien : serrer ferme le passage. Passez-les en revue un par un et laissez-les tomber.":
        "Shoulders, jaw, pelvic floor: clenching closes the passage. Go through them one by one and let them drop.",
    "Six respirations avant de réessayer": "Six breaths before trying again",
    "Plutôt que de forcer, comptez six respirations lentes. L'exercice guidé de l'app est fait pour ça.":
        "Rather than forcing, count six slow breaths. The app's guided exercise is made for this.",
    "Au bout de cinq minutes, levez-vous": "After five minutes, stand up",
    "Si rien ne vient, revenez plus tard : rester assis à pousser irrite et n'accélère rien. L'envie repassera.":
        "If nothing comes, come back later: sitting there pushing irritates and speeds up nothing. The urge will return.",
    "Allez-y quand l'envie vient": "Go when the urge comes",
    "Repousser l'envie laisse le temps à l'eau d'être réabsorbée : les selles durcissent et la fois suivante est plus difficile.":
        "Putting the urge off gives water time to be reabsorbed: stools harden and the next time is harder.",
    "Profitez de l'après-repas": "Use the post-meal window",
    "Manger déclenche un réflexe qui met le colon en mouvement. Essayez vingt à trente minutes après un repas, à heure régulière.":
        "Eating triggers a reflex that gets the colon moving. Try twenty to thirty minutes after a meal, at a regular time.",
    "Des visites courtes": "Keep visits short",
    "Cinq à dix minutes suffisent. Au-delà, on pousse par habitude plus que par besoin — et l'écran fait perdre la notion du temps.":
        "Five to ten minutes is enough. Beyond that, you push out of habit rather than need — and a screen makes you lose track of time.",
    "Buvez tout au long de la journée": "Drink through the day",
    "L'eau est ce qui rend les fibres efficaces. Augmenter les fibres sans boire davantage peut même aggraver les choses.":
        "Water is what makes fibre work. Adding fibre without drinking more can even make things worse.",
    "Plus de fibres, mais progressivement": "More fibre, but gradually",
    "Fruits, légumes, légumineuses, céréales complètes : montez en douceur sur une à deux semaines, sinon ça ballonne.":
        "Fruit, vegetables, pulses, wholegrains: ramp up gently over one or two weeks, otherwise it bloats.",
    "Les classiques qui aident": "The classics that help",
    "Pruneaux, kiwis, poires, figues : connus pour faciliter le transit. Un verre d'eau tiède au réveil met souvent la machine en route.":
        "Prunes, kiwis, pears, figs: known to help things along. A glass of warm water on waking often gets the machine going.",
    "Marchez dix à quinze minutes": "Walk for ten to fifteen minutes",
    "L'activité physique, même modeste, stimule le transit. Une marche après le repas vaut mieux qu'un long moment assis.":
        "Physical activity, even modest, stimulates transit. A walk after a meal beats a long sit.",
    "Massez-vous le ventre": "Massage your belly",
    "À plat, avec la paume, dans le sens des aiguilles d'une montre : en bas à droite, puis le long des côtes, puis en bas à gauche. Quelques minutes, sans appuyer fort.":
        "Flat, with your palm, clockwise: lower right, then along the ribs, then lower left. A few minutes, without pressing hard.",
    "Étirez le bas du dos": "Stretch your lower back",
    "Torsion assise, genoux ramenés vers la poitrine, position de l'enfant : ces étirements détendent la ceinture abdominale.":
        "Seated twist, knees to your chest, child's pose: these stretches relax the abdominal girdle.",

    # --- Signaux d'alerte et avertissement ---
    "Du sang dans les selles, ou des selles noires": "Blood in your stool, or black stools",
    "Une douleur abdominale intense, ou qui ne passe pas": "Severe abdominal pain, or pain that won't go away",
    "Des vomissements avec l'impossibilité d'aller à la selle ou d'émettre des gaz":
        "Vomiting together with being unable to pass stools or gas",
    "Une constipation qui dure plus d'une semaine malgré ces gestes":
        "Constipation lasting more than a week despite these measures",
    "Un changement durable et inexpliqué de votre transit, ou une perte de poids":
        "A lasting, unexplained change in your transit, or weight loss",
    "De la fièvre associée aux douleurs": "Fever alongside the pain",
    "Chez un enfant, une personne âgée, pendant une grossesse, ou avec un traitement en cours : demandez conseil sans attendre":
        "For a child, an older person, during pregnancy, or while on medication: seek advice without delay",
    "WC Connect n'est pas un dispositif médical et ne remplace pas l'avis d'un professionnel de santé. Ces conseils sont des repères d'hygiène de vie.":
        "WC Connect is not a medical device and does not replace advice from a health professional. These tips are everyday-habit pointers.",

    # --- Météo intestinale ---
    "Météo intestinale": "Gut forecast",
    "Bulletin indisponible": "Forecast unavailable",
    "Pas encore assez de visites pour établir des prévisions. Revenez après quelques passages.":
        "Not enough visits yet to issue a forecast. Come back after a few.",
    "Grand beau": "Fine",
    "Ciel dégagé sur l'ensemble du territoire. Profitez-en, ça ne durera pas.":
        "Clear skies nationwide. Enjoy it, it won't last.",
    "Variable": "Changeable",
    "Éclaircies alternant avec quelques passages nuageux. Rien d'alarmant.":
        "Bright spells alternating with a few cloudy periods. Nothing alarming.",
    "Perturbé": "Unsettled",
    "Le passage s'annonce laborieux. Une marche et un verre d'eau amélioreraient le front.":
        "Rough going ahead. A walk and a glass of water would improve the front.",
    "Tempête": "Storm",
    "Conditions difficiles. Surélevez les pieds, respirez, et ne forcez pas : l'accalmie viendra.":
        "Difficult conditions. Raise your feet, breathe, and don't force it: the lull will come.",
    "vent faible, tendance au calme": "light wind, turning calm",
    "vent modéré de secteur sud": "moderate southerly wind",
    "vent soutenu, rafales possibles": "strong wind, gusts possible",
    "vent de tempête, avis aux navigateurs": "gale-force wind, sailors beware",
    "vent nul": "no wind",
    "réduite, brouillard persistant": "poor, persistent fog",
    "correcte, quelques bancs de brume": "fair, a few patches of mist",
    "excellente, dix kilomètres": "excellent, ten kilometres",
    "nulle": "none",
    "Pression": "Pressure",
    "Averses": "Showers",
    "Visibilité": "Visibility",

    # --- Profils ---
    "Profil vierge": "Blank profile",
    "Aucune visite enregistrée : votre légende reste à écrire.":
        "No visits recorded: your legend is yet to be written.",
    "Le Sprinteur": "The Sprinter",
    "L'Habitué": "The Regular",
    "Le Philosophe": "The Philosopher",
    "Le Fantôme nocturne": "The Night Ghost",
    "Le Veilleur": "The Watchman",
    "L'Ermite de la nuit": "The Hermit of the Night",
    "du matin": "of the Morning",
    "de la pause déjeuner": "of the Lunch Break",
    "de l'après-midi": "of the Afternoon",
    "du soir": "of the Evening",
    "de la nuit": "of the Night",
    "une heure indéterminée": "an unknown hour",

    # --- Hauts faits ---
    "Hauts faits": "Achievements",
    "Haut fait débloqué": "Achievement unlocked",
    "Hauts faits, chiffres absurdes et certificat officiel.":
        "Achievements, absurd figures and an official certificate.",
    "Première fois": "First time",
    "Enregistrer sa première visite.": "Record your first visit.",
    "Éclair": "Lightning",
    "Une visite bouclée en moins de 45 secondes.": "A visit wrapped up in under 45 seconds.",
    "Marathonien": "Marathoner",
    "Une visite de plus de vingt minutes. Respect, et attention au périnée.":
        "A visit of over twenty minutes. Respect — and mind the pelvic floor.",
    "Noctambule": "Night owl",
    "Une visite entre 2 h et 5 h du matin.": "A visit between 2 and 5 in the morning.",
    "Avant le coq": "Before the rooster",
    "Une visite avant 6 h.": "A visit before 6 am.",
    "Globe-trotteur": "Globetrotter",
    "Les trois lieux — maison, travail, dehors — le même jour.":
        "All three places — home, work, out — on the same day.",
    "Horloge suisse": "Swiss clock",
    "Trois jours de suite à la même heure, à un quart d'heure près.":
        "Three days in a row at the same time, give or take a quarter of an hour.",
    "Semaine parfaite": "Perfect week",
    "Sept jours consécutifs avec au moins une visite.":
        "Seven consecutive days with at least one visit.",
    "Centurion": "Centurion",
    "Cent visites enregistrées.": "One hundred visits recorded.",
    "Le Penseur": "The Thinker",
    "Plus d'un quart d'heure, et un confort de 5 sur 5.":
        "More than a quarter of an hour, and comfort 5 out of 5.",
    "Cinq étoiles": "Five stars",
    "Dix visites notées 5 sur 5.": "Ten visits rated 5 out of 5.",
    "Doublé": "Double",
    "Deux visites en moins de trente minutes.": "Two visits in under thirty minutes.",
    "Journée chargée": "Busy day",
    "Cinq visites dans la même journée.": "Five visits in the same day.",
    "Discrétion au bureau": "Discretion at the office",
    "Vingt visites au travail. Personne n'a rien remarqué.":
        "Twenty visits at work. Nobody noticed a thing.",

    # --- Rangs ---
    "Anonyme des toilettes": "Bathroom Nobody",
    "Apprenti": "Apprentice",
    "Habitué": "Regular",
    "Vétéran du trône": "Throne Veteran",
    "Maître du transit": "Master of Transit",
    "Légende vivante": "Living Legend",

    # --- Chiffres absurdes, certificat, rétrospective ---
    "Chiffres absurdes": "Absurd figures",
    "épisodes de série regardés assis": "TV episodes watched sitting down",
    "chansons écoutées en entier": "songs played all the way through",
    "œufs à la coque, minutés à la perfection": "soft-boiled eggs, timed to perfection",
    "trajets Paris – Lyon en TGV": "train rides from Paris to Lyon",
    "cycles de lave-linge": "washing machine cycles",
    "records du monde du marathon": "marathon world records",
    "parcourus si vous aviez marché plutôt qu'attendu": "covered had you walked instead of waited",
    "de papier déroulé, à vue de nez": "of paper unrolled, at a rough guess",
    "Certificat officiel": "Official certificate",
    "Certificat de visite": "Certificate of visit",
    "Certificat WC Connect": "WC Connect certificate",
    "Une image à faire circuler auprès de gens qui ne l'ont pas demandée.":
        "An image to pass around to people who never asked for it.",
    "Préparer le certificat": "Prepare the certificate",
    "Partager le certificat": "Share the certificate",
    "Rétrospective": "Year in review",
    "Ma rétrospective": "My year in review",
    "Rétrospective WC Connect": "WC Connect year in review",
    "Votre année sur le trône, résumée en une image. Personne ne vous l'a demandée.":
        "Your year on the throne, in one image. Nobody asked for it.",
    "Préparer la rétrospective": "Prepare the review",
    "Partager la rétrospective": "Share the review",
    "Dernier haut fait": "Latest achievement",
    "Sa Majesté": "His Majesty",
    "Le trône vous attend, Majesté": "The throne awaits, Your Majesty",

    # --- Siri et raccourcis ---
    "Démarrer une visite": "Start a visit",
    "Lance le chronomètre WC Connect et affiche la Live Activity.":
        "Starts the WC Connect timer and shows the Live Activity.",
    "Chronomètre lancé. Bonne visite !": "Timer started. Enjoy your visit!",
    "Chronomètre lancé.": "Timer started.",
    "Arrête le chronomètre et enregistre la visite dans l'historique.":
        "Stops the timer and records the visit in your history.",
    "Aucune visite en cours.": "No visit in progress.",
    "Démarrer ou terminer une visite": "Start or finish a visit",
    "Lance le chronomètre s'il est à l'arrêt, l'arrête sinon.":
        "Starts the timer if it is stopped, stops it otherwise.",
    "Noter une visite": "Log a visit",
    "Ajoute une visite à l'historique sans lancer le chronomètre.":
        "Adds a visit to your history without starting the timer.",

    # --- Chaînes à trous ---
    "%@ s": "%@ s",
    "%@ min %@ s": "%@ min %@ s",
    "%@ h %@ min": "%@ hr %@ min",
    "%@ h": "%@:00",
    "%@ m": "%@ m",
    "%@ %@": "%@ %@",
    "%@ sur 5": "%@ out of 5",
    "%@ heures": "%@ o'clock",
    "%@ visite": "%@ visit",
    "%@ visites": "%@ visits",
    "visite aujourd'hui": "visit today",
    "visites aujourd'hui": "visits today",
    "%@ visite aujourd'hui": "%@ visit today",
    "%@ visites aujourd'hui": "%@ visits today",
    "%@ au total": "%@ in total",
    "%@ haut fait sur %@": "%@ achievement out of %@",
    "%@ hauts faits sur %@": "%@ achievements out of %@",
    "Cycle %@ sur %@": "Cycle %@ of %@",
    "Moyenne %@": "Average %@",
    "Sans apnée, %@": "No breath hold, %@",
    "Sa Majesté siège · %@": "His Majesty is seated · %@",
    "WC · %@": "WC · %@",
    "WC · %@ aujourd'hui": "WC · %@ today",
    "Visite enregistrée : %@.": "Visit recorded: %@.",
    "Visite de %@ min enregistrée.": "%@-minute visit recorded.",
    "Prochaine visite prévue vers %@ — fiabilité %@ %%":
        "Next visit expected around %@ — %@ %% confidence",
    "Délivré par WC Connect le %@. Sans aucune valeur.":
        "Issued by WC Connect on %@. Of no value whatsoever.",
    "Vous avez passé %@ sur le trône. C'est un début.":
        "You have spent %@ on the throne. It's a start.",
    "Vous avez passé %.1f heures sur le trône. Un bon film, quoi.":
        "You have spent %.1f hours on the throne. A decent film, then.",
    "Vous avez passé %.1f jours entiers sur le trône. Assumez.":
        "You have spent %.1f full days on the throne. Own it.",
    "À ce rythme, votre vie entière y passera moins d'une journée. Suspect.":
        "At this rate, your whole life will amount to less than a day. Suspicious.",
    "À ce rythme, vous y passerez %.0f jours sur cinquante ans.":
        "At this rate, you will spend %.0f days on it over fifty years.",
    "À ce rythme, vous y passerez %.1f mois de votre vie. Assis.":
        "At this rate, you will spend %.1f months of your life on it. Sitting.",
    "Vous expédiez l'affaire en %@, surtout vers %@. Efficace, presque suspect.":
        "You get it done in %@, mostly around %@. Efficient, almost suspicious.",
    "%@ en moyenne, avec une préférence marquée pour %@. Une horloge.":
        "%@ on average, with a marked preference for %@. A clock.",
    "%@ en moyenne : vous ne venez pas seulement pour la fonction, mais aussi pour la réflexion. Surtout vers %@.":
        "%@ on average: you come not only for the function, but for the thinking. Mostly around %@.",
})

TRANSLATIONS.update({
    # --- Hauts faits secrets, rang suprême ---
    "Le Coup de minuit": "The Stroke of Midnight",
    "Une visite dans les cinq premières minutes d'un jour nouveau.":
        "A visit within the first five minutes of a new day.",
    "Réveillon": "New Year's Eve",
    "Une visite le 31 décembre ou le 1er janvier. Bonne année.":
        "A visit on 31 December or 1 January. Happy new year.",
    "3,14": "3.14",
    "Une visite de 3 minutes et 14 secondes. Au hasard, évidemment.":
        "A visit of exactly 3 minutes and 14 seconds. By chance, obviously.",
    "Triplé": "Hat-trick",
    "Trois visites en moins d'une heure. Tout va bien ?":
        "Three visits in under an hour. Everything all right?",
    "Jour sans fin": "Groundhog Day",
    "Deux visites de durée rigoureusement identique, à la seconde.":
        "Two visits of rigorously identical duration, to the second.",
    "Secret": "Secret",
    "À découvrir par accident.": "To be discovered by accident.",
    "Divinité des latrines": "Deity of the Latrines",

    # --- Haïku ---
    "Haïku de la visite": "Haiku of the visit",
    "Composé d'après la durée, l'heure et le lieu. Personne ne l'avait demandé.":
        "Composed from the duration, the hour and the place. Nobody asked for it.",
    "Le carrelage froid": "The cold tiled floor",
    "La porte se referme": "The door swings shut again",
    "Un souffle retenu": "A held-in breath waits",
    "Lumière blafarde": "Wan and pallid light",
    "Le silence s'installe": "Silence settles in for good",
    "Loin du bruit du monde": "Far from the world's noise",
    "l'affaire est réglée en un souffle": "the matter is settled in a breath",
    "le devoir accompli sans attendre": "duty discharged without waiting",
    "une parenthèse à peine ouverte": "a parenthesis barely opened",
    "le temps s'étire paisiblement": "time stretches out peacefully here",
    "les minutes coulent sans hâte": "the minutes flow without hurry",
    "un moment volé à la journée": "a moment stolen from the day",
    "le temps semble avoir renoncé": "time itself appears to have given up",
    "les civilisations s'effondrent": "whole civilisations rise and fall",
    "on médite sur le sens des choses": "one ponders the meaning of things",
    "la journée peut commencer": "the day may now begin",
    "le café attendra": "the coffee will wait",
    "l'aube est complice": "dawn is an accomplice",
    "le déjeuner refroidit": "lunch is going cold",
    "la pause s'achève": "the break is ending",
    "midi sonne ailleurs": "noon rings elsewhere",
    "le travail patiente": "the work can wait",
    "l'après-midi s'allonge": "the afternoon drags",
    "personne n'a remarqué": "nobody noticed a thing",
    "la nuit tombe dehors": "night falls outside",
    "le canapé appelle": "the sofa is calling",
    "le jour se referme": "the day folds itself shut",
    "les étoiles témoignent": "the stars bear witness",
    "nul ne saura jamais": "no one will ever know",
    "la lune est discrète": "the moon is discreet",

    # --- Couverture sonore et abstinence ---
    "Couverture sonore": "Sound cover",
    "Couper la couverture": "Stop the cover",
    "Dernière visite il y a moins d'une heure. Le rythme est soutenu.":
        "Last visit less than an hour ago. Brisk pace.",
    "Vous tenez depuis %@. Rien d'anormal.": "You have held out for %@. Nothing unusual.",
    "Vous tenez depuis %@. Le corps travaille en silence.":
        "You have held out for %@. The body is working quietly.",
    "Vous tenez depuis %@. Buvez un verre d'eau et marchez un peu.":
        "You have held out for %@. Drink a glass of water and walk a little.",
    "Vous tenez depuis %@. Au-delà de trois jours, un avis médical vaut mieux qu'un haut fait.":
        "You have held out for %@. Beyond three days, medical advice beats an achievement.",

    # --- Widget météo ---
    "Météo intestinale": "Gut forecast",
    "Le bulletin du jour, calculé sur votre semaine.":
        "Today's bulletin, computed from your week.",
})

TRANSLATIONS.update({
    # --- Journal des symptômes (échelle de Bristol) ---
    "Journal": "Journal",
    "Consistance": "Consistency",
    "Non renseignée": "Not recorded",
    "Type %@": "Type %@",
    "Billes dures et séparées": "Hard, separate lumps",
    "En saucisse, grumeleuse": "Sausage-shaped, lumpy",
    "En saucisse, avec des craquelures": "Sausage-shaped, with cracks",
    "En saucisse, lisse et souple": "Sausage-shaped, smooth and soft",
    "Morceaux mous aux bords nets": "Soft blobs with clear edges",
    "Morceaux floconneux, bords déchiquetés": "Fluffy pieces, ragged edges",
    "Entièrement liquide": "Entirely liquid",
    "Tendance constipation": "Constipation tendency",
    "Dans la norme": "Within the norm",
    "Tendance diarrhée": "Diarrhoea tendency",
    "Effort": "Effort",
    "Effort important": "Considerable effort",
    "Effort moyen : %@/5": "Average effort: %@/5",
    "Symptômes notés": "Symptoms recorded",
    "Symptôme à signaler": "Symptom worth reporting",
    "Ballonnements": "Bloating",
    "Crampes": "Cramps",
    "Urgence": "Urgency",
    "Sensation incomplète": "Incomplete feeling",
    "Présence de sang": "Blood present",
    "L'échelle de Bristol est la classification usuelle de la consistance. Ces notes servent à suivre une évolution, et à la montrer à un professionnel si besoin.":
        "The Bristol scale is the usual classification for consistency. These notes are there to track a trend, and to show it to a professional if needed.",
    "Du sang dans les selles justifie un avis médical, même une seule fois. Ce n'est pas une urgence en soi, mais ça se regarde.":
        "Blood in your stool warrants medical advice, even just once. It is not an emergency in itself, but it should be looked at.",
    "Un symptôme noté justifie un avis médical. L'app ne diagnostique rien : montrez ce journal à un professionnel.":
        "One recorded symptom warrants medical advice. The app diagnoses nothing: show this journal to a professional.",

    # --- Rappels d'hydratation ---
    "Hydratation": "Hydration",
    "Rappels d'hydratation": "Hydration reminders",
    "Un verre d'eau ?": "A glass of water?",
    "L'eau est ce qui rend les fibres efficaces. Deux minutes, et c'est fait.":
        "Water is what makes fibre work. Two minutes, and it is done.",

    # --- Objectif de la semaine ---
    "Objectif de la semaine": "Goal for the week",
    "Objectif tenu : %@ jours sur %@, et des visites courtes.":
        "Goal met: %@ days out of %@, with short visits.",
    "Régularité tenue, mais les visites s'allongent : %@ en moyenne.":
        "Regularity holding, but visits are getting longer: %@ on average.",
    "%@ jours sur %@ cette semaine. Continuez.":
        "%@ days out of %@ this week. Keep going.",

    # --- Export vers Santé ---
    "Santé": "Health",
    "Exporter les symptômes vers Santé": "Export symptoms to Health",

    # --- Carte de défi ---
    "Défi": "Challenge",
    "Défi WC Connect": "WC Connect Challenge",
    "Défier quelqu'un": "Challenge someone",
    "Préparer le défi": "Prepare the challenge",
    "Envoyer le défi": "Send the challenge",
    "Battez ça. Sans serveur pour arbitrer, il faudra se croire sur parole.":
        "Beat that. With no server to referee, you will have to take each other's word for it.",
    "Une carte à envoyer à qui vous voudrez. Aucun serveur, aucun classement : juste une image et votre parole.":
        "A card to send to whoever you like. No server, no leaderboard: just an image and your word.",

    # --- Réglages : hydratation, objectif, Santé ---
    "%@ j": "%@ d",
    "Rappels par jour : %@": "Reminders per day: %@",
    "À partir de %@": "From %@",
    "Jusqu'à %@": "Until %@",
    "Rappels prévus à %@. Tout est programmé localement.":
        "Reminders set for %@. Everything is scheduled locally.",
    "Boire régulièrement est le conseil le plus déterminant, et le plus facile à oublier.":
        "Drinking regularly is the most decisive piece of advice, and the easiest to forget.",
    "Jours avec visite : %@ sur 7": "Days with a visit: %@ out of 7",
    "Durée moyenne visée : %@ min": "Target average duration: %@ min",
    "Un objectif modeste : de la régularité, et des visites qui ne s'éternisent pas. L'avancement s'affiche dans les statistiques.":
        "A modest goal: regularity, and visits that do not drag on. Progress shows up in the statistics.",
    "Seuls les symptômes digestifs sont déposés dans Santé : constipation, diarrhée, ballonnements, crampes. Jamais l'historique complet.":
        "Only digestive symptoms are written to Health: constipation, diarrhoea, bloating, cramps. Never the full history.",
    "L'app Santé n'est pas disponible sur cet appareil.":
        "The Health app is not available on this device.",
})


def escape(texte: str) -> str:
    return texte.replace("\\", "\\\\").replace('"', '\\"')


def cles_du_code(racine: pathlib.Path) -> set[str]:
    """Clés effectivement utilisées dans les sources Swift."""
    cles: set[str] = set()
    motifs = [
        r'"((?:[^"\\]|\\.)*?)"\.wcLocalized',
        r'Text\("((?:[^"\\]|\\.)+)"\)',
        r'Label\("((?:[^"\\]|\\.)+)"',
        r'navigationTitle\("((?:[^"\\]|\\.)+)"\)',
        r'Button\("((?:[^"\\]|\\.)+)"',
        r'Picker\("((?:[^"\\]|\\.)+)"',
        r'Section\("((?:[^"\\]|\\.)+)"\)',
        r'Toggle\("((?:[^"\\]|\\.)+)"',
        r'LabeledContent\("((?:[^"\\]|\\.)+)"',
        r'accessibilityLabel\("((?:[^"\\]|\\.)+)"\)',
        r'title: LocalizedStringResource = "((?:[^"\\]|\\.)+)"',
        r'IntentDescription\("((?:[^"\\]|\\.)+)"\)',
        r'\.result\(dialog: "((?:[^"\\]|\\.)+)"\)',
        r'SharePreview\("((?:[^"\\]|\\.)+)"',
        r'TextField\("((?:[^"\\]|\\.)+)"',
    ]
    for chemin in racine.rglob("*.swift"):
        src = chemin.read_text()
        for motif in motifs:
            for m in re.finditer(motif, src):
                texte = m.group(1)
                if len(texte) < 2:
                    continue
                if re.fullmatch(r"[a-z0-9._-]+", texte):
                    continue
                if "\\(" in texte:
                    continue
                cles.add(texte)
    return cles


def ecrire(chemin: pathlib.Path, paires) -> None:
    chemin.parent.mkdir(parents=True, exist_ok=True)
    lignes = [
        "/* WC Connect — table de traduction.",
        "   Générée par Support/Tools/localize.py : n'éditez pas à la main,",
        "   modifiez TRANSLATIONS puis relancez le script. */",
        "",
    ]
    for cle, valeur in sorted(paires):
        lignes.append(f'"{escape(cle)}" = "{escape(valeur)}";')
    chemin.write_text("\n".join(lignes) + "\n")
    print(f"écrit {chemin} ({len(paires)} entrées)")


if __name__ == "__main__":
    racine = pathlib.Path(__file__).resolve().parents[2]
    sources = racine / "Sources"
    localisation = racine / "Support/Localization"

    utilisees = cles_du_code(sources)
    manquantes = sorted(utilisees - set(TRANSLATIONS))
    inutiles = sorted(set(TRANSLATIONS) - utilisees)

    for cle in manquantes:
        print(f"MANQUANTE : {cle}")
    # Informatif : certaines clés passent par des tableaux ou des motifs que
    # l'extraction ne couvre pas (map(\\.wcLocalized), @Parameter, axes de
    # graphique). Une clé en trop est inoffensive ; une clé manquante non.
    for cle in inutiles:
        print(f"clé non détectée dans le code (peut-être normal) : {cle}")

    if "--check" in sys.argv:
        sys.exit(1 if manquantes else 0)

    ecrire(localisation / "fr.lproj/Localizable.strings", [(c, c) for c in TRANSLATIONS])
    ecrire(localisation / "en.lproj/Localizable.strings", list(TRANSLATIONS.items()))

    if manquantes:
        print(f"\n{len(manquantes)} clé(s) sans traduction : complétez TRANSLATIONS.")
        sys.exit(1)
    print("\ntoutes les clés du code sont traduites.")
