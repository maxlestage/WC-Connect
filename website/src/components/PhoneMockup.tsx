import { useT } from "../i18n";
import { DEMO_GOAL_SECONDS } from "../lib/demo";
import { formatClock, progressRatio } from "../lib/format";
import { DropletIcon } from "./DropletIcon";
import { ProgressBar } from "./ProgressBar";

interface PhoneMockupProps {
  readonly elapsed: number;
}

/** Écran verrouillé d'iPhone avec la Live Activity de WC Connect. */
export function PhoneMockup({ elapsed }: PhoneMockupProps) {
  const t = useT();
  const clock = formatClock(elapsed);

  return (
    <div className="phone" role="img" aria-label={`${t.hero.phoneAlt} — ${clock}`}>
      <div className="phone__screen">
        <div className="island">
          <span className="island__dot" />
          <span className="island__timer">{clock}</span>
        </div>

        <div className="phone__time">{t.hero.lockTime}</div>
        <div className="phone__date">{t.hero.lockDate}</div>

        <div className="activity">
          <div className="activity__icon">
            <DropletIcon />
          </div>
          <div className="activity__body">
            <p className="activity__label">{t.hero.activityLabel}</p>
            <p className="activity__timer">{clock}</p>
            <p className="activity__meta">{t.hero.activityMeta}</p>
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
