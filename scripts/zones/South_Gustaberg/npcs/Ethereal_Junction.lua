-----------------------------------
-- Area: South Gustaberg (107)
--  NPC: Ethereal Junction
-- !pos -208.360 20.000 -437.110 107
-- !pos -519.520 39.660 -198.990 107
-- !pos -153.800 -0.120 -200.770 107
--
-- Notes:
--   Spawns Bounding Belinda (Wanted I / RoE 818) via xi.unityNM.
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
