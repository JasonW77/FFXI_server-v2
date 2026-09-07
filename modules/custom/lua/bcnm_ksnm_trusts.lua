-----------------------------------
-- Non-retail QoL: allow Trusts in BCNM / KSNM (orb) battlefields.
-- Cast-time allow lives in rov_trust_live (canCast / checkBattlefieldTrustCount).
-- This module still flips allowTrusts on the registered content at server start.
-- Level Restriction still clears Trusts on entry; recall after the cap.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('bcnm_ksnm_trusts')

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

    local contents = xi.battlefield and xi.battlefield.contents
    if not contents then
        print('bcnm_ksnm_trusts: xi.battlefield.contents missing at onServerStart')
        return
    end

    local enabled = 0
    for _, content in pairs(contents) do
        local entryItem = content.requiredItems and content.requiredItems[1]
        if entryItem and sealOrbs[entryItem] then
            content.allowTrusts = true
            enabled = enabled + 1
        end
    end

    print('bcnm_ksnm_trusts: allowTrusts enabled on ' .. enabled .. ' BCNM/KSNM battlefields')
end)

return m
