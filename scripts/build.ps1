param(
    [string]$BuildDir = "$PSScriptRoot\build",
    [string]$Config = "Release",
    [string]$Arch = "x64"
)

if (Test-Path $BuildDir) { Remove-Item $BuildDir -Recurse -Force }
New-Item -ItemType Directory -Path $BuildDir | Out-Null

Push-Location $BuildDir
cmake -G "Visual Studio 17 2022" -A $Arch ..
cmake --build . --config $Config
Pop-Location
