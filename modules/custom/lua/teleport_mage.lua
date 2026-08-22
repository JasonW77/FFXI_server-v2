-----------------------------------
-- Non-retail QoL: Orwen the teleport mage in the three nations and Jeuno.
-- Gil-priced Warp / Crag / field Dynamis / Hall of the Gods warps, plus
-- WotG Recalls/Retrace and ToAU Staging Points when those expansions are on.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/teleports')
-----------------------------------
local m = Module:new('teleport_mage')

-- Hume look + Wizard's AF (BLM artifact) + Dark Staff.
local mageLook = '0x01000C0200104620463046404650446100700000'

local cost =
{
    basic   = 1000,
    wotg    = 2500,
    dynamis = 3000,
    high    = 5000,
}

local duration =
{
    warp   = 3,
    crag   = 4,
    custom = 4,
}

-- Sentinel powers for custom coords (avoid colliding with xi.teleport.id.*).
local customId =
{
    DYNAMIS_XARCABARD  = 9001,
    DYNAMIS_BEAUCEDINE = 9002,
    DYNAMIS_QUFIM      = 9003,
    DYNAMIS_VALKURM    = 9004,
    DYNAMIS_BUBURIMU   = 9005,
    HALL_OF_THE_GODS   = 9006,
}

local customDestinations =
{
    -- Field Dynamis entry NPCs (not cities / Tavnazia).
    [customId.DYNAMIS_XARCABARD ] = {  572.933,  -2.023, -273.348, 179, xi.zone.XARCABARD            },
    [customId.DYNAMIS_BEAUCEDINE] = { -279.424, -40.059, -415.980,  57, xi.zone.BEAUCEDINE_GLACIER   },
    [customId.DYNAMIS_QUFIM     ] = {   14.622, -20.532,  163.894, 170, xi.zone.QUFIM_ISLAND         },
    [customId.DYNAMIS_VALKURM   ] = {  115.965, -10.015,  133.359, 181, xi.zone.VALKURM_DUNES        },
    [customId.DYNAMIS_BUBURIMU  ] = {  164.238,   0.464, -175.149, 215, xi.zone.BUBURIMU_PENINSULA   },
    -- Hall of the Gods zone-in pad.
    [customId.HALL_OF_THE_GODS  ] = {   -0.011,  -1.848, -176.133, 192, xi.zone.HALL_OF_THE_GODS     },
}

-- Forward declarations for paginated menus.
local rootMenu     = { title = 'Orwen\'s Teleports', options = {} }
local basicMenu    = { title = 'Basic (1,000 gil)', options = {} }
local wotgMenu     = { title = 'WotG (2,500 gil)', options = {} }
local dynamisMenu  = { title = 'Dynamis (3,000 gil)', options = {} }
local highMenu     = { title = 'Advanced (5,000 gil)', options = {} }

local delaySendMenu = function(player, menuForPlayer)
    player:timer(50, function(playerArg)
        playerArg:customMenu(menuForPlayer)
    end)
end

local sayAsOrwen = function(player, message)
    player:printToPlayer(message, xi.msg.channel.NS_SAY, 'Orwen')
end

local tryStartTeleport = function(player, npc, teleportPower, teleportDuration, gilCost, needsAllegiance)
    if player:hasStatusEffect(xi.effect.TELEPORT) then
        sayAsOrwen(player, 'Hold still -- I\'m already casting!')
        return
    end

    if needsAllegiance and player:getCampaignAllegiance() <= 0 then
        sayAsOrwen(player, 'Retrace needs a campaign allegiance. Come back when you\'ve picked a side.')
        return
    end

    if player:getGil() < gilCost then
        sayAsOrwen(player, string.format('That\'ll be %d gil. Relic upgrades aren\'t cheap, you know.', gilCost))
        return
    end

    if not player:delGil(gilCost) then
        sayAsOrwen(player, string.format('That\'ll be %d gil. Relic upgrades aren\'t cheap, you know.', gilCost))
        return
    end

    sayAsOrwen(player, 'Right then -- stand still...')
    -- Warp / Warp II VFX (spell anim 261); do not castSpell -- that would Warp home.
    npc:independentAnimation(player, 261, 0)
    player:addStatusEffect(xi.effect.TELEPORT, {
        power    = teleportPower,
        duration = teleportDuration,
        origin   = player,
        icon     = 0,
    })
end

local makeDestOption = function(label, npc, teleportPower, teleportDuration, gilCost, needsAllegiance)
    return {
        string.format('%s (%d)', label, gilCost),
        function(playerArg)
            tryStartTeleport(playerArg, npc, teleportPower, teleportDuration, gilCost, needsAllegiance)
        end,
    }
end

local makeBackOption = function()
    return {
        'Back',
        function(playerArg)
            delaySendMenu(playerArg, rootMenu)
        end,
    }
end

local buildBasicOptions = function(npc)
    return {
        makeDestOption('Warp', npc, xi.teleport.id.WARP, duration.warp, cost.basic, false),
        makeDestOption('Holla', npc, xi.teleport.id.HOLLA, duration.crag, cost.basic, false),
        makeDestOption('Dem', npc, xi.teleport.id.DEM, duration.crag, cost.basic, false),
        makeDestOption('Mea', npc, xi.teleport.id.MEA, duration.crag, cost.basic, false),
        makeDestOption('Vahzl', npc, xi.teleport.id.VAHZL, duration.crag, cost.basic, false),
        makeDestOption('Yhoat', npc, xi.teleport.id.YHOAT, duration.crag, cost.basic, false),
        makeDestOption('Altep', npc, xi.teleport.id.ALTEP, duration.crag, cost.basic, false),
        makeBackOption(),
    }
