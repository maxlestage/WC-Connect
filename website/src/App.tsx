import { Cta } from "./components/Cta";
import { Faq } from "./components/Faq";
import { Features } from "./components/Features";
import { Footer } from "./components/Footer";
import { Hero } from "./components/Hero";
import { LiveActivitySection } from "./components/LiveActivitySection";
import { Nav } from "./components/Nav";
import { Privacy } from "./components/Privacy";
import { WatchSection } from "./components/WatchSection";
import { useDemoTimer } from "./hooks/useDemoTimer";

export default function App() {
  // Un seul chronomètre pour toutes les maquettes de la page.
  const elapsed = useDemoTimer();

  return (
    <>
      <a className="skip-link" href="#contenu">
        Aller au contenu
      </a>

      <Nav />

      <main id="contenu">
        <Hero elapsed={elapsed} />
        <Features />
        <LiveActivitySection elapsed={elapsed} />
        <WatchSection elapsed={elapsed} />
        <Privacy />
        <Faq />
        <Cta />
      </main>

      <Footer />
    </>
  );
}
