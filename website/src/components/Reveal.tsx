import type { ElementType, ReactNode } from "react";
import { useReveal } from "../hooks/useReveal";

interface RevealProps {
  readonly children: ReactNode;
  /** Balise rendue (div par défaut). */
  readonly as?: ElementType;
  readonly className?: string;
}

/** Enveloppe un bloc et le fait apparaître à l'entrée dans le viewport. */
export function Reveal({ children, as: Tag = "div", className }: RevealProps) {
  const { ref, isVisible } = useReveal<HTMLDivElement>();
  const classes = ["reveal", isVisible ? "is-visible" : "", className ?? ""]
    .filter(Boolean)
    .join(" ");

  return (
    <Tag ref={ref} className={classes}>
      {children}
    </Tag>
  );
}
