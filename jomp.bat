@echo off
REM Agentic Project Chooser (OpenCode) - Wrapper for OpenCode-specific browsing
REM Usage: jomp [--sessions]
REM
REM Examples:
REM   jomp          - Browse OpenCode projects
REM   jomp --sessions - Browse projects and their sessions

setlocal enabledelayedexpansion
set SESSION_MODE=projects

:parse_args
if "%~1"=="" goto run
if /i "%~1"=="--sessions" (
    set SESSION_MODE=sessions
    shift
    goto parse_args
)
shift
goto parse_args

:run
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0choose-agentic-project.ps1" -Mode "opencode" -OpenCodeSessionMode "%SESSION_MODE%"
