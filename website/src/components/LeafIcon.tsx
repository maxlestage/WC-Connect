interface LeafIconProps {
  readonly size?: number;
}

/** Feuille du mode serein : le symbole qui remplace le chronomètre. */
export function LeafIcon({ size = 26 }: LeafIconProps) {
  return (
    <svg viewBox="0 0 64 64" width={size} height={size} aria-hidden="true">
      <path
        d="M47 14c2 14-2.5 24-11 29.5-5.6 3.6-11.6 3.3-15.4-.6-3.9-3.8-4.1-9.8-.5-15.4C25.6 19 35.6 14.5 47 14Z"
        fill="currentColor"
      />
      <path
        d="M41 21 19 47"
        stroke="currentColor"
        strokeWidth="3"
        strokeLinecap="round"
        fill="none"
        opacity="0.45"
      />
    </svg>
  );
}
