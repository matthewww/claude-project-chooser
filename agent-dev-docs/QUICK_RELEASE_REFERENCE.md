# Quick Reference - Releases and Builds

## For Maintainers

### Create a New Release

1. **Update version** in `src/ClaudeProjectChooser/ClaudeProjectChooser.csproj`
2. **Commit and push** changes
3. **Create and push tag**:
   ```bash
   git tag -a v2.1.0 -m "Release 2.1.0"
   git push origin v2.1.0
   ```
4. **Monitor** at https://github.com/matthewww/claude-project-chooser/actions
5. **Verify** release at https://github.com/matthewww/claude-project-chooser/releases

### Test Builds Without Release

Run manually: https://github.com/matthewww/claude-project-chooser/actions

Or push to branch - builds run automatically on:
- Push to `main` or `copilot/**` branches
- Pull requests to `main`

### Local Testing

```powershell
# Build
.\build.ps1

# Publish self-contained
.\build.ps1 -Publish

# Or manually
dotnet publish src/ClaudeProjectChooser/ClaudeProjectChooser.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o publish
```

## For Users

### Download Latest Release

Go to: https://github.com/matthewww/claude-project-chooser/releases/latest

### Choose Your Version

- **Taskbar App (Recommended)**: `ClaudeProjectChooser-X.X.X-win-x64.zip` (~80MB, includes .NET)
- **Taskbar App (Small)**: `ClaudeProjectChooser-X.X.X-win-x64-framework.zip` (~1MB, needs .NET 8.0)
- **CLI Tool**: `ClaudeProjectChooser-CLI-X.X.X.zip` (PowerShell scripts)

## Artifacts Produced

Each release creates:

1. **Windows x64 Self-contained** (`~80MB`)
   - Includes .NET runtime
   - No installation needed
   - Best for most users

2. **Windows x64 Framework-dependent** (`~1MB`)
   - Requires .NET 8.0 Runtime
   - Smaller download
   - For users with .NET already installed

3. **Windows ARM64 Self-contained** (`~80MB`)
   - For ARM64 Windows devices
   - Surface Pro X, etc.

4. **Standalone EXE** (`~80MB`)
   - Single executable file
   - Self-contained

5. **CLI Version** (`<100KB`)
   - PowerShell scripts
   - `jmp` command tool

## Troubleshooting

### Build fails
- Check Actions logs
- Verify .csproj syntax
- Ensure .NET SDK 8.0 is available

### Release not created
- Verify tag format: `v*` (e.g., `v2.1.0`)
- Check GitHub token permissions
- Review Actions logs

### Artifacts missing
- Check if build completed successfully
- Verify upload steps in workflow
- Check artifact retention (7 days for test builds)

## More Information

- **Full Guide**: See [RELEASE_GUIDE.md](RELEASE_GUIDE.md)
- **Build Workflow**: See [.github/workflows/build.yml](.github/workflows/build.yml)
- **Release Workflow**: See [.github/workflows/release.yml](.github/workflows/release.yml)
