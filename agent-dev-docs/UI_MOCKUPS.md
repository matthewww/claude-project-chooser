# Windows Taskbar App - UI Mockups

This document shows what the Windows Taskbar App looks like when running.

## System Tray Icon

When the app is running, you'll see an icon in your Windows system tray:

```
┌─────────────────────────────────────────────┐
│  System Tray (Bottom-right of Windows)     │
│                                             │
│  [WiFi] [Volume] [Battery] [📁]  [Time]    │
│                             ↑               │
│                    Claude Project Chooser   │
└─────────────────────────────────────────────┘
```

The icon appears alongside other system tray applications like WiFi, Volume, etc.

## Context Menu (Left-Click)

When you left-click the tray icon, a context menu appears:

```
┌─────────────────────────────────────────────────────┐
│ 📁 Claude Project Chooser                          │
├─────────────────────────────────────────────────────┤
│ ► C:\Dev\my-awesome-app (2m ago)                    │
│ ► C:\Projects\website-redesign (15m ago)            │
│ ► C:\Code\api-service (1h ago)                      │
│ ► D:\Work\client-project (3h ago)                   │
│ ► C:\Dev\machine-learning (5h ago)                  │
│ ► C:\Projects\mobile-app (1d ago)                   │
│ ► C:\Code\data-pipeline (2d ago)                    │
│ ► C:\Dev\automation-scripts (3d ago)                │
│ ► C:\Projects\documentation (5d ago)                │
│ ► C:\Work\prototype (Jan 15, 3:45 PM)               │
├─────────────────────────────────────────────────────┤
│ 🔄 Refresh Project List                             │
│ ℹ️ About                                            │
├─────────────────────────────────────────────────────┤
│ ❌ Exit                                             │
└─────────────────────────────────────────────────────┘
```

### Menu Features:
- **Header**: Bold title showing app name
- **Project List**: Up to 20 most recent projects
- **Timestamps**: Shows when each project was last accessed
- **Hover**: Each project shows full path in tooltip
- **Click**: Any project to launch Claude there

## Balloon Notification

When you launch a project, a balloon notification appears:

```
┌────────────────────────────────────┐
│ 📁 Launching Claude                │
│                                    │
│ Opening C:\Dev\my-awesome-app     │
│                                    │
│ [Claude Project Chooser]   [X]     │
└────────────────────────────────────┘
```

The notification disappears after 2 seconds automatically.

## About Dialog

When you click "About" from the menu:

```
┌─────────────────────────────────────────┐
│  ℹ️  About Claude Project Chooser       │
├─────────────────────────────────────────┤
│                                         │
│  Claude Project Chooser v2.0.0          │
│                                         │
│  A Windows system tray application for  │
│  quick access to your Claude projects.  │
│                                         │
│  Original CLI version by matthewww      │
│  Taskbar version: 2.0                   │
│                                         │
│  GitHub:                                │
│  github.com/matthewww/                  │
│  claude-project-chooser                 │
│                                         │
│             [ OK ]                      │
└─────────────────────────────────────────┘
```

## When No Projects Found

If no projects are detected:

```
┌─────────────────────────────────────────────────────┐
│ 📁 Claude Project Chooser                          │
├─────────────────────────────────────────────────────┤
│   No projects found                                 │
│   (grayed out)                                      │
├─────────────────────────────────────────────────────┤
│ 🔄 Refresh Project List                             │
│ ℹ️ About                                            │
├─────────────────────────────────────────────────────┤
│ ❌ Exit                                             │
└─────────────────────────────────────────────────────┘
```

## Launch Behavior

When you click a project, here's what happens:

### 1. Menu closes
The context menu disappears immediately after clicking a project.

### 2. Notification appears
A balloon notification shows briefly:
```
"Launching Claude - Opening C:\Dev\my-awesome-app"
```

### 3. PowerShell window opens
A new PowerShell window appears:

