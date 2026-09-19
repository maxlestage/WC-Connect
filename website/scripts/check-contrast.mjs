// Contrôle du contraste des textes, dans les deux thèmes et les deux langues.
//
// Le seuil retenu est celui de WCAG AA : 4,5:1 pour un texte courant, 3:1 pour
// un grand texte (24 px, ou 18,7 px en gras). Les teintes vives de la charte
// conviennent à un aplat ou à un trait mais tombent sous le seuil dès qu'on
// écrit avec : d'où les jetons `--accent-ink`, `--mint-ink`, `--amber-ink` et
// la paire `--btn-bg` / `--btn-ink`, qui existent précisément pour le texte.
//
// Les éléments posés sur un dégradé ou une image sont écartés : leur fond n'est
// pas calculable de façon fiable, et une fausse alerte userait le contrôle.
//
// Usage : node website/scripts/check-contrast.mjs [url]
import { chromium } from "playwright";

const url = process.argv[2] ?? process.env.SITE_CHECK_URL ?? "http://localhost:4173/";

const sonde = () => {
  // Chromium renvoie soit `rgb(0-255)`, soit `color(srgb 0-1)` — notamment
  // pour tout ce qui vient de `color-mix()`. Les deux doivent être lus, sans
  // quoi du noir sur blanc se mesure à 1,2:1.
  const parse = (s) => {
    const n = (s.match(/-?[\d.]+(?:e-?\d+)?/g) || []).map(Number);
    if (n.length < 3) return null;
    const echelle = s.startsWith("color(") ? 255 : 1;
    return [n[0] * echelle, n[1] * echelle, n[2] * echelle, n.length > 3 ? n[3] : 1];
  };
  const luminance = (c) => {
    const v = c.slice(0, 3).map((x) => {
      const s = x / 255;
      return s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
    });
    return 0.2126 * v[0] + 0.7152 * v[1] + 0.0722 * v[2];
  };
  const melange = (avant, arriere, a) => avant.slice(0, 3).map((x, i) => x * a + arriere[i] * (1 - a));

  /** Fond effectif : on empile les couches translucides jusqu'à une opaque. */
  const fond = (el) => {
    let n = el;
    const pile = [];
    while (n && n !== document.documentElement) {
      const s = getComputedStyle(n);
      if (s.backgroundImage !== "none") return { image: true };
      const c = parse(s.backgroundColor);
      if (c && c[3] > 0) {
        pile.push(c);
        if (c[3] >= 1) break;
      }
      n = n.parentElement;
    }
    let res = parse(getComputedStyle(document.body).backgroundColor);
    res = res ? res.slice(0, 3) : [255, 255, 255];
    for (let i = pile.length - 1; i >= 0; i--) res = melange(pile[i], res, pile[i][3]);
    return { couleur: res };
  };

  const trouves = [];
  for (const el of document.querySelectorAll("body *")) {
    const aDuTexte = [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim().length > 1);
    if (!aDuTexte) continue;
    const s = getComputedStyle(el);
    const r = el.getBoundingClientRect();
    if (r.width < 2 || r.height < 2) continue;
    if (s.visibility === "hidden" || parseFloat(s.opacity) < 0.15) continue;
    // Masqué visuellement mais lu par les lecteurs d'écran : hors sujet.
    if (el.closest(".skip-link")) continue;

    const f = fond(el);
    if (f.image) continue;
    const devant = parse(s.color);
    if (!devant) continue;
    const couleur = devant[3] < 1 ? melange(devant, f.couleur, devant[3]) : devant.slice(0, 3);
    if (couleur.some(Number.isNaN) || f.couleur.some(Number.isNaN)) continue;

    const l1 = luminance(couleur);
    const l2 = luminance(f.couleur);
    const rapport = (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);
    const taille = parseFloat(s.fontSize);
    const grand = taille >= 24 || (taille >= 18.66 && parseInt(s.fontWeight, 10) >= 700);
    const seuil = grand ? 3 : 4.5;

    if (rapport < seuil) {
      trouves.push({
        classe: (typeof el.className === "string" ? el.className : "").split(" ")[0] || el.tagName.toLowerCase(),
        rapport: Math.round(rapport * 100) / 100,
        seuil,
        taille: Math.round(taille),
        texte: el.textContent.trim().slice(0, 40),
      });
    }
  }
  return trouves;
};

const navigateur = await chromium.launch();
let echecs = 0;

for (const colorScheme of ["light", "dark"]) {
  for (const locale of ["fr-FR", "en-US"]) {
    const contexte = await navigateur.newContext({
      viewport: { width: 1280, height: 900 },
      locale,
      colorScheme,
      reducedMotion: "reduce",
    });
    const page = await contexte.newPage();
    await page.goto(url, { waitUntil: "networkidle" });
    await page.waitForTimeout(400);

    const trouves = await page.evaluate(sonde);
    const uniques = [...new Map(trouves.map((t) => [t.classe + t.rapport, t])).values()];

    if (uniques.length === 0) {
      console.log(`ok ${colorScheme} / ${locale}`);
    } else {
      echecs += uniques.length;
      console.error(`ÉCHEC ${colorScheme} / ${locale} : ${uniques.length} texte(s) sous le seuil`);
      for (const t of uniques) {
        console.error(`   ${t.rapport}:1 (seuil ${t.seuil}) ${t.taille}px .${t.classe} — « ${t.texte} »`);
      }
    }
    await contexte.close();
  }
}

await navigateur.close();

if (echecs > 0) {
  console.error(`\n${echecs} texte(s) sous le seuil de contraste AA.`);
  process.exit(1);
}
console.log("\nTous les textes mesurables tiennent le seuil AA.");
