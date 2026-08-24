---
name: unity-wanted
description: >-
  Implement Unity Concord Wanted battles (UNM): Ethereal Junction spawn,
  confrontation, RoE records, and NM coffers. Use when adding or fixing Wanted
  NMs, UNM, Ethereal Junction, Wanted RoE, or unity_nm.
---

# Unity Wanted (UNM)

Missing retail Wanted content belongs in **core** (`scripts/` + `sql/`), not `modules/custom/`.

## Checklist (one NM)

1. **IDs** — `npc_list` Ethereal Junctions + `mob_spawn_points` / `mob_groups` / `mob_pools` for that zone. Pair each junction to a mob by matching coords (or order/proximity when mob XYZ is `0,0,0`).
2. **Spawn level** — set `mob_spawn_points` `minLevel`/`maxLevel` to the RoE recommended level (e.g. Wanted I → `75,75`). **`0,0` yields tiny HP** (formula from level). Match siblings (e.g. Harold) already fixed in-tree.
3. **Group HP** — `mob_groups.HP = 0` uses level/job formula. Explicit HP only when sourced or clearly `-- TODO` vs retail.
4. **`xi.unityNM`** — add junction → `{ roeId, cost, contentLevel, mobId, coffer }` rows in `scripts/globals/unity_nm.lua`.
5. **Zone** — `npcs/Ethereal_Junction.lua` (calls `xi.unityNM.onTrigger`), `mobs/<Name>.lua`, `IDs.lua` mob/npc tables + `UNITY_WANTED_BATTLE_INTERACT`. Ensure `text.NOTHING_HAPPENS` exists (often `141`) — `unity_nm` uses it for fail paths.
6. **RoE** — `[id]` in `roe_records.lua` with `DEFEAT_MOB` + all zone mob IDs, `repeat`, sparks/exp. Stub tiers if retail unknown: lv75 → 500/2500, lv99 → 750/4000, lv119 → 1000/5000 (+ TODO). Unimplemented IDs cannot be set (`AddEminenceRecord` rejects them).
7. **Coffer** — give in confrontation `onWin` (not RoE `item`; repeats skip non-exception item rewards). Add `xi.item` enum, `scripts/items/<coffer>.lua`, clear `-- TODO: Not implemented` on `item_usable` when scripted.
8. **Loot stubs** — weighted table + TODO until captures/samples. Match wiki qty (e.g. Belinda hide **1–3**). Do not invent retail rates.
9. **NM mechanics** — BG-Wiki notes (e.g. Belinda Light/Dark stagger; Harold TP-move vulnerability). Stub + TODO if unverified.
10. **Apply** — `dbtool` for SQL + **map restart** (globals, zone scripts, RoE bitset, mob tables, `scripts/enum/*`). See `dbtool` skill.

## Patterns

- Confrontation: `xi.confrontation.start` (`pirates_chart.lua`, `confrontation.lua`).
- **Trusts:** `CONFRONTATION` isolates by matching effect power. Pets copy on gain; Trusts already out must also get a copy (`scripts/effects/confrontation.lua`). Mid-fight summons use `trustutils::CopyConfrontationEffect`. Without matching power, Trusts stay out but never engage.
- Junction menu: `UNITY_WANTED_BATTLE_INTERACT` params / yes-no event **unverified** without capture; current MVP is double-trigger confirm in `unity_nm.lua`.
- Accolades: `delCurrency('unity_accolades', cost)` per participant.
- Content tag: junctions often `SOA` in `npc_list` — respect `ENABLE_SOA`.

## Do not

- Put Wanted QoL or incomplete retail in `modules/custom/` or `modules/era/`.
- Ship coffer as RoE `reward.item` unless it is a documented repeat exception.
- Leave spawn levels at `0,0` for leveled Wanted NMs.
- Invent menu CSIDs, object-set bits, or coffer rates — TODO until capture/wiki samples.
- Implement NMs with `poolid = 0`, all-zero spawn coords, or unconfirmed RoE IDs — defer (do not invent pools/coords/IDs).
- Concord NQ→HQ **enhance** (retail: trade gear + mats at Unity NPC, 1 Vanadiel day pickup). Out of Wanted MVP; `xi.unity.onTrade` stub only until built.

## Verify (smoke)

- RoE settable; junction double-trigger pops fight; kill completes RoE + coffer.
- Trusts already summoned **engage** the NM (confrontation power copied).
- After `scripts/enum/item.lua` (or other enum) edits: **map restart** — FileWatcher does not hot-reload enums safely.
