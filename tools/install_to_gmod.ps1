$src = "C:\Users\John Sonnier\Desktop\HordeEngine_Improvementinator_fixed\experiments\perfmesh_v2\addon"
$dest = "E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod\addons\perfmesh_v2"

$robocopyArgs = @(
    $src,
    $dest,
    '/MIR',
    '/IS',
    '/IT',
    '/R:0',
    '/W:0',
    '/NFL',
    '/NDL',
    '/NP'
)

$rcOutput = robocopy @robocopyArgs
$summary = $rcOutput | Select-String -Pattern 'Dirs :|Files :|Bytes :'
$summary | ForEach-Object { $_.Line }

Get-ChildItem -Recurse $dest | Select-Object FullName, Length, LastWriteTime
