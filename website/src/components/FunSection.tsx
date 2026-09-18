import { useT } from "../i18n";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section assumée : tout ce qui ne sert à rien mais qu'on regarde quand même. */
export function FunSection() {
  const t = useT();

  return (
    <section className="section section--alt" id="palmares">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">{t.fun.eyebrow}</p>
          <h2>{t.fun.title}</h2>
          <p>{t.fun.body}</p>
          <Checklist items={t.fun.points} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="badges" role="img" aria-label={t.fun.badgesAlt}>
            {t.fun.badges.map((badge) => (
              <div className="badge-card" key={badge.title}>
                <strong>{badge.title}</strong>
                <span>{badge.detail}</span>
              </div>
            ))}
          </div>

          <div className="haiku">
            <p className="haiku__head">{t.fun.haiku.title}</p>
            {t.fun.haiku.lines.map((vers) => (
              <p className="haiku__line" key={vers}>
                {vers}
              </p>
            ))}
            <p className="haiku__foot">{t.fun.haiku.foot}</p>
          </div>

          <div className="absurd">
            <p className="absurd__head">{t.fun.absurdTitle}</p>
            <ul>
              {t.fun.equivalences.map((item) => (
                <li key={item.label}>
                  <strong>{item.value}</strong>
                  <span>{item.label}</span>
                </li>
              ))}
            </ul>
            <p className="absurd__foot">{t.fun.absurdFoot}</p>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
