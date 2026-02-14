#!/usr/bin/env pwsh
# OpenCode Project/Session Chooser
# Navigates OpenCode projects and sessions with an interactive UI

param()

$OpenCodeStorageDir = Join-Path $env:USERPROFILE ".local\share\opencode\storage"
$ProjectsDir = Join-Path $OpenCodeStorageDir "project"
$SessionsDir = Join-Path $OpenCodeStorageDir "session"
$CacheFile = "$env:TEMP\.opencode-projects-cache.txt"
$CacheMaxAgeMinutes = 5
$PageSize = 10

# ==================== Data Loading Functions ====================
function Get-ProjectList {
    if (Test-Path $CacheFile) {
        $CacheAge = (Get-Date) - (Get-Item $CacheFile).LastWriteTime
        if ($CacheAge.TotalMinutes -lt $CacheMaxAgeMinutes) {
            try {
                $cached = @(Get-Content $CacheFile | ConvertFrom-Json)
                return @($cached | Where-Object { -not [string]::IsNullOrWhiteSpace($_.worktree) })
            } catch { }
        }
    }

    $projectList = @()
    
    if (Test-Path $ProjectsDir) {
        $projectFiles = Get-ChildItem -Path $ProjectsDir -Filter "*.json" -File | Sort-Object -Property LastWriteTime
        foreach ($file in $projectFiles) {
            try {
                $project = Get-Content $file.FullName | ConvertFrom-Json
                if ($project.id -and $project.worktree) {
                    $relativeTime = Format-RelativeTime $file.LastWriteTime
                    $displayName = Split-Path -Leaf $project.worktree
                    $projectList += @{
                        id = $project.id
                        displayName = $displayName
                        worktree = $project.worktree
                        vcs = $project.vcs
                        modified = $relativeTime
                        createdTime = $file.LastWriteTime
                    }
                }
            } catch {
                Write-Host "Error reading project file: $($file.Name)" -ForegroundColor DarkYellow
            }
        }
    }

    if ($projectList.Count -gt 0) {
        $projectList | ConvertTo-Json | Set-Content $CacheFile
    }

    return @($projectList)
}

function Get-SessionsForProject {
    param([string]$ProjectId)
    
    $projectSessionDir = Join-Path $SessionsDir $ProjectId
    $sessions = @()

    if (Test-Path $projectSessionDir) {
        $sessionFiles = Get-ChildItem -Path $projectSessionDir -Filter "*.json" -File | Sort-Object -Property LastWriteTime -Descending
        foreach ($file in $sessionFiles) {
            try {
                $session = Get-Content $file.FullName | ConvertFrom-Json
                if ($session.id) {
                    $relativeTime = Format-RelativeTime $file.LastWriteTime
                    $title = if ($session.title) { $session.title } else { $session.slug }
                    $sessions += @{
                        id = $session.id
                        slug = $session.slug
                        title = $title
                        projectID = $session.projectID
                        directory = $session.directory
                        modified = $relativeTime
                        createdTime = $file.LastWriteTime
                        additions = $session.summary.additions
                        deletions = $session.summary.deletions
                        files = $session.summary.files
                    }
                }
            } catch {
                Write-Host "Error reading session file: $($file.Name)" -ForegroundColor DarkYellow
            }
        }
    }

    return @($sessions)
}

# ==================== Display Functions ====================
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

function Show-ProjectsPage {
    param([int]$Offset, [int]$CurrentIndex, [object[]]$Projects)
    
    $pageStart = $Offset
    $pageEnd = [Math]::Min($Offset + $PageSize, $Projects.Count)
    
    if ($Offset -gt 0) { Write-Host "  (scroll up for older)" -ForegroundColor DarkGray }
    for ($i = $pageStart; $i -lt $pageEnd; $i++) {
        $isSelected = ($i -eq $CurrentIndex)
        $project = $Projects[$i]
        $color = if ($isSelected) { "Green" } else { "White" }
        $marker = if ($isSelected) { ">" } else { " " }
        Write-Host "  $marker $($project.displayName)" -ForegroundColor $color -NoNewline
        Write-Host " ($($project.modified))" -ForegroundColor DarkGray
    }
    if ($pageEnd -lt $Projects.Count) { Write-Host "  (scroll down for newer)" -ForegroundColor DarkGray }
    Write-Host "  [R]efresh list | [Q]uit" -ForegroundColor DarkGray
}

