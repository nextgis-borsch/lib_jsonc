################################################################################
# Project:  json-c
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015-2016, NextGIS <info@nextgis.com>
# Copyright (C) 2012,2013,2014 Dmitry Baryshnikov
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################
cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)

project(json-c)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
set(INSTALL_LIB_DIR "lib" CACHE INTERNAL "Installation directory for libraries" FORCE)
set(INSTALL_INC_DIR "include/${PROJECT_NAME}" CACHE INTERNAL "Installation directory for headers" FORCE)

# setup package meta-data
include(util)

check_version(JSON_C_MAJOR_VERSION JSON_C_MINOR_VERSION JSON_C_REV_VERSION)
set(VERSION ${JSON_C_MAJOR_VERSION}.${JSON_C_MINOR_VERSION}.${JSON_C_REV_VERSION})

report_version(${PROJECT_NAME} ${VERSION})  

set(PACKAGE_NAME "JSON C Library")
set(PACKAGE_STRING "${PACKAGE_NAME} ${VERSION}")
set(PACKAGE_TARNAME ${PROJECT_NANE})

# setup paths
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

include(configure)

set(HHEADERS
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    ${CMAKE_CURRENT_BINARY_DIR}/json_config.h
    arraylist.h
    bits.h
    debug.h
    json_c_version.h
    json.h
    json_inttypes.h
    json_object.h
    json_object_iterator.h
    json_object_private.h
    json_tokener.h
    json_util.h
    math_compat.h
    linkhash.h
    printbuf.h
    random_seed.h
)

set(CSOURCES
    arraylist.c
    debug.c
    json_c_version.c
    json_object.c
    json_object_iterator.c
    json_tokener.c
    json_util.c
    linkhash.c
    printbuf.c
    random_seed.c
)

set(LIB_NAME)
if(BUILD_SHARED_LIBS)
    set(LIB_TYPE SHARED)
    set(LIB_NAME ${PROJECT_NAME})
else()
    set(LIB_TYPE STATIC)
    set(LIB_NAME ${PROJECT_NAME}static)
endif()

add_library(${LIB_NAME} ${LIB_TYPE} ${CSOURCES} ${HHEADERS})

if(BUILD_SHARED_LIBS)
    if(WIN32)
        set (LIB_VERSION ${JSON_C_MAJOR_VERSION})
        if(MSVC)        
            set_target_properties(${LIB_NAME} PROPERTIES IMPORT_SUFFIX "_i.lib")
        endif()
    else ()
        set (LIB_VERSION ${VERSION})
    endif()    
    set_target_properties (${LIB_NAME} PROPERTIES VERSION ${LIB_VERSION})
    set_target_properties (${LIB_NAME} PROPERTIES SOVERSION ${LIB_VERSION})
endif()


export(TARGETS ${LIB_NAME} FILE ${LIB_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)

install(TARGETS ${LIB_NAME} RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT libraries
                      LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
                      ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries)
                      

# install headers
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HHEADERS} DESTINATION ${INSTALL_INC_DIR} COMPONENT headers)
endif()

# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

