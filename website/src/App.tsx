import { BreathSection } from "./components/BreathSection";
import { Cta } from "./components/Cta";
import { Faq } from "./components/Faq";
import { Features } from "./components/Features";
import { Footer } from "./components/Footer";
import { FunSection } from "./components/FunSection";
import { HelpSection } from "./components/HelpSection";
import { Hero } from "./components/Hero";
import { JournalSection } from "./components/JournalSection";
import { LiveActivitySection } from "./components/LiveActivitySection";
import { Nav } from "./components/Nav";
import { Privacy } from "./components/Privacy";
import { SeatedSection } from "./components/SeatedSection";
import { SoundSection } from "./components/SoundSection";
import { TrackingSection } from "./components/TrackingSection";
import { WatchSection } from "./components/WatchSection";
import { WeatherSection } from "./components/WeatherSection";
import { useDemoTimer } from "./hooks/useDemoTimer";
import { useT } from "./i18n";

export default function App() {
  // Un seul chronomètre pour toutes les maquettes de la page.
  const elapsed = useDemoTimer();
  const t = useT();

  return (
    <>
      <a className="skip-link" href="#contenu">
        {t.nav.skip}
      </a>

      <Nav />

      <main id="contenu">
        <Hero elapsed={elapsed} />
        <Features />
        <HelpSection />
        <SeatedSection />
        <BreathSection />
        <SoundSection />
        <LiveActivitySection elapsed={elapsed} />
        <WatchSection elapsed={elapsed} />
        <TrackingSection />
        <JournalSection />
        <FunSection />
        <WeatherSection />
        <Privacy />
        <Faq />
        <Cta />
      </main>

      <Footer />
    </>
  );
}
