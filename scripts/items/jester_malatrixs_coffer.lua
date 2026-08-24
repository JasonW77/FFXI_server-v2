-----------------------------------
-- ID: 6330
-- Jester Malatrix's Coffer
-- Guaranteed Wanted battle reward; open for gear / shard / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Buramgh, Evalach, Malatrix's Shard, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local malatrixCofferLoot =
{
    { itemId = xi.item.JESTER_MALATRIXS_SHARD, weight = 50 },
    { itemId = xi.item.BURAMGH,                weight = 15 },
    { itemId = xi.item.EVALACH,                weight = 15 },
    { itemId = 0,                               weight = 20 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(malatrixCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Malatrix's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(6000, 15000))
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
