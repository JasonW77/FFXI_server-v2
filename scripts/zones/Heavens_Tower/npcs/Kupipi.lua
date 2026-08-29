-----------------------------------
-- Area: Heaven's Tower
--  NPC: Kupipi
-- Involved in Mission 2-3
-- Involved in Quest: Riding on the Clouds
-- !pos 2 0.1 30 242
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if player:getNation() == xi.nation.WINDURST then
        if player:getRank(player:getNation()) == 10 then
            player:startEvent(408)
        else
            player:startEvent(251)
        end
    else
        player:startEvent(251)
    end
end

return entity
