# HordeEngine Addon

A performance-oriented backend module for Garry's Mod that enables large-scale NPC spawning with minimal performance impact.

## Installation

1. Extract this folder to: `garrysmod/addons/hordeengine/`
2. Build the native modules (see below) and place the DLLs in `garrysmod/lua/bin/`

## Building the Native Modules

This addon requires compiled C++ native modules to function.

### Requirements
- Visual Studio 2022 with C++ support
- CMake 3.21+
- The HordeEngine source code

### Build Steps

1. Clone or download the HordeEngine repository
2. Open PowerShell and navigate to the repository root
3. Run the build script:
   ```powershell
   .\scripts\build.ps1
   ```
4. The compiled DLLs will be in `build\bin\Release\`

### Deploying the Modules

After building, copy the DLLs to your Garry's Mod installation:

```powershell
Copy-Item "build\bin\Release\gmsv_hordeengine_win64.dll" -Destination "C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\lua\bin\"
Copy-Item "build\bin\Release\gmcl_hordeengine_win64.dll" -Destination "C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\lua\bin\"
```

## Console Commands

### Server-side
- `he_status` - Check HordeEngine server module status
- `he_bench <iterations>` - Run performance benchmark (default: 100,000 iterations)

### Client-side
- `he_status_cl` - Check HordeEngine client module status
- `he_bench_cl <iterations>` - Run client benchmark (default: 100,000 iterations)

## File Structure

```
addon/
├── addon.json                          # Addon metadata
├── README.md                           # This file
└── lua/
    └── autorun/
        ├── hordeengine_loader.lua      # Main loader
        ├── server/
        │   └── hordeengine_server.lua  # Server module loader
        └── client/
            └── hordeengine_client.lua  # Client module loader
```

## Support

For issues and feature requests, visit: https://github.com/John00188/HordeEngine
