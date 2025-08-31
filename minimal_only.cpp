// minimal_only.cpp
#if !defined(HORDE_MINIMAL_ONLY)
// Not the active entrypoint → export a harmless symbol so link succeeds,
extern "C" __declspec(dllexport) void __gm_minimal_not_selected__() {}
#else
#include <GarrysMod/Lua/Interface.h>
using namespace GarrysMod::Lua;

GMOD_MODULE_OPEN()
{
    // ... minimal init ...
    return 0;
}

GMOD_MODULE_CLOSE()
{
    // ... minimal shutdown ...
    return 0;
}
#endif
