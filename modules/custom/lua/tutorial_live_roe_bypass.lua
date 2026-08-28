-----------------------------------
-- Non-retail QoL: Tutorial step 5 bypass when RoE spark NPCs are unavailable.
-- Modern tutorial requires MEMORANDOLL (RoE record 1). Live keeps ENABLE_ROE=1 but
-- Rolandienne/Isakoth/Fhelm are SOA-gated, so grant the key item on tutorial NPC talk.
-----------------------------------
require('modules/module_utils')
local m = Module:new('tutorial_live_roe_bypass')

local tutorialNpcs =
{
    ['Gulldago'] = true,
    ['Alaune']   = true,
    ['Selele']   = true,
}

m:addOverride('InteractionGlobal.onTrigger', function(player, npc, fallbackFn)
    local npcName = npc:getName()

    if tutorialNpcs[npcName] then
        local prog = player:getVar('HQuest[Tutorial]Prog')

        if prog == 5 and not player:hasKeyItem(xi.ki.MEMORANDOLL) then
            npcUtil.giveKeyItem(player, xi.ki.MEMORANDOLL)

            if player:getEminenceProgress(1) then
                xi.roe.onRecordTrigger(player, 1)
            end
        end
    end

    return super(player, npc, fallbackFn)
end)

return m
