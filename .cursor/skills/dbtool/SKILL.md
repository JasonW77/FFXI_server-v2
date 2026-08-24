---
name: dbtool
description: Run LandSandBoat database backup, update, and migration via tools/dbtool.py. Use when SQL files changed, the user needs a DB refresh, or character data migrations are mentioned.
---

# dbtool

From `tools/`, Python 3 + `tools/requirements.txt`. Connects using `settings/network.lua`. See `tools/README.md`.

```
python dbtool.py update       # express + backup + migrations (preferred CLI)
python dbtool.py update full  # re-import all sql/
python dbtool.py backup
python dbtool.py backup lite
python dbtool.py migrate
```

`python dbtool.py` with no subcommand opens an interactive menu — unusable in agent shells. Always pass a subcommand.

After SQL edits, tell the user the DB must be updated. Do not run `update`, restore, or other destructive commands unless they asked.

Express `update` diffs since `db_ver` and **skips unchanged SQL files**. It can report “up to date” while static tables (e.g. fishing) are stale. After item edits, verify with `SELECT` on the target DB. If rows are still stale, use a targeted import of the specific `sql/*.sql` files or `update full`.

After `item_equipment` / `item_mods` / `item_usable` changes, restart the map on **the same host as that DB** (`xi_map` / `ssh-live`) before client checks — a running map keeps the old item cache.

After `scripts/enum/item.lua` (or other `scripts/enum/*`) edits: **map restart required**. Enum Lua is not SQL and FileWatcher does not hot-reload enums safely (skipped / unsafe); a running map keeps the old `xi.item` table until restart.

After `mob_groups` / `mob_spawn_points` (and similar static mob SQL), update the DB **and** restart the map on that host. Spawn level and group HP are loaded at map/zone bring-up.

Optional verify for an NM (replace IDs):

```sql
SELECT mobid, minLevel, maxLevel FROM mob_spawn_points WHERE mobid IN (...);
SELECT groupid, zoneid, name, HP, MP FROM mob_groups WHERE name = '...';
```

Do not commit `sql/backups/` or `tools/config.yaml`. Character-data migrations live in `tools/migrations/` and are applied by dbtool.

## Agent shell gotchas

- **PowerShell:** chain commands with `;`, not `&&`.
- **Windows:** `mysql` may not be in PATH — use `python dbtool.py` from `tools/` (with deps from `requirements.txt`), not raw `mysql`.

## Fishing static SQL

Fishing has **no** `tools/migrations/` scripts; schema and data live in `sql/fishing_*.sql`. Runtime logic is C++ (`src/map/utils/fishingutils.cpp`), not Lua.

**Static (safe to re-import):** `fishing_area`, `fishing_zone`, `fishing_fish`, `fishing_mob`, `fishing_rod`, `fishing_bait`, `fishing_bait_affinity`, `fishing_group`, `fishing_catch`.

**Protected (dbtool skips if table exists):** `fishing_contest`, `fishing_contest_entries`, `char_fishing_contest_history`.

To sync fishing after enable or repo pull: import all 9 static files (or `update full`). Map loads fishing pools at startup — restart `xi_map` on the DB host after import or `FISHING_ENABLE` change.

### Verify after import

```sql
SELECT COUNT(*) FROM fishing_area;
SELECT COUNT(*) FROM fishing_fish;
SELECT COUNT(*) FROM fishing_group;
SELECT COUNT(*) FROM fishing_catch;
-- hook-check crash risk if nonzero:
SELECT COUNT(*) FROM fishing_group fg
  LEFT JOIN fishing_fish ff ON ff.fishid = fg.fishid
    AND ff.disabled = 0 AND ff.ranking < 99
  WHERE ff.fishid IS NULL;
```

Counts should be non-zero on core tables; integrity query should return **0**.
