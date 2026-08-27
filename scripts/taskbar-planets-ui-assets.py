#!/usr/bin/env python3
"""
TaskBar Planets Forger — pack de UI, planetas 2D e VFX.

Uso típico (após gerar imagens com Imagine / openrouter-image):

  python scripts/taskbar-planets-ui-assets.py init
  python scripts/taskbar-planets-ui-assets.py install --from-dir path/to/images
  python scripts/taskbar-planets-ui-assets.py catalog
  python scripts/taskbar-planets-ui-assets.py doctor

O script:
  - cria a árvore assets/generated/{planets,vfx,ui}
  - normaliza PNGs (resize, chroma #FF00FF opcional)
  - escreve catalog.json consumido pelo Godot
  - imprime briefs de prompt alinhados ao design system
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "TaskBarPlanetsForger" / "task-bar-planet-forger" / "assets" / "generated"
PLANETS = OUT / "planets"
VFX = OUT / "vfx"
UI = OUT / "ui"
CATALOG = OUT / "catalog.json"

# Magenta chave (mesmo contrato do shader chroma_key.gdshader)
CHROMA = (255, 0, 255, 255)

STYLE = (
    "stylized cosmic workshop idle-game art for TaskBar Planets Forger, "
    "deep navy space mood, cyan and solar-gold accents, clean silhouette, "
    "solid pure magenta #FF00FF background, no text, no watermark, game asset"
)

MANIFEST = {
    "version": 2,
    "generator": "taskbar-planets-ui-assets",
    "style": "cosmic-workshop-pixel-stylized",
    "chroma_key": "#FF00FF",
    "planets": {
        "Oceanico": {
            "file": "planets/planet-oceanic.png",
            "size": 512,
            "prompt": (
                f"stylized oceanic planet globe icon, cyan oceans, soft white cloud bands, "
                f"small green continents, gentle rim light, centered sphere, {STYLE}"
            ),
        },
        "Rochoso": {
            "file": "planets/planet-rocky.png",
            "size": 512,
            "prompt": (
                f"stylized rocky planet globe icon, dusty ochre and rust craters, dry surface, "
                f"subtle rim light, centered sphere, {STYLE}"
            ),
        },
        "Vulcanico": {
            "file": "planets/planet-volcanic.png",
            "size": 512,
            "prompt": (
                f"stylized volcanic planet globe icon, charcoal rock with glowing orange lava cracks, "
                f"emissive fissures, centered sphere, {STYLE}"
            ),
        },
        "Desertico": {
            "file": "planets/planet-desert.png",
            "size": 512,
            "prompt": (
                f"stylized desert planet globe icon, amber sand dunes, violet shadows, dusty bands, "
                f"centered sphere, {STYLE}"
            ),
        },
        "Congelado": {
            "file": "planets/planet-ice.png",
            "size": 512,
            "prompt": (
                f"stylized frozen ice planet globe icon, pale blue ice, white polar caps, "
                f"subtle aurora tint, centered sphere, {STYLE}"
            ),
        },
        "Gasoso": {
            "file": "planets/planet-gas.png",
            "size": 512,
            "prompt": (
                f"stylized gas giant globe icon, indigo and rose cloud bands, one large storm spot, "
                f"centered sphere, {STYLE}"
            ),
        },
        "Vivo": {
            "file": "planets/planet-living.png",
            "size": 512,
            "prompt": (
                f"stylized living garden planet globe icon, lush continents, soft bioluminescent coastlines, "
                f"thin blue atmosphere, centered sphere, {STYLE}"
            ),
        },
        "Maquina": {
            "file": "planets/planet-machine.png",
            "size": 512,
            "prompt": (
                f"stylized machine megacity planet globe icon, geometric city lights, steel continents, "
                f"neon cyan grid glow, centered sphere, {STYLE}"
            ),
        },
    },
    "props": {
        "sun": {
            "file": "planets/prop-sun.png",
            "size": 256,
            "prompt": (
                f"stylized sun star icon sphere, bright solar gold and warm yellow core glow, "
                f"soft corona, clean circle, {STYLE}"
            ),
        },
        "asteroid": {
            "file": "planets/prop-asteroid.png",
            "size": 256,
            "prompt": (
                f"stylized asteroid rock chunk icon, irregular craggy stone gray-brown, "
                f"floating space rock, not a planet, {STYLE}"
            ),
        },
    },
    "vfx": {
        "forge_burst": {
            "file": "vfx/vfx-forge-burst.png",
            "size": 512,
            "prompt": (
                f"stylized cosmic forge burst VFX sprite, cyan and gold energy explosion with soft particles "
                f"and bright core, radial glow, centered, transparent-ready edges on magenta, {STYLE}"
            ),
        },
        "terraform": {
            "file": "vfx/vfx-terraform.png",
            "size": 512,
            "prompt": (
                f"stylized terraform aqua mist VFX sprite, rising cyan water vapor rings and soft green "
                f"atmosphere sparkles around empty center for planet overlay, {STYLE}"
            ),
        },
        "life_bloom": {
            "file": "vfx/vfx-life-bloom.png",
            "size": 512,
            "prompt": (
                f"stylized life bloom VFX sprite, soft green bioluminescent petals and spore particles "
                f"radiating from center, gentle glow, {STYLE}"
            ),
        },
        "supernova": {
            "file": "vfx/vfx-supernova.png",
            "size": 512,
            "prompt": (
                f"stylized supernova VFX sprite, brilliant white-gold core with magenta-violet shockwave "
                f"ring and star particles, epic but readable at small size, {STYLE}"
            ),
        },
    },
    "ui": {
        "panel_main": {
            "file": "ui/ui-panel-main.png",
            "size": 512,
            "prompt": (
                "empty game UI panel frame for cosmic idle game, deep navy #0D1430 fill, cyan #55D9FF "
                "thin border, soft corner ornaments only in corners for 9-slice, blank center, no text, "
                "no icons, solid pure magenta #FF00FF outside the panel silhouette"
            ),
        },
        "panel_card": {
            "file": "ui/ui-panel-card.png",
            "size": 256,
            "prompt": (
                "empty small UI resource card frame, deep navy fill, soft cyan border, rounded corners, "
                "blank center, no text, solid pure magenta #FF00FF background"
            ),
        },
        "button_normal": {
            "file": "ui/ui-button-normal.png",
            "size": 256,
            "prompt": (
                "empty rectangular game UI button, raised navy panel, cyan edge, blank center, no text, "
                "solid pure magenta #FF00FF background"
            ),
        },
        "button_hover": {
            "file": "ui/ui-button-hover.png",
            "size": 256,
            "prompt": (
                "empty rectangular game UI button hover state, brighter cyan glow edge, same shape as "
                "standard button, blank center, no text, solid pure magenta #FF00FF background"
            ),
        },
        "button_pressed": {
            "file": "ui/ui-button-pressed.png",
            "size": 256,
            "prompt": (
                "empty rectangular game UI button pressed state, darker inset navy, gold edge accent, "
                "same geometry, blank center, no text, solid pure magenta #FF00FF background"
            ),
        },
        "bar_frame": {
            "file": "ui/ui-bar-frame.png",
            "size": 256,
            "prompt": (
                "horizontal game progress bar empty frame only, thin cyan border, deep navy trough, "
                "no fill, no text, solid pure magenta #FF00FF background"
            ),
        },
        "bar_fill": {
            "file": "ui/ui-bar-fill.png",
            "size": 256,
            "prompt": (
                "horizontal game progress bar fill segment, glowing cyan-to-gold gradient, soft glow, "
                "no frame, no text, solid pure magenta #FF00FF background"
            ),
        },
        "icon_materia": {
            "file": "ui/icon-materia.png",
            "size": 128,
            "prompt": (
                f"flat game resource icon diamond crystal of cosmic matter, warm bronze, centered, {STYLE}"
            ),
        },
        "icon_energia": {
            "file": "ui/icon-energia.png",
            "size": 128,
            "prompt": (
                f"flat game resource icon lightning bolt energy, solar gold, centered, {STYLE}"
            ),
        },
        "icon_agua": {
            "file": "ui/icon-agua.png",
            "size": 128,
            "prompt": (
                f"flat game resource icon water drop, cosmic cyan, centered, {STYLE}"
            ),
        },
        "icon_biomassa": {
            "file": "ui/icon-biomassa.png",
            "size": 128,
            "prompt": (
                f"flat game resource icon leaf sprout biomass, life green, centered, {STYLE}"
            ),
        },
        "icon_conhecimento": {
            "file": "ui/icon-conhecimento.png",
            "size": 128,
            "prompt": (
                f"flat game resource icon open star-book knowledge, nebula violet, centered, {STYLE}"
            ),
        },
    },
}


def _ensure_dirs() -> None:
    for d in (PLANETS, VFX, UI):
        d.mkdir(parents=True, exist_ok=True)


def cmd_init(_: argparse.Namespace) -> int:
    _ensure_dirs()
    briefs = OUT / "PROMPTS.md"
    lines = [
        "# Briefs — TaskBar Planets UI / Planetas / VFX",
        "",
        "Gere cada asset (Imagine / openrouter-image) com o prompt abaixo.",
        "Fundo **magenta puro `#FF00FF`**. Sem texto. Depois:",
        "",
        "```bash",
        "python scripts/taskbar-planets-ui-assets.py install --from-dir <pasta-com-pngs>",
        "python scripts/taskbar-planets-ui-assets.py catalog",
        "```",
        "",
        "Ou copie manualmente para os caminhos `file` listados.",
        "",
    ]
    for section in ("planets", "props", "vfx", "ui"):
        lines.append(f"## {section}")
        lines.append("")
        for key, meta in MANIFEST[section].items():
            lines.append(f"### {key} → `{meta['file']}` ({meta['size']}px)")
            lines.append("")
            lines.append(f"> {meta['prompt']}")
            lines.append("")
    briefs.write_text("\n".join(lines), encoding="utf-8")
    write_catalog()
    print(f"init OK → {OUT}")
    print(f"prompts → {briefs}")
    return 0


def _try_pil():
    try:
        from PIL import Image  # type: ignore

        return Image
    except Exception:
        return None


def _normalize_png(src: Path, dest: Path, size: int, enforce_chroma: bool) -> None:
    Image = _try_pil()
    dest.parent.mkdir(parents=True, exist_ok=True)
    if Image is None:
        shutil.copy2(src, dest)
        return
    im = Image.open(src).convert("RGBA")
    # Square pad/crop to center
    w, h = im.size
    side = max(w, h)
    canvas = Image.new("RGBA", (side, side), CHROMA if enforce_chroma else (0, 0, 0, 0))
    canvas.paste(im, ((side - w) // 2, (side - h) // 2), im)
    if size > 0 and side != size:
        canvas = canvas.resize((size, size), Image.Resampling.LANCZOS)
    if enforce_chroma:
        # Converte magenta em alpha real — funciona com draw_texture_rect e TextureRect
        # sem precisar do shader chroma_key (que continua opcional em VFX).
        px = canvas.load()
        for y in range(canvas.height):
            for x in range(canvas.width):
                r, g, b, a = px[x, y]
                if a < 8:
                    px[x, y] = (0, 0, 0, 0)
                    continue
                if r > 200 and b > 200 and g < 90:
                    px[x, y] = (0, 0, 0, 0)
                elif r > 180 and b > 180 and g < 120 and abs(r - b) < 40:
                    soft = max(0, min(255, int((g - 40) * 3)))
                    if soft < a:
                        px[x, y] = (r, g, b, soft)
    canvas.save(dest, "PNG")


def _collect_sources(from_dir: Path) -> dict[str, Path]:
    """Map logical keys / filenames to source paths."""
    mapping: dict[str, Path] = {}
    for p in from_dir.rglob("*"):
        if p.suffix.lower() not in {".png", ".jpg", ".jpeg", ".webp"}:
            continue
        mapping[p.name.lower()] = p
        mapping[p.stem.lower()] = p
    return mapping


def _guess_source(sources: dict[str, Path], key: str, file_rel: str) -> Path | None:
    candidates = [
        Path(file_rel).name.lower(),
        Path(file_rel).stem.lower(),
        key.lower(),
        key.lower().replace("_", "-"),
        f"planet-{key.lower()}",
        f"vfx-{key.lower().replace('_', '-')}",
        f"ui-{key.lower().replace('_', '-')}",
        f"icon-{key.lower().replace('icon_', '')}",
        f"prop-{key.lower()}",
    ]
    # friendly aliases
    aliases = {
        "oceanico": ["planet-oceanic", "oceanic", "ocean"],
        "rochoso": ["planet-rocky", "rocky"],
        "vulcanico": ["planet-volcanic", "volcanic"],
        "desertico": ["planet-desert", "desert"],
        "congelado": ["planet-ice", "ice", "frozen"],
        "gasoso": ["planet-gas", "gas"],
        "vivo": ["planet-living", "living"],
        "maquina": ["planet-machine", "machine"],
        "forge_burst": ["vfx-forge-burst", "forge-burst", "forge"],
        "life_bloom": ["vfx-life-bloom", "life-bloom"],
        "icon_materia": ["icon-materia", "materia"],
        "icon_energia": ["icon-energia", "energia", "energy"],
        "icon_agua": ["icon-agua", "agua", "water"],
        "icon_biomassa": ["icon-biomassa", "biomassa"],
        "icon_conhecimento": ["icon-conhecimento", "conhecimento"],
        "button_normal": ["ui-button-normal", "button-normal"],
        "button_hover": ["ui-button-hover", "button-hover"],
        "button_pressed": ["ui-button-pressed", "button-pressed"],
        "panel_main": ["ui-panel-main", "panel-main"],
        "panel_card": ["ui-panel-card", "panel-card"],
        "bar_frame": ["ui-bar-frame", "bar-frame"],
        "bar_fill": ["ui-bar-fill", "bar-fill"],
    }
    candidates.extend(aliases.get(key.lower(), []))
    for c in candidates:
        if c in sources:
            return sources[c]
    # fuzzy contains
    for name, path in sources.items():
        if key.lower().replace("_", "") in name.replace("-", "").replace("_", ""):
            return path
    return None


def cmd_install(args: argparse.Namespace) -> int:
    _ensure_dirs()
    from_dir = Path(args.from_dir).resolve()
    if not from_dir.is_dir():
        print(f"erro: pasta não encontrada: {from_dir}", file=sys.stderr)
        return 1
    sources = _collect_sources(from_dir)
    installed = 0
    missing: list[str] = []
    for section in ("planets", "props", "vfx", "ui"):
        for key, meta in MANIFEST[section].items():
            dest = OUT / meta["file"]
            src = _guess_source(sources, key, meta["file"])
            if src is None:
                missing.append(f"{section}/{key} → {meta['file']}")
                continue
            enforce = section in {"planets", "props", "vfx", "ui"}
            _normalize_png(src, dest, int(meta.get("size", 0)), enforce_chroma=enforce)
            print(f"  OK  {src.name} → {meta['file']}")
            installed += 1
    write_catalog()
    print(f"instalados: {installed}")
    if missing:
        print("ainda faltam:")
        for m in missing:
            print(f"  - {m}")
    return 0 if installed else 2


def write_catalog() -> None:
    _ensure_dirs()

    def res_path(rel: str) -> str:
        return f"res://assets/generated/{rel.replace(chr(92), '/')}"

    archetypes = {}
    for key, meta in MANIFEST["planets"].items():
        path = OUT / meta["file"]
        if path.exists():
            archetypes[key] = {
                "preview": res_path(meta["file"]),
                "source": "generated-2d",
            }
    # aliases for class names used in code
    if "Oceanico" in archetypes:
        archetypes.setdefault("Vivo", dict(archetypes["Oceanico"]))
    if "Rochoso" in archetypes:
        archetypes.setdefault("Maquina", dict(archetypes["Rochoso"]))

    props = {}
    for key, meta in MANIFEST["props"].items():
        path = OUT / meta["file"]
        if path.exists():
            props[key] = {"preview": res_path(meta["file"]), "source": "generated-2d"}

    vfx = {}
    for key, meta in MANIFEST["vfx"].items():
        path = OUT / meta["file"]
        if path.exists():
            vfx[key] = {"texture": res_path(meta["file"]), "source": "generated-2d"}

    ui = {}
    for key, meta in MANIFEST["ui"].items():
        path = OUT / meta["file"]
        if path.exists():
            ui[key] = {"texture": res_path(meta["file"]), "source": "generated-2d"}

    catalog = {
        "generator": MANIFEST["generator"],
        "version": MANIFEST["version"],
        "chroma_key": MANIFEST["chroma_key"],
        "note": "2D generated pack for offline UI/planets/VFX. Meshy 3D pack remains optional in assets/meshy/.",
        "archetypes": archetypes,
        "props": props,
        "vfx": vfx,
        "ui": ui,
    }
    CATALOG.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"catalog → {CATALOG}")


def cmd_catalog(_: argparse.Namespace) -> int:
    write_catalog()
    return 0


def cmd_prompts(_: argparse.Namespace) -> int:
    for section in ("planets", "props", "vfx", "ui"):
        print(f"## {section}")
        for key, meta in MANIFEST[section].items():
            print(f"[{key}] {meta['file']}")
            print(meta["prompt"])
            print()
    return 0


def cmd_doctor(_: argparse.Namespace) -> int:
    _ensure_dirs()
    total = 0
    present = 0
    for section in ("planets", "props", "vfx", "ui"):
        for key, meta in MANIFEST[section].items():
            total += 1
            path = OUT / meta["file"]
            ok = path.exists()
            present += int(ok)
            mark = "OK" if ok else "MISS"
            print(f"[{mark}] {section}/{key}: {meta['file']}")
    print(f"{present}/{total} assets")
    print(f"PIL: {'yes' if _try_pil() else 'no (copy-only install)'}")
    print(f"catalog: {'yes' if CATALOG.exists() else 'no'}")
    return 0 if present == total else 1


def main() -> int:
    parser = argparse.ArgumentParser(description="TaskBar Planets UI/planets/VFX asset pack")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_init = sub.add_parser("init", help="Cria pastas, PROMPTS.md e catalog vazio")
    p_init.set_defaults(func=cmd_init)

    p_inst = sub.add_parser("install", help="Copia/normaliza PNGs de uma pasta para o pack")
    p_inst.add_argument("--from-dir", required=True, help="Pasta com imagens geradas")
    p_inst.set_defaults(func=cmd_install)

    p_cat = sub.add_parser("catalog", help="Reescreve catalog.json a partir dos arquivos existentes")
    p_cat.set_defaults(func=cmd_catalog)

    p_pr = sub.add_parser("prompts", help="Imprime prompts do manifesto")
    p_pr.set_defaults(func=cmd_prompts)

    p_doc = sub.add_parser("doctor", help="Lista assets presentes/faltantes")
    p_doc.set_defaults(func=cmd_doctor)

    args = parser.parse_args()
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
