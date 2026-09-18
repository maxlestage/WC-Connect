# WC Connect — consignes de travail

## Contexte du propriétaire

- **Pas d'ordinateur** : tout se pilote depuis un téléphone. Une étape qui
  exige un terminal n'est pas une solution livrable — proposez toujours un
  chemin faisable dans un navigateur mobile, et dites-le quand ce n'est pas
  possible (la compilation Swift, par exemple, demande un Mac).
- **Langue** : français partout — interface, commentaires, messages de commit,
  descriptions de PR, réponses.

## Fusion automatique

À la demande explicite du propriétaire (18 septembre 2026) : **quand une tâche
est terminée, fusionnez vous-même la pull request dans `master`** sans
redemander d'autorisation.

Conditions à respecter avant de fusionner :

1. la CI est verte sur le dernier commit (workflow `Site` et les autres
   vérifications de la PR) ;
2. la PR n'a pas de conflit ;
3. ce que vous livrez a été vérifié (types, construction, serveur qui répond).

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
website/   site de présentation React 18 + TypeScript (Vite) servi par Express
```

- Espace de travail npm à la racine : `npm install`, `npm run typecheck`,
  `npm run build`, `npm start`.
- Déploiement : bouton Heroku (dépôt public seulement), connexion GitHub
  authentifiée côté Heroku, ou blueprint Render (`render.yaml`, gratuit).
- Le workflow `.github/workflows/site.yml` rejoue la construction d'Heroku,
  démarre le serveur et vérifie `/healthz`, la carte de partage et les
  métadonnées absolues.

## Application iOS

- Aucun toolchain Swift/Xcode n'est disponible dans l'environnement de
  développement : **le code Swift n'est jamais compilé ici**. Dites-le
  explicitement à chaque livraison qui touche `app/`, plutôt que de laisser
  croire à une vérification.
- Les tests de `app/Tests/WCConnectTests` couvrent la logique pure et
  n'exigent pas d'application hôte.
