[CmdletBinding()]
param(
    [string]$DelphiRoot = 'C:\Program Files (x86)\Embarcadero\Studio\19.0',
    [string]$MainOutput
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$msbuild = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'
$env:BDS = $DelphiRoot
$env:FrameworkDir = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319'
$env:FrameworkVersion = 'v4.0.30319'
$env:PATH = (Join-Path $DelphiRoot 'bin') + ';' + $env:PATH
if (!(Get-Command map2pdb.exe -ErrorAction SilentlyContinue)) { throw 'map2pdb.exe is required to build matching PDB symbols.' }
$projectHashes = @{}
Get-ChildItem -Path (Join-Path $repo 'Src') -Filter '*.dproj' -Recurse | ForEach-Object { $projectHashes[$_.FullName] = (Get-FileHash -LiteralPath $_.FullName).Hash }
foreach ($project in @('Src\Launchers\git-zsh.dproj','Src\Tests\GuakeTests.dproj','Src\Tests\GuakeFormsPreview.dproj','Src\guake.dproj')) {
    $outputArguments = @()
    if ($MainOutput -and $project -in @('Src\guake.dproj','Src\Launchers\git-zsh.dproj')) {
        $MainOutput = [IO.Path]::GetFullPath($MainOutput)
        $outputArguments = @('/p:DCC_ExeOutput=' + $MainOutput)
    }
    & $msbuild (Join-Path $repo $project) @outputArguments /t:Build /p:Config=Debug /p:Platform=Win64 /v:minimal /nologo
    if ($LASTEXITCODE -ne 0) { throw "MSBuild failed: $LASTEXITCODE" }
}
$launcherOutput = if ($MainOutput) { $MainOutput } else { Join-Path $repo 'bin\Win64' }
foreach ($destination in @('bin\tests','bin\forms')) {
    foreach ($name in @('git-zsh.exe','git-zsh.pdb')) {
        Copy-Item -LiteralPath (Join-Path $launcherOutput $name) -Destination (Join-Path $repo $destination) -Force
    }
}
$locale = Join-Path $repo 'bin\forms\locale\catalogs'
New-Item -ItemType Directory -Force -Path $locale | Out-Null
Copy-Item -Path (Join-Path $repo 'Src\Localization\catalogs\*.json') -Destination $locale -Force
$applicationOutput = if ($MainOutput) { $MainOutput } else { Join-Path $repo 'bin\Win64' }
Copy-Item -LiteralPath (Join-Path $repo 'bin\forms\locale') -Destination $applicationOutput -Recurse -Force
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

foreach ($path in $projectHashes.Keys) {
    if ((Get-FileHash -LiteralPath $path).Hash -ne $projectHashes[$path]) { throw "Building modified the project: $path" }
}
