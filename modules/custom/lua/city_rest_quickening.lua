-----------------------------------
-- Custom QoL: rest in a city grants Sprint movement speed.
-- Inspired by Super Kupower Swift Shoes. Not retail.
-- /heal at full HP in a city: Sprint +5 for 60 minutes
-- (same additive speed as Sprinter's Shoes). Stripped when leaving town.
-- Uses Sprint, not Quickening, so shoes and jig are left alone.
-- Shows the Quickening icon; effect 161 has no client graphic.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('city_rest_quickening')

local sprintPower    = 5
local sprintDuration = 3600 -- seconds; setDuration uses milliseconds

local isInCity = function(player)
    local zone = player:getZone()
    if not zone then
        return false
    end

    return bit.band(zone:getTypeMask(), xi.zoneType.CITY) ~= 0
end

local tryGrantTownSprint = function(target)
    if
        not target:isPC() or
        not isInCity(target) or
        target:getHPP() < 100 or
        target:hasStatusEffect(xi.effect.DISEASE)
    then
        return
    end

    local existing = target:getStatusEffect(xi.effect.SPRINT)
    if existing then
        existing:resetStartTime()
        existing:setDuration(sprintDuration * 1000)
        return
    end

    if target:addStatusEffect(xi.effect.SPRINT, {
        power    = sprintPower,
        duration = sprintDuration,
        origin   = target,
        icon     = xi.effect.QUICKENING,
    })
    then
        target:messageBasic(xi.msg.basic.GAINS_EFFECT_OF_STATUS, xi.effect.QUICKENING)
    end
end

-- effect:addMod before SetOwner so C++ applies and removes the speed (same pattern as era composure).
m:addOverride('xi.effects.sprint.onEffectGain', function(target, effect)
    super(target, effect)
    effect:addMod(xi.mod.MOVE_SPEED_QUICKENING, effect:getPower())
end)

m:addOverride('xi.effects.healing.onEffectGain', function(target, effect)
    super(target, effect)
    tryGrantTownSprint(target)
end)

m:addOverride('xi.effects.healing.onEffectTick', function(target, effect)
    super(target, effect)

    if not target:hasStatusEffect(xi.effect.HEALING) then
        return
    end

    tryGrantTownSprint(target)
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
