// Fabrique les icônes PNG de la PWA à partir du logo du site.
//
// Android et iOS veulent des PNG : un SVG suffit pour l'onglet, pas pour
// l'écran d'accueil. Plutôt que de garder des binaires dont personne ne sait
// d'où ils viennent, ce script les regénère à l'identique depuis le dessin du
// logo, avec le navigateur déjà installé pour les autres contrôles.
//
// Usage : node website/scripts/make-icons.mjs
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";

const sortie = new URL("../public/", import.meta.url);

/** Dessin du logo, à plat dans un carré de 512. */
function emblème({ pleinBord, echelle }) {
  const contenu = `
    <circle cx="256" cy="256" r="176" fill="none" stroke="#ffffff"
            stroke-opacity="0.55" stroke-width="24"/>
    <path transform="scale(8)"
          d="M32 17c5.6 6.4 9 11 9 15.2A9 9 0 0 1 23 32.2C23 28 26.4 23.4 32 17Z"
          fill="#ffffff"/>`;

  // Une icône « maskable » est rognée par le système : tout ce qui compte doit
  // tenir dans le disque central, d'où l'emblème réduit sur un fond débordant.
  const groupe =
    echelle === 1
      ? contenu
      : `<g transform="translate(256 256) scale(${echelle}) translate(-256 -256)">${contenu}</g>`;

  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#33a9f7"/>
      <stop offset="1" stop-color="#1c66c7"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" rx="${pleinBord ? 0 : 112}" fill="url(#g)"/>
  ${groupe}
</svg>`;
}

const icones = [
  { nom: "icon-192.png", taille: 192, svg: emblème({ pleinBord: false, echelle: 1 }) },
  { nom: "icon-512.png", taille: 512, svg: emblème({ pleinBord: false, echelle: 1 }) },
  // Rognable : fond jusqu'aux bords, emblème dans la zone sûre.
  { nom: "icon-maskable-512.png", taille: 512, svg: emblème({ pleinBord: true, echelle: 0.62 }) },
  // iOS arrondit lui-même : le carré doit être plein, et sans transparence.
  { nom: "apple-touch-icon.png", taille: 180, svg: emblème({ pleinBord: true, echelle: 1 }) },
];

const navigateur = await chromium.launch();
const page = await navigateur.newPage();

for (const { nom, taille, svg } of icones) {
  await page.setViewportSize({ width: taille, height: taille });
  await page.setContent(
    `<!doctype html><meta charset="utf-8">
     <style>html,body{margin:0;padding:0;background:transparent}
     svg{display:block;width:${taille}px;height:${taille}px}</style>${svg}`,
  );
  await page.screenshot({ path: fileURLToPath(new URL(nom, sortie)), omitBackground: true });
  console.log(`écrit public/${nom} (${taille}×${taille})`);
}

await navigateur.close();
