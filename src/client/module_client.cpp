#include <GarrysMod/Lua/Interface.h>
#include "core/he_core.hpp"

using namespace GarrysMod::Lua;

LUA_FUNCTION( he_GetStatusCL )
{
    auto s = he::GetStatus();
    LUA->CreateTable();
    LUA->PushString("version");    LUA->PushString(s.version.c_str()); LUA->SetTable(-3);
    LUA->PushString("uptime_ms");  LUA->PushNumber(s.uptime_ms);       LUA->SetTable(-3);
    LUA->PushString("enqueued");   LUA->PushNumber((double)s.jobs_enqueued); LUA->SetTable(-3);
    LUA->PushString("executed");   LUA->PushNumber((double)s.jobs_executed); LUA->SetTable(-3);
    return 1;
}

LUA_FUNCTION( he_BenchCL )
{
    size_t iters = 400000;
    if (LUA->Top() >= 1 && LUA->IsType(1, GarrysMod::Lua::Type::Number)) {
        iters = (size_t)LUA->GetNumber(1);
    }
    double ms = he::Bench(iters);
    LUA->PushNumber(ms);
    return 1;
}

GMOD_MODULE_OPEN()
{
    he::Init();

    LUA->PushSpecial(SPECIAL_GLOB);
    LUA->CreateTable();

    LUA->PushCFunction(he_GetStatusCL);
    LUA->SetField(-2, "GetStatus");

    LUA->PushCFunction(he_BenchCL);
    LUA->SetField(-2, "Bench");

    LUA->SetField(-2, "he");
    LUA->Pop();

    printf("[HE] Client module loaded (Improvementinator 3000)\n");
    return 0;
}

GMOD_MODULE_CLOSE()
{
    he::Shutdown();
    printf("[HE] Client module unloaded\n");
    return 0;
}
