-----------------------------------
-- Non-retail QoL: Mission-gated Mog Wardrobe storage (AirSkyBoat Live).
-- One story arc per wardrobe; addon arcs share Wardrobe 8.
-- Enable: custom/lua/awesomes_mission_wardrobe_unlocks.lua in modules/init.txt
-----------------------------------
require('modules/module_utils')
require('scripts/globals/missions')
-----------------------------------
local m = Module:new('awesomes_mission_wardrobe_unlocks')

local SLOT_INCREASE = 10

local nationMilestones =
{
    6, 10, 13, 15, 17, 19, 21, 23,
}

local bagNames =
{
    [xi.inv.WARDROBE]  = 'Mog Wardrobe 1',
    [xi.inv.WARDROBE2] = 'Mog Wardrobe 2',
    [xi.inv.WARDROBE3] = 'Mog Wardrobe 3',
    [xi.inv.WARDROBE4] = 'Mog Wardrobe 4',
    [xi.inv.WARDROBE5] = 'Mog Wardrobe 5',
    [xi.inv.WARDROBE6] = 'Mog Wardrobe 6',
    [xi.inv.WARDROBE7] = 'Mog Wardrobe 7',
    [xi.inv.WARDROBE8] = 'Mog Wardrobe 8',
}

local wardrobes =
{
    xi.inv.WARDROBE,
    xi.inv.WARDROBE2,
    xi.inv.WARDROBE3,
    xi.inv.WARDROBE4,
    xi.inv.WARDROBE5,
    xi.inv.WARDROBE6,
    xi.inv.WARDROBE7,
    xi.inv.WARDROBE8,
}

local function buildNationUnlocks(wardrobe)
    local entries = {}

    for _, missionId in ipairs(nationMilestones) do
        entries[missionId] = { wardrobe, SLOT_INCREASE }
    end

    return entries
end

local function buildUnlocks(missionIds, wardrobe)
    local entries = {}

    for _, missionId in ipairs(missionIds) do
        entries[missionId] = { wardrobe, SLOT_INCREASE }
    end

    return entries
end

