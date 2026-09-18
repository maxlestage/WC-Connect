import { useT } from "../i18n";
import { Reveal } from "./Reveal";

export function Features() {
  const t = useT();

  return (
    <section className="section" id="fonctions">
      <div className="wrap">
        <Reveal as="h2">{t.features.title}</Reveal>
        <Reveal as="p" className="section__lead">
          {t.features.lead}
        </Reveal>

        <div className="grid">
          {t.features.cards.map((card) => (
            <Reveal as="article" className="card" key={card.title}>
              <h3>{card.title}</h3>
              <p>{card.description}</p>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
