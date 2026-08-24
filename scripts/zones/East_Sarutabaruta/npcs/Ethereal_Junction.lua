-----------------------------------
-- Area: East Sarutabaruta (116)
--  NPC: Ethereal Junction
-- !pos 142.690 -13.090 109.560 116
-- !pos 361.840 0.100 -195.160 116
-- !pos -245.730 -0.640 -106.960 116
--
-- Notes:
--   Spawns Prickly Pitriv (Wanted I / RoE 819) via xi.unityNM.
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
