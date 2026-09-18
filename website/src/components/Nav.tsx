import { useEffect, useState } from "react";
import { useLanguage, useT } from "../i18n";
import { useStuckNav } from "../hooks/useStuckNav";
import { ThemeSwitch } from "./ThemeSwitch";

export function Nav() {
  const isStuck = useStuckNav();
  const t = useT();
  const { toggle } = useLanguage();
  const [open, setOpen] = useState(false);

  // Échap referme le menu : c'est attendu, et ça évite de rester coincé
  // derrière un panneau au clavier.
  useEffect(() => {
    if (!open) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === "Escape") setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open]);

  return (
    <header className={`nav${isStuck ? " is-stuck" : ""}`}>
      <div className="wrap nav__inner">
        <a className="brand" href="#" onClick={() => setOpen(false)}>
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
          <div className="nav__wide">
            <ThemeSwitch />
            <button type="button" className="lang" onClick={toggle} aria-label={t.switchLabel}>
              {t.switchTo}
            </button>
            <a className="btn btn--small" href="#disponibilite">
              {t.nav.cta}
            </a>
          </div>

          <button
            type="button"
            className={open ? "burger burger--on" : "burger"}
            aria-label={open ? t.nav.close : t.nav.open}
            aria-expanded={open}
            aria-controls="menu-principal"
            onClick={() => setOpen((ouvert) => !ouvert)}
          >
            <span className="burger__bars" aria-hidden="true">
              <span />
              <span />
              <span />
            </span>
          </button>
        </div>
      </div>

      <div className={open ? "menu menu--on" : "menu"} id="menu-principal">
        <nav className="menu__links" aria-label={t.nav.label}>
          {t.nav.links.map((link) => (
            <a key={link.href} href={link.href} onClick={() => setOpen(false)}>
              {link.label}
            </a>
          ))}
        </nav>

        <div className="menu__row">
          <span className="menu__label">{t.theme.label}</span>
          <ThemeSwitch />
        </div>
        <p className="menu__hint">{t.theme.hint}</p>

        <div className="menu__row">
          <span className="menu__label">{t.nav.languageLabel}</span>
          <button type="button" className="lang" onClick={toggle} aria-label={t.switchLabel}>
            {t.switchTo}
          </button>
        </div>

        <a className="btn menu__cta" href="#disponibilite" onClick={() => setOpen(false)}>
          {t.nav.cta}
        </a>
      </div>
    </header>
  );
}
