param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath
)

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outputPath = Join-Path $root 'assets/models/model_02/base/model_02_face_base_v2.png'
$tempPath = "$outputPath.pending.png"
$resolvedSource = (Resolve-Path -LiteralPath $SourcePath).Path
$source = [System.Drawing.Bitmap]::new($resolvedSource)
if ($source.Width -ne 1024 -or $source.Height -ne 1536) {
    $source.Dispose()
    throw 'A arte aprovada precisa usar o canvas 1024 × 1536.'
}

$source.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
$source.Dispose()
Move-Item -LiteralPath $tempPath -Destination $outputPath -Force
Write-Output "Created $outputPath"
