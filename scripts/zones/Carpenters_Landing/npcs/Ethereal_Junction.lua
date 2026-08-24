-----------------------------------
-- Area: Carpenters' Landing (2)
--  NPC: Ethereal Junction
-- !pos 126.090 -6.840 -440.030 2
-- !pos 152.890 -8.740 -511.440 2
-- !pos 77.980 -6.000 -603.000 2
--
-- Notes:
--   Spawns Orcfeltrap (Wanted / RoE 827) via xi.unityNM.
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
