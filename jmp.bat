@echo off
REM Agentic Project Chooser - Unified tool for Claude and OpenCode projects
REM Supports Claude projects, OpenCode projects, and session browsing with smart fallback
REM Usage: jmp [--auto|--claude|--opencode] [--sessions]
REM 
REM Examples:
REM   jmp              - Smart auto-detection (Claude → OpenCode)
REM   jmp --auto       - Explicit auto-detection mode
REM   jmp --claude     - Claude projects explicitly
REM   jmp --opencode   - OpenCode projects
REM   jmp --opencode --sessions - OpenCode with session browser

setlocal enabledelayedexpansion
set MODE=auto
set SESSION_MODE=projects

:parse_args
if "%~1"=="" goto run
if /i "%~1"=="--auto" (
    set MODE=auto
    shift
    goto parse_args
)
if /i "%~1"=="--claude" (
    set MODE=claude
    shift
    goto parse_args
)
if /i "%~1"=="--opencode" (
    set MODE=opencode
    shift
    goto parse_args
)
if /i "%~1"=="--sessions" (
    set SESSION_MODE=sessions
    shift
    goto parse_args
)
shift
goto parse_args

:run
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0choose-agentic-project.ps1" -Mode "%MODE%" -OpenCodeSessionMode "%SESSION_MODE%"

