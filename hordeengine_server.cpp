// hordeengine_server.cpp
#if defined(HORDE_MINIMAL_ONLY)
// Minimal build selected → don’t export the full server entry
extern "C" __declspec(dllexport) void __gm_server_not_selected__() {}
#else
#include <GarrysMod/Lua/Interface.h>
using namespace GarrysMod::Lua;

GMOD_MODULE_OPEN()
{
    // ... full init ...
    return 0;
}

GMOD_MODULE_CLOSE()
{
    // ... full shutdown ...
    return 0;
}
#endif
