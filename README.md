# Agentic Project Chooser

[![Build and Test](https://github.com/matthewww/agentic-project-chooser/actions/workflows/build.yml/badge.svg)](https://github.com/matthewww/agentic-project-chooser/actions/workflows/build.yml)
[![Release](https://github.com/matthewww/agentic-project-chooser/actions/workflows/release.yml/badge.svg)](https://github.com/matthewww/agentic-project-chooser/actions/workflows/release.yml)
[![GitHub release](https://img.shields.io/github/v/release/matthewww/agentic-project-chooser)](https://github.com/matthewww/agentic-project-chooser/releases)

Quick access to your Claude Code projects and OpenCode sessions with one unified tool!

![jmp demo](./image.png)

---

## 🚀 Quick Start

```batch
jmp                          # Smart auto-detection (Claude → OpenCode)
jmp --claude                 # Claude projects
jmp --opencode               # OpenCode projects
jmp --opencode --sessions    # OpenCode with session browser
```

---

## ✨ Features

### 🎯 Agentic Project Chooser
- **Single Script** - Unified PowerShell tool for both Claude and OpenCode
- **Smart Auto-Detection** - Automatically tries Claude first, falls back to OpenCode
- **Session Browsing** - Browse OpenCode session history with metadata
- **Fast & Cached** - 5-minute caching for instant access to project lists
- **Robust Error Handling** - Clear guidance when directories are missing
- **Keyboard Navigation** - Use arrow keys to browse, Enter to launch

### 🖥️ Windows Taskbar App
- Always-accessible system tray application
- One-click access to all projects
- Auto-refresh every 5 minutes
- Single click to launch Claude in any project

---

## 📋 Configuration

### Via Batch File

`jmp.bat` is your single launcher with all options:

```batch
jmp [--auto|--claude|--opencode] [--sessions]
```

| Flag | Description | Default |
|------|-------------|---------|
| `--auto` | Smart auto-detection | ✓ |
| `--claude` | Force Claude projects | Optional |
| `--opencode` | Force OpenCode projects | Optional |
| `--sessions` | Enable session browsing | Disabled |

### Via PowerShell

Call the script directly:

```powershell
.\choose-agentic-project.ps1 -Mode auto
.\choose-agentic-project.ps1 -Mode opencode -OpenCodeSessionMode sessions
```

---

## 🎮 Mode Details

### Claude Mode
- **Data Source**: `~/.claude/projects/`
- **Launches**: Claude Code
- **Features**: Project list with modification times, 5-min cache
- **Controls**: ↑/↓ navigate, Enter to launch, R to refresh, Esc to exit

### OpenCode Mode (Projects)
- **Data Source**: `~/.local/share/opencode/storage/project/`
- **Launches**: OpenCode
- **Features**: Project browser, one-step launch
- **Controls**: ↑/↓ navigate, Enter to launch, R to refresh, Q/Esc to exit

### OpenCode Mode (With Sessions)
- **Data Sources**: Projects + `~/.local/share/opencode/storage/session/<id>/`
- **Launches**: OpenCode
- **Features**: Two-tier navigation (Projects → Sessions), session metadata
- **Controls**: ↑/↓ navigate, Enter to select, B to go back, R to refresh, Q/Esc to exit

---

## 📁 Installation

### Option 1: Use Directly (Recommended)
Just run from the repository:
```batch
.\jmp.bat
```

### Option 2: Add to PATH
Run the installer to add to your PATH:
```powershell
.\install.ps1
```

Then restart PowerShell and use:
```batch
jmp
```

### Manual PATH Setup
Add the script directory to your user PATH:
```powershell
$binDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$path = [Environment]::GetEnvironmentVariable('Path', 'User')
[Environment]::SetEnvironmentVariable('Path', "$path;$binDir", 'User')
```

---

## 🛠️ Troubleshooting

### "Projects directory not found"
**Cause**: Missing Claude/OpenCode installation
**Solution**: 
- For Claude: Create a project in Claude Code
- For OpenCode: Install OpenCode and create a project
- The tool will provide specific instructions

### "No projects found"
**Cause**: Directory exists but is empty
**Solution**: Create at least one project in the respective tool

### "Project path no longer exists"
**Cause**: A project's folder was deleted
**Solution**: Delete the project from Claude/OpenCode or restore the folder

### Keyboard input not working
**Cause**: Non-interactive terminal
**Solution**: Use `pwsh` directly, not piped from another process

### Script execution errors
**Cause**: PowerShell execution policy blocked
**Solution**: The batch files bypass this, but if running scripts directly:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📁 File Structure

```
agentic-project-chooser/
├── choose-agentic-project.ps1  # Main unified script (all features)
├── jmp.bat                      # Single launcher
├── install.ps1                  # Optional PATH installer
├── build.ps1                    # Taskbar app build
├── windows-app/                 # Windows taskbar app source
│   ├── ClaudeProjectChooser.csproj
│   ├── Program.cs
│   └── README.md
└── README.md                    # This file
```

---

## 🖥️ Windows Taskbar App

### Installation

**Pre-built Release (Recommended):**
1. Go to [Releases](https://github.com/matthewww/agentic-project-chooser/releases)
2. Download `ClaudeProjectChooser-X.X.X-win-x64.zip`
3. Extract and run `ClaudeProjectChooser.exe`

**Build from Source:**
```powershell
.\build.ps1
# Run: windows-app/bin/Release/net8.0-windows/ClaudeProjectChooser.exe
```

### Usage
- **Left-click** tray icon to see projects
- **Click project** to launch Claude
- **Right-click** for refresh/exit options

For details, see [windows-app/README.md](windows-app/README.md)

---

## 🎯 Custom Shortcuts

Create quick-access batch files:

**claude-projects.bat**
```batch
@echo off
call "%~dp0jmp.bat" --claude
```

**opencode-with-sessions.bat**
```batch
@echo off
call "%~dp0jmp.bat" --opencode --sessions
```

---

## 🤝 Contributing

Contributions welcome! Areas for improvement:
- Core script: `choose-agentic-project.ps1`
- Launcher: `jmp.bat`
- Taskbar app: `windows-app/`

---

## 📝 Version Information

- **Version**: 2.0 (Consolidated)
- **Tested with**:
  - Windows PowerShell 5.1
  - PowerShell 7.0+
  - OpenCode 1.1.53
  - Claude Code (latest)

---

## 📖 Performance

| Metric | Value |
|--------|-------|
| First load | ~1-2 seconds |
| Cached load | <100ms |
| Cache lifetime | 5 minutes |
| Memory usage | ~5MB |

---

## 🐛 Issues?

- Check the error message - the script provides helpful guidance
- Verify your Claude/OpenCode installation
- Review the Troubleshooting section above
- Open an issue on GitHub with details

---

Made with ❤️ for faster project switching on Windows
