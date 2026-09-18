import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

/**
 * Le site est entièrement statique : aucune exécution côté serveur.
 *
 * - `VITE_BASE` : sous-chemin de publication (« /WC-Connect/ » sur GitHub
 *   Pages, « / » sur un domaine dédié).
 * - `VITE_SITE_URL` : origine publique, injectée à la construction dans les
 *   balises de partage — Open Graph exige des URL absolues, et il n'y a plus
 *   de serveur pour les calculer à la volée.
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
