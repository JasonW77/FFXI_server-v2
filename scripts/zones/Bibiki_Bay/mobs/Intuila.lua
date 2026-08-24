-----------------------------------
-- Area: Bibiki Bay
--   NM: Intuila
-- Unity Concord Wanted (RoE 825)
--
-- Notes:
--   UNM version of Intulo.
--   Spawn level 119 in SQL.
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
