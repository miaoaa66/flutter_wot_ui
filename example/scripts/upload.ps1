<#
.SYNOPSIS
  Upload APK to multiple Android stores (pgyer + huawei/xiaomi/oppo/vivo/tencent/honor).

.DESCRIPTION
  Auto-finds the latest release APK under build/app/outputs/flutter-apk/,
  then invokes apkgo v3.x with apkgo.yaml config.

  apkgo path resolution (first match wins):
    1. -ApkgoPath CLI argument
    2. .apkgo.path file in example/ dir (one line = full exe path)
    3. apkgo from system PATH

.PARAMETER ApkPath
  Explicit APK path. If omitted, auto-finds the newest *-release.apk.

.PARAMETER Notes
  One-line update note.

.PARAMETER NotesFile
  Multi-line update note file path.

.PARAMETER Store
  Comma-separated store filter, e.g. -Store pgyer,huawei.

.PARAMETER DryRun
  Validate config only, do not upload.

.PARAMETER ApkgoPath
  apkgo.exe path. Omit to auto-resolve.

.EXAMPLE
  .\scripts\upload.ps1 -Notes "v1.0.1: fix table drag"
  .\scripts\upload.ps1 -NotesFile CHANGELOG.md
  .\scripts\upload.ps1 -ApkPath .\build\app\outputs\flutter-apk\app-release.apk -DryRun
  .\scripts\upload.ps1 -Store pgyer,huawei -Notes "internal beta"
#>

param(
    [string]$ApkPath    = "",
    [string]$Notes      = "",
    [string]$NotesFile  = "",
    [string]$Store      = "",
    [switch]$DryRun,
    [string]$ApkgoPath  = ""
)

$ErrorActionPreference = "Stop"

# --- base paths ---
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$exampleDir = Split-Path -Parent $scriptDir
$configFile = Join-Path $exampleDir "apkgo.yaml"
$pathFile   = Join-Path $exampleDir ".apkgo.path"

# --- 1. resolve apkgo ---
$apkgoCmd = $null

if ($ApkgoPath -and (Test-Path $ApkgoPath)) {
    $apkgoCmd = $ApkgoPath
}
elseif ((Test-Path $pathFile) -and -not $ApkgoPath) {
    $configured = (Get-Content $pathFile -Raw).Trim()
    if ($configured -and (Test-Path $configured)) {
        $apkgoCmd = $configured
    }
}
else {
    $resolved = Get-Command apkgo -ErrorAction SilentlyContinue
    if (-not $resolved) {
        # fallback: re-read User PATH from registry (handles terminals opened before PATH change)
        try {
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath) {
                $env:Path = $userPath + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
                $resolved = Get-Command apkgo -ErrorAction SilentlyContinue
            }
        } catch {}
    }
    if ($resolved) { $apkgoCmd = $resolved.Source }
}

if (-not $apkgoCmd) {
    Write-Host ""
    Write-Host "apkgo not found." -ForegroundColor Red
    Write-Host "  Option A: add apkgo v3.x dir to system PATH" -ForegroundColor Red
    Write-Host "  Option B: create example/.apkgo.path with full apkgo.exe path" -ForegroundColor Red
    Write-Host "  Option C: run with -ApkgoPath 'E:\...\apkgo.exe'" -ForegroundColor Red
    Write-Host "Download: https://github.com/KevinGong2013/apkgo/releases" -ForegroundColor Red
    exit 1
}

# --- 2. show version ---
try {
    $verJson = ((& $apkgoCmd version 2>&1) -join "`n") | ConvertFrom-Json -ErrorAction Stop
    Write-Host ("apkgo v{0} ready: {1}" -f $verJson.version, $apkgoCmd) -ForegroundColor Green
}
catch {
    Write-Host ("apkgo ready: " + $apkgoCmd) -ForegroundColor Green
}

# --- 3. apkgo.yaml ---
if (-not (Test-Path $configFile)) {
    Write-Host ("Missing apkgo.yaml: " + $configFile) -ForegroundColor Red
    Write-Host "Copy the template from README.md and fill in store secrets." -ForegroundColor Red
    exit 1
}

# --- 4. resolve APK ---
if ($ApkPath -and -not (Test-Path $ApkPath)) {
    Write-Error ("APK not found: " + $ApkPath)
}

if (-not $ApkPath) {
    $apkDir = Join-Path $exampleDir "build\app\outputs\flutter-apk"
    if (-not (Test-Path $apkDir)) {
        Write-Error ("APK output dir missing: {0}  Run 'flutter build apk --release' first." -f $apkDir)
    }
    $latest = Get-ChildItem -Path $apkDir -Filter "*-release.apk" -File |
              Sort-Object LastWriteTime -Descending |
              Select-Object -First 1
    if (-not $latest) {
        Write-Error ("No *-release.apk in {0}. Run 'flutter build apk --release' first." -f $apkDir)
    }
    $ApkPath = $latest.FullName
    Write-Host ("Latest APK: {0}  ({1} MB)" -f $ApkPath, [math]::Round($latest.Length / 1MB, 2)) -ForegroundColor Cyan
}

# --- 5. build args ---
$argList = @("upload", "-f", $ApkPath, "-c", $configFile)
if ($Notes)           { $argList += @("--notes", $Notes) }
if ($NotesFile)       { $argList += @("--notes-file", $NotesFile) }
if ($Store)           { $argList += @("--store", $Store) }
if ($DryRun.IsPresent) { $argList += "--dry-run" }

Write-Host ("RUN: apkgo " + ($argList -join ' ')) -ForegroundColor DarkGray

# --- 6. execute ---
& $apkgoCmd @argList
exit $LASTEXITCODE
