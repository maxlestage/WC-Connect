import { useT } from "../i18n";

export function Footer() {
  const t = useT();
  // Année réelle, plutôt qu'une date figée qui vieillit mal.
  const annee = new Date().getFullYear();

  return (
    <footer className="footer">
      <div className="wrap footer__grid">
        <div className="footer__brand">
          <div className="brand">
            <img src={`${import.meta.env.BASE_URL}logo.svg`} width={32} height={32} alt="" />
            <span>WC&nbsp;Connect</span>
          </div>
          <p className="footer__description">{t.footer.description}</p>
          <p className="footer__tagline">{t.footer.tagline}</p>
        </div>

        {t.footer.columns.map((colonne) => (
          <nav className="footer__column" key={colonne.title} aria-label={colonne.title}>
            <h2>{colonne.title}</h2>
            <ul>
              {colonne.links.map((lien) => (
                <li key={lien.href}>
                  <a href={lien.href}>{lien.label}</a>
                </li>
              ))}
            </ul>
          </nav>
        ))}

        <div className="footer__column">
          <h2>{t.footer.statusTitle}</h2>
          <p className="footer__status">{t.footer.status}</p>
          <h2 className="footer__credits-title">{t.footer.creditsTitle}</h2>
          <p className="footer__credits">
            {t.footer.credits.split("%@")[0]}
            <strong>{t.footer.author}</strong>
            {t.footer.credits.split("%@")[1]}
          </p>
        </div>
      </div>

      <div className="wrap footer__bottom">
        <p className="footer__copyright">{t.footer.copyright.replace("%@", String(annee))}</p>
        <a className="footer__top" href="#contenu">
          {t.footer.backToTop} ↑
        </a>
      </div>

      <div className="wrap footer__legal">
        <p>{t.footer.legal}</p>
        <p>{t.footer.medical}</p>
      </div>
    </footer>
  );
}
