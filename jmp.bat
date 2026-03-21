@echo off
REM Agentic Project Chooser - Unified tool for Claude, OpenCode, and Copilot projects
REM Supports all tools combined, or per-tool modes with smart fallback
REM Usage: jmp [--all|--auto|--claude|--opencode|--copilot] [--sessions]
REM 
REM Examples:
REM   jmp              - Combined view: all tools, sorted by recency (default)
REM   jmp --all        - Explicit combined mode
REM   jmp --auto       - Auto-detect a single tool (Claude → OpenCode → Copilot)
REM   jmp --claude     - Claude projects only
REM   jmp --opencode   - OpenCode projects only
REM   jmp --opencode --sessions - OpenCode with session browser
REM   jmp --copilot    - Copilot projects only

setlocal enabledelayedexpansion
set MODE=all
set SESSION_MODE=projects

:parse_args
if "%~1"=="" goto run
if /i "%~1"=="--all" (
    set MODE=all
    shift
    goto parse_args
)
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
if /i "%~1"=="--copilot" (
    set MODE=copilot
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

