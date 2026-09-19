// Contrôle de l'installabilité et du fonctionnement hors ligne.
//
// Une PWA, ça ne se vérifie pas en lisant le manifeste : ça se vérifie en
// coupant le réseau. Ce script installe le service worker dans un vrai
// navigateur, passe le contexte hors ligne, recharge, et exige que la page
// s'affiche quand même. Il contrôle aussi que le manifeste est cohérent avec
// le sous-chemin de publication et que chacune de ses icônes existe — une
// icône manquante fait échouer l'installation sans rien dire.
//
// Ce script démarre et arrête lui-même son serveur, contrairement aux autres
// contrôles. C'est la seule façon de prouver le hors-ligne : couper le réseau
// depuis le navigateur ne suffit pas. `setOffline` de Playwright coupe les
// requêtes de la page, pas celles du service worker, qui continue donc de
// servir la page depuis le réseau — et le contrôle passait même après avoir
// retiré tout le mécanisme de secours. Éteindre le serveur, lui, ne se
// contourne pas.
//
// Usage : node website/scripts/check-pwa.mjs
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";

const port = Number(process.env.PORT_PWA ?? 4199);
const url = `http://localhost:${port}/`;
const base = "/";

const serveur = spawn(process.execPath, [fileURLToPath(new URL("../server.js", import.meta.url))], {
  env: { ...process.env, PORT: String(port) },
  stdio: "ignore",
});

async function attendreLeServeur() {
  for (let essai = 0; essai < 40; essai += 1) {
    try {
      const reponse = await fetch(`${url}healthz`);
      if (reponse.ok) return;
    } catch {
      // Pas encore prêt.
    }
    await new Promise((suite) => setTimeout(suite, 250));
  }
  throw new Error(`le serveur ne répond pas sur ${url}`);
}

let serveurEteint = false;

async function eteindreLeServeur() {
  // Un processus tué par signal garde `exitCode` à null : s'y fier ferait
  // attendre un second « exit » qui ne viendra jamais.
  if (serveurEteint) return;
  serveurEteint = true;
  const fini = new Promise((suite) => serveur.once("exit", suite));
  serveur.kill("SIGTERM");
  await fini;
  // Le port doit être réellement mort avant de conclure quoi que ce soit.
  for (let essai = 0; essai < 20; essai += 1) {
    try {
      await fetch(`${url}healthz`);
    } catch {
      return;
    }
    await new Promise((suite) => setTimeout(suite, 100));
  }
  throw new Error("le serveur répond encore après extinction");
}

await attendreLeServeur();

let echecs = 0;
function signaler(message) {
  echecs += 1;
  console.error(`ÉCHEC ${message}`);
}

const navigateur = await chromium.launch();

