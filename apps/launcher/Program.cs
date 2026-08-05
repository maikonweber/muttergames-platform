using System.Diagnostics;
using System.IO.Compression;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text.Json;
using Microsoft.Win32;

namespace MutterGames.Launcher;

internal static class Program
{
    [STAThread]
    static void Main(string[] args)
    {
        ApplicationConfiguration.Initialize();
        Protocol.Register();
        Application.Run(new LauncherForm(Protocol.GameFromArguments(args)));
    }
}

internal sealed class LauncherForm : Form
{
    private const string DefaultApi = "http://localhost:3001/api/v1";
    private readonly HttpClient client = new();
    private readonly ComboBox games = new() { DropDownStyle = ComboBoxStyle.DropDownList };
    private readonly TextBox apiUrl = new() { Text = Environment.GetEnvironmentVariable("MUTTERGAMES_API_URL") ?? DefaultApi };
    private readonly Label description = new() { AutoSize = true, MaximumSize = new Size(540, 0) };
    private readonly Label state = new() { AutoSize = true, MaximumSize = new Size(540, 0) };
    private readonly Button action = new() { Text = "Instalar", AutoSize = true };
    private readonly ProgressBar progress = new() { Width = 540, Visible = false };
    private Catalog? catalog;
    private string? requestedGame;

