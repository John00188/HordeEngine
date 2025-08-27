param(
    [string]$GMod = "E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod",
    [string]$Config = "Release"
)

$bin = Join-Path "$PSScriptRoot\..\build" "bin\$Config"
$dstBin = Join-Path $GMod "lua\bin"
$dstLua = Join-Path $GMod "lua\autorun"

New-Item -ItemType Directory -Path $dstBin -Force | Out-Null
New-Item -ItemType Directory -Path $dstLua -Force | Out-Null

Copy-Item "$bin\gmcl_hordeengine_win64.dll" $dstBin -Force
Copy-Item "$bin\gmsv_hordeengine_win64.dll" $dstBin -Force

Copy-Item "$PSScriptRoot\..\lua\autorun\*.lua" $dstLua -Force
Copy-Item "$PSScriptRoot\..\lua\autorun\server\*.lua" (Join-Path $dstLua "server") -Force -ErrorAction SilentlyContinue
Copy-Item "$PSScriptRoot\..\lua\autorun\client\*.lua" (Join-Path $dstLua "client") -Force -ErrorAction SilentlyContinue

Write-Host "[HE] Installed to $GMod"
