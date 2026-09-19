import { useT } from "../i18n";
import { LeafIcon } from "./LeafIcon";

/**
 * Maquettes du hero en mode serein.
 *
 * Elles ne portent volontairement aucun chiffre qui avance : c'est tout
 * l'objet du mode serein, et c'est ce que la première page doit montrer.
 * Le chronomètre existe toujours dans l'app — il se voit plus bas, dans la
 * section Live Activity, pour qui le veut.
 */

/** Écran verrouillé d'iPhone, mode serein. */
export function CalmPhoneMockup() {
  const t = useT();

  return (
    <div className="phone" role="img" aria-label={t.hero.phoneAlt}>
      <div className="phone__screen">
        <div className="island">
          <span className="island__dot island__dot--calm" />
          <span className="island__label">{t.hero.islandLabel}</span>
        </div>

        <div className="phone__time">{t.hero.lockTime}</div>
        <div className="phone__date">{t.hero.lockDate}</div>

        <div className="activity">
          <div className="activity__icon activity__icon--calm">
            <LeafIcon />
          </div>
          <div className="activity__body">
            <p className="activity__label">{t.hero.activityLabel}</p>
            <p className="activity__calm">{t.hero.activityTitle}</p>
            <p className="activity__meta">{t.hero.activityMeta}</p>
          </div>
          <div className="activity__action" aria-hidden="true">
            ✓
          </div>
        </div>

        <div className="activity activity--night">
          <span className="night__dot" aria-hidden="true" />
          <span className="night__label">{t.hero.nightLabel}</span>
          <span className="night__value">{t.hero.nightValue}</span>
        </div>
      </div>
    </div>
  );
}

/** Apple Watch, mode serein : un souffle, pas un compte. */
export function CalmWatchMockup() {
  const t = useT();

  return (
    <div className="watch" role="img" aria-label={t.hero.watchAlt}>
      <div className="watch__screen">
        <div className="ring ring--calm">
          <span className="ring__halo" aria-hidden="true" />
          <span className="ring__halo ring__halo--inner" aria-hidden="true" />
          <div className="ring__label">
            <span className="ring__calm">{t.hero.watchCalm}</span>
            <small>{t.hero.watchPlace}</small>
          </div>
        </div>
        <div className="watch__button">{t.hero.watchButton}</div>
      </div>
    </div>
  );
}
