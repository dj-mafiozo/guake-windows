[CmdletBinding()]
param([string]$OutputDirectory)
$ErrorActionPreference = 'Stop'
$repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$output = if ($OutputDirectory) { [IO.Path]::GetFullPath($OutputDirectory) } else { Join-Path $repo 'bin\Win64' }
foreach ($name in @('guake.exe','guake.pdb','git-zsh.exe','git-zsh.pdb')) {
    if (!(Test-Path -LiteralPath (Join-Path $output $name))) { throw "Missing $name; build the Win64 project first." }
}
$licenses = Join-Path $output 'licenses'
New-Item -ItemType Directory -Force -Path $licenses | Out-Null
foreach ($entry in @(
    @('LICENSE','Guake-Windows.txt'),
    @('Src\Localization\COPYING','Guake-translations.txt'),
    @('Src\Vendor\i18n\LICENSE','i18n.txt'),
    @('Src\Vendor\stacktrace\License','stacktrace.txt'),
    @('Src\Common\LICENSE','Common.txt')
)) {
    Copy-Item -LiteralPath (Join-Path $repo $entry[0]) -Destination (Join-Path $licenses $entry[1]) -Force
}
$archive = Join-Path $repo ('bin\guake-' + (Get-Item (Join-Path $output 'guake.exe')).VersionInfo.FileVersion + '-Win64.zip')
Compress-Archive -LiteralPath (Join-Path $output 'guake.exe'),(Join-Path $output 'guake.pdb'),(Join-Path $output 'git-zsh.exe'),(Join-Path $output 'git-zsh.pdb'),(Join-Path $output 'locale'),$licenses -DestinationPath $archive -Force
Write-Output $archive
