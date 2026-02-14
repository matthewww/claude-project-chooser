# OpenCode Integration Summary

## Overview
Successfully adapted the Windows project chooser tool to work with OpenCode projects and sessions. The tool now provides interactive navigation and data querying capabilities for OpenCode's local storage.

## Files Created

### 1. `choose-opencode-session.ps1` (14KB)
**Interactive session chooser** - Primary user-facing tool

**Features:**
- Browse all OpenCode projects from `~/.local/share/opencode/storage/project/`
- Select a project to view its sessions
- Session display includes titles, change statistics (+/- counts), and modification times
- Two-tier navigation: Projects → Sessions
- Keyboard-driven interface (arrow keys, Enter, Esc)
- Real-time relative timestamps (e.g., "3 days ago")
- Auto-caching for performance (5-minute TTL)
- Error handling for invalid paths

**Data Sources:**
- Projects: Read from `storage/project/*.json` files
  - Each file contains: `id`, `worktree` (path), `vcs` type, timestamps
  - Displays folder name extracted from worktree path

- Sessions: Read from `storage/session/<project-id>/*.json`
  - Each file contains: `id`, `slug`, `title`, `directory`, summary changes
  - Sorted by recency (newest first)

**Usage:**
```powershell
.\choose-opencode-session.ps1
```

### 2. `opencode-util.ps1` (11KB)
**Non-interactive CLI utility** - For scripting and data extraction

**Commands:**

1. **list-projects** (default)
   - Lists all projects with IDs, modification times, and paths
   - Example: `.\opencode-util.ps1 list-projects`

2. **list-sessions**
   - Shows all sessions for a specific project
   - Include change statistics for each session
   - Example: `.\opencode-util.ps1 list-sessions -ProjectName fpv-db`

3. **info**
   - Detailed project information with aggregated statistics
   - Shows total sessions, additions, deletions across all sessions
   - Example: `.\opencode-util.ps1 info -ProjectName fpv-db`

4. **recent**
   - Displays 20 most recent session activities across all projects
   - Helpful for seeing what you've been working on
   - Example: `.\opencode-util.ps1 recent`

5. **search**
   - Search sessions by title or slug (regex supported)
   - Returns matching projects and sessions
   - Example: `.\opencode-util.ps1 search -Filter "CI"`

6. **export**
   - Export data as JSON for integration with other tools
   - Example: `.\opencode-util.ps1 list-projects -Json > projects.json`

**Output Formats:**
- Human-readable (default): Color-coded table output
- JSON: Use `-Json` flag for machine-readable format

**Usage Examples:**
```powershell
# List all projects
.\opencode-util.ps1

# Get project details
.\opencode-util.ps1 info -ProjectName fpv-db

# Find sessions related to a task
.\opencode-util.ps1 search -Filter "authentication"

# Export data
.\opencode-util.ps1 recent -Json | Out-File recent-sessions.json
```

### 3. `jomp.bat`
**Batch wrapper** for convenient launching of the interactive chooser

**Usage:**
```batch
jomp
```

This launches `choose-opencode-session.ps1` with proper PowerShell execution policy.

## Data Structure Discovered

### OpenCode Storage Layout
```
~/.local/share/opencode/storage/
├── project/               # Project metadata
│   ├── 033395aa4c90092609854145a5b5f5a3dcb08439.json
│   ├── 913dec22738bc856a3228cdf91e1bdfbdae7ea20.json
│   ├── baa02e877331379c0b8ba5bab55d37b5e19d0744.json
│   ├── f66cc7d34e01621598cc848fa79cd8bbf08b1ebe.json
│   ├── global.json
│   └── ...
│
├── session/               # Session history per project
│   ├── 033395aa4c90092609854145a5b5f5a3dcb08439/
│   │   ├── ses_3ba4f7c4effelaejsuenL3WS1s.json
│   │   └── ...
│   ├── baa02e877331379c0b8ba5bab55d37b5e19d0744/
│   │   ├── ses_XXXXX.json
│   │   └── ...
│   └── ...
│
└── ...
```

### Project JSON Schema
```json
{
  "id": "033395aa4c90092609854145a5b5f5a3dcb08439",
  "worktree": "C:\\Repos\\github\\matthewww\\fpv-db-monorepo",
  "vcs": "git",
  "sandboxes": [],
  "time": {
    "created": 1770695597035,
    "updated": 1770695597039
  },
  "icon": {
    "url": "data:image/png;base64,...",
    "color": "cyan"
  }
}
```

