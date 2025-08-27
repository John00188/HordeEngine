cmake_minimum_required(VERSION 3.20)
project(HordeEngine LANGUAGES CXX)

# --- Language standard ---
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# --- Fetch Facepunch gmod-module-base headers ---
include(FetchContent)
FetchContent_Declare(
  gmod-module-base
  GIT_REPOSITORY https://github.com/Facepunch/gmod-module-base.git
  GIT_TAG development
)
FetchContent_MakeAvailable(gmod-module-base)

# --- Helper to set output dir ---
function(he_set_out tgt)
  get_property(MC GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(MC)
    set(_out "${CMAKE_BINARY_DIR}/out/$<CONFIG>")
  else()
    set(_out "${CMAKE_BINARY_DIR}/out")
  endif()
  set_target_properties(${tgt} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${_out}"
    LIBRARY_OUTPUT_DIRECTORY "${_out}"
    ARCHIVE_OUTPUT_DIRECTORY "${_out}")
endfunction()

# --- Client DLL ---
add_library(gmcl_hordeengine_win64 SHARED
  src/client/module_client.cpp
)
target_compile_definitions(gmcl_hordeengine_win64 PRIVATE GMOD_CLIENT)
target_include_directories(gmcl_hordeengine_win64 PRIVATE
  ${gmod-module-base_SOURCE_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/src
)
set_target_properties(gmcl_hordeengine_win64 PROPERTIES OUTPUT_NAME "gmcl_hordeengine_win64")
he_set_out(gmcl_hordeengine_win64)

# --- Server DLL ---
add_library(gmsv_hordeengine_win64 SHARED
  src/server/module_server.cpp
)
target_compile_definitions(gmsv_hordeengine_win64 PRIVATE GMOD_SERVER)
target_include_directories(gmsv_hordeengine_win64 PRIVATE
  ${gmod-module-base_SOURCE_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/src
)
set_target_properties(gmsv_hordeengine_win64 PROPERTIES OUTPUT_NAME "gmsv_hordeengine_win64")
he_set_out(gmsv_hordeengine_win64)
