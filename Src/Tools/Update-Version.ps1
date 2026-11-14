[CmdletBinding()]
param([Parameter(Mandatory = $true)][ValidateSet('Build', 'Release')][string]$Part)
$ErrorActionPreference = 'Stop'
$repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$projects = @('Src\Tests\GuakeTests.dproj','Src\Tests\GuakeFormsPreview.dproj','Src\guake.dproj')
[xml]$reference = [IO.File]::ReadAllText((Join-Path $repo $projects[0]))
$ns = [Xml.XmlNamespaceManager]::new($reference.NameTable)
$ns.AddNamespace('p', 'http://schemas.microsoft.com/developer/msbuild/2003')
$group = $reference.SelectSingleNode('/p:Project/p:PropertyGroup[p:VerInfo_Build]', $ns)
$values = [ordered]@{}
foreach ($name in @('VerInfo_MajorVer','VerInfo_MinorVer','VerInfo_Release','VerInfo_Build')) {
    $values[$name] = [int]$group.SelectSingleNode("p:$name", $ns).InnerText
}
$name = if ($Part -eq 'Build') { 'VerInfo_Build' } else { 'VerInfo_Release' }
if ($values[$name] -ge 65535) { throw "$name reached the Windows version limit; resetting is forbidden." }
$values[$name]++
$version = $values.Values -join '.'
foreach ($project in $projects) {
    $path = Join-Path $repo $project
    [xml]$document = [IO.File]::ReadAllText($path)
    $ns = [Xml.XmlNamespaceManager]::new($document.NameTable)
    $ns.AddNamespace('p', 'http://schemas.microsoft.com/developer/msbuild/2003')
    $group = $document.SelectSingleNode('/p:Project/p:PropertyGroup[p:VerInfo_Build]', $ns)
    foreach ($name in $values.Keys) { $group.SelectSingleNode("p:$name", $ns).InnerText = [string]$values[$name] }
    $keys = $group.SelectSingleNode('p:VerInfo_Keys', $ns)
    $keys.InnerText = $keys.InnerText -replace '(FileVersion|ProductVersion)=[^;]*', "`$1=$version"
    $document.Save($path)
}
Write-Output $version
