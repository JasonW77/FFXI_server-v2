-----------------------------------
-- Area: Qufim Island
--   NM: Jester Malatrix
-- Unity Concord Wanted (RoE 835)
--
-- Notes:
--   UNM Doll / Trickster family.
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
