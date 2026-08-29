-----------------------------------
-- Trust: Windurst
-----------------------------------
-- !addquest 2 119
-- Wetata : !pos -23.825 2.533 -44.567 241
-- Kupipi : !pos 2.050 0.000 32.400 242
-----------------------------------
local towerID = zones[xi.zone.HEAVENS_TOWER]
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST)

quest.reward =
{
    keyItem = xi.ki.WINDURST_TRUST_PERMIT,
}

local function trustMemory(player)
    local memories = 0

    if player:hasCompletedMission(xi.mission.log_id.WINDURST, xi.mission.id.windurst.THE_THREE_KINGDOMS) then
        memories = memories + 2
    end

    if player:hasCompletedMission(xi.mission.log_id.WINDURST, xi.mission.id.windurst.MOON_READING) then
        memories = memories + 8
    end

    return memories
end

local function learnKupipiTrust(player)
    player:addSpell(xi.magic.spell.KUPIPI, { silentLog = true })
    player:messageSpecial(towerID.text.YOU_LEARNED_TRUST, 0, xi.magic.spell.KUPIPI)
    player:setCharVar('WindurstFirstTrust', 1)
end

local function completeWindurstTrustShortcut(player)
    learnKupipiTrust(player)
    player:delKeyItem(xi.ki.GREEN_INSTITUTE_CARD)
    player:messageSpecial(towerID.text.KEYITEM_LOST, xi.ki.GREEN_INSTITUTE_CARD)
    if npcUtil.completeQuest(player, xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST, {
        keyItem = xi.ki.WINDURST_TRUST_PERMIT,
        var     = 'WindurstFirstTrust',
    }) then
        quest:cleanup(player)
    end
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 5 and
                xi.settings.main.ENABLE_TRUST_QUESTS == 1
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Wetata'] =
            {
                onTrigger = function(player, npc)
                    local trustSandoria = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA)
                    local trustBastok   = player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.TRUST_BASTOK)

                    if
                        trustBastok == xi.questStatus.QUEST_AVAILABLE and
                        trustSandoria == xi.questStatus.QUEST_AVAILABLE
                    then
                        return quest:progressEvent(863)
                    elseif
                        trustBastok == xi.questStatus.QUEST_COMPLETED or
                        trustSandoria == xi.questStatus.QUEST_COMPLETED
                    then
                        return quest:progressEvent(867)
                    end
                end,
            },

            onEventFinish =
            {
                [863] = function(player, csid, option, npc)
                    if option == 2 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.GREEN_INSTITUTE_CARD)
                    end
                end,

                [867] = function(player, csid, option, npc)
                    if option == 2 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.GREEN_INSTITUTE_CARD)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.HEAVENS_TOWER] =
        {
            ['Kupipi'] =
            {
                onTrigger = function(player, npc)
                    local trustSandoria = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA)
                    local trustBastok   = player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.TRUST_BASTOK)
                    local windurstFirstTrust = player:getCharVar('WindurstFirstTrust')
                    local rank3 = player:getRank(player:getNation()) >= 3 and 1 or 0

                    if
                        trustSandoria == xi.questStatus.QUEST_COMPLETED or
                        trustBastok == xi.questStatus.QUEST_COMPLETED
                    then
                        completeWindurstTrustShortcut(player)
                        return
                    elseif windurstFirstTrust == 0 then
                        learnKupipiTrust(player)
                        return quest:progressEvent(436):oncePerZone()
                    elseif windurstFirstTrust == 1 then
                        return quest:progressEvent(436):oncePerZone()
                    elseif windurstFirstTrust == 2 then
                        return quest:progressEvent(437)
                    end
                end,
            },

            onEventFinish =
            {
                [437] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.GREEN_INSTITUTE_CARD)
                    player:messageSpecial(towerID.text.KEYITEM_LOST, xi.ki.GREEN_INSTITUTE_CARD)
                    if npcUtil.completeQuest(player, xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST, {
                        keyItem = xi.ki.WINDURST_TRUST_PERMIT,
                        title   = xi.title.THE_TRUSTWORTHY,
                        var     = 'WindurstFirstTrust',
                    }) then
                        quest:cleanup(player)
                        player:messageSpecial(towerID.text.CALL_MULTIPLE_ALTER_EGO)
                    end
                end,
            },
        },

        [xi.zone.WINDURST_WOODS] =
        {
            ['Wetata'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.GREEN_INSTITUTE_CARD) then
                        return quest:progressEvent(864)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Wetata'] = quest:progressEvent(861),
        },

        [xi.zone.HEAVENS_TOWER] =
        {
            ['Kupipi'] =
            {
                onTrigger = function(player, npc)
                    local rank3 = player:getRank(player:getNation()) >= 3 and 1 or 0

                    if not player:hasSpell(xi.magic.spell.NANAA_MIHGO) then
                        return quest:progressEvent(438, 0, 0, 0, trustMemory(player), 0, 0, 0, rank3):oncePerZone()
                    elseif player:getNation() == xi.nation.WINDURST then
                        if player:getRank(player:getNation()) == 10 then
                            return quest:progressEvent(408)
                        end

                        return quest:progressEvent(251)
                    end

                    return quest:progressEvent(251)
                end,
            },
        },
    },
}

return quest
