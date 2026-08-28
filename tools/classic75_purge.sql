-- Classic 75 go-live purge
-- KEEP: character 'Awesome' and its account only.
-- Run ONLY after a full backup (tools/dbtool.py backup).
-- Stop login/world/map and ffxiahbot before executing.

-- Verify target before deleting anything:
-- SELECT c.charid, c.charname, c.gmlevel, c.accid, a.login
-- FROM chars c JOIN accounts a ON a.id = c.accid
-- WHERE c.charname = 'Awesome';

SET @keep_charid = (SELECT charid FROM chars WHERE charname = 'Awesome' LIMIT 1);
SET @keep_accid  = (SELECT accid  FROM chars WHERE charid = @keep_charid LIMIT 1);

-- Abort if Awesome is missing (charid will be NULL).
SELECT IF(@keep_charid IS NULL, 'ERROR: character Awesome not found', CONCAT('Keeping charid=', @keep_charid, ' accid=', @keep_accid)) AS purge_status;

-- Characters (char_delete trigger cascades most char_* rows)
DELETE FROM char_flags WHERE charid != @keep_charid;
DELETE FROM chars WHERE charid != @keep_charid;

-- Orphan accounts
DELETE FROM accounts_sessions WHERE accid != @keep_accid;
DELETE FROM accounts_parties WHERE accid != @keep_accid;
DELETE FROM accounts WHERE id != @keep_accid;

-- Auction house reset
TRUNCATE TABLE auction_house;
TRUNCATE TABLE auction_house_items;
TRUNCATE TABLE ahbot_unlocked_items;

-- Audit tables
TRUNCATE TABLE audit_trade;
TRUNCATE TABLE audit_vendor;
TRUNCATE TABLE audit_bazaar;
TRUNCATE TABLE audit_dbox;

-- GM level cap baseline (adjust levels/inventory in-game after login)
UPDATE char_jobs SET genkai = 75 WHERE charid = @keep_charid;
