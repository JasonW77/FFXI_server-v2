-----------------------------------
-- Area: La Theine Plateau (102)
--  NPC: Ethereal Junction
-- !pos -122.880 -8.000 -43.550 102
-- !pos -268.680 -15.640 -161.210 102
-- !pos 119.310 8.000 -158.750 102
--
-- Notes:
--   Spawns Ironhorn Baldurno (Wanted / RoE 820) via xi.unityNM.
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
