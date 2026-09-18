import { soundPoints, soundscapes } from "../content";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section « Son » : ambiances embarquées et commande de votre musique. */
export function SoundSection() {
  return (
    <section className="section section--alt" id="son">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">Ambiances &amp; musique</p>
          <h2>Votre musique, plus un fond sonore</h2>
          <p>
            WC&nbsp;Connect ne diffuse aucun catalogue : elle télécommande ce que vous écoutez
            déjà, Apple&nbsp;Music comprise. Et elle ajoute trois ambiances synthétisées, qui se
            mélangent au morceau en cours sans l'interrompre.
          </p>
          <Checklist items={soundPoints} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="player" role="img" aria-label="Lecteur de l'app : morceau en cours et ambiances sonores">
            <div className="player__track">
              <div className="player__art" aria-hidden="true">
                ♪
              </div>
              <div className="player__meta">
                <strong>Votre morceau</strong>
                <span>Depuis votre bibliothèque</span>
              </div>
              <div className="player__controls" aria-hidden="true">
                <span>⏮</span>
                <span className="player__play">⏸</span>
                <span>⏭</span>
              </div>
            </div>

            <div className="player__sounds">
              {soundscapes.map((sound, index) => (
                <div className={`sound${index === 0 ? " sound--on" : ""}`} key={sound.title}>
                  <div className="sound__bars" aria-hidden="true">
                    {[0, 1, 2, 3].map((bar) => (
                      <span key={bar} style={{ animationDelay: `${bar * 0.18}s` }} />
                    ))}
                  </div>
                  <strong>{sound.title}</strong>
                  <span>{sound.detail}</span>
                </div>
              ))}
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
