param()
$src = "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh_v2\addon"
$dst = Join-Path "E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod" "addons\perfmesh_v2"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
robocopy $src $dst /E | Out-Null
Write-Host "Installed -> $dst"
