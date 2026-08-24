-----------------------------------
-- Area: South Gustaberg
--   NM: Bounding Belinda
-- Unity Concord Wanted I (RoE 818)
--
-- Notes:
--   UNM version of Leaping Lizzy.
--   Spawn level 75 / group HP 20000 in SQL (Wanted I one-party placeholder; verify vs retail).
--   Light / Darkness skillchains cause a 10s stagger with no chat message (BG-Wiki).
--   Timing/message-less behavior marked TODO until verified in client.
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 180)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
end

entity.onMobSpawn = function(mob)
    -- TODO: confirm Light/Dark(ness) stagger is exactly 10s and silent vs retail
    mob:addListener('WEAPONSKILL_TAKE', 'BELINDA_SC_STAGGER', function(user, target, skill, tp, action)
        if not target:hasStatusEffect(xi.effect.SKILLCHAIN) then
            return
        end

        local skillchain = target:getStatusEffect(xi.effect.SKILLCHAIN)
        local scType = skillchain:getPower()

        if
            scType == xi.skillchainType.LIGHT or
            scType == xi.skillchainType.DARKNESS or
            scType == xi.skillchainType.LIGHT_II or
            scType == xi.skillchainType.DARKNESS_II
        then
            target:stun(10000)
        end
    end)
end

entity.onMobDespawn = function(mob)
    mob:removeListener('BELINDA_SC_STAGGER')
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
