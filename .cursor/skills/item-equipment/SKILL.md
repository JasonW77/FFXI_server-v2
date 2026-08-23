---
name: item-equipment
description: >-
  Diagnose and finish FFXI equipment SQL (look MId, mods, usable scripts).
  Use when gear is invisible, item_equipment has MId 0 or verify-model TODO,
  stub armor/weapons need mods, or enchanted gear needs item_usable / scripts/items.
---

# Item equipment

## Diagnose invisible gear

1. Check `sql/item_equipment.sql` `MId`. `0` → client look slot stays bare/invisible.
2. Confirm `item_basic` exists and slot/jobs/level are sane.
3. Item DAT (ROM armor tables) does **not** store LSB `MId`. Do not hunt for SQL MId as a raw uint16 in the item record.

## Resolve MId

Prefer in order:

1. **XI Tinkerer** (or equivalent) Model field for the item ID.
2. **FTABLE + race mesh paths** (AltanaViewer `List/PC/*/Feet.csv` etc.):
   - All-races gear has **one look index**, many race mesh DATs (e.g. `383/15`…`383/21`). Per-race paths ≠ race-locked item.
   - Find the labeled mesh for ≥2 races → FTABLE file IDs → subtract that race’s feet (or slot) base → **same index**.
   - Store the **raw index** in `MId` (e.g. `499`). Char/login packets already add the slot base (`look.feet + 0x5000`). Do **not** pre-pack `0x5000|index` in SQL (that double-adds and looks invisible). Rows like Ilm/AA feet with `209xx` are suspect.
3. Retail equip look capture if still unknown. Leave TODO rather than guessing.

Never invent a model ID.

## Finish the stub

| Need | Where |
|------|--------|
| Look | `sql/item_equipment.sql` `MId` |
| Stats | `sql/item_mods.sql` (wiki/DAT; `HASTE_GEAR` 100≈1%, Store TP = mod `73`) |
| Enchant | `sql/item_usable.sql` + `scripts/items/<name>.lua` (+ `xi.item` enum if missing) |

Copy nearby INSERT / script style. Clear verify-model TODOs only after MId is sourced.

## Apply & verify

1. `python dbtool.py update` from `tools/` (only if the user asked to update the DB).
2. Restart map so item tables reload (see `dbtool` skill / `ssh-live`).
3. In client: equip → visible look; check mods; use enchantment if any.
