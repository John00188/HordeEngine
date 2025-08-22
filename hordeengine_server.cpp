#include <GarrysMod/Lua/Interface.h>
#include <windows.h>
using namespace GarrysMod::Lua;

// ❶ Force exports via linker flags (belt-and-suspenders)
#pragma comment(linker, "/EXPORT:gmod13_open")
#pragma comment(linker, "/EXPORT:gmod13_close")

extern "C" {   // ❷ Remove C++ name mangling

    // ❸ __declspec(dllexport) in case DEF/pragma are ignored
    __declspec(dllexport) int gmod13_open(ILuaBase* LUA) {
        OutputDebugStringA("[HE/CLIENT] gmod13_open\n");
        LUA->CreateTable();
        return 1;
    }

    __declspec(dllexport) int gmod13_close(ILuaBase* /*LUA*/) {
        OutputDebugStringA("[HE/CLIENT] gmod13_close\n");
        return 0;
    }

} // extern "C"
