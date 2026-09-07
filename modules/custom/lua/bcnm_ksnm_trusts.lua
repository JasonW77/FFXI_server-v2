-----------------------------------
-- Non-retail QoL: allow Trusts in BCNM / KSNM (orb) battlefields.
-- Level Restriction still clears Trusts on entry; recall after the cap.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('bcnm_ksnm_trusts')

-- Beastmen's Seal (BCNM) + Kindred's Seal (KSNM) entry orbs
local sealOrbs = set{
    xi.item.CLOUDY_ORB,
    xi.item.SKY_ORB,
    xi.item.STAR_ORB,
    xi.item.COMET_ORB,
    xi.item.MOON_ORB,
    xi.item.CLOTHO_ORB,
    xi.item.LACHESIS_ORB,
    xi.item.ATROPOS_ORB,
    xi.item.THEMIS_ORB,
}

m:addOverride('xi.server.onServerStart', function()
    super()

    for _, content in pairs(xi.battlefield.contents) do
        local entryItem = content.requiredItems and content.requiredItems[1]
        if entryItem and sealOrbs[entryItem] then
            content.allowTrusts = true
        end
    end
end)

return m
