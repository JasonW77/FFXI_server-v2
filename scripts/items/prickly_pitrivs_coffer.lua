-----------------------------------
-- ID: 6314
-- Prickly Pitriv's Coffer
-- Guaranteed Wanted battle reward; open for gear / thread / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Charitoni Sling, Crested Torque, Dew Silk Cape, Pitriv's Thread, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local pitrivCofferLoot =
{
    { itemId = xi.item.PRICKLY_PITRIVS_THREAD, weight = 50 },
    { itemId = xi.item.CHARITONI_SLING,        weight = 10 },
    { itemId = xi.item.CRESTED_TORQUE,         weight = 10 },
    { itemId = xi.item.DEW_SILK_CAPE,          weight = 10 },
    { itemId = 0,                               weight = 20 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(pitrivCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Pitriv's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(2000, 6000))
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
