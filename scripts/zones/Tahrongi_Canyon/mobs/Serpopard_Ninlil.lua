-----------------------------------
-- Area: Tahrongi Canyon
--   NM: Serpopard Ninlil
-- Unity Concord Wanted (RoE 823)
--
-- Notes:
--   UNM version of Serpopard Ishtar.
--   Spawn level 99 in SQL; spawn coords copied from Ethereal Junctions.
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
