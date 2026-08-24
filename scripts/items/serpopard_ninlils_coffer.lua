-----------------------------------
-- ID: 6318
-- Serpopard Ninlil's Coffer
-- Guaranteed Wanted battle reward; open for gear / bone / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Narmar Boomerang, Nekhen Ring, Cloud Hairpin, Ninlil's Bone, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local ninlilCofferLoot =
{
    { itemId = xi.item.SERPOPARD_NINLILS_BONE, weight = 50 },
    { itemId = xi.item.NARMAR_BOOMERANG,       weight = 10 },
    { itemId = xi.item.NEKHEN_RING,            weight = 10 },
    { itemId = xi.item.CLOUD_HAIRPIN,          weight = 10 },
    { itemId = 0,                               weight = 20 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(ninlilCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Ninlil's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(4000, 10000))
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
