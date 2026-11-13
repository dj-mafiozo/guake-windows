[CmdletBinding()]
param([ValidateSet('Build', 'Release')][string]$Part = 'Build')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$project = Join-Path $repo 'tests\GuakeTests.dproj'
[xml]$document = [IO.File]::ReadAllText($project)
$ns = [Xml.XmlNamespaceManager]::new($document.NameTable)
$ns.AddNamespace('p', 'http://schemas.microsoft.com/developer/msbuild/2003')
$group = $document.SelectSingleNode('/p:Project/p:PropertyGroup', $ns)
$name = if ($Part -eq 'Build') { 'VerInfo_Build' } else { 'VerInfo_Release' }
$node = $group.SelectSingleNode("p:$name", $ns)
$value = [int]$node.InnerText
if ($value -ge 65535) { throw "$name reached the Windows version limit; resetting is forbidden." }
$node.InnerText = [string]($value + 1)
$version = (@('VerInfo_MajorVer','VerInfo_MinorVer','VerInfo_Release','VerInfo_Build') | ForEach-Object {
    $group.SelectSingleNode("p:$_", $ns).InnerText
}) -join '.'
$keys = $group.SelectSingleNode('p:VerInfo_Keys', $ns)
$keys.InnerText = $keys.InnerText -replace '(FileVersion|ProductVersion)=[^;]*', "`$1=$version"
$document.Save($project)
Write-Output $version