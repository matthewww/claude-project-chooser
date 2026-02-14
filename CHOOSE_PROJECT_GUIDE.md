# Unified Project Chooser (choose-project.ps1)

A versatile, configurable PowerShell script that works with both **Claude Projects** and **OpenCode Projects & Sessions**. Configure your launcher with simple command-line flags.

## Overview

`choose-project.ps1` is a unified project browser that automatically adapts to your chosen mode:

- **Claude Mode**: Browse your Claude Code projects from `~/.claude/projects`
- **OpenCode Mode**: Browse OpenCode projects from `~/.local/share/opencode/storage`
- **OpenCode Session Mode**: Browse OpenCode projects and their session history

## Quick Start

### Default (Claude Projects)
```batch
jmp
```

### OpenCode Projects
```batch
jmp --opencode
```

### OpenCode with Sessions
```batch
jmp --opencode --sessions
```

### Auto-Detection Mode (Smart Fallback)
```batch
jmp --auto
```

The script automatically detects which tools are available and uses them in this order:
1. **Claude Projects** - If `~/.claude/projects` exists
2. **OpenCode Projects** - If Claude isn't available but OpenCode is found
3. **Combined Setup Guidance** - If neither tool is found (helps you get started)

This is also the **default behavior when no mode is specified**.

## Configuration

### Via Batch Files

Both `jmp.bat` and `jomp.bat` are fully configurable using command-line flags.

**jmp.bat** (Unified Launcher)
```batch
jmp [--claude|--opencode] [--sessions]
```

**jomp.bat** (OpenCode-Focused)
```batch
jomp [--sessions]
```

### Flags Explained

| Flag | Description | Default |
|------|-------------|---------|
| `--claude` | Use Claude project browser | ✓ (jmp only) |
| `--opencode` | Use OpenCode project browser | ✗ (for jomp) |
| `--sessions` | Enable session browsing for OpenCode | Disabled |

## Usage Examples

### Example 1: Browse Claude Projects
```batch
jmp
jmp --claude
```
Both open the Claude project selector.

### Example 2: Browse OpenCode Projects Only
```batch
jmp --opencode
```
Displays all OpenCode projects, opens directly without session selection.

### Example 3: Browse OpenCode with Sessions
```batch
jmp --opencode --sessions
jomp --sessions
```
Displays projects first, allows selecting a project to view its sessions.

### Example 4: Create Custom Shortcuts

Create batch files for quick access:

**open-claude.bat**
```batch
@echo off
call jmp --claude
```

**open-opencode.bat**
```batch
@echo off
call jmp --opencode --sessions
```

## Mode Details

### Claude Mode

**Data Source**: `~/.claude/projects/`

**Features**:
- Lists all Claude Code projects
- Extracts actual working directory from JSONL session files
- Shows relative modification times
- Direct project launch on selection
- 5-minute cache for performance

**Keyboard Controls**:
- ↑/↓: Navigate projects
- Enter: Open project
- R: Refresh list
- Esc: Exit

### OpenCode Mode (Projects)

**Data Source**: `~/.local/share/opencode/storage/project/`

**Features**:
- Lists all OpenCode projects with metadata
- Shows project folder names and paths
- Displays relative modification times
- One-step project launch
- 5-minute cache for performance

**Keyboard Controls**:
- ↑/↓: Navigate projects
- Enter: Open project
- R: Refresh list
- Q/Esc: Exit

### OpenCode Mode (With Sessions)

**Data Sources**: 
- Projects: `~/.local/share/opencode/storage/project/`
- Sessions: `~/.local/share/opencode/storage/session/<project-id>/`

**Features**:
- Two-tier navigation: Projects → Sessions
- Shows file change statistics (+/- counts)
- Session titles and creation timestamps
- Browse full session history before opening
- Back navigation to return to projects
- 5-minute cache for projects

**Keyboard Controls**:
- ↑/↓: Navigate items
- Enter: Select item / Open project
- B: Back to projects (sessions view only)
- R: Refresh list
- Q/Esc: Exit

## Technical Details

### Parameters

```powershell
.\choose-project.ps1 [-Mode <auto|claude|opencode>] [-OpenCodeSessionMode <projects|sessions>]
```

| Parameter | Values | Default |
|-----------|--------|---------|
| `-Mode` | `auto`, `claude`, `opencode` | `auto` |
| `-OpenCodeSessionMode` | `projects`, `sessions` | `projects` |

**Mode Details:**
- `auto` (Default): Smart detection - tries Claude first, falls back to OpenCode, shows combined setup guidance if neither found
- `claude`: Explicitly use Claude projects browser
- `opencode`: Explicitly use OpenCode projects browser

### Examples

```powershell
# Auto-detection (default - tries Claude first, then OpenCode)
.\choose-project.ps1

# Explicit auto-mode
.\choose-project.ps1 -Mode auto

# Claude projects
.\choose-project.ps1 -Mode claude

# OpenCode projects only
.\choose-project.ps1 -Mode opencode

# OpenCode with sessions
.\choose-project.ps1 -Mode opencode -OpenCodeSessionMode sessions
```

### Performance Characteristics

| Aspect | Value |
|--------|-------|
| First load time | ~1-2 seconds |
| Cached load time | <100ms |
| Cache lifetime | 5 minutes |
| Memory usage | ~5MB |
| Max projects | No limit |
| Max sessions per project | No limit |