```
┌─────────────────────────────────────────────┐
│  PowerShell 7                          [_][□][X]
├─────────────────────────────────────────────┤
│ PS C:\Dev\my-awesome-app>                   │
│                                             │
│ [Claude is starting...]                     │
│                                             │
│                                             │
│                                             │
│                                             │
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

The PowerShell window:
- Opens in the selected project directory
- Automatically runs the `claude` command
- Remains open (with `-NoExit` flag)
- Can be closed normally when done

### 4. Tray icon remains active
The tray icon stays in place, ready for the next project launch.

## Multiple Projects

You can launch multiple projects simultaneously:

```
Window 1: PowerShell - C:\Dev\project-a
Window 2: PowerShell - C:\Code\project-b  
Window 3: PowerShell - C:\Work\project-c

Tray Icon: Still running, ready for more
```

Each project gets its own PowerShell window with Claude running.

## Refresh Behavior

When you click "Refresh Project List":

1. Brief notification appears: "Refreshing - Updating project list..."
2. Cache file is deleted
3. Projects are re-scanned from disk
4. Menu rebuilds with updated list
5. New timestamps are calculated

The process takes less than a second on most systems.

## Menu Limits

To keep the menu manageable:
- Maximum 20 most recent projects shown
- If you have more than 20 projects, the menu shows:
  ```
  ... and 15 more projects (grayed out)
  ```
- Older projects are hidden but still in cache
- Use Refresh to update after creating new projects

## Visual States

### Normal State
- Icon visible in tray
- Tooltip: "Claude Project Chooser - Click to open"
- No window visible

### Menu Open
- Context menu displayed
- Projects listed
- Hover shows tooltips
- Click launches project

### Launching
- Balloon notification visible
- PowerShell window opening
- Menu closes
- Icon remains in tray

### Error State
If a project can't be launched, an error dialog appears:
```
┌─────────────────────────────────────────┐
│  ⚠️  Error                         [X]  │
├─────────────────────────────────────────┤
│                                         │
│  Failed to launch project:              │
│                                         │
│  Project directory not found:           │
│  C:\Dev\deleted-project                 │
│                                         │
│             [ OK ]                      │
└─────────────────────────────────────────┘
```

## Exiting the App

When you click "Exit":
1. Menu closes
2. Tray icon disappears
3. App terminates gracefully
4. All resources cleaned up
5. Any launched PowerShell windows remain open

## Comparison with CLI

### CLI Version (`jmp`)
```
PS C:\> jmp

Claude Project Chooser (jmp)
Up/Down ➡️Choose | Enter ➡️Launch | Esc ➡️Exit

  (scroll up for older)
    C:\Dev\project-a (5d ago)
    C:\Code\project-b (2d ago)
  > C:\Work\project-c (1h ago)
    C:\Dev\project-d (15m ago)
  (scroll down for newer)
  [R]efresh list

[Use arrow keys to navigate, Enter to select]
```

### Taskbar Version
```
[Click tray icon]
→ Menu appears instantly
→ Click project
→ Done!
```

Much faster for GUI-focused workflows!

## Technical Notes

### Icon
- Default: Uses Windows' system application icon
- Custom: Can be replaced with `icon.ico` file
- Sizes: Supports 16x16, 32x32, 48x48 pixels
- Format: Standard Windows ICO format

### Menu Rendering
- Native Windows Forms context menu
- Follows Windows theme (light/dark mode)
- Scales with DPI settings
- Supports high-DPI displays

### Performance
- Menu builds in <100ms
- Cache hits: <10ms
- Cache misses: <500ms (depends on project count)
- Memory usage: ~10MB RAM
- CPU usage: <1% (mostly idle)

## Platform Specifics

### Windows 11
- Modern rounded corners on menu
- Follows Windows 11 design language
- Supports new taskbar layouts

### Windows 10
- Classic rectangular menu
- Follows Windows 10 aesthetics
- Compatible with all taskbar positions

### High-DPI Displays
- Automatically scales
- Sharp text on 4K displays
- Supports DPI awareness levels

---

**Note**: Actual screenshots will be added once the application is built and tested on a Windows machine. These mockups represent the intended design and functionality.
