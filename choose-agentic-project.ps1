#!/usr/bin/env pwsh
# Agentic Project Chooser - Unified tool for Claude and OpenCode projects
# Features: Smart auto-detection, session browsing, comprehensive error handling
# Usage: .\choose-agentic-project.ps1 [-Mode <claude|opencode|auto>] [-OpenCodeSessionMode <projects|sessions>]
#
# Consolidated features:
#   - Claude project browser (choose-claude-project.ps1)
#   - OpenCode project and session browser (choose-opencode-session.ps1)
#   - Smart fallback: Claude → OpenCode → Error guidance

param(
    [ValidateSet('claude', 'opencode', 'auto')]
    [string]$Mode = 'auto',
    
    [ValidateSet('projects', 'sessions')]
    [string]$OpenCodeSessionMode = 'projects'
)

# ==================== Configuration ====================
$PageSize = 10

# Detect available modes if auto mode is selected
$detectedMode = $Mode
$claudeProjectsDir = Join-Path $env:USERPROFILE ".claude\projects"
$openCodeStorageDir = Join-Path $env:USERPROFILE ".local\share\opencode\storage"
$openCodeProjectsDir = Join-Path $openCodeStorageDir "project"

# Smart detection: Try Claude first, fall back to OpenCode
if ($Mode -eq 'auto') {
    if (Test-Path $claudeProjectsDir) {
        $detectedMode = 'claude'
    } elseif (Test-Path $openCodeProjectsDir) {
        $detectedMode = 'opencode'
    } else {
        # Neither found, default to claude for error message
        $detectedMode = 'claude'
    }
}

# Mode-specific paths and configuration
if ($detectedMode -eq 'claude') {
    $ProjectsDir = $claudeProjectsDir
    $CacheFile = "$env:TEMP\.claude-projects-cache.txt"
    $ToolName = "Claude Project Chooser"
    $CacheMaxAgeMinutes = 5
} else {
    $ProjectsDir = $openCodeProjectsDir
    $SessionsDir = Join-Path $openCodeStorageDir "session"
    $CacheFile = "$env:TEMP\.opencode-projects-cache.txt"
    $ToolName = "OpenCode Project Chooser"
    $CacheMaxAgeMinutes = 5
}

# ==================== Error Handling Functions ====================
function Show-DirectoryNotFoundError {
    param(
        [string]$MissingDir,
        [string]$DetectedMode
    )
    
    Clear-Host
    
    # Check if BOTH tools are missing
    $claudeMissing = -not (Test-Path (Join-Path $env:USERPROFILE ".claude\projects"))
    $opencodeMissing = -not (Test-Path (Join-Path $env:USERPROFILE ".local\share\opencode\storage\project"))
    
    if ($claudeMissing -and $opencodeMissing) {
        # Both missing - show combined guidance
        Write-Host "`n❌ ERROR: No projects found`n" -ForegroundColor Red
        Write-Host "Neither Claude Code nor OpenCode projects directory found." -ForegroundColor Yellow
        Write-Host "Expected locations:" -ForegroundColor Yellow
        Write-Host "  • $(Join-Path $env:USERPROFILE '.claude\projects')" -ForegroundColor DarkGray
        Write-Host "  • $(Join-Path $env:USERPROFILE '.local\share\opencode\storage\project')`n" -ForegroundColor DarkGray
        
        Write-Host "To get started, choose one option:`n" -ForegroundColor Cyan
        
        Write-Host "Option 1: Use Claude Code" -ForegroundColor White
        Write-Host "  1. Install Claude Code from https://claude.ai" -ForegroundColor DarkGray
        Write-Host "  2. Create or open a project" -ForegroundColor DarkGray
        Write-Host "  3. This tool will find it automatically`n" -ForegroundColor DarkGray
        
        Write-Host "Option 2: Use OpenCode" -ForegroundColor White
        Write-Host "  1. Install OpenCode from https://opencode.ai" -ForegroundColor DarkGray
        Write-Host "  2. Create or open a project" -ForegroundColor DarkGray
        Write-Host "  3. This tool will find it automatically`n" -ForegroundColor DarkGray
    } else {
        # One tool is available but its directory is empty
        Write-Host "`n❌ ERROR: $DetectedMode projects directory not found`n" -ForegroundColor Red
        Write-Host "Expected location: $MissingDir`n" -ForegroundColor Yellow
        
        switch ($DetectedMode.ToLower()) {
            'claude' {
                Write-Host "To use Claude Project Chooser:" -ForegroundColor Cyan
                Write-Host "  1. Install Claude Code (if not already installed)" -ForegroundColor White
                Write-Host "  2. Create or open a project in Claude Code" -ForegroundColor White
                Write-Host "  3. This will create the .claude/projects directory" -ForegroundColor White
                Write-Host "  4. Run this tool again`n" -ForegroundColor White
                Write-Host "Need help? Visit: https://claude.ai" -ForegroundColor DarkGray
            }
            'opencode' {
                Write-Host "To use OpenCode Project Chooser:" -ForegroundColor Cyan
                Write-Host "  1. Install OpenCode (https://opencode.ai)" -ForegroundColor White
                Write-Host "  2. Create or open a project in OpenCode" -ForegroundColor White
                Write-Host "  3. This will create the .local/share/opencode directory" -ForegroundColor White
                Write-Host "  4. Run this tool again`n" -ForegroundColor White
                Write-Host "Directory that would be created:" -ForegroundColor Gray
                Write-Host "    $MissingDir`n" -ForegroundColor DarkGray
            }
        }
    }
    
    exit 1
}

