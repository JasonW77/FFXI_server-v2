-----------------------------------
-- ID: 6312
-- Hugemaw Harold's Coffer
-- Guaranteed Wanted battle reward; open for gear / ore / mats / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Setae Ring, Harold's Red Ore, Guatambu Log, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local haroldCofferLoot =
{
    { itemId = xi.item.CHUNK_OF_HUGEMAW_HAROLDS_RED_ORE, weight = 40 },
    { itemId = xi.item.GUATAMBU_LOG,                     weight = 20 },
    { itemId = xi.item.SETAE_RING,                       weight = 10 },
    { itemId = 0,                                        weight = 30 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(haroldCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Harold's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(2000, 6000))
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
