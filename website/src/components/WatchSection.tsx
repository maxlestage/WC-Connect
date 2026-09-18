import { watchPoints } from "../content";
import { formatClock } from "../lib/format";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

interface WatchSectionProps {
  readonly elapsed: number;
}

export function WatchSection({ elapsed }: WatchSectionProps) {
  const clock = formatClock(elapsed);

  return (
    <section className="section" id="watch">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">Apple Watch</p>
          <h2>Le poignet suffit</h2>
          <p>
            L'app Watch est autonome : lancez la visite depuis le cadran, terminez-la d'un
            tapotement. Tout se resynchronise avec l'iPhone dès qu'il est à portée, y compris une
            visite démarrée hors de portée.
          </p>
          <Checklist items={watchPoints} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="complications">
            <div className="comp comp--circ">
              <span>{clock}</span>
            </div>
            <div className="comp comp--rect">
              <strong>Visite en cours</strong>
              <span>{clock}</span>
              <small>Maison</small>
            </div>
            <div className="comp comp--line">WC · 3 aujourd'hui</div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
