-----------------------------------
-- Non-retail QoL: Land Kings + Ground HNMs
--
-- Land Kings: timed NQ, no idle despawn, HQ lottery of NQ kills.
--   25% HQ after each NQ kill, 100% after 4 NQ kills in a row.
--   Pop items and ??? trades are disabled.
--
-- Ground HNMs: tiered respawn windows, ToD persisted across map restart.
--   Tier 1: 1-2h  | Tier 2: 2-4h  | Tier 3: 4-8h  | Tier 4: 8-16h
-- King Vinegarroon weather gating is unchanged.
-- Guivre unclaimed 3-5h despawn is disabled.
-- Vrtra Charm 2hr is disabled (pet summons kept).
-----------------------------------
require('modules/module_utils')
-----------------------------------
local dragonsAeryID     = zones[xi.zone.DRAGONS_AERY]
local valleySorrowsID   = zones[xi.zone.VALLEY_OF_SORROWS]
local behemothDomID     = zones[xi.zone.BEHEMOTHS_DOMINION]
local rolanberryID      = zones[xi.zone.ROLANBERRY_FIELDS]
local sauromugueID      = zones[xi.zone.SAUROMUGUE_CHAMPAIGN]
local westernAltepaID   = zones[xi.zone.WESTERN_ALTEPA_DESERT]
local kuftalID          = zones[xi.zone.KUFTAL_TUNNEL]
local garlaigeID        = zones[xi.zone.GARLAIGE_CITADEL]
local ifritsID          = zones[xi.zone.IFRITS_CAULDRON]
local attohwaID         = zones[xi.zone.ATTOHWA_CHASM]
local uleguerandID      = zones[xi.zone.ULEGUERAND_RANGE]
local ranperreID        = zones[xi.zone.KING_RANPERRES_TOMB]
local zhayolmID         = zones[xi.zone.MOUNT_ZHAYOLM]
local caedarvaID        = zones[xi.zone.CAEDARVA_MIRE]

-- Wajaom Woodlands has no Hydra entry in IDs.lua.
local hydraMobId = 16986355

local m = Module:new('land_kings')

local hqChancePercent = 25
local nqKillsForGuaranteedHq = 4

local tiers =
{
    [1] = { min = 1 * 3600, max = 2 * 3600 },  -- 1-2 hours
    [2] = { min = 2 * 3600, max = 4 * 3600 },  -- 2-4 hours
    [3] = { min = 4 * 3600, max = 8 * 3600 },  -- 4-8 hours
    [4] = { min = 8 * 3600, max = 16 * 3600 }, -- 8-16 hours
}

local function randomTierDelay(tier)
    local window = tiers[tier]
    return math.random(window.min, window.max)
end

