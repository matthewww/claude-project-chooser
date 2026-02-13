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
    private bool _showAllProjects = false;
    private const int RecentProjectLimit = 10;

    public TrayApplicationContext()
    {
        InitializeComponents();
    }

    private void InitializeComponents()
    {
        _projectManager = new ProjectManager();

        // Create context menu
        _contextMenu = new ContextMenuStrip
        {
            AutoSize = false,
            LayoutStyle = ToolStripLayoutStyle.VerticalStackWithOverflow,
            MaximumSize = new Size(720, 600),
            MinimumSize = new Size(420, 200),
            Size = new Size(420, 600)
        };

        _contextMenu.Opened += (s, e) => ScrollMenuToBottom();

        // Create tray icon
        _trayIcon = new NotifyIcon
        {
            Icon = GetTrayIcon(),
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
                
                // Show the context menu above the cursor so latest entries are visible at the bottom
                _contextMenu.Show(Cursor.Position, ToolStripDropDownDirection.AboveRight);
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

            if (projects.Count > RecentProjectLimit)
            {
                var toggleItemText = _showAllProjects
                    ? $"Show recent {RecentProjectLimit} only"
                    : $"Show all projects ({projects.Count})";

                var toggleItem = new ToolStripMenuItem(toggleItemText)
                {
                    Font = new Font(_contextMenu.Font, FontStyle.Italic)
                };
                toggleItem.Click += (s, e) =>
                {
                    _showAllProjects = !_showAllProjects;
                    BuildContextMenu();
                };
                _contextMenu.Items.Add(toggleItem);
            }

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

            _contextMenu.Items.Add(new ToolStripSeparator());

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
                var displayProjects = _showAllProjects
                    ? projects
                    : projects.TakeLast(RecentProjectLimit).ToList();

                foreach (var project in displayProjects)
                {
                    var projectItem = new ToolStripMenuItem(project.ToString())
                    {
                        Tag = project
                    };
                    projectItem.Click += OnProjectClick;
                    _contextMenu.Items.Add(projectItem);
                }
            }

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

        UpdateContextMenuSize();
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
        if (_trayIcon != null)
        {
            _trayIcon.Visible = false;
        }
        _trayIcon?.Dispose();
        _contextMenu?.Dispose();

        // Exit application
        Application.Exit();
    }

    private void UpdateContextMenuSize()
    {
        if (_contextMenu == null)
            return;

        var maxWidth = 0;
        var totalHeight = 0;
        foreach (ToolStripItem item in _contextMenu.Items)
        {
            var text = item.Text ?? string.Empty;
            var measured = TextRenderer.MeasureText(text, _contextMenu.Font);
            if (measured.Width > maxWidth)
            {
                maxWidth = measured.Width;
            }

            var preferred = item.GetPreferredSize(Size.Empty);
            totalHeight += preferred.Height;
        }

        totalHeight += _contextMenu.Padding.Vertical + 8;
        var workingArea = Screen.FromPoint(Cursor.Position).WorkingArea;
        var maxHeight = Math.Max(_contextMenu.MinimumSize.Height, workingArea.Height - 40);

        var targetWidth = Math.Clamp(maxWidth + 48, _contextMenu.MinimumSize.Width, _contextMenu.MaximumSize.Width);
        var targetHeight = Math.Clamp(totalHeight, _contextMenu.MinimumSize.Height, maxHeight);
        _contextMenu.Size = new Size(targetWidth, targetHeight);
    }

    private void ScrollMenuToBottom()
    {
        if (_contextMenu == null)
            return;

        if (!_contextMenu.IsHandleCreated)
            return;

        _contextMenu.BeginInvoke(() =>
        {
            if (_contextMenu.Items.Count > 0)
            {
                _contextMenu.Items[^1].Select();
            }

            var scroll = _contextMenu.VerticalScroll;
            if (scroll.Visible)
            {
                scroll.Value = scroll.Maximum;
            }
        });
    }

    private static Icon GetTrayIcon()
    {
        try
        {
            var appIcon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
            if (appIcon != null)
            {
                return appIcon;
            }
        }
        catch
        {
            // Fall back to default icon if extraction fails.
        }

        return SystemIcons.Application;
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
