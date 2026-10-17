# SPDX-License-Identifier: CC-BY-SA-4.0
# Compile every example into build/<name>/. Run from the repository root with
# PowerShell 7. Set $env:MPINPUTS to the fiziko checkout first (trailing ';')
# or pass -Fiziko <path>; without it the fiziko examples are skipped.
param(
  [string]$Fiziko = "",
  [string[]]$Only = @()
)
$ErrorActionPreference = 'Stop'
if ($Fiziko) { $env:MPINPUTS = "$((Resolve-Path $Fiziko).Path);" }
New-Item -ItemType Directory -Force build | Out-Null
$mpostIsMiKTeX = (& mpost --version 2>&1 | Select-Object -First 1) -match 'MiKTeX'

$failed = @()
foreach ($file in Get-ChildItem examples -Include *.tex, *.mp -Recurse | Sort-Object Name) {
  $name = $file.BaseName
  if ($Only.Count -gt 0 -and $Only -notcontains $name) { continue }
  $needsFiziko = $name -like '*fiziko*'
  if ($needsFiziko -and -not $env:MPINPUTS) {
    Write-Host "SKIP $name (MPINPUTS not set)"; continue
  }
  $sourcePath = $file.FullName
  $outDir = "build/$name"
  New-Item -ItemType Directory -Force $outDir | Out-Null
  if ($file.Extension -eq '.tex') {
    # A relative cache path avoids Windows LuaTeX issues with Unicode user paths.
    $savedTexmfCache = $env:TEXMFCACHE
    if (-not $env:TEXMFCACHE) {
      New-Item -ItemType Directory -Force build/tex-cache | Out-Null
      $env:TEXMFCACHE = 'build/tex-cache'
    }
    try {
      lualatex -interaction=nonstopmode -halt-on-error "-output-directory=$outDir" $sourcePath > "$outDir/$name.stdout.txt" 2>&1
    } finally {
      $env:TEXMFCACHE = $savedTexmfCache
    }
  } else {
    # MiKTeX's mpost (3.00, 2026) crashes at the first btex label unless a
    # job name is given, and spells the flag -job-name; TeX Live's mpost
    # rejects that spelling and needs no flag, since the job name defaults
    # to the file's basename.
    if ($mpostIsMiKTeX) {
      mpost -interaction=nonstopmode -halt-on-error "-job-name=$name" "-output-directory=$outDir" $sourcePath > "$outDir/$name.stdout.txt" 2>&1
    } else {
      # TeX Live cannot read back its mpx file with -output-directory.
      # Look up the source by basename: Windows mpost can crash on parent paths.
      $savedMpInputs = $env:MPINPUTS
      $env:MPINPUTS = "$($file.DirectoryName);$savedMpInputs"
      Push-Location $outDir
      try {
        mpost -interaction=nonstopmode -halt-on-error $file.Name > "$name.stdout.txt" 2>&1
      } finally {
        Pop-Location
        $env:MPINPUTS = $savedMpInputs
      }
    }
  }
  if ($LASTEXITCODE -eq 0) { Write-Host "OK   $name" } else { Write-Host "FAIL $name"; $failed += $name }
}
if ($failed) { Write-Error "Failed: $($failed -join ', ')" }