local unlocks =
{
    [xi.mission.log_id.SANDORIA] = buildNationUnlocks(xi.inv.WARDROBE),
    [xi.mission.log_id.BASTOK]   = buildNationUnlocks(xi.inv.WARDROBE2),
    [xi.mission.log_id.WINDURST] = buildNationUnlocks(xi.inv.WARDROBE3),

    [xi.mission.log_id.ZILART] = buildUnlocks(
        {
            xi.mission.id.zilart.THE_NEW_FRONTIER,
            xi.mission.id.zilart.KAZHAMS_CHIEFTAINESS,
            xi.mission.id.zilart.HEADSTONE_PILGRIMAGE,
            xi.mission.id.zilart.THE_CHAMBER_OF_ORACLES,
            xi.mission.id.zilart.ROMAEVE,
            xi.mission.id.zilart.THE_HALL_OF_THE_GODS,
            xi.mission.id.zilart.ARK_ANGELS,
            xi.mission.id.zilart.AWAKENING,
        },
        xi.inv.WARDROBE4),

    [xi.mission.log_id.COP] = buildUnlocks(
        {
            xi.mission.id.cop.THE_RITES_OF_LIFE,
            xi.mission.id.cop.THE_MOTHERCRYSTALS,
            xi.mission.id.cop.THE_LOST_CITY,
            xi.mission.id.cop.ANCIENT_VOWS,
            xi.mission.id.cop.DARKNESS_NAMED,
            xi.mission.id.cop.THE_SECRETS_OF_WORSHIP,
            xi.mission.id.cop.ONE_TO_BE_FEARED,
            xi.mission.id.cop.DAWN,
        },
        xi.inv.WARDROBE5),

    [xi.mission.log_id.TOAU] = buildUnlocks(
        {
            xi.mission.id.toau.LAND_OF_SACRED_SERPENTS,
            xi.mission.id.toau.WESTERLY_WINDS,
            xi.mission.id.toau.LOST_KINGDOM,
            xi.mission.id.toau.SWEETS_FOR_THE_SOUL,
            xi.mission.id.toau.SEAL_OF_THE_SERPENT,
            xi.mission.id.toau.SENTINELS_HONOR,
            xi.mission.id.toau.LIGHT_OF_JUDGMENT,
            xi.mission.id.toau.ETERNAL_MERCENARY,
        },
        xi.inv.WARDROBE6),

    [xi.mission.log_id.WOTG] = buildUnlocks(
        {
            xi.mission.id.wotg.CAVERNOUS_MAWS,
            xi.mission.id.wotg.IN_THE_NAME_OF_THE_FATHER,
            xi.mission.id.wotg.CROSSROADS_OF_TIME,
            xi.mission.id.wotg.A_SANGUINARY_PRELUDE,
            xi.mission.id.wotg.THE_BATTLE_OF_XARCABARD,
            xi.mission.id.wotg.ADIEU_LILISETTE,
            xi.mission.id.wotg.WHEN_WILLS_COLLIDE,
            xi.mission.id.wotg.LEST_WE_FORGET,
        },
        xi.inv.WARDROBE7),

    [xi.mission.log_id.ACP] = buildUnlocks(
        {
            xi.mission.id.acp.A_CRYSTALLINE_PROPHECY,
            xi.mission.id.acp.THOSE_WHO_LURK_IN_SHADOWS_I,
            xi.mission.id.acp.BORN_OF_HER_NIGHTMARES,
        },
        xi.inv.WARDROBE8),

    [xi.mission.log_id.AMK] = buildUnlocks(
        {
            xi.mission.id.amk.A_MOOGLE_KUPO_DETAT,
            xi.mission.id.amk.SHOCK_ARRANT_ABUSE_OF_AUTHORITY,
            xi.mission.id.amk.SMASH_A_MALEVOLENT_MENACE,
        },
        xi.inv.WARDROBE8),

    [xi.mission.log_id.ASA] = buildUnlocks(
        {
            xi.mission.id.asa.A_SHANTOTTO_ASCENSION,
            xi.mission.id.asa.ENEMY_OF_THE_EMPIRE_I,
        },
        xi.inv.WARDROBE8),
}

local function getUnlockCharVarKey(logId, missionId)
    return string.format('WardrobeUnlock[%u][%u]', logId, missionId)
end

local function tryGrantUnlock(player, logId, missionId, skipCompleteCheck)
    local charVarKey = getUnlockCharVarKey(logId, missionId)

    if player:getCharVar(charVarKey) == 1 then
        return
    end

    local logUnlocks = unlocks[logId]
    if logUnlocks == nil then
        return
    end

    local unlock = logUnlocks[missionId]
    if unlock == nil then
        return
    end

    if
        not skipCompleteCheck and
        not player:hasCompletedMission(logId, missionId)
    then
        return
    end

    local bag         = unlock[1]
    local bagIncrease = unlock[2]
    local bagName     = bagNames[bag]
    local oldSize     = player:getContainerSize(bag)

    player:changeContainerSize(bag, bagIncrease)
    player:setCharVar(charVarKey, 1)

    local newSize = player:getContainerSize(bag)
    local str     = string.format(
        '%s capacity has been increased by %i from %i to %i',
        bagName, bagIncrease, oldSize, newSize)

    player:printToPlayer(str, xi.msg.channel.SYSTEM_3, '')
end

local function backfillUnlocks(player)
    for logId, logUnlocks in pairs(unlocks) do
        for missionId, _ in pairs(logUnlocks) do
            tryGrantUnlock(player, logId, missionId, false)
        end
    end
end

m:addOverride('xi.player.charCreate', function(player)
    super(player)

    -- NOTE: These will all be clamped between 0-80,
    --     : so using -80 is fine
    for _, wardrobe in ipairs(wardrobes) do
        player:changeContainerSize(wardrobe, -80)
    end
end)

m:addOverride('npcUtil.completeMission', function(player, logId, missionId, params)
    local result = super(player, logId, missionId, params)

    if result then
        tryGrantUnlock(player, logId, missionId, true)
    end

    return result
end)

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    backfillUnlocks(player)
end)

return m
