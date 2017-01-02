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

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
    set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/Applications" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_EXECUTABLES ON)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)

    set(CMAKE_MACOSX_RPATH ON)

    # use, i.e. don't skip the full RPATH for the build tree
    #set(CMAKE_SKIP_BUILD_RPATH  TRUE)

    # when building, don't use the install RPATH already
    # (but later on when installing)
    #set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

    # the RPATH to be used when installing
    #set(CMAKE_INSTALL_RPATH "${INSTALL_LIB_DIR}")
    #set(CMAKE_INSTALL_RPATH "@executable_path/../../../../Library/Frameworks/")

    # don't add the automatically determined parts of the RPATH
    # which point to directories outside the build tree to the install RPATH
    #set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}" CACHE INTERNAL "Installation directory for headers" FORCE)
endif()

# setup package meta-data
include(util)

check_version(JSON_C_MAJOR_VERSION JSON_C_MINOR_VERSION JSON_C_REV_VERSION)
set(VERSION ${JSON_C_MAJOR_VERSION}.${JSON_C_MINOR_VERSION}.${JSON_C_REV_VERSION})

report_version(${PROJECT_NAME} ${VERSION})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${JSON_C_MAJOR_VERSION}")
endif()

set(PACKAGE_NAME "JSON C Library")
set(PACKAGE_STRING "${PACKAGE_NAME} ${VERSION}")
set(PACKAGE_TARNAME ${PROJECT_NANE})

# setup paths
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

if(MSVC)
    if(CMAKE_C_COMPILER_VERSION VERSION_LESS "18.0.31101.0")
        message(FATAL_ERROR "The compiled version is less than VC 2013 SP 4")
    endif()

    add_definitions (-D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NON_CONFORMING_SWPRINTFS -D_CRT_SECURE_NO_DEPRECATE)
endif()

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

set(LIB_NAME ${PROJECT_NAME})
if(BUILD_SHARED_LIBS)
    set(LIB_TYPE SHARED)
else()
    add_definitions(-DJSONC_STATIC)
    set(LIB_TYPE STATIC)
    if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
        set( CMAKE_CXX_FLAGS "-fpic ${CMAKE_CXX_FLAGS}" )
        set( CMAKE_C_FLAGS   "-fpic ${CMAKE_C_FLAGS}" )
    endif()
endif()

#set( CMAKE_C_FLAGS   "-std=c99 ${CMAKE_C_FLAGS}" )

if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} ${LIB_TYPE} ${CSOURCES} ${HHEADERS})
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
    set_target_properties (${LIB_NAME} PROPERTIES DEFINE_SYMBOL JSONC_DLL_EXPORTS)
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${CSOURCES} ${HHEADERS})
    set_target_properties(${LIB_NAME} PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION "${FRAMEWORK_VERSION}"
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
        MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
        MACOSX_FRAMEWORK_IDENTIFIER org.jsonc.jsonc
        XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
        PUBLIC_HEADER "${HHEADERS}")
    set_target_properties (${LIB_NAME} PROPERTIES VERSION ${VERSION})
else()
    add_library(${LIB_NAME} ${LIB_TYPE} ${CSOURCES} ${HHEADERS})
endif()

if (REGISTER_PACKAGE)
    export(TARGETS ${LIB_NAME} FILE ${LIB_NAME}-exports.cmake)
    set(EXPORT_PACKAGE_NAME JSONC)
    set(EXPORT_PACKAGE_NAME_UPPER JSONC)
    set(EXPORT_PACKAGE_LIB_NAME ${LIB_NAME})

    export(PACKAGE ${EXPORT_PACKAGE_NAME})

    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}Config.cmake
        INSTALL_DESTINATION ${INSTALL_LIB_DIR}/cmake
        PATH_VARS INSTALL_INC_DIR )
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}ConfigVersion.cmake
        VERSION ${VERSION}
        COMPATIBILITY AnyNewerVersion )
else()
    export(TARGETS ${LIB_NAME} FILE ${LIB_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME}
        RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT libraries
        LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
    )
endif()

# install headers
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HHEADERS} DESTINATION ${INSTALL_INC_DIR} COMPONENT headers)
endif()

# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
