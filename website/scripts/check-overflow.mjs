// Contrôle de débordement horizontal.
//
// Un site qui se balade latéralement sur un téléphone est un défaut, pas une
// fantaisie : ce script échoue si la page est plus large que l'écran, à toutes
// les largeurs courantes et dans les deux langues.
//
// Usage : node website/scripts/check-overflow.mjs [url]
import { chromium } from "playwright";

const url = process.argv[2] ?? process.env.SITE_CHECK_URL ?? "http://localhost:4173/";
// Les largeurs autour de 960 px sont celles où la barre de navigation est
// la plus serrée (les liens réapparaissent) : c'est là que ça déborde.
const largeurs = [320, 360, 375, 390, 414, 430, 540, 768, 960, 961, 1000, 1024, 1100, 1280];
const langues = ["fr-FR", "en-US"];

const navigateur = await chromium.launch();
let echecs = 0;

for (const locale of langues) {
  for (const width of largeurs) {
    const contexte = await navigateur.newContext({
      viewport: { width, height: 780 },
      locale,
      deviceScaleFactor: 2,
      isMobile: width < 900,
      hasTouch: width < 900,
    });
    const page = await contexte.newPage();
    await page.goto(url, { waitUntil: "networkidle" });

    // Les sections apparaissent au défilement : il faut toutes les révéler,
    // sinon la mesure ignore la moitié de la page.
    await page.evaluate(async () => {
      for (let y = 0; y < document.body.scrollHeight; y += 500) {
        window.scrollTo(0, y);
        await new Promise((suite) => setTimeout(suite, 25));
      }
      window.scrollTo(0, 0);
    });
    await page.waitForTimeout(300);

    const mesurer = () => page.evaluate((cible) => {
      const coupables = [];
      for (const element of document.querySelectorAll("body *")) {
        const rect = element.getBoundingClientRect();
        if (rect.width === 0 && rect.height === 0) continue;
        if (rect.right > cible + 1) {
          const classe =
            typeof element.className === "string" && element.className
              ? "." + element.className.trim().split(/\s+/)[0]
              : "";
          coupables.push(`${element.tagName.toLowerCase()}${classe} (droite ${Math.round(rect.right)})`);
        }
      }
      return {
        innerWidth: window.innerWidth,
        scrollWidth: document.documentElement.scrollWidth,
        coupables: coupables.slice(0, 5),
      };
    }, width);

    const verifier = async (etat) => {
      const mesure = await mesurer();
      const conforme =
        mesure.scrollWidth <= width + 1 &&
        mesure.innerWidth === width &&
        mesure.coupables.length === 0;

      if (!conforme) {
        echecs += 1;
        console.error(
          `ÉCHEC ${locale} ${width}px ${etat} : innerWidth=${mesure.innerWidth} scrollWidth=${mesure.scrollWidth}` +
            (mesure.coupables.length ? ` — ${mesure.coupables.join(", ")}` : ""),
        );
      } else {
        console.log(`ok ${locale} ${String(width).padStart(4)}px ${etat}`);
      }
    };

    await verifier("menu fermé");

    // Le panneau du menu contient dix liens, le sélecteur de thème et la
    // bascule de langue : c'est un candidat au débordement à part entière, et
    // il faut l'ouvrir pour le mesurer.
    const burger = page.locator(".burger");
    if (await burger.isVisible()) {
      await burger.click();
      await page.waitForTimeout(250);
      await verifier("menu ouvert");
    }

    await contexte.close();
  }
}

await navigateur.close();

if (echecs > 0) {
  console.error(`\n${echecs} largeur(s) en débordement horizontal.`);
  process.exit(1);
}
console.log("\nAucun débordement horizontal.");
