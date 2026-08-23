---
name: dbtool
description: Run LandSandBoat database backup, update, and migration via tools/dbtool.py. Use when SQL files changed, the user needs a DB refresh, or character data migrations are mentioned.
---

# dbtool

From `tools/`, Python 3 + `tools/requirements.txt`. Connects using `settings/network.lua`. See `tools/README.md`.

```
python dbtool.py              # interactive
python dbtool.py backup
python dbtool.py backup lite
python dbtool.py update       # express + backup + migrations
python dbtool.py update full
python dbtool.py migrate
```

After SQL edits, tell the user the DB must be updated. Do not run `update`, restore, or other destructive commands unless they asked.

After `item_equipment` / `item_mods` / `item_usable` imports, a running map still serves the old item cache — restart `xi_map` (or ask via `ssh-live`) before client verification.

Do not commit `sql/backups/` or `tools/config.yaml`. Character-data migrations live in `tools/migrations/` and are applied by dbtool.