-- Spawn points from era_HNM_system (pre-2011 Land King windows).
local dragonSpawnPoints =
{
    { x =  78.000, y =  6.000, z =  39.000 },
    { x =  77.071, y =  6.830, z =  49.523 },
    { x =  76.578, y =  6.838, z =  45.602 },
    { x =  75.966, y =  6.808, z =  49.096 },
    { x =  76.954, y =  6.807, z =  38.122 },
    { x =  80.965, y =  6.868, z =  42.384 },
    { x =  81.468, y =  6.751, z =  50.467 },
    { x =  83.394, y =  6.822, z =  37.243 },
    { x =  70.539, y =  6.788, z =  38.241 },
    { x =  87.661, y =  6.520, z =  34.198 },
    { x =  75.645, y =  6.749, z =  35.790 },
    { x =  72.633, y =  6.541, z =  46.110 },
    { x =  80.314, y =  6.788, z =  43.262 },
    { x =  72.263, y =  6.500, z =  46.213 },
    { x =  86.844, y =  6.658, z =  35.538 },
    { x =  79.370, y =  6.800, z =  34.151 },
    { x =  70.843, y =  6.837, z =  41.976 },
    { x =  89.395, y =  6.805, z =  39.952 },
    { x =  88.030, y =  6.988, z =  39.351 },
    { x =  86.059, y =  6.683, z =  36.147 },
    { x =  68.200, y =  6.471, z =  45.104 },
    { x =  88.831, y =  6.666, z =  35.991 },
    { x =  76.047, y =  6.859, z =  29.836 },
    { x =  75.376, y =  6.757, z =  37.572 },
    { x =  78.282, y =  6.937, z =  31.587 },
    { x =  74.620, y =  6.688, z =  43.669 },
    { x =  71.115, y =  6.874, z =  39.345 },
    { x =  79.657, y =  6.750, z =  35.427 },
    { x =  69.902, y =  6.705, z =  42.077 },
    { x =  83.039, y =  6.842, z =  47.133 },
    { x =  70.701, y =  6.112, z =  48.573 },
    { x =  87.368, y =  6.887, z =  43.054 },
    { x =  87.497, y =  6.950, z =  40.250 },
    { x =  79.854, y =  6.701, z =  29.823 },
    { x =  80.822, y =  6.905, z =  47.002 },
    { x =  89.650, y =  6.770, z =  41.123 },
    { x =  83.556, y =  6.867, z =  31.715 },
    { x =  90.002, y =  6.667, z =  37.252 },
    { x =  81.332, y =  6.908, z =  40.101 },
    { x =  83.983, y =  6.722, z =  38.491 },
    { x =  84.031, y =  6.753, z =  45.983 },
    { x =  81.171, y =  6.908, z =  41.793 },
    { x =  78.138, y =  6.773, z =  34.914 },
    { x =  88.014, y =  6.769, z =  46.911 },
    { x =  81.764, y =  6.908, z =  39.900 },
    { x =  79.750, y =  6.826, z =  46.203 },
    { x =  82.875, y =  6.808, z =  46.375 },
    { x =  86.300, y =  6.752, z =  42.655 },
    { x =  72.623, y =  7.035, z =  31.974 },
    { x =  78.287, y =  6.770, z =  45.003 },
}

local valleySpawnPoints =
{
    { x =   3.000, y = -0.416, z =   8.000 },
    { x = -41.571, y =  0.042, z = -35.142 },
    { x =   5.864, y = -0.190, z = -29.660 },
    { x = -26.068, y = -0.038, z =  23.504 },
    { x =  -9.116, y = -0.071, z = -29.449 },
    { x =  14.996, y =  0.657, z =  31.093 },
    { x = -33.512, y =  0.140, z =  26.365 },
    { x = -47.618, y =  0.018, z = -29.171 },
    { x = -16.484, y =  0.093, z =  23.930 },
    { x =  -2.061, y =  0.385, z =  11.890 },
    { x =  15.896, y =  0.496, z =   6.045 },
    { x =   6.573, y = -0.026, z =   5.809 },
    { x = -21.673, y =  0.786, z = -45.105 },
    { x = -24.746, y =  0.125, z =  10.983 },
    { x =  23.045, y = -0.375, z =  18.410 },
    { x = -12.040, y =  0.327, z =  -5.008 },
    { x =  -1.446, y =  0.543, z =  13.472 },
    { x = -11.380, y =  0.116, z =   8.869 },
    { x =   4.485, y = -0.196, z = -44.631 },
    { x =  17.881, y =  0.752, z =  -2.229 },
    { x =   6.001, y =  0.478, z =  30.221 },
    { x =  -8.214, y =  0.233, z =   6.407 },
    { x = -29.303, y =  0.332, z = -41.083 },
    { x = -14.385, y =  0.048, z = -18.790 },
    { x =  -9.626, y =  0.161, z =  24.267 },
    { x =   1.119, y =  0.687, z =  14.916 },
    { x =  -2.042, y =  0.994, z =  19.894 },
    { x = -22.561, y =  0.208, z = -34.151 },
    { x =  -5.911, y =  0.282, z =   9.178 },
    { x = -21.178, y =  0.580, z =  -5.789 },
    { x =  -8.614, y =  0.119, z = -45.060 },
    { x =  -3.119, y = -0.251, z = -47.303 },
    { x = -15.110, y =  0.707, z =  40.673 },
    { x = -46.076, y =  0.895, z = -19.828 },
    { x =   4.758, y =  0.325, z = -10.139 },
    { x =   5.260, y =  0.292, z =  -8.671 },
    { x =   0.388, y =  0.106, z = -33.867 },
    { x = -28.618, y = -0.011, z = -13.328 },
    { x =  29.220, y =  0.143, z =  17.957 },
    { x = -35.488, y =  0.024, z =  37.351 },
    { x =  26.502, y =  0.375, z =   8.628 },
    { x = -34.571, y =  0.124, z = -30.934 },
    { x = -19.823, y =  0.990, z =  -3.804 },
    { x = -37.850, y =  0.512, z = -13.164 },
    { x =  -2.782, y =  0.333, z =  29.323 },
    { x = -40.693, y =  0.097, z =   8.104 },
    { x =  -8.348, y = -0.023, z =  30.394 },
    { x =   1.502, y =  0.946, z = -21.061 },
    { x = -16.271, y = -0.361, z =  31.262 },
    { x = -24.813, y = -0.148, z = -14.807 },
}

