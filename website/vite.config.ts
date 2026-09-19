import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

/**
 * Le site est entièrement statique : aucune exécution côté serveur.
 *
 * - `VITE_BASE` : sous-chemin de publication (« /WC-Connect/ » sur GitHub
 *   Pages, « / » sur un domaine dédié).
 * - `VITE_SITE_URL` : origine publique, injectée à la construction dans les
 *   balises de partage, qu'Open Graph exige absolues. Laissée vide, le
 *   marqueur `__SITE_URL__` reste dans la page : `server.js` s'en charge à la
 *   volée, ce qui permet à Heroku de fonctionner sans connaître son domaine
 *   à l'avance.
 */
const base = process.env["VITE_BASE"] ?? "/";
const siteUrl = (process.env["VITE_SITE_URL"] ?? "").replace(/\/+$/, "");

export default defineConfig({
  base,
  plugins: [
    react(),
    {
      name: "wc-connect-site-url",
      transformIndexHtml(html) {
        // Origine inconnue à la construction (cas d'un hébergeur qui attribue
        // le domaine) : le marqueur reste, et le serveur le remplace par
        // l'origine réellement servie.
        if (!siteUrl) return html;
        return html.replaceAll("__SITE_URL__", siteUrl);
      },
    },
    {
      /**
       * Manifeste et service worker, écrits à la construction.
       *
       * Ils ne peuvent pas être de simples fichiers de `public/` : le
       * manifeste doit porter le sous-chemin de publication dans `start_url`,
       * `scope` et ses icônes, et le service worker doit connaître le nom
       * empreinté des fichiers produits — qui change à chaque modification.
       * Les écrire ici, c'est la seule façon qu'ils restent justes sur un
       * domaine dédié comme sous « /WC-Connect/ ».
       */
      name: "wc-connect-pwa",
      /**
       * Vite préfixe lui-même les chemins absolus des balises qu'il connaît —
       * `rel="icon"`, `rel="apple-touch-icon"`, `src` d'un script — mais pas
       * `rel="manifest"`. Publié sous « /WC-Connect/ », le manifeste était
       * donc cherché à la racine du domaine : 404, et un site qui ne
       * s'installe plus. On le préfixe ici.
       */
      transformIndexHtml(html) {
        return html.replace('href="/manifest.webmanifest"', `href="${base}manifest.webmanifest"`);
      },
      generateBundle(_options, bundle) {
        // Fichiers de `public/`, recopiés tels quels par Vite : ils ne
        // figurent pas dans le lot, il faut les nommer.
        const statiques = [
          "favicon.svg",
          "logo.svg",
          "icon-192.png",
          "icon-512.png",
          "icon-maskable-512.png",
          "apple-touch-icon.png",
        ];

        const produits = Object.keys(bundle).filter((nom) => nom !== "manifest.webmanifest");
        // `base` se termine toujours par « / » : l'accueil, c'est lui-même.
        const aGarder = [base, ...produits, ...statiques].map((nom) =>
          nom === base ? base : `${base}${nom}`,
        );

        // Nom de cache dérivé du contenu : reconstruire à l'identique ne fait
        // pas repartir le cache de zéro, modifier quoi que ce soit le change.
        const empreinte = createHash("sha256")
          .update(aGarder.join("\n"))
          .digest("hex")
          .slice(0, 12);

        const manifeste = {
          name: "WC Connect",
          short_name: "WC Connect",
          description:
            "Le suivi discret de vos pauses. Aucun compte, aucun serveur : rien ne quitte votre appareil.",
          // Un manifeste ne porte qu'une langue ; le français est la source de
          // vérité du contenu. Le site, lui, reste bilingue une fois ouvert.
          lang: "fr",
          dir: "ltr",
          start_url: base,
          scope: base,
          id: base,
          display: "standalone",
          orientation: "portrait",
          background_color: "#f6f8fc",
          theme_color: "#1c66c7",
          icons: [
            { src: `${base}icon-192.png`, sizes: "192x192", type: "image/png", purpose: "any" },
            { src: `${base}icon-512.png`, sizes: "512x512", type: "image/png", purpose: "any" },
            {
              src: `${base}icon-maskable-512.png`,
              sizes: "512x512",
              type: "image/png",
              purpose: "maskable",
            },
          ],
        };

        this.emitFile({
          type: "asset",
          fileName: "manifest.webmanifest",
          source: `${JSON.stringify(manifeste, null, 2)}\n`,
        });

        const gabarit = readFileSync(new URL("./sw-template.js", import.meta.url), "utf8");
        this.emitFile({
          type: "asset",
          fileName: "sw.js",
          source: gabarit
            .replace("__CACHE__", `wc-connect-${empreinte}`)
            .replace("__BASE__", base)
            .replace("__PRECACHE__", JSON.stringify(aGarder, null, 2)),
        });
      },
    },
  ],
  build: {
    outDir: "dist",
    sourcemap: false,
  },
  server: {
    port: 5173,
  },
});
