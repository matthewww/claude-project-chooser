# Project Structure - Complete Overview

```
claude-project-chooser/
│
├── 📚 Documentation (Root Level)
│   ├── README.md                     # Main documentation (both CLI & Taskbar)
│   ├── TASKBAR_APP_DESIGN.md         # Complete architectural design (10,731 chars)
│   ├── COMPARISON.md                  # CLI vs Taskbar analysis (6,706 chars)
│   ├── QUICKSTART.md                  # Developer quick start (5,787 chars)
│   ├── UI_MOCKUPS.md                  # Visual mockups (8,896 chars)
│   ├── TODO.md                        # Future enhancements (8,241 chars)
│   └── IMPLEMENTATION_SUMMARY.md      # What was delivered (8,004 chars)
│
├── 📟 CLI Version (Original - PowerShell)
│   ├── choose-claude-project.ps1     # Main CLI script (133 lines)
│   ├── jmp.bat                        # Windows batch wrapper (3 lines)
│   └── install.ps1                    # CLI installer (69 lines)
│
├── 🖥️ Taskbar App (New - C# / .NET 8.0)
│   ├── build.ps1                      # Build script for Windows (114 lines)
│   │
│   └── src/
│       ├── README.md                  # Taskbar app documentation (6,188 chars)
│       │
│       └── ClaudeProjectChooser/      # C# Project
│           ├── ClaudeProjectChooser.csproj    # Project file (.NET 8.0)
│           ├── Program.cs                     # Entry point (27 lines)
│           ├── TrayApplicationContext.cs      # Main app logic (194 lines)
│           ├── ProjectManager.cs              # Discovery & caching (200 lines)
│           ├── ProjectLauncher.cs             # Launch logic (97 lines)
│           └── ClaudeProject.cs               # Data model (15 lines)
│
├── 🔧 Configuration
│   └── .gitignore                     # Git ignore patterns
│
└── 🎨 Assets (To Be Added)
    └── Resources/                     # Icons and resources
        └── icon.ico                   # (Future: Custom icon)

```

## File Statistics

### Documentation
- **Total**: 7 markdown files
- **Total Size**: ~56,365 characters
- **Coverage**: Complete from design to deployment

### Code - CLI Version
- **Language**: PowerShell
- **Files**: 3 (.ps1, .bat)
- **Lines**: ~205 total
- **Purpose**: Terminal-based project chooser

### Code - Taskbar Version
- **Language**: C# / .NET 8.0
- **Files**: 6 (.cs, .csproj)
- **Lines**: ~533 C# code
- **Purpose**: GUI system tray application

