-- ---------------------------------------------------------------------------
-- Remove Land King HQ pop items from NQ droplists.
-- HQ is a lottery of timed NQ kings (see custom/lua/land_kings.lua).
-- ---------------------------------------------------------------------------

-- Fafnir (dropid 805): Cup Of Sweet Tea
DELETE FROM `mob_droplist` WHERE dropId = 805 AND itemId = 3340;

-- Adamantoise (dropid 21): Clump Of Red Pondweed
DELETE FROM `mob_droplist` WHERE dropId = 21 AND itemId = 3344;

-- Behemoth (dropid 251): Savory Shank
DELETE FROM `mob_droplist` WHERE dropId = 251 AND itemId = 3342;
