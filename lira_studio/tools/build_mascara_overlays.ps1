Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;

public static class MascaraOverlayBuilder {
    static Rectangle AlphaBounds(Bitmap bitmap) {
        int minX = bitmap.Width, minY = bitmap.Height, maxX = -1, maxY = -1;
        for (int y = 0; y < bitmap.Height; y++) for (int x = 0; x < bitmap.Width; x++) {
            if (bitmap.GetPixel(x, y).A > 12) { minX = Math.Min(minX, x); minY = Math.Min(minY, y); maxX = Math.Max(maxX, x); maxY = Math.Max(maxY, y); }
        }
        return maxX < 0 ? Rectangle.Empty : Rectangle.FromLTRB(minX, minY, maxX + 1, maxY + 1);
    }
    public static void Build(string leftPath, string rightPath, string outputPath, int leftX, int rightX, int y, int width, int height) {
        using (Bitmap left = new Bitmap(leftPath)) using (Bitmap right = new Bitmap(rightPath)) using (Bitmap output = new Bitmap(1024, 1536, PixelFormat.Format32bppArgb)) {
            Rectangle leftSource = AlphaBounds(left), rightSource = AlphaBounds(right);
            using (Graphics graphics = Graphics.FromImage(output)) {
                graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceOver;
                graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
                graphics.DrawImage(left, new Rectangle(leftX, y, width, height), leftSource, GraphicsUnit.Pixel);
                graphics.DrawImage(right, new Rectangle(rightX, y, width, height), rightSource, GraphicsUnit.Pixel);
            }
            output.Save(outputPath, ImageFormat.Png);
        }
    }
}
'@

$styles = @(
    @{ Id = 'natural_defined'; Height = 32 },
    @{ Id = 'lengthening'; Height = 34 },
    @{ Id = 'volumizing'; Height = 34 },
    @{ Id = 'dramatic_fan'; Height = 36 }
)
$placements = @(
    @{ Model = 'model_01'; LeftX = 338; RightX = 555; Y = 508; Width = 132; Height = 32 },
    @{ Model = 'model_02'; LeftX = 338; RightX = 555; Y = 672; Width = 132; Height = 32 },
    @{ Model = 'model_03'; LeftX = 338; RightX = 555; Y = 550; Width = 132; Height = 32 },
    @{ Model = 'model_04'; LeftX = 338; RightX = 555; Y = 558; Width = 132; Height = 32 }
)

foreach ($placement in $placements) {
    $outputDirectory = Join-Path $root ("assets\models\{0}\makeup\mascara" -f $placement.Model)
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
    foreach ($style in $styles) {
        $left = Join-Path $root ("assets\cosmetics\mascara\items\mascara_{0}_left_v1.png" -f $style.Id)
        $right = Join-Path $root ("assets\cosmetics\mascara\items\mascara_{0}_right_v1.png" -f $style.Id)
        $outputPath = Join-Path $outputDirectory ("{0}_mascara_{1}_overlay_v1.png" -f $placement.Model, $style.Id)
        [MascaraOverlayBuilder]::Build($left, $right, $outputPath, $placement.LeftX, $placement.RightX, $placement.Y, $placement.Width, $style.Height)
    }
}