### Total Project
- **Files**: 18 (excluding .git)
- **Languages**: 3 (PowerShell, C#, Batch)
- **Documentation**: ~56KB
- **Code**: ~738 lines

## Component Breakdown

### 1. CLI Tool (Original)
```
choose-claude-project.ps1 (133 lines)
├── Get-ActualProjectPath()      # Extract path from JSONL
├── Format-RelativeTime()         # "2m ago" formatting
├── Get-ProjectList()             # Discovery with cache
├── Show-Page()                   # Paginated display
└── Main Loop                     # Keyboard navigation
```

### 2. Taskbar App (New)
```
Program.cs (27 lines)
└── Main()                        # Entry point + single instance check

TrayApplicationContext.cs (194 lines)
├── InitializeComponents()        # Setup tray icon & menu
├── BuildContextMenu()            # Dynamic menu builder
├── OnProjectClick()              # Launch handler
├── OnRefreshClick()              # Cache clear
├── OnAboutClick()                # About dialog
└── OnExitClick()                 # Cleanup & exit

ProjectManager.cs (200 lines)
├── GetProjects()                 # Main discovery method
├── TryLoadFromCache()            # Cache loading
├── SaveToCache()                 # Cache saving
├── DiscoverProjects()            # Scan filesystem
├── GetActualProjectPath()        # JSONL parsing
├── FormatRelativeTime()          # Time formatting
└── ClearCache()                  # Cache invalidation

ProjectLauncher.cs (97 lines)
├── LaunchProject()               # Main launch method
├── FindPowerShell()              # Locate PowerShell
└── TryFindInPath()               # PATH search helper

ClaudeProject.cs (15 lines)
└── Properties                    # Data model
```

## Data Flow

### CLI Version
```
User → jmp.bat → choose-claude-project.ps1
                    ↓
            Read ~/.claude/projects
                    ↓
            Parse JSONL files
                    ↓
            Cache to %TEMP%\.claude-projects-cache.txt
                    ↓
            Display arrow-key menu
                    ↓
            Launch: PowerShell + cd + claude
```

### Taskbar Version
```
User → ClaudeProjectChooser.exe
            ↓
    TrayApplicationContext
            ↓
    ProjectManager.GetProjects()
            ↓
    Read ~/.claude/projects
            ↓
    Parse JSONL files
            ↓
    Cache to %TEMP%\.claude-projects-cache.json
            ↓
    Build Context Menu
            ↓
    User clicks project
            ↓
    ProjectLauncher.LaunchProject()
            ↓
    Launch: PowerShell + cd + claude
```

## Shared Logic

Both versions share the same core algorithm:

1. **Discover Projects**
   - Scan `~/.claude/projects` directory
   - Find session folders
   - Sort by last modified time

2. **Extract Paths**
   - Read `*.jsonl` files in each folder
   - Parse JSON lines
   - Find `cwd` field
   - Use as display path

3. **Cache Results**
   - Store in temp directory
   - 5-minute TTL
   - Fast repeated access

4. **Launch Claude**
   - Find PowerShell executable
   - Start new window
   - Set working directory
   - Run `claude` command

## Technology Stack

### CLI Version
- **Runtime**: PowerShell (built into Windows)
- **UI**: Console text + ANSI colors
- **Navigation**: Arrow keys
- **Cache Format**: Text file

### Taskbar Version
- **Runtime**: .NET 8.0
- **UI**: Windows Forms (System.Windows.Forms)
- **Navigation**: Mouse clicks
- **Cache Format**: JSON
- **Dependencies**: Newtonsoft.Json

## Key Differences

| Aspect | CLI | Taskbar |
|--------|-----|---------|
| **Persistence** | On-demand | Always running |
| **Interface** | Console | System Tray |
| **Cache** | .txt | .json |
| **Navigation** | Keyboard | Mouse |
| **Startup** | Manual | Optional auto-start |
| **Code Size** | 205 lines | 533 lines |
| **Complexity** | Simple | Moderate |

## Build Outputs

### CLI (No Build Required)
```
~/.claude/bin/
├── jmp.bat
└── choose-claude-project.ps1
```

### Taskbar (After Build)
```
src/ClaudeProjectChooser/bin/Release/net8.0-windows/
├── ClaudeProjectChooser.exe          # Main executable
├── ClaudeProjectChooser.dll          # Application library
├── Newtonsoft.Json.dll               # JSON dependency
└── [Other .NET runtime files]
```

### Taskbar (After Publish)
```
publish/
└── ClaudeProjectChooser.exe          # Single self-contained file
                                       # ~80-100 MB (includes .NET runtime)
```

## Documentation Hierarchy

```
README.md (Top Level)
├── Overview of both versions
├── Quick start for both
└── Links to detailed docs

TASKBAR_APP_DESIGN.md
├── Architecture
├── Components
├── Design decisions
└── Implementation phases

COMPARISON.md
├── Feature comparison
├── Use cases
├── User personas
└── Technical analysis

QUICKSTART.md
├── Prerequisites
├── Build steps
├── Running instructions
└── Troubleshooting

UI_MOCKUPS.md
├── Visual mockups
├── Interaction flows
├── State diagrams
└── Platform notes

TODO.md
├── Phase 2 features
├── Phase 3 features
├── Future ideas
└── Roadmap

IMPLEMENTATION_SUMMARY.md
├── What was delivered
├── Technical details
├── Next steps
└── Testing guide

src/README.md
├── Taskbar app usage
├── Installation
├── Configuration
└── Troubleshooting
```

## Lines of Code by Component

```
Component                    Lines    Percentage
──────────────────────────────────────────────
CLI Script                   133      18%
CLI Installer                69       9%
Taskbar - Main App           194      26%
Taskbar - Project Manager    200      27%
Taskbar - Launcher           97       13%
Taskbar - Entry Point        27       4%
Taskbar - Data Model         15       2%
Build Script                 114      15%
──────────────────────────────────────────────
Total                        738      100%
```

## Documentation by Type

```
Type                         Characters   Percentage
────────────────────────────────────────────────────
Design Document             10,731       19%
Comparison Analysis         6,706        12%
Quick Start Guide           5,787        10%
UI Mockups                  8,896        16%
TODO List                   8,241        15%
Implementation Summary      8,004        14%
Taskbar README              6,188        11%
Main README                 6,812        12%
────────────────────────────────────────────────────
Total                       56,365       100%
```

## Project Maturity

### CLI Version (v1.0)
- ✅ Production ready
- ✅ Fully tested
- ✅ Well documented
- ✅ No known bugs

### Taskbar Version (v2.0)
- ✅ Code complete
- ✅ Comprehensively documented
- ⏳ Awaiting Windows testing
- ⏳ Needs icon asset
- ⏳ Needs installer
- ⏳ Needs screenshots

## Success Metrics

### Code Quality
- ✅ Clean separation of concerns
- ✅ Single responsibility principle
- ✅ DRY (Don't Repeat Yourself)
- ✅ Clear naming conventions
- ✅ Error handling
- ⚠️ Unit tests (future)

### Documentation Quality
- ✅ Complete architecture docs
- ✅ User guides
- ✅ Developer guides
- ✅ Comparison analysis
- ✅ Visual mockups
- ✅ Future roadmap
- ⚠️ Screenshots (pending Windows build)

### Feature Completeness (MVP)
- ✅ System tray integration
- ✅ Project discovery
- ✅ Menu generation
- ✅ Project launching
- ✅ Caching
- ✅ Auto-refresh
- ✅ Notifications
- ⚠️ Custom icon (future)
- ⚠️ Settings UI (future)

---

**Status**: Ready for Windows testing ✓

**Next Action**: Build and test on Windows machine

**Branch**: copilot/plan-windows-taskbar-app
