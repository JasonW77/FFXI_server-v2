# Apply hp_potion_qol client fix on Windows.
#
# Mode A (default): patch retail FFXI ROM — works with Windower without XIPivot.
# Mode B: install XIPivot + overlay mod (non-destructive; pass -UseXIPivot -WindowerRoot <path>).

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
    $bak = Backup-RetailDat $retailDat
    Copy-Item -LiteralPath $overlayDat -Destination $retailDat -Force
    Write-Host "Patched retail DAT: $retailDat"
    Write-Host "Restore: .\apply_client_fix.ps1 -RestoreRetail"
}

function Restore-RetailDat() {
    $retailDat = Get-UsableDatPath $FfxiRoot
    $bak = Join-Path $BackupDir (Split-Path $retailDat -Leaf) + ".retail.bak"
    if (-not (Test-Path $bak)) {
        throw "No backup at $bak"
    }
    Copy-Item -LiteralPath $bak -Destination $retailDat -Force
    Write-Host "Restored retail DAT from backup."
}

function Install-XIPivotOverlay() {
    if (-not $WindowerRoot) {
        throw "Pass -WindowerRoot 'C:\path\to\Windower' with -UseXIPivot"
    }
    $xiPivotDir = Join-Path $WindowerRoot "addons\XIPivot"
    if (-not (Test-Path (Join-Path $WindowerRoot "Windower.exe"))) {
        throw "Windower.exe not found under $WindowerRoot"
    }
    if (-not (Test-Path (Join-Path $xiPivotDir "XIPivot.dll"))) {
        Write-Host "XIPivot not found. Download from https://github.com/HealsCodes/XIPivot/releases"
        Write-Host "Extract so addons\XIPivot\XIPivot.dll exists, then re-run."
        throw "Install XIPivot addon first"
    }
    $dest = Join-Path $xiPivotDir "data\DATs\hp_potion_qol"
    Ensure-OverlayBuilt | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $xiPivotDir "data\DATs") | Out-Null
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse -Force $OverlayMod $dest
    $settings = Join-Path $xiPivotDir "data\settings.xml"
    $sample = Join-Path $ModRoot "xipivot\settings.sample.xml"
    if (-not (Test-Path $settings)) {
        Copy-Item $sample $settings
    } else {
        $xml = Get-Content $settings -Raw
        if ($xml -notmatch 'hp_potion_qol') {
            $xml = $xml -replace '(<overlays>)([^<]*)(</overlays>)', '$1hp_potion_qol,$2$3'
            Set-Content -Path $settings -Value $xml -Encoding UTF8
        }
    }
    Write-Host "XIPivot overlay installed to $dest"
    Write-Host "Enable in settings.xml overlays list; /load xipivot in Windower."
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
