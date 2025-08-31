param()
$addon = "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\horde_optimizer\addon"
$zipOut = Join-Path "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\artifacts" "horde_optimizer.zip"
if (Test-Path $zipOut) { Remove-Item $zipOut -Force }
Compress-Archive -Path (Join-Path $addon "*") -DestinationPath $zipOut
Write-Host "Packed -> $zipOut"
