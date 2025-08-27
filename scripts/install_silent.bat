@echo off
setlocal
set "GMOD=E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod"
set "BUILD=%~dp0..\build\bin\Release"
set "BIN=%GMOD%\lua\bin"
set "LUA=%GMOD%\lua\autorun"
if not exist "%BIN%" mkdir "%BIN%" >nul 2>&1
if not exist "%LUA%" mkdir "%LUA%" >nul 2>&1
copy /Y "%BUILD%\gmcl_hordeengine_win64.dll" "%BIN%\\" >nul 2>&1
copy /Y "%BUILD%\gmsv_hordeengine_win64.dll" "%BIN%\\" >nul 2>&1
copy /Y "%~dp0..\lua\autorun\*.lua" "%LUA%\\" >nul 2>&1
