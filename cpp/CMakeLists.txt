cmake_minimum_required(VERSION 3.16)
project(worldline_wasm)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Emscripten specific settings
if(EMSCRIPTEN)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s WASM=1 -s EXPORTED_FUNCTIONS='[\"_F0\", \"_DecodeMgc\", \"_DecodeBap\", \"_WorldSynthesis\", \"_Resample\", \"_PhraseSynthNew\", \"_PhraseSynthDelete\", \"_PhraseSynthAddRequest\", \"_PhraseSynthSetCurves\", \"_PhraseSynthSynth\"]' -s EXPORTED_RUNTIME_METHODS='[\"ccall\", \"cwrap\"]' -s ALLOW_MEMORY_GROWTH=1 -s INITIAL_MEMORY=16777216 -s MAXIMUM_MEMORY=268435456")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s EXPORT_NAME='WorldlineModule' -s MODULARIZE=1")
endif()

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/worldline
    ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/world
    ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/miniaudio
    ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/xxhash
)

# Source files
file(GLOB_RECURSE SOURCES 
    "worldline/*.cpp"
    "dependencies/world/*.cpp"
)

# Create the library
add_library(worldline_wasm STATIC ${SOURCES})

# Set output directory
set_target_properties(worldline_wasm PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../node/dist
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../node/dist
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../node/dist
)

# Emscripten specific output
if(EMSCRIPTEN)
    set_target_properties(worldline_wasm PROPERTIES
        SUFFIX ".js"
    )
endif() 