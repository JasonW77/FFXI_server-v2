-----------------------------------
-- Area: East Ronfaure (101)
--  NPC: Ethereal Junction
-- !pos 522.230 -30.000 -41.480 101
-- !pos 237.740 -20.000 -160.000 101
-- !pos 565.270 -10.290 -378.180 101
--
-- Notes:
--   Spawns Hugemaw Harold (Wanted I / RoE 817) via xi.unityNM.
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
