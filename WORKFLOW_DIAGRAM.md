# Release Workflow Diagram

## Automated Release Process

```
┌─────────────────────────────────────────────────────────────────┐
│                     DEVELOPER ACTIONS                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ Update Version   │
                    │ in .csproj       │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Commit & Push    │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Create Git Tag   │
                    │  (e.g., v2.1.0)  │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Push Tag         │
                    │ to GitHub        │
                    └────────┬─────────┘
                             │
┌────────────────────────────┴────────────────────────────┐
│                                                          │
│              GITHUB ACTIONS WORKFLOW                     │
│                                                          │
└──────────────────────────────────────────────────────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
    ┌──────────────────┐      ┌──────────────────┐
    │ Build Taskbar    │      │ Package CLI      │
    │     App          │      │    Version       │
    └────────┬─────────┘      └────────┬─────────┘
             │                         │
             │  ┌──────────────────┐  │
             │  │                  │  │
             ▼  ▼                  ▼  ▼
    ┌─────────────────────────────────────┐
    │  Build Windows x64 (Self-contained) │
    │  - Includes .NET Runtime            │
    │  - ~80 MB                           │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  Build Windows x64 (Framework-dep)  │
    │  - Requires .NET 8.0                │
    │  - ~1 MB                            │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  Build Windows ARM64                │
    │  - For ARM64 devices                │
    │  - ~80 MB                           │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  Package CLI Scripts                │
    │  - PowerShell files                 │
    │  - <100 KB                          │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  Create ZIP Archives                │
    │  - One per variant                  │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  Generate Release Notes             │
    │  - Automatic template               │
    │  - Download links                   │
    │  - Requirements                     │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  Create GitHub Release              │
    │  - Tag: v2.1.0                      │
    │  - Upload all artifacts             │
    │  - Publish release                  │
    └──────────────┬──────────────────────┘
                   │
┌──────────────────┴───────────────────┐
│                                      │
│          RELEASE PUBLISHED           │
│                                      │
└──────────────────────────────────────┘
                   │
                   ▼
           ┌───────────────┐
           │   USERS CAN   │
           │   DOWNLOAD    │
           └───────────────┘
```

## Build Variants

```
Taskbar App:
├── win-x64 (Self-contained)
│   ├── Size: ~80 MB
│   ├── Includes: .NET Runtime
│   └── Best for: Most users
│
├── win-x64 (Framework-dependent)
│   ├── Size: ~1 MB
│   ├── Requires: .NET 8.0 Runtime
│   └── Best for: Users with .NET installed
│
└── win-arm64 (Self-contained)
    ├── Size: ~80 MB
    ├── Includes: .NET Runtime
    └── Best for: ARM64 Windows devices

CLI Version:
└── PowerShell Scripts
    ├── Size: <100 KB
    ├── Requires: PowerShell
    └── Best for: Terminal users
```

## Continuous Integration Flow

```
Push to Branch
     │
     ▼
┌─────────────────────┐
│  Build Workflow     │
│  (build.yml)        │
└──────┬──────────────┘
       │
       ├─► Build Debug
       ├─► Build Release
       ├─► Test Publish
       ├─► Validate Scripts
       └─► Upload Artifacts
              │
              ▼
         (Retained 7 days)
```

## Release Flow

```
Push Tag (v*)
     │
     ▼
┌─────────────────────┐
│ Release Workflow    │
│ (release.yml)       │
└──────┬──────────────┘
       │
       ├─► Build All Variants
       ├─► Package CLI
       ├─► Create Release
       └─► Upload to GitHub
              │
              ▼
      Published Release
      (Permanent)
```

## File Naming Convention

```
Release Tag: v2.1.0

Generated Files:
├── ClaudeProjectChooser-2.1.0-win-x64.zip
├── ClaudeProjectChooser-2.1.0-win-x64-framework.zip
├── ClaudeProjectChooser-2.1.0-win-arm64.zip
├── ClaudeProjectChooser-2.1.0-win-x64.exe
└── ClaudeProjectChooser-CLI-2.1.0.zip
```

## Timeline

```
00:00  Tag pushed to GitHub
       │
00:01  Workflow triggered
       │
00:02  Windows runner starts
       │
00:03  .NET SDK installed
       │
00:05  Build starts
       │
00:07  First variant complete
       │
00:09  All builds complete
       │
00:10  Packaging starts
       │
00:11  Release created
       │
00:12  Artifacts uploaded
       │
00:13  Release published ✓
```

Typical total time: **10-15 minutes**

## Manual Triggers

You can also trigger builds manually:

1. Go to Actions tab
2. Select workflow
3. Click "Run workflow"
4. Enter version number
5. Wait for completion

This is useful for testing without creating a release.
