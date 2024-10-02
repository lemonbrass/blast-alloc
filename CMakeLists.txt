cmake_minimum_required(VERSION 3.10)
project(MyProject)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -g")

set(SRCDIR csrc)
set(LIBDIR lib)
set(BUILDDIR build)

include_directories(${SRCDIR})

file(GLOB_RECURSE SOURCES "${SRCDIR}/*.c")

foreach(SOURCE ${SOURCES})
    get_filename_component(SOURCE_NAME ${SOURCE} NAME_WE)
    add_library(${SOURCE_NAME} STATIC ${SOURCE})
endforeach()

set_target_properties(${SOURCE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${LIBDIR})

add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${BUILDDIR}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${LIBDIR}
)

install(DIRECTORY ${LIBDIR}/
        DESTINATION lib
        FILES_MATCHING PATTERN "*.a")
