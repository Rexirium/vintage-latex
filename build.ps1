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

$failed = @()
foreach ($file in Get-ChildItem examples -Include *.tex, *.mp -Recurse | Sort-Object Name) {
  $name = $file.BaseName
  if ($Only.Count -gt 0 -and $Only -notcontains $name) { continue }
  $needsFiziko = $name -like '*fiziko*'
  if ($needsFiziko -and -not $env:MPINPUTS) {
    Write-Host "SKIP $name (MPINPUTS not set)"; continue
  }
  if ($file.Extension -eq '.tex') {
    lualatex -interaction=nonstopmode -halt-on-error -output-directory=build $file.FullName > "build/$name.stdout.txt" 2>&1
  } else {
    mpost -interaction=nonstopmode -halt-on-error -job-name=$name -output-directory=build $file.FullName > "build/$name.stdout.txt" 2>&1
  }
  if ($LASTEXITCODE -eq 0) { Write-Host "OK   $name" } else { Write-Host "FAIL $name"; $failed += $name }
}
if ($failed) { Write-Error "Failed: $($failed -join ', ')" }
