/** Formate un nombre de secondes en « m:ss », comme le chronomètre de l'app. */
export function formatClock(totalSeconds: number): string {
  const safe = Math.max(0, Math.floor(totalSeconds));
  const minutes = Math.floor(safe / 60);
  const seconds = safe % 60;
  return `${minutes}:${String(seconds).padStart(2, "0")}`;
}

/** Ratio de progression borné à [0, 1]. */
export function progressRatio(elapsedSeconds: number, goalSeconds: number): number {
  if (goalSeconds <= 0) return 0;
  return Math.min(Math.max(elapsedSeconds / goalSeconds, 0), 1);
}
