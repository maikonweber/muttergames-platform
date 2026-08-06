# MutterGames Launcher (Windows)

Cliente desktop que lê `GET /api/v1/launcher/catalog?platform=windows`, instala releases ZIP verificadas por SHA-256, atualiza quando a versão muda e abre o executável configurado. Os jogos são instalados em `%LOCALAPPDATA%\MutterGames\Games`.

**Spec detalhada:** [`Ecosystem/tools/03-launcher-spec.md`](../../Ecosystem/tools/03-launcher-spec.md) · Projeto: [`Ecosystem/projects/03-launcher.md`](../../Ecosystem/projects/03-launcher.md)

## Gerar o .exe

Instale o [.NET SDK 8](https://dotnet.microsoft.com/download/dotnet/8.0) e execute na raiz:

```powershell
dotnet publish apps/launcher/MutterGames.Launcher.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o outputs/launcher/win-x64
```

Publique `outputs/launcher/win-x64/MutterGames.Launcher.exe` e defina sua URL em `LAUNCHER_DOWNLOAD_URL`. Na primeira abertura ele registra o protocolo `muttergames://`, usado pelo portal para encaminhar a instalação de um jogo.

## Publicar uma release

Exporte cada jogo Godot para Windows, compacte os arquivos exportados em um ZIP e hospede-o por HTTPS. Configure `*_DOWNLOAD_URL`, `*_SHA256` e `*_EXECUTABLE_PATH` no ambiente da API. Enquanto qualquer um deles estiver ausente, a release não aparece como instalável. O arquivo declarado em `*_EXECUTABLE_PATH` deve estar dentro do ZIP. Gere o hash com:

```powershell
(Get-FileHash .\FallenTactics.zip -Algorithm SHA256).Hash.ToLower()
```
