# HP potion QoL — client mod (XIPivot)

AirSkyBoat server SQL (`modules/custom/sql/hp_potion_qol.sql`) sets **stack size 12** and **party/trust targeting** (`validTargets = 3`) in the database. The FFXI client still reads **stack size** and **valid targets** from item DAT before it shows stack UI or sends use packets. This folder ships an **XIPivot overlay** for Ashita and Windower.

Without this overlay (or an equivalent DAT patch), potions stay single-stack and self-only in the UI even when the server DB is correct.

## Requirements

- Ashita v3/v4 or Windower 4
- [XIPivot](https://github.com/HealsCodes/XIPivot) (Ashita: install from plugin list; Windower: addon from releases)
- Matching server module: `custom/sql/hp_potion_qol.sql` in `modules/init.txt` (already on LIVE)

## Backup

Back up your retail FFXI folder before installing overlays. XIPivot does not modify retail ROM files, but keep a copy of `FINAL FANTASY XI\ROM\` if you build DATs manually.

## Install (players)

### 1. Install XIPivot

- **Ashita**: Plugins → install **XIPivot** → load before login (`/load xipivot` or autoload).
- **Windower**: Copy XIPivot into `addons/XIPivot` from [releases](https://github.com/HealsCodes/XIPivot/releases).

### 2. Copy this mod

Copy the folder `xipivot/DATs/hp_potion_qol` into your XIPivot `DATs` directory:

| Launcher | DATs path |
|----------|-----------|
| Ashita | `Ashita/config/plugins/DATs/` or path shown by `/pivot` in-game |
| Windower | `Windower/addons/XIPivot/data/DATs/` |

Structure:

```text
DATs/hp_potion_qol/
  ROM/
    118/
      107.DAT    ← built overlay (see Build below)
```

If you received a release zip, extract so `hp_potion_qol/ROM/...` sits under `DATs/`.

### 3. Enable overlay

**Ashita** — add `hp_potion_qol` to `config/XIPivot.xml` (see `xipivot/XIPivot.sample.xml`), or use `/pivot` and enable the mod before zoning.

**Windower** — add `hp_potion_qol` to `addons/XIPivot/data/settings.xml` (see `xipivot/settings.sample.xml`):

```xml
<overlays>hp_potion_qol</overlays>
```

Order matters: first listed overlay wins for each file. Place `hp_potion_qol` before conflicting packs if needed.

### 4. Log in

Enable the overlay **before** login or relog after enabling. Existing single potions in inventory stay separate until merged or re-acquired.

## Build overlay (maintainers / local)

The overlay is **not** stored in git (~12 MB full usable-items DAT). Build on a PC with retail FFXI installed:

```powershell
cd client-mods/hp_potion_qol
python build/patch_usable_dat.py
```

Details: [build/BUILD.md](build/BUILD.md).

## Patched items

| ID | Name |
|----|------|
| 4112–4115 | Potion +1/+2/+3 |
| 4116–4119 | Hi-Potion +1/+2/+3 |
| 4120–4123 | X-Potion +1/+2/+3 |
| 4124–4127 | Max-Potion +1/+2/+3 |
| 5254 | Hyper Potion |
| 5716 | Soothing Potion |

Client DAT changes per item:

| Field | Value |
|-------|-------|
| `StackSize` | **12** |
| `ValidTargets` | **3** (Self + party; server `TARGET_SELF \| TARGET_PLAYER_PARTY`) |

Cast/activation times are **not** changed in the DAT (server `item_usable.activation` still applies).

## Verify (Ashita)

```text
/iteminfo 4116
```

Expect **Stack: 12** and valid targets including party (not Self-only).

Windower: use Resource plugin or equivalent item info display.

## In-game test checklist

1. **Stack UI** — Hi-Potion shows stack capacity; up to 12 merge in one slot (re-acquire or manually combine singles).
2. **Party member** — Target ally, use Hi-Potion; cast completes and heals them (not only self).
3. **Party trust** — Use on a non-passive GEO (or other trust); heal applies.
4. **Reject at full HP** — Server still rejects use when target is full (existing Lua).
5. **GM server test** (optional) — `additem` 12× potion stacks in one slot even without client mod; confirms DB is applied.

## Server-side only test

If `additem` stacks 12 potions in one inventory slot but the client shows no stack icon, the gap is **client-only** — install this mod.

After SQL import, restart `xi_map` so the item cache reloads.

## Troubleshooting

| Issue | Check |
|-------|--------|
| No stack icon | XIPivot loaded? Overlay enabled? `/iteminfo 4116` stack still 1? Rebuild overlay for your client version. |
| No party cursor | `valid_targets` still 1 in `/iteminfo` — overlay not active or wrong ROM path. |
| Works on self only | Server `validTargets` in DB; run `hp_potion_qol.sql` and restart map. |
| Wrong ROM path | Run build script on **your** client; FTABLE path varies by patch (e.g. `ROM/118/107.DAT`). |

## Related

- Server SQL: `modules/custom/sql/hp_potion_qol.sql`
- Item manifest: `items.json`
