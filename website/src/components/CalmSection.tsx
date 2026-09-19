import { useT } from "../i18n";
import { LeafIcon } from "./LeafIcon";
import { Reveal } from "./Reveal";

/** Section « Sérénité » : ce que l'app retire de l'écran, et ce qu'elle garde. */
export function CalmSection() {
  const t = useT();

  return (
    <section className="section section--calm" id="serenite">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">{t.calm.eyebrow}</p>
          <h2>{t.calm.title}</h2>
          <p>{t.calm.body}</p>

          <div className="grid grid--pair">
            {t.calm.cards.map((card) => (
              <article className="card card--calm" key={card.title}>
                <h3>{card.title}</h3>
                <p>{card.description}</p>
              </article>
            ))}
          </div>
        </Reveal>

        <Reveal className="split__visual">
          <div className="calm" role="img" aria-label={t.calm.demoAlt}>
            <span className="calm__halo" aria-hidden="true" />
            <span className="calm__halo calm__halo--inner" aria-hidden="true" />
            <div className="calm__label">
              <LeafIcon size={34} />
              <strong>{t.calm.demoTitle}</strong>
              <span>{t.calm.demoMeta}</span>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
