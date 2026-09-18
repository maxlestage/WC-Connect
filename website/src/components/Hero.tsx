import { PhoneMockup } from "./PhoneMockup";
import { Reveal } from "./Reveal";
import { WatchMockup } from "./WatchMockup";

interface HeroProps {
  readonly elapsed: number;
}

const facts = [
  { value: "1 geste", label: "pour démarrer" },
  { value: "0 donnée", label: "envoyée en ligne" },
  { value: "2 appareils", label: "synchronisés" },
] as const;

export function Hero({ elapsed }: HeroProps) {
  return (
    <section className="hero">
      <div className="wrap hero__inner">
        <Reveal className="hero__text">
          <p className="eyebrow">iPhone · Apple Watch · Live Activity</p>
          <h1>
            Chaque pause
            <br />
            compte vraiment.
          </h1>
          <p className="lead">
            WC&nbsp;Connect chronomètre vos passages aux toilettes d'un seul geste, affiche le temps
            écoulé sur l'écran verrouillé et dans la Dynamic Island, et vous laisse tout piloter
            depuis votre poignet. Sans compte, sans serveur, sans jugement.
          </p>
          <div className="hero__cta">
            <a className="btn" href="#telecharger">
              Essayer WC&nbsp;Connect
            </a>
            <a className="btn btn--ghost" href="#live">
              Voir la Live Activity
            </a>
          </div>
          <ul className="hero__facts">
            {facts.map((fact) => (
              <li key={fact.value}>
                <strong>{fact.value}</strong>
                <span>{fact.label}</span>
              </li>
            ))}
          </ul>
        </Reveal>

        <Reveal className="hero__devices">
          <PhoneMockup elapsed={elapsed} />
          <WatchMockup elapsed={elapsed} />
        </Reveal>
      </div>
    </section>
  );
}
