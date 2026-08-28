Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$failed = $false
foreach ($number in 1..4) {
    $id = '{0:D2}' -f $number
    $modelRoot = Join-Path $root "assets/models/model_$id"
    foreach ($asset in @(
        @{ Path = Join-Path $modelRoot "base/model_${id}_face_base_v2.png"; Width = 1024; Height = 1536 },
        @{ Path = Join-Path $modelRoot "thumbnails/model_${id}_thumb_v2.png"; Width = 256; Height = 256 }
    )) {
        if (-not (Test-Path -LiteralPath $asset.Path)) { Write-Error "Ausente: $($asset.Path)"; $failed = $true; continue }
        $image = [System.Drawing.Bitmap]::FromFile($asset.Path)
        if ($image.Width -ne $asset.Width -or $image.Height -ne $asset.Height) { Write-Error "Tamanho invalido: $($asset.Path)"; $failed = $true }
        if ($image.GetPixel(0, 0).A -ne 0) { Write-Error "Canto sem transparencia: $($asset.Path)"; $failed = $true }
        $image.Dispose()
    }
    Write-Output "OK model_${id}: base e perfil v2"
}
if ($failed) { exit 1 }
