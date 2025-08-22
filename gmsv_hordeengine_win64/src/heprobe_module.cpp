// heprobe_module.cpp — tiny, safe probe
#include <GarrysMod/Lua/Interface.h>
#include <windows.h>
using namespace GarrysMod::Lua;

static void push_self_path(ILuaBase* L)
{
    HMODULE mod = nullptr;
    // Get HMODULE for this DLL by using an address inside it
    GetModuleHandleExA(
      GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
      reinterpret_cast<LPCSTR>(&push_self_path), &mod);
    char buf[MAX_PATH] = {0};
    DWORD n = mod ? GetModuleFileNameA(mod, buf, MAX_PATH) : 0;
    L->PushString(n ? buf : "");
}

LUA_FUNCTION(l_heprobe_version) { LUA->PushString("heprobe/0.1"); return 1; }
LUA_FUNCTION(l_heprobe_status)  { LUA->PushString("ok"); return 1; }

LUA_FUNCTION(l_heprobe_cpath)
{
    LUA->GetGlobal("package");
    if (!LUA->IsType(-1, GarrysMod::Lua::Type::TABLE)) { LUA->Pop(); LUA->PushString(""); return 1; }
    LUA->GetField(-1, "cpath");
    const char* s = LUA->IsType(-1, GarrysMod::Lua::Type::STRING) ? LUA->GetString(-1) : "";
    LUA->Pop(2);
    LUA->PushString(s);
    return 1;
}

LUA_FUNCTION(l_heprobe_path)
{
    LUA->GetGlobal("package");
    if (!LUA->IsType(-1, GarrysMod::Lua::Type::TABLE)) { LUA->Pop(); LUA->PushString(""); return 1; }
    LUA->GetField(-1, "path");
    const char* s = LUA->IsType(-1, GarrysMod::Lua::Type::STRING) ? LUA->GetString(-1) : "";
    LUA->Pop(2);
    LUA->PushString(s);
    return 1;
}

LUA_FUNCTION(l_heprobe_self) { push_self_path(LUA); return 1; }

static void ExportAll(ILuaBase* L)
{
    // heprobe table
    L->CreateTable();
    L->PushCFunction(l_heprobe_version); L->SetField(-2, "version");
    L->PushCFunction(l_heprobe_status);  L->SetField(-2, "status");
    L->PushCFunction(l_heprobe_cpath);   L->SetField(-2, "cpath");
    L->PushCFunction(l_heprobe_path);    L->SetField(-2, "path");
    L->PushCFunction(l_heprobe_self);    L->SetField(-2, "self");

    L->PushSpecial(SPECIAL_GLOB); L->Push(-2); L->SetField(-2, "heprobe"); L->Pop();
    L->Pop();
}

GMOD_MODULE_OPEN()  { ExportAll(LUA); return 0; }
GMOD_MODULE_CLOSE() { return 0; }
