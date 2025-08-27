#include <GarrysMod/Lua/Interface.h>
using namespace GarrysMod::Lua;

LUA_FUNCTION(he_GetStatus)
{
    LUA->PushString("hordeengine: server ok");
    return 1;
}

LUA_FUNCTION(he_Bench)
{
    LUA->PushNumber(0.0);
    return 1;
}

GMOD_MODULE_OPEN()
{
    LUA->PushSpecial(SPECIAL_GLOB);
    LUA->PushCFunction(he_GetStatus); LUA->SetField(-2, "he_GetStatus");
    LUA->PushCFunction(he_Bench);     LUA->SetField(-2, "he_Bench");
    LUA->Pop();
    return 0;
}

GMOD_MODULE_CLOSE()
{
    return 0;
}
