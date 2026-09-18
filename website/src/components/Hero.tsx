import { useT } from "../i18n";
import { PhoneMockup } from "./PhoneMockup";
import { Reveal } from "./Reveal";
import { WatchMockup } from "./WatchMockup";

interface HeroProps {
  readonly elapsed: number;
}

export function Hero({ elapsed }: HeroProps) {
  const t = useT();

  return (
    <section className="hero">
      <div className="wrap hero__inner">
        <Reveal className="hero__text">
          <p className="eyebrow">{t.hero.eyebrow}</p>
          <h1>
            {t.hero.titleLine1}
            <br />
            {t.hero.titleLine2}
          </h1>
          <p className="lead">{t.hero.lead}</p>
          <div className="hero__cta">
            <a className="btn" href="#fonctions">
              {t.hero.primary}
            </a>
            <a className="btn btn--ghost" href="#live">
              {t.hero.secondary}
            </a>
          </div>
          <ul className="hero__facts">
            {t.hero.facts.map((fact) => (
              <li key={fact.label}>
                <strong>{fact.value}</strong>
                <span>{fact.label}</span>
              </li>
            ))}
          </ul>
        </Reveal>

        <Reveal className="hero__devices">
          <PhoneMockup elapsed={elapsed} />
          <WatchMockup elapsed={elapsed} />
        </Reveal>
      </div>
    </section>
  );
}
