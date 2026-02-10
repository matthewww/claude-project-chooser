using System.Diagnostics;

namespace ClaudeProjectChooser;

/// <summary>
/// Handles launching Claude in a specific project directory
/// </summary>
public class ProjectLauncher
{
    /// <summary>
    /// Launches Claude in the specified project path
    /// </summary>
    public static void LaunchProject(string projectPath)
    {
        if (string.IsNullOrWhiteSpace(projectPath))
            throw new ArgumentException("Project path cannot be empty", nameof(projectPath));

        if (!Directory.Exists(projectPath))
            throw new DirectoryNotFoundException($"Project directory not found: {projectPath}");

        try
        {
            // Try pwsh first (PowerShell 7+), fall back to powershell.exe (Windows PowerShell)
            var pwshPath = FindPowerShell();
            
            var startInfo = new ProcessStartInfo
            {
                FileName = pwshPath,
                Arguments = $"-NoExit -Command \"Set-Location '{projectPath}'; claude\"",
                UseShellExecute = true,
                WindowStyle = ProcessWindowStyle.Normal
            };

            Process.Start(startInfo);
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Failed to launch Claude in {projectPath}", ex);
        }
    }

    private static string FindPowerShell()
    {
        // Try to find pwsh.exe first (PowerShell 7+)
        var pwshPaths = new[]
        {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "PowerShell", "7", "pwsh.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "PowerShell", "7-preview", "pwsh.exe"),
            "pwsh.exe" // Try PATH
        };

        foreach (var path in pwshPaths)
        {
            if (File.Exists(path) || TryFindInPath(path))
                return path;
        }

        // Fall back to Windows PowerShell
        var windowsPowerShell = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.System),
            "WindowsPowerShell", "v1.0", "powershell.exe"
        );

        if (File.Exists(windowsPowerShell))
            return windowsPowerShell;

        // Last resort: just use "powershell.exe" and hope it's in PATH
        return "powershell.exe";
    }

    private static bool TryFindInPath(string executable)
    {
        try
        {
            var process = Process.Start(new ProcessStartInfo
            {
                FileName = "where",
                Arguments = executable,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            });

            if (process != null)
            {
                process.WaitForExit(1000);
                return process.ExitCode == 0;
            }
        }
        catch
        {
            // Ignore errors
        }
        return false;
    }
}
