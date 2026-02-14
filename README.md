# Claude Project Chooser

[![Build and Test](https://github.com/matthewww/claude-project-chooser/actions/workflows/build.yml/badge.svg)](https://github.com/matthewww/claude-project-chooser/actions/workflows/build.yml)
[![Release](https://github.com/matthewww/claude-project-chooser/actions/workflows/release.yml/badge.svg)](https://github.com/matthewww/claude-project-chooser/actions/workflows/release.yml)
[![GitHub release](https://img.shields.io/github/v/release/matthewww/claude-project-chooser)](https://github.com/matthewww/claude-project-chooser/releases)

Quick access to your Claude Code projects and OpenCode sessions with one unified tool!

![jmp demo](./image.png)

## 🎯 Features

### 🚀 Agentic Project Chooser (Single Unified Script)
Interactive project browser with smart fallback, session browsing, and comprehensive error handling. Works with both Claude and OpenCode projects.

### 🖥️ Windows Taskbar App
A system tray application that sits in your Windows taskbar. Click the icon for instant access to your projects.

---

## 🚀 Agentic Project Chooser (choose-agentic-project.ps1)

### What Is It?
A single, consolidated PowerShell script that works with **both Claude and OpenCode** projects. Includes session browsing and smart auto-detection. Control behavior via command-line flags in `jmp.bat` and `jomp.bat`.

### Quick Start

```batch
jmp                          # Smart auto-detection (Claude → OpenCode)
jmp --claude                 # Claude projects (explicit)
jmp --opencode               # OpenCode projects
jmp --opencode --sessions    # OpenCode with session browser
jomp                         # OpenCode projects
jomp --sessions              # OpenCode with sessions
```

### Features
- 🔄 **Single Script, Multiple Modes** - No duplicate code, one unified implementation
- ⚙️ **Fully Configurable** - Control via batch file flags
- 📂 **Claude & OpenCode** - Works with both project types
- 📋 **Session Support** - Optional two-tier navigation for OpenCode sessions
- 🎯 **Smart Auto-Detection** - Automatically uses Claude if available, falls back to OpenCode (default mode)
- ⚡ **Fast Performance** - 5-minute caching for speed
- 🛡️ **Robust Error Handling** - Helpful guidance for missing directories, invalid paths, and more

### Configuration Examples

**jmp.bat** (main launcher - all options):
```batch
jmp [--claude|--opencode] [--sessions]
```

**jomp.bat** (OpenCode launcher - simplified):
```batch
jomp [--sessions]
```

### Full Documentation
See [CHOOSE_PROJECT_GUIDE.md](./CHOOSE_PROJECT_GUIDE.md) for detailed configuration, usage, and **error handling guidance**.

---

### What Is It?
An interactive PowerShell menu for navigating OpenCode projects and sessions directly from the command line. Integrates with OpenCode's local storage to display project metadata and session history.

### Features
- 📂 **Browse Projects** - View all OpenCode projects with modification timestamps
- 📋 **Browse Sessions** - See all sessions for a project with change statistics
- 🔍 **Session Details** - View titles, file changes (+/- counts)
- ⚡ **Quick Launch** - One key press to open project in Claude with session context
- 🔄 **Auto-refresh** - Updates automatically to show latest projects/sessions
- 🔎 **Search & Filter** - Find sessions by keywords

### Installation

```powershell
# Copy the scripts to your path or call directly
# Quick start:
.\choose-opencode-session.ps1
```

Or create a batch file wrapper:
```batch
@echo off
pwsh -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\path\to\choose-opencode-session.ps1'"
```

### Usage

#### Interactive Session Chooser
```powershell
.\choose-opencode-session.ps1
```

Navigation:
- **Up/Down arrows** - Move between projects/sessions
- **Enter** - Open selected project in Claude
- **B** - Go back to project list (when in sessions)
- **R** - Refresh project/session list
- **Esc/Q** - Exit

#### OpenCode Utility Script (CLI)
For non-interactive querying of OpenCode data:

```powershell
# List all projects
.\opencode-util.ps1

# List sessions for a project
.\opencode-util.ps1 list-sessions -ProjectName fpv-db

# Get project information with statistics
.\opencode-util.ps1 info -ProjectName fpv-db

# Show recent activity across all projects
.\opencode-util.ps1 recent

# Search sessions by title or slug
.\opencode-util.ps1 search -Filter "CI"

# Export data as JSON
.\opencode-util.ps1 list-projects -Json
```

### Data Source
- **Location:** `~/.local/share/opencode/storage/`
- **Projects:** `project/*.json` - Contains project metadata (path, VCS type, timestamps)
- **Sessions:** `session/<project-id>/*.json` - Contains session history with change tracking
- **Auto-detection:** Automatically finds OpenCode installation and project data

### Examples

```powershell
# Quick jump to a project
.\choose-opencode-session.ps1

# Find all sessions related to "bug"
.\opencode-util.ps1 search -Filter "bug"

# Export all project data
.\opencode-util.ps1 list-projects -Json | Out-File projects.json

# Get detailed stats for a specific project
.\opencode-util.ps1 info -ProjectName fpv-db
```

---

## 🖥️ Windows Taskbar App (v2.0)

### What Is It?
A persistent Windows application that runs in your system tray, providing one-click access to all your Claude projects.

### Features
- 🎯 **Always Accessible** - Lives in your system tray
- ⚡ **Instant Access** - Click to see all projects
- 🔄 **Auto-refresh** - Updates every 5 minutes
- 📊 **Smart Sorting** - Shows most recent projects first
- 🚀 **Quick Launch** - One click to open Claude in any project

### Installation

**Download Pre-built Release (Recommended):**
1. Go to [Releases](https://github.com/matthewww/claude-project-chooser/releases)
2. Download `ClaudeProjectChooser-X.X.X-win-x64.zip` (self-contained, no .NET required)
   - Or download `ClaudeProjectChooser-X.X.X-win-x64-framework.zip` (requires .NET 8.0 Runtime)
3. Extract the ZIP file
4. Run `ClaudeProjectChooser.exe`
5. Look for the icon in your system tray!

**Building from Source:**
1. Install [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
2. Run the build script:
   ```powershell
   .\build.ps1
   ```
3. Find the executable in `windows-app/bin/Release/net8.0-windows/`
4. Double-click to run!

**Optional - Auto-start with Windows:**
1. Press `Win + R`, type `shell:startup`
2. Create a shortcut to `ClaudeProjectChooser.exe` in the Startup folder

### Usage
- **Left-click** the tray icon to see your projects
- **Click a project** to launch Claude in that directory
- **Refresh** to reload the project list
- **Exit** from the menu when done

📖 **Full Documentation:** See [windows-app/README.md](windows-app/README.md) for detailed information.

---

## 📟 Command Line Tool (CLI)

### What It Does

- Lists all your Claude projects from `~/.claude/projects`
- Shows actual project paths (not the encoded session folder names)
- Navigate with arrow keys for easy selection
- Launches Claude Code in the selected project directory in a new PowerShell window
- Caches project list for 5 minutes for faster performance

### Installation

#### Quick Install (Recommended)

Run the installer script:

```powershell
.\install.ps1
```

This will:
1. Create `~/.claude/bin` directory
2. Copy `jmp.bat` and `choose-claude-project.ps1` to that location
3. Add `~/.claude/bin` to your user PATH
4. Provide instructions for the current session

Then restart PowerShell for the PATH changes to take effect.

#### Manual Installation (Alternative)

If you prefer to install manually:

1. Create the directory: `mkdir $env:USERPROFILE\.claude\bin`
2. Copy `jmp.bat` and `choose-claude-project.ps1` to that directory
3. Add `~/.claude/bin` to PATH (see options below)

##### Adding to PATH via PowerShell (Admin)
```powershell
$binDir = Join-Path $env:USERPROFILE ".claude\bin"
$path = [Environment]::GetEnvironmentVariable('Path', 'User')
$newPath = "$binDir;$path"
[Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
```

##### Adding to PATH via GUI
1. Press `Win + X`, select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", click "Edit" on `Path` (or create it if it doesn't exist)
5. Add a new entry: `%USERPROFILE%\.claude\bin`
6. Click OK and restart PowerShell

#### Verify Installation

After restarting PowerShell, run:

```powershell
jmp
```

You should see a menu of your projects with arrow key navigation.

### Usage

```powershell
jmp
```

Then:
- **Up/Down arrows** - Move selection highlight
- **Enter** - Launch Claude Code in that project in a new window
- **R** - Refresh the project list (clears cache)
- **Esc** - Exit the project picker

The tool will:
1. Open a new PowerShell window
2. Change to the project directory
3. Start `claude` session
4. Return to the picker menu so you can launch another project without restarting

This persistent menu lets you quickly switch between multiple projects.

---

## 🔍 How It Works

Both versions:
- Read project folders from `~/.claude/projects`
- Extract actual project paths from the `cwd` field in JSONL session files
- Sort by most recently modified
- Cache results for 5 minutes for better performance
- Launch Claude in a new PowerShell window at the selected project directory

## 📊 Comparison

| Feature | CLI (`jmp`) | Taskbar App |
|---------|-------------|-------------|
| **Launch Method** | Type `jmp` in terminal | Click tray icon |
| **Always Visible** | No | Yes (system tray) |
| **Resource Usage** | None when not running | ~10MB RAM |
| **Best For** | Terminal enthusiasts | GUI users |
| **Keyboard Focus** | Required | Not required |

## 📁 Repository Structure

```
claude-project-chooser/
├── choose-agentic-project.ps1  # Main unified script (all features)
├── jmp.bat                      # Main launcher with auto-detection
├── jomp.bat                     # OpenCode launcher
├── install.ps1                  # CLI installer for PATH setup
├── build.ps1                    # Taskbar app build script
├── windows-app/                 # Windows taskbar app
│   ├── ClaudeProjectChooser.csproj  # C# project
│   ├── Program.cs              # Main entry point
│   └── README.md               # Taskbar app docs
├── CHOOSE_PROJECT_GUIDE.md     # Detailed usage guide
└── README.md                   # This file
```

## 🚀 Quick Start

**Using the Agentic Project Chooser:**
```batch
jmp                          # Smart auto-detection
jmp --claude                 # Claude projects
jmp --opencode               # OpenCode projects
jmp --opencode --sessions    # OpenCode with sessions
```

**For Terminal Users (via PowerShell):**
```powershell
.\choose-agentic-project.ps1
```

**For GUI Users (Taskbar App):**
```powershell
.\build.ps1
# Then run: windows-app/bin/Release/net8.0-windows/ClaudeProjectChooser.exe
```

## 🤝 Contributing

Both the CLI and taskbar versions are open for contributions! 

- CLI improvements: Edit `choose-claude-project.ps1`
- Taskbar app: See `windows-app/`
- Design discussions: See `TASKBAR_APP_DESIGN.md`

## 📝 Notes

- Only shows projects that have valid `cwd` paths in their session data
- Projects without session data are automatically filtered out
- Both versions can run simultaneously without conflicts