local behemothSpawnPoints =
{
    { x = -277.763, y = -20.309, z =  72.189 },
    { x = -236.097, y = -19.030, z =  20.582 },
    { x = -239.829, y = -19.017, z =  60.325 },
    { x = -245.463, y = -19.864, z =  49.767 },
    { x = -243.601, y = -19.067, z =  18.680 },
    { x = -271.155, y = -19.248, z =  59.935 },
    { x = -268.381, y = -20.327, z =  23.361 },
    { x = -220.682, y = -19.537, z =  29.991 },
    { x = -202.783, y = -19.254, z =  64.501 },
    { x = -268.644, y = -19.752, z =  65.473 },
    { x = -233.803, y = -19.665, z =  29.285 },
    { x = -224.944, y = -19.403, z =  73.941 },
    { x = -205.924, y = -19.107, z =  59.944 },
    { x = -255.954, y = -19.209, z =  39.293 },
    { x = -241.015, y = -19.758, z =  48.865 },
    { x = -275.621, y = -19.982, z =  40.647 },
    { x = -277.167, y = -20.010, z =  76.177 },
    { x = -244.339, y = -19.684, z =  29.301 },
    { x = -247.063, y = -19.931, z =  51.601 },
    { x = -275.421, y = -19.387, z =  65.208 },
    { x = -229.189, y = -20.039, z =  71.014 },
    { x = -238.301, y = -19.638, z =  68.747 },
    { x = -248.994, y = -19.672, z =  26.165 },
    { x = -232.554, y = -19.814, z =  16.558 },
    { x = -209.320, y = -20.016, z =  48.118 },
    { x = -237.104, y = -19.007, z =  60.122 },
    { x = -264.964, y = -19.624, z =  72.804 },
    { x = -238.056, y = -19.742, z =  70.810 },
    { x = -234.731, y = -19.389, z =  26.156 },
    { x = -263.275, y = -19.237, z =  75.329 },
    { x = -249.483, y = -20.000, z =  70.077 },
    { x = -263.325, y = -19.835, z =  61.364 },
    { x = -244.573, y = -19.130, z =  18.021 },
    { x = -242.115, y = -19.360, z =  14.437 },
    { x = -260.186, y = -19.330, z =  10.312 },
    { x = -272.583, y = -19.833, z =  29.200 },
    { x = -203.146, y = -19.669, z =  50.643 },
    { x = -258.461, y = -19.078, z =  36.431 },
    { x = -201.804, y = -19.634, z =  68.656 },
    { x = -207.906, y = -19.889, z =  45.647 },
    { x = -243.488, y = -19.030, z =  20.576 },
    { x = -257.096, y = -19.792, z =  11.574 },
    { x = -245.934, y = -19.260, z =  15.478 },
    { x = -253.225, y = -19.882, z =  52.921 },
    { x = -274.141, y = -19.908, z =  42.265 },
    { x = -214.846, y = -19.320, z =  36.134 },
    { x = -254.938, y = -19.435, z =  34.812 },
    { x = -259.494, y = -20.121, z =  23.333 },
    { x = -257.510, y = -19.278, z =  47.036 },
    { x = -271.910, y = -19.543, z =  63.326 },
}

local function hideQm(npcId)
    local npc = GetNPCByID(npcId)
    if npc then
        npc:setStatus(xi.status.DISAPPEAR)
    end
end

local function wasKilled(optParams)
    return optParams and (optParams.isKiller or optParams.noKiller)
end

