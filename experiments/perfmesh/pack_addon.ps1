param()
$zipOut = Join-Path "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\artifacts" "perfmesh.zip"
if (Test-Path $zipOut) { Remove-Item $zipOut -Force }
Compress-Archive -Path "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh\addon\*" -DestinationPath $zipOut
Write-Host "Packed -> $zipOut"
