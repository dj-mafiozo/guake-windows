[CmdletBinding()]
param([string]$DelphiRoot = 'C:\Program Files (x86)\Embarcadero\Studio\19.0')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$msbuild = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'
$env:BDS = $DelphiRoot
$env:FrameworkDir = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319'
$env:FrameworkVersion = 'v4.0.30319'
$env:PATH = (Join-Path $DelphiRoot 'bin') + ';' + $env:PATH
& (Join-Path $PSScriptRoot 'Update-Version.ps1') -Part Build
& $msbuild (Join-Path $repo 'tests\GuakeTests.dproj') /t:Build /p:Config=Debug /p:Platform=Win64 /v:minimal /nologo
if ($LASTEXITCODE -ne 0) { throw "MSBuild failed: $LASTEXITCODE" }
& (Join-Path $repo 'bin\tests\GuakeTests.exe')
if ($LASTEXITCODE -ne 0) { throw "DUnitX failed: $LASTEXITCODE" }