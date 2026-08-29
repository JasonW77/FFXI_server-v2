-----------------------------------
-- Trust: San d'Oria
-----------------------------------
-- !addquest 0 119
-- Gondebaud  : !pos 123.754 0.000 92.125 230
-- Excenmille : !pos -229.344 6.999 22.976 231
-----------------------------------
local northernID = zones[xi.zone.NORTHERN_SAN_DORIA]
-----------------------------------

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA)

quest.reward =
{
    keyItem = xi.ki.SAN_DORIA_TRUST_PERMIT,
}

-- Retail learn CS 893 / shortcut 897 are single-instruction END_REQSTACK stubs; grant server-side then play dialog.
local function learnExcenmilleTrust(player)
    player:addSpell(xi.magic.spell.EXCENMILLE, { silentLog = true })
    player:messageSpecial(northernID.text.YOU_LEARNED_TRUST, 0, xi.magic.spell.EXCENMILLE)
    player:setCharVar('SandoriaFirstTrust', 1)
end

local function completeSandoriaTrustShortcut(player)
    learnExcenmilleTrust(player)
    player:delKeyItem(xi.ki.RED_INSTITUTE_CARD)
    player:messageSpecial(northernID.text.KEYITEM_LOST, xi.ki.RED_INSTITUTE_CARD)
    if npcUtil.completeQuest(player, xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA, {
        keyItem = xi.ki.SAN_DORIA_TRUST_PERMIT,
        var     = 'SandoriaFirstTrust',
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

        [xi.zone.SOUTHERN_SAN_DORIA] =
        {
            ['Gondebaud'] =
            {
                onTrigger = function(player, npc)
                    local trustBastok   = player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.TRUST_BASTOK)
                    local trustWindurst = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST)

                    if
                        trustWindurst == xi.questStatus.QUEST_AVAILABLE and
                        trustBastok == xi.questStatus.QUEST_AVAILABLE
                    then
                        return quest:progressEvent(3500)
                    elseif
                        trustWindurst == xi.questStatus.QUEST_COMPLETED or
                        trustBastok == xi.questStatus.QUEST_COMPLETED
                    then
                        return quest:progressEvent(3504)
                    end
                end,
            },

            onEventFinish =
            {
                [3500] = function(player, csid, option, npc)
                    if option == 2 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.RED_INSTITUTE_CARD)
                    end
                end,

                [3504] = function(player, csid, option, npc)
                    if option == 2 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.RED_INSTITUTE_CARD)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Excenmille'] =
            {
                onTrigger = function(player, npc)
                    local trustBastok   = player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.TRUST_BASTOK)
                    local trustWindurst = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST)
                    local sandoriaFirstTrust = player:getCharVar('SandoriaFirstTrust')
                    local rank3 = player:getRank(player:getNation()) >= 3 and 1 or 0

                    if
                        trustWindurst == xi.questStatus.QUEST_COMPLETED or
                        trustBastok == xi.questStatus.QUEST_COMPLETED
                    then
                        completeSandoriaTrustShortcut(player)
                        return
                    elseif sandoriaFirstTrust == 0 then
                        learnExcenmilleTrust(player)
                        return quest:progressEvent(894):oncePerZone()
                    elseif sandoriaFirstTrust == 1 then
                        return quest:progressEvent(894):oncePerZone()
                    elseif sandoriaFirstTrust == 2 then
                        return quest:progressEvent(895)
                    end
                end,
            },

            onEventFinish =
            {
                [895] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.RED_INSTITUTE_CARD)
                    player:messageSpecial(northernID.text.KEYITEM_LOST, xi.ki.RED_INSTITUTE_CARD)
                    if npcUtil.completeQuest(player, xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA, {
                        keyItem = xi.ki.SAN_DORIA_TRUST_PERMIT,
                        title   = xi.title.THE_TRUSTWORTHY,
                        var     = 'SandoriaFirstTrust',
                    }) then
                        quest:cleanup(player)
                        player:messageSpecial(northernID.text.CALL_MULTIPLE_ALTER_EGO)
                    end
                end,
            },
        },

        [xi.zone.SOUTHERN_SAN_DORIA] =
        {
            ['Gondebaud'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.RED_INSTITUTE_CARD) then
                        return quest:progressEvent(3501)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.SOUTHERN_SAN_DORIA] =
        {
            ['Gondebaud'] = quest:progressEvent(3502),
        },

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Excenmille'] =
            {
                onTrigger = function(player, npc)
                    local rank3 = player:getRank(player:getNation()) >= 3 and 1 or 0

                    if not player:hasSpell(xi.magic.spell.CURILLA) then
                        return quest:progressEvent(896, 0, 0, 0, 0, 0, 0, 0, rank3):oncePerZone()
                    end
                end,
            },
        },
    },
}

return quest
