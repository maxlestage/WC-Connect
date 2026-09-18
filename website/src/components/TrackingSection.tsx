import { statTiles, trackingPoints, weekBars } from "../content";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section « Suivi » : historique, statistiques et export. */
export function TrackingSection() {
  const highest = Math.max(...weekBars.map((bar) => bar.value), 1);

  return (
    <section className="section" id="suivi">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">Suivi</p>
          <h2>De quoi voir ce qui se passe vraiment</h2>
          <p>
            Chaque visite enregistrée alimente un historique et des statistiques lisibles : durée
            moyenne, créneau favori, série de jours suivis. De quoi repérer une tendance — ou
            montrer quelque chose de concret à un médecin.
          </p>
          <Checklist items={trackingPoints} />
        </Reveal>

        <Reveal className="split__visual">
          <figure className="chart">
            <figcaption>Visites des 7 derniers jours</figcaption>
            <div className="chart__plot">
              {weekBars.map((bar, index) => (
                <div className="chart__col" key={`${bar.label}-${index}`}>
                  <div
                    className={`chart__bar${bar.today ? " chart__bar--today" : ""}`}
                    style={{ height: `${(bar.value / highest) * 100}%` }}
                    data-tooltip={`${bar.value} visite${bar.value > 1 ? "s" : ""}`}
                    role="img"
                    aria-label={`${bar.value} visites`}
                  >
                    <span className="chart__value">{bar.value}</span>
                  </div>
                  <span className="chart__label">{bar.label}</span>
                </div>
              ))}
            </div>
          </figure>

          <div className="tiles">
            {statTiles.map((tile) => (
              <div className="tile" key={tile.label}>
                <strong>{tile.value}</strong>
                <span>{tile.label}</span>
              </div>
            ))}
          </div>
        </Reveal>
      </div>
    </section>
  );
}
