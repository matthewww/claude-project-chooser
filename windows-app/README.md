# Claude Project Chooser - Windows Taskbar App

A Windows system tray application that provides quick access to your Claude projects. This is the 2.0 version that runs persistently in your system tray.

![System Tray App](../image.png)

## Features

- 🖥️ **System Tray Integration** - Runs quietly in your Windows taskbar
- ⚡ **Quick Access** - Click the tray icon to see your projects
- 📁 **Smart Discovery** - Automatically finds all your Claude projects
- ⏱️ **Recent Projects** - Shows projects sorted by last modified time
- 🔄 **Auto-refresh** - Updates project list every 5 minutes
- 💾 **Caching** - Fast performance with 5-minute cache
- 🚀 **One-Click Launch** - Launch Claude in any project instantly

## Installation

### Prerequisites

- Windows 10 or later
- .NET 8.0 Runtime or later ([Download here](https://dotnet.microsoft.com/download/dotnet/8.0))
- PowerShell (pre-installed on Windows)
- Claude CLI installed and accessible

### Option 1: Download Pre-built Release (Recommended)

1. Download the latest `ClaudeProjectChooser.exe` from the [Releases](https://github.com/matthewww/claude-project-chooser/releases) page
2. Place it in a permanent location (e.g., `C:\Program Files\ClaudeProjectChooser\`)
3. Double-click to run
4. (Optional) Add to Windows startup:
   - Press `Win + R`
   - Type `shell:startup`
   - Create a shortcut to `ClaudeProjectChooser.exe` in the Startup folder

### Option 2: Build from Source

1. Install [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
2. Clone this repository
3. Navigate to the windows-app directory:
   ```powershell
   cd windows-app
   ```
4. Build the application:
   ```powershell
   dotnet build -c Release
   ```
5. Run the application:
   ```powershell
   dotnet run -c Release
   ```
   Or find the executable in: `bin/Release/net8.0-windows/ClaudeProjectChooser.exe`

## Usage

### Starting the Application

Simply run `ClaudeProjectChooser.exe`. The application will:
1. Start minimized (no window appears)
2. Add an icon to your system tray (bottom-right of taskbar)
3. Begin monitoring your Claude projects

### Accessing Your Projects

**Left-click** the tray icon to open the project menu:
- Projects are listed newest first
- Each project shows its path and last modified time
- Click any project to launch Claude in that directory

### Menu Options

- **🔄 Refresh Project List** - Clear cache and reload projects immediately
- **ℹ️ About** - View application version and information
- **❌ Exit** - Close the application

### How It Works

The app:
1. Scans `~/.claude/projects` for session folders
2. Reads JSONL files to find actual project paths
3. Caches the list for 5 minutes for performance
4. Shows up to 20 most recent projects in the menu
5. Launches PowerShell in the selected project directory with `claude` command

## Configuration

### Projects Directory

By default, the app looks for projects in:
```
%USERPROFILE%\.claude\projects
```

### Cache

Project list is cached in:
```
%TEMP%\.claude-projects-cache.json
```

Cache expires after 5 minutes and can be refreshed manually via the menu.

## Comparison: CLI vs Taskbar App

| Feature | CLI (`jmp`) | Taskbar App |
|---------|-------------|-------------|
| **Access Method** | Type `jmp` in terminal | Click tray icon |
| **Always Available** | No | Yes |
| **Resource Usage** | None when not running | Minimal (~10MB RAM) |
| **Startup Time** | Instant | Persistent |
| **Best For** | Terminal users | GUI users |

Both versions work great - choose based on your workflow!

## Building an Installer (Advanced)

To create an installer using Inno Setup:

1. Install [Inno Setup](https://jrsoftware.org/isinfo.php)
2. Use the included `installer/setup.iss` script (to be created)
3. Build creates a `Setup.exe` installer

## Troubleshooting

### App doesn't appear in system tray
- Check Task Manager to see if it's running
- Look for it in the hidden icons area (click ^ in system tray)
- Try running as Administrator

### No projects appear in menu
- Verify Claude projects exist in `%USERPROFILE%\.claude\projects`
- Check that JSONL files contain `cwd` fields
- Try "Refresh Project List" from the menu

### Claude doesn't launch
- Ensure PowerShell is accessible (type `pwsh` or `powershell` in cmd)
- Verify `claude` command works in PowerShell
- Check project path is valid and accessible

### Multiple instances running
The app prevents multiple instances using a named mutex. If you see the "Already Running" message, check Task Manager.

## Uninstalling

1. Right-click the tray icon and select "Exit"
2. Delete the executable file
3. Remove from startup folder if added
4. (Optional) Delete cache file from `%TEMP%\.claude-projects-cache.json`

## Development

### Project Structure
```
windows-app/
├── Program.cs                    # Entry point
├── TrayApplicationContext.cs     # Main tray app logic
├── ProjectManager.cs             # Project discovery and caching
├── ProjectLauncher.cs            # Launches Claude in projects
├── ClaudeProject.cs              # Project data model
├── ClaudeProjectChooser.csproj   # Project configuration
└── Resources/
    └── icon.ico                  # Application icon
```

### Technologies Used
- .NET 8.0
- Windows Forms (System Tray support)
- Newtonsoft.Json (JSON parsing)

### Adding Features

To add features:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Version History

- **2.0.0** - Initial taskbar app release
  - System tray integration
  - Context menu with project list
  - Auto-refresh every 5 minutes
  - Balloon notifications
  - Single instance enforcement

- **1.0.0** - Original CLI version (`jmp` command)

## License

Same as the original CLI version. See main README.

## Credits

- Original CLI tool by matthewww
- Taskbar version: Modernization for GUI users

## Support

For issues or questions:
- Open an issue on [GitHub](https://github.com/matthewww/claude-project-chooser/issues)
- Check existing issues for solutions

---

**Note**: The original CLI version (`jmp`) is still available and fully functional. Both versions can coexist on the same system.
