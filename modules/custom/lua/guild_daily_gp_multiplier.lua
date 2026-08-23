-----------------------------------
-- Non-retail QoL: multiply daily GP turn-in cap.
-- Requires this module enabled in local modules/init.txt:
--   modules/custom/lua/guild_daily_gp_multiplier.lua
-- Add to local settings/map.lua (setting alone has no effect without the module):
--   GUILD_DAILY_GP_MULTIPLIER = 1, -- 1 = retail; 2/3/4/5 = 2x/3x/4x/5x daily GP turn-in cap
-----------------------------------
require('modules/module_utils')
require('scripts/globals/hobbies/crafting/guild_points')
require('scripts/globals/hobbies/crafting/utils')
require('scripts/globals/npc_util')
-----------------------------------
local m = Module:new('guild_daily_gp_multiplier')

local function getMultiplier()
    return math.max(1, math.floor(xi.settings.map.GUILD_DAILY_GP_MULTIPLIER or 1))
end

local function scaleRemaining(remaining)
    return remaining * getMultiplier()
end

local function calculateKeyItemBitmask(player, rank, keyItemTable)
    local keyItemBits = 0

    for currentBit, keyItem in pairs(keyItemTable) do
        if rank >= keyItem.rank then
            if not player:hasKeyItem(keyItem.id) then
                keyItemBits = bit.bor(keyItemBits, bit.lshift(1, currentBit))
            end
        end
    end

    return keyItemBits
end

-- C++ awards retail GP and bumps daily_points by P. Scale consumption so the
-- retail cap allows M times as many turn-ins, and grant the extra currency here.
local function applyBonus(player, guildId, points)
    local multiplier = getMultiplier()

    if multiplier <= 1 or points <= 0 then
        return points
    end

    local currency = xi.crafting.guildTable[guildId][2]
    player:addCurrency(currency, points * (multiplier - 1))

    local daily = player:getCharVar('[GUILD]daily_points')
    player:setCharVar('[GUILD]daily_points', daily - points + math.floor(points / multiplier), JstMidnight())

    return points * multiplier
end

m:addOverride('xi.crafting.guildPointOnTrade', function(player, npc, trade, csid, guildId)
    if getMultiplier() <= 1 then
        super(player, npc, trade, csid, guildId)
        return
    end

    local ID                 = zones[player:getZoneID()]
    local _, remainingPoints = player:getCurrentGPItem(guildId)

    if player:getCharVar('[GUILD]currentGuild') - 1 == guildId then
        if remainingPoints == 0 then
            player:messageText(npc, ID.text.NO_MORE_GP_ELIGIBLE)
        else
            local totalPoints = 0

            for tradeSlot = 0, 8 do
                local items, points = player:addGuildPoints(guildId, tradeSlot)

                if items ~= 0 and points ~= 0 then
                    totalPoints = totalPoints + applyBonus(player, guildId, points)
                    trade:confirmSlot(tradeSlot, items)
                end
            end

            if totalPoints > 0 then
                player:confirmTrade()
                player:startEvent(csid, totalPoints)
            end
        end
    end
end)

m:addOverride('xi.crafting.guildPointOnTrigger', function(player, csid, guildId)
    if getMultiplier() <= 1 then
        super(player, csid, guildId)
        return
    end

    local currency                = xi.crafting.guildTable[guildId][2]
    local gpItem, remainingPoints = player:getCurrentGPItem(guildId)
    local rank                    = player:getSkillRank(xi.crafting.guildTable[guildId][1])
    local skillCap                = (rank + 1) * 10
    local keyItemBits             = calculateKeyItemBitmask(player, rank, xi.crafting.guildKeyItemTable[guildId])

    player:startEvent(csid, player:getCurrency(currency), player:getCharVar('[GUILD]currentGuild') - 1, gpItem, scaleRemaining(remainingPoints), skillCap, 0, keyItemBits, 0)
end)

m:addOverride('xi.crafting.guildPointOnEventUpdate', function(player, option, target, guildId)
    if getMultiplier() <= 1 then
        super(player, option, target, guildId)
        return
    end

    local category           = bit.band(bit.rshift(option, 2), 3)
    local ID                 = zones[player:getZoneID()]
    local _, remainingPoints = player:getCurrentGPItem(guildId)
    local rank               = player:getSkillRank(xi.crafting.guildTable[guildId][1])
    local skillCap           = (rank + 1) * 10
    local currency           = xi.crafting.guildTable[guildId][2]
    local keyItems           = xi.crafting.guildKeyItemTable[guildId]

    remainingPoints = scaleRemaining(remainingPoints)

    -- GP Key Item Option.
    if category == 3 then
        local keyItem = keyItems[bit.band(bit.rshift(option, 5), 15) - 1]

        if keyItem and rank >= keyItem.rank then
            if player:getCurrency(currency) >= keyItem.cost then
                player:delCurrency(currency, keyItem.cost)
                npcUtil.giveKeyItem(player, keyItem.id)
            else
                player:messageText(target, ID.text.NOT_HAVE_ENOUGH_GP, false, 6)
            end
        end

        player:updateEvent(keyItem.id, 0, keyItem.cost, remainingPoints, skillCap, 0, calculateKeyItemBitmask(player, rank, xi.crafting.guildKeyItemTable[guildId]), 1)

    -- GP Item Option.
    elseif category == 2 or category == 1 then
        local index    = bit.band(option, 3)
        local items    = xi.crafting.guildItemTable[guildId]
        local item     = items[(category - 1) * 4 + index]
        local quantity = math.min(bit.rshift(option, 9), 12)
        local cost     = quantity * item.cost

        if item and rank >= item.rank then
            if player:getCurrency(currency) >= cost then
                local delivered = 0

                for count = 1, quantity do
                    if player:addItem(item.id, true) then
                        player:delCurrency(currency, item.cost)
                        player:messageSpecial(ID.text.ITEM_OBTAINED, item.id)
                        delivered = delivered + 1
                    end
                end

                if delivered == 0 then
                    player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, item.id)
                end
            else
                player:messageText(target, ID.text.NOT_HAVE_ENOUGH_GP, false, 6)
            end
        end

        player:updateEvent(player:getCurrency(currency), player:getCharVar('[GUILD]currentGuild') - 1, item.cost, remainingPoints, skillCap, 0, calculateKeyItemBitmask(player, rank, xi.crafting.guildKeyItemTable[guildId]), 1)

    -- HQ crystal Option.
    elseif
        category == 0 and
        option ~= utils.EVENT_CANCELLED_OPTION
    then
        local crystal  = xi.crafting.hqCrystals[bit.band(bit.rshift(option, 5), 15)]
        local quantity = bit.rshift(option, 9)
        local cost     = quantity * crystal.cost

        if crystal and rank >= 3 then
            if
                player:getCurrency(currency) >= cost and
                npcUtil.giveItem(player, { { crystal.id, quantity } })
            then
                player:delCurrency(currency, cost)
            else
                player:messageText(target, ID.text.NOT_HAVE_ENOUGH_GP, false, 6)
            end
        end

        player:updateEvent(crystal.id, quantity, crystal.cost, remainingPoints, skillCap, 0, calculateKeyItemBitmask(player, rank, xi.crafting.guildKeyItemTable[guildId]), 1)
    end
end)

return m
