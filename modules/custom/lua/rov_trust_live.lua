-----------------------------------
-- Non-retail QoL: RoV trust substitutes for Live (ENABLE_ROV = 0).
-- - Rhapsody White/Umber/Crimson from LB1/LB4/LB5
-- - Cipher Moogle in Ru'Lude (story-gated cipher catalog)
-- - Trusts allowed in alliances (alliance-wide uniqueness)
-- Enable: custom/lua/rov_trust_live.lua in modules/init.txt
-- Also set main.ALLOW_TRUST_IN_ALLIANCE = 1 (and rebuild xi_map for C++ gate)
-----------------------------------
require('modules/module_utils')
require('scripts/globals/missions')
require('scripts/globals/npc_util')
require('scripts/globals/quests')
require('scripts/globals/shop')
require('scripts/globals/trust')
-----------------------------------
local m = Module:new('rov_trust_live')

local CIPHER_PRICE = 10000

local nomadMoogleLook = '0x0000D50300000000000000000000000000000000'

-- Copied from scripts/globals/trust.lua (file-local there).
local rovKIBattlefieldIDs = set{
    5,    -- Shattering Stars (WAR LB5)
    6,    -- Shattering Stars (BLM LB5)
    7,    -- Shattering Stars (RNG LB5)
    70,   -- Shattering Stars (RDM LB5)
    71,   -- Shattering Stars (THF LB5)
    72,   -- Shattering Stars (BST LB5)
    101,  -- Shattering Stars (MNK LB5)
    102,  -- Shattering Stars (WHM LB5)
    103,  -- Shattering Stars (SMN LB5)
    163,  -- Survival of the Wisest (SCH LB5)
    194,  -- Shattering Stars (SAM LB5)
    195,  -- Shattering Stars (NIN LB5)
    196,  -- Shattering Stars (DRG LB5)
    517,  -- Shattering Stars (PLD LB5)
    518,  -- Shattering Stars (DRK LB5)
    519,  -- Shattering Stars (BRD LB5)
    530,  -- A Furious Finale (DNC LB5)
    1091, -- Breaking the Bonds of Fate (COR LB5)
    1123, -- Achieving True Power (PUP LB5)
    1154, -- The Beast Within (BLU LB5)
}

-- Maat is at ~10.88, 3.10, 119.47; place Cipher Moogle beside him.
local cipherMooglePos =
{
    x        = 12.500,
    y        = 2.200,
    z        = 118.200,
    rotation = 160,
}

local kiGrants =
{
    {
        area    = xi.questLog.JEUNO,
        quest   = xi.quest.id.jeuno.IN_DEFIANT_CHALLENGE,
        keyItem = xi.ki.RHAPSODY_IN_WHITE,
        label   = 'Rhapsody in White',
    },
    {
        area    = xi.questLog.JEUNO,
        quest   = xi.quest.id.jeuno.RIDING_ON_THE_CLOUDS,
        keyItem = xi.ki.RHAPSODY_IN_UMBER,
        label   = 'Rhapsody in Umber',
    },
    {
        area    = xi.questLog.JEUNO,
        quest   = xi.quest.id.jeuno.SHATTERING_STARS,
        keyItem = xi.ki.RHAPSODY_IN_CRIMSON,
        label   = 'Rhapsody in Crimson',
    },
}

-- Unlock helpers (shop already requires Trust permit).
local function alwaysUnlocked()
    return true
end

local function completedLB1(player)
    return player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.IN_DEFIANT_CHALLENGE)
end

local function completedLB4(player)
    return player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.RIDING_ON_THE_CLOUDS)
end

local function completedArkAngels(player)
    return player:hasCompletedMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.ARK_ANGELS)
end

local function completedAwakening(player)
    return player:hasCompletedMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.AWAKENING)
end

local function completedDawn(player)
    return player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.DAWN)
end

local function completedEternalMercenary(player)
    return player:hasCompletedMission(xi.mission.log_id.TOAU, xi.mission.id.toau.ETERNAL_MERCENARY)
