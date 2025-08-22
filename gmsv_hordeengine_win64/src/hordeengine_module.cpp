// hordeengine_module.cpp — safe lazy loader (no heavy work in GMOD_MODULE_OPEN)
#include <GarrysMod/Lua/Interface.h>
#include "he_api.hpp"   // must exist; see stub below
using namespace GarrysMod::Lua;

static bool g_inited = false;

static bool HE_InitSafely()
{
    if (g_inited) return true;
    // Call into your backend (stubbed to no-op) *here*, not in module open.
    if (!he::connect(nullptr)) return false;
    g_inited = true;
    return true;
}

// Lua funcs (globals + table)
LUA_FUNCTION(l_he_version)     { LUA->PushString("HordeEngine/0.0.1-stub"); return 1; }
LUA_FUNCTION(l_he_connected)   { LUA->PushBool(he::is_connected()); return 1; }
LUA_FUNCTION(l_he_native_load) { LUA->PushBool(HE_InitSafely()); return 1; }
LUA_FUNCTION(l_he_status)      { LUA->PushString(g_inited ? "ready" : "not_inited"); return 1; }

static void ExportAll(ILuaBase* L)
{
    // Globals
    L->PushSpecial(SPECIAL_GLOB);
    L->PushCFunction(l_he_native_load); L->SetField(-2, "he_native_load");
    L->PushCFunction(l_he_status);      L->SetField(-2, "he_status");
    L->PushCFunction(l_he_version);     L->SetField(-2, "he_version");
    L->PushCFunction(l_he_connected);   L->SetField(-2, "he_connected");
    L->Pop();

    // Table: hordeengine = { version=..., connected=..., native_load=..., status=... }
    L->CreateTable();
    L->PushCFunction(l_he_version);     L->SetField(-2, "version");
    L->PushCFunction(l_he_connected);   L->SetField(-2, "connected");
    L->PushCFunction(l_he_native_load); L->SetField(-2, "native_load");
    L->PushCFunction(l_he_status);      L->SetField(-2, "status");
    L->PushSpecial(SPECIAL_GLOB); L->Push(-2); L->SetField(-2, "hordeengine"); L->Pop();
    L->Pop();
}

GMOD_MODULE_OPEN()  { ExportAll(LUA); return 0; }
GMOD_MODULE_CLOSE() { return 0; }
