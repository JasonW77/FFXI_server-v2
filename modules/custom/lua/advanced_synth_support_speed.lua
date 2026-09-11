-----------------------------------
-- Non-retail QoL: Advanced Image Support shortens synthesis time by 25%.
-- Free Image Support is unchanged (power 1). Advanced / Aht Urhgan paid
-- support (power 3) gains the matching SYNTH_SPEED_* mod (4000 ms of 16 s).
-- Inter-synth wait in core also respects SYNTH_SPEED_* so wall-clock matches.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('advanced_synth_support_speed')

-- Base synth animation is 16s; 25% of that is 4000 ms.
local synthSpeedBonusMs = 4000
local advancedPowerMin  = 3

local craftImagery =
{
    { effect = 'woodworking_imagery',  mod = 'SYNTH_SPEED_WOODWORKING'  },
    { effect = 'smithing_imagery',     mod = 'SYNTH_SPEED_SMITHING'     },
    { effect = 'goldsmithing_imagery', mod = 'SYNTH_SPEED_GOLDSMITHING' },
    { effect = 'clothcraft_imagery',   mod = 'SYNTH_SPEED_CLOTHCRAFT'   },
    { effect = 'leathercraft_imagery', mod = 'SYNTH_SPEED_LEATHERCRAFT' },
    { effect = 'bonecraft_imagery',    mod = 'SYNTH_SPEED_BONECRAFT'    },
    { effect = 'alchemy_imagery',      mod = 'SYNTH_SPEED_ALCHEMY'      },
    { effect = 'cooking_imagery',      mod = 'SYNTH_SPEED_COOKING'      },
}

for _, entry in ipairs(craftImagery) do
    m:addOverride(string.format('xi.effects.%s.onEffectGain', entry.effect), function(target, effect)
        super(target, effect)

        if effect:getPower() >= advancedPowerMin then
            effect:addMod(xi.mod[entry.mod], synthSpeedBonusMs)
        end
    end)
end

return m
