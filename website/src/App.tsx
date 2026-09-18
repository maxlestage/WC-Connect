import { BreathSection } from "./components/BreathSection";
import { Cta } from "./components/Cta";
import { Faq } from "./components/Faq";
import { Features } from "./components/Features";
import { Footer } from "./components/Footer";
import { HelpSection } from "./components/HelpSection";
import { Hero } from "./components/Hero";
import { LiveActivitySection } from "./components/LiveActivitySection";
import { Nav } from "./components/Nav";
import { Privacy } from "./components/Privacy";
import { SoundSection } from "./components/SoundSection";
import { TrackingSection } from "./components/TrackingSection";
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
        <HelpSection />
        <BreathSection />
        <SoundSection />
        <LiveActivitySection elapsed={elapsed} />
        <WatchSection elapsed={elapsed} />
        <TrackingSection />
        <Privacy />
        <Faq />
        <Cta />
      </main>

      <Footer />
    </>
  );
}
