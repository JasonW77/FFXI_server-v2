-----------------------------------
-- Custom QoL: rest in a city grants Sprint movement speed.
-- Inspired by Super Kupower Swift Shoes. Not retail.
-- Full HP in a city after a heal tick: Sprint +5 for 60 minutes
-- (same additive speed as Sprinter's Shoes). Stripped when leaving town.
-- Uses Sprint, not Quickening, so shoes and jig are left alone.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('custom_city_rest_quickening')

local sprintPower    = 5
local sprintDuration = 3600 -- seconds; setDuration uses milliseconds

local isInCity = function(player)
    local zone = player:getZone()
    if not zone then
        return false
    end

    return bit.band(zone:getTypeMask(), xi.zoneType.CITY) ~= 0
end

m:addOverride('xi.effects.sprint.onEffectGain', function(target, effect)
    super(target, effect)
    target:addMod(xi.mod.MOVE_SPEED_QUICKENING, effect:getPower())
end)

m:addOverride('xi.effects.sprint.onEffectLose', function(target, effect)
    target:delMod(xi.mod.MOVE_SPEED_QUICKENING, effect:getPower())
    super(target, effect)
end)

m:addOverride('xi.effects.healing.onEffectTick', function(target, effect)
    super(target, effect)

    if
        not target:isPC() or
        not target:hasStatusEffect(xi.effect.HEALING) or
        not isInCity(target) or
        target:getHPP() < 100 or
        target:hasStatusEffect(xi.effect.DISEASE)
    then
        return
    end

    if effect:getTickCount() <= 1 then
        return
    end

    local existing = target:getStatusEffect(xi.effect.SPRINT)
    if existing then
        existing:resetStartTime()
        existing:setDuration(sprintDuration * 1000)
        return
    end

    target:addStatusEffect(xi.effect.SPRINT, { power = sprintPower, duration = sprintDuration, origin = target })
    target:messageBasic(xi.msg.basic.GAINS_EFFECT_OF_STATUS, xi.effect.SPRINT)
end)

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    if
        player:hasStatusEffect(xi.effect.SPRINT) and
        not isInCity(player)
    then
        player:delStatusEffectSilent(xi.effect.SPRINT)
    end
end)

return m
