import { useT } from "../i18n";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section « Météo intestinale » : le bulletin et le profil. */
export function WeatherSection() {
  const t = useT();
  const bulletin = t.weather.forecast;

  return (
    <section className="section section--alt" id="meteo">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">{t.weather.eyebrow}</p>
          <h2>{t.weather.title}</h2>
          <p>{t.weather.body}</p>
          <Checklist items={t.weather.points} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="forecast" role="img" aria-label={t.weather.cardAlt}>
            <div className="forecast__head">
              <span className="forecast__icon" aria-hidden="true">
                ⛅️
              </span>
              <div>
                <span className="forecast__kicker">{t.weather.kicker}</span>
                <strong>{bulletin.condition}</strong>
              </div>
            </div>
            <p className="forecast__summary">{bulletin.summary}</p>

            <div className="forecast__rows">
              {bulletin.rows.map((row) => (
                <div key={row.label}>
                  <strong>{row.value}</strong>
                  <span>{row.label}</span>
                </div>
              ))}
            </div>

            <p className="forecast__wind">{bulletin.wind}</p>

            <div className="forecast__persona">
              <strong>{bulletin.personaTitle}</strong>
              <span>{bulletin.personaDetail}</span>
            </div>

            <p className="forecast__meta">{bulletin.prediction}</p>
            <p className="forecast__life">{bulletin.lifetime}</p>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
