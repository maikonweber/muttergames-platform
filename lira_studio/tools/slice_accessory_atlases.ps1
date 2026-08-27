Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$atlasDirectory = Join-Path $root 'assets\accessories\atlas'
$outputDirectory = Join-Path $root 'assets\accessories\items'
$challengeOutputDirectory = Join-Path $root 'assets\ui\challenge_emblems'
$actionOutputDirectory = Join-Path $root 'assets\ui\action_controls'
$toolOutputDirectory = Join-Path $root 'assets\ui\cosmetic_tools'
$swatchOutputDirectory = Join-Path $root 'assets\cosmetics\swatches'
$finishOutputDirectory = Join-Path $root 'assets\cosmetics\finishes'
$highlightOutputDirectory = Join-Path $root 'assets\cosmetics\highlights'
$eyelinerOutputDirectory = Join-Path $root 'assets\cosmetics\eyeliner\items'
$mascaraOutputDirectory = Join-Path $root 'assets\cosmetics\mascara\items'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $challengeOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $actionOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $toolOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $swatchOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $finishOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $highlightOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $eyelinerOutputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $mascaraOutputDirectory | Out-Null

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;

public static class AccessorySlicer {
    static double[] Mean(Bitmap bmp, int x0, int y0, int width, int height) {
        double r = 0, g = 0, b = 0; int count = 0;
        for (int y = y0; y < y0 + height; y += 3)
        for (int x = x0; x < x0 + width; x += 3) { Color c = bmp.GetPixel(x, y); r += c.R; g += c.G; b += c.B; count++; }
        return new[] { r / count, g / count, b / count };
    }
    static double Mix(double a, double b, double t) { return a * (1 - t) + b * t; }
    public static void Slice(string sourcePath, string outputPath, string prefix, string[] names) {
        using (Bitmap source = new Bitmap(sourcePath)) {
            int cw = source.Width / 3, ch = source.Height / 2, margin = 24, sample = 32;
            for (int i = 0; i < 6; i++) {
                int ox = (i % 3) * cw, oy = (i / 3) * ch;
                double[] tl = Mean(source, ox + margin, oy + margin, sample, sample), tr = Mean(source, ox + cw - margin - sample, oy + margin, sample, sample), bl = Mean(source, ox + margin, oy + ch - margin - sample, sample, sample), br = Mean(source, ox + cw - margin - sample, oy + ch - margin - sample, sample, sample);
                using (Bitmap sprite = new Bitmap(cw, ch, PixelFormat.Format32bppArgb)) {
                    for (int y = 0; y < ch; y++) for (int x = 0; x < cw; x++) {
                        double u = x / (double)(cw - 1), v = y / (double)(ch - 1);
                        double topR = Mix(tl[0], tr[0], u), topG = Mix(tl[1], tr[1], u), topB = Mix(tl[2], tr[2], u);
                        double bottomR = Mix(bl[0], br[0], u), bottomG = Mix(bl[1], br[1], u), bottomB = Mix(bl[2], br[2], u);
                        double bgR = Mix(topR, bottomR, v), bgG = Mix(topG, bottomG, v), bgB = Mix(topB, bottomB, v);
                        Color c = source.GetPixel(ox + x, oy + y);
                        double distance = Math.Sqrt((c.R-bgR)*(c.R-bgR)+(c.G-bgG)*(c.G-bgG)+(c.B-bgB)*(c.B-bgB));
                        int alpha = (int)Math.Round(Math.Max(0, Math.Min(255, (distance - 7) * 10)));
                        sprite.SetPixel(x, y, Color.FromArgb(alpha, c.R, c.G, c.B));
                    }
                    sprite.Save(System.IO.Path.Combine(outputPath, prefix + "_" + names[i] + "_v1.png"), ImageFormat.Png);
                }
            }
        }
    }
    public static void SliceCards(string sourcePath, string outputPath, string prefix, string[] names) {
        using (Bitmap source = new Bitmap(sourcePath)) {
            int cw = source.Width / 3, ch = source.Height / 2;
            for (int i = 0; i < 6; i++) using (Bitmap card = new Bitmap(cw, ch, PixelFormat.Format32bppArgb)) {
                using (Graphics graphics = Graphics.FromImage(card)) graphics.DrawImage(source, new Rectangle(0, 0, cw, ch), new Rectangle((i % 3) * cw, (i / 3) * ch, cw, ch), GraphicsUnit.Pixel);
                card.Save(System.IO.Path.Combine(outputPath, prefix + "_" + names[i] + "_card_v1.png"), ImageFormat.Png);
            }
        }
    }
    public static void SliceCardsGrid(string sourcePath, string outputPath, string prefix, string[] names, int columns, int rows) {
        using (Bitmap source = new Bitmap(sourcePath)) {
            int cw = source.Width / columns, ch = source.Height / rows;
            for (int i = 0; i < names.Length; i++) using (Bitmap card = new Bitmap(cw, ch, PixelFormat.Format32bppArgb)) {
                using (Graphics graphics = Graphics.FromImage(card)) graphics.DrawImage(source, new Rectangle(0, 0, cw, ch), new Rectangle((i % columns) * cw, (i / columns) * ch, cw, ch), GraphicsUnit.Pixel);
                card.Save(System.IO.Path.Combine(outputPath, prefix + "_" + names[i] + "_card_v1.png"), ImageFormat.Png);
            }
        }
    }
    public static void SlicePairsGrid(string sourcePath, string outputPath, string prefix, string[] names, int columns, int rows) {
        using (Bitmap source = new Bitmap(sourcePath)) {
            int cw = source.Width / columns, ch = source.Height / rows, leftWidth = cw / 2, rightWidth = cw - leftWidth;
            for (int i = 0; i < names.Length; i++) {
                int x = (i % columns) * cw, y = (i / columns) * ch;
                using (Bitmap left = new Bitmap(leftWidth, ch, PixelFormat.Format32bppArgb)) {
                    using (Graphics graphics = Graphics.FromImage(left)) graphics.DrawImage(source, new Rectangle(0, 0, leftWidth, ch), new Rectangle(x, y, leftWidth, ch), GraphicsUnit.Pixel);
                    left.Save(System.IO.Path.Combine(outputPath, prefix + "_" + names[i] + "_left_v1.png"), ImageFormat.Png);
                }
                using (Bitmap right = new Bitmap(rightWidth, ch, PixelFormat.Format32bppArgb)) {
                    using (Graphics graphics = Graphics.FromImage(right)) graphics.DrawImage(source, new Rectangle(0, 0, rightWidth, ch), new Rectangle(x + leftWidth, y, rightWidth, ch), GraphicsUnit.Pixel);
                    right.Save(System.IO.Path.Combine(outputPath, prefix + "_" + names[i] + "_right_v1.png"), ImageFormat.Png);
                }
            }
        }
    }
}
'@

