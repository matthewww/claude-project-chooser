#!/usr/bin/env pwsh
# Agentic Project Chooser - Unified tool for managing agentic coding tool projects
# Features: Smart auto-detection, session browsing, extensible provider architecture
# Usage: .\choose-agentic-project.ps1 [-Mode <all|auto|<providerId>>] [-OpenCodeSessionMode <projects|sessions>]
#
# Architecture: Provider plugins in ./providers/*.ps1 self-register via Register-Provider.
# Add support for a new tool by dropping a .ps1 file in the providers/ directory.

param(
    [string]$Mode = 'all',

    [ValidateSet('projects', 'sessions')]
    [string]$OpenCodeSessionMode = 'projects'
)

# ==================== Configuration ====================
$PageSize           = 10
$CacheMaxAgeMinutes = 5

# UI Symbols - using ASCII-compatible characters for terminal compatibility
$UI = @{
    Arrow    = '->'        # Navigation arrows (compatible with all terminals)
    Pipe     = '|'         # Vertical pipe for separation
    Check    = '>'         # Selection indicator
    Space    = ' '         # Selection placeholder
    Scroll   = '...'       # Scroll indicator
    KeyUp    = 'Up/Down'   # Up/down arrow keys
    KeyEnter = 'Enter'     # Enter key
    KeyEsc   = 'Esc'       # Escape key
}

# Error/status icons that work across terminals
$Icons = @{
    Error   = '[!]'        # Error indicator
    Warning = '[!]'        # Warning indicator
    Info    = '[*]'        # Information indicator
}

# ==================== Provider Registry ====================
$script:Providers = [System.Collections.Generic.List[object]]::new()

function Register-Provider {
    param([hashtable]$Provider)
    $script:Providers.Add($Provider)
}

# Load all provider files from the providers/ subdirectory
$_providersDir = Join-Path $PSScriptRoot "providers"
if (Test-Path $_providersDir) {
    Get-ChildItem -Path $_providersDir -Filter "*.ps1" -File | Sort-Object Name | ForEach-Object {
        . $_.FullName
    }
} else {
    Write-Error "Providers directory not found: $_providersDir"
    exit 1
}
Remove-Variable _providersDir

# ==================== Mode Detection ====================
$detectedMode = $Mode
if ($Mode -eq 'auto') {
    $firstAvailable = $script:Providers | Where-Object { Test-Path $_.DataDir } | Select-Object -First 1
    $detectedMode   = if ($firstAvailable) { $firstAvailable.Id } else { ($script:Providers | Select-Object -First 1).Id }
}

# Validate mode (accepts 'all', 'auto', or any registered provider Id)
$_validModes = @('all', 'auto') + @($script:Providers | ForEach-Object { $_.Id })
if ($Mode -notin $_validModes) {
    Write-Error "Invalid mode: '$Mode'. Valid modes: $($_validModes -join ', ')"
    exit 1
}
Remove-Variable _validModes

# ==================== Mode Configuration ====================
$ProjectsDir    = $null
$CacheFile      = $null
$ToolName       = $null
$activeProvider = $null

if ($detectedMode -eq 'all') {
    $CacheFile = "$env:TEMP\.all-projects-cache.txt"
    $ToolName  = "Agentic Project Chooser"
} else {
    $activeProvider = $script:Providers | Where-Object { $_.Id -eq $detectedMode } | Select-Object -First 1
    $ProjectsDir    = $activeProvider.DataDir
    $CacheFile      = $activeProvider.CacheFile
    $ToolName       = "$($activeProvider.Name) Project Chooser"
}

