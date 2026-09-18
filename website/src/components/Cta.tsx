import { useT } from "../i18n";
import { Reveal } from "./Reveal";

export function Cta() {
  const t = useT();

  return (
    <section className="cta" id="disponibilite">
      <div className="wrap narrow">
        <Reveal>
          <h2>{t.cta.title}</h2>
          <p>{t.cta.body}</p>
          <div className="hero__cta hero__cta--center">
            <a className="btn btn--ghost" href="#fonctions">
              {t.cta.action}
            </a>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
