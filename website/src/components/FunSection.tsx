import { badgeCount, badges, equivalences, funPoints } from "../content";
import { Checklist } from "./Checklist";
import { Reveal } from "./Reveal";

/** Section assumée : tout ce qui ne sert à rien mais qu'on regarde quand même. */
export function FunSection() {
  return (
    <section className="section section--alt" id="palmares">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">Inutile, donc indispensable</p>
          <h2>Un palmarès pour un sujet qui n'en méritait pas</h2>
          <p>
            {badgeCount} hauts faits calculés sur vos vraies visites, des équivalences
            rigoureusement absurdes, un titre honorifique et un certificat à faire circuler auprès
            de gens qui ne l'ont pas demandé.
          </p>
          <Checklist items={funPoints} />
        </Reveal>

        <Reveal className="split__visual">
          <div className="badges" role="img" aria-label="Exemples de hauts faits à débloquer">
            {badges.map((badge) => (
              <div className="badge-card" key={badge.title}>
                <strong>{badge.title}</strong>
                <span>{badge.detail}</span>
              </div>
            ))}
          </div>

          <div className="absurd">
            <p className="absurd__head">Votre temps, en unités plus parlantes</p>
            <ul>
              {equivalences.map((item) => (
                <li key={item.label}>
                  <strong>{item.value}</strong>
                  <span>{item.label}</span>
                </li>
              ))}
            </ul>
            <p className="absurd__foot">Exemple pour quelques heures d'historique.</p>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
