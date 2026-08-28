param(
    [Parameter(Mandatory = $true)]
    [string]$SpritePath
)

Add-Type -AssemblyName System.Drawing

$resolved = (Resolve-Path -LiteralPath $SpritePath).Path
$tempPath = "$resolved.alpha.png"
$source = [System.Drawing.Bitmap]::new($resolved)
$bitmap = [System.Drawing.Bitmap]::new($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$graphics.DrawImage($source, 0, 0, $source.Width, $source.Height)
$graphics.Dispose()
$source.Dispose()

for ($y = 0; $y -lt $bitmap.Height; $y++) {
    for ($x = 0; $x -lt $bitmap.Width; $x++) {
        $pixel = $bitmap.GetPixel($x, $y)
        $minimum = [Math]::Min($pixel.R, [Math]::Min($pixel.G, $pixel.B))
        $maximum = [Math]::Max($pixel.R, [Math]::Max($pixel.G, $pixel.B))
        # Remove somente o tabuleiro branco/cinza neutro inserido pela geração.
        if ($minimum -ge 190 -and ($maximum - $minimum) -le 8) {
            $bitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $pixel.R, $pixel.G, $pixel.B))
        }
    }
}

$bitmap.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()
Move-Item -LiteralPath $tempPath -Destination $resolved -Force
Write-Output "Cleaned alpha in $resolved"
