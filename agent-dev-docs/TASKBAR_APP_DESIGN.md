# Windows Taskbar App Design

## Overview

Converting the Claude Project Chooser from a CLI tool to a Windows System Tray (taskbar) application that runs persistently in the background and provides quick access to Claude projects via a context menu.

## Architecture

### Technology Stack
- **Language**: C# / .NET 6+ (or .NET Framework 4.8 for broader compatibility)
- **UI Framework**: Windows Forms (lightweight and perfect for system tray apps)
- **Alternative**: WPF (if more advanced UI needed)

### Why C# over PowerShell?
1. Native Windows system tray support
2. Better performance for background applications
3. Easier to create installers and standalone executables
4. Can still call PowerShell scripts if needed for project discovery
5. Proper event-driven architecture for tray icons

## Core Components

### 1. System Tray Icon (`NotifyIcon`)
- **Icon**: Custom icon for Claude Project Chooser
- **Tooltip**: "Claude Project Chooser - Click for projects"
- **Context Menu**: Dynamic menu populated with projects
- **Double-click**: Show project list or settings

### 2. Project Manager Class
```csharp
public class ProjectManager
{
    private string projectsDir = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
        ".claude", "projects"
    );
    
    private string cacheFile = Path.Combine(
        Path.GetTempPath(),
        ".claude-projects-cache.txt"
    );
    
    private TimeSpan cacheMaxAge = TimeSpan.FromMinutes(5);
    
    public List<ClaudeProject> GetProjects(bool forceRefresh = false);
    public string GetActualProjectPath(string sessionFolder);
    public void LaunchProject(string projectPath);
}

public class ClaudeProject
{
    public string SessionName { get; set; }
    public string DisplayName { get; set; }
    public string FullPath { get; set; }
    public DateTime Modified { get; set; }
    public string RelativeTime { get; set; }
}
```

### 3. Main Application Form
```csharp
public class TrayApplicationContext : ApplicationContext
{
    private NotifyIcon trayIcon;
    private ProjectManager projectManager;
    private System.Windows.Forms.Timer refreshTimer;
    
    public TrayApplicationContext()
    {
        // Initialize tray icon
        // Setup context menu
        // Start refresh timer
    }
    
    private void BuildContextMenu();
    private void OnProjectClick(object sender, EventArgs e);
    private void OnRefreshClick(object sender, EventArgs e);
    private void OnExitClick(object sender, EventArgs e);
}
```

## User Interface Design

### System Tray Menu Structure
```
┌─────────────────────────────────────┐
│ 📁 Claude Project Chooser           │
├─────────────────────────────────────┤
│ ► C:\Dev\my-project (2m ago)        │
│ ► C:\Dev\another-app (15m ago)      │
│ ► C:\Code\website (1h ago)          │
│ ► [More projects...]                │
├─────────────────────────────────────┤
│ 🔄 Refresh Project List             │
│ ⚙️ Settings                         │
│ ℹ️ About                            │
├─────────────────────────────────────┤
│ ❌ Exit                             │
└─────────────────────────────────────┘
```

### Menu Behaviors
- **Project Items**: Click to launch Claude in that directory
- **Refresh**: Clear cache and reload project list
- **Settings**: Open settings dialog (optional)
- **About**: Show version info and GitHub link
- **Exit**: Close application

### Settings Dialog (Optional Phase 2)
```
┌─────────────────────────────────────┐
│ Claude Project Chooser Settings    │
├─────────────────────────────────────┤
│ ☑ Start with Windows                │
│ ☑ Auto-refresh project list         │
│   Refresh interval: [5] minutes     │
│ ☐ Show notifications on launch      │
│ ☐ Limit to [10] most recent         │
│                                     │
│ Projects Directory:                 │
│ [%USERPROFILE%\.claude\projects ]   │
│ [Browse...]                         │
│                                     │
│         [Save]     [Cancel]         │
└─────────────────────────────────────┘
```

## Implementation Phases

### Phase 1: Core Functionality (MVP)
1. Create C# Windows Forms project
2. Implement system tray icon
3. Port project discovery logic from PowerShell
4. Build dynamic context menu from projects
5. Implement project launching
6. Add cache mechanism

### Phase 2: Enhanced Features
1. Add settings dialog
2. Implement auto-start with Windows
3. Add notifications
4. Project search/filter in menu
5. Recent projects submenu
6. Custom icon support

### Phase 3: Polish & Distribution
1. Create installer (WiX or Inno Setup)
2. Add application icon and branding
3. Sign executable (optional)
4. Create MSI/EXE installer
5. Update documentation

## File Structure

```
claude-project-chooser/
├── src/
│   ├── ClaudeProjectChooser.csproj
│   ├── Program.cs
│   ├── TrayApplicationContext.cs
│   ├── ProjectManager.cs
│   ├── ClaudeProject.cs
│   ├── ProjectLauncher.cs
│   ├── Forms/
│   │   └── SettingsForm.cs (Phase 2)
│   ├── Resources/
│   │   └── icon.ico
│   └── app.manifest (for admin rights if needed)
├── installer/
│   └── setup.iss (Inno Setup script)
├── choose-claude-project.ps1 (keep for reference/fallback)
├── jmp.bat (keep for CLI users)
├── README.md
└── TASKBAR_APP_DESIGN.md (this file)
```

## Technical Considerations

### Project Discovery
Two approaches:
1. **Pure C# Implementation**: Read JSONL files directly in C#
   - Pros: Standalone, no PowerShell dependency
   - Cons: More code to maintain
   
