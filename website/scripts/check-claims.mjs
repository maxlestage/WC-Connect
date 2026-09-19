// Contrôle des chiffres annoncés par le site.
//
// Le site affirme des quantités — combien de hauts faits, d'ambiances, de
// rythmes de respiration. Ces quantités vivent dans le code Swift de l'app, et
// rien n'empêchait le site de rester sur un chiffre périmé : « 14 hauts faits »
// y est resté alors que l'app en comptait dix-neuf (quatorze annoncés, cinq
// secrets), ce qui se lisait comme un total.
//
// Ce script lit les vraies quantités dans `app/Sources/Shared/Core/`, puis
// vérifie que le texte réellement affiché par la section concernée les porte,
// en chiffres ou en toutes lettres, dans les deux langues. Une reformulation
// passe ; un chiffre périmé échoue.
//
// Usage : node website/scripts/check-claims.mjs [url]
import { readFile } from "node:fs/promises";
import { chromium } from "playwright";

const url = process.argv[2] ?? process.env.SITE_CHECK_URL ?? "http://localhost:4173/";
const racine = new URL("../../app/Sources/Shared/Core/", import.meta.url);

const lire = (nom) => readFile(new URL(nom, racine), "utf8");

/** Cas d'une énumération Swift, à un niveau d'indentation donné. */
function casEnum(source, nom) {
  const debut = source.indexOf(`enum ${nom}`);
  if (debut === -1) return [];
  const ouvrante = source.indexOf("{", debut);
  const fermante = source.indexOf("\n}", ouvrante);
  const corps = source.slice(ouvrante, fermante);
  return [...corps.matchAll(/^\s{4}case (\w+)/gm)].map((m) => m[1]);
}

const achievement = await lire("Achievement.swift");
const soundscape = await lire("Soundscape.swift");
const breathing = await lire("BreathingPattern.swift");

/** Éléments d'un tableau `static let all: [T] = [...]`. */
function listeAll(source) {
  const m = source.match(/static let all: \[[\w.]+\] = \[([^\]]*)\]/);
  return m ? m[1].split(",").map((e) => e.trim()).filter(Boolean) : [];
}

const hautsFaits = casEnum(achievement, "Achievement");
const blocSecret = achievement.slice(achievement.indexOf("var isSecret"));
const secrets = new Set(
  [...blocSecret.slice(0, blocSecret.indexOf("\n    }")).matchAll(/\.(\w+)/g)].map((m) => m[1]),
);

const quantites = {
  hautsFaits: hautsFaits.length,
  secrets: secrets.size,
  ambiances: casEnum(soundscape, "Soundscape").length,
  // `BreathingPattern` est une structure, pas une énumération : ses trois
  // rythmes sont listés dans `all`.
  rythmes: listeAll(breathing).length,
};

console.log("quantités lues dans l'app :", JSON.stringify(quantites));

const enLettres = {
  "fr-FR": ["zéro", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf",
    "dix", "onze", "douze", "treize", "quatorze", "quinze", "seize", "dix-sept", "dix-huit",
    "dix-neuf", "vingt"],
  "en-US": ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
    "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen",
    "eighteen", "nineteen", "twenty"],
};

const affirmations = [
  { section: "#palmares", quoi: "hauts faits", valeur: quantites.hautsFaits },
  { section: "#palmares", quoi: "hauts faits secrets", valeur: quantites.secrets },
  { section: "#son", quoi: "ambiances sonores", valeur: quantites.ambiances },
  { section: "#detente", quoi: "rythmes de respiration", valeur: quantites.rythmes },
];

const navigateur = await chromium.launch();
let echecs = 0;

for (const locale of ["fr-FR", "en-US"]) {
  const contexte = await navigateur.newContext({
    viewport: { width: 1280, height: 900 },
    locale,
    reducedMotion: "reduce",
  });
  const page = await contexte.newPage();
  await page.goto(url, { waitUntil: "networkidle" });

  for (const { section, quoi, valeur } of affirmations) {
    const texte = (await page.locator(section).innerText()).toLowerCase();
    const mot = enLettres[locale][valeur];
    const trouve = texte.includes(String(valeur)) || (mot && texte.includes(mot));
    if (trouve) {
      console.log(`ok ${locale} ${section} — ${valeur} ${quoi}`);
    } else {
      echecs += 1;
      console.error(
        `ÉCHEC ${locale} ${section} : l'app compte ${valeur} ${quoi}, ` +
          `mais la section ne dit ni « ${valeur} » ni « ${mot} »`,
      );
    }
  }
  await contexte.close();
}

await navigateur.close();

if (echecs > 0) {
  console.error(`\n${echecs} chiffre(s) périmé(s) sur le site.`);
  process.exit(1);
}
console.log("\nLes chiffres du site correspondent au code de l'app.");
