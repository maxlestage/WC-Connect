/*
 * Service worker de WC Connect.
 *
 * Ce fichier est un gabarit : `vite.config.ts` y injecte, à la construction,
 * le sous-chemin de publication, la liste exacte des fichiers à garder, et un
 * nom de cache dérivé de cette liste. Un nom dérivé du contenu veut dire qu'un
 * site reconstruit à l'identique ne fait pas repartir le cache de zéro, et
 * qu'un site modifié en change forcément.
 *
 * Deux stratégies, et une seule raison de les distinguer : une page doit
 * pouvoir être mise à jour, un fichier au nom empreinté ne change jamais.
 *
 * - navigation → le réseau d'abord, le cache en secours. Hors ligne, la page
 *   gardée s'affiche ; en ligne, on voit toujours la dernière version.
 * - le reste → le cache d'abord. Les fichiers de `assets/` portent une
 *   empreinte dans leur nom : les garder indéfiniment est sans risque.
 */
const CACHE = "__CACHE__";
const ACCUEIL = "__BASE__";
const AGARDER = __PRECACHE__;

self.addEventListener("install", (evenement) => {
  evenement.waitUntil(
    caches
      .open(CACHE)
      .then((cache) => cache.addAll(AGARDER))
      // Sans ça, la version fraîche attendrait la fermeture de tous les
      // onglets : sur un téléphone, autant dire jamais.
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener("activate", (evenement) => {
  evenement.waitUntil(
    caches
      .keys()
      .then((noms) => Promise.all(noms.filter((nom) => nom !== CACHE).map((nom) => caches.delete(nom))))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener("fetch", (evenement) => {
  const requete = evenement.request;
  // Un service worker ne répond qu'aux lectures de sa propre origine : le
  // reste (autres domaines, envois de formulaire) passe sans être touché.
  if (requete.method !== "GET") return;
  if (new URL(requete.url).origin !== self.location.origin) return;

  evenement.respondWith(
    requete.mode === "navigate" ? reseauDAbord(requete) : cacheDAbord(requete),
  );
});

async function reseauDAbord(requete) {
  const cache = await caches.open(CACHE);
  try {
    const reponse = await fetch(requete);
    // Le serveur répond 404 avec la page d'accueil pour une route inconnue :
    // ne gardons que les vraies réussites, sinon on mémoriserait une erreur.
    if (reponse && reponse.ok) await cache.put(ACCUEIL, reponse.clone());
    return reponse;
  } catch (erreur) {
    const gardee = (await cache.match(ACCUEIL)) ?? (await cache.match(ACCUEIL + "index.html"));
    if (gardee) return gardee;
    throw erreur;
  }
}

async function cacheDAbord(requete) {
  const cache = await caches.open(CACHE);
  const gardee = await cache.match(requete);
  if (gardee) return gardee;

  const reponse = await fetch(requete);
  if (reponse && reponse.ok && reponse.type === "basic") {
    await cache.put(requete, reponse.clone());
  }
  return reponse;
}
