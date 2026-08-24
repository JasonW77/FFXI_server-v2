-----------------------------------
-- Unity Concord Wanted Battles (UNM)
--
-- Ethereal Junction spawn + confrontation helper.
-- Expand nmData as additional Wanted objectives are implemented.
--
-- TODO (unverified without retail capture):
-- - Yes/no menu packet/event for UNITY_WANTED_BATTLE_INTERACT
-- - Object-set limited reward messaging
-- - Exact accolade charge timing vs confirm
-- - Confrontation time / distance limits per NM
-----------------------------------
require('scripts/globals/confrontation')
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.unityNM = xi.unityNM or {}

-- Junction NPC ID -> Wanted entry
-- Content level is the RoE recommended level shown in UNITY_WANTED_BATTLE_INTERACT.
local nmData =
{
    -- Hugemaw Harold (Wanted I) -- RoE 817 -- East Ronfaure
    [17191542] = { roeId = 817, cost = 200, contentLevel = 75, mobId = 17191471, coffer = xi.item.HUGEMAW_HAROLDS_COFFER },
    [17191543] = { roeId = 817, cost = 200, contentLevel = 75, mobId = 17191472, coffer = xi.item.HUGEMAW_HAROLDS_COFFER },
    [17191544] = { roeId = 817, cost = 200, contentLevel = 75, mobId = 17191473, coffer = xi.item.HUGEMAW_HAROLDS_COFFER },

    -- Bounding Belinda (Wanted I) -- RoE 818 -- South Gustaberg
    [17216189] = { roeId = 818, cost = 200, contentLevel = 75, mobId = 17216127, coffer = xi.item.BOUNDING_BELINDAS_COFFER },
    [17216190] = { roeId = 818, cost = 200, contentLevel = 75, mobId = 17216128, coffer = xi.item.BOUNDING_BELINDAS_COFFER },
    [17216191] = { roeId = 818, cost = 200, contentLevel = 75, mobId = 17216129, coffer = xi.item.BOUNDING_BELINDAS_COFFER },
}

local CONFIRM_WINDOW = 30 -- seconds between prompt and confirm (MVP stand-in for yes/no menu)
local PARTICIPANT_RANGE = 15

---@param player CBaseEntity
---@param npc CBaseEntity
---@param entry table
---@return table
local function collectParticipants(player, npc, entry)
    local participants = {}

    for _, member in ipairs(player:getAlliance()) do
        if
            member:getZoneID() == player:getZoneID() and
            member:checkDistance(npc) <= PARTICIPANT_RANGE and
            member:getCurrency('unity_accolades') >= entry.cost and
            member:getFreeSlotsCount() > 0
        then
            table.insert(participants, member)
        end
    end

    return participants
end

---@param players table
---@param cost integer
local function chargeAccolades(players, cost)
    for _, member in ipairs(players) do
        member:delCurrency('unity_accolades', cost)
    end
end

---@param player CBaseEntity
---@param npc CBaseEntity
---@return nil
xi.unityNM.onTrigger = function(player, npc)
    local entry = nmData[npc:getID()]
    if not entry then
        return
    end

    local zoneId = player:getZoneID()
    local zoneText = zones[zoneId].text

    if not player:hasEminenceRecord(entry.roeId) then
        player:messageSpecial(zoneText.NOTHING_HAPPENS)
        return
    end

    local mob = GetMobByID(entry.mobId)
    if not mob or mob:isSpawned() then
        player:messageSpecial(zoneText.NOTHING_HAPPENS)
        return
    end

    -- TODO: Retail uses a yes/no menu on UNITY_WANTED_BATTLE_INTERACT.
    -- Param layout and event response are unverified. MVP: first trigger shows
    -- the prompt; second trigger within CONFIRM_WINDOW starts the battle.
    player:messageSpecial(zoneText.UNITY_WANTED_BATTLE_INTERACT, entry.roeId, entry.cost, entry.contentLevel)

    local confirmKey = 'unityNM_confirm_' .. npc:getID()
    local lastPrompt = player:getLocalVar(confirmKey)
    local now = GetSystemTime()

    if lastPrompt == 0 or (now - lastPrompt) > CONFIRM_WINDOW then
        player:setLocalVar(confirmKey, now)
        return
    end

    player:setLocalVar(confirmKey, 0)

    local participants = collectParticipants(player, npc, entry)
    if #participants == 0 then
        player:messageSpecial(zoneText.NOTHING_HAPPENS)
        return
    end

    -- Initiator must be able to pay and have inventory space (already filtered).
    local initiatorIncluded = false
    for _, member in ipairs(participants) do
        if member:getID() == player:getID() then
            initiatorIncluded = true
            break
        end
    end

    if not initiatorIncluded then
        player:messageSpecial(zoneText.NOTHING_HAPPENS)
        return
    end

    chargeAccolades(participants, entry.cost)

    local params =
    {
        playerList = participants,
        allRegPlayerEnmity = true,
        -- TODO: verify Wanted time limit vs retail
        timeLimit = 1800,

        onWin = function(member)
            npcUtil.giveItem(member, { { entry.coffer, 1 } })
        end,
    }

    xi.confrontation.start(player, npc, entry.mobId, params)
end
