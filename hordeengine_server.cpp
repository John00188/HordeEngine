#include "GarrysMod/Lua/Interface.h"

using namespace GarrysMod::Lua;

// Define a Lua-callable function
LUA_FUNCTION(he_Test)
{
    LUA->PushString("Hello from HordeEngine!");
    return 1; // returning 1 means 1 value is left on the Lua stack
}

GMOD_MODULE_OPEN()
{
    // Create a table for the module
    LUA->CreateTable();

    // Add the he_Test function to it
    LUA->PushCFunction(he_Test);
    LUA->SetField(-2, "test");

    // This table is returned to Lua as the value of require("hordeengine")
    return 1;
}

GMOD_MODULE_CLOSE()
{
    return 0;
}
