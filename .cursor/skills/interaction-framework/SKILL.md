---
name: interaction-framework
description: Implement or migrate FFXI quests and missions with the Interaction Framework. Use when editing scripts/quests, scripts/missions, HiddenQuest, DefaultActions, or converting old onTrigger NPC logic.
---

# Interaction Framework

Read before writing:

- `documentation/interaction-framework.md`
- `documentation/ai_agents/interaction-framework-migration.md`

Copy structure from a nearby completed quest (e.g. `scripts/quests/jeuno/Chocobos_Wounds.lua`).

## Rules

- `Quest:new` / `Mission:new` / `HiddenQuest:new` — do not mix.
- `progressEvent` for progression; `event` for flavor; `npcUtil.tradeHasExactly` for trades.
- `quest:getVar` / `setVar`, not raw `getCharVar`, for framework vars.
- After migrating, strip quest if/else from the NPC file. Keep patrol/Trust/unrelated logic.
- One-line defaults go in `scripts/zones/<Zone>/DefaultActions.lua`.
- Mark partial conversions in `scripts/globals/quests.lua` with a TODO.

Never assume the old script is complete. Cross-check BG-Wiki, FFXIclopedia, and event dumps.
