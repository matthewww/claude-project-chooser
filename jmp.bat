@echo off
REM Project Chooser - Supports both Claude and OpenCode modes
REM Usage: jmp [--claude|--opencode] [--sessions]
REM 
REM Examples:
REM   jmp              - Default (Claude projects)
REM   jmp --claude     - Claude projects explicitly
REM   jmp --opencode   - OpenCode projects
REM   jmp --opencode --sessions - OpenCode with session browser

setlocal enabledelayedexpansion
set MODE=claude
set SESSION_MODE=projects

:parse_args
if "%~1"=="" goto run
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
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0choose-project.ps1" -Mode "%MODE%" -OpenCodeSessionMode "%SESSION_MODE%"

