import compression from "compression";
import express, { type Request, type Response } from "express";
import { existsSync } from "node:fs";
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

const app = express();
const port = Number(process.env["PORT"] ?? 3000);

app.disable("x-powered-by");
app.use(compression());

// Les fichiers versionnés par Vite (/assets/*-[hash].js) sont immuables.
app.use(
  "/assets",
  express.static(path.join(distDir, "assets"), {
    immutable: true,
    maxAge: "1y",
  }),
);

app.use(express.static(distDir, { maxAge: "1h" }));

app.get("/healthz", (_request: Request, response: Response) => {
  response.json({ status: "ok" });
});

// Le site est une application d'une seule page : tout le reste renvoie index.html.
app.get("*", (_request: Request, response: Response) => {
  response.sendFile(indexFile);
});

app.listen(port, () => {
  console.log(`WC Connect — site disponible sur http://localhost:${port}`);
});
