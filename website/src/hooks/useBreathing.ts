import { useEffect, useState } from "react";
import { usePrefersReducedMotion } from "./usePrefersReducedMotion";

export interface BreathingDemoState {
  /** Phase en cours, comme dans l'app. */
  readonly phase: "inhale" | "exhale";
  /** Secondes restantes dans la phase, arrondies vers le haut. */
  readonly remaining: number;
  /** Taille du cercle, de 0,55 à 1. */
  readonly scale: number;
}

const MIN_SCALE = 0.55;

/**
 * Reproduit la logique de `BreathingPattern` de l'app : inspiration puis
 * expiration, sans apnée. La maquette respire donc au même rythme que
 * l'exercice réel.
 */
export function useBreathing(inhale: number, exhale: number): BreathingDemoState {
  const prefersReducedMotion = usePrefersReducedMotion();
  const cycle = inhale + exhale;
  const [elapsed, setElapsed] = useState(0);

  useEffect(() => {
    if (prefersReducedMotion) return;
    const started = performance.now();
    const id = window.setInterval(() => {
      setElapsed(((performance.now() - started) / 1000) % cycle);
    }, 100);
    return () => window.clearInterval(id);
  }, [prefersReducedMotion, cycle]);

  if (prefersReducedMotion) {
    return { phase: "inhale", remaining: inhale, scale: 1 };
  }

  if (elapsed < inhale) {
    const progress = elapsed / inhale;
    return {
      phase: "inhale",
      remaining: Math.ceil(inhale - elapsed),
      scale: MIN_SCALE + (1 - MIN_SCALE) * progress,
    };
  }

  const progress = (elapsed - inhale) / exhale;
  return {
    phase: "exhale",
    remaining: Math.ceil(cycle - elapsed),
    scale: 1 - (1 - MIN_SCALE) * progress,
  };
}
