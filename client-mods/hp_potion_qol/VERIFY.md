# HP potion QoL — verification checklist

Run after overlay install and live `xi_map` rebuild.

## Client (Windower4) — before login

1. Restart Windower completely (close launcher + game).
2. Confirm `settings.xml` autoload includes `XIPivot` before `plugin_manager`.
3. Confirm `addons/XIPivot/data/settings.xml` contains `hp_potion_qol` in `<overlays>`.

## In-game — XIPivot

```text
//pivot s
//pivot q ROM/118/107.DAT
```

| Command | Pass |
|---------|------|
| `//pivot s` | `enabled: true`, overlays list includes `hp_potion_qol` |
| `//pivot q ROM/118/107.DAT` | `ROM/118/107.DAT: hp_potion_qol` (not “no redirect”) |

If overlays are empty, re-run:

```powershell
cd e:\AirSkyBoat\AirSkyBoat\client-mods\hp_potion_qol\install
.\apply_client_fix.ps1 -UseXIPivot
```

Then restart Windower and **relog**.

## In-game — potion behavior

| Test | Pass |
|------|------|
| Hi-Potion stack UI | Shows stack capacity; merges to 12 |
| Party member `<t>` | Use completes; heals ally |
| Own trust `<t>` (non-passive GEO) | Use completes; heals trust |
| Full HP target | Server rejects use (existing Lua) |

Re-acquire or manually merge old single-slot potions after overlay is active.

## Server (live box)

Trust targeting requires **rebuilt** `xi_map` (commit `8a14d18c63` or later on LIVE):

```bash
cd /home/jason/server/build
cmake --build . --target xi_map -j"$(nproc)"
sudo systemctl restart xi_map.service
```

DB `hp_potion_qol.sql` is already applied. SQL alone does not fix client stack UI or party cursor.

## On-disk sanity (optional, PowerShell)

Overlay DAT should show hi-potion stack=12, valid_targets=3; retail ROM should still be stack=1, valid_targets=1 until overlay redirects.
