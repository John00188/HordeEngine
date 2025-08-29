@echo off
:: ========================================================
:: HordeEngine Build Insights Helper
:: Collects MSVC build performance data with vcperf
:: ========================================================

:: Run as Administrator check
whoami /groups | find "S-1-5-32-544" >nul
if errorlevel 1 (
    echo ERROR: Please run this script as Administrator.
    pause
    exit /b
)

:: ===== CONFIGURATION =====
set SOLUTION="C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\HordeEngine.sln"
set CONFIG=Debug
set PLATFORM=x64
set TRACE_NAME=HordeTrace
set TRACE_OUT=%~dp0BuildInsights.etl
:: =========================

echo === Stopping conflicting ETW sessions ===
logman stop "Diagtrack-Listener" -ets >nul 2>&1
logman stop "Steam Event Tracing" -ets >nul 2>&1
logman stop "NVIDIA-NVTOPPS" -ets >nul 2>&1
logman stop "NVIDIA-NVTOPPS-NOCAT" -ets >nul 2>&1

:: Stop Windows Diagnostic Tracking service
sc stop diagtrack >nul 2>&1

echo === Starting Build Insights trace (%TRACE_NAME%) ===
vcperf /start %TRACE_NAME%
if errorlevel 1 (
    echo ERROR: vcperf could not start trace.
    pause
    exit /b
)

echo === Building solution ===
msbuild %SOLUTION% /t:Rebuild /p:Configuration=%CONFIG% /p:Platform=%PLATFORM%
if errorlevel 1 (
    echo ERROR: Build failed. Stopping trace...
    vcperf /stop %TRACE_NAME% "%TRACE_OUT%"
    pause
    exit /b
)

echo === Stopping trace and saving to %TRACE_OUT% ===
vcperf /stop %TRACE_NAME% "%TRACE_OUT%"

echo === Done! ===
echo Build Insights trace saved to: %TRACE_OUT%
pause
