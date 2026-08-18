---
name: era-module
description: Add or change AirSkyBoat era-accuracy overrides under modules/era. Use when reverting post-era job, combat, quest, or spell behavior, or when xi.module.isContentEnabled is involved.
---

# Era module

Read `modules/README.md` and copy a sibling file under `modules/era/lua/`. Header must name the patch/date and a source (see `modules/era/lua/globals/combat/tp.lua`).

```lua
-----------------------------------
-- Module: Monk Job Adjustments
-- Revert Focus to flat +20 ACC (pre-RoV). See BG-Wiki Focus.
-----------------------------------
require('modules/module_utils')
local moduleName = 'era_job_utils_monk'

if xi.module.isContentEnabled('ROV') then
    return { name = moduleName }
end

local m = Module:new(moduleName)
m:addOverride('xi.job_utils.monk.useFocus', function(player, target, ability)
    -- era behavior
end)

return m
```

- Mirror the `scripts/` path under `modules/era/lua/`.
- Override the LSB path; do not fork a full copy of the script unless required.
- Call `super()` when wrapping. Full replace is OK when the era formula differs.
- Match sibling naming in that folder (`era_job_utils_<job>` next to job utils; content-tag prefixes like `soa_tp_gain` exist).
- Tags: COP, TOAU, WOTG, ABYSSEA, SOA, ROV, TVR.
