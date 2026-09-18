import { useT } from "../i18n";
import { formatClock } from "../lib/format";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

interface WatchSectionProps {
  readonly elapsed: number;
}

export function WatchSection({ elapsed }: WatchSectionProps) {
  const t = useT();
  const clock = formatClock(elapsed);

  return (
    <section className="section section--alt" id="watch">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">{t.watch.eyebrow}</p>
          <h2>{t.watch.title}</h2>
          <p>{t.watch.body}</p>
          <Checklist items={t.watch.points} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="complications">
            <div className="comp comp--circ">
              <span>{clock}</span>
            </div>
            <div className="comp comp--rect">
              <strong>{t.watch.complicationTitle}</strong>
              <span>{clock}</span>
              <small>{t.watch.complicationPlace}</small>
            </div>
            <div className="comp comp--line">{t.watch.complicationInline}</div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