function Show-SessionsPage {
    param([int]$Offset, [int]$CurrentIndex, [object[]]$Sessions)
    
    $pageStart = $Offset
    $pageEnd = [Math]::Min($Offset + $PageSize, $Sessions.Count)
    
    if ($Offset -gt 0) { Write-Host "  (scroll up for older)" -ForegroundColor DarkGray }
    for ($i = $pageStart; $i -lt $pageEnd; $i++) {
        $isSelected = ($i -eq $CurrentIndex)
        $session = $Sessions[$i]
        $color = if ($isSelected) { "Green" } else { "White" }
        $marker = if ($isSelected) { ">" } else { " " }
        
        $title = if ($session.title.Length -gt 50) { $session.title.Substring(0, 47) + "..." } else { $session.title }
        Write-Host "  $marker $title" -ForegroundColor $color -NoNewline
        Write-Host " ($($session.modified))" -ForegroundColor DarkGray
        
        $changes = ""
        if ($session.additions -gt 0 -or $session.deletions -gt 0) {
            $changes = " [+$($session.additions) -$($session.deletions) files: $($session.files)]"
            Write-Host "      $changes" -ForegroundColor DarkGray
        }
    }
    if ($pageEnd -lt $Sessions.Count) { Write-Host "  (scroll down for newer)" -ForegroundColor DarkGray }
    Write-Host "  [B]ack to projects | [R]efresh | [Q]uit" -ForegroundColor DarkGray
}

# ==================== Main UI Loop ====================
function Show-ProjectChooser {
    $allProjects = Get-ProjectList
    
    if ($allProjects.Count -eq 0) {
        Write-Error "No projects found in $ProjectsDir"
        exit 1
    }

    Clear-Host
    while ($true) {
        Write-Host "`nOpenCode Project Chooser" -ForegroundColor Cyan
        Write-Host "Up/Down ➡️ Choose | Enter ➡️ Browse Sessions | Esc ➡️ Exit`n" -ForegroundColor DarkGray
        
        $selectedIndex = $allProjects.Count - 1
        $pageOffset = [Math]::Max(0, $allProjects.Count - $PageSize)
        
        Show-ProjectsPage $pageOffset $selectedIndex $allProjects
        
        $selected = $false
        while (-not $selected) {
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq [ConsoleKey]::UpArrow) {
                if ($selectedIndex -gt 0) {
                    $selectedIndex--
                    if ($selectedIndex -lt $pageOffset) { $pageOffset = [Math]::Max(0, $selectedIndex - $PageSize + 1) }
                    Clear-Host
                    Write-Host "`nOpenCode Project Chooser" -ForegroundColor Cyan
                    Write-Host "Up/Down ➡️ Choose | Enter ➡️ Browse Sessions | Esc ➡️ Exit`n" -ForegroundColor DarkGray
                    Show-ProjectsPage $pageOffset $selectedIndex $allProjects
                }
            }
            elseif ($key.Key -eq [ConsoleKey]::DownArrow) {
                if ($selectedIndex -lt $allProjects.Count - 1) {
                    $selectedIndex++
                    if ($selectedIndex -ge $pageOffset + $PageSize) { $pageOffset = $selectedIndex - $PageSize + 1 }
                    Clear-Host
                    Write-Host "`nOpenCode Project Chooser" -ForegroundColor Cyan
                    Write-Host "Up/Down ➡️ Choose | Enter ➡️ Browse Sessions | Esc ➡️ Exit`n" -ForegroundColor DarkGray
                    Show-ProjectsPage $pageOffset $selectedIndex $allProjects
                }
            }
            elseif ($key.Key -eq [ConsoleKey]::Enter) { $selected = $true }
            elseif ($key.Key -eq [ConsoleKey]::Escape) { exit 0 }
            elseif ($key.KeyChar -eq 'r' -or $key.KeyChar -eq 'R') {
                Clear-Host
                Write-Host "Refreshing..." -ForegroundColor Cyan
                Start-Sleep -Milliseconds 800
                Remove-Item -Path $CacheFile -Force -ErrorAction SilentlyContinue | Out-Null
                $allProjects = Get-ProjectList
                if ($allProjects.Count -eq 0) {
                    Write-Error "No projects found after refresh"
                    exit 1
                }
                $selectedIndex = $allProjects.Count - 1
                $pageOffset = [Math]::Max(0, $allProjects.Count - $PageSize)
                Clear-Host
                Write-Host "`nOpenCode Project Chooser" -ForegroundColor Cyan
                Write-Host "Up/Down ➡️ Choose | Enter ➡️ Browse Sessions | Esc ➡️ Exit`n" -ForegroundColor DarkGray
                Show-ProjectsPage $pageOffset $selectedIndex $allProjects
            }
            elseif ($key.KeyChar -eq 'q' -or $key.KeyChar -eq 'Q') {
                exit 0
            }
        }
        
        $selectedProject = $allProjects[$selectedIndex]
        Show-SessionChooser $selectedProject $allProjects
    }
}

