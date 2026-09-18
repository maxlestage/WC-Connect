import { useT } from "../i18n";
import { useBreathing } from "../hooks/useBreathing";
import { DEMO_BREATH } from "../lib/demo";
import { Reveal } from "./Reveal";

/** Section « Détente » : la respiration guidée, animée au vrai rythme. */
export function BreathSection() {
  const t = useT();
  const breath = useBreathing(DEMO_BREATH.inhale, DEMO_BREATH.exhale);

  return (
    <section className="section" id="detente">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">{t.breath.eyebrow}</p>
          <h2>{t.breath.title}</h2>
          <p>{t.breath.body}</p>

          <div className="rhythms">
            {t.breath.rhythms.map((item) => (
              <div className="rhythm" key={item.rhythm}>
                <div className="rhythm__head">
                  <strong>{item.title}</strong>
                  <span className="rhythm__count">{item.rhythm}</span>
                  {item.recommended && <span className="badge">{t.breath.recommended}</span>}
                </div>
                <p>{item.detail}</p>
              </div>
            ))}
          </div>
        </Reveal>

        <Reveal className="split__visual">
          <div className="breath" role="img" aria-label={t.breath.demoAlt}>
            <div className="breath__halo" />
            <div className="breath__disc" style={{ transform: `scale(${breath.scale.toFixed(3)})` }} />
            <div className="breath__label">
              <span>{breath.phase === "inhale" ? t.breath.inhale : t.breath.exhale}</span>
              <strong>{breath.remaining}</strong>
            </div>
          </div>
          <p className="breath__caption">{t.breath.caption}</p>
        </Reveal>
      </div>
    </section>
  );
}
