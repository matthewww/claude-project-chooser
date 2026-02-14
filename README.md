# Agentic Project Chooser

[![Build and Test](https://github.com/matthewww/claude-project-chooser/actions/workflows/build.yml/badge.svg)](https://github.com/matthewww/claude-project-chooser/actions/workflows/build.yml)
[![Release](https://github.com/matthewww/claude-project-chooser/actions/workflows/release.yml/badge.svg)](https://github.com/matthewww/claude-project-chooser/actions/workflows/release.yml)

Quick access to your Claude and OpenCode projects with a unified CLI tool and Windows taskbar app.

## 🚀 Quick Start

```batch
jmp                          # Auto-detect (Claude → OpenCode)
jmp --claude                 # Claude projects only
jmp --opencode               # OpenCode projects
jmp --opencode --sessions    # OpenCode with session browser
```

## ✨ Features

- **Single Unified Tool** - Works with both Claude Code and OpenCode
- **Smart Auto-Detection** - Tries Claude first, falls back to OpenCode
- **Session Browsing** - Browse OpenCode session history with metadata
- **Fast & Cached** - 5-minute caching for instant project access
- **Keyboard Navigation** - Arrow keys to browse, Enter to launch
- **Terminal-Compatible** - ASCII arrows for universal terminal support

## 📋 Installation

### Option 1: Use Directly (Recommended)
```batch
.\jmp.bat
```

### Option 2: Add to PATH
```powershell
.\install.ps1
```
Then restart PowerShell and type `jmp` from anywhere.

## 🖥️ Windows Taskbar App

For the system tray application (one-click project access), see **[windows-app/README.md](windows-app/README.md)**.

## 🎮 Usage

### CLI Modes

| Mode | Command | Data Source |
|------|---------|-------------|
| Claude | `jmp --claude` | `~/.claude/projects/` |
| OpenCode | `jmp --opencode` | `~/.local/share/opencode/storage/project/` |
| Sessions | `jmp --opencode --sessions` | Projects + session history |

### Controls

- **↑/↓** - Navigate projects
- **Enter** - Launch project
- **R** - Refresh list
- **B** - Back (sessions mode)
- **Q/Esc** - Exit

## 📁 File Structure

```
├── choose-agentic-project.ps1  # Main CLI tool
├── jmp.bat                      # Launcher
├── install.ps1                  # Optional PATH installer
├── windows-app/                 # Windows taskbar app
│   ├── build.ps1               # Build script
│   ├── *.cs                    # C# source
│   └── README.md               # App docs
└── README.md                   # This file
```

## 🛠️ Troubleshooting

| Issue | Solution |
|-------|----------|
| "Projects directory not found" | Create a project in Claude Code or OpenCode |
| "No projects found" | Directory is empty - create at least one project |
| "Project path no longer exists" | Project folder was deleted - restore or remove from tool |
| Keyboard input not working | Use `pwsh` directly, not piped from another process |

## 📝 Requirements

- Windows 10+
- PowerShell 5.1 or PowerShell 7+
- Claude Code and/or OpenCode installed (depending on which you use)

## 🤝 Contributing

Contributions welcome! Areas:
- **CLI**: `choose-agentic-project.ps1`
- **Launcher**: `jmp.bat`
- **Windows App**: `windows-app/`

---

Made with ❤️ for faster project switching
