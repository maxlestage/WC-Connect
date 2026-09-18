import { features } from "../content";
import { Reveal } from "./Reveal";

export function Features() {
  return (
    <section className="section" id="fonctions">
      <div className="wrap">
        <Reveal as="h2">Tout ce qu'il faut, rien de plus</Reveal>
        <Reveal as="p" className="section__lead">
          Une app qui s'ouvre, s'utilise et se referme en moins de trois secondes.
        </Reveal>

        <div className="grid">
          {features.map((feature) => (
            <Reveal as="article" className="card" key={feature.title}>
              <h3>{feature.title}</h3>
              <p>{feature.description}</p>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
