# Quick Start Guide - Windows Taskbar App

This guide will get you up and running with the Windows Taskbar version of Claude Project Chooser in minutes.

## Prerequisites Check

Before starting, ensure you have:

1. **Windows 10 or later** ✓
2. **PowerShell** (pre-installed on Windows) ✓
3. **Claude CLI** installed and working ✓
4. **.NET 8.0 SDK** for building (check below)

### Check if .NET is Installed

Open PowerShell and run:
```powershell
dotnet --version
```

If you see a version number like `8.0.x` or higher, you're good to go! ✓

If not, download and install from: https://dotnet.microsoft.com/download/dotnet/8.0

## Building the Taskbar App

### Step 1: Clone or Navigate to Repository

```powershell
cd C:\path\to\claude-project-chooser
```

### Step 2: Build the Application

```powershell
.\build.ps1
```

This will:
- Restore NuGet packages
- Compile the C# code
- Create the executable

**Expected output:**
```
✓ .NET SDK version: 8.0.xxx
Building application...
✓ Build successful!

Executable location:
  C:\path\to\claude-project-chooser\src\ClaudeProjectChooser\bin\Release\net8.0-windows\ClaudeProjectChooser.exe
```

### Step 3: Run the Application

Navigate to the output directory and run:
```powershell
cd src\ClaudeProjectChooser\bin\Release\net8.0-windows\
.\ClaudeProjectChooser.exe
```

Or double-click `ClaudeProjectChooser.exe` in File Explorer.

### Step 4: Find the Tray Icon

Look in your Windows system tray (bottom-right corner). You should see a new icon:
- If you don't see it immediately, click the `^` arrow to show hidden icons
- The icon will be labeled "Claude Project Chooser"

### Step 5: Try It Out!

1. **Left-click** the tray icon
2. You should see a menu with your Claude projects
3. **Click** any project to launch Claude in that directory
4. A new PowerShell window should open with Claude running

## Creating a Standalone Executable

To create a single .exe file that includes the .NET runtime (no installation needed):

```powershell
.\build.ps1 -Publish
```

This creates a self-contained executable in the `publish/` folder that can be distributed to other machines.

## Auto-Start with Windows (Optional)

To make the app start automatically when Windows boots:

### Method 1: Using Startup Folder
1. Press `Win + R`
2. Type `shell:startup` and press Enter
3. Create a shortcut to `ClaudeProjectChooser.exe` in this folder

### Method 2: Task Scheduler (More Control)
1. Open Task Scheduler
2. Create Basic Task
3. Name: "Claude Project Chooser"
4. Trigger: "When I log on"
5. Action: "Start a program"
6. Program: Path to `ClaudeProjectChooser.exe`
7. Finish

## Troubleshooting

### Build Fails with "NETSDK1100"

**Error:** `error NETSDK1100: To build a project targeting Windows on this operating system...`

**Solution:** You're trying to build on Linux/Mac. Windows Forms apps must be built on Windows.

### "No projects found" in Menu

**Cause:** No Claude projects exist yet, or they're in a different location.

**Solution:**
1. Verify projects exist in `%USERPROFILE%\.claude\projects`
2. Try creating a new Claude project by running `claude` in a directory
3. Check that JSONL files in project folders contain `cwd` fields

### App Doesn't Appear in System Tray

**Cause:** May be running but icon is hidden.

**Solutions:**
1. Click the `^` arrow in system tray to see hidden icons
2. Check Task Manager to see if `ClaudeProjectChooser` is running
3. Try running as Administrator
4. Check Windows notification settings

### Claude Doesn't Launch

**Cause:** PowerShell or Claude CLI not found.

**Solutions:**
1. Verify PowerShell works: Open cmd and type `pwsh` or `powershell`
2. Verify Claude works: Open PowerShell and type `claude --version`
3. Ensure `claude` is in your PATH

### Multiple Instances Warning

**Cause:** App is already running.

**Solution:** This is intentional! Only one instance can run at a time. Check your system tray for the existing instance.

## Development Tips

### Debugging

To run with debugging:
```powershell
cd src\ClaudeProjectChooser
dotnet run
```

### Modifying the Code

Main files to edit:
- `TrayApplicationContext.cs` - Main app logic and menu
- `ProjectManager.cs` - Project discovery
- `ProjectLauncher.cs` - Launch behavior
- `ClaudeProject.cs` - Data model

After making changes, rebuild:
```powershell
.\build.ps1 -Clean
```

### Adding an Icon

To use a custom icon:
1. Create or find a `.ico` file (16x16, 32x32, 48x48 sizes)
2. Place it in `src/ClaudeProjectChooser/Resources/icon.ico`
3. Update `TrayApplicationContext.cs`:
   ```csharp
   _trayIcon = new NotifyIcon
   {
       Icon = new Icon("Resources/icon.ico"),
       // ...
   };
   ```
4. Rebuild

## Next Steps

### For Users
- Add to Windows Startup (see above)
- Customize the refresh interval in `ProjectManager.cs`
- Report any issues on GitHub

### For Developers
- Read `TASKBAR_APP_DESIGN.md` for architecture details
- See `COMPARISON.md` for CLI vs Taskbar analysis
- Check `src/README.md` for detailed documentation
- Submit pull requests for improvements!

## Useful Commands

```powershell
# Build
.\build.ps1

# Build with clean
.\build.ps1 -Clean

# Create standalone executable
.\build.ps1 -Publish

# Run from source
cd src\ClaudeProjectChooser
dotnet run

# Clean all build artifacts
cd src\ClaudeProjectChooser
dotnet clean
```

## Getting Help

- **Documentation:** See `src/README.md`
- **Issues:** https://github.com/matthewww/claude-project-chooser/issues
- **Design Details:** See `TASKBAR_APP_DESIGN.md`
- **Comparison:** See `COMPARISON.md`

## Summary

You've successfully:
- ✓ Built the Windows taskbar app
- ✓ Launched it in your system tray
- ✓ Accessed your Claude projects with one click
- ✓ Learned how to customize and extend it

Enjoy your new taskbar app! 🎉
