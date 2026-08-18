-----------------------------------
-- Non-retail QoL: successful HELM grants extra items.
-- Uses HARVESTING/EXCAVATION/LOGGING/MINING_YIELD_MULTIPLIER from local settings.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/hobbies/helm/logic')
-----------------------------------
local m = Module:new('helm_yield_multiplier')

local defaultMultiplier = 6

local settingByType =
{
    [xi.helmType.HARVESTING] = 'HARVESTING_YIELD_MULTIPLIER',
    [xi.helmType.EXCAVATION] = 'EXCAVATION_YIELD_MULTIPLIER',
    [xi.helmType.LOGGING]    = 'LOGGING_YIELD_MULTIPLIER',
    [xi.helmType.MINING]     = 'MINING_YIELD_MULTIPLIER',
}

m:addOverride('xi.helm.result', function(player, helmType, broke, itemID)
    if itemID > 0 then
        local settingName = settingByType[helmType]
        local multiplier  = defaultMultiplier
        if settingName then
            multiplier = xi.settings.main[settingName] or defaultMultiplier
        end

        local extra = multiplier - 1
        if extra > 0 then
            player:addItem(itemID, extra)
        end
    end

    super(player, helmType, broke, itemID)
end)

return m