-----------------------------------
-- Land Kings (NQ/HQ pairs)
-----------------------------------
local function scheduleSpawn(king, popHq)
    local delay  = randomTierDelay(king.tier)
    local nextId = popHq and king.hqId or king.nqId

    SetServerVariable(king.popTimeVar, GetSystemTime() + delay)
    SetServerVariable(king.hqNextVar, popHq and 1 or 0)

    DisallowRespawn(king.nqId, popHq)
    DisallowRespawn(king.hqId, not popHq)

    xi.mob.updateNMSpawnPoint(nextId, king.spawnPoints)
    GetMobByID(nextId):setRespawnTime(delay)
end

local function restoreOrSpawnKing(king)
    local popTime     = GetServerVariable(king.popTimeVar)
    local currentTime = GetSystemTime()

    if popTime == 0 then
        popTime = currentTime + randomTierDelay(king.tier)
        SetServerVariable(king.popTimeVar, popTime)
        SetServerVariable(king.hqNextVar, 0)
        SetServerVariable(king.countVar, 0)
    end

    local popHq  = GetServerVariable(king.hqNextVar) == 1
    local nextId = popHq and king.hqId or king.nqId

    DisallowRespawn(king.nqId, popHq)
    DisallowRespawn(king.hqId, not popHq)
    xi.mob.updateNMSpawnPoint(nextId, king.spawnPoints)

    if popTime <= currentTime then
        SpawnMob(nextId)
    else
        GetMobByID(nextId):setRespawnTime(popTime - currentTime)
    end

    hideQm(king.qmId)
end

local function onNqKilled(king)
    local killCount = GetServerVariable(king.countVar) + 1
    local popHq     = killCount >= nqKillsForGuaranteedHq or math.random(1, 100) <= hqChancePercent

    SetServerVariable(king.countVar, killCount)
    scheduleSpawn(king, popHq)
end

local function onHqKilled(king)
    SetServerVariable(king.countVar, 0)
    scheduleSpawn(king, false)
end

local function registerKing(king)
    m:addOverride(king.zoneInitPath, function(zone)
        super(zone)
        restoreOrSpawnKing(king)
    end)

    m:addOverride(king.nqInitPath, function(mob)
        super(mob)
        mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 0)
    end)

    m:addOverride(king.hqInitPath, function(mob)
        super(mob)
        mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 0)
    end)

    m:addOverride(king.nqDeathPath, function(mob, player, optParams)
        super(mob, player, optParams)
        if wasKilled(optParams) then
            mob:setLocalVar('[land_kings]killed', 1)
        end
    end)

    m:addOverride(king.hqDeathPath, function(mob, player, optParams)
        super(mob, player, optParams)
        if wasKilled(optParams) then
            mob:setLocalVar('[land_kings]killed', 1)
        end
    end)

    -- Stock despawn re-shows the ??? after FORCE_SPAWN_QM_RESET_TIME. Keep it hidden
    -- and ignore trades so pop items cannot be used.
    m:addOverride(king.qmTradePath, function(player, npc, trade)
    end)

    m:addOverride(king.nqDespawnPath, function(mob)
        super(mob)
        hideQm(king.qmId)
        if mob:getLocalVar('[land_kings]killed') == 1 then
            onNqKilled(king)
        end
    end)

    m:addOverride(king.hqDespawnPath, function(mob)
        super(mob)
        hideQm(king.qmId)
        if mob:getLocalVar('[land_kings]killed') == 1 then
            onHqKilled(king)
        end
    end)
end

-----------------------------------
-- Timed Ground HNMs (single mob)
-----------------------------------
local function restoreOrSpawnTimed(nm)
    local mob = GetMobByID(nm.mobId)
    if not mob then
        return
    end

    local popTime     = GetServerVariable(nm.popTimeVar)
    local currentTime = GetSystemTime()

    if popTime == 0 then
        popTime = currentTime + randomTierDelay(nm.tier)
        SetServerVariable(nm.popTimeVar, popTime)
    end

    xi.mob.updateNMSpawnPoint(mob)

    if popTime <= currentTime then
        if nm.weatherGated then
            -- Ready when weather allows (KV); do not force spawn.
            mob:setRespawnTime(0)
        else
            SpawnMob(nm.mobId)
        end
    else
        mob:setRespawnTime(popTime - currentTime)
    end
end