function Show-NoProjectsError {
    param(
        [string]$Mode,
        [string]$ProjectsDir
    )
    
    Clear-Host
    Write-Host "`n⚠️  No projects found`n" -ForegroundColor Yellow
    Write-Host "Looking in: $ProjectsDir`n" -ForegroundColor Gray
    
    switch ($Mode.ToLower()) {
        'claude' {
            Write-Host "The directory exists but contains no projects." -ForegroundColor White
            Write-Host "`nTo add projects:" -ForegroundColor Cyan
            Write-Host "  1. Open Claude Code" -ForegroundColor White
            Write-Host "  2. Create or open a project" -ForegroundColor White
            Write-Host "  3. Run this tool again`n" -ForegroundColor White
        }
        'opencode' {
            Write-Host "The directory exists but contains no projects." -ForegroundColor White
            Write-Host "`nTo add projects:" -ForegroundColor Cyan
            Write-Host "  1. Open OpenCode" -ForegroundColor White
            Write-Host "  2. Create or browse to a project directory" -ForegroundColor White
            Write-Host "  3. Run this tool again`n" -ForegroundColor White
        }
    }
    
    exit 1
}

function Show-InvalidPathError {
    param(
        [string]$InvalidPath
    )
    
    Write-Host "Error: Invalid path" -ForegroundColor Red
    Write-Host "Path: $InvalidPath" -ForegroundColor Yellow
    Write-Host "This directory no longer exists or is not accessible.`n" -ForegroundColor White
}

