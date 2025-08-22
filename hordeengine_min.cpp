// hordeengine_min.cpp
#include <GarrysMod/Lua/Interface.h>

using namespace GarrysMod::Lua;

static ILuaBase* G_LUA = nullptr; // set in gmod13_open, used in callbacks

// Safe callback: receives lua_State*, but uses the stored ILuaBase*
static int he_version(lua_State* /*L*/) {
    // Do NOT cast lua_State* to ILuaBase*. Use the global set in gmod13_open.
    if (G_LUA == nullptr) return 0;
    G_LUA->PushString("HordeEngine v0.1");
    return 1; // 1 return value
}

extern "C" __declspec(dllexport)
int gmod13_open(ILuaBase* LUA)
{
    G_LUA = LUA;            // stash for later callbacks
    LUA->CreateTable();     // module table
    LUA->PushCFunction(he_version);
    LUA->SetField(-2, "version");
    return 1;               // return the module table
}

extern "C" __declspec(dllexport)
int gmod13_close(ILuaBase* /*LUA*/)
{
    G_LUA = nullptr;
    return 0;
}
