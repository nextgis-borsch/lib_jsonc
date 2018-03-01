################################################################################
# Project:  json-c
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015-2018, NextGIS <info@nextgis.com>
# Copyright (C) 2012,2013,2014-2018 Dmitry Baryshnikov
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

if(NOT DEFINED PACKAGE_VENDOR)
    set(PACKAGE_VENDOR NextGIS)
endif()

if(NOT DEFINED PACKAGE_BUGREPORT)
    set(PACKAGE_BUGREPORT info@nextgis.com)
endif()


# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
    set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_EXECUTABLES ON)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)

    set(CMAKE_MACOSX_RPATH ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
endif()

# setup package meta-data
include(util)

check_version(JSON_C_MAJOR_VERSION JSON_C_MINOR_VERSION JSON_C_REV_VERSION)
set(VERSION ${JSON_C_MAJOR_VERSION}.${JSON_C_MINOR_VERSION}.${JSON_C_REV_VERSION})

report_version(${PROJECT_NAME} ${VERSION})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${JSON_C_MAJOR_VERSION}")
endif()

set(PACKAGE_NAME "JSONC")
set(PACKAGE_STRING "${PACKAGE_NAME} ${VERSION}")
set(PACKAGE_TARNAME ${PROJECT_NANE})

# setup paths
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR}/config)

if(MSVC)
    if(CMAKE_C_COMPILER_VERSION VERSION_LESS "18.0.31101.0")
        message(FATAL_ERROR "The compiled version is less than VC 2013 SP 4")
    endif()

    add_definitions (-D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NON_CONFORMING_SWPRINTFS -D_CRT_SECURE_NO_DEPRECATE)
endif()

include(configure)

set(HHEADERS
    ${CMAKE_CURRENT_BINARY_DIR}/config/config.h
    ${CMAKE_CURRENT_BINARY_DIR}/json_config.h
    arraylist.h
    bits.h
    debug.h
    json.h
    json_c_version.h
    json_inttypes.h
    json_object.h
    json_object_iterator.h
    json_object_private.h
    json_pointer.h
    json_tokener.h
    json_util.h
    json_visit.h
    linkhash.h
    math_compat.h
    printbuf.h
    random_seed.h
    snprintf_compat.h
    strdup_compat.h
    strerror_override.h
    strerror_override_private.h
    vasprintf_compat.h
)

set(CSOURCES
    arraylist.c
    debug.c
    json_c_version.c
    json_object.c
    json_object_iterator.c
    json_pointer.c
    json_tokener.c
    json_util.c
    json_visit.c
    linkhash.c
    printbuf.c
    random_seed.c
    strerror_override.c
)

set(LIB_NAME ${PROJECT_NAME})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${CSOURCES} ${HHEADERS})
    if(MSVC)
        set_target_properties(${LIB_NAME} PROPERTIES IMPORT_SUFFIX "_i.lib")
    endif()

    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${VERSION}
        SOVERSION ${JSON_C_MAJOR_VERSION}
        DEFINE_SYMBOL JSONC_DLL_EXPORTS)
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${CSOURCES} ${HHEADERS})
    set_target_properties(${LIB_NAME} PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION "${FRAMEWORK_VERSION}"
        VERSION ${VERSION}
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
        MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
        MACOSX_FRAMEWORK_IDENTIFIER org.jsonc.jsonc
        XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
        PUBLIC_HEADER "${HHEADERS}")
else()
    add_definitions(-DJSONC_STATIC)
    add_library(${LIB_NAME} STATIC ${CSOURCES} ${HHEADERS})
endif()

string(TOUPPER ${PACKAGE_NAME} PACKAGE_UPPER_NAME)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    install(TARGETS ${LIB_NAME}
        EXPORT ${PACKAGE_UPPER_NAME}Targets
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INC_DIR}
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
    )
endif()

# install headers
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HHEADERS} DESTINATION ${INSTALL_INC_DIR} COMPONENT headers)
endif()

# Testing ======================================================================
enable_testing()
if(BUILD_TESTING)
    include (CheckIncludeFile)
    check_include_file("locale.h" HAVE_LOCALE_H)
    if(HAVE_LOCALE_H)
        add_definitions(-DHAVE_LOCALE_H -DHAVE_SETLOCALE)
    endif()

    # Include macros for platform checks
    include(CheckFunctionExists)

    # Check for strcasecmp (case-insensitive strcmp())
    check_function_exists(strcasecmp HAVE_STRCASECMP)
    if(HAVE_STRCASECMP)
        add_definitions(-DHAVE_STRCASECMP)
    endif()

    macro(ADD_JSONC_TEST name)
        add_executable(${name} tests/${name}.c tests/parse_flags.c)
        target_link_libraries(${name} ${LIB_NAME})
        add_test(NAME jsonc_${name}
                 COMMAND ${CMAKE_COMMAND}
                 -DTEST_PROG=$<TARGET_FILE:${name}>
                 -DTEST_NAME=${name}
                 -DBINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
                 -DSOURCES_DIR=${CMAKE_CURRENT_SOURCE_DIR}
                 -P ${CMAKE_SOURCE_DIR}/cmake/TestCompareFiles.cmake)
    endmacro()

    add_jsonc_test(test1)
    add_jsonc_test(test2)
    add_jsonc_test(test4)
    add_jsonc_test(testReplaceExisting)
    add_jsonc_test(test_null)
    add_jsonc_test(test_locale)
    add_jsonc_test(test_charcase)
    add_jsonc_test(test_compare)
    # add_jsonc_test(test_deep_copy)
    add_jsonc_test(test_float)
    add_jsonc_test(test_int_add)
    # add_jsonc_test(test_json_pointer)
    add_jsonc_test(test_set_value)
    # add_jsonc_test(test_util_file)
if(UNIX)
    add_jsonc_test(test_printbuf)
    add_jsonc_test(test_set_serializer)
    add_jsonc_test(test_parse_int64)
    add_jsonc_test(test_cast)
    add_jsonc_test(test_parse)
    add_jsonc_test(test_visit)
endif()
endif()

# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

# Export package ===============================================================

# Add path to includes to build-tree export
target_include_directories(${LIB_NAME} INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)

# Add all targets to the build-tree export set
export(TARGETS ${LIB_NAME}
    FILE ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Targets.cmake)

if(REGISTER_PACKAGE)
    # Export the package for use from the build-tree
    # (this registers the build-tree with a global CMake-registry)
    export(PACKAGE ${PACKAGE_UPPER_NAME})
endif()

# Create the <Package>Config.cmake file
configure_file(cmake/PackageConfig.cmake.in
    ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake @ONLY)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    # Install the <Package>Config.cmake
    install(FILES
      ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake
      DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)

    # Install the export set for use with the install-tree
    install(EXPORT ${PACKAGE_UPPER_NAME}Targets DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)
endif()

# Archiving ====================================================================

set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "${PACKAGE_VENDOR}")
set(CPACK_PACKAGE_VERSION "${VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PACKAGE_NAME} Installation")
set(CPACK_PACKAGE_RELOCATABLE TRUE)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_GENERATOR "ZIP")
set(CPACK_MONOLITHIC_INSTALL ON)
set(CPACK_STRIP_FILES TRUE)

# Get cpack zip archive name
get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_CPACK_FILENAME})

include(CPack)
