-----------------------------------
-- ID: 6320
-- Intuila's Coffer
-- Guaranteed Wanted battle reward; open for gear / hide / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Assiduity Pants, Nourishing Earring, Intuila's Hide, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local intuilaCofferLoot =
{
    { itemId = xi.item.INTUILAS_HIDE,       weight = 50 },
    { itemId = xi.item.ASSIDUITY_PANTS,     weight = 15 },
    { itemId = xi.item.NOURISHING_EARRING,  weight = 15 },
    { itemId = 0,                            weight = 20 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(intuilaCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Intuila's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(6000, 15000))
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
