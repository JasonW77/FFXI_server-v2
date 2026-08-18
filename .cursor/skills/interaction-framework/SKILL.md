---
name: interaction-framework
description: Implement or migrate FFXI quests and missions with the Interaction Framework. Use when editing scripts/quests, scripts/missions, HiddenQuest, DefaultActions, or converting old onTrigger NPC logic.
---

# Interaction Framework

Read before writing:

- `documentation/ai_agents/interaction-framework-migration.md` (workflow, captures, wiki triangulation)
- `documentation/interaction-framework.md` (API overview only; enums in it are stale)

Copy structure from a nearby completed quest (e.g. `scripts/quests/jeuno/Chocobos_Wounds.lua`). Do not start an IF conversion without captures or dumps unless the user wants a best-effort stub.

## Rules

- Research: BG-Wiki **and** FFXIclopedia, then event dumps, then captures. Never assume the old `onTrigger` script is complete.
- `Quest:new` / `Mission:new` / `HiddenQuest:new` — do not mix.
- `xi.item`, `xi.questStatus`, `xi.questLog` — not `xi.items` or bare `QUEST_AVAILABLE`.
- `progressEvent` for progression; `event` for flavor; `npcUtil.tradeHasExactly` for trades.
- `quest:getVar` / `setVar`, not raw `getCharVar`, for framework vars.
- After migrating, strip quest if/else from the NPC file. Keep patrol/Trust/unrelated logic.
- One-line defaults go in `scripts/zones/<Zone>/DefaultActions.lua`.
- Mark partial conversions in `scripts/globals/quests.lua` with a TODO.
