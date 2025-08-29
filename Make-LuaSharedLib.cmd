@echo off
if exist lua_shared.lib goto :eof
lib /nologo /def:lua_shared.exports.txt /out:lua_shared.lib /machine:x64