local function registerTimed(nm)
    m:addOverride(nm.zoneInitPath, function(zone)
        super(zone)
        restoreOrSpawnTimed(nm)
    end)

    m:addOverride(nm.despawnPath, function(mob)
        super(mob)

        local delay = randomTierDelay(nm.tier)
        SetServerVariable(nm.popTimeVar, GetSystemTime() + delay)
        xi.mob.updateNMSpawnPoint(mob)
        mob:setRespawnTime(delay)
    end)

    if nm.initPath then
        m:addOverride(nm.initPath, function(mob)
            super(mob)
            -- Zone restore owns the window; avoid stock long timers on load.
            local popTime = GetServerVariable(nm.popTimeVar)
            if popTime > GetSystemTime() then
                mob:setRespawnTime(popTime - GetSystemTime())
            end
        end)
    end

    if nm.disableUnclaimedDespawn then
        m:addOverride(nm.spawnPath, function(mob)
            super(mob)
            -- Stock sets a 3-5h unclaimed despawn timer; keep Guivre up.
            mob:setLocalVar('despawnTime', GetSystemTime() + (86400 * 365))
        end)

        m:addOverride(nm.roamPath, function(mob)
            -- Stock onMobRoam only despawns when unclaimed; skip that.
        end)
    end

    if nm.removeCharm then
        -- Push Charm 2hr window forward so stock onMobFight never uses ability 710.
        -- Pet summons and draw-in still run via super().
        m:addOverride(nm.fightPath, function(mob, target)
            local twohourTime  = mob:getLocalVar('twohourTime')
            local fifteenBlock = mob:getBattleTime() / 15

            if twohourTime == 0 then
                mob:setLocalVar('twohourTime', math.random(4, 6))
            elseif fifteenBlock > twohourTime then
                mob:setLocalVar('twohourTime', fifteenBlock + math.random(4, 6))
            end

            super(mob, target)
        end)
    end
end

-----------------------------------
-- Land Kings
-- Tier 2: Adamantoise | Tier 3: Fafnir | Tier 4: Behemoth
-----------------------------------
registerKing(
{
    tier         = 3,
    nqId         = dragonsAeryID.mob.FAFNIR,
    hqId         = dragonsAeryID.mob.NIDHOGG,
    qmId         = dragonsAeryID.npc.FAFNIR_QM,
    spawnPoints  = dragonSpawnPoints,
    popTimeVar   = '[HNM]Fafnir',
    countVar     = '[HNM]Fafnir_C',
    hqNextVar    = '[HNM]Fafnir_HQ',
    zoneInitPath = 'xi.zones.Dragons_Aery.Zone.onInitialize',
    nqInitPath   = 'xi.zones.Dragons_Aery.mobs.Fafnir.onMobInitialize',
    hqInitPath   = 'xi.zones.Dragons_Aery.mobs.Nidhogg.onMobInitialize',
    nqDeathPath  = 'xi.zones.Dragons_Aery.mobs.Fafnir.onMobDeath',
    hqDeathPath  = 'xi.zones.Dragons_Aery.mobs.Nidhogg.onMobDeath',
    nqDespawnPath = 'xi.zones.Dragons_Aery.mobs.Fafnir.onMobDespawn',
    hqDespawnPath = 'xi.zones.Dragons_Aery.mobs.Nidhogg.onMobDespawn',
    qmTradePath   = 'xi.zones.Dragons_Aery.npcs.qm0.onTrade',
})

registerKing(
{
    tier         = 2,
    nqId         = valleySorrowsID.mob.ADAMANTOISE,
    hqId         = valleySorrowsID.mob.ASPIDOCHELONE,
    qmId         = valleySorrowsID.npc.ADAMANTOISE_QM,
    spawnPoints  = valleySpawnPoints,
    popTimeVar   = '[HNM]Adamantoise',
    countVar     = '[HNM]Adamantoise_C',
    hqNextVar    = '[HNM]Adamantoise_HQ',
    zoneInitPath = 'xi.zones.Valley_of_Sorrows.Zone.onInitialize',
    nqInitPath   = 'xi.zones.Valley_of_Sorrows.mobs.Adamantoise.onMobInitialize',
    hqInitPath   = 'xi.zones.Valley_of_Sorrows.mobs.Aspidochelone.onMobInitialize',
    nqDeathPath  = 'xi.zones.Valley_of_Sorrows.mobs.Adamantoise.onMobDeath',
    hqDeathPath  = 'xi.zones.Valley_of_Sorrows.mobs.Aspidochelone.onMobDeath',
    nqDespawnPath = 'xi.zones.Valley_of_Sorrows.mobs.Adamantoise.onMobDespawn',
    hqDespawnPath = 'xi.zones.Valley_of_Sorrows.mobs.Aspidochelone.onMobDespawn',
    qmTradePath   = 'xi.zones.Valley_of_Sorrows.npcs.qm0.onTrade',
})

