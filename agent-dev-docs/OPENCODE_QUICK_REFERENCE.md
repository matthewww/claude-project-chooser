# Quick Reference - OpenCode Tools

## Installation

No installation needed! The tools are ready to use immediately.

## Available Commands

### Interactive Mode (Visual Navigator)
```powershell
.\choose-opencode-session.ps1
# or
jomp
```
**Best for:** Browsing and exploring projects interactively

### Command Line Mode (Non-Interactive)
```powershell
.\opencode-util.ps1 [command] [options]
```

## Command Reference

| Command | Usage | Example |
|---------|-------|---------|
| `list-projects` | List all projects | `.\opencode-util.ps1 list-projects` |
| `list-sessions` | List sessions for a project | `.\opencode-util.ps1 list-sessions -ProjectName fpv-db` |
| `info` | Get project statistics | `.\opencode-util.ps1 info -ProjectName fpv-db` |
| `recent` | Show 20 recent sessions | `.\opencode-util.ps1 recent` |
| `search` | Find sessions by keyword | `.\opencode-util.ps1 search -Filter "bug"` |
| `--Help` | Show command help | `.\opencode-util.ps1 --Help` |
| `-Json` | Export as JSON | `.\opencode-util.ps1 list-projects -Json` |

## Keyboard Shortcuts (Interactive Mode)

| Key | Action |
|-----|--------|
| ↑/↓ | Navigate between items |
| Enter | Open project in Claude |
| B | Back to project list |
| R | Refresh data |
| Q/Esc | Exit |

## Examples

### List All Projects
```powershell
.\opencode-util.ps1
```

### Find Sessions About "Authentication"
```powershell
.\opencode-util.ps1 search -Filter "authentication"
```

### Get Project Stats
```powershell
.\opencode-util.ps1 info -ProjectName fpv-db
```

### Export Recent Activity
```powershell
.\opencode-util.ps1 recent -Json | Out-File recent.json
```

### Quick Project Navigation
```powershell
.\choose-opencode-session.ps1
# Use arrow keys to browse
# Press Enter to open
```

## Data Locations

- **Projects:** `~/.local/share/opencode/storage/project/*.json`
- **Sessions:** `~/.local/share/opencode/storage/session/<project-id>/*.json`
- **Cache:** `$env:TEMP\.opencode-projects-cache.txt`

## Common Tasks

### Jump to a Project
```powershell
.\choose-opencode-session.ps1
```

### See What You've Been Working On
```powershell
.\opencode-util.ps1 recent
```

### Find All Sessions from Today
```powershell
.\opencode-util.ps1 recent | Select-Object -First 5
```

### Generate Project Report
```powershell
.\opencode-util.ps1 list-projects -Json | ConvertFrom-Json | Format-Table -Property displayName, modified, worktree
```

### Monitor Project Updates
```powershell
while ($true) {
    Clear-Host
    .\opencode-util.ps1 recent
    Start-Sleep -Seconds 30
}
```

## Troubleshooting

### "Cannot find path" error
- Ensure OpenCode is installed and initialized
- Check that `~/.local/share/opencode/storage/` exists

### "No projects found"
- OpenCode must have created at least one project
- Try creating a session in OpenCode first

### ReadKey error in batch files
- This is expected in non-interactive mode
- Use the direct PowerShell commands instead

### Script execution policy error
- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

## Performance Notes

- First run may take 1-2 seconds to load all data
- Subsequent runs use a 5-minute cache
- Use `-Json` flag for large data exports
- Search can be slow with many sessions (40+)

## Integration Tips

### Add to PATH for Global Access
```powershell
# Add to PowerShell profile ($PROFILE)
Set-Alias jomp 'C:\path\to\choose-opencode-session.ps1'
Set-Alias opencode-info 'C:\path\to\opencode-util.ps1'
```

### Create Custom Scripts
```powershell
# my-recent-projects.ps1
.\opencode-util.ps1 recent -Json | ConvertFrom-Json | Where-Object { $_.modified -match "ago" } | ForEach-Object { Write-Host "$($_.projectName): $($_.title)" }
```

### Schedule Reports
```powershell
# Create a scheduled task to export activity daily
$trigger = New-ScheduledTaskTrigger -Daily -At 9am
$action = New-ScheduledTaskAction -Execute "powershell" -Argument "-NoProfile -Command `". opencode-util.ps1 recent -Json | Out-File C:\reports\daily.json`""
Register-ScheduledTask -TaskName "OpenCode Daily Report" -Trigger $trigger -Action $action
```

## File Structure
- `choose-opencode-session.ps1` - Interactive project/session selector (14 KB)
- `opencode-util.ps1` - CLI utility for querying data (11 KB)
- `jomp.bat` - Convenient launcher (226 B)
- `OPENCODE_INTEGRATION.md` - Full documentation

## Version Info
- Created: Feb 12, 2026
- Tested with OpenCode 1.1.53
- Compatible with: Windows PowerShell 5.1+, PowerShell 7+
