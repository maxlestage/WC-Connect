import { useT } from "../i18n";

export function Footer() {
  const t = useT();

  return (
    <footer className="footer">
      <div className="wrap footer__inner">
        <div className="brand">
          <img src={`${import.meta.env.BASE_URL}logo.svg`} width={28} height={28} alt="" />
          <span>WC&nbsp;Connect</span>
        </div>
        <p>{t.footer.tagline}</p>
      </div>
    </footer>
  );
}