function Test-DirectoriesExist {
    param(
        [string]$DetectedMode
    )
    
    # Check if projects directory exists
    if (-not (Test-Path $ProjectsDir)) {
        Show-DirectoryNotFoundError -MissingDir $ProjectsDir -DetectedMode $DetectedMode
        return $false
    }
    
    # Check if there are any projects
    $projectCount = (Get-ChildItem -Path $ProjectsDir -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($projectCount -eq 0) {
        Show-NoProjectsError -Mode $DetectedMode -ProjectsDir $ProjectsDir
        return $false
    }
    
    return $true
}

# ==================== Helper Functions ====================
function Format-RelativeTime {
    param([datetime]$Date)
    $now = Get-Date
    $diff = $now - $Date
    if ($diff.TotalMinutes -lt 1) { return "just now" }
    elseif ($diff.TotalMinutes -lt 60) { return "$([Math]::Round($diff.TotalMinutes))m ago" }
    elseif ($diff.TotalHours -lt 24) { return "$([Math]::Round($diff.TotalHours))h ago" }
    elseif ($diff.TotalDays -lt 7) { return "$([Math]::Round($diff.TotalDays))d ago" }
    else { return $Date.ToString("MMM d, h:mm tt") }
}

# ==================== Claude Mode Functions ====================
function Get-ActualProjectPath {
    param([string]$SessionFolder)
    $jsonlFile = Get-ChildItem -Path $SessionFolder -Filter "*.jsonl" -File | Select-Object -First 1
    if ($jsonlFile) {
        Get-Content $jsonlFile.FullName | ForEach-Object {
            try {
                $obj = $_ | ConvertFrom-Json
                if ($obj.cwd) { return $obj.cwd }
            } catch { }
        } | Select-Object -First 1
    }
    return $null
}

function Get-ClaudeProjectList {
    if (Test-Path $CacheFile) {
        $CacheAge = (Get-Date) - (Get-Item $CacheFile).LastWriteTime
        if ($CacheAge.TotalMinutes -lt $CacheMaxAgeMinutes) {
            try {
                $cached = @(Get-Content $CacheFile | ConvertFrom-Json)
                $validCache = @($cached | Where-Object { -not [string]::IsNullOrWhiteSpace($_.fullPath) })
                if ($validCache.Count -gt 0) {
                    return @($validCache)
                }
            } catch { 
                # Cache is corrupted, ignore and reload
                Remove-Item -Path $CacheFile -Force -ErrorAction SilentlyContinue | Out-Null
            }
        }
    }
    
    $projectList = @()
    
    try {
        $projectDirs = @(Get-ChildItem -Path $ProjectsDir -Directory -ErrorAction Stop | Sort-Object -Property LastWriteTime)
    } catch {
        Write-Host "Error accessing projects directory: $_" -ForegroundColor Yellow
        return @()
    }
    
    foreach ($dir in $projectDirs) {
        try {
            $actualPath = Get-ActualProjectPath $dir.FullName
            if ($actualPath -and -not [string]::IsNullOrWhiteSpace($actualPath)) {
                $relativeTime = Format-RelativeTime $dir.LastWriteTime
                $projectList += @{ 
                    sessionName = $dir.Name
                    displayName = $actualPath
                    fullPath = $actualPath
                    modified = $relativeTime
                    type = 'claude'
                }
            }
        } catch {
            Write-Host "Warning: Could not read project folder $($dir.Name): $_" -ForegroundColor DarkYellow
        }
    }
    
    if ($projectList.Count -gt 0) { 
        try {
            $projectList | ConvertTo-Json | Set-Content $CacheFile -ErrorAction SilentlyContinue
        } catch { 
            # Cache write failed, but we still have the data
        }
    }
    
    return @($projectList)
}

# ==================== OpenCode Mode Functions ====================
function Get-OpenCodeProjectList {
    if (Test-Path $CacheFile) {
        $CacheAge = (Get-Date) - (Get-Item $CacheFile).LastWriteTime
        if ($CacheAge.TotalMinutes -lt $CacheMaxAgeMinutes) {
            try {
                $cached = @(Get-Content $CacheFile | ConvertFrom-Json)
                $validCache = @($cached | Where-Object { -not [string]::IsNullOrWhiteSpace($_.worktree) })
                if ($validCache.Count -gt 0) {
                    return @($validCache)
                }
            } catch { 
                # Cache is corrupted, ignore and reload
                Remove-Item -Path $CacheFile -Force -ErrorAction SilentlyContinue | Out-Null
            }
        }
    }

    $projectList = @()
    
    if (-not (Test-Path $ProjectsDir)) {
        Write-Host "Projects directory does not exist: $ProjectsDir" -ForegroundColor Yellow
        return @()
    }
    
    try {
        $projectFiles = @(Get-ChildItem -Path $ProjectsDir -Filter "*.json" -File -ErrorAction Stop | Sort-Object -Property LastWriteTime)
    } catch {
        Write-Host "Error accessing projects directory: $_" -ForegroundColor Yellow
        return @()
    }
    
    foreach ($file in $projectFiles) {
        try {
            $project = Get-Content $file.FullName | ConvertFrom-Json
            if ($project.id -and $project.worktree) {
                # Verify the path still exists
                if (Test-Path $project.worktree) {
                    $relativeTime = Format-RelativeTime $file.LastWriteTime
                    $displayName = Split-Path -Leaf $project.worktree
                    $projectList += @{
                        id = $project.id
                        displayName = $displayName
                        worktree = $project.worktree
                        fullPath = $project.worktree
                        vcs = $project.vcs
                        modified = $relativeTime
                        type = 'opencode'
                    }
                } else {
                    Write-Host "Warning: Project path no longer exists: $($project.worktree)" -ForegroundColor DarkYellow
                }
            }
        } catch {
            Write-Host "Warning: Error reading project file $($file.Name): $_" -ForegroundColor DarkYellow
        }
    }

    if ($projectList.Count -gt 0) { 
        try {
            $projectList | ConvertTo-Json | Set-Content $CacheFile -ErrorAction SilentlyContinue
        } catch { 
            # Cache write failed, but we still have the data
        }
    }
    
    return @($projectList)
}

function Get-OpenCodeSessionsForProject {
    param([string]$ProjectId)
    
    $projectSessionDir = Join-Path $SessionsDir $ProjectId
    $sessions = @()

    if (-not (Test-Path $projectSessionDir)) {
        Write-Host "No sessions directory for project $ProjectId" -ForegroundColor DarkGray
        return @()
    }
    
    try {
        $sessionFiles = @(Get-ChildItem -Path $projectSessionDir -Filter "*.json" -File -ErrorAction Stop | Sort-Object -Property LastWriteTime -Descending)
    } catch {
        Write-Host "Warning: Error accessing sessions directory: $_" -ForegroundColor DarkYellow
        return @()
    }
    
    foreach ($file in $sessionFiles) {
        try {
            $session = Get-Content $file.FullName | ConvertFrom-Json
            if ($session.id) {
                $relativeTime = Format-RelativeTime $file.LastWriteTime
                $title = if ($session.title) { $session.title } else { $session.slug }
                $sessions += @{
                    id = $session.id
                    slug = $session.slug
                    displayName = $title
                    fullPath = $session.directory
                    modified = $relativeTime
                    additions = $session.summary.additions
                    deletions = $session.summary.deletions
                    files = $session.summary.files
                    type = 'opencode-session'
                }
            }
        } catch {
            Write-Host "Warning: Error reading session file $($file.Name): $_" -ForegroundColor DarkYellow
        }
    }

    return @($sessions)
}

# ==================== Display Functions ====================
function Show-Page {
    param([int]$Offset, [int]$CurrentIndex, [object[]]$Items, [bool]$IsSessionMode = $false)
    
    $pageStart = $Offset
    $pageEnd = [Math]::Min($Offset + $PageSize, $Items.Count)
    
    if ($Offset -gt 0) { Write-Host "  (scroll up for older)" -ForegroundColor DarkGray }
    for ($i = $pageStart; $i -lt $pageEnd; $i++) {
        $isSelected = ($i -eq $CurrentIndex)
        $item = $Items[$i]
        $color = if ($isSelected) { "Green" } else { "White" }
        $marker = if ($isSelected) { ">" } else { " " }
        
        Write-Host "  $marker $($item.displayName)" -ForegroundColor $color -NoNewline
        Write-Host " ($($item.modified))" -ForegroundColor DarkGray
        
        # Show additional info for OpenCode sessions
        if ($IsSessionMode -and $item.type -eq 'opencode-session') {
            if ($item.additions -gt 0 -or $item.deletions -gt 0) {
                Write-Host "      [+$($item.additions) -$($item.deletions) in $($item.files) file(s)]" -ForegroundColor DarkGray
            }
        }
    }
    if ($pageEnd -lt $Items.Count) { Write-Host "  (scroll down for newer)" -ForegroundColor DarkGray }
    if ($IsSessionMode) {
        Write-Host "  [B]ack to projects | [R]efresh | [Q]uit" -ForegroundColor DarkGray
    } else {
        Write-Host "  [R]efresh list | [Q]uit" -ForegroundColor DarkGray
    }
}

# ==================== Main UI Logic ====================
function Show-Chooser {
    param([object[]]$Items, [bool]$IsSessionMode = $false, [object]$ParentProject = $null)
    
    if ($Items.Count -eq 0) {
        Write-Host "No items found" -ForegroundColor Yellow
        if ($IsSessionMode) {
            Write-Host "Press any key to go back..."
            $null = [Console]::ReadKey($true)
            return $false
        } else {
            Write-Error "No projects found"
            exit 1
        }
    }

    $selectedIndex = $Items.Count - 1
    $pageOffset = [Math]::Max(0, $Items.Count - $PageSize)
    
    while ($true) {
        Clear-Host
        Write-Host "`n$ToolName" -ForegroundColor Cyan
        
        if ($IsSessionMode) {
            Write-Host "Project: $($ParentProject.displayName)" -ForegroundColor Green
            Write-Host "Up/Down ➡️ Choose | Enter ➡️ Open | B ➡️ Back | Esc ➡️ Exit`n" -ForegroundColor DarkGray
        } else {
            Write-Host "Up/Down ➡️ Choose | Enter ➡️ Open | Esc ➡️ Exit`n" -ForegroundColor DarkGray
        }
        
        Show-Page $pageOffset $selectedIndex $Items $IsSessionMode
        
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq [ConsoleKey]::UpArrow) {
            if ($selectedIndex -gt 0) {
                $selectedIndex--
                if ($selectedIndex -lt $pageOffset) { $pageOffset = [Math]::Max(0, $selectedIndex - $PageSize + 1) }
            }
        }
        elseif ($key.Key -eq [ConsoleKey]::DownArrow) {
            if ($selectedIndex -lt $Items.Count - 1) {
                $selectedIndex++
                if ($selectedIndex -ge $pageOffset + $PageSize) { $pageOffset = $selectedIndex - $PageSize + 1 }
            }
        }
        elseif ($key.Key -eq [ConsoleKey]::Enter) {
            return @{ selected = $true; index = $selectedIndex }
        }
        elseif ($key.Key -eq [ConsoleKey]::Escape) {
            if ($IsSessionMode) { return @{ selected = $false } }
            else { exit 0 }
        }
        elseif ($key.KeyChar -eq 'r' -or $key.KeyChar -eq 'R') {
            Clear-Host
            Write-Host "Refreshing..." -ForegroundColor Cyan
            Start-Sleep -Milliseconds 800
            Remove-Item -Path $CacheFile -Force -ErrorAction SilentlyContinue | Out-Null
            if ($IsSessionMode) {
                $script:allItems = Get-OpenCodeSessionsForProject $ParentProject.id
                if ($allItems.Count -eq 0) {
                    Write-Host "No sessions found after refresh" -ForegroundColor Yellow
                    Start-Sleep -Seconds 1
                    return @{ selected = $false }
                }
            } else {
                if ($detectedMode -eq 'claude') {
                    $script:allItems = Get-ClaudeProjectList
                } else {
                    $script:allItems = Get-OpenCodeProjectList
                }
                if ($allItems.Count -eq 0) {
                    Write-Error "No projects found after refresh"
                    exit 1
                }
            }
            $selectedIndex = $Items.Count - 1
            $pageOffset = [Math]::Max(0, $Items.Count - $PageSize)
        }
        elseif ($key.KeyChar -eq 'q' -or $key.KeyChar -eq 'Q') {
            exit 0
        }
        elseif (($key.KeyChar -eq 'b' -or $key.KeyChar -eq 'B') -and $IsSessionMode) {
            return @{ selected = $false }
        }
    }
}