# ==================== Error Handling Functions ====================
function Show-DirectoryNotFoundError {
    param(
        [string]$MissingDir,
        [string]$DetectedMode
    )

    Clear-Host

    $missingAll = @($script:Providers | Where-Object { -not (Test-Path $_.DataDir) })
    if ($missingAll.Count -eq $script:Providers.Count) {
        Write-Host "`n$($Icons.Error) ERROR: No agentic tool data found`n" -ForegroundColor Red
        Write-Host "No project directories found for any configured provider." -ForegroundColor Yellow
        Write-Host "Expected locations:" -ForegroundColor Yellow
        foreach ($p in $script:Providers) {
            Write-Host "  • $($p.DataDir)" -ForegroundColor DarkGray
        }
        Write-Host "`nTo get started:`n" -ForegroundColor Cyan
        $i = 1
        foreach ($p in $script:Providers) {
            Write-Host "Option $i`: Use $($p.Name)" -ForegroundColor White
            if ($p.InstallUrl) {
                Write-Host "  Install from: $($p.InstallUrl)" -ForegroundColor DarkGray
            }
            Write-Host "  Launch with:  $($p.LaunchCmd)`n" -ForegroundColor DarkGray
            $i++
        }
    } else {
        Write-Host "`n$($Icons.Error) ERROR: $DetectedMode projects directory not found`n" -ForegroundColor Red
        Write-Host "Expected location: $MissingDir`n" -ForegroundColor Yellow
        $provider = $script:Providers | Where-Object { $_.Id -eq $DetectedMode } | Select-Object -First 1
        if ($provider) {
            Write-Host "To use $($provider.Name) Project Chooser:" -ForegroundColor Cyan
            if ($provider.InstallUrl) {
                Write-Host "  1. Install $($provider.Name): $($provider.InstallUrl)" -ForegroundColor White
            } else {
                Write-Host "  1. Install $($provider.Name)" -ForegroundColor White
            }
            Write-Host "  2. Launch it once to create the data directory: $($provider.LaunchCmd)" -ForegroundColor White
            Write-Host "  3. Run this tool again`n" -ForegroundColor White
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
    Write-Host "`n$($Icons.Warning) No projects found`n" -ForegroundColor Yellow
    Write-Host "Looking in: $ProjectsDir`n" -ForegroundColor Gray

    $provider = $script:Providers | Where-Object { $_.Id -eq $Mode } | Select-Object -First 1
    $toolName = if ($provider) { $provider.Name } else { $Mode }
    $launchCmd = if ($provider) { $provider.LaunchCmd } else { $Mode }

    Write-Host "The directory exists but contains no projects." -ForegroundColor White
    Write-Host "`nTo add projects:" -ForegroundColor Cyan
    Write-Host "  1. Open $toolName" -ForegroundColor White
    Write-Host "  2. Create or open a project" -ForegroundColor White
    Write-Host "  3. Run: $launchCmd" -ForegroundColor White
    Write-Host "  4. Run this tool again`n" -ForegroundColor White

    exit 1
}

function Show-InvalidPathError {
    <#
    .SYNOPSIS
        Display error when a selected project path no longer exists
    .PARAMETER InvalidPath
        The project path that is invalid
    #>
    param(
        [string]$InvalidPath
    )
    
    Write-Host "Error: Invalid path" -ForegroundColor Red
    Write-Host "Path: $InvalidPath" -ForegroundColor Yellow
    Write-Host "This directory no longer exists or is not accessible.`n" -ForegroundColor White
}

function Test-DirectoriesExist {
    param([string]$DetectedMode)

    if ($DetectedMode -eq 'all') {
        $anyExists = @($script:Providers | Where-Object { Test-Path $_.DataDir }).Count -gt 0
        if (-not $anyExists) {
            Show-DirectoryNotFoundError -MissingDir '' -DetectedMode $DetectedMode
            return $false
        }
        return $true
    }

    if (-not (Test-Path $ProjectsDir)) {
        Show-DirectoryNotFoundError -MissingDir $ProjectsDir -DetectedMode $DetectedMode
        return $false
    }

    $projectCount = (Get-ChildItem -Path $ProjectsDir -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($projectCount -eq 0) {
        Show-NoProjectsError -Mode $DetectedMode -ProjectsDir $ProjectsDir
        return $false
    }

    return $true
}

# ==================== Helper Functions ====================
function Format-RelativeTime {
    <#
    .SYNOPSIS
        Convert a datetime to a human-readable relative time string
    .PARAMETER Date
        The datetime to format
    .EXAMPLE
        Format-RelativeTime (Get-Date).AddHours(-2)  # Returns "2h ago"
    #>
    param([datetime]$Date)
    $now = Get-Date
    $diff = $now - $Date
    if ($diff.TotalMinutes -lt 1) { return "just now" }
    elseif ($diff.TotalMinutes -lt 60) { return "$([Math]::Round($diff.TotalMinutes))m ago" }
    elseif ($diff.TotalHours -lt 24) { return "$([Math]::Round($diff.TotalHours))h ago" }
    elseif ($diff.TotalDays -lt 7) { return "$([Math]::Round($diff.TotalDays))d ago" }
    else { return $Date.ToString("MMM d, h:mm tt") }
}

# ==================== All Mode Functions ====================
function Get-AllProjectList {
    <#
    .SYNOPSIS
        Get merged, deduplicated project list from all registered providers
    .RETURNS
        Array of project hashtables sorted by sortDate descending (most recent first)
    #>
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
                Remove-Item -Path $CacheFile -Force -ErrorAction SilentlyContinue | Out-Null
            }
        }
    }

    $combined = @()
    foreach ($provider in $script:Providers) {
        if (Test-Path $provider.DataDir) {
            $projects = @(& $provider.GetProjects $provider.DataDir $provider.CacheFile $CacheMaxAgeMinutes)
            $combined += $projects
        }
    }

    # Deduplicate by fullPath — keep the entry with the most recent sortDate
    $seen = @{}
    foreach ($p in $combined) {
        $key = $p.fullPath.ToLower().TrimEnd('\', '/')
        if (-not $seen.ContainsKey($key) -or $p.sortDate -gt $seen[$key].sortDate) {
            $seen[$key] = $p
        }
    }

    $projectList = @($seen.Values | Sort-Object { $_.sortDate } -Descending)

    if ($projectList.Count -gt 0) {
        try {
            $projectList | ConvertTo-Json | Set-Content $CacheFile -ErrorAction SilentlyContinue
        } catch { }
    }

    return @($projectList)
}


# ==================== Display Functions ====================
function Show-Page {
    <#
    .SYNOPSIS
        Displays a paginated list of items with selection indicator
    .PARAMETER Offset
        Starting index for the current page
    .PARAMETER CurrentIndex
        Currently selected item index
    .PARAMETER Items
        Array of items to display
    .PARAMETER IsSessionMode
        Whether displaying sessions (affects available commands)
    #>
    param([int]$Offset, [int]$CurrentIndex, [object[]]$Items, [bool]$IsSessionMode = $false)
    
    $pageStart = $Offset
    $pageEnd = [Math]::Min($Offset + $PageSize, $Items.Count)
    
    if ($Offset -gt 0) { Write-Host "  (scroll up for older)" -ForegroundColor DarkGray }
    
    for ($i = $pageStart; $i -lt $pageEnd; $i++) {
        $isSelected = ($i -eq $CurrentIndex)
        $item = $Items[$i]
        $color = if ($isSelected) { "Green" } else { "White" }
        $marker = if ($isSelected) { $UI.Check } else { $UI.Space }
        
        Write-Host "  $marker " -NoNewline

        # Tool badge in 'all' mode — resolved dynamically from the provider registry
        if (-not $IsSessionMode -and $detectedMode -eq 'all') {
            $p = $script:Providers | Where-Object { $_.Id -eq $item.type } | Select-Object -First 1
            if ($p) { Write-Host "[$($p.Badge)] " -ForegroundColor $p.BadgeColor -NoNewline }
        }

        Write-Host "$($item.displayName)" -ForegroundColor $color -NoNewline
        Write-Host " ($($item.modified))" -ForegroundColor DarkGray
        
        # Show additional info for OpenCode sessions
        if ($IsSessionMode -and $item.type -eq 'opencode-session') {
            if ($item.additions -gt 0 -or $item.deletions -gt 0) {
                Write-Host "      [+$($item.additions) -$($item.deletions) in $($item.files) file(s)]" -ForegroundColor DarkGray
            }
        }

        # Show last session summary for Copilot projects
        if (-not $IsSessionMode -and $item.type -eq 'copilot' -and $item.summary) {
            Write-Host "      $($item.summary)" -ForegroundColor DarkGray
        }
    }
    
    if ($pageEnd -lt $Items.Count) { Write-Host "  (scroll down for newer)" -ForegroundColor DarkGray }
    
    # Show available commands based on mode
    Write-Host "  " -NoNewline
    Write-Host "[R]efresh" -ForegroundColor DarkGray -NoNewline
    if ($IsSessionMode) { Write-Host " | [B]ack" -ForegroundColor DarkGray -NoNewline }
    Write-Host " | [Q]uit" -ForegroundColor DarkGray
}

# ==================== Key Handling Functions ====================
function Handle-NavigationKey {
    <#
    .SYNOPSIS
        Process navigation keys (Up/Down arrows)
    #>
    param(
        [int]$CurrentIndex,
        [int]$ItemCount,
        [ConsoleKeyInfo]$Key,
        [ref]$SelectedIndex,
        [ref]$PageOffset
    )
    
    if ($key.Key -eq [ConsoleKey]::UpArrow) {
        if ($CurrentIndex -gt 0) {
            $SelectedIndex.Value = $CurrentIndex - 1
            if ($SelectedIndex.Value -lt $PageOffset.Value) {
                $PageOffset.Value = [Math]::Max(0, $SelectedIndex.Value - $PageSize + 1)
            }
        }
    }
    elseif ($key.Key -eq [ConsoleKey]::DownArrow) {
        if ($CurrentIndex -lt $ItemCount - 1) {
            $SelectedIndex.Value = $CurrentIndex + 1
            if ($SelectedIndex.Value -ge $PageOffset.Value + $PageSize) {
                $PageOffset.Value = $SelectedIndex.Value - $PageSize + 1
            }
        }
    }
}

function Handle-ControlKey {
    <#
    .SYNOPSIS
        Process control keys (R for Refresh, Q for Quit, B for Back)
    .RETURNS
        Hashtable with action: 'continue', 'refresh', 'back', 'quit', or $null for no action
    #>
    param(
        [ConsoleKeyInfo]$Key,
        [bool]$IsSessionMode
    )
    
    $char = [char]$key.KeyChar
    
    if ($char -eq [char]13) {  # Enter key (also handled by $key.Key -eq [ConsoleKey]::Enter)
        return @{ action = 'select' }
    }
    elseif ($key.Key -eq [ConsoleKey]::Escape) {
        if ($IsSessionMode) {
            return @{ action = 'back' }
        } else {
            return @{ action = 'quit' }
        }
    }
    elseif ($char -eq 'r' -or $char -eq 'R') {
        return @{ action = 'refresh' }
    }
    elseif ($char -eq 'q' -or $char -eq 'Q') {
        return @{ action = 'quit' }
    }
    elseif (($char -eq 'b' -or $char -eq 'B') -and $IsSessionMode) {
        return @{ action = 'back' }
    }
    
    return $null
}

function Refresh-ItemList {
    param([bool]$IsSessionMode, [string]$ProjectId = $null, [string]$ProjectType = $null)

    Clear-Host
    Write-Host "Refreshing..." -ForegroundColor Cyan
    Start-Sleep -Milliseconds 800
    Remove-Item -Path $CacheFile -Force -ErrorAction SilentlyContinue | Out-Null

    if ($IsSessionMode) {
        $provider = $script:Providers | Where-Object { $_.Id -eq $ProjectType } | Select-Object -First 1
        if ($provider -and $provider.GetSessions) {
            return & $provider.GetSessions $ProjectId $provider.StorageDir
        }
        return @()
    }

    if ($detectedMode -eq 'all') {
        return Get-AllProjectList
    }

    return & $activeProvider.GetProjects $activeProvider.DataDir $activeProvider.CacheFile $CacheMaxAgeMinutes
}

# ==================== Main UI Logic ====================
function Show-Chooser {
    <#
    .SYNOPSIS
        Main interactive chooser interface for selecting projects or sessions
    .PARAMETER Items
        Array of projects or sessions to choose from
    .PARAMETER IsSessionMode
        Whether displaying sessions instead of projects
    .PARAMETER ParentProject
        Parent project (for context in session mode)
    #>
    param([object[]]$Items, [bool]$IsSessionMode = $false, [object]$ParentProject = $null)
    
    if ($Items.Count -eq 0) {
        Write-Host "No items found" -ForegroundColor Yellow
        if ($IsSessionMode) {
            Write-Host "Press any key to go back..."
            $null = [Console]::ReadKey($true)
            return @{ selected = $false }
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
        }
        Write-Host "$($UI.KeyUp) $($UI.Arrow) Choose | $($UI.KeyEnter) $($UI.Arrow) Open" -ForegroundColor DarkGray -NoNewline
        if ($IsSessionMode) {
            Write-Host " | B $($UI.Arrow) Back" -ForegroundColor DarkGray -NoNewline
        }
        Write-Host " | $($UI.KeyEsc) $($UI.Arrow) Exit`n" -ForegroundColor DarkGray
        
        Show-Page $pageOffset $selectedIndex $Items $IsSessionMode
        
        $key = [Console]::ReadKey($true)
        
        # Try to handle as control key first
        $controlAction = Handle-ControlKey $key $IsSessionMode
        
        if ($controlAction) {
            switch ($controlAction.action) {
                'select' {
                    return @{ selected = $true; index = $selectedIndex }
                }
                'refresh' {
                    $newItems = Refresh-ItemList $IsSessionMode $(if ($IsSessionMode) { $ParentProject.id }) $(if ($IsSessionMode) { $ParentProject.type })
                    if ($newItems.Count -eq 0) {
                        if ($IsSessionMode) {
                            Write-Host "No items found after refresh" -ForegroundColor Yellow
                            Start-Sleep -Seconds 1
                            return @{ selected = $false }
                        } else {
                            Write-Error "No items found after refresh"
                            exit 1
                        }
                    }
                    $Items = $newItems
                    $selectedIndex = $Items.Count - 1
                    $pageOffset = [Math]::Max(0, $Items.Count - $PageSize)
                }
                'back' {
                    return @{ selected = $false }
                }
                'quit' {
                    exit 0
                }
            }
        } else {
            # Handle navigation keys
            Handle-NavigationKey $selectedIndex $Items.Count $key ([ref]$selectedIndex) ([ref]$pageOffset)
        }
    }
}

# ==================== Main Entry Point ====================
# Validate directories before proceeding
if (-not (Test-DirectoriesExist -DetectedMode $detectedMode)) {
    exit 1
}

# Load initial projects based on detected mode
if ($detectedMode -eq 'all') {
    $allProjects = Get-AllProjectList
} else {
    $allProjects = @(& $activeProvider.GetProjects $activeProvider.DataDir $activeProvider.CacheFile $CacheMaxAgeMinutes)
}

# Double-check we have projects
if ($allProjects.Count -eq 0) {
    Show-NoProjectsError -Mode $detectedMode -ProjectsDir $ProjectsDir
    exit 1
}

# Main loop for project selection
while ($true) {
    $result = Show-Chooser $allProjects $false

    if ($result -is [hashtable] -and $result.selected) {
        $selectedProject = $allProjects[$result.index]

        # Resolve the provider for the selected project
        $projectType     = if ($detectedMode -eq 'all') { $selectedProject.type } else { $detectedMode }
        $launchProvider  = $script:Providers | Where-Object { $_.Id -eq $projectType } | Select-Object -First 1

        # For providers that support session browsing, optionally show sessions first
        if ($launchProvider -and $launchProvider.GetSessions -and $OpenCodeSessionMode -eq 'sessions') {
            $sessions = & $launchProvider.GetSessions $selectedProject.id $launchProvider.StorageDir
            if ($sessions.Count -gt 0) {
                $sessionResult = Show-Chooser $sessions $true $selectedProject
                if ($sessionResult -is [hashtable] -and $sessionResult.selected) {
                    $selectedSession = $sessions[$sessionResult.index]
                    $projectPath     = $selectedSession.fullPath
                } else {
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
        $pwshExe   = (Get-Command pwsh).Source
        $launchCmd = if ($launchProvider) { $launchProvider.LaunchCmd } else { $projectType }

        Start-Process -FilePath $pwshExe -ArgumentList "-NoExit", "-Command", "Set-Location '$projectPath'; $launchCmd"
        Clear-Host
    }
}
