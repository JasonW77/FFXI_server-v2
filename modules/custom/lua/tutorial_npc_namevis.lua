-----------------------------------
-- Non-retail QoL: Hide tutorial NPC blue dot after beginner quest completion.
-- Requires custom/cpp/tutorial_npc_namevis.cpp for per-player namevis updates.
-----------------------------------
require('modules/module_utils')
local m = Module:new('tutorial_npc_namevis')

local tutorialNpcsByZone =
{
    [xi.zone.SOUTHERN_SAN_DORIA] = 17719618, -- Alaune
    [xi.zone.BASTOK_MARKETS]     = 17739939, -- Gulldago
    [xi.zone.WINDURST_WOODS]     = 17764600, -- Selele
}

local function hideTutorialMarkerIfComplete(player)
    if player:getVar('HQuest[Tutorial]Prog') < 12 then
        return
    end

    local npcId = tutorialNpcsByZone[player:getZoneID()]
    if npcId and xi.custom and xi.custom.sendNpcNamevisToPlayer then
        xi.custom.sendNpcNamevisToPlayer(player, npcId, 0)
    end
end

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    if zoning then
        hideTutorialMarkerIfComplete(player)
    end
end)

m:addOverride('InteractionGlobal.onEventFinish', function(player, csid, option, npc, fallbackFn)
    local result = super(player, csid, option, npc, fallbackFn)

    hideTutorialMarkerIfComplete(player)

    return result
end)

return m
