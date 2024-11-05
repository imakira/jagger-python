cmake_minimum_required(VERSION 3.16)

set(EXE_TARGET "jagger_cli.js")
set(JS_TARGET_DEV "jagger-standalone.js")
set(JS_LIB "jagger-binding.js")
project(${EXE_TARGET} CXX)

set(CMAKE_C_COMPILER   emcc)
set(CMAKE_CXX_COMPILER em++)
set(CMAKE_CXX_FLAGS "-sSTACK_SIZE=1048576 -lembind -sALLOW_MEMORY_GROWTH=1")
set(CMAKE_EXE_LINKER_FLAGS "-sSTACK_SIZE=1048576 -lembind -sALLOW_MEMORY_GROWTH=1")
set(CMAKE_CXX_FLAGS_DEBUG "-fno-omit-frame-pointer -g -O0 -fsanitize=address")
# set(CMAKE_EXE_LINKER_FLAGS_DEBUG "")
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -flto")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-O2 -flto")
# set(CMAKE_CXX_FLAGS_RELEASE "")


set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
option(JAGGER_WASM "" ON)

# cmake modules
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/sanitizers)
find_package(Sanitizers) # Address sanitizer (-DSANITIZE_ADDRESS=ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(${EXE_TARGET} cpp_cli/jagger-app.cc)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_sanitizers(${EXE_TARGET})
endif()
file(COPY kwdlc DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/)
target_link_options(${EXE_TARGET} PUBLIC --preload-file kwdlc)

add_executable(${JS_LIB} jagger/python-binding-jagger.cc)
target_compile_options(${JS_LIB} PUBLIC)
target_link_options(${JS_LIB} PUBLIC -sMODULARIZE -sEXPORT_NAME="initJagger" -sEXTRA_EXPORTED_RUNTIME_METHODS=["FS"])
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_sanitizers(${JS_LIB})
endif()

target_include_directories(${EXE_TARGET} PRIVATE jagger)
target_include_directories(${JS_LIB} PRIVATE jagger)

# enable mmap by default.
target_compile_definitions(${EXE_TARGET} PRIVATE "JAGGER_USE_MMAP_IO")
# target_compile_definitions(${JS_LIB} PRIVATE "JAGGER_USE_MMAP_IO")
