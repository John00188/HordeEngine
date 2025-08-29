#include "GarrysMod/Lua/Interface.h"

using namespace GarrysMod::Lua;

// Example client-only function
LUA_FUNCTION(he_ClientTest)
{
    LUA->PushString("Hello from HordeEngine Client!");
    return 1; // 1 return value
}

GMOD_MODULE_OPEN()
{
    // Create a table for the client module
    LUA->CreateTable();

    // Add our test function
    LUA->PushCFunction(he_ClientTest);
    LUA->SetField(-2, "test");

    // Table returned to Lua when calling require("hordeengine")
    return 1;
}

GMOD_MODULE_CLOSE()
{
    return 0;
}
