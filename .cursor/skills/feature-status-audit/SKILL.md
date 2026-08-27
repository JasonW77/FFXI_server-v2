---
name: feature-status-audit
description: >-
  Audit how finished an FFXI system, NPC, or feature is (gap analysis, finished
  vs unfinished). Use when the user asks completeness, implementation status,
  what’s left, or how much of a system works — not when implementing the feature.
---

# Feature status audit

## Do not confuse

| Signal | Means |
|--------|--------|
| `npc_list` row / zone spawn | Present in world |
| `DefaultActions` `{ event = N }` | Client CS opens; **not** finished gameplay |
| Item in `item_basic` / mods / kupon redeem | Obtainable or equippable base stats |
| C++/exdata + `scripts/data/*` tables | Infrastructure |
| Lua that **consumes** data (trade, apply mods, spend JP) | Playable system |

C++ comments like “Used in NPC Oboro” mean the API was intended for that NPC — not that the Lua exists.

## Layer checklist

Search narrow first (`scripts/zones/<Zone>/`, then `scripts/globals/`, `scripts/data/`, `src/`, `modules/`). Avoid repo-wide greps that stall.

1. **NPC surface** — dedicated `npcs/*.lua`, IF quest/mission, or only `DefaultActions`?
2. **Interaction** — `onTrade` / `onEventUpdate` / `progressEvent` / recipe tables?
3. **Items** — `item_basic` / `item_equipment` / `item_weapon` / `item_mods` complete enough to equip?
4. **Core/exdata** — structs, get/set ExData, unit tests?
5. **Consumers** — any Lua/C++ that applies the data on create, upgrade, or equip? Data tables with zero references = unfinished.
6. **Bypasses** — Dealer Moogle kupons, spark shop, GM `!additem` (players can have the item without the NPC flow).

## Report

- Split **infrastructure** vs **playable**.
- Cite concrete paths; peers help (e.g. Oboro `365` / Monisette `384` = event stubs).
- Optional rough % only if evidence-backed; prefer tables over vibes.
- For implement-next work, point at `npc-scripts`, `item-equipment`, `interaction-framework`, or `lsb-pr` — do not invent retail costs/events.
