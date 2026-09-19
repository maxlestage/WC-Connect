// Contrôle des maquettes d'appareils du hero, et de la page à texte agrandi.
//
// Trois défauts se sont succédé à cet endroit, tous invisibles sur un écran
// large et à taille de texte normale : la montre recouvrait la carte de la
// Live Activity, son cadran débordait de son boîtier, et le contenu des
// maquettes cassait dès que la taille de texte du téléphone grandissait. Ce
// script vérifie les trois, plus l'absence de débordement de la page, à
// plusieurs largeurs et à trois tailles de texte.
//
// Il vérifie aussi que le texte ne sort pas des maquettes — une boîte peut
// tenir pendant que son contenu déborde, et c'est arrivé — et, depuis que le
// propriétaire l'a demandé, que la première page ne compte rien : ni anneau de progression, ni barre qui se remplit, ni
// texte qui change avec le temps. Le chronomètre existe toujours dans l'app et
// se montre plus bas dans la page ; il n'a simplement plus à accueillir les
// visiteurs.
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
      // Aucun compteur ne doit revenir sur la première page : ni anneau de
      // progression, ni barre qui se remplit.
      const compteurs = document.querySelectorAll(
        ".hero__devices .ring__value, .hero__devices .bar",
      ).length;

      return {
        compteurs,
        telephone: boite(".hero__devices .phone"),
        montre: boite(".hero__devices .watch"),
        cadran: boite(".hero__devices .ring"),
        bouton: boite(".hero__devices .watch__button"),
        carte: boite(".hero__devices .activity"),
        barre: boite(".hero__devices .activity--night"),
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

    // 0. Rien ne compte sur la première page. C'est une demande explicite du
    //    propriétaire : un chronomètre en tête de page met la pression avant
    //    même d'avoir ouvert l'app. Le chronomètre existe toujours — il se
    //    montre plus bas, dans la section Live Activity.
    if (mesure.compteurs > 0) {
      signaler(
        `${etiquette} : ${mesure.compteurs} compteur(s) de progression dans le hero ` +
          `(anneau ou barre) — la première page ne doit rien mesurer`,
      );
    }

    // 1. La montre et le téléphone ne se chevauchent pas du tout. Ils se
    //    chevauchaient auparavant, et selon l'ordre de peinture le cadre du
    //    téléphone pouvait passer devant la montre : un écart supprime la
    //    question.
    if (montre.gauche < telephone.droite - marge) {
      signaler(
        `${etiquette} : la montre et le téléphone se chevauchent sur ` +
          `${Math.round(telephone.droite - montre.gauche)} px ` +
          `(téléphone jusqu'à ${Math.round(telephone.droite)}, montre dès ${Math.round(montre.gauche)})`,
      );
    }

    // 2. La montre ne recouvre ni la carte de la visite ni celle de la veilleuse.
    for (const [nom, cible] of [["la carte", carte], ["la veilleuse", barre]]) {
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

    // 3. Le contenu de la montre tient dans son boîtier.
    for (const [nom, cible] of [["le cadran", cadran], ["le bouton", bouton]]) {
      if (cible.bas > montre.bas + marge || cible.droite > montre.droite + marge || cible.gauche < montre.gauche - marge) {
        signaler(
          `${etiquette} : ${nom} déborde du boîtier ` +
            `(${nom} bas ${Math.round(cible.bas)}, montre bas ${Math.round(montre.bas)})`,
        );
      }
    }

    // 4. La carte de la Live Activity tient dans l'écran du téléphone.
    if (carte.droite > telephone.droite + marge || carte.gauche < telephone.gauche - marge) {
      signaler(`${etiquette} : la carte déborde du téléphone`);
    }

    // 5. Rien ne sort de la page.
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

// Contrôle du texte *à l'intérieur* des maquettes.
//
// Les contrôles ci-dessus mesurent des boîtes : le téléphone, la montre, le
// cadran, les cartes. Aucun ne regardait le texte à l'intérieur, et c'est
// exactement là qu'un défaut est passé : « Rien ne presse, rien ne compte »
// sortait de la carte de 34 px en français et de 61 px en anglais, à toutes
// les largeurs, parce que `.activity__meta` hérite de `white-space: nowrap`.
// Une boîte peut tenir pendant que son contenu déborde.
//
// Ici on mesure l'encre : l'étendue réelle de chaque nœud de texte, comparée
// à la zone de contenu du plus proche bloc qui le porte. Une première version
// la comparait à la carte entière — et ne voyait rien, parce que le texte
// fautif débordait de son bloc en restant dans la carte, sous la pastille.
{
  const largeurs = [320, 390, 1024, 1440];
  const langues = ["fr-FR", "en-US"];
  const polices = [16, 24];

  for (const width of largeurs) {
    for (const locale of langues) {
      for (const police of polices) {
        const contexte = await navigateur.newContext({
          viewport: { width, height: 900 },
          locale,
          isMobile: width < 900,
          hasTouch: width < 900,
          reducedMotion: "reduce",
        });
        const page = await contexte.newPage();
        const cdp = await contexte.newCDPSession(page);
        await cdp.send("Page.setFontSizes", { fontSizes: { standard: police, fixed: police } });
        await page.goto(url, { waitUntil: "networkidle" });
        await page.waitForTimeout(250);

        const fautes = await page.evaluate(() => {
          const racine = document.querySelector(".hero__devices");
          if (!racine) return [{ texte: "(hero absent)", contenant: ".hero__devices", depasse: 0 }];

          const resultat = [];
          const marcheur = document.createTreeWalker(racine, NodeFilter.SHOW_TEXT);
          for (let noeud = marcheur.nextNode(); noeud; noeud = marcheur.nextNode()) {
            const contenu = noeud.nodeValue.trim();
            if (!contenu) continue;
            // Le conteneur qui compte est le plus proche bloc, pas la carte :
            // le texte fautif débordait de `.activity__body` et passait sous
            // la pastille « terminer », tout en restant dans la carte. Une
            // comparaison avec la carte laissait donc passer le défaut.
            let contenant = noeud.parentElement;
            while (contenant && getComputedStyle(contenant).display === "inline") {
              contenant = contenant.parentElement;
            }
            if (!contenant || !contenant.closest(".hero__devices")) continue;

            const plage = document.createRange();
            plage.selectNodeContents(noeud);
            const encre = plage.getBoundingClientRect();
            if (encre.width === 0) continue;

            const boite = contenant.getBoundingClientRect();
            const style = getComputedStyle(contenant);
            const px = (v) => parseFloat(v) || 0;
            const gauche = boite.left + px(style.borderLeftWidth) + px(style.paddingLeft);
            const droite = boite.right - px(style.borderRightWidth) - px(style.paddingRight);
            const depasse = Math.max(gauche - encre.left, encre.right - droite);

            if (depasse > 1) {
              resultat.push({
                texte: contenu.slice(0, 32),
                contenant: (contenant.className || contenant.tagName).split(" ")[0],
                depasse: Math.round(depasse),
              });
            }
          }
          return resultat;
        });

        const etiquette = `${width}px / ${locale} / racine ${police}px`;
        if (fautes.length > 0) {
          for (const f of fautes) {
            signaler(`${etiquette} : « ${f.texte} » sort de .${f.contenant} de ${f.depasse} px`);
          }
        } else {
          console.log(`ok   texte dans les maquettes — ${etiquette}`);
        }

        await contexte.close();
      }
    }
  }
}

// Dernier contrôle, une seule fois : le texte de la première page est
// strictement le même deux secondes plus tard. Un chiffre qui avance — même
// ailleurs que dans un anneau ou une barre — se ferait prendre ici.
{
  const contexte = await navigateur.newContext({
    viewport: { width: 1280, height: 900 },
    locale: "fr-FR",
    reducedMotion: "reduce",
  });
  const page = await contexte.newPage();
  await page.goto(url, { waitUntil: "networkidle" });
  await page.waitForTimeout(300);
  const texte = () => page.evaluate(() => document.querySelector(".hero")?.innerText ?? "");
  const avant = await texte();
  await page.waitForTimeout(2000);
  const apres = await texte();
  if (avant !== apres) {
    signaler("le texte de la première page change avec le temps : quelque chose y compte");
  } else {
    console.log("ok   la première page ne compte rien");
  }
  await contexte.close();
}

await navigateur.close();

if (echecs > 0) {
  console.error(`\n${echecs} défaut(s) dans les maquettes du hero.`);
  process.exit(1);
}
console.log("\nMaquettes conformes : montre lisible, rien qui déborde, rien qui compte.");
