# WC Connect

Suivi (sérieusement codé, gentiment absurde) de vos passages aux toilettes :
une app iPhone avec **Live Activity**, une app **Apple Watch** autonome, des
widgets et complications, et un site de présentation statique.

Tout reste sur l'appareil : pas de compte, pas de serveur, pas de réseau.

| | |
|---|---|
| **App iOS** | SwiftUI, iOS 17+, chronomètre, historique, statistiques, export CSV |
| **Live Activity** | ActivityKit : écran verrouillé, Dynamic Island, bouton « Terminer » interactif |
| **Apple Watch** | watchOS 10+, app native autonome + complications, synchronisation WatchConnectivity |
| **Widgets** | Écran d'accueil et écran verrouillé, bouton interactif (App Intents) |
| **Aide & détente** | Conseils quand ça coince, respiration guidée, signaux qui doivent envoyer consulter |
| **Son** | Quatre ambiances embarquées qui se mélangent à votre musique, et commande de la musique du système |
| **Palmarès** | 19 hauts faits dont 5 secrets, équivalences absurdes, titre honorifique, certificat et haïku |
| **Météo intestinale** | Bulletin calculé sur la semaine, profil, prévision de la prochaine visite |
| **Siri** | « Je vais aux toilettes », « I'm going to the bathroom » et leurs variantes |
| **Site** | `website/`, React 18 + TypeScript (Vite), **bilingue**, servi par Heroku ou par n'importe quel hébergeur de fichiers |

## Structure du dépôt

```
app/
  project.yml                  spec XcodeGen (génère WCConnect.xcodeproj)
  Sources/
    Shared/Core/               modèles, store, persistance, Live Activity, App Intents
    Shared/Sync/               synchronisation iPhone <-> Watch (WatchConnectivity)
    iOS/                       app iPhone (SwiftUI)
    Widgets/                   extension widgets + Live Activity
    Watch/                     app Apple Watch
    WatchWidgets/              complications de la montre
  Support/                     Info.plist, entitlements, catalogues d'assets, icône
  Tests/WCConnectTests/        tests unitaires de la logique (sans app hôte)
website/
  index.html                 point d'entrée Vite
  src/                       app React + TypeScript (composants, hooks, styles)
  server.js                  serveur de fichiers sans dépendance (statique + repli SPA)
  scripts/                   contrôles Playwright (débordement, aperçus de partage)
package.json, Procfile       espace de travail npm et démarrage Heroku
app.json                     manifeste du bouton « Deploy to Heroku »
.github/workflows/site.yml   construction du site vérifiée à chaque commit
```

### Aide quand ça coince

- `TipLibrary` — 18 conseils classés (posture, respiration, détente, habitudes,
  boire et manger, bouger). Ceux marqués `isImmediate` s'appliquent assis :
  surélever les pieds, se pencher vers l'avant, ne pas bloquer sa respiration.
- Après quelques minutes de visite (au plus quatre), l'écran principal propose
  trois de ces gestes, la respiration guidée et une ambiance sonore. La carte se
  masque d'un geste.
- `TipLibrary.redFlags` — sang dans les selles, douleur intense, vomissements,
  constipation qui dure : la liste est affichée dans l'app avec, en pied de
  page, le rappel que **WC Connect n'est pas un dispositif médical**.
- `BreathingPattern` — trois rythmes (ventre 4-6 sans apnée, carré 4-4-4-4,
  détente 4-7-8). La logique est purement calculée (`state(at:)`) et testée ;
  l'interface anime un cercle, la montre ajoute un tapotement par phase. Le
  rythme conseillé pendant une visite est sans apnée, parce que retenir son
  souffle revient à pousser.

### Journal, objectifs et Santé

- `Bristol` — l'**échelle de Bristol** (types 1 à 7) avec le détail de chaque
  type et la tendance associée (constipation, norme, diarrhée). Proposée en fin
  de visite, jamais obligatoire.
- `Symptom` — six symptômes en un geste : ballonnements, crampes, urgence,
  sensation incomplète, effort important, présence de sang. Seul le dernier
  porte `needsAdvice` : il déclenche, dans la feuille de fin de visite, un
  renvoi vers un avis médical — pas un verdict.
- `ToiletSession` gagne `bristol`, `effort` et `symptoms`. Ces champs sont
  **facultatifs** : les historiques enregistrés avant le journal se décodent
  sans perte (`JournalTests` le vérifie).
- `StatsEngine` agrège la répartition par type de Bristol, le compte par
  symptôme et l'effort moyen. La carte **Journal** des statistiques les affiche,
  et signale les types hors norme.
