#include <GarrysMod/Lua/Interface.h>
#include "core/he_core.hpp"
#include <algorithm>

using namespace GarrysMod::Lua;

namespace
{
    void PushStatusTable(ILuaBase *LUA, const he::Status &status)
    {
        LUA->CreateTable();

        LUA->PushString(status.version.c_str());
        LUA->SetField(-2, "version");

        LUA->PushNumber(status.uptime_ms);
        LUA->SetField(-2, "uptime_ms");

        LUA->PushNumber(static_cast<double>(status.jobs_enqueued));
        LUA->SetField(-2, "jobs_enqueued");

        LUA->PushNumber(static_cast<double>(status.jobs_executed));
        LUA->SetField(-2, "jobs_executed");
    }
}

LUA_FUNCTION(he_GetStatus)
{
    PushStatusTable(LUA, he::GetStatus());
    return 1;
}

LUA_FUNCTION(he_Bench)
{
    const int args = LUA->Top();
    double iterations = args >= 1 ? LUA->CheckNumber(1) : 5'000'000.0;
    iterations = std::max(iterations, 0.0);

    const size_t iters = static_cast<size_t>(iterations);
    const double elapsed_ms = he::Bench(iters);

    LUA->CreateTable();
    LUA->PushNumber(static_cast<double>(iters));
    LUA->SetField(-2, "iterations");
    LUA->PushNumber(elapsed_ms);
    LUA->SetField(-2, "elapsed_ms");

    return 1;
}

GMOD_MODULE_OPEN()
{
    he::Init();

    LUA->PushSpecial(SPECIAL_GLOB);
    LUA->PushCFunction(he_GetStatus); LUA->SetField(-2, "he_GetStatus");
    LUA->PushCFunction(he_Bench);     LUA->SetField(-2, "he_Bench");
    LUA->Pop();
    return 0;
}

GMOD_MODULE_CLOSE()
{
    he::Shutdown();
    return 0;
}
