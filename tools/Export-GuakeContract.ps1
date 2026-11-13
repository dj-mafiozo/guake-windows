[CmdletBinding()]
param([string]$GuakeRoot = (Join-Path (Split-Path $PSScriptRoot -Parent) '..\guake'))
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$revision = & git -C $GuakeRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot identify source revision' }
[xml]$schema = [IO.File]::ReadAllText((Join-Path $GuakeRoot 'guake\data\org.guake.gschema.xml'))
$schemas = @($schema.schemalist.schema | ForEach-Object {
    [ordered]@{
        id = $_.id
        path = $_.path
        keys = @($_.key | ForEach-Object {
            [ordered]@{ name = $_.name; type = $_.type; default = $_.default; summary = $_.summary }
        })
    }
})
$dbus = [IO.File]::ReadAllText((Join-Path $GuakeRoot 'guake\dbusiface.py'))
$methods = @([regex]::Matches($dbus, '(?m)^    def (?!__init__)([^\r\n]+):') | ForEach-Object { $_.Groups[1].Value })
$cli = [IO.File]::ReadAllText((Join-Path $GuakeRoot 'guake\main.py'))
$options = @([regex]::Matches($cli, '"(--[a-z][a-z0-9-]*)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
$contract = [ordered]@{
    source = 'https://github.com/Guake/guake'
    revision = [string]$revision
    note = 'Reference inventory only. Listed features are not necessarily implemented in the Windows port.'
    settings = $schemas
    remoteMethods = $methods
    cliOptions = $options
}
$path = Join-Path $repo 'docs\guake-contract.json'
[IO.File]::WriteAllText($path, ($contract | ConvertTo-Json -Depth 12) + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))