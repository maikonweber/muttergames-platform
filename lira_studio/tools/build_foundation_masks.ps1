Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$models = @('model_01', 'model_02', 'model_03', 'model_04')

foreach ($model in $models) {
    $maskPath = Join-Path $root "assets/models/$model/masks/${model}_skin_mask.png"
    $backupPath = Join-Path $root "assets/models/$model/masks/${model}_skin_mask_legacy.png"
    $tempPath = "$maskPath.new.png"

    if (-not (Test-Path -LiteralPath $backupPath)) {
        Copy-Item -LiteralPath $maskPath -Destination $backupPath
    }

    $bitmap = [System.Drawing.Bitmap]::new(1024, 1536, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()

    # Região segura do rosto: testa, bochechas e queixo, sem cabelo ou cenário.
    $path.AddBezier(512, 350, 420, 350, 340, 420, 305, 520)
    $path.AddBezier(305, 520, 270, 650, 276, 820, 335, 935)
    $path.AddBezier(335, 935, 385, 1035, 445, 1110, 512, 1125)
    $path.AddBezier(512, 1125, 579, 1110, 639, 1035, 689, 935)
    $path.AddBezier(689, 935, 748, 820, 754, 650, 719, 520)
    $path.AddBezier(719, 520, 684, 420, 604, 350, 512, 350)
    $path.CloseFigure()
    $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $graphics.FillPath($brush, $path)
    $bitmap.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $brush.Dispose()
    $path.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
    Move-Item -LiteralPath $tempPath -Destination $maskPath -Force
    Write-Output "Regenerated $maskPath"
}
