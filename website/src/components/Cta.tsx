import { Reveal } from "./Reveal";

export function Cta() {
  return (
    <section className="cta" id="disponibilite">
      <div className="wrap narrow">
        <Reveal>
          <h2>Bientôt dans votre poche</h2>
          <p>
            WC&nbsp;Connect est en cours de développement, en privé. L'app arrivera sur iPhone et
            Apple&nbsp;Watch ; d'ici là, la bêta se fait sur invitation.
          </p>
          <div className="hero__cta hero__cta--center">
            <a className="btn btn--ghost" href="#fonctions">
              Revoir les fonctions
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
