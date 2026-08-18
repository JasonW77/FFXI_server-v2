---
name: npc-scripts
description: Format NPC zone scripts, headers, positions, and stubs. Use when editing scripts/zones/**/npcs, IDs.lua, or DefaultActions.lua.
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
- Display name and coords from `sql/npc_list.sql`.
- Keep existing Notes.

Minimal stub when all quest logic is in IF:

```lua
---@type TNpcEntity
local entity = {}
entity.onTrigger = function(player, npc) end
entity.onTrade = function(player, npc, trade) end
return entity
```
