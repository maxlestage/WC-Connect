interface ProgressBarProps {
  /** Progression entre 0 et 1. */
  readonly ratio: number;
}

export function ProgressBar({ ratio }: ProgressBarProps) {
  return (
    <div
      className="bar"
      role="progressbar"
      aria-label="Progression de la visite"
      aria-valuemin={0}
      aria-valuemax={100}
      aria-valuenow={Math.round(ratio * 100)}
    >
      <span style={{ width: `${Math.round(ratio * 100)}%` }} />
    </div>
  );
}
