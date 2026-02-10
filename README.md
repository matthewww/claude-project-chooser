# Claude Project Chooser

A PowerShell tool to quickly navigate to and launch Claude Code sessions in your projects.

![jmp demo](./image.png)

## What It Does

- Lists all your Claude projects from `~/.claude/projects`
- Shows actual project paths (not the encoded session folder names)
- Navigate with arrow keys for easy selection
- Launches Claude Code in the selected project directory in a new PowerShell window
- Caches project list for 5 minutes for faster performance

## Installation

### Quick Install (Recommended)

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

### Manual Installation (Alternative)

If you prefer to install manually:

1. Create the directory: `mkdir $env:USERPROFILE\.claude\bin`
2. Copy `jmp.bat` and `choose-claude-project.ps1` to that directory
3. Add `~/.claude/bin` to PATH (see options below)

#### Adding to PATH via PowerShell (Admin)
```powershell
$binDir = Join-Path $env:USERPROFILE ".claude\bin"
$path = [Environment]::GetEnvironmentVariable('Path', 'User')
$newPath = "$binDir;$path"
[Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
```

#### Adding to PATH via GUI
1. Press `Win + X`, select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", click "Edit" on `Path` (or create it if it doesn't exist)
5. Add a new entry: `%USERPROFILE%\.claude\bin`
6. Click OK and restart PowerShell

### Verify Installation

After restarting PowerShell, run:

```powershell
jmp
```

You should see a menu of your projects with arrow key navigation.

## Usage

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

## How It Works

- Reads project folders from `~/.claude/projects`
- Each folder contains Claude Code session data (JSONL files)
- Extracts actual project paths from the `cwd` field in session data
- Sorts by most recently modified (newest last)
- Caches results in `%TEMP%\.claude-projects-cache.txt` for 5 minutes

## Refreshing the Project List

The project list is cached for 5 minutes to improve performance. To refresh immediately:

**From the menu:** Press **R** to refresh the project list

**From PowerShell:**
```powershell
rm $env:TEMP\.claude-projects-cache.txt
```

## Files

- `install.ps1` - Automated installer script (recommended)
- `choose-claude-project.ps1` - Main script
- `jmp.bat` - Windows batch wrapper for easy command-line access

## Notes

- Only shows projects that have valid `cwd` paths in their session data
- Projects without session data are automatically filtered out
- The batch wrapper runs PowerShell with execution policy bypass for convenience
