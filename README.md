# HordeEngine

[![Build Status](https://github.com/John00188/HordeEngine/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/John00188/HordeEngine/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/John00188/HordeEngine?include_prereleases&sort=semver)](https://github.com/John00188/HordeEngine/releases)

HordeEngine is a performance-oriented backend module for Garry's Mod. The project provides a clean, buildable foundation that bridges native C++17 code with Lua through the exposed `he.*` namespace.

## Highlights

* **Pre-built modules** for both client and server: `gmcl_hordeengine_win64.dll` and `gmsv_hordeengine_win64.dll`.
* **Lua loader utilities** including `he_status`, `he_bench`, `he_status_cl`, and `he_bench_cl`.
* **Safe pool integration** that respects existing PerfCore `pf.NPCPools` definitions.

## Prerequisites

| Requirement | Notes |
| --- | --- |
| Visual Studio 2022 | Ensure the Desktop development with C++ workload is installed. |
| CMake 3.20 or newer | Used to configure and generate build files. |
| Facepunch GMod module base headers | Expected at `dev/gmod-module-base/include` relative to the repo. Override with `-DGMOD_MODULE_BASE_INCLUDE="C:/path/to/gmod-module-base/include"` if located elsewhere. |

## Building

Run the build script from the project root:

```powershell
./scripts/build.ps1
```

The compiled artifacts are placed in `build/bin/Release`.

## Installation

Specify your Garry's Mod installation path (either by editing `install.ps1` or passing it as a parameter) and run:

```powershell
./scripts/install.ps1 -GMod "E:\SteamLibrary\steamapps\common\GarrysMod\garrysmod"
```

## In-Game Usage

From the in-game console you can invoke the included helpers:

```
// Server-side (works in singleplayer too)
he_status
he_bench 1000000

// Client-side helpers
he_status_cl
he_bench_cl 400000
```

If you also keep **PerfCore**, the bundled `he_pools.lua` script ensures `pf.SpawnFromPool` remains available without overwriting existing pools.
