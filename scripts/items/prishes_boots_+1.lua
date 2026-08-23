-----------------------------------
-- ID: 24271
-- Item: Prishe's Boots +1
-- Enchantment: TP+3000
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, caster)
    return 0
end

itemObject.onItemUse = function(target)
    target:addTP(3000)
end

return itemObject
