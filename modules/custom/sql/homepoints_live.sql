-- Non-retail QoL: Restore live-relevant Home Points, Artisan Moogles, and Ephemeral Moogles
-- (crystal storage) hidden by SOA content gating.
-- Live uses ENABLE_SOA=0 + RESTRICT_CONTENT=1; SOA-tagged NPCs never spawn.
-- Adoulin expansion, Leafallia, Ra'Kaznar Home Points, and Mog Garden intentionally remain hidden.

-- Retag live-relevant SOA Home Points (skip placeholder 0,0,0 coords and Adoulin-era zones).
UPDATE npc_list
SET content_tag = NULL
WHERE name LIKE 'HomePoint%'
  AND content_tag = 'SOA'
  AND NOT (pos_x = 0 AND pos_y = 0 AND pos_z = 0)
  AND npcid NOT IN (
    17825908, 17825909, -- Western Adoulin
    17829976, 17829977, -- Eastern Adoulin
    17846860,           -- Ceizak Battlegrounds
    17850980,           -- Foret de Hennetiel
    17855102,           -- Yorcia Weald
    17863495,           -- Morimar Basalt Fields
    17867226,           -- Marjami Ravine
    17871221,           -- Kamihr Drifts
    17908263,           -- Ra'Kaznar Inner Court
    17928259            -- Leafallia
  );

-- Artisan Moogles (Mog Sack; separate from intentionally disabled Mog Satchel).
UPDATE npc_list
SET content_tag = NULL
WHERE npcid IN (
    17719633, -- Southern San d'Oria
    17739947, -- Bastok Markets
    17764601, -- Windurst Woods
    17772833  -- Ru'Lude Gardens
);

-- Ephemeral Moogles (guild crystal storage; May 2016 QoL, not Adoulin story).
UPDATE npc_list
SET content_tag = NULL
WHERE npcid IN (
    17720012, -- Southern San d'Oria (Leather)
    17723848, -- Northern San d'Oria (Wood)
    17723849, -- Northern San d'Oria (Smith)
    17740209, -- Bastok Markets (Gold)
    17736061, -- Bastok Mines (Alchemy)
    17752574, -- Windurst Waters (Cook)
    17764824, -- Windurst Woods (Bone)
    17764825  -- Windurst Woods (Cloth)
);
