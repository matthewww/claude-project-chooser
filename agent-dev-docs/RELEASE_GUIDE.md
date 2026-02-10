# Release Guide

This document explains how to create a new release of Claude Project Chooser.

## Automated Release Process

The repository uses GitHub Actions to automatically build and publish releases when you create a new tag.

## Creating a Release

### 1. Update Version Numbers

Before creating a release, update the version number in the project file:

Edit `src/ClaudeProjectChooser/ClaudeProjectChooser.csproj`:
```xml
<Version>2.1.0</Version>  <!-- Change this -->
```

Commit this change:
```bash
git add src/ClaudeProjectChooser/ClaudeProjectChooser.csproj
git commit -m "Bump version to 2.1.0"
git push
```

### 2. Create and Push a Tag

Create a new tag for the release:

```bash
# Create an annotated tag (recommended)
git tag -a v2.1.0 -m "Release version 2.1.0"

# Push the tag to GitHub
git push origin v2.1.0
```

### 3. Automated Build Process

Once the tag is pushed, GitHub Actions will automatically:

1. **Build the Windows Taskbar App**
   - Build for Windows x64 (self-contained)
   - Build for Windows x64 (framework-dependent)
   - Build for Windows ARM64 (self-contained)
   - Create ZIP archives for each variant
   - Create standalone EXE for x64

2. **Package the CLI Version**
   - Package PowerShell scripts
   - Include installer and documentation
   - Create ZIP archive

3. **Create GitHub Release**
   - Create a new release on GitHub
   - Upload all artifacts
   - Generate release notes
   - Make the release public

### 4. Monitor the Build

You can monitor the build progress at:
```
https://github.com/matthewww/claude-project-chooser/actions
```

The release workflow typically takes 5-10 minutes to complete.

### 5. Verify the Release

Once complete, verify the release at:
```
https://github.com/matthewww/claude-project-chooser/releases
```

Check that all expected files are present:
- `ClaudeProjectChooser-X.X.X-win-x64.zip` (Self-contained, ~80MB)
- `ClaudeProjectChooser-X.X.X-win-x64-framework.zip` (Framework-dependent, ~1MB)
- `ClaudeProjectChooser-X.X.X-win-arm64.zip` (ARM64, ~80MB)
- `ClaudeProjectChooser-X.X.X-win-x64.exe` (Standalone executable)
- `ClaudeProjectChooser-CLI-X.X.X.zip` (CLI version)

## Manual Release (If Needed)

If you need to create a release manually or test the build locally:

### Build Locally (Windows Only)

```powershell
# Build and publish all variants
.\build.ps1 -Publish

# Or build specific variants
dotnet publish src/ClaudeProjectChooser/ClaudeProjectChooser.csproj `
  -c Release `
  -r win-x64 `
  --self-contained true `
  -p:PublishSingleFile=true `
  -o publish/win-x64
```

### Create Release Manually

1. Go to https://github.com/matthewww/claude-project-chooser/releases
2. Click "Draft a new release"
3. Choose or create a tag (e.g., `v2.1.0`)
4. Fill in the release title and description
5. Upload the built artifacts
6. Click "Publish release"

## Triggering Manual Builds

You can manually trigger the release workflow without creating a tag:

1. Go to: https://github.com/matthewww/claude-project-chooser/actions
2. Click on "Build and Release" workflow
3. Click "Run workflow"
4. Enter the version number (e.g., `2.1.0`)
5. Click "Run workflow"

This will build the artifacts but won't create a GitHub release.

## Release Checklist

Before creating a release:

- [ ] Update version in `ClaudeProjectChooser.csproj`
- [ ] Update CHANGELOG or release notes (if maintaining one)
- [ ] Test the build locally on Windows
- [ ] Verify all features work as expected
- [ ] Update documentation if needed
- [ ] Commit all changes
- [ ] Create and push the tag
- [ ] Monitor the GitHub Actions workflow
- [ ] Verify the release on GitHub
- [ ] Test downloaded artifacts
- [ ] Announce the release (if applicable)

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **Major version** (X.0.0): Breaking changes or major new features
- **Minor version** (2.X.0): New features, backward compatible
- **Patch version** (2.1.X): Bug fixes, backward compatible

Examples:
- `v2.0.0` - Initial taskbar app release
- `v2.1.0` - Add settings dialog feature
- `v2.1.1` - Fix crash on startup bug
- `v3.0.0` - Major redesign with breaking changes

## Release Artifacts Explained

### Self-Contained (Recommended)
- **File**: `ClaudeProjectChooser-X.X.X-win-x64.zip`
- **Size**: ~80-100 MB
- **Requirements**: Windows 10+ (x64)
- **Includes**: .NET runtime bundled
- **Best for**: Distribution to users who don't have .NET installed

### Framework-Dependent
- **File**: `ClaudeProjectChooser-X.X.X-win-x64-framework.zip`
- **Size**: ~1-2 MB
- **Requirements**: Windows 10+ (x64) + .NET 8.0 Runtime
- **Best for**: Users who already have .NET 8.0 installed

### ARM64
- **File**: `ClaudeProjectChooser-X.X.X-win-arm64.zip`
- **Size**: ~80-100 MB
- **Requirements**: Windows 10+ (ARM64)
- **Best for**: Surface Pro X and other ARM64 Windows devices

### CLI Version
- **File**: `ClaudeProjectChooser-CLI-X.X.X.zip`
- **Size**: <100 KB
- **Requirements**: Windows with PowerShell
- **Best for**: Terminal users who prefer the `jmp` command

## Troubleshooting

### Build Fails on GitHub Actions

1. Check the Actions logs for errors
2. Ensure .NET SDK 8.0 is properly configured
3. Verify the project file is valid
4. Check for missing dependencies

### Tag Already Exists

If you need to recreate a tag:
```bash
# Delete local tag
git tag -d v2.1.0

# Delete remote tag
git push origin :refs/tags/v2.1.0

# Create new tag
git tag -a v2.1.0 -m "Release version 2.1.0"

# Push new tag
git push origin v2.1.0
```

### Release Not Created

- Verify the tag matches the pattern `v*`
- Check GitHub Actions permissions
- Ensure `GITHUB_TOKEN` has write permissions
- Review Actions logs for errors

## Post-Release Tasks

After creating a release:

1. Test the downloaded artifacts on a clean Windows machine
2. Update the main README if needed
3. Close related issues/PRs
4. Announce on relevant channels
5. Plan next release features

## Getting Help

If you encounter issues:
- Check GitHub Actions logs
- Review this guide
- Open an issue on GitHub
- Check .NET build documentation

---

**Note**: The first time you create a release, GitHub Actions may need permissions configured. Check repository Settings → Actions → General → Workflow permissions.
