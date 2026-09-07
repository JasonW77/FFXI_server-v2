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

local function isSealOrbBattlefield(content)
    if not content then
        return false
    end

    local entryItem = content.requiredItems and content.requiredItems[1]
    if not entryItem and content.tradeItems then
        entryItem = content.tradeItems[1]
    end

    return entryItem ~= nil and sealOrbs[entryItem] == true
end

local function enableSealOrbTrusts()
    local contents = xi.battlefield and xi.battlefield.contents
    if not contents then
        return 0
    end

    local enabled = 0
    for _, content in pairs(contents) do
        if isSealOrbBattlefield(content) then
            content.allowTrusts = true
            enabled = enabled + 1
        end
    end

    return enabled
end

m:addOverride('xi.server.onServerStart', function()
    super()

    local enabled = enableSealOrbTrusts()
    print(string.format('bcnm_ksnm_trusts: allowTrusts enabled on %d BCNM/KSNM battlefields', enabled))
end)

-- Cast-time safety net (wraps rov_trust_live / core canCast). Ensures the
-- battlefield flag is set even if contents were registered after onServerStart.
m:addOverride('xi.trust.canCast', function(caster, spell, notAllowedTrustIds)
    local bfId = caster:getBattlefieldID()
    if bfId and bfId > 0 then
        local content = xi.battlefield.contents[bfId]
        if isSealOrbBattlefield(content) then
            content.allowTrusts = true
        end
    end

    return super(caster, spell, notAllowedTrustIds)
end)

return m
