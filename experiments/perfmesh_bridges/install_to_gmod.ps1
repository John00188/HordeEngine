param()
$src = "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh_bridges\addon"
$dst = "E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons\perfmesh_bridges"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
robocopy $src $dst /E | Out-Null
Write-Host "Installed -> $dst"
