import { privacyTags } from "../content";
import { Reveal } from "./Reveal";

export function Privacy() {
  return (
    <section className="section" id="confidentialite">
      <div className="wrap narrow">
        <Reveal>
          <p className="eyebrow">Confidentialité</p>
          <h2>Vos pauses ne regardent personne</h2>
          <p className="section__lead">
            Aucun compte, aucune analyse, aucun serveur. L'historique vit dans un espace partagé
            entre l'app, les widgets et la montre, sur vos appareils uniquement. La synchronisation
            iPhone ↔ Watch passe par WatchConnectivity, en direct, d'appareil à appareil.
          </p>
          <div className="pills">
            {privacyTags.map((tag) => (
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