2. **PowerShell Integration**: Call existing PS1 script
   - Pros: Reuse existing logic
   - Cons: PowerShell dependency
   
**Recommendation**: Pure C# for better performance and no dependencies

### Cache Management
- Store in `%TEMP%\.claude-projects-cache.json`
- JSON format for easy C# serialization
- Same 5-minute TTL as current implementation
- Background thread for cache updates

### Project Launching
```csharp
ProcessStartInfo startInfo = new ProcessStartInfo
{
    FileName = "pwsh.exe", // or powershell.exe
    Arguments = $"-NoExit -Command \"Set-Location '{projectPath}'; claude\"",
    UseShellExecute = true
};
Process.Start(startInfo);
```

### Error Handling
- Gracefully handle missing `.claude/projects` directory
- Show tray notification on errors
- Log to `%APPDATA%\ClaudeProjectChooser\logs\`
- Fallback to empty menu if no projects found

### Performance Optimization
- Lazy load projects on first menu open
- Background refresh timer (5 minutes)
- Don't block UI thread during refresh
- Cache menu items, rebuild only on refresh

## User Experience Enhancements

### Visual Feedback
- Show loading indicator while refreshing
- Highlight most recently used project
- Use different icons for different project types
- Animate tray icon during project launch

### Keyboard Shortcuts
- Global hotkey to show menu (optional)
- Number keys to quickly select projects (1-9)

### Notifications
- Toast notification when Claude launches
- Warning if project directory doesn't exist
- Update notification (future)

## Installation & Distribution

### Installer Features
1. One-click installation
2. Optional: Add to Windows startup
3. Optional: Create desktop shortcut
4. Automatic .NET runtime check
5. Uninstaller

### Installation Locations
- Program: `%ProgramFiles%\ClaudeProjectChooser\`
- User Data: `%APPDATA%\ClaudeProjectChooser\`
- Settings: `%APPDATA%\ClaudeProjectChooser\settings.json`
- Logs: `%APPDATA%\ClaudeProjectChooser\logs\`

## Backwards Compatibility

Keep CLI version for:
- Command-line users
- Automation/scripting
- Users who prefer terminal interface

Both can coexist:
- CLI: `jmp` command
- Taskbar: System tray icon

## Development Steps

### Step 1: Project Setup
```bash
dotnet new winforms -n ClaudeProjectChooser
cd ClaudeProjectChooser
# Add references
dotnet add package Newtonsoft.Json  # For JSON handling
```

### Step 2: Implement Core Classes
1. `ClaudeProject.cs` - Data model
2. `ProjectManager.cs` - Business logic
3. `ProjectLauncher.cs` - Launch functionality
4. `TrayApplicationContext.cs` - Main app

### Step 3: Test Locally
```bash
dotnet build
dotnet run
```

### Step 4: Create Installer
- Use Inno Setup or WiX Toolset
- Package with .NET runtime (self-contained)
- Or require .NET 6+ installation

### Step 5: Documentation
- Update README.md with taskbar app instructions
- Add screenshots
- Installation guide
- Troubleshooting section

## Configuration File Format

`%APPDATA%\ClaudeProjectChooser\settings.json`:
```json
{
  "projectsDirectory": "%USERPROFILE%\\.claude\\projects",
  "cacheMaxAgeMinutes": 5,
  "autoRefresh": true,
  "startWithWindows": false,
  "showNotifications": true,
  "maxRecentProjects": 20,
  "sortOrder": "modified-desc"
}
```

## Testing Plan

1. **Unit Tests**
   - Project discovery logic
   - Cache management
   - Path validation
   - Time formatting

2. **Integration Tests**
   - Menu building
   - Project launching
   - Settings persistence

3. **Manual Tests**
   - System tray icon visibility
   - Menu interaction
   - Multiple monitor support
   - Windows startup behavior

## Future Enhancements (Post-MVP)

1. **Project Groups/Favorites**
   - Pin favorite projects to top
   - Create project groups/categories
   
2. **Quick Actions**
   - Open in VS Code
   - Open in File Explorer
   - Copy path to clipboard
   
3. **Search & Filter**
   - Search box in menu
   - Filter by path/name
   - Recent projects view
   
4. **Sync & Backup**
   - Sync favorites across machines
   - Backup/restore settings
   
5. **Statistics**
   - Most used projects
   - Usage history
   - Time tracking

## Success Criteria

MVP is successful when:
- ✅ Application runs in system tray
- ✅ Projects list populates from `.claude/projects`
- ✅ Clicking project launches Claude in new window
- ✅ Cache works (5-minute TTL)
- ✅ Refresh works on demand
- ✅ No console window appears
- ✅ Can exit gracefully

## Comparison: CLI vs Taskbar App

| Feature | CLI (jmp) | Taskbar App |
|---------|-----------|-------------|
| Launch Method | Type `jmp` | Click tray icon |
| Visibility | Console window | System tray |
| Persistence | Runs on demand | Always running |
| Resource Usage | Only when running | Minimal background |
| Convenience | Requires terminal | Always accessible |
| Learning Curve | Know command | Visual/intuitive |
| Automation | Easy to script | GUI-focused |

Both approaches are valid for different use cases!

## Conclusion

The Windows taskbar app will provide a more integrated, always-available way to access Claude projects while maintaining the speed and efficiency of the current CLI tool. The phased approach ensures a working MVP quickly while leaving room for future enhancements.
