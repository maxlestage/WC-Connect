import { useT } from "../i18n";
import { Reveal } from "./Reveal";

export function Privacy() {
  const t = useT();

  return (
    <section className="section section--alt" id="confidentialite">
      <div className="wrap narrow">
        <Reveal>
          <p className="eyebrow">{t.privacy.eyebrow}</p>
          <h2>{t.privacy.title}</h2>
          <p className="section__lead">{t.privacy.lead}</p>
          <div className="pills">
            {t.privacy.tags.map((tag) => (
              <span className="pill pill--static" key={tag}>
                {tag}
              </span>
            ))}
          </div>
        </Reveal>
      </div>
    </section>
  );
}
