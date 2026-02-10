using System.Diagnostics;

namespace ClaudeProjectChooser;

/// <summary>
/// Main application context that manages the system tray icon and menu
/// </summary>
public class TrayApplicationContext : ApplicationContext
{
    private NotifyIcon? _trayIcon;
    private ContextMenuStrip? _contextMenu;
    private ProjectManager? _projectManager;
    private System.Windows.Forms.Timer? _refreshTimer;
    private bool _isRefreshing = false;

    public TrayApplicationContext()
    {
        InitializeComponents();
    }

    private void InitializeComponents()
    {
        _projectManager = new ProjectManager();

        // Create context menu
        _contextMenu = new ContextMenuStrip();

        // Create tray icon
        _trayIcon = new NotifyIcon
        {
            Icon = SystemIcons.Application, // We'll use a custom icon later
            Text = "Claude Project Chooser - Click to open",
            Visible = true,
            ContextMenuStrip = _contextMenu
        };

        // Handle left-click to show menu
        _trayIcon.MouseClick += (s, e) =>
        {
            if (e.Button == MouseButtons.Left)
            {
                // Rebuild menu and show it
                BuildContextMenu();
                
                // Show the context menu at cursor position
                var method = typeof(NotifyIcon).GetMethod("ShowContextMenu",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
                method?.Invoke(_trayIcon, null);
            }
        };

        // Setup auto-refresh timer (every 5 minutes)
        _refreshTimer = new System.Windows.Forms.Timer
        {
            Interval = 5 * 60 * 1000 // 5 minutes
        };
        _refreshTimer.Tick += (s, e) => BuildContextMenu();
        _refreshTimer.Start();

        // Build initial menu
        BuildContextMenu();
    }

    private void BuildContextMenu()
    {
        if (_contextMenu == null || _projectManager == null || _isRefreshing)
            return;

        _isRefreshing = true;

        try
        {
            _contextMenu.Items.Clear();

            // Header
            var headerItem = new ToolStripLabel("📁 Claude Project Chooser")
            {
                Font = new Font(_contextMenu.Font, FontStyle.Bold),
                ForeColor = Color.DarkBlue
            };
            _contextMenu.Items.Add(headerItem);
            _contextMenu.Items.Add(new ToolStripSeparator());

            // Get projects
            var projects = _projectManager.GetProjects();

            if (projects.Count == 0)
            {
                var noProjectsItem = new ToolStripMenuItem("No projects found")
                {
                    Enabled = false
                };
                _contextMenu.Items.Add(noProjectsItem);
            }
            else
            {
                // Limit to most recent 20 projects to avoid menu becoming too large
                var displayProjects = projects.TakeLast(20).Reverse().ToList();

                foreach (var project in displayProjects)
                {
                    var projectItem = new ToolStripMenuItem(project.ToString())
                    {
                        Tag = project,
                        ToolTipText = $"Launch Claude in:\n{project.FullPath}"
                    };
                    projectItem.Click += OnProjectClick;
                    _contextMenu.Items.Add(projectItem);
                }

                if (projects.Count > 20)
                {
                    var moreItem = new ToolStripMenuItem($"... and {projects.Count - 20} more projects")
                    {
                        Enabled = false,
                        Font = new Font(_contextMenu.Font, FontStyle.Italic)
                    };
                    _contextMenu.Items.Add(moreItem);
                }
            }

            // Separator before actions
            _contextMenu.Items.Add(new ToolStripSeparator());

            // Refresh button
            var refreshItem = new ToolStripMenuItem("🔄 Refresh Project List")
            {
                ShortcutKeyDisplayString = "R"
            };
            refreshItem.Click += OnRefreshClick;
            _contextMenu.Items.Add(refreshItem);

            // About button
            var aboutItem = new ToolStripMenuItem("ℹ️ About");
            aboutItem.Click += OnAboutClick;
            _contextMenu.Items.Add(aboutItem);

            // Separator before exit
            _contextMenu.Items.Add(new ToolStripSeparator());

            // Exit button
            var exitItem = new ToolStripMenuItem("❌ Exit");
            exitItem.Click += OnExitClick;
            _contextMenu.Items.Add(exitItem);
        }
        finally
        {
            _isRefreshing = false;
        }
    }

    private void OnProjectClick(object? sender, EventArgs e)
    {
        if (sender is not ToolStripMenuItem menuItem || menuItem.Tag is not ClaudeProject project)
            return;

        try
        {
            // Show notification
            _trayIcon?.ShowBalloonTip(2000, "Launching Claude",
                $"Opening {project.DisplayName}", ToolTipIcon.Info);

            // Launch the project
            ProjectLauncher.LaunchProject(project.FullPath);
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                $"Failed to launch project:\n\n{ex.Message}",
                "Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
        }
    }

    private void OnRefreshClick(object? sender, EventArgs e)
    {
        _projectManager?.ClearCache();
        _trayIcon?.ShowBalloonTip(1000, "Refreshing", "Updating project list...", ToolTipIcon.Info);
        BuildContextMenu();
    }

    private void OnAboutClick(object? sender, EventArgs e)
    {
        var version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;
        MessageBox.Show(
            $"Claude Project Chooser v{version}\n\n" +
            "A Windows system tray application for quick access to your Claude projects.\n\n" +
            "Original CLI version by matthewww\n" +
            "Taskbar version: 2.0\n\n" +
            "GitHub: github.com/matthewww/claude-project-chooser",
            "About Claude Project Chooser",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information
        );
    }

    private void OnExitClick(object? sender, EventArgs e)
    {
        // Cleanup
        _refreshTimer?.Stop();
        _refreshTimer?.Dispose();
        _trayIcon?.Visible = false;
        _trayIcon?.Dispose();
        _contextMenu?.Dispose();

        // Exit application
        Application.Exit();
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _refreshTimer?.Dispose();
            _trayIcon?.Dispose();
            _contextMenu?.Dispose();
        }
        base.Dispose(disposing);
    }
}
