# Quick Release Script (PowerShell)
# Run this from your local machine with push access

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🚀 Creating Claude Project Chooser v2.0.0 Release" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "✓ Checking out branch..." -ForegroundColor Yellow
git checkout copilot/plan-windows-taskbar-app

Write-Host "✓ Pulling latest changes..." -ForegroundColor Yellow
git pull origin copilot/plan-windows-taskbar-app

Write-Host "✓ Creating tag v2.0.0..." -ForegroundColor Yellow
git tag -a v2.0.0 -m "Release v2.0.0 - Initial Windows Taskbar App

First release of Claude Project Chooser with Windows taskbar application.

Features:
- Windows system tray application for quick access to Claude projects
- Original CLI tool (jmp command) for terminal users
- Automated builds with GitHub Actions
- Multiple platform support (x64, ARM64)
- Self-contained and framework-dependent variants

What's included:
- Taskbar app with auto-refresh and project caching
- CLI version with PowerShell installer
- Comprehensive documentation
- Build and release automation"

Write-Host "✓ Pushing tag to GitHub..." -ForegroundColor Yellow
git push origin v2.0.0

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ Tag pushed successfully!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 Release is being built automatically by GitHub Actions!" -ForegroundColor Green
Write-Host ""
Write-Host "Monitor the build:" -ForegroundColor Cyan
Write-Host "  https://github.com/matthewww/claude-project-chooser/actions" -ForegroundColor Gray
Write-Host ""
Write-Host "Check the release (available in ~10-15 minutes):" -ForegroundColor Cyan
Write-Host "  https://github.com/matthewww/claude-project-chooser/releases" -ForegroundColor Gray
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
