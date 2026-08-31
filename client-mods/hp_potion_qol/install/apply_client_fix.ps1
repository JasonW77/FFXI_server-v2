# Apply hp_potion_qol client fix on Windows.
#
# Mode A (default): patch retail FFXI ROM — works with Windower without XIPivot.
# Mode B: install XIPivot + overlay mod (non-destructive; pass -UseXIPivot).

param(
    [string]$FfxiRoot = "${env:ProgramFiles(x86)}\PlayOnline\SquareEnix\FINAL FANTASY XI",
    [string]$WindowerRoot = "${env:ProgramFiles(x86)}\Windower4",
    [switch]$UseXIPivot,
    [switch]$RestoreRetail
)

$ErrorActionPreference = "Stop"
$ModRoot = Split-Path $PSScriptRoot -Parent
$PatchScript = Join-Path $ModRoot "build\patch_usable_dat.py"
$OverlayMod = Join-Path $ModRoot "xipivot\DATs\hp_potion_qol"
$BackupDir = Join-Path $ModRoot "backup"

function Get-UsableDatPath([string]$Root) {
    $py = @"
import struct
from pathlib import Path
ffxi = Path(r'$Root')
for rom_index in range(1, 20):
    suffix = '' if rom_index == 1 else str(rom_index)
    vtable = ffxi / f'VTABLE{suffix}.DAT'
    ftable = ffxi / f'FTABLE{suffix}.DAT'
    if not vtable.is_file() or not ftable.is_file():
        continue
    vdata = vtable.read_bytes()
    fn = 0x004A
    if fn >= len(vdata) or vdata[fn] != rom_index:
        continue
    off = fn * 2
    fdata = ftable.read_bytes()
    file_dir = struct.unpack_from('<H', fdata, off)[0]
    folder = file_dir // 0x80
    file_id = file_dir % 0x80
    rom_dir = ffxi / ('ROM' + suffix if rom_index > 1 else 'ROM')
    print(str(rom_dir / str(folder) / f'{file_id}.DAT'))
    raise SystemExit(0)
raise SystemExit('FTABLE resolve failed')
"@
    $resolved = python -c $py
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve usable-items DAT under $Root" }
    return $resolved.Trim()
}

function Ensure-OverlayBuilt() {
    $report = Join-Path $ModRoot "build\build_report.json"
    if (-not (Test-Path $report)) {
        Write-Host "Building overlay from retail DAT..."
        python $PatchScript --ffxi-root $FfxiRoot
    }
    $romRel = (Get-Content $report | ConvertFrom-Json).rom_relative_path
    $dat = Join-Path $OverlayMod ($romRel -replace '/', '\')
    if (-not (Test-Path $dat)) {
        python $PatchScript --ffxi-root $FfxiRoot
    }
    return $dat
}

function Merge-OverlaySetting([string]$SettingsPath) {
    $sample = Join-Path $ModRoot "xipivot\settings.sample.xml"
    if (-not (Test-Path $SettingsPath)) {
        Copy-Item -LiteralPath $sample -Destination $SettingsPath -Force
        return
    }
    $xml = Get-Content -LiteralPath $SettingsPath -Raw
    if ($xml -match '<overlays>([^<]*)</overlays>') {
        $cur = $Matches[1].Trim()
        if ($cur -notmatch 'hp_potion_qol') {
            $new = if ($cur) { "hp_potion_qol,$cur" } else { 'hp_potion_qol' }
            $xml = $xml -replace '<overlays>[^<]*</overlays>', "<overlays>$new</overlays>"
            Set-Content -LiteralPath $SettingsPath -Value $xml -Encoding UTF8
        }
    } else {
        Copy-Item -LiteralPath $sample -Destination $SettingsPath -Force
    }
}

function Backup-RetailDat([string]$RetailDat) {
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    $bak = Join-Path $BackupDir "$(Split-Path $RetailDat -Leaf).retail.bak"
    if (-not (Test-Path $bak)) {
        Copy-Item -LiteralPath $RetailDat -Destination $bak -Force
        Write-Host "Backup: $bak"
    }
    return $bak
}

function Apply-RetailPatch() {
    if (-not (Test-Path $FfxiRoot)) {
        throw "FFXI root not found: $FfxiRoot"
    }
    $retailDat = Get-UsableDatPath $FfxiRoot
    if (-not (Test-Path $retailDat)) {
        throw "Retail DAT missing: $retailDat"
    }
    $overlayDat = Ensure-OverlayBuilt
    Backup-RetailDat $retailDat | Out-Null
    Copy-Item -LiteralPath $overlayDat -Destination $retailDat -Force
    Write-Host "Patched retail DAT: $retailDat"
    Write-Host "Restore: .\apply_client_fix.ps1 -RestoreRetail"
}

function Restore-RetailDat() {
    $retailDat = Get-UsableDatPath $FfxiRoot
    $bak = Join-Path $BackupDir "$(Split-Path $RetailDat -Leaf).retail.bak"
    if (-not (Test-Path $bak)) {
        throw "No backup at $bak"
    }
    Copy-Item -LiteralPath $bak -Destination $retailDat -Force
    Write-Host "Restored retail DAT from backup."
}

function Install-XIPivotOverlay() {
    if (-not (Test-Path (Join-Path $WindowerRoot "Windower.exe"))) {
        throw "Windower.exe not found under $WindowerRoot"
    }
    $xiPivotDir = Join-Path $WindowerRoot "addons\XIPivot"
    $xiPivotDll = Join-Path $xiPivotDir "libs\_XIPivot.dll"
    if (-not (Test-Path $xiPivotDll)) {
        Write-Host "XIPivot not found. Install from https://github.com/HealsCodes/XIPivot/releases (Windower zip)"
        Write-Host "Expected: addons\XIPivot\libs\_XIPivot.dll"
        throw "Install XIPivot addon first"
    }

    $overlayDat = Ensure-OverlayBuilt
    $dest = Join-Path $xiPivotDir "data\DATs\hp_potion_qol"
    New-Item -ItemType Directory -Force -Path (Join-Path $xiPivotDir "data\DATs") | Out-Null
    if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
    Copy-Item -LiteralPath $OverlayMod -Destination $dest -Recurse -Force

    $settings = Join-Path $xiPivotDir "data\settings.xml"
    Merge-OverlaySetting $settings

    $windowerSettings = Join-Path $WindowerRoot "settings.xml"
    if (Test-Path $windowerSettings) {
        $ws = Get-Content -LiteralPath $windowerSettings -Raw
        if ($ws -notmatch '<addon>XIPivot</addon>') {
            $ws = $ws -replace '(<autoload>\s*)', "`$1<addon>XIPivot</addon>`n    "
            Set-Content -LiteralPath $windowerSettings -Value $ws -Encoding UTF8
        }
    }

    Write-Host "XIPivot overlay installed: $dest"
    Write-Host "Overlay DAT synced from: $overlayDat"
    Write-Host ""
    Write-Host "Post-install (required):"
    Write-Host "  1. Restart Windower completely (not //lua reload)"
    Write-Host "  2. In-game: //pivot s  (enabled + hp_potion_qol in overlays)"
    Write-Host "  3. In-game: //pivot q ROM/118/107.DAT  (should show hp_potion_qol)"
    Write-Host "  4. Relog if item table was loaded before XIPivot hooked"
}

if ($RestoreRetail) {
    Restore-RetailDat
    exit 0
}

if ($UseXIPivot) {
    Install-XIPivotOverlay
} else {
    Apply-RetailPatch
}