## File Structure

```
choose-project.ps1         # Unified script (380+ lines with error handling)
jmp.bat                    # Claude launcher (configurable)
jomp.bat                   # OpenCode launcher (configurable)
choose-claude-project.ps1  # Original Claude tool (still available)
choose-opencode-session.ps1# Original OpenCode tool (still available)
opencode-util.ps1          # CLI utility (still available)
```

## Advanced Usage

### Batch Script Integration

Add to PowerShell profile (`$PROFILE`):

```powershell
function jmp { & 'C:\path\to\jmp.bat' @args }
function jomp { & 'C:\path\to\jomp.bat' @args }
```

Then use directly:
```powershell
jmp --opencode --sessions
```

### Scripted Project Selection

```powershell
# Get list of OpenCode projects programmatically
# (Use opencode-util.ps1 for this)
.\opencode-util.ps1 list-projects -Json | ConvertFrom-Json
```

### Custom Launchers

**Switch between modes easily**:

```batch
@echo off
REM quick-opencode.bat - Opens OpenCode with sessions
call "%~dp0jmp.bat" --opencode --sessions
```

## Error Handling

The unified project chooser includes comprehensive error handling with helpful guidance for common issues:

### Directory Not Found Errors

When a required data directory doesn't exist, the tool displays mode-specific instructions:

**Claude Mode Example:**
```
❌ ERROR: claude projects directory not found

Expected location: C:\Users\YourName\.claude\projects

To use Claude Project Chooser:
  1. Install Claude Code (if not already installed)
  2. Create or open a project in Claude Code
  3. This will create the .claude/projects directory
  4. Run this tool again

Need help? Visit: https://claude.ai
```

**OpenCode Mode Example:**
```
❌ ERROR: opencode projects directory not found

Expected location: C:\Users\YourName\.local\share\opencode\storage\project

To use OpenCode Project Chooser:
  1. Install OpenCode (https://opencode.ai)
  2. Create or open a project in OpenCode
  3. This will create the .local/share/opencode directory
  4. Run this tool again

Directory that would be created:
    C:\Users\YourName\.local\share\opencode\storage\project
```

### No Projects Found

When the directory exists but contains no projects:

```
⚠️  No projects found

Looking in: C:\Users\YourName\.local\share\opencode\storage\project

The directory exists but contains no projects.

To add projects:
  1. Open OpenCode
  2. Create or browse to a project directory
  3. Run this tool again
```

### Invalid Project Paths

If a project's path becomes invalid or inaccessible:

```
Warning: Project path no longer exists: C:\some\deleted\path

This project path no longer exists.
You may need to remove it from your projects or verify the location.
```

The tool automatically filters out invalid projects and displays warnings without crashing.

### Error Recovery

The script provides graceful recovery for various error scenarios:

- **Corrupt cache files**: Automatically detected and replaced on next run
- **File read errors**: Warnings displayed, valid projects still loaded
- **Missing session data**: Sessions gracefully skipped with warnings
- **Access permission errors**: Handled with informative messages

## Troubleshooting

### "Projects directory not found"
**Cause**: The required data directory doesn't exist  
**Solution**: 
- For Claude: Create a Claude Code project first
- For OpenCode: Install and initialize OpenCode
- The tool will provide specific instructions when run

### "No projects found"
**Cause**: No projects exist in the data directory  
**Solution**: 
- Create at least one project in the respective tool
- The tool will guide you with the exact directory to check
- Run the tool again after creating projects

### "Project path no longer exists" warnings
**Cause**: A project's path was deleted or moved  
**Solution**: 
- The project metadata still exists but the directory is inaccessible
- Remove the project from Claude/OpenCode, or restore the directory
- Refresh the project list (R key) to reload data

### Script execution errors
**Cause**: PowerShell execution policy blocked  
**Solution**: The batch files use `-ExecutionPolicy Bypass` already; if still blocked, try:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Keyboard input not working
**Cause**: Running in non-interactive terminal  
**Solution**: Use `pwsh` directly in a terminal, not from a piped context

### "Cannot read keys" errors in CI/CD environments
**Cause**: Script requires interactive console input which is unavailable  
**Solution**: These tools are designed for interactive use. For CI/CD automation, use `opencode-util.ps1` instead:
```powershell
.\opencode-util.ps1 list-projects -Json
```

## Backward Compatibility

All original tools remain available and fully functional:
- `choose-claude-project.ps1` - Original Claude chooser
- `choose-opencode-session.ps1` - Original OpenCode chooser  
- `opencode-util.ps1` - OpenCode CLI utility
- `install.ps1` - Original CLI installer

The unified `choose-project.ps1` provides a modern alternative while maintaining the original scripts.

## Version Information

- **Version**: 1.0
- **Created**: February 12, 2026
- **Tested with**:
  - Windows PowerShell 5.1
  - PowerShell 7.0+
  - OpenCode 1.1.53
  - Claude Code (latest)

## Related Tools

- **opencode-util.ps1** - Non-interactive CLI tool for OpenCode data
- **choose-opencode-session.ps1** - Original OpenCode-specific browser
- **choose-claude-project.ps1** - Original Claude-specific browser

## Support & Feedback

For issues, improvements, or feature requests:
- Check the tool documentation in this directory
- Review batch file comments for usage notes
- Examine PowerShell script functions for configuration options
