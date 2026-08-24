-----------------------------------
-- xi.effect.CONFRONTATION
--
-- Isolates participants: entities only interact when GetConfrontationEffect()
-- power matches. Pets and Trusts already summoned when the effect is applied
-- must receive a copy, or they cannot engage confrontation mobs.
-- Trusts summoned after gain are handled in trustutils::CopyConfrontationEffect.
-----------------------------------
---@type TEffect
local effectObject = {}

---@param target CBaseEntity
---@param effect CStatusEffect
local function copyToOwnedCompanions(target, effect)
    local pet = target:getPet()
    if pet then
        pet:copyStatusEffect(effect)
    end

    -- getPartyWithTrusts includes party members' trusts; only copy to this PC's.
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
local function clearFromOwnedCompanions(target)
    local pet = target:getPet()
    if pet then
        pet:delStatusEffect(xi.effect.CONFRONTATION)
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
            member:delStatusEffect(xi.effect.CONFRONTATION)
        end
    end
end

effectObject.onEffectGain = function(target, effect)
    copyToOwnedCompanions(target, effect)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    clearFromOwnedCompanions(target)
end

return effectObject
