---
name: dbtool
description: Run LandSandBoat database backup, update, and migration via tools/dbtool.py. Use when SQL files changed, the user needs a DB refresh, or character data migrations are mentioned.
---

# dbtool

From `tools/`, Python 3 + `tools/requirements.txt`. Connects using `settings/network.lua`.

```
python dbtool.py              # interactive
python dbtool.py backup
python dbtool.py backup lite
python dbtool.py update       # express + backup + migrations
python dbtool.py update full
python dbtool.py migrate
```

Do not run destructive DB commands unless the user asked. Do not commit `sql/backups/` or local settings.
