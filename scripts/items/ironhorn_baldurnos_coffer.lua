-----------------------------------
-- ID: 6315
-- Ironhorn Baldurno's Coffer
-- Guaranteed Wanted battle reward; open for gear / horn / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Thorfinn Shield, Grit Earring, Bleating Mantle, Baldurno's Horn, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local baldurnoCofferLoot =
{
    { itemId = xi.item.IRONHORN_BALDURNOS_HORN, weight = 50 },
    { itemId = xi.item.THORFINN_SHIELD,         weight = 10 },
    { itemId = xi.item.GRIT_EARRING,            weight = 10 },
    { itemId = xi.item.BLEATING_MANTLE,         weight = 10 },
    { itemId = 0,                                weight = 20 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(baldurnoCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Baldurno's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(4000, 10000))
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
