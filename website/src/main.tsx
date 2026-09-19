import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import { LanguageProvider } from "./i18n";
import { ThemeProvider } from "./theme";
import "./styles.css";

const container = document.getElementById("root");

if (!container) {
  throw new Error("Élément racine introuvable : vérifiez index.html");
}

/**
 * Service worker : c'est lui qui rend le site installable et consultable hors
 * ligne. Il n'existe qu'en production — en développement, un cache actif
 * masquerait les modifications en cours.
 *
 * Un refus (navigation privée, réglage du navigateur, contexte non sécurisé)
 * n'est pas une erreur à remonter : le site fonctionne exactement pareil, il
 * ne sera simplement pas disponible hors ligne.
 */
if (import.meta.env.PROD && "serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    void navigator.serviceWorker.register(`${import.meta.env.BASE_URL}sw.js`).catch(() => {});
  });
}

createRoot(container).render(
  <StrictMode>
    <ThemeProvider>
      <LanguageProvider>
        <App />
      </LanguageProvider>
    </ThemeProvider>
  </StrictMode>,
);
