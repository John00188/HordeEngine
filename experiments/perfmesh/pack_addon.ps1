# PerfMesh Bridges
Auto-generated bridge stubs that let each addon publish/subscribe on PerfMesh without modifying them.
- Loader: \lua/autorun/server/perfmesh_bridges_loader.lua\
- Generated stubs: \lua/autorun/server/perfmesh_bridges_gen/*.lua\
"@ | Set-Content -Encoding UTF8 C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh_bridges\addon\README.md

C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh\pack_addon.ps1 = Join-Path C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh_bridges "pack_addon.ps1"
@"
param()
$zipOut = Join-Path "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\artifacts" "perfmesh_bridges.zip"
if (Test-Path $zipOut) { Remove-Item $zipOut -Force }
Compress-Archive -Path "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh_bridges\addon\*" -DestinationPath $zipOut
Write-Host "Packed -> $zipOut"
