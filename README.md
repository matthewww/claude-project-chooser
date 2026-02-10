# Claude Project Chooser

Quick access to your Claude Code projects - available in two flavors!

![jmp demo](./image.png)

## 🎯 Two Ways to Use

### 1️⃣ Command Line (CLI) - `jmp` Command
A PowerShell tool for terminal users. Type `jmp` to get an interactive menu.

### 2️⃣ Windows Taskbar App (NEW! 🎉)
A system tray application that sits in your Windows taskbar. Click the icon for instant access to your projects.

**Choose the version that fits your workflow!** Both can be installed side-by-side.

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

**Prerequisites:**
- Windows 10 or later
- [.NET 8.0 Runtime](https://dotnet.microsoft.com/download/dotnet/8.0) or later

**Building from Source:**
1. Install [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
2. Run the build script:
   ```powershell
   .\build.ps1
   ```
3. Find the executable in `src/ClaudeProjectChooser/bin/Release/net8.0-windows/`
4. Double-click to run!

**Optional - Auto-start with Windows:**
1. Press `Win + R`, type `shell:startup`
2. Create a shortcut to `ClaudeProjectChooser.exe` in the Startup folder

### Usage
- **Left-click** the tray icon to see your projects
- **Click a project** to launch Claude in that directory
- **Refresh** to reload the project list
- **Exit** from the menu when done

📖 **Full Documentation:** See [src/README.md](src/README.md) for detailed information.

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
├── choose-claude-project.ps1  # CLI script
├── jmp.bat                     # CLI wrapper
├── install.ps1                 # CLI installer
├── build.ps1                   # Taskbar app build script
├── src/                        # Taskbar app source code
│   ├── ClaudeProjectChooser/   # C# project
│   └── README.md               # Taskbar app docs
├── TASKBAR_APP_DESIGN.md       # Design documentation
└── README.md                   # This file
```

## 🚀 Quick Start

**For Terminal Users:**
```powershell
.\install.ps1
jmp
```

**For GUI Users:**
```powershell
.\build.ps1
# Then run: src/ClaudeProjectChooser/bin/Release/net8.0-windows/ClaudeProjectChooser.exe
```

## 🤝 Contributing

Both the CLI and taskbar versions are open for contributions! 

- CLI improvements: Edit `choose-claude-project.ps1`
- Taskbar app: See `src/ClaudeProjectChooser/`
- Design discussions: See `TASKBAR_APP_DESIGN.md`

## 📝 Notes

- Only shows projects that have valid `cwd` paths in their session data
- Projects without session data are automatically filtered out
- Both versions can run simultaneously without conflicts
