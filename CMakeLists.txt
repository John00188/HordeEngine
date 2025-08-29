cmake_minimum_required(VERSION 3.20)
project(HordeEngine LANGUAGES CXX)

# Enforce x64-only builds
if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "HordeEngine requires a 64-bit build")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Fetch gmod-module-base
include(FetchContent)
FetchContent_Declare(
  gmod_module_base
  GIT_REPOSITORY https://github.com/Facepunch/gmod-module-base.git
  GIT_TAG master
)
FetchContent_MakeAvailable(gmod_module_base)

# Generate lua_shared.lib if missing
set(LUA_SHARED_LIB "${CMAKE_CURRENT_SOURCE_DIR}/lua_shared.lib")
if(NOT EXISTS "${LUA_SHARED_LIB}")
  if(WIN32)
    add_custom_command(
      OUTPUT "${LUA_SHARED_LIB}"
      COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/Make-LuaSharedLib.cmd"
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
      COMMENT "Generating lua_shared.lib"
    )
  else()
    message(WARNING "lua_shared.lib missing and cannot be generated on non-Windows hosts")
  endif()
endif()
add_custom_target(lua_shared DEPENDS "${LUA_SHARED_LIB}")

# Helper to set output directories
function(he_set_out target type)
  set(dir "${CMAKE_BINARY_DIR}/bin/${type}/x64/$<CONFIG>")
  set_target_properties(${target} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${dir}"
    LIBRARY_OUTPUT_DIRECTORY "${dir}"
    ARCHIVE_OUTPUT_DIRECTORY "${dir}")
endfunction()

# Server DLL
add_library(gmsv_hordeengine_win64 SHARED
  server/hordeengine_server.cpp
)
target_compile_definitions(gmsv_hordeengine_win64 PRIVATE GMOD_SERVER)
target_include_directories(gmsv_hordeengine_win64 PRIVATE
  ${gmod_module_base_SOURCE_DIR}/include
)
target_link_libraries(gmsv_hordeengine_win64 PRIVATE
  "${LUA_SHARED_LIB}"
  "${CMAKE_CURRENT_SOURCE_DIR}/tier0.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/vstdlib.lib"
)
add_dependencies(gmsv_hordeengine_win64 lua_shared)
he_set_out(gmsv_hordeengine_win64 server)
add_custom_command(TARGET gmsv_hordeengine_win64 POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:gmsv_hordeengine_win64> "E:/SteamLibrary/steamapps/common/GarrysMod/garrysmod/lua/bin/$<TARGET_FILE_NAME:gmsv_hordeengine_win64>")

# Client DLL
add_library(gmcl_hordeengine_win64 SHARED
  client/hordeengine_client.cpp
)
target_compile_definitions(gmcl_hordeengine_win64 PRIVATE GMOD_CLIENT)
target_include_directories(gmcl_hordeengine_win64 PRIVATE
  ${gmod_module_base_SOURCE_DIR}/include
)
target_link_libraries(gmcl_hordeengine_win64 PRIVATE
  "${LUA_SHARED_LIB}"
  "${CMAKE_CURRENT_SOURCE_DIR}/tier0.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/vstdlib.lib"
)
add_dependencies(gmcl_hordeengine_win64 lua_shared)
he_set_out(gmcl_hordeengine_win64 client)
add_custom_command(TARGET gmcl_hordeengine_win64 POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:gmcl_hordeengine_win64> "E:/SteamLibrary/steamapps/common/GarrysMod/garrysmod/lua/bin/$<TARGET_FILE_NAME:gmcl_hordeengine_win64>")

# Ensure ALL_BUILD builds both modules
add_custom_target(build_all ALL)
add_dependencies(build_all gmsv_hordeengine_win64 gmcl_hordeengine_win64)
