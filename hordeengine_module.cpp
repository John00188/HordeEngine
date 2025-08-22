#include <GarrysMod/Lua/Interface.h>
using GarrysMod::Lua::ILuaBase;

extern "C" __declspec(dllexport)
int gmod13_open(ILuaBase* LUA)
{
    // Return a small, pure-data table (no C callbacks)
    LUA->CreateTable();

    // Marker so you can verify which side
#ifdef GMOD_CLIENT
    LUA->PushString("client");
#else
    LUA->PushString("server");
#endif
    LUA->SetField(-2, "side");

    // Static fields
    LUA->PushString("HordeEngine v0.1");
    LUA->SetField(-2, "version");

    LUA->PushBool(false);           // until we wire real he_api
    LUA->SetField(-2, "connected");

    return 1; // return the table
}

extern "C" __declspec(dllexport)
int gmod13_close(ILuaBase* /*LUA*/)
{
    return 0;
}
