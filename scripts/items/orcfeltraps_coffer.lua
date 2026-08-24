-----------------------------------
-- ID: 6322
-- Orcfeltrap's Coffer
-- Guaranteed Wanted battle reward; open for gear / leaf / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Shinjutsu-no-Obi, Tancho, Orcfeltrap's Leaf, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local orcfeltrapCofferLoot =
{
    { itemId = xi.item.ORCFELTRAPS_LEAF,  weight = 50 },
    { itemId = xi.item.SHINJUTSU_NO_OBI,  weight = 15 },
    { itemId = xi.item.TANCHO,            weight = 15 },
    { itemId = 0,                          weight = 20 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(orcfeltrapCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Orcfeltrap's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(6000, 15000))
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
