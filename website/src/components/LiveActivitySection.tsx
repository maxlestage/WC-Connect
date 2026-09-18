import { useT } from "../i18n";
import { DEMO_GOAL_SECONDS } from "../lib/demo";
import { formatClock, progressRatio } from "../lib/format";
import { Checklist } from "./Checklist";
import { ProgressBar } from "./ProgressBar";
import { Reveal } from "./Reveal";

interface LiveActivitySectionProps {
  readonly elapsed: number;
}

export function LiveActivitySection({ elapsed }: LiveActivitySectionProps) {
  const t = useT();
  const clock = formatClock(elapsed);

  return (
    <section className="section" id="live">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">{t.live.eyebrow}</p>
          <h2>{t.live.title}</h2>
          <p>{t.live.body}</p>
          <Checklist items={t.live.points} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="island island--big">
            <span className="island__dot" />
            <span className="island__timer">{clock}</span>
          </div>

          <div className="expanded">
            <div className="expanded__row">
              <span className="tag">{t.live.kind}</span>
              <span className="expanded__timer">{clock}</span>
            </div>
            <ProgressBar ratio={progressRatio(elapsed, DEMO_GOAL_SECONDS)} />
            <div className="expanded__row expanded__row--foot">
              <span>{t.live.place}</span>
              <span className="pill">{t.live.action}</span>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
