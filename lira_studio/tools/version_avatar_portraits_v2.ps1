<#
Cria a revisao v2 dos retratos sem alterar a identidade das modelos.
Remove apenas pixels ciano/azulados de vazamento nas bordas e deriva a
miniatura diretamente da base que sera exibida no jogo.
#>
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot

function Save-Png([System.Drawing.Bitmap]$bitmap, [string]$path) {
    $temp = "$path.tmp.png"
    $bitmap.Save($temp, [System.Drawing.Imaging.ImageFormat]::Png)
    Move-Item -LiteralPath $temp -Destination $path -Force
}

foreach ($number in 1..4) {
    $id = '{0:D2}' -f $number
    $modelRoot = Join-Path $root "assets/models/model_$id"
    $sourcePath = Join-Path $modelRoot "base/model_${id}_face_base_v1.png"
    $baseV2Path = Join-Path $modelRoot "base/model_${id}_face_base_v2.png"
    $thumbV2Path = Join-Path $modelRoot "thumbnails/model_${id}_thumb_v2.png"

    $source = [System.Drawing.Bitmap]::FromFile($sourcePath)
    $base = New-Object System.Drawing.Bitmap($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($base)
    $graphics.DrawImage($source, 0, 0, $source.Width, $source.Height)
    $graphics.Dispose()
    $source.Dispose()

    # Vazamentos azuis/cianos aparecem sobretudo como pixels frios isolados
    # ao redor do cabelo. Remover somente essa faixa preserva pele, cabelo
    # e a arte original do retrato.
    for ($y = 0; $y -lt $base.Height; $y++) {
        for ($x = 0; $x -lt $base.Width; $x++) {
            $pixel = $base.GetPixel($x, $y)
            $isCyanLeak = ($pixel.G -gt ($pixel.R + 24)) -and ($pixel.B -gt ($pixel.R + 8))
            $isBlueLeak = ($pixel.B -gt ($pixel.R + 35)) -and ($pixel.B -gt ($pixel.G - 8))
            if (($isCyanLeak -or $isBlueLeak) -and $pixel.A -lt 255) {
                $base.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            }
        }
    }
    Save-Png $base $baseV2Path

    $thumb = New-Object System.Drawing.Bitmap(256, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $thumbGraphics = [System.Drawing.Graphics]::FromImage($thumb)
    $thumbGraphics.Clear([System.Drawing.Color]::Transparent)
    $thumbGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $thumbGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $thumbGraphics.DrawImage($base, [System.Drawing.Rectangle]::new(0, 0, 256, 256), [System.Drawing.Rectangle]::new(64, 28, 896, 896), [System.Drawing.GraphicsUnit]::Pixel)
    $thumbGraphics.Dispose()
    Save-Png $thumb $thumbV2Path
    $thumb.Dispose()
    $base.Dispose()
    Write-Output "v2 criado: model_$id"
}
