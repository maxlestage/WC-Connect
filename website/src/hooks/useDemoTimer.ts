import { useEffect, useState } from "react";
import { usePrefersReducedMotion } from "./usePrefersReducedMotion";

interface DemoTimerOptions {
  /** Valeur de départ, en secondes (4:07 comme sur les captures). */
  readonly start?: number;
  /** Le compteur reboucle pour que la maquette reste vivante. */
  readonly cycle?: number;
}

/**
 * Chronomètre de démonstration partagé par toutes les maquettes : iPhone,
 * Dynamic Island, montre et complications affichent la même valeur.
 */
export function useDemoTimer({ start = 247, cycle = 420 }: DemoTimerOptions = {}): number {
  const prefersReducedMotion = usePrefersReducedMotion();
  const [elapsed, setElapsed] = useState(start);

  useEffect(() => {
    if (prefersReducedMotion) return;
    const id = window.setInterval(() => {
      setElapsed((current) => (current + 1) % cycle);
    }, 1000);
    return () => window.clearInterval(id);
  }, [prefersReducedMotion, cycle]);

  return elapsed;
}
