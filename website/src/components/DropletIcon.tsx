interface DropletIconProps {
  readonly size?: number;
}

/** Goutte du logo, réutilisée dans les maquettes. */
export function DropletIcon({ size = 26 }: DropletIconProps) {
  return (
    <svg viewBox="0 0 64 64" width={size} height={size} aria-hidden="true">
      <path
        d="M32 15c6 6.8 9.6 11.7 9.6 16.2A9.6 9.6 0 0 1 22.4 31.2C22.4 26.7 26 21.8 32 15Z"
        fill="currentColor"
      />
    </svg>
  );
}
