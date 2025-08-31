param()
$zipOut = "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\artifacts\perfmesh_bridges.zip"
if (Test-Path $zipOut) { Remove-Item $zipOut -Force }
Compress-Archive -Path "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh_bridges\addon\*" -DestinationPath $zipOut
Write-Host "Packed -> $zipOut"
