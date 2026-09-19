// Serveur de fichiers pour Heroku, sans aucune dépendance : seuls les modules
// intégrés de Node sont utilisés. Le site reste par ailleurs un dossier de
// fichiers, déposable tel quel sur un hébergement statique.
import { createReadStream, existsSync, readFileSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, join, normalize, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { createGzip } from "node:zlib";

const racine = resolve(fileURLToPath(new URL("./dist", import.meta.url)));
const accueil = join(racine, "index.html");
const port = Number(process.env.PORT ?? 3000);

if (!existsSync(accueil)) {
  console.error(`Build introuvable dans ${racine}. Lancez « npm run build » d'abord.`);
  process.exit(1);
}

const TYPES = new Map(
  Object.entries({
    ".html": "text/html; charset=utf-8",
    ".js": "text/javascript; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".svg": "image/svg+xml",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".webp": "image/webp",
    ".ico": "image/x-icon",
    ".woff2": "font/woff2",
    ".txt": "text/plain; charset=utf-8",
    ".webmanifest": "application/manifest+json; charset=utf-8",
    ".map": "application/json; charset=utf-8",
  }),
);

/** Les types texte gagnent à être compressés ; les images déjà compressées non. */
const COMPRESSIBLES = new Set([".html", ".js", ".css", ".json", ".svg", ".txt", ".map", ".webmanifest"]);

const gabaritAccueil = readFileSync(accueil, "utf8");

/**
 * Les balises Open Graph exigent des URL absolues, inconnues à la construction
 * quand l'hébergeur attribue le domaine. Si le marqueur est encore là, il est
 * remplacé par l'origine réellement servie.
 */
function pageAccueil(requete) {
  if (!gabaritAccueil.includes("__SITE_URL__")) return gabaritAccueil;
  return gabaritAccueil.replaceAll("__SITE_URL__", origine(requete));
}

function origine(requete) {
  const forcee = (process.env.SITE_URL ?? "").trim().replace(/\/+$/, "");
  if (/^https?:\/\/[\w.-]+(:\d+)?$/.test(forcee)) return forcee;

  const hote = requete.headers.host ?? "";
  // L'en-tête Host vient du client : on n'y réinjecte que des noms plausibles.
  if (!/^[A-Za-z0-9.-]+(:\d{1,5})?$/.test(hote) || hote.length > 253) return "";

  const protocole = String(requete.headers["x-forwarded-proto"] ?? "")
    .split(",")[0]
    .trim();
  return `${protocole === "https" ? "https" : "http"}://${hote}`;
}

/** Chemin demandé, ramené dans le dossier publié. */
function cheminDemande(cheminUrl) {
  try {
    return decodeURIComponent(cheminUrl.split("?")[0] ?? "/");
  } catch {
    return "/";
  }
}

/** Fichier correspondant au chemin, ou null s'il n'existe pas. */
function fichierPour(chemin) {
  const candidat = resolve(join(racine, normalize(chemin)));
  // Aucune sortie du dossier publié.
  if (candidat !== racine && !candidat.startsWith(racine + sep)) return null;
  if (!existsSync(candidat) || !statSync(candidat).isFile()) return null;
  return candidat;
}

function envoie(requete, reponse, statut, type, corps, cache) {
  const entetes = { "Content-Type": type, "Cache-Control": cache, "X-Content-Type-Options": "nosniff" };
  const compresse =
    String(requete.headers["accept-encoding"] ?? "").includes("gzip") && corps.length > 1024;

  if (compresse) {
    entetes["Content-Encoding"] = "gzip";
    reponse.writeHead(statut, entetes);
    const gzip = createGzip();
    gzip.pipe(reponse);
    gzip.end(corps);
    return;
  }
  reponse.writeHead(statut, entetes);
  reponse.end(corps);
}

const serveur = createServer((requete, reponse) => {
  const url = requete.url ?? "/";

  if (requete.method !== "GET" && requete.method !== "HEAD") {
    reponse.writeHead(405, { Allow: "GET, HEAD" });
    reponse.end();
    return;
  }

  if (url === "/healthz") {
    envoie(requete, reponse, 200, "application/json; charset=utf-8", '{"status":"ok"}', "no-store");
    return;
  }

  const chemin = cheminDemande(url);
  const estAccueil = chemin === "/" || chemin === "/index.html";
  const fichier = estAccueil ? accueil : fichierPour(chemin);

  // Accueil, et repli des routes inconnues : index.html, complété à la volée.
  if (estAccueil || !fichier) {
    envoie(
      requete,
      reponse,
      estAccueil ? 200 : 404,
      "text/html; charset=utf-8",
      pageAccueil(requete),
      "no-cache",
    );
    return;
  }

  const extension = extname(fichier);
  const type = TYPES.get(extension) ?? "application/octet-stream";
  // Le service worker et le manifeste pilotent tout le reste : gardés en cache
  // par le navigateur, une mise à jour du site mettrait une heure à être vue.
  // Ils se revalident donc à chaque fois.
  const cache = /(?:^|[\\/])(?:sw\.js|manifest\.webmanifest)$/.test(chemin)
    ? "no-cache"
    // Les fichiers versionnés par Vite portent une empreinte : ils sont immuables.
    : fichier.includes(`${sep}assets${sep}`)
      ? "public, max-age=31536000, immutable"
      : "public, max-age=3600";

  if (COMPRESSIBLES.has(extension)) {
    envoie(requete, reponse, 200, type, readFileSync(fichier), cache);
    return;
  }

  reponse.writeHead(200, {
    "Content-Type": type,
    "Cache-Control": cache,
    "Content-Length": statSync(fichier).size,
    "X-Content-Type-Options": "nosniff",
  });
  createReadStream(fichier).pipe(reponse);
});

serveur.listen(port, () => {
  console.log(`WC Connect — site servi sur http://localhost:${port}`);
});
