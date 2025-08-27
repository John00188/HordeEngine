#include <GarrysMod/Lua/Interface.h>
#include "core/he_core.hpp"

using namespace GarrysMod::Lua;

// he.GetStatus() -> table
LUA_FUNCTION( he_GetStatus )
{
    auto s = he::GetStatus();

    LUA->CreateTable();
    LUA->PushString("version");    LUA->PushString(s.version.c_str()); LUA->SetTable(-3);
    LUA->PushString("uptime_ms");  LUA->PushNumber(s.uptime_ms);       LUA->SetTable(-3);
    LUA->PushString("enqueued");   LUA->PushNumber((double)s.jobs_enqueued); LUA->SetTable(-3);
    LUA->PushString("executed");   LUA->PushNumber((double)s.jobs_executed); LUA->SetTable(-3);
    return 1;
}

// he.Bench(iters:number) -> ms:number
LUA_FUNCTION( he_Bench )
{
    int iters_index = 1;
    size_t iters = 1000000;
    if (LUA->Top() >= iters_index && LUA->IsType(iters_index, GarrysMod::Lua::Type::Number)) {
        iters = (size_t)LUA->GetNumber(iters_index);
    }
    double ms = he::Bench(iters);
    LUA->PushNumber(ms);
    return 1;
}

GMOD_MODULE_OPEN()
{
    he::Init();

    // he table
    LUA->PushSpecial(SPECIAL_GLOB);
    LUA->CreateTable();

    LUA->PushCFunction(he_GetStatus);
    LUA->SetField(-2, "GetStatus");

    LUA->PushCFunction(he_Bench);
    LUA->SetField(-2, "Bench");

    LUA->SetField(-2, "he");
    LUA->Pop();

    printf("[HE] Server module loaded (Improvementinator 3000)\n");
    return 0;
}

GMOD_MODULE_CLOSE()
{
    he::Shutdown();
    printf("[HE] Server module unloaded\n");
    return 0;
}
