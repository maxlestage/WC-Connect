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
app.json                     manifeste du bouton « Deploy to Heroku »
.github/workflows/site.yml   construction du site vérifiée à chaque commit
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

### Déploiement sur Heroku depuis un téléphone (sans ordinateur)

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/maxlestage/WC-Connect)

Tout se fait dans le navigateur du téléphone, sans ligne de commande :

1. **Appuyez sur le bouton ci-dessus.** Heroku lit `app.json` à la racine du
   dépôt et prépare l'application tout seul.
2. **Connectez-vous à Heroku** (ou créez un compte). Heroku n'a plus d'offre
   gratuite : il faut une carte et un dyno Eco, environ 5 $ par mois pour
   toutes vos applications.
3. **Choisissez un nom** d'application et une région, puis **Deploy app**.
   La construction dure une à deux minutes.
4. **View** ouvre le site. C'est fini.

### Redéployer à chaque modification, toujours depuis le téléphone

Dans le tableau de bord Heroku : **votre app → Deploy → Deployment method →
GitHub → Connect to GitHub**, choisissez le dépôt `WC-Connect` et la branche,
puis **Enable Automatic Deploys**. Chaque commit poussé sur cette branche
redéploie le site tout seul.

À partir de là, le cycle complet tient dans le téléphone : vous demandez une
modification à Claude Code depuis l'application mobile, le commit part sur
GitHub, GitHub Actions vérifie que le site se construit (pastille verte ou
rouge sur le commit, visible dans l'app GitHub), et Heroku met le site en ligne.

En cas de souci, les journaux se lisent aussi depuis le navigateur :
**votre app → More → View logs**.

### Variante gratuite : Render, aussi depuis le téléphone

Render lit `render.yaml` (offre gratuite, sonde sur `/healthz`, déploiement
automatique à chaque commit) :

1. Ouvrez [dashboard.render.com](https://dashboard.render.com) depuis le
   téléphone, puis **New → Blueprint**.
2. Connectez le dépôt `WC-Connect` et choisissez la branche.
3. **Apply** : Render construit et met le site en ligne, puis redéploie à
   chaque commit.

### Et en ligne de commande, si un ordinateur repasse par là

```bash
heroku create mon-app-wc-connect
heroku buildpacks:set heroku/nodejs
git push heroku HEAD:main
heroku open
```

### Ce que fait Heroku à la construction

`npm ci` à la racine, puis `heroku-postbuild`
(`npm run build --workspace website`), qui produit le client dans
`website/dist/` et le serveur dans `website/server-dist/`. Heroku retire
ensuite les dépendances de développement (Vite, TypeScript) — le serveur n'a
besoin que d'Express et de `compression`. Le `Procfile` lance
`node website/server-dist/server.js`, qui écoute sur `$PORT`.

Le serveur sert les fichiers versionnés de `dist/assets` en cache long, renvoie
`index.html` pour toute autre route et expose `/healthz` pour les sondes de
disponibilité.

### Aperçus de partage

Les balises Open Graph exigent des URL absolues, alors que le domaine n'est
connu qu'au déploiement : le serveur remplace le marqueur `__SITE_URL__` de
`index.html` par l'origine réellement servie (en tenant compte du proxy
d'Heroku ou de Render). Un en-tête `Host` invraisemblable est ignoré, et la
variable d'environnement `SITE_URL` permet de forcer l'origine si vous
utilisez un nom de domaine personnalisé.

L'image de partage `website/public/social-card.png` (1200 × 630) est produite
à partir du gabarit `website/scripts/social-card.html` :

```bash
npx playwright screenshot --viewport-size=1200,630 \
  website/scripts/social-card.html website/public/social-card.png
```

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
