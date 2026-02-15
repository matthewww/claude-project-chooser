# Automated Release System - Complete Setup

## Overview

The Claude Project Chooser repository now has a fully automated release system using GitHub Actions. This enables one-command releases with automatic building, packaging, and publishing.

## What Was Created

### 1. GitHub Actions Workflows

#### Build and Test Workflow (`.github/workflows/build.yml`)
- **Triggers**: Push to `main`, `copilot/**` branches, and PRs to `main`
- **Purpose**: Continuous integration testing
- **Actions**:
  - Builds Debug and Release configurations
  - Validates PowerShell script syntax
  - Tests publish process
  - Uploads build artifacts (7-day retention)
- **Runtime**: ~5 minutes
- **Status Badge**: Shows on README

#### Release Workflow (`.github/workflows/release.yml`)
- **Triggers**: Git tags matching `v*` pattern (e.g., `v2.0.0`)
- **Purpose**: Automated release creation
- **Actions**:
  - Builds Windows x64 self-contained (~80MB)
  - Builds Windows x64 framework-dependent (~1MB)
  - Builds Windows ARM64 self-contained (~80MB)
  - Creates standalone .exe
  - Packages CLI version
  - Generates release notes
  - Creates GitHub release
  - Uploads all artifacts
- **Runtime**: ~10-15 minutes
- **Status Badge**: Shows on README

### 2. Release Artifacts

Each release automatically creates 5 downloadable files:

1. **`ClaudeProjectChooser-X.X.X-win-x64.zip`**
   - Self-contained Windows x64 build
   - Includes .NET 8.0 runtime
   - Size: ~80-100 MB
   - No dependencies required
   - Recommended for most users

2. **`ClaudeProjectChooser-X.X.X-win-x64-framework.zip`**
   - Framework-dependent Windows x64 build
   - Requires .NET 8.0 Runtime installed
   - Size: ~1-2 MB
   - For users with .NET already installed

3. **`ClaudeProjectChooser-X.X.X-win-arm64.zip`**
   - Self-contained Windows ARM64 build
   - For ARM64 Windows devices (Surface Pro X, etc.)
   - Includes .NET 8.0 runtime
   - Size: ~80-100 MB

4. **`ClaudeProjectChooser-X.X.X-win-x64.exe`**
   - Standalone executable
   - Self-contained with runtime
   - Single file for easy distribution
   - Size: ~80-100 MB

5. **`ClaudeProjectChooser-CLI-X.X.X.zip`**
   - CLI version (PowerShell scripts)
   - Includes `jmp.bat`, `choose-claude-project.ps1`, `install.ps1`
   - Size: <100 KB
   - For terminal users

### 3. Documentation

#### `RELEASE_GUIDE.md` (6.3 KB)
Comprehensive guide covering:
- Complete release process
- Version numbering (Semantic Versioning)
- Manual release instructions
- Troubleshooting common issues
- Post-release checklist
- Requirements and prerequisites

#### `QUICK_RELEASE_REFERENCE.md` (2.6 KB)
Quick reference for:
- Creating releases (5-step process)
- Testing builds
- Local development
- Choosing downloads
- Common troubleshooting

#### `WORKFLOW_DIAGRAM.md` (6.4 KB)
Visual documentation including:
- Automated release process diagram
- Build variants breakdown
- CI/CD flow charts
- File naming conventions
- Timeline expectations

#### `README.md` (Updated)
Added:
- Build status badges (Build, Release, Latest Version)
- Download instructions with release links
- Updated installation section
- Professional presentation

### 4. Configuration Changes

#### `.gitignore` (Updated)
Added exclusions for:
- `release/` - Release packages
- `release-assets/` - Temporary release assets
- `artifacts/` - Downloaded artifacts

## How It Works

### Creating a Release

1. **Update Version**
   ```bash
   # Edit src/ClaudeProjectChooser/ClaudeProjectChooser.csproj
   # Change <Version>2.1.0</Version>
   ```

2. **Commit Changes**
   ```bash
   git add src/ClaudeProjectChooser/ClaudeProjectChooser.csproj
   git commit -m "Bump version to 2.1.0"
   git push
   ```

3. **Create and Push Tag**
   ```bash
   git tag -a v2.1.0 -m "Release 2.1.0"
   git push origin v2.1.0
   ```

4. **Automated Process**
   - GitHub Actions triggers
   - Builds all variants
   - Creates packages
   - Generates release notes
   - Publishes release

5. **Result**
   - Release appears at: `https://github.com/matthewww/claude-project-chooser/releases`
   - All artifacts uploaded
   - Professional release notes
   - Users can download immediately

### Build Process

```
Tag Push (v2.1.0)
    ↓
GitHub Actions Trigger
    ↓
Setup .NET SDK 8.0
    ↓
Build Windows x64 (Self-contained)
    ↓
Build Windows x64 (Framework)
    ↓
Build Windows ARM64
    ↓
Package CLI Version
    ↓
Create ZIP Archives
    ↓
Generate Release Notes
    ↓
Create GitHub Release
    ↓
Upload All Artifacts
    ↓
Publish Release ✓
```

## Continuous Integration

On every push to `main` or `copilot/**` branches:
- Builds are tested automatically
- PowerShell scripts are validated
- Test artifacts are uploaded
- Build status is updated
- No release is created (unless tag is pushed)

## Benefits

