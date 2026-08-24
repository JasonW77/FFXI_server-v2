-----------------------------------
-- Area: Tahrongi Canyon (117)
--  NPC: Ethereal Junction
-- !pos 80.790 -8.000 -242.000 117
-- !pos -442.380 -39.940 -153.810 117
-- !pos 76.040 8.000 39.740 117
--
-- Notes:
--   Spawns Serpopard Ninlil (Wanted / RoE 823) via xi.unityNM.
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
