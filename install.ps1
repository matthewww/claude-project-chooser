#!/usr/bin/env pwsh
<#
.SYNOPSIS
Installs the Claude Project Chooser tool to ~/.claude/bin and adds it to PATH.

.DESCRIPTION
This script:
1. Creates ~/.claude/bin if it doesn't exist
2. Copies jmp.bat and choose-claude-project.ps1 to that directory
3. Adds ~/.claude/bin to the user's PATH environment variable
4. Provides instructions for updating PATH in the current session

.EXAMPLE
.\install.ps1
#>

param(
    [switch]$Force
)

$claudeBinDir = Join-Path $env:USERPROFILE ".claude\bin"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Claude Project Chooser Installer" -ForegroundColor Cyan
Write-Host "================================`n"

# Create directory if it doesn't exist
if (-not (Test-Path $claudeBinDir)) {
    Write-Host "Creating directory: $claudeBinDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $claudeBinDir -Force | Out-Null
} else {
    Write-Host "Directory exists: $claudeBinDir" -ForegroundColor Green
}

# Copy files
$filesToCopy = @("jmp.bat", "choose-claude-project.ps1")
foreach ($file in $filesToCopy) {
    $source = Join-Path $scriptDir $file
    $destination = Join-Path $claudeBinDir $file

    if (Test-Path $source) {
        Write-Host "Copying $file..." -ForegroundColor Yellow
        Copy-Item -Path $source -Destination $destination -Force
        Write-Host "  ✓ Installed to $destination" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Error: $file not found in source directory" -ForegroundColor Red
        exit 1
    }
}

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($currentPath -contains $claudeBinDir) {
    Write-Host "`n✓ $claudeBinDir is already in PATH" -ForegroundColor Green
} else {
    Write-Host "`nAdding to PATH..." -ForegroundColor Yellow
    $newPath = "$claudeBinDir;$currentPath"
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "✓ Added to user PATH" -ForegroundColor Green
}

# Instructions
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "`nTo use 'jmp' in this PowerShell session, run:" -ForegroundColor Cyan
Write-Host "`$env:Path = `"$claudeBinDir;`$env:Path`"" -ForegroundColor Gray
Write-Host "`nFor future sessions, close and reopen PowerShell." -ForegroundColor Cyan
Write-Host "`nThen simply type: jmp" -ForegroundColor Green
