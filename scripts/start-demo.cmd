@echo off
title MES Demo Launcher
echo [1/2] Checking backend and tunnel ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refresh-demo.ps1" -NoOpen
echo.
echo [2/2] Starting daily watcher (08:00 / 12:00 / 18:00 Beijing time) ...
start "MES-Demo-Watch" /min powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0refresh-demo.ps1" -Watch -NoOpen
echo.
echo ============================================
echo  Daily checks: 08:00, 12:00, 18:00.
echo  Closing this window will NOT stop them.
echo ============================================
pause
