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
| **Siri** | « Je vais aux toilettes », « J'ai fini » via App Shortcuts |
| **Site** | `website/`, HTML/CSS/JS statique, thème clair et sombre, sans dépendance |

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
website/                       site de présentation (index.html, styles.css, app.js)
```

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

Statique, aucune dépendance :

```bash
cd website
python3 -m http.server 8000     # puis http://localhost:8000
```

Déployable tel quel sur GitHub Pages, Netlify ou tout hébergement de fichiers.

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
