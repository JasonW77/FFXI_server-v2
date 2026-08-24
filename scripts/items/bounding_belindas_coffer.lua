-----------------------------------
-- ID: 6313
-- Bounding Belinda's Coffer
-- Guaranteed Wanted battle reward; open for gear / hide / gil.
--
-- Loot rates are stubs (TODO: verify vs retail / community samples).
-- Known contents: Adsilio Boots, Emico Mantle, Salire Belt, Belinda's Hide, gil.
-----------------------------------
---@type TItem
local itemObject = {}

-- TODO: replace weights with captured / sampled rates
local belindaCofferLoot =
{
    { itemId = xi.item.BOUNDING_BELINDAS_HIDE, weight = 50 },
    { itemId = xi.item.ADSILIO_BOOTS,          weight = 10 },
    { itemId = xi.item.EMICO_MANTLE,           weight = 10 },
    { itemId = xi.item.SALIRE_BELT,            weight = 10 },
    { itemId = 0,                              weight = 20 }, -- gil placeholder
}

itemObject.onItemCheck = function(target, item, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    local result = xi.itemUtils.pickItemRandom(belindaCofferLoot)

    if result == 0 then
        -- TODO: verify gil amount range from Belinda's Coffer vs retail
        npcUtil.giveCurrency(target, 'gil', math.random(2000, 6000))
    elseif result == xi.item.BOUNDING_BELINDAS_HIDE then
        -- BG-Wiki: chance to obtain 1~3 hide from Belinda's Coffer
        npcUtil.giveItem(target, { { result, math.random(1, 3) } })
    else
        npcUtil.giveItem(target, { { result, 1 } })
    end
end

return itemObject