end

local function completedLestWeForget(player)
    return player:hasCompletedMission(xi.mission.log_id.WOTG, xi.mission.id.wotg.LEST_WE_FORGET)
end

local function completedAcpFin(player)
    return player:hasCompletedMission(xi.mission.log_id.ACP, xi.mission.id.acp.A_CRYSTALLINE_PROPHECY_FIN)
end

local function completedAmkFin(player)
    return player:hasCompletedMission(xi.mission.log_id.AMK, xi.mission.id.amk.SMASH_A_MALEVOLENT_MENACE)
end

local function completedAsaFin(player)
    return player:hasCompletedMission(xi.mission.log_id.ASA, xi.mission.id.asa.A_SHANTOTTO_ASCENSION_FIN)
end

-- Shop entries: unlocked when unlock() is true. Price is always CIPHER_PRICE.
local cipherCatalog =
{
    -- RoE tutorial / starter trusts (permit opens shop)
    { item = xi.item.CIPHER_OF_VALAINERALS_ALTER_EGO, unlock = alwaysUnlocked },
    { item = xi.item.CIPHER_OF_MIHLIS_ALTER_EGO,      unlock = alwaysUnlocked },
    { item = xi.item.CIPHER_OF_TENZENS_ALTER_EGO,     unlock = alwaysUnlocked },
    { item = xi.item.CIPHER_OF_ADELHEIDS_ALTER_EGO,   unlock = alwaysUnlocked },
    { item = xi.item.CIPHER_OF_JOACHIMS_ALTER_EGO,    unlock = alwaysUnlocked },

    -- LB1 (In Defiant Challenge)
    { item = xi.item.CIPHER_OF_SAKURAS_ALTER_EGO,   unlock = completedLB1 },
    { item = xi.item.CIPHER_OF_F_COFFINS_ALTER_EGO, unlock = completedLB1 },
    { item = xi.item.CIPHER_OF_QULTADAS_ALTER_EGO,  unlock = completedLB1 },
    { item = xi.item.CIPHER_OF_KINGS_ALTER_EGO,     unlock = completedLB1 },
    { item = xi.item.CIPHER_OF_CIDS_ALTER_EGO,      unlock = completedLB1 },
    { item = xi.item.CIPHER_OF_GILGAMESHS_ALTER_EGO, unlock = completedLB1 },

    -- LB4
    { item = xi.item.CIPHER_OF_KORU_MORUS_ALTER_EGO, unlock = completedLB4 },

    -- RoZ ZM14 Ark Angels (AAHM / AAEV implemented; others stubbed until AI done)
    { item = xi.item.CIPHER_OF_AA_HMS_ALTER_EGO, unlock = completedArkAngels },
    { item = xi.item.CIPHER_OF_AA_EVS_ALTER_EGO, unlock = completedArkAngels },
    -- TODO: enable when AAMR / AATT / AAGK trust AI is finished
    -- { item = xi.item.CIPHER_OF_AA_MRS_ALTER_EGO, unlock = completedArkAngels },
    -- { item = xi.item.CIPHER_OF_AA_TTS_ALTER_EGO, unlock = completedArkAngels },
    -- { item = xi.item.CIPHER_OF_AA_GKS_ALTER_EGO, unlock = completedArkAngels },

    -- RoZ Awakening
    { item = xi.item.CIPHER_OF_ZEIDS_ALTER_EGO,        unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_LIONS_ALTER_EGO,        unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_ALDOS_ALTER_EGO,        unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_BRYGIDS_ALTER_EGO,      unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_RONGELOUTSS_ALTER_EGO,  unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_RAHALS_ALTER_EGO,       unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_STAR_SIBYLS_ALTER_EGO,  unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_KARAHAS_ALTER_EGO,      unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_UKAS_ALTER_EGO,         unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_D_SHANTOTTOS_ALTER_EGO, unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_LEHKOS_ALTER_EGO,       unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_LIONS_ALTER_EGO_II,     unlock = completedAwakening },
    { item = xi.item.CIPHER_OF_ZEIDS_ALTER_EGO_II,     unlock = completedAwakening },

    -- CoP Dawn
    { item = xi.item.CIPHER_OF_TENZENS_ALTER_EGO_II, unlock = completedDawn },
    { item = xi.item.CIPHER_OF_PRISHES_ALTER_EGO_II, unlock = completedDawn },

    -- ToAU Eternal Mercenary
    { item = xi.item.CIPHER_OF_NAJAS_ALTER_EGO,           unlock = completedEternalMercenary },
    { item = xi.item.CIPHER_OF_OVJANGS_ALTER_EGO,         unlock = completedEternalMercenary },
    { item = xi.item.CIPHER_OF_MNEJINGS_ALTER_EGO,        unlock = completedEternalMercenary },
    { item = xi.item.CIPHER_OF_LUZAFS_ALTER_EGO,          unlock = completedEternalMercenary },
    { item = xi.item.CIPHER_OF_NAJELITHS_ALTER_EGO,       unlock = completedEternalMercenary },
    { item = xi.item.CIPHER_OF_RUGHADJEENS_ALTER_EGO,     unlock = completedEternalMercenary },
    { item = xi.item.CIPHER_OF_LHES_ALTER_EGO,            unlock = completedEternalMercenary },
    { item = xi.item.CIPHER_OF_AUGUSTS_ALTER_EGO,         unlock = completedEternalMercenary },
    { item = xi.item.CIPHER_OF_NASHMEIRAS_ALTER_EGO_II,   unlock = completedEternalMercenary },

    -- WoTG Lest We Forget
    { item = xi.item.CIPHER_OF_MONBERAUXS_ALTER_EGO,   unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_MUMORS_ALTER_EGO,       unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_MUMORS_ALTER_EGO_II,    unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_ELIVIRAS_ALTER_EGO,     unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_NOILLURIES_ALTER_EGO,   unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_LHUS_ALTER_EGO,         unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_LEONOYNES_ALTER_EGO,    unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_MAXIMILIANS_ALTER_EGO,  unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_KAYEELS_ALTER_EGO,      unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_RAINEMARDS_ALTER_EGO,   unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_ROBEL_AKBELS_ALTER_EGO, unlock = completedLestWeForget },
    { item = xi.item.CIPHER_OF_LILISETTES_ALTER_EGO_II, unlock = completedLestWeForget },

    -- ACP fin
    { item = xi.item.CIPHER_OF_MILDAURIONS_ALTER_EGO, unlock = completedAcpFin },
    { item = xi.item.CIPHER_OF_ULLEGORES_ALTER_EGO,   unlock = completedAcpFin },
    { item = xi.item.CIPHER_OF_TEODORS_ALTER_EGO,     unlock = completedAcpFin },
    { item = xi.item.CIPHER_OF_AREUHATS_ALTER_EGO,    unlock = completedAcpFin },

    -- AMK (Smash a Malevolent Menace)
    { item = xi.item.CIPHER_OF_A_MOOGLES_ALTER_EGO,   unlock = completedAmkFin },
    { item = xi.item.CIPHER_OF_KUPOFRIEDS_ALTER_EGO,  unlock = completedAmkFin },
    { item = xi.item.CIPHER_OF_FABLINIXS_ALTER_EGO,   unlock = completedAmkFin },
    { item = xi.item.CIPHER_OF_ABENZIOS_ALTER_EGO,    unlock = completedAmkFin },

    -- ASA fin
    { item = xi.item.CIPHER_OF_KUYINS_ALTER_EGO,         unlock = completedAsaFin },
    { item = xi.item.CIPHER_OF_MAYAKOVS_ALTER_EGO,       unlock = completedAsaFin },
    { item = xi.item.CIPHER_OF_BABBANS_ALTER_EGO,        unlock = completedAsaFin },
    { item = xi.item.CIPHER_OF_SHANTOTTOS_ALTER_EGO_II,  unlock = completedAsaFin },
    { item = xi.item.CIPHER_OF_KUKKIS_ALTER_EGO,         unlock = completedAsaFin },
    { item = xi.item.CIPHER_OF_MAKKIS_ALTER_EGO,         unlock = completedAsaFin },
}

