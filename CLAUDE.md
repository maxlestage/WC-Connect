# WC Connect — consignes de travail

## Contexte du propriétaire

- **Pas d'ordinateur** : tout se pilote depuis un téléphone. Une étape qui
  exige un terminal n'est pas une solution livrable — proposez toujours un
  chemin faisable dans un navigateur mobile, et dites-le quand ce n'est pas
  possible (la compilation Swift, par exemple, demande un Mac).
- **Langue de travail** : français partout — commentaires, messages de commit,
  descriptions de PR, réponses.
- **Produit bilingue** : l'app et le site existent en français et en anglais.
  Toute chaîne visible par l'utilisateur doit être ajoutée dans les deux
  langues. Côté site, `src/i18n/fr.ts` est la source de vérité et le type
  `Dictionary` force `en.ts` à la couvrir entièrement.

## Fusion automatique

À la demande explicite du propriétaire (18 septembre 2026) : **quand une tâche
est terminée, fusionnez vous-même la pull request dans `master`** sans
redemander d'autorisation.

Conditions à respecter avant de fusionner :

1. la CI est verte sur le dernier commit (workflow `Site` et les autres
   vérifications de la PR) ;
2. la PR n'a pas de conflit ;
3. ce que vous livrez a été vérifié (types, construction, contenu du dossier publié).

Si l'une des trois n'est pas remplie : réparez d'abord, ou dites clairement ce
qui bloque. Ne fusionnez jamais du rouge. Passez toujours par une PR — jamais
de commit poussé directement sur `master` — pour que la CI ait son mot à dire.

## Le projet n'est pas open source

- Le site **ne renvoie vers aucun dépôt** et ne présente rien comme ouvert :
  pas de « cloner le dépôt », pas de lien GitHub, pas de bouton de
  téléchargement tant que l'app n'est pas publiée.
- Aucune licence ouverte n'est ajoutée au dépôt.

## Le dépôt

```
app/       application iOS + watchOS (SwiftUI, XcodeGen, Live Activity)
website/   site de présentation React 18 + TypeScript (Vite), statique
```

- Espace de travail npm à la racine : `npm install`, `npm run typecheck`,
  `npm run build`, `npm run preview`.
- **Heroku est de nouveau la cible principale** : le propriétaire l'a demandé
  (18 septembre 2026, après avoir demandé le tout-statique plus tôt le même
  jour — cette consigne-ci l'emporte). `Procfile`, `app.json` et
  `website/server.js` doivent rester en place et fonctionnels.
- `website/server.js` n'a **aucune dépendance** : seuls les modules intégrés de
  Node. N'y ajoutez ni Express ni équivalent ; le site doit aussi rester
  déposable tel quel sur un hébergeur de fichiers.
- Publication : Heroku (`Procfile`), ou GitHub Pages par
  `.github/workflows/pages.yml`, Cloudflare Pages, Netlify, blueprint Render
  statique. Variables : `VITE_BASE`, `VITE_SITE_URL` à la construction, et
  `SITE_URL` côté serveur.
- `.github/workflows/site.yml` vérifie types, construction et contenu du
  dossier publié.
- `.github/workflows/app.yml` compile et teste le code Swift sur un runner
  macOS : c'est la seule vérification possible de `app/`.

## Application iOS

- Aucun toolchain Swift/Xcode n'est disponible dans l'environnement de
  développement : **le code Swift n'est jamais compilé ici**. Dites-le
  explicitement à chaque livraison qui touche `app/`, plutôt que de laisser
  croire à une vérification.
- Les tests de `app/Tests/WCConnectTests` couvrent la logique pure et
  n'exigent pas d'application hôte.
- **Traductions** : le français sert de clé. Toute chaîne visible ajoutée doit
  être traduite dans `app/Support/Tools/localize.py`, puis les tables
  régénérées (`python3 app/Support/Tools/localize.py`). Les chaînes calculées
  passent par `String.wcLocalized` ; les littéraux SwiftUI sont traduits
  automatiquement. `localize.py --check` et `LocalizationTests` échouent si une
  clé manque.
