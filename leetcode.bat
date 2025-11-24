@echo off
rem leetcode.bat — simple launcher that calls the PowerShell helper

:: ensure UTF-8 console for nicer output (no harm if ignored)
chcp 65001 >nul

:: path to this batch file's folder
set SCRIPT_DIR=%~dp0

:: PowerShell helper path (same folder)
set PSFILE=%SCRIPT_DIR%leetcode_helper.ps1

:: forward all arguments to the PS script
rem Use "%*" if you want all args preserved as a single string (works for usual use)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%" "%*"
