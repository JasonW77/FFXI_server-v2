---
name: custom-module
description: >-
  Add or change live-server QoL under modules/custom. Use when the change is
  non-retail, this server only, or the user asks for a custom module, init.txt
  enable, or not to touch era/core. Also use for HNM/NM timers, ToD persist,
  idle/unclaimed despawn, land-king style spawn systems, or mission-gated
  inventory/wardrobe storage.
---

# Custom module

Read `modules/README.md` and a sibling under `modules/custom/` (Lua example: `homepoint_heal.lua`). LSB module overview: https://landsandboat-server.mintlify.app/modules/overview

Do not edit `scripts/`, `src/`, repo-root `sql/`, or `modules/era/` for this kind of change. Custom SQL belongs in `modules/custom/sql/`. Era modules are retail reverts only.

```lua
-----------------------------------
-- Non-retail QoL: Home Points restore HP/MP (single-player style).
-----------------------------------
require('modules/module_utils')
local m = Module:new('homepoint_heal')

m:addOverride('xi.homepoint.onTrigger', function(player, csid, index)
    super(player, csid, index)
    -- custom behavior
end)

return m
```

- `Module:new(...)` matches the filename (snake_case). Prefix `custom_` only if the name could collide with core/era.
- One concern per file: `lua/`, `sql/`, `commands/`, or `cpp/`.
- Prefer extending an existing related module over a second file for the same concern. Do not rename only for clarity if `init.txt` already loads the file. If the user names a **new** module file or the existing one is an unused stub, **create the new file**; leave the stub unless asked to remove it.
- Override the LSB path; do not fork a full copy of the script unless required.
- Call `super()` when wrapping (especially when multiplier/toggle is 1 or disabled).
- Document that it is non-retail QoL at the top.
- Enable in `modules/init.txt` — entry format: `custom/lua/foo.lua` (not `modules/custom/...`). OK on `LIVE` branch; never in LandSandBoat upstream PRs.
- Missing retail features belong in core `scripts/`, not here.
- Live flavor that landed in core by mistake (HELM yields, etc.) should be moved here, not left in `scripts/`.

## Settings

| Knob type | File | Lua table |
|---|---|---|
| Craft, GP, map-server | local `settings/map.lua` | `xi.settings.map` |
| Other QoL (HELM yields, etc.) | local `settings/main.lua` | `xi.settings.main` |

Do not edit `settings/default/` for live flavor. Default to `1` or retail in module code when a setting is unset.

**Module-only settings:** if a setting does nothing without the module, comment in `settings/map.lua` or `settings/main.lua` that `custom/lua/<module>.lua` must be enabled in local `modules/init.txt`.

## C++ vs Lua overrides

`addOverride` only works on Lua functions. C++ bindings (e.g. `player:addGuildPoints`, `player:getCurrentGPItem`) cannot be overridden directly.

When retail limits are enforced in C++, wrap the Lua layer instead (`scripts/globals/...`) — validate in C++, apply QoL in Lua. Reference: `modules/custom/lua/guild_daily_gp_multiplier.lua` (scales GP daily cap via bonus currency + `daily_points` consumption scaler).

Prefer `super()` when disabled; duplicate globals logic only when the wrapper must change behavior (e.g. scaled UI values).

## Mission-gated container storage

Reference: `modules/custom/lua/awesomes_mission_wardrobe_unlocks.lua`.

Use when gating **Mog Wardrobes** (or similar containers) behind mission progress on Live. Satchel is out of scope on Live (disabled by default).

**Do**

- Hook **`npcUtil.completeMission`** for IF / `mission:complete()` paths.
- Hook **`xi.player.onGameIn`** to **backfill** unlocks from `hasCompletedMission` (covers **`player:completeMission`** in zone scripts, e.g. ACP).
- **Charvar dedup** per `(logId, missionId)` so login backfill does not double-grant.
- **Char create:** strip wardrobes with `changeContainerSize(wardrobe, -80)` after `super()` (new chars only).
- **Nation lines:** one mission log → one wardrobe (Sandy/Bastok/Windy each own a bag). Do not map all three nations to the same container.
- **One arc, one wardrobe** for expansions; addons (ACP/AMK/ASA) may share one wardrobe with split milestones.

