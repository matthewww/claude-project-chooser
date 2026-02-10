# How to Create the v2.0.0 Release

## Ready to Release! 🚀

Everything is set up and ready for the first release. The automated release system is in place and will handle all the building and packaging automatically.

## Create the Release (Simple Method)

Run these commands from your local machine where you have push access:

```bash
# 1. Make sure you're on the latest code
git checkout copilot/plan-windows-taskbar-app
git pull origin copilot/plan-windows-taskbar-app

# 2. Create the release tag
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

# 3. Push the tag to GitHub
git push origin v2.0.0

# 4. Watch the magic happen!
# The GitHub Actions workflow will automatically:
#   - Build all platform variants
#   - Package everything as ZIP files
#   - Create a GitHub release
#   - Upload all artifacts
#   - Generate release notes
```

## What Happens Next

Once you push the tag, GitHub Actions will:

1. **Trigger the Release Workflow** (~10-15 minutes)
   - Monitor at: https://github.com/matthewww/claude-project-chooser/actions

2. **Build All Variants**
   - Windows x64 self-contained (~80MB)
   - Windows x64 framework-dependent (~1MB)
   - Windows ARM64 self-contained (~80MB)
   - Standalone .exe
   - CLI version package

3. **Create GitHub Release**
   - Release page: https://github.com/matthewww/claude-project-chooser/releases
   - All artifacts uploaded
   - Professional release notes generated

## Expected Artifacts

After the workflow completes, users will be able to download:

1. `ClaudeProjectChooser-2.0.0-win-x64.zip` (Self-contained, ~80MB)
2. `ClaudeProjectChooser-2.0.0-win-x64-framework.zip` (Framework-dependent, ~1MB)
3. `ClaudeProjectChooser-2.0.0-win-arm64.zip` (ARM64, ~80MB)
4. `ClaudeProjectChooser-2.0.0-win-x64.exe` (Standalone executable)
5. `ClaudeProjectChooser-CLI-2.0.0.zip` (CLI version)

## Verification Checklist

After pushing the tag:

- [ ] Check GitHub Actions: https://github.com/matthewww/claude-project-chooser/actions
  - Look for "Build and Release" workflow
  - Verify all jobs complete successfully
  
- [ ] Check the Release: https://github.com/matthewww/claude-project-chooser/releases
  - Verify v2.0.0 release is created
  - Confirm all 5 artifacts are uploaded
  - Review the release notes
  
- [ ] Test Download
  - Download one of the artifacts
  - Extract and test the application
  - Verify it runs correctly

## Troubleshooting

If the workflow fails:
1. Check the Actions logs for errors
2. Review the RELEASE_GUIDE.md for troubleshooting tips
3. The workflow can be re-run from the Actions page

## Alternative: Create Release from GitHub UI

If you prefer using the GitHub web interface:

1. Go to: https://github.com/matthewww/claude-project-chooser/releases
2. Click "Draft a new release"
3. Click "Choose a tag" and type `v2.0.0`, then "Create new tag: v2.0.0 on publish"
4. Set the target to `copilot/plan-windows-taskbar-app` branch
5. Title: "Claude Project Chooser v2.0.0"
6. Description: Use the release notes template from RELEASE_GUIDE.md
7. Click "Publish release"

The workflow will trigger when you publish!

## Current Status

✅ Version set to 2.0.0 in .csproj
✅ Automated release workflows configured
✅ Documentation complete
✅ Branch ready: copilot/plan-windows-taskbar-app
✅ All code committed and pushed

**Ready to release!** Just push the tag and watch the automation work! 🎉
