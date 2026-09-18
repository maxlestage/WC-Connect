import { useEffect, useState } from "react";

/** Vrai dès que la page a défilé : sert à révéler la bordure de la barre de navigation. */
export function useStuckNav(threshold = 8): boolean {
  const [isStuck, setIsStuck] = useState(false);

  useEffect(() => {
    const onScroll = () => setIsStuck(window.scrollY > threshold);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, [threshold]);

  return isStuck;
}