// --- 1. Le manifeste, ses valeurs et ses icônes ---
{
  const contexte = await navigateur.newContext({ baseURL: url });
  const page = await contexte.newPage();
  await page.goto(url, { waitUntil: "networkidle" });

  const lien = await page.getAttribute('link[rel="manifest"]', "href");
  if (!lien) {
    signaler("aucune balise <link rel=\"manifest\"> dans la page");
  } else {
    const reponse = await contexte.request.get(new URL(lien, url).href);
    if (!reponse.ok()) {
      signaler(`le manifeste répond ${reponse.status()}`);
    } else {
      const type = reponse.headers()["content-type"] ?? "";
      if (!type.includes("manifest+json") && !type.includes("application/json")) {
        signaler(`le manifeste est servi en « ${type} »`);
      }

      let manifeste;
      try {
        manifeste = JSON.parse(await reponse.text());
      } catch (erreur) {
        signaler(`le manifeste n'est pas du JSON valide : ${erreur.message}`);
      }

      if (manifeste) {
        // Un `start_url` ou un `scope` qui ignore le sous-chemin donne une
        // icône installée qui ouvre une page blanche : le défaut classique
        // d'une publication sous « /WC-Connect/ ».
        for (const cle of ["start_url", "scope"]) {
          if (manifeste[cle] !== base) {
            signaler(`manifeste : ${cle} vaut « ${manifeste[cle]} » au lieu de « ${base} »`);
          }
        }
        for (const cle of ["name", "short_name", "theme_color", "background_color"]) {
          if (!manifeste[cle]) signaler(`manifeste : ${cle} manquant`);
        }
        if (manifeste.display !== "standalone") {
          signaler(`manifeste : display vaut « ${manifeste.display} »`);
        }

        const icones = Array.isArray(manifeste.icons) ? manifeste.icons : [];
        const tailles = icones.map((i) => i.sizes);
        for (const attendue of ["192x192", "512x512"]) {
          if (!tailles.includes(attendue)) signaler(`manifeste : aucune icône ${attendue}`);
        }
        if (!icones.some((i) => String(i.purpose ?? "").includes("maskable"))) {
          signaler("manifeste : aucune icône « maskable » (Android rogne les autres)");
        }
        for (const icone of icones) {
          const rep = await contexte.request.get(new URL(icone.src, url).href);
          if (!rep.ok()) signaler(`icône ${icone.src} : ${rep.status()}`);
        }
      }
    }
  }

  // iOS ne lit pas le manifeste : sans cette balise, l'icône d'accueil est
  // une capture de la page.
  const pomme = await page.getAttribute('link[rel="apple-touch-icon"]', "href");
  if (!pomme) {
    signaler("aucune balise apple-touch-icon (iOS installerait une vignette de la page)");
  } else {
    const rep = await contexte.request.get(new URL(pomme, url).href);
    if (!rep.ok()) signaler(`apple-touch-icon ${pomme} : ${rep.status()}`);
  }

  if (echecs === 0) console.log("ok   manifeste, icônes et balises iOS");
  await contexte.close();
}

// --- 2. Hors ligne : la seule preuve qui compte ---
{
  const contexte = await navigateur.newContext();
  const page = await contexte.newPage();
  await page.goto(url, { waitUntil: "networkidle" });

  // Le service worker s'enregistre au chargement puis réclame la page.
  const controle = await page
    .waitForFunction(() => navigator.serviceWorker.controller !== null, null, { timeout: 15000 })
    .then(() => true)
    .catch(() => false);

  if (!controle) {
    signaler("le service worker ne prend pas la main sur la page en 15 s");
  } else {
    console.log("ok   service worker actif");

    // Sans cette ligne non plus, le contrôle ne prouverait rien : Chromium
    // ressert la page depuis son propre cache HTTP. Le vider laisse intacts
    // le service worker et son stockage — ce qu'on veut mettre à l'épreuve.
    const cdp = await contexte.newCDPSession(page);
    await cdp.send("Network.clearBrowserCache");

    await eteindreLeServeur();
    console.log("ok   serveur éteint");

    try {
      await page.reload({ waitUntil: "domcontentloaded" });
      // Le titre vient de React : s'il est là, ce n'est pas une page d'erreur.
      await page.waitForSelector(".hero h1", { timeout: 10000 });
      const titre = (await page.textContent(".hero h1")) ?? "";
      if (titre.trim().length === 0) {
        signaler("hors ligne : la page s'ouvre mais le titre est vide");
      } else {
        console.log(`ok   hors ligne : « ${titre.trim().replace(/\s+/g, " ")} »`);
      }

      // Les images aussi doivent venir du cache, sinon l'écran est troué.
      const logoCharge = await page.evaluate(() => {
        const img = document.querySelector(".brand img");
        return img instanceof HTMLImageElement ? img.complete && img.naturalWidth > 0 : false;
      });
      if (!logoCharge) signaler("hors ligne : le logo ne se charge pas");
    } catch (erreur) {
      signaler(`hors ligne : la page ne s'affiche pas (${erreur.message.split("\n")[0]})`);
    }
  }
  await contexte.close();
}

await navigateur.close();
await eteindreLeServeur();

if (echecs > 0) {
  console.error(`\n${echecs} défaut(s) d'installation ou de fonctionnement hors ligne.`);
  process.exit(1);
}
console.log("\nPWA conforme : installable, et consultable sans réseau.");
