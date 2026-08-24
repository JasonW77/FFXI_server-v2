-----------------------------------
-- Area: East Sarutabaruta
--   NM: Prickly Pitriv
-- Unity Concord Wanted I (RoE 819)
--
-- Notes:
--   UNM version of Spiny Spipi.
--   Spawn level 75 in SQL (Wanted I).
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 180)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
