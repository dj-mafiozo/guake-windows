[CmdletBinding()]
param([string]$ResourceCompiler)
$ErrorActionPreference = 'Stop'
$repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (!$ResourceCompiler -and $env:RC_EXE) { $ResourceCompiler = $env:RC_EXE }
if (!$ResourceCompiler) {
    $sdk = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
    $ResourceCompiler = Get-ChildItem -LiteralPath $sdk -Directory |
        Sort-Object Name -Descending |
        ForEach-Object { Join-Path $_.FullName 'x64\rc.exe' } |
        Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (!$ResourceCompiler) { throw 'Windows SDK x64 Resource Compiler was not found' }
foreach ($item in @(@('Src\Vendor\i18n\Packages','i18nFlags_16x11'),@('Src\Resources','Guake.Images'))) {
    Push-Location -LiteralPath (Join-Path $repo $item[0])
    try {
        & $ResourceCompiler /nologo /fo ($item[1] + '.res') ($item[1] + '.rc')
        if ($LASTEXITCODE -ne 0) { throw "Resource Compiler failed: $LASTEXITCODE" }
    } finally { Pop-Location }
}
