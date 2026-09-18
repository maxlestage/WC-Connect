import compression from "compression";
import express, { type Request, type Response } from "express";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

/** Dossier des fichiers construits par Vite (`npm run build:client`). */
const distDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "dist");
const indexFile = path.join(distDir, "index.html");

if (!existsSync(indexFile)) {
  console.error(
    `Build introuvable dans ${distDir}. Lancez « npm run build » avant « npm start ».`,
  );
  process.exit(1);
}

const indexTemplate = readFileSync(indexFile, "utf8");
const app = express();
const port = Number(process.env["PORT"] ?? 3000);

/** Origine forcée par configuration, sinon déduite de la requête. */
const configuredOrigin = normalizeOrigin(process.env["SITE_URL"]);

app.disable("x-powered-by");
// Heroku et Render placent l'application derrière un proxy : sans cela,
// req.protocol renvoie toujours « http ».
app.set("trust proxy", true);
app.use(compression());

// Les fichiers versionnés par Vite (/assets/*-[hash].js) sont immuables.
app.use(
  "/assets",
  express.static(path.join(distDir, "assets"), {
    immutable: true,
    maxAge: "1y",
  }),
);

// `index: false` : la page d'accueil passe par le rendu ci-dessous, qui complète
// les métadonnées de partage.
app.use(express.static(distDir, { maxAge: "1h", index: false }));

app.get("/healthz", (_request: Request, response: Response) => {
  response.json({ status: "ok" });
});

// Le site est une application d'une seule page : tout le reste renvoie index.html.
app.get("*", (request: Request, response: Response) => {
  response.type("html").send(renderIndex(request));
});

app.listen(port, () => {
  console.log(`WC Connect — site disponible sur http://localhost:${port}`);
});

/**
 * Les balises Open Graph exigent des URL absolues, or le domaine n'est connu
 * qu'au déploiement : l'origine est injectée à la volée.
 */
function renderIndex(request: Request): string {
  const origin = configuredOrigin ?? requestOrigin(request) ?? "";
  return indexTemplate.replaceAll("__SITE_URL__", origin);
}

function requestOrigin(request: Request): string | undefined {
  const host = request.get("host");
  if (!host || !isSafeHost(host)) return undefined;
  const protocol = request.protocol === "https" ? "https" : "http";
  return `${protocol}://${host}`;
}

function normalizeOrigin(value: string | undefined): string | undefined {
  if (!value) return undefined;
  const trimmed = value.trim().replace(/\/+$/, "");
  return /^https?:\/\/[\w.-]+(:\d+)?$/.test(trimmed) ? trimmed : undefined;
}

/**
 * L'en-tête Host vient du client : on n'y réinjecte que des noms d'hôtes
 * plausibles, pour ne rien laisser passer dans la page.
 */
function isSafeHost(host: string): boolean {
  return host.length <= 253 && /^[A-Za-z0-9.-]+(:\d{1,5})?$/.test(host);
}
