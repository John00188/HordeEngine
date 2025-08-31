cmake_minimum_required(VERSION 3.21)
project(HordeEngine LANGUAGES CXX)

# =============== Options ==========================
option(HORDE_MINIMAL_ONLY "Build the tiny stub entry instead of full server entry" OFF)

# =============== Tooling ==========================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(MSVC)
  add_compile_definitions(NOMINMAX WIN32_LEAN_AND_MEAN _CRT_SECURE_NO_WARNINGS)
  add_compile_options(/permissive- /EHsc /MP)
endif()

# =============== Sources (server-only + core) =====
# Keep this tight to avoid pulling examples/tests.
file(GLOB_RECURSE SRC_SERVER CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/src/server/*.cpp")
file(GLOB_RECURSE SRC_CORE   CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/src/core/*.cpp" "${CMAKE_SOURCE_DIR}/core/*.cpp")

# Top-level .cpp files (exclude the two entry files; we'll add the chosen one back)
file(GLOB ROOT_CPP CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/*.cpp")
list(FILTER ROOT_CPP EXCLUDE REGEX ".*/(minimal_only|hordeengine_server)\\.cpp$")

# Entry files (exactly one must be compiled)
set(ENTRY_MIN "${CMAKE_SOURCE_DIR}/minimal_only.cpp")
set(ENTRY_SRV "${CMAKE_SOURCE_DIR}/hordeengine_server.cpp")

set(ENTRY_CXX "")
if(HORDE_MINIMAL_ONLY)
  if(EXISTS "${ENTRY_MIN}")
    set(ENTRY_CXX "${ENTRY_MIN}")
  elseif(EXISTS "${ENTRY_SRV}")
    message(WARNING "minimal_only.cpp not found; falling back to hordeengine_server.cpp")
    set(ENTRY_CXX "${ENTRY_SRV}")
  endif()
else()
  if(EXISTS "${ENTRY_SRV}")
    set(ENTRY_CXX "${ENTRY_SRV}")
  elseif(EXISTS "${ENTRY_MIN}")
    message(WARNING "hordeengine_server.cpp not found; falling back to minimal_only.cpp")
    set(ENTRY_CXX "${ENTRY_MIN}")
  endif()
endif()

if(NOT ENTRY_CXX)
  message(FATAL_ERROR "No entry file found. Expected one of:\n  ${ENTRY_SRV}\n  ${ENTRY_MIN}")
endif()

set(COMMON_SOURCES
  ${ROOT_CPP}
  ${SRC_SERVER}
  ${SRC_CORE}
)

# =============== garrysmod_common =================
# Use the submodule if present; otherwise auto-fetch so first-time builds "just work".
set(GMOD_COMMON_DIR "${CMAKE_SOURCE_DIR}/deps/garrysmod_common")
if(NOT EXISTS "${GMOD_COMMON_DIR}/include/GarrysMod/Lua/Interface.h")
  include(FetchContent)
  message(STATUS "garrysmod_common not found; fetching via FetchContent...")
  FetchContent_Declare(garrysmod_common
    GIT_REPOSITORY https://github.com/danielga/garrysmod_common
    GIT_TAG        master
  )
  FetchContent_MakeAvailable(garrysmod_common)
  set(GMOD_COMMON_DIR "${garrysmod_common_SOURCE_DIR}")
endif()

# =============== Helper to make a GMOD target =====
function(add_horde_target tgt gmdef out_subdir)
  set(SRCS ${COMMON_SOURCES} "${ENTRY_CXX}")      # only the chosen entry gets compiled

  add_library(${tgt} MODULE ${SRCS})
  set_target_properties(${tgt} PROPERTIES PREFIX "" OUTPUT_NAME "${tgt}")
  target_compile_definitions(${tgt} PRIVATE ${gmdef})
  if(HORDE_MINIMAL_ONLY)
    target_compile_definitions(${tgt} PRIVATE HORDE_MINIMAL_ONLY=1)
  endif()

  target_include_directories(${tgt} PRIVATE
    "${CMAKE_SOURCE_DIR}"
    "${CMAKE_SOURCE_DIR}/include"
    "${CMAKE_SOURCE_DIR}/src"
    "${CMAKE_SOURCE_DIR}/src/server"
    "${CMAKE_SOURCE_DIR}/src/core"
    "${GMOD_COMMON_DIR}/include"
  )

  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ARCH_DIR x64)
  else()
    set(ARCH_DIR x86)
  endif()

  foreach(cfg IN ITEMS Debug Release RelWithDebInfo MinSizeRel)
    string(TOUPPER "${cfg}" CFG)
    set_target_properties(${tgt} PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY_${CFG} "${CMAKE_SOURCE_DIR}/bin/${out_subdir}/${ARCH_DIR}/${cfg}"
      LIBRARY_OUTPUT_DIRECTORY_${CFG} "${CMAKE_SOURCE_DIR}/bin/${out_subdir}/${ARCH_DIR}/${cfg}"
      ARCHIVE_OUTPUT_DIRECTORY_${CFG} "${CMAKE_SOURCE_DIR}/bin/${out_subdir}/${ARCH_DIR}/${cfg}"
    )
  endforeach()

  # Optional auto-copy to your game if you set GMOD_BIN_DIR
  if(DEFINED ENV{GMOD_BIN_DIR})
    add_custom_command(TARGET ${tgt} POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E make_directory "$ENV{GMOD_BIN_DIR}"
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different
              "$<TARGET_FILE:${tgt}>"
              "$ENV{GMOD_BIN_DIR}/$<TARGET_FILE_NAME:${tgt}>")
  endif()
endfunction()

# =============== Targets ==========================
# Server binary: gmsv_hordeengine_win64.dll
add_horde_target(gmsv_hordeengine_win64 GMOD_SERVER=1 "server")

# Client binary (optional): gmcl_hordeengine_win64.dll
# Comment out the next line if your code isn't client-safe yet.
add_horde_target(gmcl_hordeengine_win64 GMOD_CLIENT=1 "client")

# =============== Logs =============================
message(STATUS "HORDE_MINIMAL_ONLY = ${HORDE_MINIMAL_ONLY}")
message(STATUS "Entry file         = ${ENTRY_CXX}")
message(STATUS "Server DLL output  = ${CMAKE_SOURCE_DIR}/bin/server/x64/<Config>/")
message(STATUS "Client DLL output  = ${CMAKE_SOURCE_DIR}/bin/client/x64/<Config>/")
