# OpenCode provider
# Reads projects from ~/.local/share/opencode/storage/project — each .json file is a project.
# Supports optional session browsing via GetSessions.

$_ocStorageDir = Join-Path $env:USERPROFILE ".local\share\opencode\storage"

Register-Provider @{
    Id         = 'opencode'
    Name       = 'OpenCode'
    Badge      = 'OC'
    BadgeColor = 'Yellow'
    DataDir    = Join-Path $_ocStorageDir "project"
    StorageDir = $_ocStorageDir
    CacheFile  = "$env:TEMP\.opencode-projects-cache.txt"
    LaunchCmd  = 'opencode'
    InstallUrl = 'https://opencode.ai'

    GetProjects = {
        param([string]$DataDir, [string]$CacheFile, [int]$CacheMaxAge)

        if (Test-Path $CacheFile) {
            $age = (Get-Date) - (Get-Item $CacheFile).LastWriteTime
            if ($age.TotalMinutes -lt $CacheMaxAge) {
                try {
                    $cached = @(Get-Content $CacheFile | ConvertFrom-Json)
                    $valid  = @($cached | Where-Object { -not [string]::IsNullOrWhiteSpace($_.worktree) })
                    if ($valid.Count -gt 0) { return @($valid) }
                } catch {
                    Remove-Item $CacheFile -Force -ErrorAction SilentlyContinue
                }
            }
        }

        $list = @()
        if (-not (Test-Path $DataDir)) { return @() }

        try {
            $files = @(Get-ChildItem -Path $DataDir -Filter "*.json" -File -ErrorAction Stop |
                       Sort-Object LastWriteTime)
        } catch { return @() }

        foreach ($file in $files) {
            try {
                $p = Get-Content $file.FullName | ConvertFrom-Json
                if ($p.id -and $p.worktree -and (Test-Path $p.worktree)) {
                    $list += @{
                        id          = $p.id
                        displayName = Split-Path -Leaf $p.worktree
                        worktree    = $p.worktree
                        fullPath    = $p.worktree
                        vcs         = $p.vcs
                        modified    = Format-RelativeTime $file.LastWriteTime
                        sortDate    = $file.LastWriteTime
                        type        = 'opencode'
                    }
                }
            } catch {}
        }

        if ($list.Count -gt 0) {
            try { $list | ConvertTo-Json | Set-Content $CacheFile -ErrorAction SilentlyContinue } catch {}
        }
        return @($list)
    }

    GetSessions = {
        param([string]$ProjectId, [string]$StorageDir)
        $sessionsDir = Join-Path $StorageDir "session"
        $projDir     = Join-Path $sessionsDir $ProjectId
        if (-not (Test-Path $projDir)) { return @() }

        try {
            $files = @(Get-ChildItem -Path $projDir -Filter "*.json" -File -ErrorAction Stop |
                       Sort-Object LastWriteTime -Descending)
        } catch { return @() }

        $sessions = @()
        foreach ($file in $files) {
            try {
                $s = Get-Content $file.FullName | ConvertFrom-Json
                if ($s.id) {
                    $sessions += @{
                        id          = $s.id
                        slug        = $s.slug
                        displayName = if ($s.title) { $s.title } else { $s.slug }
                        fullPath    = $s.directory
                        modified    = Format-RelativeTime $file.LastWriteTime
                        sortDate    = $file.LastWriteTime
                        additions   = $s.summary.additions
                        deletions   = $s.summary.deletions
                        files       = $s.summary.files
                        type        = 'opencode-session'
                    }
                }
            } catch {}
        }
        return @($sessions)
    }
}
