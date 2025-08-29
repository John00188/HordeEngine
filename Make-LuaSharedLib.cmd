@echo off
REM Generate a fake import library for lua_shared.dll so MSVC can link

REM Adjust this path if Garry's Mod is installed somewhere else
set LUA_SHARED_DLL="E:\SteamLibrary\steamapps\common\GarrysMod\bin\lua_shared.dll"

if not exist %LUA_SHARED_DLL% (
    echo ERROR: Could not find lua_shared.dll at %LUA_SHARED_DLL%
    exit /b 1
)

echo Generating lua_shared.lib from %LUA_SHARED_DLL% ...

REM Use dumpbin to extract exports
dumpbin /exports %LUA_SHARED_DLL% > lua_shared.exports.txt

REM Convert to .def file (keep only export section)
echo LIBRARY lua_shared > lua_shared.def
echo EXPORTS >> lua_shared.def
for /f "tokens=4" %%A in ('findstr /r /c:"[0-9][0-9A-F]*[ ]*[_A-Za-z]" lua_shared.exports.txt') do (
    echo %%A >> lua_shared.def
)

REM Create import library
lib /def:lua_shared.def /out:lua_shared.lib /machine:x64

echo Done! lua_shared.lib generated in %CD%
