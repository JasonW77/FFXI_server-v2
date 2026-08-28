-- One-time: reset players stuck on legacy TutorialProgress charvar after tutorial migration.
-- Do NOT enable in init.txt; run manually on live DB once after deploying Tutorial_Quest.lua.
-- Safe to re-run (sets non-zero legacy var to 0, then removes zero entries).

UPDATE char_vars SET value = '0' WHERE varname = 'TutorialProgress' AND value != '0';
DELETE FROM char_vars WHERE varname = 'TutorialProgress';
