#!/usr/bin/env pwsh
# OpenCode Session Analysis and Navigation Utility
# Provides additional functionality for working with OpenCode projects and sessions

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("list-projects", "list-sessions", "info", "recent", "search", "export")]
    [string]$Command = "list-projects",
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string]$Filter,
    
    [switch]$Json,
    [switch]$Help
)

$OpenCodeStorageDir = Join-Path $env:USERPROFILE ".local\share\opencode\storage"
$ProjectsDir = Join-Path $OpenCodeStorageDir "project"
$SessionsDir = Join-Path $OpenCodeStorageDir "session"

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

function Get-AllProjects {
    $projectList = @()
    if (Test-Path $ProjectsDir) {
        Get-ChildItem -Path $ProjectsDir -Filter "*.json" -File | ForEach-Object {
            try {
                $project = Get-Content $_.FullName | ConvertFrom-Json
                if ($project.id -and $project.worktree) {
                    $projectList += @{
                        id = $project.id
                        displayName = Split-Path -Leaf $project.worktree
                        worktree = $project.worktree
                        vcs = $project.vcs
                        modified = $_.LastWriteTime
                        createdTime = if ($project.time) { [datetime]::FromFileTimeUtc($project.time.updated * 10000) } else { $_.LastWriteTime }
                    }
                }
            } catch { }
        }
    }
    return @($projectList | Sort-Object -Property modified -Descending)
}

function Get-SessionsForProject {
    param([string]$ProjectId)
    
    $projectSessionDir = Join-Path $SessionsDir $ProjectId
    $sessions = @()
    
    if (Test-Path $projectSessionDir) {
        Get-ChildItem -Path $projectSessionDir -Filter "*.json" -File | ForEach-Object {
            try {
                $session = Get-Content $_.FullName | ConvertFrom-Json
                if ($session.id) {
                    $sessions += @{
                        id = $session.id
                        slug = $session.slug
                        title = if ($session.title) { $session.title } else { $session.slug }
                        projectID = $session.projectID
                        directory = $session.directory
                        modified = $_.LastWriteTime
                        additions = $session.summary.additions
                        deletions = $session.summary.deletions
                        files = $session.summary.files
                    }
                }
            } catch { }
        }
    }
    
    return @($sessions | Sort-Object -Property modified -Descending)
}

function Show-Help {
    @"
OpenCode Session Utility - Manage and explore OpenCode projects and sessions

USAGE:
  opencode-util.ps1 [Command] [Options]

COMMANDS:
  list-projects        List all OpenCode projects (default)
  list-sessions        List sessions for a specific project
  info                 Show detailed information about a project
  recent               Show recent activity across all projects
  search               Search projects and sessions
  export               Export project/session data

OPTIONS:
  -ProjectName <name>  Project name filter (for list-sessions, info commands)
  -Filter <pattern>    Filter pattern for search results
  -Json                Output results as JSON
  -Help                Show this help message

EXAMPLES:
  # List all projects
  .\opencode-util.ps1

  # List all sessions for fpv-db project
  .\opencode-util.ps1 list-sessions -ProjectName fpv-db

  # Show project info
  .\opencode-util.ps1 info -ProjectName fpv-db

  # Show recent activity
  .\opencode-util.ps1 recent

  # Search for sessions with specific keywords
  .\opencode-util.ps1 search -Filter "bug"

  # Export data as JSON
  .\opencode-util.ps1 list-projects -Json
"@
}

