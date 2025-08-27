# HordeEngine

[![Build Status](https://github.com/John00188/HordeEngine/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/John00188/HordeEngine/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/John00188/HordeEngine?include_prereleases&sort=semver)](https://github.com/John00188/HordeEngine/releases)

A performance-oriented backend module for Garry's Mod.


# HordeEngine Improvementinator 3000 (Usable Skeleton)

This is a **clean, buildable** backend module for Garry's Mod that exposes `he.*` functions from native C++ to Lua.

## What you get
- **C++17 native module** (client + server): `gmcl_hordeengine_win64.dll`, `gmsv_hordeengine_win64.dll`
- **Lua loader & helpers**: `he_status`, `he_bench`, `he_status_cl`, `he_bench_cl`
- **Safe pools glue** that won't overwrite your existing PerfCore `pf.NPCPools`

## Build
1. Make sure you have **Visual Studio 2022** with C++ and **CMake 3.20+**.
2. Ensure Facepunch headers are available at:
   `dev/gmod-module-base/include` relative to this project.
   - If not, set `-DGMOD_MODULE_BASE_INCLUDE="C:/path/to/gmod-module-base/include"`

```powershell
# from the project root
.\scripts\build.ps1
```

Artifacts appear in `build/bin/Release`.

## Install
Set your GMod path (edit inside `install.ps1` or pass param) and run:

```powershell
.\scripts\install.ps1 -GMod "E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod"
```

## Use In-Game
Open console:

```
// Server-side (works in singleplayer too)
he_status
he_bench 1000000

// Client-side helpers
he_status_cl
he_bench_cl 400000
```

If you also keep **PerfCore**, the file `he_pools.lua` ensures `pf.SpawnFromPool` exists without overwriting your existing pools.
