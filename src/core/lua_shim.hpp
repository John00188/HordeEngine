// src/core/lua_shim.hpp
#pragma once
#include <GarrysMod/Lua/Interface.h>

namespace gm = GarrysMod::Lua;

inline void GetGlobal(gm::ILuaBase* L, const char* name) {
	L->PushSpecial(gm::SPECIAL_GLOB);   // push _G
	L->GetField(-1, name);              // _G[name]
	L->Remove(-2);                      // pop _G
}