registerKing(
{
    tier         = 4,
    nqId         = behemothDomID.mob.BEHEMOTH,
    hqId         = behemothDomID.mob.KING_BEHEMOTH,
    qmId         = behemothDomID.npc.BEHEMOTH_QM,
    spawnPoints  = behemothSpawnPoints,
    popTimeVar   = '[HNM]Behemoth',
    countVar     = '[HNM]Behemoth_C',
    hqNextVar    = '[HNM]Behemoth_HQ',
    zoneInitPath = 'xi.zones.Behemoths_Dominion.Zone.onInitialize',
    nqInitPath   = 'xi.zones.Behemoths_Dominion.mobs.Behemoth.onMobInitialize',
    hqInitPath   = 'xi.zones.Behemoths_Dominion.mobs.King_Behemoth.onMobInitialize',
    nqDeathPath  = 'xi.zones.Behemoths_Dominion.mobs.Behemoth.onMobDeath',
    hqDeathPath  = 'xi.zones.Behemoths_Dominion.mobs.King_Behemoth.onMobDeath',
    nqDespawnPath = 'xi.zones.Behemoths_Dominion.mobs.Behemoth.onMobDespawn',
    hqDespawnPath = 'xi.zones.Behemoths_Dominion.mobs.King_Behemoth.onMobDespawn',
    qmTradePath   = 'xi.zones.Behemoths_Dominion.npcs.qm2.onTrade',
})

-----------------------------------
-- Tier 1 (1-2h): Simurgh, Roc, KV, Guivre
-----------------------------------
registerTimed(
{
    tier         = 1,
    mobId        = rolanberryID.mob.SIMURGH,
    popTimeVar   = '[HNM]Simurgh',
    zoneInitPath = 'xi.zones.Rolanberry_Fields.Zone.onInitialize',
    despawnPath  = 'xi.zones.Rolanberry_Fields.mobs.Simurgh.onMobDespawn',
    initPath     = 'xi.zones.Rolanberry_Fields.mobs.Simurgh.onMobInitialize',
})

registerTimed(
{
    tier         = 1,
    mobId        = sauromugueID.mob.ROC,
    popTimeVar   = '[HNM]Roc',
    zoneInitPath = 'xi.zones.Sauromugue_Champaign.Zone.onInitialize',
    despawnPath  = 'xi.zones.Sauromugue_Champaign.mobs.Roc.onMobDespawn',
    initPath     = 'xi.zones.Sauromugue_Champaign.mobs.Roc.onMobInitialize',
})

registerTimed(
{
    tier         = 1,
    mobId        = westernAltepaID.mob.KING_VINEGARROON,
    popTimeVar   = '[HNM]KingVinegarroon',
    weatherGated = true,
    zoneInitPath = 'xi.zones.Western_Altepa_Desert.Zone.onInitialize',
    despawnPath  = 'xi.zones.Western_Altepa_Desert.mobs.King_Vinegarroon.onMobDespawn',
    initPath     = 'xi.zones.Western_Altepa_Desert.mobs.King_Vinegarroon.onMobInitialize',
})

registerTimed(
{
    tier                    = 1,
    mobId                   = kuftalID.mob.GUIVRE,
    popTimeVar              = '[HNM]Guivre',
    zoneInitPath            = 'xi.zones.Kuftal_Tunnel.Zone.onInitialize',
    despawnPath             = 'xi.zones.Kuftal_Tunnel.mobs.Guivre.onMobDespawn',
    initPath                = 'xi.zones.Kuftal_Tunnel.mobs.Guivre.onMobInitialize',
    spawnPath               = 'xi.zones.Kuftal_Tunnel.mobs.Guivre.onMobSpawn',
    roamPath                = 'xi.zones.Kuftal_Tunnel.mobs.Guivre.onMobRoam',
    disableUnclaimedDespawn = true,
})