**Do not**

- Enable **two modules** that override the same global (e.g. `mission_wardrobe_unlocks.lua` + `awesomes_mission_wardrobe_unlocks.lua`).
- Assume `changeContainerSize` sets absolute size — it is **additive** (`AddBuff`), clamped **0–80** per container.
- Strip existing characters’ wardrobes on login without a migration plan (items can become inaccessible).

**Deploy notes:** new `init.txt` entries need **map restart**. Existing chars: backfill on login; veterans already at 80/80 keep DB size until policy says otherwise.

## GP daily cap vs craft skill

- **Guild Points (GP) turn-ins** have a daily max: C++ `addGuildPoints`, charvar `[GUILD]daily_points`, SQL `guild_item_points.max_points`. QoL belongs in `modules/custom/lua/`, not SQL or core C++.
- **Craft skill** has no daily cap — only rank caps and `CRAFT_SPECIALIZATION_POINTS` (tune in `settings/map.lua`). Do not treat “crafting daily limit” as a separate system.

## Status-effect QoL

Reference: `modules/custom/lua/city_rest_quickening.lua` (town rest → Sprint speed).

- Extend that file for related town-sprint / rest-buff QoL; do not add a parallel module.
- Before changing buffs: read fixed `power` / duration and the **first-apply vs existing-effect** branches. Do not assume tiers exist.
- “Upgrade” message/animation only when power or tier actually increases. Refresh-only paths (`resetStartTime` / `setDuration`) need their own notify if the user wants feedback on renew.
- `addStatusEffect` success is not the same as refresh; refresh often sends no client message unless you add one.
- Shared effect IDs (e.g. `SPRINT`) can collide with shoes or other sources — call that out before changing grant/refresh logic.

## NM / HNM spawn QoL

Reference implementation: `modules/custom/lua/land_kings.lua`.

Before a new file, inventory siblings:

- `land_kings.lua` — live timed Land Kings + ground HNMs (preferred home for timer/ToD QoL)
- `custom_HNM_system.lua` — alternate Land King mix (often disabled)
- `persist_nm_time_of_deaths.lua` — generic ToD persist sample
- `claim_shield.lua` — claim delay list (separate concern)
- `modules/abyssea/lua/era_HNM_system.lua` — era Land Kings (disabled; do not stack with live `land_kings`)

**Do**

- Prefer extending the related module over a parallel file. Keep the filename if `init.txt` already lists it.
- Timers via Lua `setRespawnTime` + server vars; apply **after** `super()` on despawn / zone init so stock windows are replaced. Not core `scripts/` and not `mob_groups` SQL for this QoL.
- Weather-gated NMs (e.g. King Vinegarroon): leave zone weather + roam weather-despawn alone. On restore, mark ready (`setRespawnTime(0)`); do not `SpawnMob`.
- Idle / unclaimed despawn: `IDLE_DESPAWN = 0`, or clear Guivre-style `despawnTime` / empty roam override that only despawns.
- Multi-NM work: list candidates with **current** timers and special flags (weather, charm, HQ lottery, missing `IDs.lua` entry) for user pick before coding.
- If a mob has no `IDs.lua` entry, use `sql/mob_spawn_points.sql` id with a comment (example: Wajaom Hydra).

**Do not**

- Stack `land_kings` with `custom_HNM_system` / `era_HNM_system`.
- Put shortened HNM/NM respawn windows into core `scripts/zones/**/mobs` (Simurgh/Roc 1–2h in core is the anti-pattern; move into the module when touching).
- Copy whole mob fight scripts; wrap spawn/despawn (and narrow fight hooks only when needed, e.g. skip Charm).
