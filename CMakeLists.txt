cmake_minimum_required(VERSION 3.10)

project(StaticLibsBuilder)

set(CSRC_DIR "${CMAKE_SOURCE_DIR}/csrc")
set(LIB_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

file(GLOB_RECURSE CSRC_FILES "${CSRC_DIR}/*.c")

file(MAKE_DIRECTORY ${LIB_OUTPUT_DIR})

foreach(SOURCE_FILE ${CSRC_FILES})
    get_filename_component(FILENAME ${SOURCE_FILE} NAME_WE)
    get_filename_component(DIR_PATH ${SOURCE_FILE} DIRECTORY)
    
    if(NOT "${DIR_PATH}" STREQUAL "${CSRC_DIR}")
        string(REPLACE "${CSRC_DIR}/" "" RELATIVE_PATH "${DIR_PATH}")
        add_subdirectory("${CSRC_DIR}/${RELATIVE_PATH}")
    else()
        add_library(${FILENAME} STATIC ${SOURCE_FILE})
        set_target_properties(${FILENAME} PROPERTIES
            ARCHIVE_OUTPUT_DIRECTORY "${LIB_OUTPUT_DIR}"
        )
    endif()
endforeach()
