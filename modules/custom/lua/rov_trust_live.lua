-----------------------------------
-- Non-retail QoL: RoV trust substitutes for Live (ENABLE_ROV = 0).
-- - Rhapsody White/Crimson/Umber via Cipher Moogle seal training
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

-- Slightly south of Maat in Ru'Lude Gardens.
local cipherMooglePos =
{
    x        = 10.198,
    y        = 3.100,
    z        = 116.924,
    rotation = 198,
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

-- Capacity / pact training (seal costs). Order: White -> Crimson -> Umber.
local capacityQuests =
{
    {
        menu      = 'Trust Capacity Training',
        keyItem   = xi.ki.RHAPSODY_IN_WHITE,
        sealItem  = xi.item.BEASTMENS_SEAL,
        sealQty   = 15,
        sealName  = 'Beastmen\'s Seals',
        minLevel  = 30,
        isReady   = function(player)
            return not player:hasKeyItem(xi.ki.RHAPSODY_IN_WHITE)
        end,
        offer     = 'Trust Capacity Training, kupo! Those beastmen leave sticky seals everywhere... bring me 15 Beastmen\'s Seals, and I\'ll stretch your pact so a fourth alter ego can join you!',
        confirm   = 'Hand over 15 Beastmen\'s Seals for Trust Capacity Training?',
        success   = 'Oooh, sticky and perfect! Training complete -- your pact holds a fourth alter ego now, kupo!',
        lack      = 'That\'s shy of 15 Beastmen\'s Seals, kupo. Count again -- I don\'t do IOUs!',
    },
    {
        menu      = 'Trust Capacity Training II',
        keyItem   = xi.ki.RHAPSODY_IN_CRIMSON,
        sealItem  = xi.item.BEASTMENS_SEAL,
        sealQty   = 30,
        sealName  = 'Beastmen\'s Seals',
        minLevel  = 50,
        isReady   = function(player)
            return player:hasKeyItem(xi.ki.RHAPSODY_IN_WHITE) and
                not player:hasKeyItem(xi.ki.RHAPSODY_IN_CRIMSON)
        end,
        offer     = 'Trust Capacity Training II, kupo! Bigger roster, bigger pile -- 30 Beastmen\'s Seals this time. Pass, and a fifth alter ego answers your call!',
        confirm   = 'Hand over 30 Beastmen\'s Seals for Trust Capacity Training II?',
        success   = 'Thirty seals! My wings can barely flap! Training II done -- five alter egos, full chorus, kupo!',
        lack      = 'Thirty Beastmen\'s Seals, kupo! Ambition is good -- empty pockets are not!',
    },
    {
        menu      = 'Strengthen Alter Ego Pact',
        keyItem   = xi.ki.RHAPSODY_IN_UMBER,
        sealItem  = xi.item.KINDREDS_SEAL,
        sealQty   = 15,
        sealName  = 'Kindred\'s Seals',
        minLevel  = 70,
        isReady   = function(player)
            return player:hasKeyItem(xi.ki.RHAPSODY_IN_WHITE) and
                player:hasKeyItem(xi.ki.RHAPSODY_IN_CRIMSON) and
                not player:hasKeyItem(xi.ki.RHAPSODY_IN_UMBER)
        end,
        offer     = 'Strengthen Alter Ego Pact, kupo! Beastmen seals won\'t cut it for the hard stuff -- I need 15 Kindred\'s Seals. Then your alter egos will follow you into the battlefields!',
        confirm   = 'Hand over 15 Kindred\'s Seals to strengthen your alter ego pact?',
        success   = 'Kindred seals... fancy! Pact strengthened -- take those alter egos into the battlefields, kupopo!',
        lack      = 'Fifteen Kindred\'s Seals, kupo -- the red ones with attitude! Beastmen seals don\'t count here!',
    },
}

local function sayMoogle(player, message)
    player:printToPlayer(message, xi.msg.channel.NS_SAY, 'Cipher Moogle')
end

local function delaySendMenu(player, menu)
    player:timer(50, function(playerArg)
        playerArg:customMenu(menu)
    end)
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

local function nextCapacityQuest(player)
    for _, quest in ipairs(capacityQuests) do
        if quest.isReady(player) then
            if player:getMainLvl() >= quest.minLevel then
                return quest
            end

            -- Next KI exists but level gate failed; do not skip ahead.
            return nil
        end
    end

    return nil
end

local function tryExchangeSeals(player, quest)
    if player:hasKeyItem(quest.keyItem) then
        return
    end

    if player:getItemCount(quest.sealItem) < quest.sealQty then
        sayMoogle(player, quest.lack)
        return
    end

    if not player:delItem(quest.sealItem, quest.sealQty) then
        sayMoogle(player, quest.lack)
        return
    end

    npcUtil.giveKeyItem(player, quest.keyItem)
    sayMoogle(player, quest.success)
end

local function openCapacityConfirm(player, quest)
    delaySendMenu(player, {
        title = quest.menu,
        options =
        {
            {
                'Hand over the seals!',
                function(playerArg)
                    tryExchangeSeals(playerArg, quest)
                end,
            },
            {
                'Maybe later, kupo',
                function(playerArg)
                    sayMoogle(playerArg, 'No rush, kupo! Seals keep. My patience... mostly keeps.')
                end,
            },
        },
    })
end

local function openCipherMenu(player)
    local options = {}

    table.insert(options, {
        'Browse Cipher Catalog',
        function(playerArg)
            local stock = buildCipherStock(playerArg)
            if #stock == 0 then
                sayMoogle(playerArg, 'Kupopo... nothing in the catalog for you yet. Story first, shopping later!')
                return
            end

            sayMoogle(playerArg, 'Browsing time! Alter ego ciphers -- 10,000 gil each, kupo!')
            xi.shop.general(playerArg, stock)
        end,
    })

    local quest = nextCapacityQuest(player)
    if quest then
        table.insert(options, {
            string.format('%s (%d %s)', quest.menu, quest.sealQty, quest.sealName),
            function(playerArg)
                sayMoogle(playerArg, quest.offer)
                sayMoogle(playerArg, quest.confirm)
                openCapacityConfirm(playerArg, quest)
            end,
        })
    elseif
        player:hasKeyItem(xi.ki.RHAPSODY_IN_WHITE) and
        player:hasKeyItem(xi.ki.RHAPSODY_IN_CRIMSON) and
        player:hasKeyItem(xi.ki.RHAPSODY_IN_UMBER)
    then
        table.insert(options, {
            'Training complete',
            function(playerArg)
                sayMoogle(playerArg, 'Your roster\'s as full as my pouch after payday, kupo! White, Crimson, Umber -- every note I know!')
            end,
        })
    end

    player:customMenu({
        title   = 'Cipher Moogle',
        options = options,
        onStart = function(playerArg)
            sayMoogle(playerArg, 'Kupopo! Ciphers for sale, and a little capacity training if you\'re ready to grow that alter ego roster!')
        end,
    })
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
                sayMoogle(player, 'No Trust permit? No training, no ciphers, kupo! Come back when you\'re official!')
                return
            end

            openCipherMenu(player)
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

    -- Limits set by Rhapsody KIs (Cipher Moogle seal training on Live)
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
