import { forecastDemo, weatherPoints } from "../content";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section « Météo intestinale » : le bulletin et le profil. */
export function WeatherSection() {
  return (
    <section className="section" id="meteo">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">Météo intestinale</p>
          <h2>Un bulletin que personne n'avait demandé</h2>
          <p>
            L'app compare la semaine écoulée à la précédente et en tire un bulletin complet :
            pression, risque d'averse, visibilité, vent. Aucune valeur prédictive, une vraie
            méthode de calcul. Elle en déduit aussi votre profil et l'heure de votre prochain
            passage.
          </p>
          <Checklist items={weatherPoints} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="forecast" role="img" aria-label="Bulletin météo intestinal affiché par l'app">
            <div className="forecast__head">
              <span className="forecast__icon" aria-hidden="true">
                ⛅️
              </span>
              <div>
                <span className="forecast__kicker">Météo intestinale</span>
                <strong>{forecastDemo.title}</strong>
              </div>
            </div>
            <p className="forecast__summary">{forecastDemo.summary}</p>

            <div className="forecast__rows">
              {forecastDemo.rows.map((row) => (
                <div key={row.label}>
                  <strong>{row.value}</strong>
                  <span>{row.label}</span>
                </div>
              ))}
            </div>

            <p className="forecast__wind">{forecastDemo.wind}</p>

            <div className="forecast__persona">
              <strong>{forecastDemo.persona.title}</strong>
              <span>{forecastDemo.persona.detail}</span>
            </div>

            <p className="forecast__meta">{forecastDemo.prediction}</p>
            <p className="forecast__life">{forecastDemo.lifetime}</p>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
