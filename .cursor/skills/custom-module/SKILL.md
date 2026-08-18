---
name: custom-module
description: Add or change live-server QoL under modules/custom. Use when the change is non-retail, this server only, or the user asks for a custom module, init.txt enable, or not to touch era/core.
---

# Custom module

Read `modules/README.md` and a sibling under `modules/custom/` (Lua example: `homepoint_heal.lua`). LSB module overview: https://landsandboat-server.mintlify.app/modules/overview

Do not edit `scripts/`, `src/`, `sql/`, or `modules/era/` for this kind of change. Era modules are retail reverts only.

```lua
require('modules/module_utils')
-----------------------------------
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
- Call `super()` when wrapping.
- Document that it is non-retail QoL at the top.
- Add the path to local `modules/init.txt` (gitignored; do not commit).
- Missing retail features belong in core `scripts/`, not here.
