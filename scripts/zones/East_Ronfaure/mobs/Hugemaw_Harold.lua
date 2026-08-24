-----------------------------------
-- Area: East Ronfaure
--   NM: Hugemaw Harold
-- Unity Concord Wanted I (RoE 817)
--
-- Notes:
--   UNM version of Bigmouth Billy.
--   BG-Wiki: resistant outside TP moves; extremely weak during TP moves.
--   Weak to Wind / Light. Exact DT values TODO until verified vs retail.
-----------------------------------
---@type TMobEntity
local entity = {}

-- TODO: verify resist / vulnerability magnitudes vs retail captures
local RESIST_DT = -7500 -- 75% damage taken reduction while not using a TP move
local VULN_DT   = 0     -- full damage during TP move (stub; may need positive vuln)

local function setDamageTaken(mob, value)
    mob:setMod(xi.mod.UDMGPHYS, value)
    mob:setMod(xi.mod.UDMGRANGE, value)
    mob:setMod(xi.mod.UDMGMAGIC, value)
    mob:setMod(xi.mod.UDMGBREATH, value)
end

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 180)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
end

entity.onMobSpawn = function(mob)
    -- TODO: verify Wind / Light weakness amounts
    mob:setMod(xi.mod.WIND_SDT, 12500)
    mob:setMod(xi.mod.LIGHT_SDT, 12500)

    setDamageTaken(mob, RESIST_DT)

    mob:addListener('WEAPONSKILL_STATE_ENTER', 'HAROLD_TP_VULN', function(mobArg, skillId)
        setDamageTaken(mobArg, VULN_DT)
    end)

    mob:addListener('WEAPONSKILL_STATE_EXIT', 'HAROLD_TP_RESIST', function(mobArg, skillId, wasExecuted)
        setDamageTaken(mobArg, RESIST_DT)
    end)
end

entity.onMobDespawn = function(mob)
    mob:removeListener('HAROLD_TP_VULN')
    mob:removeListener('HAROLD_TP_RESIST')
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
