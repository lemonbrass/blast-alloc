cmake_minimum_required(VERSION 3.10)

project(commons)

set(CSRC_DIR "${CMAKE_SOURCE_DIR}/csrc")
set(LIB_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

file(GLOB CSRC_FILES "${CSRC_DIR}/*.c")

file(MAKE_DIRECTORY ${LIB_OUTPUT_DIR})

foreach(SOURCE_FILE ${CSRC_FILES})
    get_filename_component(FILENAME ${SOURCE_FILE} NAME_WE)
    add_library(${FILENAME} STATIC ${SOURCE_FILE})
    set_target_properties(${FILENAME} PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${LIB_OUTPUT_DIR}"
    )
endforeach()
