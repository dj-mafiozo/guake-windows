[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectFile,
    [Parameter(Mandatory = $true)][string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath($ProjectFile)
$output = [IO.Path]::GetFullPath($OutputDirectory)
$name = [IO.Path]::GetFileNameWithoutExtension($project)
$map = Join-Path $output ($name + '.map')
$sourceRoot = Split-Path $PSScriptRoot -Parent
if (!(Get-Command map2pdb.exe -ErrorAction SilentlyContinue)) { throw 'map2pdb.exe is required on PATH for IDE and command-line builds.' }
& python.exe (Join-Path $PSScriptRoot 'Build-Symbols.py') $map
if ($LASTEXITCODE -ne 0) { throw "PDB generation failed: $LASTEXITCODE" }
if ($name -ne 'git-zsh') {
    $catalogs = Join-Path $output 'locale\catalogs'
    New-Item -ItemType Directory -Path $catalogs -Force | Out-Null
    Copy-Item -Path (Join-Path $sourceRoot 'Localization\catalogs\*.json') -Destination $catalogs -Force
    foreach ($file in @('git-zsh.exe', 'git-zsh.pdb')) {
        if (!(Test-Path -LiteralPath (Join-Path $output $file))) { throw "The project dependency did not produce $file." }
    }
}
