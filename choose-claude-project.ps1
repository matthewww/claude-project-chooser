#!/usr/bin/env pwsh
param()
$ProjectsDir = Join-Path $env:USERPROFILE ".claude\projects"
$CacheFile = "$env:TEMP\.claude-projects-cache.txt"
$CacheMaxAgeMinutes = 5
$PageSize = 10

# ==================== Error Handling Functions ====================
function Show-DirectoryNotFoundError {
    Clear-Host
    Write-Host "`n❌ ERROR: Claude projects directory not found`n" -ForegroundColor Red
    Write-Host "Expected location: $ProjectsDir`n" -ForegroundColor Yellow
    Write-Host "To use Claude Project Chooser:" -ForegroundColor Cyan
    Write-Host "  1. Install Claude Code (if not already installed)" -ForegroundColor White
    Write-Host "  2. Create or open a project in Claude Code" -ForegroundColor White
    Write-Host "  3. This will create the .claude/projects directory" -ForegroundColor White
    Write-Host "  4. Run this tool again`n" -ForegroundColor White
    Write-Host "Need help? Visit: https://claude.ai" -ForegroundColor DarkGray
    exit 1
}

function Show-NoProjectsError {
    Clear-Host
    Write-Host "`n⚠️  No projects found`n" -ForegroundColor Yellow
    Write-Host "Looking in: $ProjectsDir`n" -ForegroundColor Gray
    Write-Host "The directory exists but contains no projects." -ForegroundColor White
    Write-Host "`nTo add projects:" -ForegroundColor Cyan
    Write-Host "  1. Open Claude Code" -ForegroundColor White
    Write-Host "  2. Create or open a project" -ForegroundColor White
    Write-Host "  3. Run this tool again`n" -ForegroundColor White
    exit 1
}

function Show-InvalidPathError {
    param([string]$InvalidPath)
    Write-Host "Error: Invalid path" -ForegroundColor Red
    Write-Host "Path: $InvalidPath" -ForegroundColor Yellow
    Write-Host "This directory no longer exists or is not accessible.`n" -ForegroundColor White
}

