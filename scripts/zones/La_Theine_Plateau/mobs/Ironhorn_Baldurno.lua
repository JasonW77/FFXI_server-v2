-----------------------------------
-- Area: La Theine Plateau
--   NM: Ironhorn Baldurno
-- Unity Concord Wanted (RoE 820)
--
-- Notes:
--   UNM version of Bloodtear Baldurf / Battering Ram family.
--   Spawn level 99 in SQL.
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
