# Agentic Project Chooser

Quick access to your Claude, OpenCode, and Copilot projects.

```bash
jmp
```

## Installation

```powershell
.\install.ps1
```

Or just run `jmp.bat` directly from the repo.

## Features

- Unified tool for Claude Code, OpenCode, and GitHub Copilot CLI projects
- Smart auto-detection (Claude → OpenCode → Copilot)
- Browse projects and select to launch
- Optional: Browse OpenCode session history

## Usage

```
jmp              # Smart auto-detection
jmp --claude     # Claude projects explicitly
jmp --opencode   # OpenCode projects
jmp --copilot    # Copilot projects
jmp --opencode --sessions  # OpenCode with session browser
```

## Windows Taskbar App

For a system tray application, see [windows-app/README.md](windows-app/README.md).

---

For more details, check [windows-app/README.md](windows-app/README.md) or run the script directly.
