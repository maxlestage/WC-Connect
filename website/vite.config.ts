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
  ],
  build: {
    outDir: "dist",
    sourcemap: false,
  },
  server: {
    port: 5173,
  },
});