    public LauncherForm(string? requestedGame)
    {
        this.requestedGame = requestedGame;
        Text = "MutterGames Launcher"; ClientSize = new Size(590, 360); FormBorderStyle = FormBorderStyle.FixedDialog; MaximizeBox = false;
        var title = new Label { Text = "MutterGames Launcher", Font = new Font(Font.FontFamily, 20, FontStyle.Bold), AutoSize = true };
        var refresh = new Button { Text = "Atualizar catálogo", AutoSize = true };
        var layout = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(24), ColumnCount = 1, RowCount = 8 };
        layout.Controls.Add(title); layout.Controls.Add(new Label { Text = "Servidor da plataforma", AutoSize = true }); layout.Controls.Add(apiUrl);
        layout.Controls.Add(refresh); layout.Controls.Add(games); layout.Controls.Add(description); layout.Controls.Add(state); layout.Controls.Add(progress); layout.Controls.Add(action);
        Controls.Add(layout);
        refresh.Click += async (_, _) => await LoadCatalog();
        games.SelectedIndexChanged += (_, _) => RenderGame();
        action.Click += async (_, _) => await InstallOrPlay();
        Shown += async (_, _) => await LoadCatalog();
    }

    private async Task LoadCatalog()
    {
        SetBusy(true, "Carregando catálogo…");
        try
        {
            var root = apiUrl.Text.Trim().TrimEnd('/');
            catalog = await client.GetFromJsonAsync<Catalog>($"{root}/launcher/catalog?platform=windows", JsonOptions);
            if (catalog?.Games is null) throw new InvalidOperationException("Catálogo inválido.");
            games.DataSource = catalog.Games;
            games.DisplayMember = nameof(Game.Name);
            if (requestedGame is not null)
            {
                var index = catalog.Games.FindIndex(game => game.Id == requestedGame);
                if (index >= 0) games.SelectedIndex = index;
                requestedGame = null;
            }
            RenderGame();
        }
        catch (Exception exception) { state.Text = $"Não foi possível conectar: {exception.Message}"; }
        finally { SetBusy(false); }
    }

    private void RenderGame()
    {
        if (games.SelectedItem is not Game game) return;
        description.Text = game.Description;
        var installed = InstalledRelease(game);
        if (game.Status != "available" || game.Release.DownloadUrl is null || game.Release.Sha256 is null || game.Release.ExecutablePath is null)
        {
            state.Text = "Esta release ainda não foi publicada."; action.Text = "Em breve"; action.Enabled = false; return;
        }
        action.Enabled = true;
        action.Text = installed == game.Release.Version ? "Jogar" : installed is null ? "Instalar" : "Atualizar";
        state.Text = installed is null ? $"Versão {game.Release.Version} disponível." : installed == game.Release.Version ? $"Instalado: versão {installed}." : $"Instalado: {installed}. Atualização {game.Release.Version} disponível.";
    }

    private async Task InstallOrPlay()
    {
        if (games.SelectedItem is not Game game || game.Release.ExecutablePath is null) return;
        if (InstalledRelease(game) == game.Release.Version) { Launch(game); return; }
        if (game.Release.DownloadUrl is null || game.Release.Sha256 is null) return;
        try
        {
            SetBusy(true, "Baixando release…"); progress.Visible = true; progress.Style = ProgressBarStyle.Marquee;
            var archive = Path.Combine(Path.GetTempPath(), $"muttergames-{game.Id}-{Guid.NewGuid():N}.zip");
            await using (var source = await client.GetStreamAsync(game.Release.DownloadUrl))
            await using (var target = File.Create(archive)) await source.CopyToAsync(target);
            await using var archiveStream = File.OpenRead(archive);
            var hash = Convert.ToHexString(await SHA256.HashDataAsync(archiveStream)).ToLowerInvariant();
            if (!CryptographicOperations.FixedTimeEquals(Convert.FromHexString(hash), Convert.FromHexString(game.Release.Sha256))) throw new InvalidDataException("A assinatura SHA-256 do pacote não confere.");
            var directory = InstallDirectory(game);
            var staging = directory + ".staging";
            if (Directory.Exists(staging)) Directory.Delete(staging, true);
            Directory.CreateDirectory(staging); ZipFile.ExtractToDirectory(archive, staging);
            var executable = SafeChildPath(staging, game.Release.ExecutablePath);
            if (!File.Exists(executable)) throw new InvalidDataException("O executável declarado não existe no pacote.");
            if (Directory.Exists(directory)) Directory.Delete(directory, true);
            Directory.Move(staging, directory);
            await File.WriteAllTextAsync(Path.Combine(directory, ".muttergames-release.json"), JsonSerializer.Serialize(new Installed { Version = game.Release.Version }));
            File.Delete(archive); state.Text = "Instalação concluída."; Launch(game);
        }
        catch (Exception exception) { state.Text = $"Falha na instalação: {exception.Message}"; }
        finally { progress.Visible = false; SetBusy(false); RenderGame(); }
    }

    private void Launch(Game game)
    {
        try { Process.Start(new ProcessStartInfo(SafeChildPath(InstallDirectory(game), game.Release.ExecutablePath!)) { UseShellExecute = true }); state.Text = "Jogo iniciado."; }
        catch (Exception exception) { state.Text = $"Não foi possível iniciar: {exception.Message}"; }
    }

    private string? InstalledRelease(Game game)
    {
        var marker = Path.Combine(InstallDirectory(game), ".muttergames-release.json");
        try { return File.Exists(marker) ? JsonSerializer.Deserialize<Installed>(File.ReadAllText(marker))?.Version : null; } catch { return null; }
    }
    private static string InstallDirectory(Game game) => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "MutterGames", "Games", game.Id);
    private static string SafeChildPath(string directory, string relative) { var path = Path.GetFullPath(Path.Combine(directory, relative)); var root = Path.GetFullPath(directory) + Path.DirectorySeparatorChar; if (!path.StartsWith(root, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Caminho inválido no manifesto."); return path; }
    private void SetBusy(bool busy, string? message = null) { action.Enabled = !busy && games.SelectedItem is Game; games.Enabled = !busy; if (message is not null) state.Text = message; }
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };
}

internal static class Protocol
{
    internal static void Register()
    {
        var executable = Environment.ProcessPath; if (string.IsNullOrWhiteSpace(executable)) return;
        using var key = Registry.CurrentUser.CreateSubKey("Software\\Classes\\muttergames");
        key?.SetValue("", "URL:MutterGames Protocol"); key?.SetValue("URL Protocol", "");
        using var command = key?.CreateSubKey("shell\\open\\command"); command?.SetValue("", $"\"{executable}\" \"%1\"");
    }
    internal static string? GameFromArguments(string[] args)
    {
        if (args.Length == 0 || !Uri.TryCreate(args[0], UriKind.Absolute, out var uri) || uri.Scheme != "muttergames" || uri.Host != "install") return null;
        var id = uri.AbsolutePath.Trim('/'); return id is "fallen-tactics" or "beat-up" ? id : null;
    }
}

internal sealed class Catalog { public List<Game> Games { get; set; } = []; }
internal sealed class Game { public string Id { get; set; } = ""; public string Name { get; set; } = ""; public string Description { get; set; } = ""; public string Status { get; set; } = ""; public Release Release { get; set; } = new(); }
internal sealed class Release { public string Version { get; set; } = ""; public string? DownloadUrl { get; set; } public string? Sha256 { get; set; } public string? ExecutablePath { get; set; } }
internal sealed class Installed { public string Version { get; set; } = ""; }
