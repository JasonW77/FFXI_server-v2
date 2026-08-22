-----------------------------------
-- Non-retail QoL: Orwen the teleport mage in the three nations and Jeuno.
-- Gil-priced Warp / Crag / field Dynamis / Hall of the Gods warps, plus
-- WotG Recalls/Retrace and ToAU Staging Points when those expansions are on.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/teleports')
-----------------------------------
local m = Module:new('teleport_mage')

-- Hume male in dark wizard robes (tweak after in-game check).
local mageLook = '0x01000C0200105820583058405850006000700000'

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

local tryStartTeleport = function(player, teleportPower, teleportDuration, gilCost, needsAllegiance)
    if player:hasStatusEffect(xi.effect.TELEPORT) then
        sayAsOrwen(player, 'Hold still — I\'m already casting!')
        return
    end

    if needsAllegiance and player:getCampaignAllegiance() <= 0 then
        sayAsOrwen(player, 'Retrace needs a campaign allegiance. Come back when you\'ve picked a side.')
        return
    end

    if player:getGil() < gilCost then
        sayAsOrwen(player, string.format('That\'ll be %d gil. I\'m saving for a proper staff, you know.', gilCost))
        return
    end

    if not player:delGil(gilCost) then
        sayAsOrwen(player, string.format('That\'ll be %d gil. I\'m saving for a proper staff, you know.', gilCost))
        return
    end

    sayAsOrwen(player, 'Right then — stand still...')
    player:addStatusEffect(xi.effect.TELEPORT, {
        power    = teleportPower,
        duration = teleportDuration,
        origin   = player,
        icon     = 0,
    })
end

local makeDestOption = function(label, teleportPower, teleportDuration, gilCost, needsAllegiance)
    return {
        string.format('%s (%d)', label, gilCost),
        function(playerArg)
            tryStartTeleport(playerArg, teleportPower, teleportDuration, gilCost, needsAllegiance)
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

local buildBasicOptions = function()
    return {
        makeDestOption('Warp', xi.teleport.id.WARP, duration.warp, cost.basic, false),
        makeDestOption('Holla', xi.teleport.id.HOLLA, duration.crag, cost.basic, false),
        makeDestOption('Dem', xi.teleport.id.DEM, duration.crag, cost.basic, false),
        makeDestOption('Mea', xi.teleport.id.MEA, duration.crag, cost.basic, false),
        makeDestOption('Vahzl', xi.teleport.id.VAHZL, duration.crag, cost.basic, false),
        makeDestOption('Yhoat', xi.teleport.id.YHOAT, duration.crag, cost.basic, false),
        makeDestOption('Altep', xi.teleport.id.ALTEP, duration.crag, cost.basic, false),
        makeBackOption(),
    }
end

local buildWotgOptions = function()
    return {
        makeDestOption('Recall-Jugner', xi.teleport.id.JUGNER, duration.crag, cost.wotg, false),
        makeDestOption('Recall-Pashh', xi.teleport.id.PASHH, duration.crag, cost.wotg, false),
        makeDestOption('Recall-Meriph', xi.teleport.id.MERIPH, duration.crag, cost.wotg, false),
        makeDestOption('Retrace', xi.teleport.id.RETRACE, duration.warp, cost.wotg, true),
        makeBackOption(),
    }
end

local buildDynamisOptions = function()
    return {
        makeDestOption('Xarcabard', customId.DYNAMIS_XARCABARD, duration.custom, cost.dynamis, false),
        makeDestOption('Beaucedine', customId.DYNAMIS_BEAUCEDINE, duration.custom, cost.dynamis, false),
        makeDestOption('Qufim', customId.DYNAMIS_QUFIM, duration.custom, cost.dynamis, false),
        makeDestOption('Valkurm', customId.DYNAMIS_VALKURM, duration.custom, cost.dynamis, false),
        makeDestOption('Buburimu', customId.DYNAMIS_BUBURIMU, duration.custom, cost.dynamis, false),
        makeBackOption(),
    }
end

local buildHighOptions = function()
    local options = {
        makeDestOption('Hall of the Gods', customId.HALL_OF_THE_GODS, duration.custom, cost.high, false),
    }

    if xi.settings.main.ENABLE_TOAU == 1 then
        options[#options + 1] = makeDestOption('Azouph SP', xi.teleport.id.AZOUPH_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Mamool SP', xi.teleport.id.MAMOOL_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Halvung SP', xi.teleport.id.HALVUNG_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Dvucca SP', xi.teleport.id.DVUCCA_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Ilrusi SP', xi.teleport.id.ILRUSI_SP, duration.crag, cost.high, false)
        options[#options + 1] = makeDestOption('Nyzul SP', xi.teleport.id.NYZUL_SP, duration.crag, cost.high, false)
    end

    options[#options + 1] = makeBackOption()
    return options
end

local buildRootOptions = function()
    local options =
    {
        {
            'Basic (1,000 gil)',
            function(playerArg)
                basicMenu.options = buildBasicOptions()
                delaySendMenu(playerArg, basicMenu)
            end,
        },
    }

    if xi.settings.main.ENABLE_WOTG == 1 then
        options[#options + 1] =
        {
            'WotG (2,500 gil)',
            function(playerArg)
                wotgMenu.options = buildWotgOptions()
                delaySendMenu(playerArg, wotgMenu)
            end,
        }
    end

    options[#options + 1] =
    {
        'Dynamis (3,000 gil)',
        function(playerArg)
            dynamisMenu.options = buildDynamisOptions()
            delaySendMenu(playerArg, dynamisMenu)
        end,
    }

    options[#options + 1] =
    {
        'Advanced (5,000 gil)',
        function(playerArg)
            highMenu.options = buildHighOptions()
            delaySendMenu(playerArg, highMenu)
        end,
    }

    return options
end

local openRootMenu = function(player)
    rootMenu.options = buildRootOptions()
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
            sayAsOrwen(player, 'Need a warp? Every gil goes toward HQ elemental staves...')
            openRootMenu(player)
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
    spawnOrwen(zone, 120.000, -0.200, -5.000, 128)
end)

m:addOverride('xi.zones.Bastok_Mines.Zone.onInitialize', function(zone)
    super(zone)
    spawnOrwen(zone, 85.000, 0.000, -60.000, 64)
end)

m:addOverride('xi.zones.Port_Windurst.Zone.onInitialize', function(zone)
    super(zone)
    spawnOrwen(zone, 187.000, -12.000, 214.000, 0)
end)

m:addOverride('xi.zones.RuLude_Gardens.Zone.onInitialize', function(zone)
    super(zone)
    spawnOrwen(zone, -2.000, 9.000, -38.000, 192)
end)

return m
