#!/usr/bin/env python3
"""Valida o grafo de EP01 e a tabela de eventos. Sem Godot.

  python game-narrativo/data/validate.py
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CRITICAL_PREFIXES = ("ep01_crit_", "ep02_crit_", "ep03_crit_", "ending_", "route_lock_")
DENY_FLAGS = {
    "ep01_viu_foto_iris",
    "ep01_ally_theo",
    "ep01_ally_gael",
    "ep01_ally_noah",
    "ep01_ally_luna",
    "ep01_ally_bia",
}
DENY_EVIDENCE = {
    "ev_colar_iris",
    "ev_iris_foto_recente",
    "ev_nexo_predicao",
    "ev_bolsa_inconsistente",
    "ev_msg_ameaca",
}


def fail(msg: str) -> None:
    print(f"FAIL {msg}")
    raise SystemExit(1)


def walk_effects(effects: list, origin: str) -> None:
    for eff in effects or []:
        t = eff.get("type")
        if t == "flag":
            flag = str(eff.get("flag", ""))
            if flag in DENY_FLAGS or flag.startswith(CRITICAL_PREFIXES):
                fail(f"{origin} seta flag proibida {flag}")
        if t == "evidence" and eff.get("id") in DENY_EVIDENCE:
            fail(f"{origin} concede evidência canônica {eff.get('id')}")
        if t in ("affinity", "trust") and abs(int(eff.get("delta", 0))) > 5:
            fail(f"{origin} delta relacional > 5")
        if t == "courage" and abs(int(eff.get("delta", 0))) > 1:
            fail(f"{origin} courage |delta| > 1")


def validate_episode(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    nodes = {n["id"]: n for n in data["nodes"]}
    if data["start"] not in nodes:
        fail(f"start ausente: {data['start']}")
    seen = []
    for node in data["nodes"]:
        nid = node["id"]
        if nid in seen:
            fail(f"id duplicado {nid}")
        seen.append(nid)
        choices = node.get("choices") or []
        if len(choices) > 4:
            fail(f"{nid} tem {len(choices)} escolhas")
        targets = [c["next"] for c in choices] if choices else [node.get("next")]
        for nxt in targets:
            if nxt and nxt not in nodes:
                fail(f"{nid} next órfão {nxt}")
        if not node.get("text"):
            fail(f"{nid} sem texto")
    print(f"OK {path.name}: {len(nodes)} nós")


def validate_events(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    for event in data["events"]:
        eid = event["id"]
        walk_effects(event.get("effects"), eid)
        for node in event.get("nodes", []):
            walk_effects(node.get("effects"), f"{eid}/{node.get('id')}")
            for choice in node.get("choices") or []:
                walk_effects(choice.get("effects"), f"{eid}/{choice.get('id')}")
        if event["weight"] < 1:
            fail(f"{eid} weight < 1")
    print(f"OK {path.name}: {len(data['events'])} eventos")


def main() -> None:
    validate_episode(ROOT / "episodes" / "ep01" / "nodes.json")
    validate_events(ROOT / "events" / "campus-day.json")
    print("OK grafo e eventos")


if __name__ == "__main__":
    sys.exit(main())