local function tryGrantKeyItem(player, keyItem, label)
    if player:hasKeyItem(keyItem) then
        return
    end

    npcUtil.giveKeyItem(player, keyItem)
    player:printToPlayer(
        string.format('%s: alter ego benefits unlocked.', label),
        xi.msg.channel.SYSTEM_3,
        '')
end

local function backfillKeyItems(player)
    for _, grant in ipairs(kiGrants) do
        if player:hasCompletedQuest(grant.area, grant.quest) then
            tryGrantKeyItem(player, grant.keyItem, grant.label)
        end
    end
end

local function buildCipherStock(player)
    local stock = {}

    for _, entry in ipairs(cipherCatalog) do
        if entry.unlock(player) then
            table.insert(stock, { entry.item, CIPHER_PRICE })
        end
    end

    return stock
end

local function spawnCipherMoogle(zone)
    zone:insertDynamicEntity({
        objtype    = xi.objType.NPC,
        name       = 'Cipher Moogle',
        packetName = 'Cipher Moogle',
        look       = nomadMoogleLook,
        x          = cipherMooglePos.x,
        y          = cipherMooglePos.y,
        z          = cipherMooglePos.z,
        rotation   = cipherMooglePos.rotation,
        widescan   = 1,
        onTrigger  = function(player, npc)
            if not xi.trust.hasPermit(player) then
                player:printToPlayer(
                    'Kupo! Come back once you have a Trust permit.',
                    xi.msg.channel.NS_SAY,
                    'Cipher Moogle')
                return
            end

            local stock = buildCipherStock(player)
            if #stock == 0 then
                player:printToPlayer(
                    'Kupopo... nothing for you yet.',
                    xi.msg.channel.NS_SAY,
                    'Cipher Moogle')
                return
            end

            xi.shop.general(player, stock)
        end,
    })
