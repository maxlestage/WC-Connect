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
| **Site** | `website/`, React 18 + TypeScript (Vite), servi par Express, déployable sur Heroku |

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

Application **React 18 + TypeScript** (Vite) servie par un petit serveur
**Express** écrit lui aussi en TypeScript, prête à être déployée sur **Heroku**.

```
package.json          racine de l'espace de travail npm (workspaces)
Procfile              web: node website/server-dist/server.js
website/
  index.html          point d'entrée Vite
  src/                composants React, hooks, contenu typé, styles
  server/server.ts    serveur Express (fichiers statiques + repli SPA)
  tsconfig*.json      client, configuration Vite et serveur
```

### En local

```bash
npm install            # à la racine du dépôt (workspaces npm)
npm run dev            # serveur de développement Vite, http://localhost:5173
npm run typecheck      # TypeScript strict, client et configuration
npm run build          # dist/ (client) + server-dist/ (serveur)
npm start              # sert le build sur http://localhost:3000
```

### Déploiement sur Heroku

Le dépôt est un espace de travail npm : le buildpack Node officiel suffit, sans
configuration supplémentaire.

```bash
heroku create mon-app-wc-connect
heroku buildpacks:set heroku/nodejs
git push heroku HEAD:main
heroku open
```

À la construction, Heroku exécute `npm ci` puis `heroku-postbuild`
(`npm run build --workspace website`), qui produit le client dans
`website/dist/` et le serveur dans `website/server-dist/`. Le `Procfile` lance
ensuite `node website/server-dist/server.js`, qui écoute sur `$PORT`.

Le serveur sert les fichiers versionnés de `dist/assets` en cache long, renvoie
`index.html` pour toute autre route et expose `/healthz` pour les sondes de
disponibilité.

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
