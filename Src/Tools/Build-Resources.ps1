[CmdletBinding()]
param([string]$ResourceCompiler)
$ErrorActionPreference = 'Stop'
$repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (!$ResourceCompiler) {
    $sdk = 'C:\Program Files (x86)\Windows Kits\10\bin'
    $ResourceCompiler = Get-ChildItem -LiteralPath $sdk -Directory |
        Sort-Object Name -Descending |
        ForEach-Object { Join-Path $_.FullName 'x64\rc.exe' } |
        Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (!$ResourceCompiler) { throw 'Windows SDK x64 Resource Compiler was not found' }
$directory = Join-Path $repo 'Src\Vendor\i18n\Packages'
Push-Location -LiteralPath $directory
try {
    & $ResourceCompiler /nologo /fo i18nFlags_16x11.res i18nFlags_16x11.rc
    if ($LASTEXITCODE -ne 0) { throw "Resource Compiler failed: $LASTEXITCODE" }
} finally { Pop-Location }