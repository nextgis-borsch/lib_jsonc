################################################################################
# Project:  json-c
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
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
cmake_minimum_required (VERSION 2.8.10 FATAL_ERROR)

# main settings
set(PROJECT_NAME "jsonc")
project(${PROJECT_NAME})

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configs" FORCE)

# setup paths
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

# read and report version
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/json_c_version.h JSONC_VERSION_H_CONTENTS)
string(REGEX MATCH "JSON_C_MAJOR_VERSION[ \t]+([0-9]+)"
  JSON_C_MAJOR_VERSION ${JSONC_VERSION_H_CONTENTS})
string (REGEX MATCH "([0-9]+)"
  JSON_C_MAJOR_VERSION ${JSON_C_MAJOR_VERSION})
string(REGEX MATCH "JSON_C_MINOR_VERSION[ \t]+([0-9]+)"
  JSON_C_MINOR_VERSION ${JSONC_VERSION_H_CONTENTS})
string (REGEX MATCH "([0-9]+)"
  JSON_C_MINOR_VERSION ${JSON_C_MINOR_VERSION})

string(REGEX MATCH "JSON_C_MICRO_VERSION[ \t]+([0-9]+)"
  JSON_C_MICRO_VERSION ${JSONC_VERSION_H_CONTENTS})
string (REGEX MATCH "([0-9]+)"
  JSON_C_MICRO_VERSION ${JSON_C_MICRO_VERSION})

set(JSON_C_VERSION ${JSON_C_MAJOR_VERSION}.${JSON_C_MINOR_VERSION})
message(STATUS "json-c version=[${JSON_C_VERSION}]")

if(WIN32)
    set(JSON_C_LIB_NAME jsonc${JSON_C_MAJOR_VERSION}${JSON_C_MINOR_VERSION})
elseif(UNIX)
    set(JSON_C_LIB_NAME jsonc)
endif()
message(STATUS "jsonc lib name ... " ${JSON_C_LIB_NAME})

include(configure)

set(HHEADERS
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
    linkhash.h
    printbuf.h
    symbol_renames.h
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
)

# create library
option(JSON_C_BUILD_SHARED "Set ON to build shared library" ON)
if(JSON_C_BUILD_SHARED)
    add_library(${JSON_C_LIB_NAME} SHARED ${HHEADERS} ${CSOURCES})
else(JSON_C_BUILD_SHARED)
    add_library(${JSON_C_LIB_NAME} STATIC ${HHEADERS} ${CSOURCES})
endif(JSON_C_BUILD_SHARED)

set_target_properties(${JSON_C_LIB_NAME}
    PROPERTIES PROJECT_LABEL ${PROJECT_NAME}
    VERSION ${JSON_C_VERSION}
    SOVERSION 1
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

#install lib and bin

install(TARGETS ${JSON_C_LIB_NAME}
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
    )
