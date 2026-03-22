# Claude Code provider
# Reads projects from ~/.claude/projects — each sub-folder contains a .jsonl metadata file.

Register-Provider @{
    Id         = 'claude'
    Name       = 'Claude'
    Badge      = 'CL'
    BadgeColor = 'Cyan'
    DataDir    = Join-Path $env:USERPROFILE ".claude\projects"
    CacheFile  = "$env:TEMP\.claude-projects-cache.txt"
    LaunchCmd  = 'claude'
    InstallUrl = 'https://claude.ai'

    GetProjects = {
        param([string]$DataDir, [string]$CacheFile, [int]$CacheMaxAge)

        if (Test-Path $CacheFile) {
            $age = (Get-Date) - (Get-Item $CacheFile).LastWriteTime
            if ($age.TotalMinutes -lt $CacheMaxAge) {
                try {
                    $cached = @(Get-Content $CacheFile | ConvertFrom-Json)
                    $valid  = @($cached | Where-Object { -not [string]::IsNullOrWhiteSpace($_.fullPath) })
                    if ($valid.Count -gt 0) { return @($valid) }
                } catch {
                    Remove-Item $CacheFile -Force -ErrorAction SilentlyContinue
                }
            }
        }

        $list = @()
        try {
            $dirs = @(Get-ChildItem -Path $DataDir -Directory -ErrorAction Stop | Sort-Object LastWriteTime)
        } catch { return @() }

        foreach ($dir in $dirs) {
            try {
                $jsonl = Get-ChildItem -Path $dir.FullName -Filter "*.jsonl" -File |
                         Select-Object -First 1
                if (-not $jsonl) { continue }

                $cwd = Get-Content $jsonl.FullName | ForEach-Object {
                    try { $o = $_ | ConvertFrom-Json; if ($o.cwd) { return $o.cwd } } catch {}
                } | Select-Object -First 1

                if ($cwd -and -not [string]::IsNullOrWhiteSpace($cwd)) {
                    $list += @{
                        sessionName = $dir.Name
                        displayName = $cwd
                        fullPath    = $cwd
                        modified    = Format-RelativeTime $dir.LastWriteTime
                        sortDate    = $dir.LastWriteTime
                        type        = 'claude'
                    }
                }
            } catch {}
        }

        if ($list.Count -gt 0) {
            try { $list | ConvertTo-Json | Set-Content $CacheFile -ErrorAction SilentlyContinue } catch {}
        }
        return @($list)
    }
}