- `WeeklyGoal` / `GoalEngine` — un **objectif de la semaine** modeste : un
  nombre de jours actifs sur sept et une durée moyenne à ne pas dépasser.
  `GoalProgress` en tire un avancement et un résumé en une phrase. Réglable
  dans les réglages, persisté dans l'espace partagé.
- `HydrationSchedule` / `HydrationReminders` — de 2 à 8 **rappels de boire** par
  jour, répartis dans le créneau choisi, programmés en local
  (`UNCalendarNotificationTrigger`). Le calcul des heures est pur, donc testé ;
  la reprogrammation efface d'abord les anciens rappels pour ne pas les
  accumuler.
- `HealthExport` — **export facultatif vers Santé** : la tendance Bristol
  devient un échantillon `constipation` ou `diarrhea`, les symptômes des
  échantillons `bloating` et `abdominalCramps`. L'app demande l'écriture
  seulement : elle n'accède à aucune donnée de santé existante.
- L'export CSV porte les nouvelles colonnes : `confort,bristol,effort,symptomes`.

### Son et musique

- `SoundscapePlayer` lit en boucle trois ambiances embarquées (pluie, bruit
  brun, souffle) avec une session audio en `mixWithOthers` : elles se
  superposent à votre musique au lieu de la couper. L'audio en arrière-plan est
  déclaré, donc l'ambiance survit au verrouillage de l'écran.
- `MusicRemote` pilote la musique du système (`MPMusicPlayerController`) :
  lecture, pause, morceau suivant ou précédent, et affichage du titre en cours
  si vous autorisez l'accès à la bibliothèque. L'app ne diffuse aucun
  catalogue — elle télécommande le vôtre.
- Les boucles sont **synthétisées**, donc libres de droits. Pour les
  régénérer :

  ```bash
  python3 app/Support/Tools/make_soundscapes.py
  ```

### Inutile, donc indispensable

- `HaikuEngine` — un **haïku** composé à la fin de chaque visite : trois vers
  choisis d'après la durée, l'heure et le lieu, avec l'identifiant de la visite
  pour graine. Le même passage donne toujours le même poème. Trente vers,
  traduits.
- **Cinq hauts faits secrets** (`isSecret`) dont l'intitulé reste masqué avant
  déblocage : coup de minuit, réveillon, 3 min 14 s pile, trois visites en une
  heure, deux durées rigoureusement identiques.
- **Couverture sonore** : un geste lance l'ambiance « Réunion » à plein volume
  depuis l'écran principal.
- **Widget Météo** sur l'écran d'accueil et l'écran verrouillé.
- `AbsurdStats.abstinence` — le temps écoulé depuis la dernière visite,
  commenté. Au-delà de trois jours, l'app renvoie vers un avis médical plutôt
  que vers une plaisanterie.
- `AchievementEngine` — 19 hauts faits calculés sur l'historique (« Éclair »
  sous 45 secondes, « Marathonien » au-delà de vingt minutes, « Horloge
  suisse » pour trois jours de suite à la même heure, « Globe-trotteur » pour
  les trois lieux le même jour…). Calculs purs, couverts par les tests.
- `AchievementEngine.rank(unlockedCount:)` — titre honorifique, d'« Anonyme des
  toilettes » à « Légende vivante ».
- `AbsurdStats` — le temps total converti en épisodes de série, chansons, œufs
  à la coque, trajets Paris–Lyon, cycles de lave-linge, records du monde du
  marathon, kilomètres à pied et mètres de papier.
- Écran **Palmarès** (accessible depuis les statistiques) avec un certificat
  rendu par `ImageRenderer` et partageable via `ShareLink`.
- **Mode trône** : un appui long sur le chronomètre couronne la visite en cours.
  C'est tout ce que ça fait.
- Ambiance **Réunion** : brouhaha de bureau et frappes de clavier, synthétisés
  comme les autres, à lancer depuis les toilettes du travail.
- `ForecastEngine` — **météo intestinale** : la semaine écoulée comparée à la
  précédente donne une condition (Grand beau, Variable, Perturbé, Tempête),
  une pression en hectopascals, un risque d'averse, une visibilité et un vent.
  Plus une prévision de la prochaine visite, avec une fiabilité honnêtement
  basse. Affichée en tête des statistiques.
- `PersonaEngine` — **profil** déduit du créneau dominant et de la durée
  moyenne : du « Sprinteur du matin » à « L'Ermite de la nuit », quinze
  combinaisons possibles.
- `AbsurdStats.lifetimeSentence` — projection du rythme actuel sur cinquante
  ans, en mois passés assis.
- **Rétrospective** partageable, façon bilan de fin d'année, rendue en image
  comme le certificat.
- **Fanfare et bandeau** au déblocage d'un haut fait : `fanfare.wav` est
  synthétisée par le même script que les ambiances.