[AccessorySlicer]::Slice((Join-Path $atlasDirectory 'accessory_selection_atlas_v1.png'), $outputDirectory, 'accessory', [string[]]@('pearl_drop_earrings', 'gold_hoop_earrings', 'star_barrette', 'flower_barrette', 'cat_eye_sunglasses', 'heart_tiara'))
[AccessorySlicer]::Slice((Join-Path $atlasDirectory 'accessory_selection_atlas_v2.png'), $outputDirectory, 'accessory', [string[]]@('heart_stud_earrings', 'moon_barrette', 'sapphire_barrette', 'round_glasses', 'floral_headband', 'pearl_flower_necklace'))
[AccessorySlicer]::SliceCards((Join-Path $root 'assets\ui\atlas\challenge_theme_emblems_atlas_v1.png'), $challengeOutputDirectory, 'challenge', [string[]]@('daily', 'gala', 'festival', 'fantasy', 'urban_editorial', 'romantic_garden'))
[AccessorySlicer]::SliceCards((Join-Path $root 'assets\ui\atlas\ui_action_controls_atlas_v1.png'), $actionOutputDirectory, 'action', [string[]]@('undo', 'redo', 'compare', 'erase', 'confirm', 'locked'))
[AccessorySlicer]::SliceCardsGrid((Join-Path $root 'assets\ui\atlas\ui_cosmetic_tools_atlas_v1.png'), $toolOutputDirectory, 'tool', [string[]]@('lipstick', 'brush', 'eyeshadow_palette', 'eyeliner', 'mascara', 'sponge'), 2, 3)
[AccessorySlicer]::SliceCards((Join-Path $root 'assets\cosmetics\atlas\cosmetic_color_swatches_v1.png'), $swatchOutputDirectory, 'swatch', [string[]]@('ruby_lip', 'rose_lip', 'plum_lip', 'champagne_shadow', 'copper_shadow', 'violet_shadow'))
[AccessorySlicer]::SliceCards((Join-Path $root 'assets\cosmetics\atlas\cosmetic_finish_texture_atlas_v1.png'), $finishOutputDirectory, 'finish', [string[]]@('matte', 'satin', 'pearl', 'glitter', 'metallic', 'gloss'))
[AccessorySlicer]::SliceCardsGrid((Join-Path $root 'assets\cosmetics\atlas\cosmetic_highlight_texture_atlas_v1.png'), $highlightOutputDirectory, 'highlight', [string[]]@('pearl_soft', 'champagne_fine', 'gold_subtle', 'rose_shimmer'), 2, 2)
[AccessorySlicer]::SlicePairsGrid((Join-Path $root 'assets\cosmetics\eyeliner\eyeliner_style_atlas_v1.png'), $eyelinerOutputDirectory, 'eyeliner', [string[]]@('natural_thin', 'classic_cat', 'long_wing', 'short_round', 'double_graphic', 'dramatic_thick'), 3, 2)
[AccessorySlicer]::SlicePairsGrid((Join-Path $root 'assets\cosmetics\mascara\mascara_style_atlas_v1.png'), $mascaraOutputDirectory, 'mascara', [string[]]@('natural_defined', 'lengthening', 'volumizing', 'dramatic_fan'), 2, 2)
