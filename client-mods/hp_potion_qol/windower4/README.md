# Windower4 overlay deploy

Apply these on `C:\Program Files (x86)\Windower4` (or run `install\apply_client_fix.ps1 -UseXIPivot`).

## 1. XIPivot overlay settings (required)

Copy [`XIPivot-data-settings.xml`](XIPivot-data-settings.xml) to:

`addons\XIPivot\data\settings.xml`

Without this file, XIPivot loads with **empty overlays** and the DAT redirect never happens.

## 2. Autoload order (required)

In root `settings.xml`, `<autoload>` must load XIPivot **before** `plugin_manager`:

```xml
<autoload>
  <addon>XIPivot</addon>
  <addon>plugin_manager</addon>
  ...
</autoload>
```

Remove duplicate `<addon>XIPivot</addon>` lines from `addons\plugin_manager\data\settings.xml` (per-character lists) so XIPivot is not loaded twice.

## 3. Git tracking (Windower4 repo)

Add to `.gitignore` exceptions:

```gitignore
!/addons/XIPivot/data/settings.xml
```

Then `git add -f addons/XIPivot/data/settings.xml`.

## 4. After changes

1. Restart Windower completely.
2. `//pivot s` and `//pivot q ROM/118/107.DAT`
3. Relog if needed.

See [VERIFY.md](../VERIFY.md) for full checklist.
