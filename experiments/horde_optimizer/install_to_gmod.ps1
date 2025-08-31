param()
$gm = "E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod"
$src = "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\horde_optimizer\addon"
$dst = Join-Path $gm "addons\horde_optimizer"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
robocopy $src $dst /E | Out-Null
Write-Host "Installed -> $dst"
