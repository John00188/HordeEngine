# Make sure we’re in the repo root
Set-Location "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed"

Write-Host ">>> Pulling latest from git..." -ForegroundColor Cyan
git pull

Write-Host ">>> Configuring CMake (x64, VS2022)..." -ForegroundColor Cyan
cmake -S . -B build\vs2022 -G "Visual Studio 17 2022" -A x64

Write-Host ">>> Building HordeEngine (Release)..." -ForegroundColor Cyan
cmake --build build\vs2022 --config Release --target gmcl_hordeengine_win64 gmsv_hordeengine_win64 --parallel

if ($LASTEXITCODE -ne 0) {
    Write-Host ">>> Build failed, not deploying." -ForegroundColor Red
    exit 1
}

Write-Host ">>> Copying DLLs into Garry's Mod..." -ForegroundColor Cyan
$src="build\vs2022\out\Release"
$dst="E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\lua\bin"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item -Force @("$src\gmcl_hordeengine_win64.dll","$src\gmsv_hordeengine_win64.dll") -Destination $dst

Write-Host ">>> Done. Deployed to $dst" -ForegroundColor Green
