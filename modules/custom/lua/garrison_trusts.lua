-----------------------------------
-- Non-retail QoL: allow Trusts (and pets) during Garrison.
--
-- Retail dismisses Trusts when Level Restriction is applied and blocks recall.
-- Core does the dismiss in xi.effects.level_restriction.onEffectGain.
-- Garrison also uses the CONFRONTATION flag on that effect; unlike
-- xi.effect.CONFRONTATION, Level Restriction does not copy to companions,
-- so kept Trusts would be unable to engage Garrison mobs without a copy.
--
-- Trusts summoned after the cap still get CopyConfrontationEffect in C++.
-- Trusts already out keep their pre-cap level until dismissed and recalled.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/garrison')
-----------------------------------
local m = Module:new('garrison_trusts')

---@param target CBaseEntity
---@param effect CStatusEffect
local function copyLevelRestrictionToCompanions(target, effect)
    local pet = target:getPet()
    if pet then
        pet:copyStatusEffect(effect)
    end

    if not target:isPC() then
        return
    end

    for _, member in ipairs(target:getPartyWithTrusts()) do
        if
            member:isTrust() and
            member:getMaster() and
            member:getMaster():getID() == target:getID()
        then
            member:copyStatusEffect(effect)
        end
    end
end

---@param target CBaseEntity
local function clearLevelRestrictionFromCompanions(target)
    local pet = target:getPet()
    if pet then
        pet:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
    end

    if not target:isPC() then
        return
    end

    for _, member in ipairs(target:getPartyWithTrusts()) do
        if
            member:isTrust() and
            member:getMaster() and
            member:getMaster():getID() == target:getID()
        then
            member:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
        end
    end
end

m:addOverride('xi.effects.level_restriction.onEffectGain', function(target, effect)
    if
        target:isPC() and
        effect:hasEffectFlag(xi.effectFlag.CONFRONTATION) and
        xi.garrison.isInGarrison(target)
    then
        target:levelRestriction(effect:getPower())
        target:messageBasic(xi.msg.basic.LEVEL_IS_RESTRICTED, effect:getPower())
        copyLevelRestrictionToCompanions(target, effect)

        if xi.settings.map.DESPAWN_JUGPETS_BELOW_MINIMUM_LEVEL then
            local pet         = target:getPet()
            local masterLevel = target:getMainLvl()

            if
                pet and
                pet:getObjType() == xi.objType.PET and
                target:hasJugPet() and
                masterLevel < pet:getMinimumPetLevel()
            then
                target:despawnPet()
            end
        end

        return
    end

    super(target, effect)
end)

m:addOverride('xi.effects.level_restriction.onEffectLose', function(target, effect)
    super(target, effect)

    if
        target:isPC() and
        effect:hasEffectFlag(xi.effectFlag.CONFRONTATION)
    then
        clearLevelRestrictionFromCompanions(target)
    end
end)

return m
