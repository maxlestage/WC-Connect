import { DEMO_GOAL_SECONDS } from "../content";
import { formatClock, progressRatio } from "../lib/format";

interface WatchMockupProps {
  readonly elapsed: number;
}

/** Circonférence du cercle de rayon 50 utilisé par l'anneau SVG. */
const CIRCUMFERENCE = 2 * Math.PI * 50;

export function WatchMockup({ elapsed }: WatchMockupProps) {
  const clock = formatClock(elapsed);
  const ratio = progressRatio(elapsed, DEMO_GOAL_SECONDS);

  return (
    <div
      className="watch"
      role="img"
      aria-label={`Apple Watch affichant le chronomètre WC Connect, ${clock} écoulées`}
    >
      <div className="watch__screen">
        <div className="ring">
          <svg viewBox="0 0 120 120">
            <circle className="ring__track" cx="60" cy="60" r="50" />
            <circle
              className="ring__value"
              cx="60"
              cy="60"
              r="50"
              strokeDasharray={CIRCUMFERENCE}
              strokeDashoffset={CIRCUMFERENCE * (1 - ratio)}
            />
          </svg>
          <div className="ring__label">
            <span>{clock}</span>
            <small>Maison</small>
          </div>
        </div>
        <div className="watch__button">Terminer</div>
      </div>
    </div>
  );
}
