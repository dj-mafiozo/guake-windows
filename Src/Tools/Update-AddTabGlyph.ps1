[CmdletBinding()]
param([switch]$Check)
$ErrorActionPreference = 'Stop'
$repo = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$source = Join-Path $repo 'Src\Resources\add_tab.png'
$form = Join-Path $repo 'Src\Forms\frmMainU.dfm'
Add-Type -AssemblyName System.Drawing
$image = $bitmap = $graphics = $stream = $null
try {
    $image = [Drawing.Image]::FromFile($source)
    $bitmap = New-Object Drawing.Bitmap($image.Width, $image.Height, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([Drawing.Color]::FromArgb(240, 240, 240))
    $graphics.DrawImageUnscaled($image, 0, 0)
    $stream = New-Object IO.MemoryStream
    $bitmap.Save($stream, [Drawing.Imaging.ImageFormat]::Bmp)
    $bytes = $stream.ToArray()
    $payload = [BitConverter]::GetBytes([int]$bytes.Length) + $bytes
    $expected = [BitConverter]::ToString($payload).Replace('-', '')
} finally {
    foreach ($resource in @($stream, $graphics, $bitmap, $image)) {
        if ($null -ne $resource) { $resource.Dispose() }
    }
}
$text = [IO.File]::ReadAllText($form)
$pattern = '(?ms)(object btnAddTab: TSpeedButton\b.*?Glyph\.Data = \{)([0-9A-Fa-f\s]+)(\})'
$match = [regex]::Match($text, $pattern)
if (!$match.Success) { throw 'Cannot find btnAddTab.Glyph.Data in frmMainU.dfm' }
$current = $match.Groups[2].Value -replace '\s', ''
if ($current -ne $expected) {
    if ($Check) { throw 'btnAddTab.Glyph differs from Src/Resources/add_tab.png; regenerate it explicitly.' }
    $rows = for ($offset = 0; $offset -lt $expected.Length; $offset += 64) {
        '        ' + $expected.Substring($offset, [Math]::Min(64, $expected.Length - $offset))
    }
    $replacement = $match.Groups[1].Value + "`r`n" + ($rows -join "`r`n") + $match.Groups[3].Value
    $text = $text.Substring(0, $match.Index) + $replacement + $text.Substring($match.Index + $match.Length)
    [IO.File]::WriteAllText($form, $text, [Text.UTF8Encoding]::new($true))
}
Write-Output 'btnAddTab.Glyph matches Src/Resources/add_tab.png'
