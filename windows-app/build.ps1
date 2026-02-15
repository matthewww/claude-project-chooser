#!/usr/bin/env pwsh
<#
.SYNOPSIS
Builds the Agentic Project Chooser taskbar application

.DESCRIPTION
This script builds the Windows taskbar application in Release mode.
Run this on a Windows machine with .NET 8.0 SDK installed.
Must be run from the windows-app directory.

.EXAMPLE
.\build.ps1
.\build.ps1 -Clean
.\build.ps1 -Publish
#>

param(
    [switch]$Clean,
    [switch]$Publish
)

$ErrorActionPreference = "Stop"
$ProjectPath = Join-Path $PSScriptRoot "ClaudeProjectChooser.csproj"

Write-Host "Agentic Project Chooser - Windows Taskbar App Build Script" -ForegroundColor Cyan
Write-Host "=========================================================`n" -ForegroundColor Cyan

# Check if .NET SDK is installed
try {
    $dotnetVersion = dotnet --version
    Write-Host "✓ .NET SDK version: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ .NET SDK not found. Please install .NET 8.0 SDK from:" -ForegroundColor Red
    Write-Host "  https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
    exit 1
}

# Clean if requested
if ($Clean) {
    Write-Host "`nCleaning previous builds..." -ForegroundColor Yellow
    dotnet clean $ProjectPath -c Release
    Write-Host "✓ Clean complete" -ForegroundColor Green
}

# Build
Write-Host "`nBuilding application..." -ForegroundColor Yellow
dotnet build $ProjectPath -c Release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Build successful!" -ForegroundColor Green
    
    $outputPath = Join-Path $PSScriptRoot "bin/Release/net8.0-windows/ClaudeProjectChooser.exe"
    
    if (Test-Path $outputPath) {
        Write-Host "`nExecutable location:" -ForegroundColor Cyan
        Write-Host "  $outputPath" -ForegroundColor Gray
    }
} else {
    Write-Host "✗ Build failed!" -ForegroundColor Red
    exit 1
}

# Publish if requested
if ($Publish) {
    Write-Host "`nPublishing self-contained application..." -ForegroundColor Yellow
    
    $publishPath = Join-Path $PSScriptRoot "publish"
    
    dotnet publish $ProjectPath `
        -c Release `
        -r win-x64 `
        --self-contained true `
        -p:PublishSingleFile=true `
        -p:IncludeNativeLibrariesForSelfExtract=true `
        -o $publishPath

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Publish successful!" -ForegroundColor Green
        Write-Host "`nPublished application:" -ForegroundColor Cyan
        Write-Host "  $publishPath\ClaudeProjectChooser.exe" -ForegroundColor Gray
        Write-Host "`nThis is a self-contained executable that includes the .NET runtime." -ForegroundColor Yellow
        Write-Host "You can distribute this file without requiring .NET to be installed." -ForegroundColor Yellow
    } else {
        Write-Host "✗ Publish failed!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n=========================================================`n" -ForegroundColor Cyan
Write-Host "To run the application:" -ForegroundColor Cyan
Write-Host "  1. Navigate to the output directory" -ForegroundColor Gray
Write-Host "  2. Double-click ClaudeProjectChooser.exe" -ForegroundColor Gray
Write-Host "  3. Look for the icon in your system tray" -ForegroundColor Gray
Write-Host "`nTo publish a standalone executable:" -ForegroundColor Cyan
Write-Host "  .\build.ps1 -Publish" -ForegroundColor Gray
