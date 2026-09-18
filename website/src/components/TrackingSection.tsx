import { useT } from "../i18n";
import { WEEK_TODAY_INDEX, WEEK_VALUES } from "../lib/demo";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section « Suivi » : historique, statistiques et export. */
export function TrackingSection() {
  const t = useT();
  const highest = Math.max(...WEEK_VALUES, 1);

  return (
    <section className="section" id="suivi">
      <div className="wrap split split--reverse">
        <Reveal className="split__text">
          <p className="eyebrow">{t.tracking.eyebrow}</p>
          <h2>{t.tracking.title}</h2>
          <p>{t.tracking.body}</p>
          <Checklist items={t.tracking.points} />
        </Reveal>

        <Reveal className="split__visual">
          <figure className="chart">
            <figcaption>{t.tracking.chartTitle}</figcaption>
            <div className="chart__plot">
              {WEEK_VALUES.map((value, index) => {
                const unit = value > 1 ? t.tracking.visitMany : t.tracking.visitOne;
                return (
                  <div className="chart__col" key={index}>
                    <div
                      className={`chart__bar${index === WEEK_TODAY_INDEX ? " chart__bar--today" : ""}`}
                      style={{ height: `${(value / highest) * 100}%` }}
                      data-tooltip={`${value} ${unit}`}
                      role="img"
                      aria-label={`${value} ${unit}`}
                    >
                      <span className="chart__value">{value}</span>
                    </div>
                    <span className="chart__label">{t.tracking.days[index]}</span>
                  </div>
                );
              })}
            </div>
          </figure>

          <div className="tiles">
            {t.tracking.tiles.map((tile) => (
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
