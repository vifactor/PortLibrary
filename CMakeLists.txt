cmake_minimum_required(VERSION 2.8)
#project(port_lib)

enable_language(Fortran)
set( SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src )
#set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )
#set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )
#set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )

file(GLOB F_SOURCES "${SOURCES}/*.f")
file(GLOB F90_SOURCES "${SOURCES}/*.f90")
file(GLOB HEADERS "${SOURCES}/*.h")

add_library(port STATIC ${F_SOURCES} ${F90_SOURCES})

install(FILES ${HEADERS} 
        DESTINATION ${CMAKE_BINARY_DIR})