# ==================== Main Entry Point ====================
# Validate directories before proceeding
if (-not (Test-DirectoriesExist -DetectedMode $detectedMode)) {
    exit 1
}

# Load initial projects based on detected mode
if ($detectedMode -eq 'claude') {
    $allProjects = Get-ClaudeProjectList
} else {
    $allProjects = Get-OpenCodeProjectList
}

# Double-check we have projects
if ($allProjects.Count -eq 0) {
    Show-NoProjectsError -Mode $detectedMode -ProjectsDir $ProjectsDir
    exit 1
}

# Main loop for project selection (Claude mode or OpenCode projects mode)
while ($true) {
    $result = Show-Chooser $allProjects $false
    
    if ($result -is [hashtable] -and $result.selected) {
        $selectedProject = $allProjects[$result.index]
        
        # For OpenCode, optionally show sessions before opening
        if ($detectedMode -eq 'opencode' -and $OpenCodeSessionMode -eq 'sessions') {
            $sessions = Get-OpenCodeSessionsForProject $selectedProject.id
            if ($sessions.Count -gt 0) {
                $sessionResult = Show-Chooser $sessions $true $selectedProject
                if ($sessionResult -is [hashtable] -and $sessionResult.selected) {
                    $selectedSession = $sessions[$sessionResult.index]
                    $projectPath = $selectedSession.fullPath
                } else {
                    # User went back, continue to next project selection
                    continue
                }
            } else {
                $projectPath = $selectedProject.fullPath
            }
        } else {
            $projectPath = $selectedProject.fullPath
        }
        
        # Validate and launch
        if ($projectPath -is [array]) { $projectPath = $projectPath[0] }
        $projectPath = $projectPath.Trim()
        
        if ([string]::IsNullOrWhiteSpace($projectPath)) {
            Write-Host "Error: No path specified" -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }
        
        if (-not (Test-Path $projectPath)) {
            Clear-Host
            Show-InvalidPathError -InvalidPath $projectPath
            Write-Host "This project path no longer exists." -ForegroundColor Yellow
            Write-Host "You may need to remove it from your projects or verify the location." -ForegroundColor Yellow
            Write-Host "`nPress any key to continue..." -ForegroundColor DarkGray
            $null = [Console]::ReadKey($true)
            continue
        }
        
        Write-Host "`nLaunching: $projectPath`n" -ForegroundColor Green
        $pwshExe = (Get-Command pwsh).Source
        Start-Process -FilePath $pwshExe -ArgumentList "-NoExit", "-Command", "Set-Location '$projectPath'; claude"
        Clear-Host
    }
}
