import { navLinks } from "../content";
import { useStuckNav } from "../hooks/useStuckNav";

export function Nav() {
  const isStuck = useStuckNav();

  return (
    <header className={`nav${isStuck ? " is-stuck" : ""}`}>
      <div className="wrap nav__inner">
        <a className="brand" href="#">
          <img src="/logo.svg" width={36} height={36} alt="" />
          <span>WC&nbsp;Connect</span>
        </a>
        <nav className="nav__links" aria-label="Navigation principale">
          {navLinks.map((link) => (
            <a key={link.href} href={link.href}>
              {link.label}
            </a>
          ))}
        </nav>
        <a className="btn btn--small" href="#disponibilite">
          Disponibilité
        </a>
      </div>
    </header>
  );
}
