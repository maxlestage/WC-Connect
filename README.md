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
| **Palmarès** | 14 hauts faits, équivalences absurdes, titre honorifique et certificat partageable |
| **Météo intestinale** | Bulletin calculé sur la semaine, profil, prévision de la prochaine visite |
| **Siri** | « Je vais aux toilettes », « J'ai fini » via App Shortcuts |
| **Site** | `website/`, React 18 + TypeScript (Vite), **statique** et **bilingue** français / anglais |

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
  server/server.ts           serveur Express (statique + repli SPA)
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

- `AchievementEngine` — 14 hauts faits calculés sur l'historique (« Éclair »
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

### Architecture en bref

- `ToiletSession` — une visite : début, fin, type, lieu, confort, note, appareil.
- `SessionStorage` — instantané JSON (`SessionState`) dans le conteneur App Group,
  lisible sans `@MainActor` pour que les widgets s'en servent directement.
- `SessionStore` — source de vérité `@MainActor` de l'app ; écrit sur disque,
  pousse l'état vers la Watch et rafraîchit les widgets à chaque changement.
- `StatsEngine` — calculs purs (moyennes, série de jours, créneaux horaires),
  couverts par les tests.
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
statiques. Il n'y a **aucun serveur** : ni Node à l'exécution, ni conteneur, ni
dyno. Un hébergeur de fichiers suffit.

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

### Publication, depuis un téléphone et sans serveur

**GitHub Pages, automatique.** Le workflow `.github/workflows/pages.yml`
construit et publie à chaque commit sur `master`. Une seule chose à faire, une
fois, depuis le navigateur du téléphone : **Settings → Pages → Source →
GitHub Actions**. Le site vit ensuite sur
`https://<compte>.github.io/WC-Connect/` et se met à jour tout seul.

> GitHub Pages sur un dépôt privé demande une offre payante. Sur un dépôt
> privé et gratuit, préférez Cloudflare Pages ou Netlify ci-dessous.

**Cloudflare Pages ou Netlify.** Connectez le dépôt depuis leur interface
(dépôts privés acceptés, offres gratuites), avec :

- commande de construction : `npm ci && npm run build`
- dossier publié : `website/dist`
- variable `VITE_SITE_URL` : l'URL que l'hébergeur vous attribue

**Render.** `render.yaml` décrit déjà un site statique : *New → Blueprint*,
puis *Apply*.

Dans tous les cas, `website/dist` est un dossier de fichiers : il se dépose
tel quel sur n'importe quel hébergement, y compris à la main.

### Aperçus de partage

L'image `website/public/social-card.png` (1200 × 630) est produite à partir du
gabarit `website/scripts/social-card.html` :

```bash
npx playwright screenshot --viewport-size=1200,630 \
  website/scripts/social-card.html website/public/social-card.png
```

Les balises Open Graph contiennent un marqueur `__SITE_URL__` que Vite
remplace à la construction par `VITE_SITE_URL`. La CI vérifie qu'aucun
marqueur ne subsiste et que l'URL de l'image est bien absolue.

## Vie privée

L'historique est stocké dans un fichier JSON du conteneur App Group partagé
entre l'app, ses extensions et la montre. La synchronisation iPhone ↔ Watch
utilise WatchConnectivity, d'appareil à appareil. Aucune requête réseau n'est
effectuée par l'app, et un export CSV permet de tout récupérer.

## Pistes d'évolution

- Rappels de bonne hydratation (notifications locales)
- Export vers l'app Santé
- Objectifs et badges hebdomadaires
- Localisation anglaise (l'app est aujourd'hui en français)

---

Projet indépendant, non affilié à Apple. iPhone, Apple Watch, Siri et Dynamic
Island sont des marques d'Apple Inc.
