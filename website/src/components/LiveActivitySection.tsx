import { DEMO_GOAL_SECONDS, liveActivityPoints } from "../content";
import { formatClock, progressRatio } from "../lib/format";
import { Checklist } from "./Checklist";
import { ProgressBar } from "./ProgressBar";
import { Reveal } from "./Reveal";

interface LiveActivitySectionProps {
  readonly elapsed: number;
}

export function LiveActivitySection({ elapsed }: LiveActivitySectionProps) {
  const clock = formatClock(elapsed);

  return (
    <section className="section" id="live">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">Live Activity</p>
          <h2>Le chronomètre là où vous regardez déjà</h2>
          <p>
            Dès que la visite démarre, iOS affiche une Live Activity : écran verrouillé, Dynamic
            Island compacte, vue étendue au toucher. Le chronomètre est animé par le système —
            l'app reste fermée, la batterie ne bouge pas.
          </p>
          <Checklist items={liveActivityPoints} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="island island--big">
            <span className="island__dot" />
            <span className="island__timer">{clock}</span>
          </div>

          <div className="expanded">
            <div className="expanded__row">
              <span className="tag">Standard</span>
              <span className="expanded__timer">{clock}</span>
            </div>
            <ProgressBar ratio={progressRatio(elapsed, DEMO_GOAL_SECONDS)} />
            <div className="expanded__row expanded__row--foot">
              <span>Maison</span>
              <span className="pill">Terminer</span>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
