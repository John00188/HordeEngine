param()
$zipOut = "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\artifacts\perfmesh_v2.zip"
if (Test-Path $zipOut) { Remove-Item $zipOut -Force }
Compress-Archive -Path "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh_v2\addon\*" -DestinationPath $zipOut
Write-Host "Packed -> $zipOut"
