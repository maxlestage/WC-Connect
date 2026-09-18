import { Reveal } from "./Reveal";

const REPO_URL = "https://github.com/maxlestage/WC-Connect";

export function Cta() {
  return (
    <section className="cta" id="telecharger">
      <div className="wrap narrow">
        <Reveal>
          <h2>Prêt à chronométrer ?</h2>
          <p>
            Le projet est open source : clonez le dépôt, ouvrez le projet Xcode, et lancez l'app sur
            votre iPhone et votre Watch.
          </p>
          <div className="hero__cta hero__cta--center">
            <a className="btn" href={REPO_URL}>
              Voir le dépôt
            </a>
            <a className="btn btn--ghost" href={`${REPO_URL}#installation`}>
              Instructions d'installation
            </a>
          </div>
          <p className="fine">
            Projet indépendant, non affilié à Apple. iPhone, Apple&nbsp;Watch, Siri et Dynamic Island
            sont des marques d'Apple&nbsp;Inc.
          </p>
        </Reveal>
      </div>
    </section>
  );
}
