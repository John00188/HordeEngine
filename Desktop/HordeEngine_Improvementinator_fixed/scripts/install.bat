@echo off
setlocal

:: === EDIT THIS if your GMod lives elsewhere ===
set "GMOD=E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod"

:: Build output (CMake multi-config → Release folder)
set "BUILD=%~dp0..\build\bin\Release"

set "BIN=%GMOD%\lua\bin"
set "LUA=%GMOD%\lua\autorun"

echo Installing HordeEngine...
echo From: %BUILD%
echo To:   %GMOD%
echo.

if not exist "%BIN%" mkdir "%BIN%"
if not exist "%LUA%" mkdir "%LUA%"

copy /Y "%BUILD%\gmcl_hordeengine_win64.dll" "%BIN%\"
copy /Y "%BUILD%\gmsv_hordeengine_win64.dll" "%BIN%\"
copy /Y "%~dp0..\lua\autorun\*.lua" "%LUA%\"

echo.
echo [HE] Install complete.
pause
