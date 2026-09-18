export function Footer() {
  return (
    <footer className="footer">
      <div className="wrap footer__inner">
        <div className="brand">
          <img src={`${import.meta.env.BASE_URL}logo.svg`} width={28} height={28} alt="" />
          <span>WC&nbsp;Connect</span>
        </div>
        <p>Fait avec sérieux pour un sujet qui ne l'est pas.</p>
      </div>
    </footer>
  );
}
