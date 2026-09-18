#!/usr/bin/env python3
"""Synthétise les ambiances sonores de l'app (WAV, sans dépendance externe).

Trois boucles de 12 secondes, mono 22,05 kHz : le raccord est fondu pour que la
lecture en boucle soit imperceptible. Les sons sont générés, donc libres de
droits.

Usage : python3 Support/Tools/make_soundscapes.py
"""
import math
import pathlib
import random
import struct
import wave

RATE = 22_050
SECONDS = 12
FADE = 1.5  # durée du fondu enchaîné au raccord de boucle
PEAK = 0.62


def white(count, rng):
    return [rng.gauss(0.0, 1.0) for _ in range(count)]


def one_pole_lowpass(samples, cutoff_hz):
    """Filtre passe-bas à un pôle (lissage exponentiel)."""
    alpha = 1.0 - math.exp(-2.0 * math.pi * cutoff_hz / RATE)
    out = []
    state = 0.0
    for sample in samples:
        state += alpha * (sample - state)
        out.append(state)
    return out


def one_pole_highpass(samples, cutoff_hz):
    low = one_pole_lowpass(samples, cutoff_hz)
    return [sample - filtered for sample, filtered in zip(samples, low)]


def normalize(samples, peak=PEAK):
    largest = max(abs(sample) for sample in samples) or 1.0
    return [sample * peak / largest for sample in samples]


def brown(count, rng):
    """Bruit brun : intégration du bruit blanc, avec une fuite pour éviter la dérive."""
    out = []
    state = 0.0
    for sample in white(count, rng):
        state = 0.995 * state + 0.05 * sample
        out.append(state)
    return normalize(out)


def rain(count, rng):
    """Pluie : bruit aigu, granulé par une modulation lente."""
    base = one_pole_highpass(white(count, rng), 900.0)
    base = one_pole_lowpass(base, 6_500.0)
    modulation = one_pole_lowpass(white(count, rng), 1.2)
    depth = max(abs(value) for value in modulation) or 1.0
    shaped = [
        sample * (0.78 + 0.22 * (value / depth))
        for sample, value in zip(base, modulation)
    ]
    return normalize(shaped)


def swell(count, rng):
    """Souffle : bruit brun respirant sur un cycle de dix secondes."""
    base = brown(count, rng)
    period = 10.0 * RATE
    shaped = [
        sample * (0.55 + 0.45 * (0.5 - 0.5 * math.cos(2.0 * math.pi * index / period)))
        for index, sample in enumerate(base)
    ]
    return normalize(shaped)


def loopable(samples, fade_samples):
    """Fond la queue sur la tête : la boucle ne s'entend plus."""
    body = samples[: len(samples) - fade_samples]
    tail = samples[len(samples) - fade_samples :]
    for index, sample in enumerate(tail):
        weight = index / fade_samples
        body[index] = body[index] * weight + sample * (1.0 - weight)
    return body


def write(path, samples):
    path.parent.mkdir(parents=True, exist_ok=True)
    frames = b"".join(
        struct.pack("<h", max(-32768, min(32767, int(sample * 32767))))
        for sample in samples
    )
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        handle.writeframes(frames)
    print(f"écrit {path.name} ({path.stat().st_size // 1024} Ko)")


GENERATORS = {
    "pluie": rain,
    "bruit-brun": brown,
    "souffle": swell,
}

if __name__ == "__main__":
    root = pathlib.Path(__file__).resolve().parents[1] / "Audio"
    total = int((SECONDS + FADE) * RATE)
    fade_samples = int(FADE * RATE)
    for index, (name, generator) in enumerate(GENERATORS.items()):
        rng = random.Random(1_000 + index)
        write(root / f"{name}.wav", loopable(generator(total, rng), fade_samples))
