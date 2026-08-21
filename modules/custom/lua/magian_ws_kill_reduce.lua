-----------------------------------
-- Non-retail QoL: Magian WS killing-blow trials need 1/4 the kills.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/magian_data')
-----------------------------------
local m = Module:new('magian_ws_kill_reduce')

m:addOverride('xi.server.onServerStart', function()
    super()

    for _, trial in pairs(xi.magian.trials) do
        if
            trial.defeatMob and
            trial.useWeaponskill and
            trial.numRequired
        then
            trial.numRequired = math.floor(trial.numRequired / 4)
        end
    end
end)

return m