end

-- Collect trusts across the alliance (each party scanned once).
local function forEachAllianceTrust(caster, callback)
    local alliance = caster:getAlliance()
    if alliance == nil then
        return
    end

    local seenPartyLeaders = {}

    for _, member in ipairs(alliance) do
        if member:getObjType() == xi.objType.PC then
            local leader = member:getPartyLeader()
            local leaderId = leader and leader:getID() or member:getID()

            if not seenPartyLeaders[leaderId] then
                seenPartyLeaders[leaderId] = true

                for _, entity in ipairs(member:getPartyWithTrusts()) do
                    if entity:getObjType() == xi.objType.TRUST then
                        callback(entity)
                    end
                end
            end
        end
    end
end

local function trustConflicts(existingTrustId, spellId, notAllowedTrustIds)
    if existingTrustId == spellId then
        return true
    end

    if type(notAllowedTrustIds) == 'number' then
        return existingTrustId == notAllowedTrustIds
    end

    if type(notAllowedTrustIds) == 'table' then
        for _, blockedId in pairs(notAllowedTrustIds) do
            if type(blockedId) == 'number' and existingTrustId == blockedId then
                return true
            end
        end
    end

    return false
end

m:addOverride('npcUtil.completeQuest', function(player, area, quest, params)
    local result = super(player, area, quest, params)

    if result then
        for _, grant in ipairs(kiGrants) do
            if area == grant.area and quest == grant.quest then
                tryGrantKeyItem(player, grant.keyItem, grant.label)
            end
        end
    end

    return result
end)

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    backfillKeyItems(player)
end)

m:addOverride('xi.zones.RuLude_Gardens.Zone.onInitialize', function(zone)
    super(zone)
    spawnCipherMoogle(zone)
end)