- **Carte de défi** partageable : votre rang, vos visites, votre moyenne et
  votre série, rendus en image. Aucun serveur, aucun classement — il faudra se
  croire sur parole.

### Bilingue

L'app s'affiche en **français ou en anglais**, selon la langue de l'appareil.

- Le **français sert de clé** : les vues SwiftUI cherchent déjà leurs littéraux
  dans la table `Localizable`, et `String.wcLocalized` fait de même pour les
  chaînes calculées (titres de modèles, conseils, hauts faits, bulletin météo).
- Les tables vivent dans `Support/Localization/<langue>.lproj/` et sont
  embarquées dans les quatre cibles applicatives : `Bundle.main` diffère entre
  l'app, ses extensions et la montre.
- Elles sont générées depuis une correspondance unique :

  ```bash
  python3 app/Support/Tools/localize.py          # régénère les deux tables
  python3 app/Support/Tools/localize.py --check  # échoue si une clé n'est pas traduite
  ```

- `LocalizationTests` vérifie dans la CI que les deux tables ont les mêmes
  clés, qu'aucune traduction n'est vide, que la table française est bien
  l'identité, que les trous de format correspondent, et que chaque conseil,
  haut fait et signal d'alerte est traduit.
- Le séparateur décimal suit la langue de l'appareil, plutôt qu'une virgule
  imposée.

### Architecture en bref

- `ToiletSession` — une visite : début, fin, type, lieu, confort, note,
  appareil, et le journal facultatif (consistance, effort, symptômes).
- `SessionStorage` — instantané JSON (`SessionState`) dans le conteneur App Group,
  lisible sans `@MainActor` pour que les widgets s'en servent directement.
- `SessionStore` — source de vérité `@MainActor` de l'app ; écrit sur disque,
  pousse l'état vers la Watch et rafraîchit les widgets à chaque changement.
- `StatsEngine` — calculs purs (moyennes, série de jours, créneaux horaires,
  agrégats du journal), couverts par les tests.
- `GoalEngine` et `HydrationSchedule` — également purs, donc testables sans
  simulateur : ils vivent dans `Shared/Core`, seuls les effets de bord
  (notifications, HealthKit) restent dans `iOS/`.
- `LiveActivityController` — démarre, met à jour et clôt la Live Activity ;
  branché sur le store via le protocole `LiveActivityCoordinating`, ce qui garde
  le store compilable sur watchOS.
- `WatchSyncService` — `applicationContext` WatchConnectivity (dernier état
  connu) + message direct quand l'autre appareil est joignable ; la fusion
  privilégie toujours la version terminée d'une visite.

## Installation

