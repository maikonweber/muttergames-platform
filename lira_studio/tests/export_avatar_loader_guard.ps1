Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path -Parent $PSScriptRoot
$libraryPath = Join-Path $root 'scripts/data/content_library.gd'
$library = Get-Content -Raw $libraryPath
$loader = [regex]::Match($library, 'func _tex\(rel: String\) -> Texture2D:(.*?)(?=\nfunc )', 'Singleline').Groups[1].Value

if ($loader.IndexOf('var loaded := load(path)') -lt 0) {
    throw 'FAIL: _tex não tenta carregar o recurso importado.'
}
if ($loader.IndexOf('var loaded := load(path)') -gt $loader.IndexOf('FileAccess.file_exists(path)')) {
    throw 'FAIL: _tex testa o PNG bruto antes do recurso importado; isso falha no Android.'
}

$apkPath = Join-Path $root 'builds/android/lira_studio.apk'
if (Test-Path -LiteralPath $apkPath) {
    $apk = [System.IO.Compression.ZipFile]::OpenRead($apkPath)
    try {
        foreach ($number in 1..4) {
            $id = '{0:D2}' -f $number
            $found = $apk.Entries | Where-Object { $_.FullName -match "model_${id}_face_base_v2\.png-.*\.ctex$" }
            if (-not $found) { throw "FAIL: model_$id v2 não está empacotado na APK." }
        }
    } finally {
        $apk.Dispose()
    }
}

Write-Output 'OK: recursos v2 são carregáveis no Android e estão presentes na APK.'
