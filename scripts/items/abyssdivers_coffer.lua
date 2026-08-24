-----------------------------------
-- ID: 6319
-- Abyssdiver's Coffer
-- Guaranteed Wanted battle reward; open for gear / feather / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Wingcutter, Macabre Gauntlets, Abyssdiver's Feather, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local abyssdiverCofferLoot =
{
    { itemId = xi.item.ABYSSDIVERS_FEATHER, weight = 50 },
    { itemId = xi.item.WINGCUTTER,          weight = 15 },
    { itemId = xi.item.MACABRE_GAUNTLETS,   weight = 15 },
    { itemId = 0,                            weight = 20 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(abyssdiverCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Abyssdiver's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(6000, 15000))
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
