@echo off
for %%S in (Diagtrack Steam NVIDIA) do (
    logman stop %%S -ets >nul 2>&1
)

vcperf.exe /start HordeBuild

msbuild.exe HordeEngine.sln /p:Configuration=Debug /p:Platform=x64

vcperf.exe /stop HordeBuild BuildInsights.etl
