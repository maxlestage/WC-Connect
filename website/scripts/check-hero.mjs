// Contrôle des maquettes d'appareils du hero, et de la page à texte agrandi.
//
// Trois défauts se sont succédé à cet endroit, tous invisibles sur un écran
// large et à taille de texte normale : la montre recouvrait la carte de la
// Live Activity, son cadran débordait de son boîtier, et le contenu des
// maquettes cassait dès que la taille de texte du téléphone grandissait. Ce
// script vérifie les trois, plus l'absence de débordement de la page, à
// plusieurs largeurs et à trois tailles de texte.
//
// Usage : node website/scripts/check-hero.mjs [url]
import { chromium } from "playwright";

const url = process.argv[2] ?? process.env.SITE_CHECK_URL ?? "http://localhost:4173/";
const largeurs = [320, 360, 375, 390, 414, 430, 540, 768, 900, 1024, 1280];
/** Tailles de police racine : le réglage « texte plus grand » d'un téléphone. */
const polices = [16, 20, 24];

const navigateur = await chromium.launch();
let echecs = 0;

function signaler(message) {
  echecs += 1;
  console.error(`ÉCHEC ${message}`);
}

for (const width of largeurs) {
  for (const police of polices) {
    const contexte = await navigateur.newContext({
      viewport: { width, height: 900 },
      locale: "fr-FR",
      isMobile: width < 900,
      hasTouch: width < 900,
      // Les blocs apparaissent au défilement : sans ça ils restent invisibles
      // et les mesures porteraient sur du vide.
      reducedMotion: "reduce",
    });
    const page = await contexte.newPage();
    // Émulation fidèle du réglage « texte plus grand » : c'est la taille de
    // police par défaut du navigateur qui change. Une surcharge CSS de `html`
    // n'agirait pas sur les unités `em` des requêtes de média, et laisserait
    // passer les défauts de bascule de la barre de navigation.
    const cdp = await contexte.newCDPSession(page);
    await cdp.send("Page.setFontSizes", { fontSizes: { standard: police, fixed: police } });
    await page.goto(url, { waitUntil: "networkidle" });
    await page.waitForTimeout(250);

    const mesure = await page.evaluate(() => {
      const boite = (sel) => {
        const el = document.querySelector(sel);
        if (!el) return null;
        const r = el.getBoundingClientRect();
        return { gauche: r.left, droite: r.right, haut: r.top, bas: r.bottom };
      };
      // Part de progression réellement affichée par l'anneau et par la barre :
      // elles décrivent la même visite et doivent donc concorder.
      const anneau = document.querySelector(".hero__devices .ring__value");
      const barre = document.querySelector(".hero__devices .bar span");
      const circonference = 2 * Math.PI * 50;
      const decalage = anneau ? parseFloat(getComputedStyle(anneau).strokeDashoffset) : NaN;
      const largeurBarre = barre ? parseFloat(getComputedStyle(barre).width) : NaN;
      const largeurPiste = barre ? parseFloat(getComputedStyle(barre.parentElement).width) : NaN;

      return {
        partAnneau: Number.isFinite(decalage) ? 1 - decalage / circonference : null,
        partBarre: Number.isFinite(largeurBarre) ? largeurBarre / largeurPiste : null,
        telephone: boite(".hero__devices .phone"),
        montre: boite(".hero__devices .watch"),
        cadran: boite(".hero__devices .ring"),
        bouton: boite(".hero__devices .watch__button"),
        carte: boite(".hero__devices .activity"),
        barre: boite(".hero__devices .activity--bar"),
        largeurPage: document.documentElement.scrollWidth,
      };
    });

    const etiquette = `${width}px / racine ${police}px`;
    const structurels = ["telephone", "montre", "cadran", "bouton", "carte", "barre"];
    const manquant = structurels.find((cle) => mesure[cle] === null);
    if (manquant) {
      signaler(`${etiquette} : élément introuvable (${manquant})`);
      await contexte.close();
      continue;
    }

    const { telephone, montre, cadran, bouton, carte, barre, largeurPage } = mesure;
    const marge = 1;

    // 0. L'anneau de la montre et la barre du téléphone décrivent la même
    //    visite : un écart signale une valeur figée quelque part.
    if (mesure.partAnneau === null || mesure.partBarre === null) {
      signaler(`${etiquette} : progression non mesurable (anneau ou barre absent)`);
    } else if (Math.abs(mesure.partAnneau - mesure.partBarre) > 0.03) {
      signaler(
        `${etiquette} : l'anneau affiche ${Math.round(mesure.partAnneau * 100)}% ` +
          `alors que la barre affiche ${Math.round(mesure.partBarre * 100)}%`,
      );
    }

    // 1. La montre ne recouvre ni la carte ni la barre de progression.
    for (const [nom, cible] of [["la carte", carte], ["la barre", barre]]) {
      const chevauche =
        montre.gauche < cible.droite - marge &&
        montre.droite > cible.gauche + marge &&
        montre.haut < cible.bas - marge &&
        montre.bas > cible.haut + marge;
      if (chevauche) {
        signaler(
          `${etiquette} : la montre recouvre ${nom} ` +
            `(montre ${Math.round(montre.gauche)}–${Math.round(montre.droite)}, ` +
            `${nom} ${Math.round(cible.gauche)}–${Math.round(cible.droite)})`,
        );
      }
    }

    // 2. Le contenu de la montre tient dans son boîtier.
    for (const [nom, cible] of [["le cadran", cadran], ["le bouton", bouton]]) {
      if (cible.bas > montre.bas + marge || cible.droite > montre.droite + marge || cible.gauche < montre.gauche - marge) {
        signaler(
          `${etiquette} : ${nom} déborde du boîtier ` +
            `(${nom} bas ${Math.round(cible.bas)}, montre bas ${Math.round(montre.bas)})`,
        );
      }
    }

    // 3. La carte de la Live Activity tient dans l'écran du téléphone.
    if (carte.droite > telephone.droite + marge || carte.gauche < telephone.gauche - marge) {
      signaler(`${etiquette} : la carte déborde du téléphone`);
    }

    // 4. Rien ne sort de la page.
    if (largeurPage > width + marge) {
      signaler(`${etiquette} : la page est large de ${largeurPage} px`);
    } else if (montre.droite > width + marge) {
      signaler(`${etiquette} : la montre sort de l'écran (droite ${Math.round(montre.droite)})`);
    } else {
      console.log(`ok ${String(width).padStart(4)}px / racine ${police}px`);
    }

    await contexte.close();
  }
}

await navigateur.close();

if (echecs > 0) {
  console.error(`\n${echecs} défaut(s) dans les maquettes du hero.`);
  process.exit(1);
}
console.log("\nMaquettes conformes : montre lisible, rien qui déborde.");
