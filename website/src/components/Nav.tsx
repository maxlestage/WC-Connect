import { useLanguage, useT } from "../i18n";
import { useStuckNav } from "../hooks/useStuckNav";

export function Nav() {
  const isStuck = useStuckNav();
  const t = useT();
  const { toggle } = useLanguage();

  return (
    <header className={`nav${isStuck ? " is-stuck" : ""}`}>
      <div className="wrap nav__inner">
        <a className="brand" href="#">
          <img src={`${import.meta.env.BASE_URL}logo.svg`} width={36} height={36} alt="" />
          <span>WC&nbsp;Connect</span>
        </a>
        <nav className="nav__links" aria-label={t.nav.label}>
          {t.nav.links.map((link) => (
            <a key={link.href} href={link.href}>
              {link.label}
            </a>
          ))}
        </nav>
        <div className="nav__actions">
          <button type="button" className="lang" onClick={toggle} aria-label={t.switchLabel}>
            {t.switchTo}
          </button>
          <a className="btn btn--small" href="#disponibilite">
            {t.nav.cta}
          </a>
        </div>
      </div>
    </header>
  );
}
