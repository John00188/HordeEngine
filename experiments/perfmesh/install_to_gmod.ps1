param()
$gm = "E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod"
$src = "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh\addon"
$dst = Join-Path $gm "addons\perfmesh"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
robocopy $src $dst /E | Out-Null
Write-Host "Installed -> $dst"
