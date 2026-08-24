-----------------------------------
-- Area: Buburimu Peninsula (118)
--  NPC: Ethereal Junction
-- !pos 445.560 0.280 -319.430 118
-- !pos 441.980 0.000 199.850 118
-- !pos 19.240 -16.400 92.740 118
--
-- Notes:
--   Spawns Abyssdiver (Wanted / RoE 824) via xi.unityNM.
--   Requires active Wanted objective.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.unityNM.onTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
