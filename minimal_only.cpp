#include <GarrysMod/Lua/Interface.h>
using namespace GarrysMod::Lua;

LUA_FUNCTION(l_he_ping) { LUA->PushString("pong"); return 1; }

GMOD_MODULE_OPEN() {
    LUA->PushSpecial(SPECIAL_GLOB);
    LUA->PushCFunction(l_he_ping);
    LUA->SetField(-2, "he_ping");
    LUA->Pop();
    return 0;
}
GMOD_MODULE_CLOSE() { return 0; }
