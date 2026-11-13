[CmdletBinding()]
param([string]$DelphiRoot = 'C:\Program Files (x86)\Embarcadero\Studio\19.0')
$ErrorActionPreference = 'Stop'
$repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$msbuild = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'
$env:BDS = $DelphiRoot
$env:FrameworkDir = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319'
$env:FrameworkVersion = 'v4.0.30319'
$env:PATH = (Join-Path $DelphiRoot 'bin') + ';' + $env:PATH
if (!(Get-Command map2pdb.exe -ErrorAction SilentlyContinue)) { throw 'map2pdb.exe is required to build matching PDB symbols.' }
& (Join-Path $PSScriptRoot 'Update-Version.ps1') -Part Build
foreach ($project in @('Src\Tests\GuakeTests.dproj','Src\Tests\GuakeFormsPreview.dproj','Src\guake.dproj')) {
    & $msbuild (Join-Path $repo $project) /t:Build /p:Config=Debug /p:Platform=Win64 /v:minimal /nologo
    if ($LASTEXITCODE -ne 0) { throw "MSBuild failed: $LASTEXITCODE" }
}
$locale = Join-Path $repo 'bin\forms\locale\catalogs'
New-Item -ItemType Directory -Force -Path $locale | Out-Null
Copy-Item -Path (Join-Path $repo 'Src\Localization\catalogs\*.json') -Destination $locale -Force
Copy-Item -LiteralPath (Join-Path $repo 'bin\forms\locale') -Destination (Join-Path $repo 'bin\Win64') -Recurse -Force
$testTemp = Join-Path $repo '.build\test-temp'
New-Item -ItemType Directory -Force -Path $testTemp | Out-Null
$previousTemp = $env:TEMP
$previousTmp = $env:TMP
try {
    $env:TEMP = $testTemp
    $env:TMP = $testTemp
    & (Join-Path $repo 'bin\tests\GuakeTests.exe')
    if ($LASTEXITCODE -ne 0) { throw "DUnitX failed: $LASTEXITCODE" }
} finally {
    $env:TEMP = $previousTemp
    $env:TMP = $previousTmp
}
