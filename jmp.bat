@echo off
REM Agentic Project Chooser - Unified tool for all agentic coding tools
REM Supports all tools combined, per-tool modes, and smart fallback.
REM Usage: jmp [--all|--auto|--<providerId>] [--sessions]
REM 
REM Examples:
REM   jmp              - Combined view: all tools, sorted by recency (default)
REM   jmp --all        - Explicit combined mode
REM   jmp --auto       - Auto-detect a single tool (first found wins)
REM   jmp --claude     - Claude projects only
REM   jmp --opencode   - OpenCode projects only
REM   jmp --opencode --sessions - OpenCode with session browser
REM   jmp --copilot    - Copilot projects only
REM   jmp --mytool     - Any custom provider with id 'mytool'

setlocal enabledelayedexpansion
set MODE=all
set SESSION_MODE=projects

:parse_args
if "%~1"=="" goto run
if /i "%~1"=="--sessions" (
    set SESSION_MODE=sessions
    shift
    goto parse_args
)
REM Any --X flag (other than --sessions above) is treated as a provider mode name
set _ARG=%~1
if "!_ARG:~0,2!"=="--" (
    set MODE=!_ARG:~2!
    shift
    goto parse_args
)
shift
goto parse_args

:run
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0choose-agentic-project.ps1" -Mode "%MODE%" -OpenCodeSessionMode "%SESSION_MODE%"