### For Maintainers
- **One-command releases**: Just push a tag
- **Consistent packaging**: Same process every time
- **Multiple variants**: x64, ARM64, self-contained, framework-dependent
- **Automatic release notes**: Generated from template
- **Build verification**: CI catches issues early
- **Version management**: Automated from tags

### For Users
- **Pre-built binaries**: No need to compile
- **Multiple options**: Choose what works best
- **Professional releases**: Clear documentation
- **Reliable downloads**: Consistent naming
- **ARM64 support**: Modern Windows devices
- **Easy installation**: Just download and run

### For Contributors
- **Clear process**: Well-documented
- **Automated testing**: Builds checked on PR
- **Fast feedback**: CI runs on every push
- **No manual steps**: Everything automated

## Release Notes Template

Each release automatically includes:
- Download links for all variants
- Requirements for each variant
- Installation instructions
- Documentation links
- Full changelog link

Example:
```markdown
## Claude Project Chooser v2.1.0

### Downloads

#### Windows Taskbar App
- Recommended: ClaudeProjectChooser-2.1.0-win-x64.zip
- Small: ClaudeProjectChooser-2.1.0-win-x64-framework.zip
- ARM64: ClaudeProjectChooser-2.1.0-win-arm64.zip

#### CLI Version
- ClaudeProjectChooser-CLI-2.1.0.zip

### Requirements
[Details about each variant...]

### Installation
[Step-by-step instructions...]
```

## Testing the System

### First Release
To test the release system:

```bash
# After merging to main
git checkout main
git pull

# Create first release tag
git tag -a v2.0.0 -m "Initial taskbar app release"
git push origin v2.0.0

# Monitor at:
# https://github.com/matthewww/claude-project-chooser/actions

# Check release at:
# https://github.com/matthewww/claude-project-chooser/releases
```

### Manual Test Build
To test without creating a release:

1. Go to: `https://github.com/matthewww/claude-project-chooser/actions`
2. Select "Build and Release" workflow
3. Click "Run workflow"
4. Enter version number (e.g., "2.0.0-test")
5. Click "Run workflow"
6. Artifacts will be uploaded but no release created

## Troubleshooting

### Build Fails
- Check Actions logs for errors
- Verify .NET SDK 8.0 compatibility
- Ensure project file is valid
- Check for missing dependencies

### Release Not Created
- Verify tag format: `v*` (e.g., `v2.0.0`)
- Check GitHub Actions permissions
- Ensure GITHUB_TOKEN has write access
- Review workflow run logs

### Artifacts Missing
- Verify build completed successfully
- Check upload steps in logs
- Ensure artifact names match pattern
- Verify retention settings

## Maintenance

### Updating Workflows
Edit workflow files:
- `.github/workflows/build.yml` - CI/testing
- `.github/workflows/release.yml` - Releases

Commit and push changes:
```bash
git add .github/workflows/
git commit -m "Update workflows"
git push
```

Changes take effect immediately on next run.

### Updating .NET Version
To update to .NET 9.0 (example):

1. Update workflows:
   ```yaml
   - name: Setup .NET
     uses: actions/setup-dotnet@v4
     with:
       dotnet-version: '9.0.x'
   ```

2. Update project file:
   ```xml
   <TargetFramework>net9.0-windows</TargetFramework>
   ```

3. Update documentation

### Adding New Platforms
To add Linux or macOS support (future):

1. Add jobs in `release.yml`
2. Update artifact packaging
3. Update release notes template
4. Update documentation

## Security

- Workflows run in isolated GitHub-hosted runners
- No secrets required for public releases
- GITHUB_TOKEN is automatically provided
- Artifacts are scanned by GitHub
- Published releases are public

## Performance

### Build Times
- CI Build: ~5 minutes
- Full Release: ~10-15 minutes
- Parallel jobs speed up process

### Artifact Sizes
- Self-contained: ~80-100 MB (includes runtime)
- Framework-dependent: ~1-2 MB (requires .NET)
- CLI: <100 KB (scripts only)

### Storage
- Test artifacts: 7-day retention
- Release artifacts: Permanent
- Total release size: ~250-300 MB per version

## Future Enhancements

Possible improvements:
- Code signing for executables
- Installer creation (MSI/EXE)
- Chocolatey package
- winget manifest
- Auto-update mechanism
- Pre-release tags (beta, rc)
- Release candidate workflow
- Automated changelog generation

## Resources

### Documentation
- `RELEASE_GUIDE.md` - Complete guide
- `QUICK_RELEASE_REFERENCE.md` - Quick commands
- `WORKFLOW_DIAGRAM.md` - Visual guides

### Links
- GitHub Actions: https://docs.github.com/en/actions
- .NET Publishing: https://docs.microsoft.com/en-us/dotnet/core/deploying/
- Semantic Versioning: https://semver.org/

### Support
- GitHub Issues: https://github.com/matthewww/claude-project-chooser/issues
- GitHub Discussions: (if enabled)
- README: For general questions

## Summary

The automated release system is complete and ready to use. It provides:

✅ **One-command releases** - Just push a tag
✅ **Multiple build variants** - x64, ARM64, self-contained, framework-dependent
✅ **Automatic packaging** - ZIP archives with proper naming
✅ **Professional releases** - Generated notes and documentation
✅ **CI/CD integration** - Build on every push
✅ **Clear documentation** - Multiple guides for different needs

**Next Step**: Create your first release by pushing a tag!

```bash
git tag -a v2.0.0 -m "Initial taskbar app release"
git push origin v2.0.0
```

Then watch the magic happen at:
https://github.com/matthewww/claude-project-chooser/actions
