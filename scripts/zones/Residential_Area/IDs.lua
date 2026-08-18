-----------------------------------
-- Area: Residential_Area
-- Note: Unused zone. Mog Houses are instanced in the zone they live in.
-----------------------------------
zones = zones or {}

zones[xi.zone.RESIDENTIAL_AREA] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED = 1, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED           = 1, -- Obtained: <item>.
        GIL_OBTAINED            = 1, -- Obtained <number> gil.
        KEYITEM_OBTAINED        = 1, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS     = 7001, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY = 7002, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER            = 7003, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
    },
    mob =
    {
    },
    npc =
    {
    },
}

return zones[xi.zone.RESIDENTIAL_AREA]
