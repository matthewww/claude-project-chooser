#!/bin/bash
# Quick script to create the v2.0.0 release
# Run this from your local machine with push access

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Creating Claude Project Chooser v2.0.0 Release"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "✓ Checking out branch..."
git checkout copilot/plan-windows-taskbar-app

echo "✓ Pulling latest changes..."
git pull origin copilot/plan-windows-taskbar-app

echo "✓ Creating tag v2.0.0..."
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

echo "✓ Pushing tag to GitHub..."
git push origin v2.0.0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Tag pushed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 Release is being built automatically by GitHub Actions!"
echo ""
echo "Monitor the build:"
echo "  https://github.com/matthewww/claude-project-chooser/actions"
echo ""
echo "Check the release (available in ~10-15 minutes):"
echo "  https://github.com/matthewww/claude-project-chooser/releases"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
