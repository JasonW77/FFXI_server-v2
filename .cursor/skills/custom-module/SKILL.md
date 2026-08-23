---
name: custom-module
description: Add or change live-server QoL under modules/custom. Use when the change is non-retail, this server only, or the user asks for a custom module, init.txt enable, or not to touch era/core.
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
- Override the LSB path; do not fork a full copy of the script unless required.
- Call `super()` when wrapping (especially when multiplier/toggle is 1 or disabled).
- Document that it is non-retail QoL at the top.
- Enable in local `modules/init.txt` — entry format: `custom/lua/foo.lua` (not `modules/custom/...`). `init.txt` is local-only; never commit it to a PR.
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

## GP daily cap vs craft skill

- **Guild Points (GP) turn-ins** have a daily max: C++ `addGuildPoints`, charvar `[GUILD]daily_points`, SQL `guild_item_points.max_points`. QoL belongs in `modules/custom/lua/`, not SQL or core C++.
- **Craft skill** has no daily cap — only rank caps and `CRAFT_SPECIALIZATION_POINTS` (tune in `settings/map.lua`). Do not treat “crafting daily limit” as a separate system.
