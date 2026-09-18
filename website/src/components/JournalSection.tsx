import { useT } from "../i18n";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section « Journal & objectifs » : Bristol, symptômes, objectif, hydratation, Santé. */
export function JournalSection() {
  const t = useT();
  const j = t.journal;

  return (
    <section className="section section--alt" id="journal">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">{j.eyebrow}</p>
          <h2>{j.title}</h2>
          <p>{j.body}</p>
          <Checklist items={j.points} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="journal" role="img" aria-label={j.cardAlt}>
            <p className="journal__title">{j.scaleTitle}</p>

            <div className="journal__scale">
              {j.scale.map((step) => {
                const choisi = step.value === j.selected;
                return (
                  <div
                    key={step.value}
                    className={choisi ? "journal__step journal__step--on" : "journal__step"}
                    title={step.label}
                  >
                    <strong>{step.value}</strong>
                    <span>{step.label}</span>
                  </div>
                );
              })}
            </div>
            <p className="journal__foot">{j.scaleFoot}</p>

            <div className="journal__row">
              <span>{j.effortLabel}</span>
              <strong>{j.effortValue}</strong>
            </div>

            <p className="journal__title">{j.symptomsTitle}</p>
            <ul className="journal__symptoms">
              {j.symptoms.map((symptome) => (
                <li
                  key={symptome}
                  className={
                    j.active.includes(symptome)
                      ? "journal__symptom journal__symptom--on"
                      : "journal__symptom"
                  }
                >
                  {symptome}
                </li>
              ))}
            </ul>

            <p className="journal__disclaimer">{j.disclaimer}</p>
          </div>
        </Reveal>
      </div>

      <div className="wrap">
        <div className="journal__tiles">
          {j.tiles.map((tile) => (
            <Reveal key={tile.title} className="journal__tile">
              <p className="journal__tile-title">{tile.title}</p>
              <strong>{tile.value}</strong>
              <span>{tile.detail}</span>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
