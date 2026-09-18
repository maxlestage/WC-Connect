import { immediateTips, medicalDisclaimer, redFlags, tipFamilies } from "../content";
import { Reveal } from "./Reveal";

/** Section « Quand ça coince » : ce que l'app propose pendant une visite. */
export function HelpSection() {
  return (
    <section className="section section--alt" id="aide">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">Quand ça coince</p>
          <h2>Des gestes concrets, au moment où ça bloque</h2>
          <p>
            Au bout de quelques minutes — avant les cinq minutes à partir desquelles il vaut mieux
            se relever — l'app propose trois gestes applicables assis, la respiration guidée et une
            ambiance sonore. La carte se masque d'un geste si vous n'en voulez pas.
          </p>

          <div className="families">
            {tipFamilies.map((family) => (
              <div className="family" key={family.title}>
                <h3>{family.title}</h3>
                <ul>
                  {family.examples.map((example) => (
                    <li key={example}>{example}</li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </Reveal>

        <Reveal className="split__visual">
          <div className="nudge" role="img" aria-label="Carte de conseils affichée par l'app pendant une visite">
            <div className="nudge__head">
              <span className="nudge__bulb" aria-hidden="true">
                💡
              </span>
              <strong>Ça coince ?</strong>
            </div>
            <ul className="nudge__tips">
              {immediateTips.map((tip) => (
                <li key={tip}>{tip}</li>
              ))}
            </ul>
            <div className="nudge__actions">
              <span className="pill pill--solid">Respirer</span>
              <span className="pill">Ambiance</span>
              <span className="pill pill--icon">☰</span>
            </div>
          </div>

          <div className="warning">
            <h3>Quand consulter</h3>
            <ul>
              {redFlags.map((flag) => (
                <li key={flag}>{flag}</li>
              ))}
            </ul>
            <p>{medicalDisclaimer}</p>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