-----------------------------------
-- Tier 2 (2-4h): Serket, Ash Dragon, Hydra
-----------------------------------
registerTimed(
{
    tier         = 2,
    mobId        = garlaigeID.mob.SERKET,
    popTimeVar   = '[HNM]Serket',
    zoneInitPath = 'xi.zones.Garlaige_Citadel.Zone.onInitialize',
    despawnPath  = 'xi.zones.Garlaige_Citadel.mobs.Serket.onMobDespawn',
    initPath     = 'xi.zones.Garlaige_Citadel.mobs.Serket.onMobInitialize',
})

registerTimed(
{
    tier         = 2,
    mobId        = ifritsID.mob.ASH_DRAGON,
    popTimeVar   = '[HNM]AshDragon',
    zoneInitPath = 'xi.zones.Ifrits_Cauldron.Zone.onInitialize',
    despawnPath  = 'xi.zones.Ifrits_Cauldron.mobs.Ash_Dragon.onMobDespawn',
    initPath     = 'xi.zones.Ifrits_Cauldron.mobs.Ash_Dragon.onMobInitialize',
})

registerTimed(
{
    tier         = 2,
    mobId        = hydraMobId,
    popTimeVar   = '[HNM]Hydra',
    zoneInitPath = 'xi.zones.Wajaom_Woodlands.Zone.onInitialize',
    despawnPath  = 'xi.zones.Wajaom_Woodlands.mobs.Hydra.onMobDespawn',
})

-----------------------------------
-- Tier 3 (4-8h): Cerberus, Khimaira
-----------------------------------
registerTimed(
{
    tier         = 3,
    mobId        = zhayolmID.mob.CERBERUS,
    popTimeVar   = '[HNM]Cerberus',
    zoneInitPath = 'xi.zones.Mount_Zhayolm.Zone.onInitialize',
    despawnPath  = 'xi.zones.Mount_Zhayolm.mobs.Cerberus.onMobDespawn',
})

registerTimed(
{
    tier         = 3,
    mobId        = caedarvaID.mob.KHIMAIRA,
    popTimeVar   = '[HNM]Khimaira',
    zoneInitPath = 'xi.zones.Caedarva_Mire.Zone.onInitialize',
    despawnPath  = 'xi.zones.Caedarva_Mire.mobs.Khimaira.onMobDespawn',
    initPath     = 'xi.zones.Caedarva_Mire.mobs.Khimaira.onMobInitialize',
})

-----------------------------------
-- Tier 4 (8-16h): Tiamat, Jormungand, Vrtra
-----------------------------------
registerTimed(
{
    tier         = 4,
    mobId        = attohwaID.mob.TIAMAT,
    popTimeVar   = '[HNM]Tiamat',
    zoneInitPath = 'xi.zones.Attohwa_Chasm.Zone.onInitialize',
    despawnPath  = 'xi.zones.Attohwa_Chasm.mobs.Tiamat.onMobDespawn',
    initPath     = 'xi.zones.Attohwa_Chasm.mobs.Tiamat.onMobInitialize',
})

registerTimed(
{
    tier         = 4,
    mobId        = uleguerandID.mob.JORMUNGAND,
    popTimeVar   = '[HNM]Jormungand',
    zoneInitPath = 'xi.zones.Uleguerand_Range.Zone.onInitialize',
    despawnPath  = 'xi.zones.Uleguerand_Range.mobs.Jormungand.onMobDespawn',
    initPath     = 'xi.zones.Uleguerand_Range.mobs.Jormungand.onMobInitialize',
})

registerTimed(
{
    tier         = 4,
    mobId        = ranperreID.mob.VRTRA,
    popTimeVar   = '[HNM]Vrtra',
    zoneInitPath = 'xi.zones.King_Ranperres_Tomb.Zone.onInitialize',
    despawnPath  = 'xi.zones.King_Ranperres_Tomb.mobs.Vrtra.onMobDespawn',
    initPath     = 'xi.zones.King_Ranperres_Tomb.mobs.Vrtra.onMobInitialize',
    fightPath    = 'xi.zones.King_Ranperres_Tomb.mobs.Vrtra.onMobFight',
    removeCharm  = true,
})

return m
