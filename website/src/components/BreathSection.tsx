import { breathingRhythms, DEMO_BREATH } from "../content";
import { useBreathing } from "../hooks/useBreathing";
import { Reveal } from "./Reveal";

/** Section « Détente » : la respiration guidée, animée au vrai rythme. */
export function BreathSection() {
  const breath = useBreathing(DEMO_BREATH.inhale, DEMO_BREATH.exhale);

  return (
    <section className="section" id="detente">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">Détente</p>
          <h2>Respirer plutôt que pousser</h2>
          <p>
            Retenir son souffle pour pousser fait monter la pression et fatigue le périnée. L'app
            guide trois rythmes ; celui proposé pendant une visite est sans apnée, et la montre
            marque chaque phase d'un tapotement — de quoi suivre les yeux fermés.
          </p>

          <div className="rhythms">
            {breathingRhythms.map((item) => (
              <div className="rhythm" key={item.rhythm}>
                <div className="rhythm__head">
                  <strong>{item.title}</strong>
                  <span className="rhythm__count">{item.rhythm}</span>
                  {item.recommended && <span className="badge">sur le trône</span>}
                </div>
                <p>{item.detail}</p>
              </div>
            ))}
          </div>
        </Reveal>

        <Reveal className="split__visual">
          <div
            className="breath"
            role="img"
            aria-label={`Démonstration de la respiration guidée, rythme ${DEMO_BREATH.inhale}-${DEMO_BREATH.exhale}`}
          >
            <div className="breath__halo" />
            <div className="breath__disc" style={{ transform: `scale(${breath.scale.toFixed(3)})` }} />
            <div className="breath__label">
              <span>{breath.phase === "inhale" ? "Inspirez" : "Expirez"}</span>
              <strong>{breath.remaining}</strong>
            </div>
          </div>
          <p className="breath__caption">Rythme réel de l'app : 4 secondes d'inspiration, 6 d'expiration.</p>
        </Reveal>
      </div>
    </section>
  );
}
