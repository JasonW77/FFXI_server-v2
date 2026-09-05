-----------------------------------
-- Non-retail QoL: SkyShop consumable/quest-item vendor in Hall of the Gods.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('hog_shop_npc')

-- Look string byte map (20 bytes, big-endian uint16 slots):
--   0100       model prefix (PC) — do not change
--   07         race  — Mithra (xi.race.MITHRA = 7)
--   02         anim  — body animation set
--   ????       head  — face + hair model
--   ????       body  — chest armor model
--   ????       hands — gloves model
--   ????       legs  — leg armor model
--   ????       feet  — foot armor model
--   ????       main  — main-hand weapon (0000 = unarmed)
--   ????       sub   — sub/ranged slot (0000 = empty)
--
-- TODO: Race byte (Mithra = 07). See scripts/enum/race.lua.
-- TODO: Anim set byte (02) — body type / animation variant.
-- TODO: Head  — face/hair model ID (hex pair after 01000702).
-- TODO: Body  — chest armor model ID.
-- TODO: Hands — gloves model ID.
-- TODO: Legs  — leg armor model ID.
-- TODO: Feet  — foot armor model ID.
-- TODO: Main  — main-hand weapon model ID (0000 = unarmed).
-- TODO: Sub   — sub/ranged slot model ID (0000 = empty).
-- local shopNpcLook = '0x01000702141019200C3002400250006000700000'
local shopNpcLook = '0x01000B077D106620083066400850006000700000'

local stock =
{
    { xi.item.PINCH_OF_PRISM_POWDER, 700 },   -- TODO: price
    { xi.item.POT_OF_SILENT_OIL,     700 },   -- TODO: price
    { xi.item.SHIHEI,                131 },   -- TODO: price — Utsusemi tool (Amalasanda ref.)
    { xi.item.SHINOBI_TABI,          131 },   -- TODO: price — Hojo tool (Amalasanda ref.)
    { xi.item.SANJAKU_TENUGUI,       131 },   -- TODO: price — Monomi tool
    { xi.item.CURTANA,             50000 },  -- TODO: price
    { xi.item.CHUNK_OF_DIORITE,    10000 },  -- TODO: price
    { xi.item.MIDRASS_HELM_P1,   100000 },  -- TODO: price
    { xi.item.CRAFTMASTERS_RING, 100000 },  -- TODO: price
    { xi.item.CRAFTKEEPERS_RING, 100000 },  -- TODO: price
    { xi.item.ARTIFICERS_RING,   100000 },  -- TODO: price
}

local spawnSkyShop = function(zone)
    zone:insertDynamicEntity({
        objtype    = xi.objType.NPC,
        name       = 'SkyShop',
        packetName = 'SkyShop',
        look       = shopNpcLook,
        x          = 3.4619,
        y          = -12.3000,
        z          = 42.5857,
        rotation   = 85,
        widescan   = 1,
        onTrigger  = function(player, npc)
            xi.shop.general(player, stock)
        end,
    })
end

m:addOverride('xi.zones.Hall_of_the_Gods.Zone.onInitialize', function(zone)
    super(zone)
    spawnSkyShop(zone)
end)

return m
