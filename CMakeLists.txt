cmake_minimum_required(VERSION 3.16)
project(cosmic_native CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Optimization & SIMD Compiler Flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-O3 -march=native -ffast-math)
endif()

# Include luakit header library
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/native/external/luakit/lib)

# Locate Lua 5.4 include directory
find_path(LUA_INCLUDE_DIR NAMES lua.h PATH_SUFFIXES lua5.4 lua54 lua)

if(NOT LUA_INCLUDE_DIR)
    message(FATAL_ERROR "Lua 5.4 header (lua.h) not found!")
endif()

message(STATUS "Found Lua 5.4 Include Dir: ${LUA_INCLUDE_DIR}")
include_directories(${LUA_INCLUDE_DIR})

# C++ Source Files
set(SOURCES
    native/src/audio_synth.cpp
    native/src/spatial_grid.cpp
    native/src/starfield.cpp
    native/src/main_bindings.cpp
)

add_library(cosmic_native SHARED ${SOURCES})
set_target_properties(cosmic_native PROPERTIES PREFIX "" OUTPUT_NAME "cosmic_native")
