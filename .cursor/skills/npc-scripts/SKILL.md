---
name: npc-scripts
description: >-
  Format NPC zone scripts, headers, positions, and stubs. Use when editing
  scripts/zones/**/npcs, IDs.lua, DefaultActions.lua, when an NPC nameplate
  shows NPC instead of its display name, or when a ??? / QM trade or examine
  silently does nothing at a known retail position.
---

# NPC scripts

Read `documentation/ai_agents/npc-header-guide.md`.

Header:

```lua
-----------------------------------
-- Area: Windurst Walls (239)
--  NPC: Ambrosius
-- !pos 65.175 -2.499 -63.231 239
-----------------------------------
```

- Zone folder name + ID from `scripts/enum/zone.lua`.
- In `sql/npc_list.sql`: `name` = internal / Lua file (`Survival_Guide`); `polutils_name` = client label (`Survival Guide`, loaded as `packetName`). Coords from `pos_x/y/z`.
- Keep an existing Notes block. Do not strip it.

## DefaultActions ≠ finished system

`['Npc'] = { event = N }` only starts a client cutscene. It is **not** trades, JP spend, augments, or upgrade logic.

Finished retail NPC systems need a zone `npcs/*.lua` and/or IF + `onTrade` / `onEventUpdate` (or a documented global). Peers that are still stubs: Oboro `365`, Monisette `384`.

For “how finished is this NPC/system?” load `feature-status-audit`.

## Silent ??? / trade after npc_list dump

IF keys, `DefaultActions`, and `npcs/<name>.lua` bind by SQL **`name`**, not the client `???` label or a stale `!pos` comment.

1. Match wiki / header coords to the `npc_list` row in that zone (`pos_x/y/z`).
2. Confirm scripts use that row’s `name` (`qm`, `qm2`, …). Silent no-op = wrong name (handler never runs). A scripted “nothing happens” message means the handler ran.
3. Client `npc_list` dumps can reassign `qm` / `qm2` across entity IDs while positions stay. Prefer **retarget Lua + DefaultActions** to current dump names. Do **not** rename dump rows to match old scripts.
4. Update quest/mission IF and zone `DefaultActions` together so the wrong `???` does not keep flavor text. Same key in another zone may still be correct — fix only the mismatched zone.

## Nameplate shows "NPC"

1. Confirm the `npc_list` row: `polutils_name` set, look/model correct, not a placeholder (`NPC[…]`, empty name).
2. If SQL is already right and the client still shows **NPC**, the 0x00E NPC name path must send `packetName` when set (`src/map/packets/entity_update.cpp`). Sending only `getName()` (`Survival_Guide`) misses client DAT and falls back to **NPC**. Prefer that core fix over per-zone `onSpawn` + `renameEntity`.
3. If every same-look NPC fails (e.g. all Survival Guides), fix the packet — not one SQL row. Optional GM check: `!rename Survival Guide`; if that fixes it, packetName is the issue.
4. Not custom QoL (`modules/custom/`). Retail naming belongs in core / LSB PR.

Minimal stub when all quest logic is in IF:

```lua
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
end

entity.onTrade = function(player, npc, trade)
end

return entity
```
