$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$canvas = Get-Content -Raw (Join-Path $root 'scripts/makeup/makeup_canvas.gd')
$session = Get-Content -Raw (Join-Path $root 'scripts/makeup/makeup_session.gd')

function Assert-True([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}

# Pintar nao pode reconstruir os acessorios; isso cria/destrui Controls a cada
# movimento do ponteiro e e a causa direta de travamentos em dispositivos moveis.
$refreshLayers = [regex]::Match($canvas, 'func _refresh_layers\(\) -> void:(.*?)(?=\nfunc )', 'Singleline').Groups[1].Value
Assert-True (-not $refreshLayers.Contains('_refresh_accessories()')) 'FAIL: refresh de maquiagem ainda reconstrói acessórios.'

$stamp = [regex]::Match($canvas, 'func _stamp\(pixel: Vector2i\) -> void:(.*?)(?=\nfunc )', 'Singleline').Groups[1].Value
Assert-True (-not $stamp.Contains('layers_changed.emit')) 'FAIL: cada carimbo ainda emite refresh global.'

Assert-True ($session.Contains('func _queue_texture_sync')) 'FAIL: falta coalescer uploads de textura por frame.'
$sessionStamp = [regex]::Match($session, 'func stamp\((.*?)(?=\nfunc _character_coverage)', 'Singleline').Groups[1].Value
Assert-True ($sessionStamp.Contains('_queue_texture_sync(category)')) 'FAIL: pintura ainda atualiza a GPU por carimbo.'

Write-Output 'OK: orçamento de pintura — acessórios isolados e upload coalescido.'
