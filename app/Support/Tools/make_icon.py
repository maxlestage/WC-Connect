#!/usr/bin/env python3
"""Génère les icônes de l'app (PNG sans dépendance externe).

Usage : python3 Support/Tools/make_icon.py
Écrit Support/Assets.xcassets/AppIcon.appiconset/icon-1024.png
et Support/WatchAssets.xcassets/AppIcon.appiconset/icon-1024.png
"""
import math
import pathlib
import struct
import zlib

SIZE = 1024
TOP = (0x33, 0xA9, 0xF7)
BOTTOM = (0x1C, 0x66, 0xC7)


def lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def coverage(px, py, inside, samples=3):
    """Anti-aliasing par super-échantillonnage."""
    hits = 0
    step = 1.0 / (samples + 1)
    for i in range(1, samples + 1):
        for j in range(1, samples + 1):
            if inside(px + i * step, py + j * step):
                hits += 1
    return hits / (samples * samples)


def droplet(x, y):
    """Goutte : disque du bas + pointe effilée vers le haut."""
    cx, cy, r = SIZE / 2, SIZE * 0.605, SIZE * 0.175
    if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
        return True
    tip_y = SIZE * 0.325
    if tip_y <= y < cy:
        # Profil quadratique : la largeur s'annule à la pointe.
        t = (y - tip_y) / (cy - tip_y)
        return abs(x - cx) <= r * (t ** 1.35)
    return False


def ring(x, y):
    """Anneau « chronomètre » autour de la goutte."""
    cx, cy = SIZE / 2, SIZE / 2
    d = math.hypot(x - cx, y - cy)
    return SIZE * 0.335 <= d <= SIZE * 0.368


def png(path):
    rows = []
    for y in range(SIZE):
        row = bytearray([0])  # filtre 0 par scanline
        base = lerp(TOP, BOTTOM, y / (SIZE - 1))
        for x in range(SIZE):
            alpha = coverage(x, y, droplet)
            if alpha == 0:
                alpha = coverage(x, y, ring) * 0.75
            if alpha <= 0:
                row += bytes(base)
            else:
                row += bytes(lerp(base, (255, 255, 255), min(1.0, alpha)))
        rows.append(bytes(row))

    raw = zlib.compress(b"".join(rows), 9)

    def chunk(tag, data):
        payload = tag + data
        return struct.pack(">I", len(data)) + payload + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", raw) + chunk(b"IEND", b"")
    )
    print(f"écrit {path} ({path.stat().st_size // 1024} Ko)")


if __name__ == "__main__":
    root = pathlib.Path(__file__).resolve().parents[1]
    image = root / "Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    png(image)
    watch = root / "WatchAssets.xcassets/AppIcon.appiconset/icon-1024.png"
    watch.parent.mkdir(parents=True, exist_ok=True)
    watch.write_bytes(image.read_bytes())
    print(f"écrit {watch}")
