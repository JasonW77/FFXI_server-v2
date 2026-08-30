------------------------------------
-- Non-retail QoL: HP potions — party/trust targeting and larger stacks.
-- Requires custom/sql/hp_potion_qol.sql in modules/init.txt.
-- Requires matching client DAT overlay — see client-mods/hp_potion_qol/README.md.
------------------------------------

-- TARGET_SELF (1) + TARGET_PLAYER_PARTY (2) = 3
UPDATE item_usable SET validTargets = 3
WHERE name IN (
    'potion',
    'potion_+1',
    'potion_+2',
    'potion_+3',
    'hi-potion',
    'hi-potion_+1',
    'hi-potion_+2',
    'hi-potion_+3',
    'x-potion',
    'x-potion_+1',
    'x-potion_+2',
    'x-potion_+3',
    'max-potion',
    'max-potion_+1',
    'max-potion_+2',
    'max-potion_+3',
    'hyper_potion',
    'soothing_potion'
);

UPDATE item_basic SET stackSize = 12
WHERE name IN (
    'potion',
    'potion_+1',
    'potion_+2',
    'potion_+3',
    'hi-potion',
    'hi-potion_+1',
    'hi-potion_+2',
    'hi-potion_+3',
    'x-potion',
    'x-potion_+1',
    'x-potion_+2',
    'x-potion_+3',
    'max-potion',
    'max-potion_+1',
    'max-potion_+2',
    'max-potion_+3',
    'hyper_potion',
    'soothing_potion'
);

-- Cast time unchanged (activation already 1s on most rows; X/Max tiers keep their retail values).
