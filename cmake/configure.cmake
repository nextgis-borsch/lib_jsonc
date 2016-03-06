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

# Include all the necessary files for macros
include (CheckFunctionExists)
include (CheckIncludeFile)
include (CheckIncludeFiles)
include (CheckLibraryExists)
include (CheckSymbolExists)
include (CheckTypeSize)
include (TestBigEndian)
# include (CheckCXXSourceCompiles)
# include (CompilerFlags)

check_include_file("inttypes.h" JSON_C_HAVE_INTTYPES_H)
check_include_file("inttypes.h" HAVE_INTTYPES_H)
check_include_file("fcntl.h" HAVE_FCNTL_H)
check_function_exists(open HAVE_OPEN)
check_function_exists(realloc HAVE_REALLOC)
check_function_exists(strdup HAVE_STRDUP)
check_include_file("stdarg.h" HAVE_STDARG_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file("strings.h" HAVE_STRINGS_H)
check_include_file("syslog.h" HAVE_SYSLOG_H)
check_include_file("sys/param.h" HAVE_SYS_PARAM_H)
check_include_file("sys/stat.h" HAVE_SYS_STAT_H)
check_include_file("unistd.h" HAVE_UNISTD_H)

check_include_file("ctype.h" HAVE_CTYPE_H)
check_include_file("stdlib.h" HAVE_STDLIB_H)

if (HAVE_CTYPE_H AND HAVE_STDLIB_H)
    set(STDC_HEADERS 1)
endif ()

check_function_exists(vsyslog HAVE_VSYSLOG)
check_function_exists(strncasecmp HAVE_STRNCASECMP)
check_function_exists(snprintf HAVE_SNPRINTF)

configure_file(${CMAKE_MODULE_PATH}/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)
configure_file(${CMAKE_MODULE_PATH}/json_config.h.in ${CMAKE_CURRENT_BINARY_DIR}/json_config.h @ONLY)
configure_file(${CMAKE_MODULE_PATH}/uninstall.cmake.in ${CMAKE_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)
