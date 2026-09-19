// Contrôle de la publication sous un sous-chemin.
//
// Le site se publie soit à la racine d'un domaine, soit sous un sous-chemin
// (« /WC-Connect/ » sur GitHub Pages). Un chemin absolu oublié ne se voit pas
// du tout dans le premier cas et casse tout dans le second — c'est arrivé au
// lien du manifeste, que Vite ne préfixe pas : le site n'était plus
// installable une fois publié sous un sous-chemin.
//
// Ce script reconstruit le site sous une base d'essai, sans navigateur, et
// vérifie que tout ce qui est absolu tombe bien sous cette base. Il vérifie
// aussi que chaque fichier listé par le service worker existe réellement :
// `cache.addAll` échoue en bloc sur une seule entrée manquante, et un service
// worker qui n'installe pas ne dit rien.
//
// Usage : node website/scripts/check-souschemin.mjs
import { execFileSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const base = "/essai-sous-chemin/";
const site = fileURLToPath(new URL("..", import.meta.url));
const dossier = mkdtempSync(join(tmpdir(), "wc-base-"));

let echecs = 0;
function signaler(message) {
  echecs += 1;
  console.error(`ÉCHEC ${message}`);
}

try {
  execFileSync("npx", ["vite", "build", "--outDir", dossier, "--emptyOutDir"], {
    cwd: site,
    env: { ...process.env, VITE_BASE: base },
    stdio: "pipe",
  });

  const page = readFileSync(join(dossier, "index.html"), "utf8");

  // 1. Aucun chemin absolu de la page ne doit ignorer la base.
  for (const [, attribut, valeur] of page.matchAll(/\s(href|src)="([^"]+)"/g)) {
    if (!valeur.startsWith("/")) continue; // relatif, ou http(s), ou __SITE_URL__
    if (!valeur.startsWith(base)) {
      signaler(`index.html : ${attribut}="${valeur}" ignore la base « ${base} »`);
    }
  }

  // 2. Le manifeste décrit bien une app installée sous cette base.
  const manifeste = JSON.parse(readFileSync(join(dossier, "manifest.webmanifest"), "utf8"));
  for (const cle of ["start_url", "scope", "id"]) {
    if (manifeste[cle] !== base) {
      signaler(`manifeste : ${cle} vaut « ${manifeste[cle] ?? "(absent)"} »`);
    }
  }
  for (const icone of manifeste.icons ?? []) {
    if (!icone.src.startsWith(base)) signaler(`manifeste : icône « ${icone.src} » hors base`);
    const fichier = join(dossier, icone.src.slice(base.length));
    if (!existsSync(fichier)) signaler(`manifeste : icône « ${icone.src} » absente du dossier publié`);
  }

  // 3. Le service worker : base juste, et chaque entrée du cache existe.
  const sw = readFileSync(join(dossier, "sw.js"), "utf8");
  for (const marqueur of ["__CACHE__", "__BASE__", "__PRECACHE__"]) {
    if (sw.includes(marqueur)) signaler(`sw.js : marqueur ${marqueur} non remplacé`);
  }
  const accueil = (sw.match(/const ACCUEIL = "(.*?)"/) ?? [])[1];
  if (accueil !== base) signaler(`sw.js : ACCUEIL vaut « ${accueil ?? "(absent)"} »`);

  const liste = sw.match(/const AGARDER = (\[[\s\S]*?\]);/);
  if (!liste) {
    signaler("sw.js : liste des fichiers à garder introuvable");
  } else {
    const aGarder = JSON.parse(liste[1]);
    if (aGarder.length < 5) signaler(`sw.js : seulement ${aGarder.length} fichiers gardés`);
    for (const entree of aGarder) {
      if (!entree.startsWith(base)) {
        signaler(`sw.js : « ${entree} » hors base`);
        continue;
      }
      // La base seule, c'est la page d'accueil : elle est servie par index.html.
      const relatif = entree === base ? "index.html" : entree.slice(base.length);
      if (!existsSync(join(dossier, relatif))) {
        signaler(`sw.js : « ${entree} » n'existe pas dans le dossier publié`);
      }
    }
    if (echecs === 0) console.log(`ok   ${aGarder.length} fichiers gardés, tous présents`);
  }
} finally {
  rmSync(dossier, { recursive: true, force: true });
}

if (echecs > 0) {
  console.error(`\n${echecs} défaut(s) de publication sous sous-chemin.`);
  process.exit(1);
}
console.log(`\nPublication sous « ${base} » conforme : rien ne pointe à côté.`);
