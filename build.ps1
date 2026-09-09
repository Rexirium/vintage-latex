# SPDX-License-Identifier: CC-BY-SA-4.0
# Compile every example into build/. Run from the repository root with
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
  $rel = "examples/$($file.Name)"
  if ($file.Extension -eq '.tex') {
    lualatex -interaction=nonstopmode -halt-on-error -output-directory=build $rel > "build/$name.stdout.txt" 2>&1
  } else {
    # MiKTeX's mpost (3.00, 2026) crashes at the first btex label unless a
    # job name is given, and spells the flag -job-name; TeX Live's mpost
    # rejects that spelling and needs no flag, since the job name defaults
    # to the file's basename.
    $jobFlag = if ($mpostIsMiKTeX) { "-job-name=$name" } else { $null }
    mpost -interaction=nonstopmode -halt-on-error $jobFlag -output-directory=build $rel > "build/$name.stdout.txt" 2>&1
  }
  if ($LASTEXITCODE -eq 0) { Write-Host "OK   $name" } else { Write-Host "FAIL $name"; $failed += $name }
}
if ($failed) { Write-Error "Failed: $($failed -join ', ')" }
