[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectFile,
    [Parameter(Mandatory = $true)][string]$OutputDirectory,
    [ValidateSet('Base', 'Debug', 'Release')][string]$Config = 'Debug',
    [ValidateSet('Win64')][string]$Platform = 'Win64',
    [string]$DelphiRoot = $env:BDS
)
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath($ProjectFile)
$output = [IO.Path]::GetFullPath($OutputDirectory)
$sourceRoot = Split-Path $PSScriptRoot -Parent
New-Item -ItemType Directory -Path $output -Force | Out-Null
if ($DelphiRoot) {
    $env:BDS = [IO.Path]::GetFullPath($DelphiRoot)
    $env:PATH = (Join-Path $env:BDS 'bin') + ';' + $env:PATH
}
if ([IO.Path]::GetFileNameWithoutExtension($project) -eq 'git-zsh') { return }

# Custom RC only. VersionInfo, manifest and the project icon remain Delphi/MSBuild resources.
& (Join-Path $PSScriptRoot 'Build-Resources.ps1')

# A direct IDE build of any host project must also provide its Zsh launcher.
$msbuild = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'
if (!(Test-Path -LiteralPath $msbuild)) { throw 'MSBuild for the installed .NET Framework was not found.' }
$env:FrameworkDir = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319'
$env:FrameworkVersion = 'v4.0.30319'
$launcher = Join-Path $sourceRoot 'Launchers\git-zsh.dproj'
& $msbuild $launcher /t:Make "/p:Config=$Config" "/p:Platform=$Platform" "/p:DCC_ExeOutput=$output" /v:minimal /nologo
if ($LASTEXITCODE -ne 0) { throw "The Zsh launcher build failed: $LASTEXITCODE" }
