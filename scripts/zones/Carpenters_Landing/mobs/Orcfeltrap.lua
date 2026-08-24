-----------------------------------
-- Area: Carpenters' Landing
--   NM: Orcfeltrap
-- Unity Concord Wanted (RoE 827)
--
-- Notes:
--   UNM version of Orctrap.
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