# ==================== Helper Functions ====================
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
function Get-ProjectList {
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
    
    # Validate directory exists
    if (-not (Test-Path $ProjectsDir)) {
        Show-DirectoryNotFoundError
    }
    
    $projectList = @()
    
    try {
        $projectDirs = @(Get-ChildItem -Path $ProjectsDir -Directory -ErrorAction Stop | Sort-Object -Property LastWriteTime)
    } catch {
        Write-Host "Error accessing projects directory: $_" -ForegroundColor Yellow
        exit 1
    }
    
    # Check if any projects were found
    if ($projectDirs.Count -eq 0) {
        Show-NoProjectsError
    }
    
    foreach ($dir in $projectDirs) {
        try {
            $actualPath = Get-ActualProjectPath $dir.FullName
            if ($actualPath -and -not [string]::IsNullOrWhiteSpace($actualPath)) {
                $relativeTime = Format-RelativeTime $dir.LastWriteTime
                $projectList += @{ sessionName = $dir.Name; displayName = $actualPath; fullPath = $actualPath; modified = $relativeTime }
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
$allProjects = Get-ProjectList
if ($allProjects.Count -eq 0) { 
    Show-NoProjectsError
}
function Show-Page {
    param([int]$Offset, [int]$CurrentIndex)
    $pageStart = $Offset
    $pageEnd = [Math]::Min($Offset + $PageSize, $allProjects.Count)
    if ($Offset -gt 0) { Write-Host "  (scroll up for older)" -ForegroundColor DarkGray }
    for ($i = $pageStart; $i -lt $pageEnd; $i++) {
        $isSelected = ($i -eq $CurrentIndex)
        $project = $allProjects[$i]
        if ($isSelected) {
            Write-Host "  > $($project.displayName) ($($project.modified))" -ForegroundColor Green
        } else {
            Write-Host "    $($project.displayName) " -NoNewline; Write-Host "($($project.modified))" -ForegroundColor DarkGray
        }
    }
    if ($pageEnd -lt $allProjects.Count) { Write-Host "  (scroll down for newer)" -ForegroundColor DarkGray }
    Write-Host "  [R]efresh list" -ForegroundColor DarkGray
}
Clear-Host
while ($true) {
    Write-Host "`nClaude Project Chooser (jmp)" -ForegroundColor Cyan
    Write-Host "Up/Down ➡️Choose | Enter ➡️Launch | Esc ➡️Exit`n" -ForegroundColor DarkGray
    $selectedIndex = $allProjects.Count - 1
    $pageOffset = [Math]::Max(0, $allProjects.Count - $PageSize)
    Show-Page $pageOffset $selectedIndex
    $selected = $false
    while (-not $selected) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq [ConsoleKey]::UpArrow) {
            if ($selectedIndex -gt 0) {
                $selectedIndex--
                if ($selectedIndex -lt $pageOffset) { $pageOffset = [Math]::Max(0, $selectedIndex - $PageSize + 1) }
                Clear-Host
                Write-Host "`nClaude Project Chooser (jmp)" -ForegroundColor Cyan
                Write-Host "Up/Down ➡️Choose | Enter ➡️Launch | Esc ➡️Exit`n" -ForegroundColor DarkGray
                Show-Page $pageOffset $selectedIndex
            }
        }
        elseif ($key.Key -eq [ConsoleKey]::DownArrow) {
            if ($selectedIndex -lt $allProjects.Count - 1) {
                $selectedIndex++
                if ($selectedIndex -ge $pageOffset + $PageSize) { $pageOffset = $selectedIndex - $PageSize + 1 }
                Clear-Host
                Write-Host "`nClaude Project Chooser (jmp)" -ForegroundColor Cyan
                Write-Host "Up/Down ➡️Choose | Enter ➡️Launch | Esc ➡️Exit`n" -ForegroundColor DarkGray
                Show-Page $pageOffset $selectedIndex
            }
        }
        elseif ($key.Key -eq [ConsoleKey]::Enter) { $selected = $true }
        elseif ($key.Key -eq [ConsoleKey]::Escape) { exit 0 }
        elseif ($key.KeyChar -eq 'r' -or $key.KeyChar -eq 'R') {
            Clear-Host
            Write-Host "Refreshing..." -ForegroundColor Cyan
            Start-Sleep -Milliseconds 800
            Remove-Item -Path $CacheFile -Force -ErrorAction SilentlyContinue | Out-Null
            $script:allProjects = Get-ProjectList
            if ($allProjects.Count -eq 0) {
                Write-Host "No projects found after refresh" -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                # Return to main menu
                Clear-Host
                Write-Host "`nClaude Project Chooser (jmp)" -ForegroundColor Cyan
                Write-Host "Up/Down ➡️Choose | Enter ➡️Launch | Esc ➡️Exit`n" -ForegroundColor DarkGray
                Show-Page $pageOffset $selectedIndex
                continue
            }
            $selectedIndex = $allProjects.Count - 1
            $pageOffset = [Math]::Max(0, $allProjects.Count - $PageSize)
            Clear-Host
            Write-Host "`nClaude Project Chooser (jmp)" -ForegroundColor Cyan
            Write-Host "Up/Down ➡️Choose | Enter ➡️Launch | Esc ➡️Exit`n" -ForegroundColor DarkGray
            Show-Page $pageOffset $selectedIndex
        }
    }
    $projectPath = $allProjects[$selectedIndex].fullPath
    if ($projectPath -is [array]) { $projectPath = $projectPath[0] }
    $projectPath = $projectPath.Trim()
    
    if ([string]::IsNullOrWhiteSpace($projectPath)) {
        Write-Host "Error: No path specified" -ForegroundColor Red
        Start-Sleep -Seconds 2
        Clear-Host
        continue
    }
    
    if (-not (Test-Path $projectPath)) {
        Clear-Host
        Show-InvalidPathError -InvalidPath $projectPath
        Write-Host "This project path no longer exists." -ForegroundColor Yellow
        Write-Host "You may need to remove it from your projects or verify the location." -ForegroundColor Yellow
        Write-Host "`nPress any key to continue..." -ForegroundColor DarkGray
        $null = [Console]::ReadKey($true)
        Clear-Host
        continue
    }
    Write-Host "`nLaunching: $projectPath`n" -ForegroundColor Green
    $pwshExe = (Get-Command pwsh).Source
    Start-Process -FilePath $pwshExe -ArgumentList "-NoExit", "-Command", "Set-Location '$projectPath'; claude"
    Clear-Host
}