### Session JSON Schema
```json
{
  "id": "ses_3ba4f7c4effelaejsuenL3WS1s",
  "slug": "nimble-island",
  "version": "1.1.53",
  "projectID": "033395aa4c90092609854145a5b5f5a3dcb08439",
  "directory": "C:\\Repos\\github\\matthewww\\fpv-db-monorepo",
  "title": "Monorepo CI placement strategy for fpv-db and no-password-auth",
  "time": {
    "created": 1770695721905,
    "updated": 1770696041437
  },
  "summary": {
    "additions": 40,
    "deletions": 0,
    "files": 1
  }
}
```

## Testing Results

All commands tested successfully with real OpenCode data:

```
✓ List Projects: 5 projects detected
✓ List Sessions: Correctly shows sessions per project
✓ Project Info: Aggregates statistics correctly
✓ Recent Activity: 20 most recent sessions displayed
✓ Search: Pattern matching works with regex
✓ JSON Export: Valid JSON output for all commands
```

### Sample Data Loaded
- **Projects:** claude-project-chooser, fpv-db-monorepo, monorepo, fpv-db, fpv-db (nested)
- **Sessions:** 40+ sessions across all projects
- **Total Changes:** Tracked with +additions/-deletions metrics

## Integration with Original Tools

The new OpenCode tools complement existing tools:

| Tool | Purpose | Data Source |
|------|---------|-------------|
| `choose-claude-project.ps1` | Navigate Claude Code projects | `~/.claude/projects/` JSONL files |
| `choose-opencode-session.ps1` | Navigate OpenCode projects/sessions | `~/.local/share/opencode/storage/` |
| `jmp.bat` | Wrapper for Claude tool | Launches above |
| `jomp.bat` | Wrapper for OpenCode tool | Launches OpenCode session chooser |

## Key Features & Design Decisions

### 1. **Two-Tier Navigation**
   - Projects → Sessions design allows quick filtering
   - Reduces visual clutter when many projects exist

### 2. **Change Tracking**
   - Sessions display file changes (+/- counts)
   - Helps identify recent work vs. idle sessions

### 3. **Relative Timestamps**
   - "3 days ago" format more intuitive than absolute dates
   - Automatically computed from file modification times

### 4. **Pagination**
   - Displays up to 10 items per page
   - Keyboard navigation for scroll (Up/Down arrows)
   - Prevents overwhelming large project lists

### 5. **Error Handling**
   - Gracefully handles missing or invalid paths
   - Auto-skips malformed JSON files
   - Provides helpful error messages

### 6. **Performance Optimization**
   - 5-minute cache for project list (in `choose-opencode-session.ps1`)
   - Lazy loading of sessions only when needed
   - Minimal memory footprint

### 7. **Flexibility**
   - Interactive chooser for typical users
   - CLI utility for automation/scripting
   - JSON output for tool integration

## Usage Workflow Examples

### Quick Jump to Recent Project
```powershell
.\choose-opencode-session.ps1
# Press Enter on most recent project
```

### Find All Bug-Related Sessions
```powershell
.\opencode-util.ps1 search -Filter "bug"
```

### Get Statistics for a Project
```powershell
.\opencode-util.ps1 info -ProjectName fpv-db
```

### Export Recent Work for Reporting
```powershell
.\opencode-util.ps1 recent -Json | ConvertFrom-Json | Format-Table
```

### Monitor Project Activity
```powershell
# Get latest sessions
.\opencode-util.ps1 recent

# Or watch continuously
while ($true) {
    Clear-Host
    .\opencode-util.ps1 recent
    Start-Sleep -Seconds 60
}
```

## Future Enhancement Possibilities

1. **Session Details Modal** - Show full session context on selection
2. **Filtering** - Filter by date range, project type, VCS status
3. **Multi-Select** - Open multiple projects simultaneously
4. **Statistics Dashboard** - Aggregate metrics across all projects
5. **Git Integration** - Show git status for each project
6. **Favorites** - Pin frequently-used projects
7. **Fuzzy Search** - Match projects/sessions with typos
8. **Shell Integration** - Auto-complete for PowerShell

## Files Modified

- **README.md** - Added comprehensive OpenCode documentation section

## Files Created (Summary)

| File | Size | Type | Purpose |
|------|------|------|---------|
| choose-opencode-session.ps1 | 14KB | PowerShell | Interactive project/session chooser |
| opencode-util.ps1 | 11KB | PowerShell | CLI utility for data queries |
| jomp.bat | 226B | Batch | Convenient launcher wrapper |

## Conclusion

The Windows tool has been successfully adapted to work with OpenCode projects and sessions. The implementation provides:

✓ Full interactive navigation of OpenCode data  
✓ Session history and change tracking  
✓ Flexible CLI for automation  
✓ JSON export for tool integration  
✓ Robust error handling  
✓ Performance optimization  

The tools are production-ready and tested with real OpenCode data.
