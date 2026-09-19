import { useT } from "../i18n";
import { CalmPhoneMockup, CalmWatchMockup } from "./CalmMockup";
import { Reveal } from "./Reveal";

/**
 * Première page. Elle ne montre aucun chronomètre : rien n'y compte, rien n'y
 * avance. `scripts/check-hero.mjs` le vérifie, parce que rien n'empêcherait un
 * chiffre qui monte de revenir s'y glisser.
 */
export function Hero() {
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
            <a className="btn btn--ghost" href="#serenite">
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
          <CalmPhoneMockup />
          <CalmWatchMockup />
        </Reveal>
      </div>
    </section>
  );
}
