---
name: era-module
description: Add or change AirSkyBoat era-accuracy overrides under modules/era. Use when reverting post-era job, combat, quest, or spell behavior, or when xi.module.isContentEnabled is involved.
---

# Era module

Read `modules/README.md` and copy a sibling file under `modules/era/lua/`.

```lua
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

- Override the LSB path; do not fork a full copy of the script unless required.
- Call `super()` when the era change is a wrap, not a full replace.
- Name modules `era_<area>_<thing>`.
- Document the retail date/patch being reverted at the top.
