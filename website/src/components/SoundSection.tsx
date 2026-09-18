import { useT } from "../i18n";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section « Son » : ambiances embarquées et commande de votre musique. */
export function SoundSection() {
  const t = useT();

  return (
    <section className="section section--alt" id="son">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">{t.sound.eyebrow}</p>
          <h2>{t.sound.title}</h2>
          <p>{t.sound.body}</p>
          <Checklist items={t.sound.points} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="player" role="img" aria-label={t.sound.playerAlt}>
            <div className="player__track">
              <div className="player__art" aria-hidden="true">
                ♪
              </div>
              <div className="player__meta">
                <strong>{t.sound.trackTitle}</strong>
                <span>{t.sound.trackSubtitle}</span>
              </div>
              <div className="player__controls" aria-hidden="true">
                <span>⏮</span>
                <span className="player__play">⏸</span>
                <span>⏭</span>
              </div>
            </div>

            <div className="player__sounds">
              {t.sound.soundscapes.map((sound, index) => (
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
