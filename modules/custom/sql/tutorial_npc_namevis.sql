-- Non-retail QoL: Blue quest-marker icon on nation tutorial NPCs (same as A.M.A.N. Liaison).
-- namevis 1 = VIS_ICON in src/map/entities/baseentity.h

UPDATE npc_list
SET namevis = 1
WHERE npcid IN (
    17719618, -- Alaune (Southern San d'Oria)
    17739939, -- Gulldago (Bastok Markets)
    17764600  -- Selele (Windurst Woods)
);
