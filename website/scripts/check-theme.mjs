// Contrôle de cohérence du thème sombre.
//
// Le sombre est défini deux fois dans styles.css : sous la requête de média
// (mode automatique) et sous le sélecteur `[data-theme="dark"]` (choix
// explicite). Une requête de média et un sélecteur ne se combinent pas en CSS,
// d'où la duplication — mais si les deux blocs divergent, le thème choisi et le
// thème hérité de l'appareil ne se ressemblent plus. Ce script vérifie qu'ils
// déclarent exactement la même chose.
import { readFile } from "node:fs/promises";

const chemin = new URL("../src/styles.css", import.meta.url);
const css = await readFile(chemin, "utf8");

/** Déclarations d'un bloc, repéré par son sélecteur, normalisées. */
function declarations(selecteur) {
  const debut = css.indexOf(selecteur);
  if (debut === -1) return null;
  const ouvrante = css.indexOf("{", debut);
  const fermante = css.indexOf("}", ouvrante);
  if (ouvrante === -1 || fermante === -1) return null;
  return css
    .slice(ouvrante + 1, fermante)
    .split(";")
    .map((ligne) => ligne.trim())
    .filter((ligne) => ligne.startsWith("--"))
    .sort();
}

const automatique = declarations(':root:not([data-theme="light"])');
const explicite = declarations(':root[data-theme="dark"]');

if (!automatique || !explicite) {
  console.error("bloc de thème sombre introuvable dans styles.css");
  process.exit(1);
}

if (automatique.length === 0) {
  console.error("le bloc automatique ne déclare aucune variable");
  process.exit(1);
}

const manquantes = automatique.filter((ligne) => !explicite.includes(ligne));
const surnumeraires = explicite.filter((ligne) => !automatique.includes(ligne));

if (manquantes.length > 0 || surnumeraires.length > 0) {
  console.error("les deux définitions du thème sombre ont divergé :");
  for (const ligne of manquantes) console.error(`  absente du choix explicite : ${ligne}`);
  for (const ligne of surnumeraires) console.error(`  absente du mode automatique : ${ligne}`);
  process.exit(1);
}

console.log(`thème sombre cohérent : ${automatique.length} variables identiques dans les deux blocs.`);
