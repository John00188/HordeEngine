cmake_minimum_required(VERSION 3.16)
project(hordeengine LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Force x64
if (NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR "HordeEngine must be built as x64, not Win32.")
endif()

# Where DLLs go in your local GMod install
set(GMOD_LUABIN "E:/SteamLibrary/steamapps/common/GarrysMod/garrysmod/lua/bin")

# Add sources
set(SOURCES
    src/hordeengine_server.cpp
    src/minimal_only.cpp
)

# Build both server + client DLLs
add_library(gmsv_hordeengine_win64 SHARED ${SOURCES})
add_library(gmcl_hordeengine_win64 SHARED ${SOURCES})

# Include paths
target_include_directories(gmsv_hordeengine_win64 PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_include_directories(gmcl_hordeengine_win64 PRIVATE ${CMAKE_SOURCE_DIR}/include)

# ========================
# Post-Build Copy (LOCAL)
# ========================
if(NOT DEFINED ENV{GITHUB_ACTIONS})
    message(STATUS "Local build detected — enabling copy to Garry's Mod.")

    # Copy server DLL
    add_custom_command(TARGET gmsv_hordeengine_win64 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${GMOD_LUABIN}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:gmsv_hordeengine_win64>
            "${GMOD_LUABIN}/"
    )

    # Copy client DLL
    add_custom_command(TARGET gmcl_hordeengine_win64 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${GMOD_LUABIN}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:gmcl_hordeengine_win64>
            "${GMOD_LUABIN}/"
    )
else()
    message(STATUS "CI build detected — skipping copy to Garry's Mod.")
endif()
