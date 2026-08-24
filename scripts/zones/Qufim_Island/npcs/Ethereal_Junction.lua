-----------------------------------
-- Area: Qufim Island (126)
--  NPC: Ethereal Junction
-- !pos 140.300 -20.960 23.190 126
-- !pos -160.000 -20.000 77.000 126
-- !pos -121.750 -19.190 216.290 126
--
-- Notes:
--   Spawns Jester Malatrix (Wanted / RoE 835) via xi.unityNM.
--   Requires SOA content tag (npc_list) and active Wanted objective.
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
