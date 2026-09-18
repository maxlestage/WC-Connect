import { DEMO_GOAL_SECONDS } from "../content";
import { formatClock, progressRatio } from "../lib/format";
import { DropletIcon } from "./DropletIcon";
import { ProgressBar } from "./ProgressBar";

interface PhoneMockupProps {
  readonly elapsed: number;
}

/** Écran verrouillé d'iPhone avec la Live Activity de WC Connect. */
export function PhoneMockup({ elapsed }: PhoneMockupProps) {
  const clock = formatClock(elapsed);

  return (
    <div
      className="phone"
      role="img"
      aria-label={`Écran verrouillé d'un iPhone affichant la Live Activity de WC Connect, ${clock} écoulées`}
    >
      <div className="phone__screen">
        <div className="island">
          <span className="island__dot" />
          <span className="island__timer">{clock}</span>
        </div>

        <div className="phone__time">9:41</div>
        <div className="phone__date">mercredi 18 mars</div>

        <div className="activity">
          <div className="activity__icon">
            <DropletIcon />
          </div>
          <div className="activity__body">
            <p className="activity__label">Visite en cours</p>
            <p className="activity__timer">{clock}</p>
            <p className="activity__meta">Standard · Maison</p>
          </div>
          <div className="activity__action" aria-hidden="true">
            ✓
          </div>
        </div>

        <div className="activity activity--bar">
          <ProgressBar ratio={progressRatio(elapsed, DEMO_GOAL_SECONDS)} />
        </div>
      </div>
    </div>
  );
}