end

local buildWotgOptions = function(npc)
    return {
        makeDestOption('Recall-Jugner', npc, xi.teleport.id.JUGNER, duration.crag, cost.wotg, false),
        makeDestOption('Recall-Pashh', npc, xi.teleport.id.PASHH, duration.crag, cost.wotg, false),
        makeDestOption('Recall-Meriph', npc, xi.teleport.id.MERIPH, duration.crag, cost.wotg, false),
        makeDestOption('Retrace', npc, xi.teleport.id.RETRACE, duration.warp, cost.wotg, true),
        makeBackOption(),
    }
end

local buildDynamisOptions = function(npc)
    return {
        makeDestOption('Xarcabard', npc, customId.DYNAMIS_XARCABARD, duration.custom, cost.dynamis, false),
        makeDestOption('Beaucedine', npc, customId.DYNAMIS_BEAUCEDINE, duration.custom, cost.dynamis, false),
        makeDestOption('Qufim', npc, customId.DYNAMIS_QUFIM, duration.custom, cost.dynamis, false),
        makeDestOption('Valkurm', npc, customId.DYNAMIS_VALKURM, duration.custom, cost.dynamis, false),
        makeDestOption('Buburimu', npc, customId.DYNAMIS_BUBURIMU, duration.custom, cost.dynamis, false),
        makeBackOption(),
    }
end

local buildHighOptions = function(npc)
    local options = {
        makeDestOption('Hall of the Gods', npc, customId.HALL_OF_THE_GODS, duration.custom, cost.high, false),
    }

    if xi.settings.main.ENABLE_TOAU == 1 then
        options[#options + 1] = makeDestOption('Azouph SP', npc, xi.teleport.id.AZOUPH_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Mamool SP', npc, xi.teleport.id.MAMOOL_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Halvung SP', npc, xi.teleport.id.HALVUNG_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Dvucca SP', npc, xi.teleport.id.DVUCCA_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Ilrusi SP', npc, xi.teleport.id.ILRUSI_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Nyzul SP', npc, xi.teleport.id.NYZUL_SP, duration.crag, cost.high, false)
    end

    options[#options + 1] = makeBackOption()
    return options
end

local buildRootOptions = function(npc)
    local options =
    {
        {
            'Basic (1,000 gil)',
            function(playerArg)
                basicMenu.options = buildBasicOptions(npc)
                delaySendMenu(playerArg, basicMenu)
            end,
        },
    }

    if xi.settings.main.ENABLE_WOTG == 1 then
        options[#options + 1] =
        {
            'WotG (2,500 gil)',
            function(playerArg)
                wotgMenu.options = buildWotgOptions(npc)
                delaySendMenu(playerArg, wotgMenu)
            end,
        }
    end

    options[#options + 1] =
    {
        'Dynamis (3,000 gil)',
        function(playerArg)
            dynamisMenu.options = buildDynamisOptions(npc)
            delaySendMenu(playerArg, dynamisMenu)
        end,
    }

    options[#options + 1] =
    {
        'Advanced (5,000 gil)',
        function(playerArg)
            highMenu.options = buildHighOptions(npc)
            delaySendMenu(playerArg, highMenu)
        end,
    }

    return options
end

local openRootMenu = function(player, npc)
    rootMenu.options = buildRootOptions(npc)
    delaySendMenu(player, rootMenu)
end

local spawnOrwen = function(zone, x, y, z, rotation)
    zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = 'Orwen',
        look     = mageLook,
        x        = x,
        y        = y,
        z        = z,
        rotation = rotation,
        widescan = 1,
        onTrigger = function(player, npc)
            npc:sendEmote(player, xi.emote.BOW, xi.emoteMode.MOTION, false)
            sayAsOrwen(player, 'Need a warp? I\'m working on my relic weapon upgrades -- only 9,756 more Jadeshells to go!')
            openRootMenu(player, npc)
        end,
    })
end

-- Custom destinations: handle sentinel powers, otherwise fall through to retail TELEPORT logic.
m:addOverride('xi.effects.teleport.onEffectLose', function(target, effect)
    local destination = effect:getPower()
    local dest        = customDestinations[destination]

    if dest then
        if target:isInEvent() and effect:getOriginID() ~= target:getID() then
            return
        end

        if target:isMob() then
            DespawnMob(target:getID())
            return
        end

        target:setPos(dest[1], dest[2], dest[3], dest[4], dest[5])
        return
    end

    super(target, effect)
end)

-- Near Explorer Moogle hubs (nudge after client check).
m:addOverride('xi.zones.Northern_San_dOria.Zone.onInitialize', function(zone)
    super(zone)
    spawnOrwen(zone, 125.8195, -0.1990, 3.2586, 63)
end)

m:addOverride('xi.zones.Bastok_Mines.Zone.onInitialize', function(zone)
    super(zone)
    spawnOrwen(zone, 77.8869, 0.0000, -64.0217, 42)
end)

m:addOverride('xi.zones.Port_Windurst.Zone.onInitialize', function(zone)
    super(zone)
    spawnOrwen(zone, 179.9023, -12.0000, 220.1712, 237)
end)

m:addOverride('xi.zones.RuLude_Gardens.Zone.onInitialize', function(zone)
    super(zone)
    spawnOrwen(zone, -2.000, 9.000, -38.000, 192)
end)

return m