Prérequis : **Xcode 15+**, iOS 17 / watchOS 10, et
[XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```bash
cd app
xcodegen generate       # écrit WCConnect.xcodeproj à partir de project.yml
open WCConnect.xcodeproj
```

Dans Xcode :

1. Sélectionnez votre équipe de signature pour les cinq cibles
   (`WCConnect`, `WCConnectWidgets`, `WCConnectWatch`, `WCConnectWatchWidgets`,
   `WCConnectTests`), ou renseignez `DEVELOPMENT_TEAM` dans `project.yml`.
2. Les identifiants sont préfixés `com.wcconnect.` — remplacez-les par les vôtres
   si vous voulez installer sur un appareil.
3. L'App Group `group.com.wcconnect.shared` doit être activé sur les quatre
   cibles applicatives (les fichiers `.entitlements` sont déjà en place) ;
   adaptez-le si vous changez de préfixe.
4. Lancez le schéma `WCConnect` sur un iPhone, puis le schéma `WCConnectWatch`
   sur la montre appairée.

Les tests unitaires (`⌘U` sur le schéma `WCConnect`) compilent les sources
partagées directement : ils n'ont besoin ni d'application hôte ni de simulateur
particulier.

> Sans XcodeGen, un projet Xcode créé à la main fonctionne aussi : créez les
> cibles listées ci-dessus et ajoutez-leur les mêmes dossiers de sources,
> `Info.plist` et entitlements que dans `project.yml`.

### Régénérer l'icône

```bash
python3 app/Support/Tools/make_icon.py
```

## Site de présentation

Application **React 18 + TypeScript** construite par **Vite** en fichiers
statiques, servie par `website/server.js` — un serveur Node **sans aucune
dépendance** (uniquement des modules intégrés), ce qui permet le déploiement sur
Heroku. Les fichiers construits se posent aussi tels quels sur un simple
hébergeur de fichiers, sans Node à l'exécution.

```
package.json          racine de l'espace de travail npm (workspaces)
website/
  index.html          point d'entrée Vite
  src/i18n/           dictionnaires fr.ts et en.ts, contexte de langue
  src/components/     sections et maquettes
  src/hooks/          chronomètre de démo, respiration, apparitions
  tsconfig*.json      client et configuration Vite
  dist/               résultat de la construction (non versionné)
```

### Bilingue

Le site s'affiche en **français ou en anglais**. La langue est déduite du
navigateur, modifiable par le bouton FR/EN de la barre de navigation, et
mémorisée. `document.documentElement.lang` et le titre de la page suivent.

`src/i18n/fr.ts` est la source de vérité : le type `Dictionary` en est déduit,
donc `en.ts` doit couvrir exactement les mêmes clés — une traduction oubliée
fait échouer la vérification des types, donc la CI.

### En local

```bash
npm install            # à la racine du dépôt (workspaces npm)
npm run dev            # serveur de développement Vite, http://localhost:5173
npm run typecheck      # TypeScript strict
npm run build          # écrit website/dist/
npm run preview        # relit le dossier construit
```

### Deux variables de construction

| Variable | Rôle |
|---|---|
| `VITE_BASE` | sous-chemin de publication : `/WC-Connect/` sur GitHub Pages, `/` sur un domaine dédié |
| `VITE_SITE_URL` | origine publique, injectée dans les balises Open Graph — elles exigent des URL absolues, et sans serveur c'est à la construction que ça se décide |

### Publication

Le site se construit en fichiers statiques. Deux façons de les servir, au
choix, sans rien changer au code.

#### Heroku

```bash
heroku create mon-app-wc-connect
heroku buildpacks:set heroku/nodejs
git push heroku HEAD:main
heroku open
```

Ou, depuis un téléphone, le bouton en tête de ce chapitre.

Heroku exécute `npm ci`, puis `heroku-postbuild` (la construction du site), et
lance `node website/server.js` — **un serveur de fichiers sans aucune
dépendance**, écrit avec les seuls modules intégrés de Node. Il sert
`website/dist`, met les fichiers versionnés en cache long, compresse le texte,
expose `/healthz`, et complète les balises de partage avec l'origine
réellement servie : Heroku attribue son domaine après la construction, donc
rien ne peut être figé avant.

La variable `SITE_URL` permet de forcer cette origine si vous branchez un
domaine personnalisé.

#### Hébergement de fichiers

`website/dist` se dépose tel quel, sans serveur :

| Hébergeur | Dépôt privé | Coût |
|---|---|---|
| GitHub Pages (workflow `pages.yml` inclus) | non, demande une offre payante | gratuit |
| Cloudflare Pages / Netlify | oui | gratuit |
| Render (`render.yaml`, statique) | oui | gratuit |

Construisez alors avec `VITE_SITE_URL` renseigné, pour que les URL de partage
soient absolues — il n'y a aucun serveur pour les calculer à la volée.

### Aperçus de partage

L'image `website/public/social-card.png` (1200 × 630) est produite à partir du
gabarit `website/scripts/social-card.html` :

```bash
npx playwright screenshot --viewport-size=1200,630 \
  website/scripts/social-card.html website/public/social-card.png
```

Les balises Open Graph contiennent un marqueur `__SITE_URL__` :

- `VITE_SITE_URL` renseigné à la construction — Vite le remplace, la page est
  autonome et convient à un hébergement de fichiers ;
- variable absente — le marqueur reste, et `website/server.js` le remplace à
  chaque requête par l'origine servie. C'est ce qui permet à Heroku de
  fonctionner sans connaître son domaine à l'avance.

La CI vérifie les deux chemins : page construite avec origine figée, puis
serveur Node interrogé derrière un proxy simulé.

## Vie privée

L'historique est stocké dans un fichier JSON du conteneur App Group partagé
entre l'app, ses extensions et la montre. La synchronisation iPhone ↔ Watch
utilise WatchConnectivity, d'appareil à appareil. Aucune requête réseau n'est
effectuée par l'app, et un export CSV permet de tout récupérer.

Deux autorisations sont demandées, et seulement si vous activez la fonction
correspondante : les **notifications**, pour les rappels d'hydratation
programmés localement, et l'**écriture dans Santé**, pour y déposer les
symptômes notés. L'app ne demande aucune autorisation de lecture dans Santé.

## Pistes d'évolution

- Rétrospective mensuelle, sur le modèle du bilan annuel
- Graphique d'évolution de la consistance sur plusieurs semaines
- Widget dédié à l'objectif de la semaine
- Verrouillage de l'historique par Face ID

## Crédits

Conçu et développé par **Maxime Nathan Lestage**.

---

Projet indépendant, non affilié à Apple. iPhone, Apple Watch, Siri et Dynamic
Island sont des marques d'Apple Inc.
