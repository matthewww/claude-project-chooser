#!/usr/bin/env pwsh
param()
$ProjectsDir = Join-Path $env:USERPROFILE ".claude\projects"
$CacheFile = "$env:TEMP\.claude-projects-cache.txt"
$CacheMaxAgeMinutes = 5
$PageSize = 10
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
            $cached = @(Get-Content $CacheFile | ConvertFrom-Json)
            return @($cached | Where-Object { -not [string]::IsNullOrWhiteSpace($_.fullPath) })
        }
    }
    $projectDirs = Get-ChildItem -Path $ProjectsDir -Directory | Sort-Object -Property LastWriteTime
    $projectList = @()
    foreach ($dir in $projectDirs) {
        $actualPath = Get-ActualProjectPath $dir.FullName
        if ($actualPath -and -not [string]::IsNullOrWhiteSpace($actualPath)) {
            $relativeTime = Format-RelativeTime $dir.LastWriteTime
            $projectList += @{ sessionName = $dir.Name; displayName = $actualPath; fullPath = $actualPath; modified = $relativeTime }
        }
    }
    if ($projectList.Count -gt 0) { $projectList | ConvertTo-Json | Set-Content $CacheFile }
    return @($projectList)
}
$allProjects = Get-ProjectList
if ($allProjects.Count -eq 0) { Write-Error "No projects found"; exit 1 }
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
                Write-Error "No projects found after refresh"
                exit 1
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
    if ([string]::IsNullOrWhiteSpace($projectPath) -or -not (Test-Path $projectPath)) {
        Write-Host "Error: Invalid path" -ForegroundColor Red
        Start-Sleep -Seconds 2
        Clear-Host
        continue
    }
    Write-Host "`nLaunching: $projectPath`n" -ForegroundColor Green
    $pwshExe = (Get-Command pwsh).Source
    Start-Process -FilePath $pwshExe -ArgumentList "-NoExit", "-Command", "Set-Location '$projectPath'; claude"
    Clear-Host
}