function Show-SessionChooser {
    param([object]$Project, [object[]]$AllProjects)
    
    Clear-Host
    Write-Host "`nOpenCode Session Chooser - " -ForegroundColor Cyan -NoNewline
    Write-Host "$($Project.displayName)" -ForegroundColor Green
    Write-Host "Project: $($Project.worktree)" -ForegroundColor DarkGray
    Write-Host "Up/Down ➡️ Choose | Enter ➡️ Open Project | B ➡️ Back | Esc ➡️ Exit`n" -ForegroundColor DarkGray
    
    $sessions = Get-SessionsForProject $Project.id
    
    if ($sessions.Count -eq 0) {
        Write-Host "No sessions found for this project" -ForegroundColor Yellow
        Write-Host "`nPress any key to go back..."
        $null = [Console]::ReadKey($true)
        return
    }

    $selectedIndex = $sessions.Count - 1
    $pageOffset = [Math]::Max(0, $sessions.Count - $PageSize)
    
    Show-SessionsPage $pageOffset $selectedIndex $sessions
    
    $navigating = $true
    while ($navigating) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq [ConsoleKey]::UpArrow) {
            if ($selectedIndex -gt 0) {
                $selectedIndex--
                if ($selectedIndex -lt $pageOffset) { $pageOffset = [Math]::Max(0, $selectedIndex - $PageSize + 1) }
                Clear-Host
                Write-Host "`nOpenCode Session Chooser - " -ForegroundColor Cyan -NoNewline
                Write-Host "$($Project.displayName)" -ForegroundColor Green
                Write-Host "Project: $($Project.worktree)" -ForegroundColor DarkGray
                Write-Host "Up/Down ➡️ Choose | Enter ➡️ Open Project | B ➡️ Back | Esc ➡️ Exit`n" -ForegroundColor DarkGray
                Show-SessionsPage $pageOffset $selectedIndex $sessions
            }
        }
        elseif ($key.Key -eq [ConsoleKey]::DownArrow) {
            if ($selectedIndex -lt $sessions.Count - 1) {
                $selectedIndex++
                if ($selectedIndex -ge $pageOffset + $PageSize) { $pageOffset = $selectedIndex - $PageSize + 1 }
                Clear-Host
                Write-Host "`nOpenCode Session Chooser - " -ForegroundColor Cyan -NoNewline
                Write-Host "$($Project.displayName)" -ForegroundColor Green
                Write-Host "Project: $($Project.worktree)" -ForegroundColor DarkGray
                Write-Host "Up/Down ➡️ Choose | Enter ➡️ Open Project | B ➡️ Back | Esc ➡️ Exit`n" -ForegroundColor DarkGray
                Show-SessionsPage $pageOffset $selectedIndex $sessions
            }
        }
        elseif ($key.Key -eq [ConsoleKey]::Enter) {
            $selectedSession = $sessions[$selectedIndex]
            # Try session directory first, fall back to project worktree
            $projectPath = if (-not [string]::IsNullOrWhiteSpace($selectedSession.directory)) {
                $selectedSession.directory
            } else {
                $Project.worktree
            }
            
            if ([string]::IsNullOrWhiteSpace($projectPath) -or -not (Test-Path $projectPath)) {
                Write-Host "Error: Invalid project path" -ForegroundColor Red
                Write-Host "Session directory: $($selectedSession.directory)" -ForegroundColor DarkGray
                Write-Host "Project worktree: $($Project.worktree)" -ForegroundColor DarkGray
                Start-Sleep -Seconds 2
                Clear-Host
                Write-Host "`nOpenCode Session Chooser - " -ForegroundColor Cyan -NoNewline
                Write-Host "$($Project.displayName)" -ForegroundColor Green
                Write-Host "Project: $($Project.worktree)" -ForegroundColor DarkGray
                Write-Host "Up/Down ➡️ Choose | Enter ➡️ Open Project | B ➡️ Back | Esc ➡️ Exit`n" -ForegroundColor DarkGray
                Show-SessionsPage $pageOffset $selectedIndex $sessions
            } else {
                Write-Host "`nLaunching: $projectPath" -ForegroundColor Green
                Write-Host "Session: $($selectedSession.title)" -ForegroundColor Green
                Write-Host "`n"
                $pwshExe = (Get-Command pwsh).Source
                Start-Process -FilePath $pwshExe -ArgumentList "-NoExit", "-Command", "Set-Location '$projectPath'; claude"
                Clear-Host
                $navigating = $false
            }
        }
        elseif ($key.Key -eq [ConsoleKey]::Escape) {
            exit 0
        }
        elseif ($key.KeyChar -eq 'b' -or $key.KeyChar -eq 'B') {
            $navigating = $false
        }
        elseif ($key.KeyChar -eq 'q' -or $key.KeyChar -eq 'Q') {
            exit 0
        }
    }
}

# ==================== Entry Point ====================
if (-not (Test-Path $ProjectsDir)) {
    Write-Error "OpenCode storage not found at: $ProjectsDir"
    Write-Error "Please ensure OpenCode is installed and has initialized projects"
    exit 1
}

Show-ProjectChooser
