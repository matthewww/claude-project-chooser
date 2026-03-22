# GitHub Copilot CLI provider
# Reads sessions from ~/.copilot/session-state — each UUID folder contains a workspace.yaml.
# Deduplicates by project path (git_root preferred, fallback to cwd), keeping the most recent session.

Register-Provider @{
    Id         = 'copilot'
    Name       = 'Copilot'
    Badge      = 'GH'
    BadgeColor = 'Magenta'
    DataDir    = Join-Path $env:USERPROFILE ".copilot\session-state"
    CacheFile  = "$env:TEMP\.copilot-projects-cache.txt"
    LaunchCmd  = 'copilot'
    InstallUrl = 'https://github.com/features/copilot'

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

        # Simple key: value YAML parser (handles Windows paths containing colons)
        function ParseYaml([string]$path) {
            $r = @{}
            Get-Content $path -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_ -match '^([^:]+):\s*(.*)$') { $r[$matches[1].Trim()] = $matches[2].Trim() }
            }
            $r
        }

        $map     = @{}
        $folders = @(Get-ChildItem -Path $DataDir -Directory -ErrorAction SilentlyContinue)

        foreach ($folder in $folders) {
            $yamlPath = Join-Path $folder.FullName "workspace.yaml"
            if (-not (Test-Path $yamlPath)) { continue }
            try {
                $y    = ParseYaml $yamlPath
                $path = if ($y.git_root -and -not [string]::IsNullOrWhiteSpace($y.git_root)) {
                    $y.git_root
                } elseif ($y.cwd -and -not [string]::IsNullOrWhiteSpace($y.cwd)) {
                    $y.cwd
                } else { $null }

                if (-not $path -or -not (Test-Path $path)) { continue }

                $date = if ($y.updated_at) {
                    try { [datetime]::Parse($y.updated_at) } catch { $folder.LastWriteTime }
                } else { $folder.LastWriteTime }

                if (-not $map.ContainsKey($path) -or $date -gt $map[$path].sortDate) {
                    $map[$path] = @{
                        id          = $y.id
                        displayName = if ($y.repository -and -not [string]::IsNullOrWhiteSpace($y.repository)) { $y.repository } else { Split-Path -Leaf $path }
                        fullPath    = $path
                        repository  = $y.repository
                        branch      = $y.branch
                        summary     = $y.summary
                        modified    = Format-RelativeTime $date
                        sortDate    = $date
                        type        = 'copilot'
                    }
                }
            } catch {}
        }

        $list = @($map.Values | Sort-Object { $_.sortDate })

        if ($list.Count -gt 0) {
            try { $list | ConvertTo-Json | Set-Content $CacheFile -ErrorAction SilentlyContinue } catch {}
        }
        return @($list)
    }
}
