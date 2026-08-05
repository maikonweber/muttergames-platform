# -*- coding: utf-8 -*-
"""Generate simple procedural WAV SFX for the combat VS."""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

OUT = Path(r"C:\Users\plugify\Documents\project-fallen-tactics\assets\audio\sfx")
SR = 44100


def write_wav(path: Path, samples: list[float], sr: int = SR) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        frames = b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples
        )
        w.writeframes(frames)


def env(i: int, n: int, attack: float = 0.01, release: float = 0.2) -> float:
    t = i / max(1, n - 1)
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = min(1.0, (1.0 - t) / release) if release > 0 else 1.0
    return a * r


def tone(freq: float, dur: float, vol: float = 0.35, kind: str = "sine") -> list[float]:
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        if kind == "square":
            s = 1.0 if math.sin(2 * math.pi * freq * t) >= 0 else -1.0
        elif kind == "noise":
            # deterministic pseudo noise
            s = ((math.sin(i * 12.9898) * 43758.5453) % 1.0) * 2 - 1
        else:
            s = math.sin(2 * math.pi * freq * t)
        out.append(s * vol * env(i, n, 0.02, 0.35))
    return out


def mix(*tracks: list[float]) -> list[float]:
    m = max(len(t) for t in tracks)
    out = [0.0] * m
    for t in tracks:
        for i, v in enumerate(t):
            out[i] += v
    peak = max(1e-6, max(abs(x) for x in out))
    if peak > 0.95:
        out = [x * 0.95 / peak for x in out]
    return out


def slash() -> list[float]:
    # whoosh noise + descending tone
    n = int(SR * 0.18)
    out = []
    for i in range(n):
        t = i / SR
        noise = ((math.sin(i * 78.233) * 43758.5453) % 1.0) * 2 - 1
        f = 1200 - 700 * (i / n)
        s = math.sin(2 * math.pi * f * t)
        e = env(i, n, 0.01, 0.5)
        out.append((noise * 0.25 + s * 0.2) * e)
    return out


def hit() -> list[float]:
    return mix(
        tone(180, 0.08, 0.4, "sine"),
        tone(90, 0.12, 0.25, "square"),
    )


def block() -> list[float]:
    return mix(
        tone(420, 0.06, 0.3, "square"),
        tone(210, 0.1, 0.2, "sine"),
    )


def parry() -> list[float]:
    return mix(
        tone(880, 0.05, 0.28, "sine"),
        tone(1320, 0.07, 0.18, "sine"),
    )


def death() -> list[float]:
    n = int(SR * 0.35)
    out = []
    for i in range(n):
        t = i / SR
        f = 220 * (1.0 - 0.7 * i / n)
        s = math.sin(2 * math.pi * f * t)
        noise = ((math.sin(i * 12.9898) * 43758.5453) % 1.0) * 2 - 1
        out.append((s * 0.3 + noise * 0.08) * env(i, n, 0.02, 0.6))
    return out


def card() -> list[float]:
    return mix(tone(660, 0.04, 0.2), tone(990, 0.05, 0.12))


def ui_click() -> list[float]:
    return tone(520, 0.04, 0.22, "square")


def reward() -> list[float]:
    return mix(
        tone(523, 0.08, 0.2),
        tone(659, 0.1, 0.18),
        tone(784, 0.12, 0.16),
    )


def main() -> None:
    specs = {
        "slash_hit.wav": slash(),
        "hit.wav": hit(),
        "block.wav": block(),
        "parry.wav": parry(),
        "death.wav": death(),
        "card_play.wav": card(),
        "ui_click.wav": ui_click(),
        "reward.wav": reward(),
    }
    for name, samples in specs.items():
        path = OUT / name
        write_wav(path, samples)
        print("wrote", path, len(samples))


if __name__ == "__main__":
    main()
