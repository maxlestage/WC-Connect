import { useT } from "../i18n";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/**
 * Section « Sans se lever ».
 *
 * Aucun trait d'humour ici, comme dans les autres sections de santé : le sujet
 * ne s'y prête pas, et le lecteur concerné n'est pas venu pour ça.
 */
export function SeatedSection() {
  const t = useT();
  const s = t.seated;

  return (
    <section className="section section--alt" id="sans-se-lever">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">{s.eyebrow}</p>
          <h2>{s.title}</h2>
          <p>{s.body}</p>
          <Checklist items={s.points} />
        </Reveal>

        <Reveal className="split__visual">
          {/* Le signal d'urgence d'abord : c'est l'information dont le coût
              d'omission est le plus élevé de tout le site. */}
          <div className="warning warning--urgent">
            <h3>{s.urgentTitle}</h3>
            <p className="warning__body">{s.urgentBody}</p>
          </div>

          <div className="seated__cards">
            <div className="seated__card">
              <p className="seated__card-title">{s.reminderTitle}</p>
              <p>{s.reminderBody}</p>
            </div>
            <div className="seated__card">
              <p className="seated__card-title">{s.handsTitle}</p>
              <p>{s.handsBody}</p>
            </div>
            <div className="seated__card">
              <p className="seated__card-title">{s.programTitle}</p>
              <p>{s.programBody}</p>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
