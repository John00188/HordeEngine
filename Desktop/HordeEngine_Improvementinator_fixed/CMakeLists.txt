cmake_minimum_required(VERSION 3.20)
project(HordeEngine_Improvementinator CXX)

# Force default build type to Release if not specified for single-config generators
if(NOT CMAKE_CONFIGURATION_TYPES)
    if(NOT CMAKE_BUILD_TYPE)
        message(STATUS "No build type selected, defaulting to Release")
        set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
    endif()
else()
    # For multi-config generators, set default build type to Release
    set(CMAKE_DEFAULT_BUILD_TYPE "Release")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")

# Option: where the Facepunch headers live (relative to this project)
# You can change this to your local path.
set(GMOD_MODULE_BASE_INCLUDE "${CMAKE_SOURCE_DIR}/dev/gmod-module-base/include" CACHE PATH "Path to gmod-module-base/include")

include_directories("${GMOD_MODULE_BASE_INCLUDE}")

add_definitions(-DGMOD_ALLOW_DEPRECATED)

# Shared core
add_library(he_core STATIC
    src/core/he_core.cpp
)
target_include_directories(he_core PUBLIC src)

# Server module
add_library(gmsv_hordeengine_win64 MODULE
    src/server/module_server.cpp
    src/core/he_core.cpp
)
target_link_libraries(gmsv_hordeengine_win64 PRIVATE he_core)
set_target_properties(gmsv_hordeengine_win64 PROPERTIES PREFIX "" SUFFIX ".dll")

# Client module
add_library(gmcl_hordeengine_win64 MODULE
    src/client/module_client.cpp
    src/core/he_core.cpp
)
target_link_libraries(gmcl_hordeengine_win64 PRIVATE he_core)
set_target_properties(gmcl_hordeengine_win64 PROPERTIES PREFIX "" SUFFIX ".dll")

# Output to a 'bin' folder next to the project for convenience
set_target_properties(gmsv_hordeengine_win64 PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set_target_properties(gmcl_hordeengine_win64 PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
