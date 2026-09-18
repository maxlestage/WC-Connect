// Contrôle du panneau du menu sur téléphone.
//
// Le bouton d'appel s'est retrouvé sous la barre d'outils de Safari : le
// panneau était borné par `100vh`, qui sur iOS mesure l'écran *sans* les barres
// du navigateur. Signalé par le propriétaire, capture à l'appui. En prime, dix
// liens en une seule colonne le repoussaient hors de l'écran.
//
// Les hauteurs ci-dessous sont les hauteurs *visibles* d'un téléphone sous
// Safari, barres déduites : c'est ce que `100dvh` vaut sur l'appareil.
//
// Usage : node website/scripts/check-menu.mjs [url]
import { chromium } from "playwright";

const url = process.argv[2] ?? process.env.SITE_CHECK_URL ?? "http://localhost:4173/";

const appareils = [
  { nom: "iPhone SE", width: 375, height: 545 },
  { nom: "iPhone 14", width: 390, height: 650 },
  { nom: "iPhone Max", width: 430, height: 720 },
  { nom: "petit écran", width: 320, height: 480 },
];

const navigateur = await chromium.launch();
let echecs = 0;

for (const { nom, width, height } of appareils) {
  for (const locale of ["fr-FR", "en-US"]) {
    const contexte = await navigateur.newContext({
      viewport: { width, height },
      locale,
      isMobile: true,
      hasTouch: true,
      reducedMotion: "reduce",
    });
    const page = await contexte.newPage();
    await page.goto(url, { waitUntil: "networkidle" });

    const burger = page.locator(".burger");
    if (!(await burger.isVisible())) {
      echecs += 1;
      console.error(`ÉCHEC ${nom} ${locale} : pas de bouton burger à cette taille`);
      await contexte.close();
      continue;
    }

    await burger.click();
    await page.waitForTimeout(300);

    const m = await page.evaluate(() => {
      const panneau = document.querySelector(".menu");
      const bouton = document.querySelector(".menu__cta");
      if (!panneau || !bouton) return null;
      const boite = (el) => {
        const b = el.getBoundingClientRect();
        return { haut: b.top, bas: b.bottom };
      };
      return {
        panneau: boite(panneau),
        bouton: boite(bouton),
        liens: document.querySelectorAll(".menu__links a").length,
        hauteurVue: window.innerHeight,
      };
    });

    if (!m) {
      echecs += 1;
      console.error(`ÉCHEC ${nom} ${locale} : panneau ou bouton introuvable`);
      await contexte.close();
      continue;
    }

    const etiquette = `${nom} ${width}×${height} ${locale}`;

    // 1. Le panneau ne dépasse pas la hauteur visible : c'est ce qui faisait
    //    passer son bas sous la barre du navigateur.
    if (m.panneau.bas > m.hauteurVue + 1) {
      echecs += 1;
      console.error(
        `ÉCHEC ${etiquette} : le panneau descend à ${Math.round(m.panneau.bas)} px ` +
          `pour ${m.hauteurVue} px visibles`,
      );
    }

    // 2. Le bouton d'appel est visible sans avoir à défiler dans le panneau.
    if (m.bouton.bas > m.hauteurVue + 1 || m.bouton.haut < 0) {
      echecs += 1;
      console.error(
        `ÉCHEC ${etiquette} : le bouton d'appel est hors de l'écran ` +
          `(${Math.round(m.bouton.haut)}–${Math.round(m.bouton.bas)} pour ${m.hauteurVue} px)`,
      );
    } else if (m.panneau.bas <= m.hauteurVue + 1) {
      console.log(`ok ${etiquette} — ${m.liens} liens, bouton à ${Math.round(m.bouton.haut)} px`);
    }

    await contexte.close();
  }
}

await navigateur.close();

if (echecs > 0) {
  console.error(`\n${echecs} défaut(s) dans le panneau du menu.`);
  process.exit(1);
}
console.log("\nMenu conforme : panneau dans l'écran, bouton d'appel atteignable.");