-- Allow trusts in alliances; enforce alliance-wide uniqueness (incl. I/II pairs via notAllowedTrustIds).
m:addOverride('xi.trust.canCast', function(caster, spell, notAllowedTrustIds)
    if xi.settings.main.ENABLE_TRUST_CASTING == 0 then
        return xi.msg.basic.TRUST_NO_CAST_TRUST
    end

    if caster:getGMLevel() > 0 and caster:getVisibleGMLevel() >= 3 then
        return 0
    end

    -- NOTE: Alliance block intentionally removed (Live QoL).

    if not caster:canUseMisc(xi.zoneMisc.TRUST) then
        return xi.msg.basic.TRUST_NO_CALL_AE
    end

    local leader = caster:getPartyLeader()
    if leader and caster:getID() ~= leader:getID() then
        caster:messageSystem(xi.msg.system.TRUST_SOLO_OR_LEADER)
        return -1
    end

    if caster:isSeekingParty() then
        caster:messageSystem(xi.msg.system.TRUST_NO_SEEKING_PARTY)
        return -1
    end

    local lastPartyMemberAddedTime = caster:getPartyLastMemberJoinedTime()
    if GetSystemTime() - lastPartyMemberAddedTime < 120 then
        caster:messageSystem(xi.msg.system.TRUST_DELAY_NEW_PARTY_MEMBER)
        return -1
    end

    if caster:hasEnmity() then
        caster:messageSystem(xi.msg.system.TRUST_NO_ENMITY)
        return -1
    end

    local numPt     = 0
    local numTrusts = 0
    local party     = caster:getPartyWithTrusts()
    local spellId   = spell:getID()

    for _, member in pairs(party) do
        if member:getObjType() == xi.objType.TRUST then
            if trustConflicts(member:getTrustID(), spellId, notAllowedTrustIds) then
                caster:messageSystem(xi.msg.system.TRUST_ALREADY_CALLED)
                return -1
            end

            numTrusts = numTrusts + 1
        end

        numPt = numPt + 1
    end

    -- Alliance-wide uniqueness (other parties' trusts)
    if caster:checkSoloPartyAlliance() == 2 then
        local blocked = false

        forEachAllianceTrust(caster, function(trustEntity)
            if
                not blocked and
                trustConflicts(trustEntity:getTrustID(), spellId, notAllowedTrustIds)
            then
                blocked = true
            end
        end)

        if blocked then
            caster:messageSystem(xi.msg.system.TRUST_ALREADY_CALLED)
            return -1
        end
    end

    if numPt >= 6 then
        caster:messageSystem(xi.msg.system.TRUST_MAXIMUM_NUMBER)
        return -1
    end

    local casterBattlefieldID = caster:getBattlefieldID()
    if rovKIBattlefieldIDs[casterBattlefieldID] then
        if not caster:hasKeyItem(xi.ki.RHAPSODY_IN_UMBER) then
            return xi.msg.basic.TRUST_NO_CAST_TRUST
        end
    elseif
        xi.battlefield.contents[casterBattlefieldID] and
        not xi.battlefield.contents[casterBattlefieldID].allowTrusts
    then
        return xi.msg.basic.TRUST_NO_CAST_TRUST
    end

    -- Limits set by ROV Key Items (granted via LB quests on Live)
    if numTrusts >= 3 and not caster:hasKeyItem(xi.ki.RHAPSODY_IN_WHITE) then
        caster:messageSystem(xi.msg.system.TRUST_MAXIMUM_NUMBER)
        return -1
    elseif numTrusts >= 4 and not caster:hasKeyItem(xi.ki.RHAPSODY_IN_CRIMSON) then
        caster:messageSystem(xi.msg.system.TRUST_MAXIMUM_NUMBER)
        return -1
    end

    if not xi.trust.checkBattlefieldTrustCount(caster) then
        return xi.msg.basic.TRUST_NO_CAST_TRUST
    end

    return 0
end)

return m
