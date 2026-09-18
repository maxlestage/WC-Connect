/* WC Connect — animations légères du site de présentation.
   Pas de dépendance, pas de suivi. */
(() => {
  "use strict";

  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* --- Apparition progressive des blocs --- */
  const revealables = document.querySelectorAll(".reveal");

  if (reduceMotion || !("IntersectionObserver" in window)) {
    revealables.forEach((element) => element.classList.add("is-visible"));
  } else {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        });
      },
      { rootMargin: "0px 0px -10% 0px", threshold: 0.12 }
    );
    revealables.forEach((element) => observer.observe(element));
  }

  /* --- Bordure de la barre de navigation au défilement --- */
  const nav = document.getElementById("nav");
  const onScroll = () => nav.classList.toggle("is-stuck", window.scrollY > 8);
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();

  /* --- Chronomètres de démonstration ---
     Le même compteur alimente la Live Activity, la Dynamic Island, la montre
     et les complications : la maquette respire comme l'app. */
  const GOAL = 300; // durée cible affichée par la barre de progression (5 min)
  const CYCLE = 420; // le compteur reboucle pour rester vivant
  const timers = document.querySelectorAll("[data-timer]");
  const bars = document.querySelectorAll("[data-progress]");
  const rings = document.querySelectorAll("[data-ring]");

  const format = (seconds) => {
    const minutes = Math.floor(seconds / 60);
    return `${minutes}:${String(seconds % 60).padStart(2, "0")}`;
  };

  let elapsed = 247; // 4:07, comme sur les captures

  const render = () => {
    const label = format(elapsed);
    timers.forEach((node) => {
      node.textContent = label;
    });

    const ratio = Math.min(elapsed / GOAL, 1);
    bars.forEach((bar) => {
      bar.style.width = `${Math.round(ratio * 100)}%`;
    });
    rings.forEach((ring) => {
      // 314 ≈ circonférence du cercle de rayon 50 utilisé dans le SVG.
      ring.style.strokeDashoffset = String(Math.round(314 * (1 - ratio)));
    });
  };

  render();

  if (!reduceMotion) {
    setInterval(() => {
      elapsed = (elapsed + 1) % CYCLE;
      render();
    }, 1000);
  }
})();
