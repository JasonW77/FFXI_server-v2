-----------------------------------
-- Area: Bibiki Bay (4)
--  NPC: Ethereal Junction
-- !pos 582.550 -20.540 847.860 4
-- !pos 198.670 -28.000 562.660 4
-- !pos 361.160 -20.000 319.810 4
--
-- Notes:
--   Spawns Intuila (Wanted / RoE 825) via xi.unityNM.
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