# ==================== Command Implementations ====================
function Invoke-ListProjects {
    param([switch]$Json)
    
    $projects = Get-AllProjects
    
    if ($Json) {
        return $projects | ConvertTo-Json
    }
    
    Write-Host "`nOpenCode Projects:`n" -ForegroundColor Cyan
    $projects | ForEach-Object {
        Write-Host "  $($_.displayName)" -ForegroundColor Green -NoNewline
        $idDisplay = if ($_.id.Length -gt 8) { $_.id.Substring(0, 8) + "..." } else { $_.id }
        Write-Host " [$idDisplay]" -ForegroundColor DarkGray -NoNewline
        Write-Host " ($(Format-RelativeTime $_.modified))" -ForegroundColor DarkGray
        Write-Host "    → $($_.worktree)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

function Invoke-ListSessions {
    param([string]$ProjectName, [switch]$Json)
    
    $projects = Get-AllProjects
    $target = $projects | Where-Object { $_.displayName -match $ProjectName -or $_.worktree -match $ProjectName } | Select-Object -First 1
    
    if (-not $target) {
        Write-Error "Project '$ProjectName' not found"
        return
    }
    
    $sessions = Get-SessionsForProject $target.id
    
    if ($Json) {
        return $sessions | ConvertTo-Json
    }
    
    Write-Host "`nSessions for $($target.displayName):`n" -ForegroundColor Cyan
    $sessions | ForEach-Object {
        Write-Host "  $($_.slug)" -ForegroundColor Green -NoNewline
        Write-Host " ($(Format-RelativeTime $_.modified))" -ForegroundColor DarkGray
        Write-Host "    → $($_.title)" -ForegroundColor DarkGray
        Write-Host "    Changes: +$($_.additions) -$($_.deletions) in $($_.files) file(s)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

function Invoke-ProjectInfo {
    param([string]$ProjectName, [switch]$Json)
    
    $projects = Get-AllProjects
    $target = $projects | Where-Object { $_.displayName -match $ProjectName -or $_.worktree -match $ProjectName } | Select-Object -First 1
    
    if (-not $target) {
        Write-Error "Project '$ProjectName' not found"
        return
    }
    
    $sessions = Get-SessionsForProject $target.id
    $totalChanges = ($sessions | Measure-Object -Property additions -Sum).Sum
    $totalDeletions = ($sessions | Measure-Object -Property deletions -Sum).Sum
    
    if ($Json) {
        $info = @{
            project = $target
            sessions = $sessions
            stats = @{
                totalSessions = $sessions.Count
                totalAdditions = $totalChanges
                totalDeletions = $totalDeletions
            }
        }
        return $info | ConvertTo-Json
    }
    
    Write-Host "`nProject Information:`n" -ForegroundColor Cyan
    Write-Host "  Name: $($target.displayName)" -ForegroundColor White
    Write-Host "  ID: $($target.id)" -ForegroundColor DarkGray
    Write-Host "  VCS: $($target.vcs)" -ForegroundColor DarkGray
    Write-Host "  Path: $($target.worktree)" -ForegroundColor White
    Write-Host "  Modified: $(Format-RelativeTime $target.modified)" -ForegroundColor DarkGray
    Write-Host "`n  Statistics:" -ForegroundColor White
    Write-Host "    Sessions: $($sessions.Count)" -ForegroundColor DarkGray
    Write-Host "    Total Changes: +$totalChanges -$totalDeletions" -ForegroundColor DarkGray
    Write-Host ""
}

function Invoke-RecentActivity {
    param([switch]$Json)
    
    $projects = Get-AllProjects
    $recentSessions = @()
    
    foreach ($project in $projects) {
        $sessions = Get-SessionsForProject $project.id
        $recentSessions += $sessions | ForEach-Object {
            $_ | Add-Member -NotePropertyName projectName -NotePropertyValue $project.displayName -PassThru
            $_ | Add-Member -NotePropertyName projectPath -NotePropertyValue $project.worktree -PassThru
        }
    }
    
    $recentSessions = @($recentSessions | Sort-Object -Property modified -Descending | Select-Object -First 20)
    
    if ($Json) {
        return $recentSessions | ConvertTo-Json
    }
    
    Write-Host "`nRecent OpenCode Activity:`n" -ForegroundColor Cyan
    $recentSessions | ForEach-Object {
        Write-Host "  $($_.projectName)" -ForegroundColor Green -NoNewline
        Write-Host " → $($_.slug)" -ForegroundColor DarkGray -NoNewline
        Write-Host " ($(Format-RelativeTime $_.modified))" -ForegroundColor DarkGray
        Write-Host "    $($_.title)" -ForegroundColor White
    }
    Write-Host ""
}

function Invoke-SearchSessions {
    param([string]$Filter, [switch]$Json)
    
    $projects = Get-AllProjects
    $results = @()
    
    foreach ($project in $projects) {
        $sessions = Get-SessionsForProject $project.id
        $results += $sessions | Where-Object { $_.title -match $Filter -or $_.slug -match $Filter } | ForEach-Object {
            $_ | Add-Member -NotePropertyName projectName -NotePropertyValue $project.displayName -PassThru
            $_ | Add-Member -NotePropertyName projectPath -NotePropertyValue $project.worktree -PassThru
        }
    }
    
    if ($Json) {
        return $results | ConvertTo-Json
    }
    
    if ($results.Count -eq 0) {
        Write-Host "No sessions found matching '$Filter'" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nSearch Results for '$Filter':`n" -ForegroundColor Cyan
    $results | ForEach-Object {
        Write-Host "  $($_.projectName) → $($_.slug)" -ForegroundColor Green
        Write-Host "    $($_.title)" -ForegroundColor White
        Write-Host "    Path: $($_.directory)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# ==================== Main ====================
if ($Help) {
    Show-Help
    exit 0
}

$result = $null

switch ($Command) {
    "list-projects" { $result = Invoke-ListProjects -Json:$Json }
    "list-sessions" { $result = Invoke-ListSessions -ProjectName $ProjectName -Json:$Json }
    "info" { $result = Invoke-ProjectInfo -ProjectName $ProjectName -Json:$Json }
    "recent" { $result = Invoke-RecentActivity -Json:$Json }
    "search" { $result = Invoke-SearchSessions -Filter $Filter -Json:$Json }
    default { $result = Invoke-ListProjects -Json:$Json }
}

if ($result -and $Json) {
    Write-Output $result
}
