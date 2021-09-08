################################################################################
# Project:  json-c
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015-2021, NextGIS <info@nextgis.com>
# Copyright (C) 2012,2013,2014-2019 Dmitry Baryshnikov
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

if(POLICY CMP0054)
    cmake_policy(SET CMP0054 NEW)
endif()

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

set(PACKAGE_NAME "jsonc")
set(PACKAGE_STRING "${PACKAGE_NAME} ${VERSION}")
set(PACKAGE_TARNAME ${PROJECT_NANE})

# setup package meta-data
include(util)

check_version(JSON_C_MAJOR_VERSION JSON_C_MINOR_VERSION JSON_C_REV_VERSION)
set(VERSION ${JSON_C_MAJOR_VERSION}.${JSON_C_MINOR_VERSION}.${JSON_C_REV_VERSION})

report_version(${PROJECT_NAME} ${VERSION})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${JSON_C_MAJOR_VERSION}")
endif()

# Enable or disable features. By default, all features are turned off.
option(DISABLE_BSYMBOLIC              "Avoid linking with -Bsymbolic-function."               OFF)
option(DISABLE_THREAD_LOCAL_STORAGE   "Disable using Thread-Local Storage (HAVE___THREAD)."   OFF)
option(ENABLE_RDRAND                  "Enable RDRAND Hardware RNG Hash Seed."                 OFF)

set(CMAKE_C_FLAGS_RELEASE   "${CMAKE_C_FLAGS_RELEASE} -O2")

if (MSVC)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS /D_CRT_SECURE_NO_DEPRECATE)
    list(APPEND CMAKE_REQUIRED_FLAGS /wd4996)
endif()

if (NOT DISABLE_STATIC_FPIC)
    # Use '-fPIC'/'-fPIE' option.
    # This will allow other libraries to statically link in libjson-c.a
    # which in turn prevents crashes in downstream apps that may use
    # a different JSON library with identical symbol names.
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

include(CheckSymbolExists)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckCSourceCompiles)
include(CheckTypeSize)
include(CMakePackageConfigHelpers)

check_include_file("fcntl.h"        HAVE_FCNTL_H)
check_include_file("inttypes.h"     HAVE_INTTYPES_H)
check_include_file(stdarg.h         HAVE_STDARG_H)
check_include_file(strings.h        HAVE_STRINGS_H)
check_include_file(string.h         HAVE_STRING_H)
check_include_file(syslog.h         HAVE_SYSLOG_H)


check_include_files("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS)

check_include_file(unistd.h         HAVE_UNISTD_H)
check_include_file(sys/types.h      HAVE_SYS_TYPES_H)
check_include_file(sys/resource.h   HAVE_SYS_RESOURCE_H) # for getrusage

check_include_file("dlfcn.h"        HAVE_DLFCN_H)
check_include_file("endian.h"       HAVE_ENDIAN_H)
check_include_file("limits.h"       HAVE_LIMITS_H)
check_include_file("locale.h"       HAVE_LOCALE_H)
check_include_file("memory.h"       HAVE_MEMORY_H)

check_include_file(stdint.h         HAVE_STDINT_H)
check_include_file(stdlib.h         HAVE_STDLIB_H)
check_include_file(sys/cdefs.h      HAVE_SYS_CDEFS_H)
check_include_file(sys/param.h      HAVE_SYS_PARAM_H)
check_include_file(sys/stat.h       HAVE_SYS_STAT_H)
check_include_file(xlocale.h        HAVE_XLOCALE_H)

if (HAVE_INTTYPES_H AND NOT MSVC)
    set(JSON_C_HAVE_INTTYPES_H 1)
endif()

check_symbol_exists(_isnan          "float.h" HAVE_DECL__ISNAN)
check_symbol_exists(_finite         "float.h" HAVE_DECL__FINITE)

if ((MSVC AND NOT (MSVC_VERSION LESS 1800)) OR MINGW OR CYGWIN OR UNIX)
    check_symbol_exists(INFINITY    "math.h" HAVE_DECL_INFINITY)
    check_symbol_exists(isinf       "math.h" HAVE_DECL_ISINF)
    check_symbol_exists(isnan       "math.h" HAVE_DECL_ISNAN)
    check_symbol_exists(nan         "math.h" HAVE_DECL_NAN)
endif()

check_symbol_exists(_doprnt         "stdio.h" HAVE_DOPRNT)
if (UNIX OR MINGW OR CYGWIN)
    check_symbol_exists(snprintf    "stdio.h" HAVE_SNPRINTF)
endif()
check_symbol_exists(vasprintf       "stdio.h" HAVE_VASPRINTF)
check_symbol_exists(vsnprintf       "stdio.h" HAVE_VSNPRINTF)
check_symbol_exists(vprintf         "stdio.h" HAVE_VPRINTF)

if (HAVE_FCNTL_H)
    check_symbol_exists(open        "fcntl.h" HAVE_OPEN)
endif()
if (HAVE_STDLIB_H)
    check_symbol_exists(realloc     "stdlib.h" HAVE_REALLOC)
endif()
if (HAVE_LOCALE_H)
    check_symbol_exists(setlocale   "locale.h" HAVE_SETLOCALE)
    check_symbol_exists(uselocale   "locale.h" HAVE_USELOCALE)
endif()
if (HAVE_STRINGS_H)
    check_symbol_exists(strcasecmp  "strings.h" HAVE_STRCASECMP)
    check_symbol_exists(strncasecmp "strings.h" HAVE_STRNCASECMP)
endif()
if (HAVE_STRING_H)
    check_symbol_exists(strdup      "string.h" HAVE_STRDUP)
    check_symbol_exists(strerror    "string.h" HAVE_STRERROR)
endif()
if (HAVE_SYSLOG_H)
    check_symbol_exists(vsyslog     "syslog.h" HAVE_VSYSLOG)
endif()
if (HAVE_SYS_RESOURCE_H)
    check_symbol_exists(getrusage   "sys/resource.h" HAVE_GETRUSAGE)
endif()

check_symbol_exists(strtoll     "stdlib.h" HAVE_STRTOLL)
check_symbol_exists(strtoull    "stdlib.h" HAVE_STRTOULL)

set(json_c_strtoll "strtoll")
if (NOT HAVE_STRTOLL)
# Use _strtoi64 if strtoll is not available.
check_symbol_exists(_strtoi64 "stdlib.h" __have_strtoi64)
if (__have_strtoi64)
    #set(HAVE_STRTOLL 1)
    set(json_c_strtoll "_strtoi64")
endif()
endif()

set(json_c_strtoull "strtoull")
if (NOT HAVE_STRTOULL)
# Use _strtoui64 if strtoull is not available.
check_symbol_exists(_strtoui64 "stdlib.h" __have_strtoui64)
if (__have_strtoui64)
    #set(HAVE_STRTOULL 1)
    set(json_c_strtoull "_strtoui64")
endif()
endif()


check_type_size(int                 SIZEOF_INT)
check_type_size(int64_t             SIZEOF_INT64_T)
check_type_size(long                SIZEOF_LONG)
check_type_size("long long"         SIZEOF_LONG_LONG)
check_type_size("size_t"            SIZEOF_SIZE_T)
if (MSVC)
list(APPEND CMAKE_EXTRA_INCLUDE_FILES BaseTsd.h)
check_type_size("SSIZE_T"           SIZEOF_SSIZE_T)
else()
check_type_size("ssize_t"           SIZEOF_SSIZE_T)
endif()

check_c_source_compiles(
"
extern void json_object_get();
__asm__(\".section .gnu.json_object_get\\n\\t.ascii \\\"Please link against libjson-c instead of libjson\\\"\\n\\t.text\");
int main(int c, char *v) { return 0;}
"
HAS_GNU_WARNING_LONG)

check_c_source_compiles(
  "int main() { int i, x = 0; i = __sync_add_and_fetch(&x,1); return x; }"
  HAVE_ATOMIC_BUILTINS)

if (NOT DISABLE_THREAD_LOCAL_STORAGE)
  check_c_source_compiles(
    "__thread int x = 0; int main() { return 0; }"
    HAVE___THREAD)

  if (HAVE___THREAD)
      set(SPEC___THREAD __thread)
  elseif (MSVC)
      set(SPEC___THREAD __declspec(thread))
  endif()
endif()

# Hardware random number is not available on Windows? Says, config.h.win32. Best to preserve compatibility.
if (WIN32)
    set(ENABLE_RDRAND 0)
endif()

# Once we've done basic symbol/header searches let's add them in.
configure_file(${PROJECT_SOURCE_DIR}/cmake/config.h.in        ${PROJECT_BINARY_DIR}/config.h)
message(STATUS "Wrote ${PROJECT_BINARY_DIR}/config.h")
configure_file(${PROJECT_SOURCE_DIR}/cmake/json_config.h.in   ${PROJECT_BINARY_DIR}/json_config.h)
message(STATUS "Wrote ${PROJECT_BINARY_DIR}/json_config.h")

if ("${CMAKE_C_COMPILER_ID}" STREQUAL "MSVC")
    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /DEBUG")
    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /wd4100")
    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /wd4996")
    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /wd4244")
    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /wd4706")
    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /wd4702")
    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /wd4127")
    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} /wd4701")
endif()

if (NOT ("${CMAKE_C_COMPILER_ID}" STREQUAL "MSVC"))
	check_c_source_compiles(
	"
	/* uClibc toolchains without threading barf when _REENTRANT is defined */
	#define _REENTRANT 1
	#include <sys/types.h>
	int main (void)
	{
	  return 0;
	}
	"
	REENTRANT_WORKS
	)
	if (REENTRANT_WORKS)
		add_compile_options("-D_REENTRANT")
	endif()

	# OSX Mach-O doesn't support linking with '-Bsymbolic-functions'.
	# Others may not support it, too.
	list(APPEND CMAKE_REQUIRED_LIBRARIES "-Wl,-Bsymbolic-functions")
	check_c_source_compiles(
	"
	int main (void)
	{
	  return 0;
	}
	"
	BSYMBOLIC_WORKS
	)
	list(REMOVE_ITEM CMAKE_REQUIRED_LIBRARIES "-Wl,-Bsymbolic-functions")
	if (DISABLE_BSYMBOLIC STREQUAL "OFF" AND BSYMBOLIC_WORKS)
		set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-Bsymbolic-functions")
		# XXX need cmake>=3.13 for this:
		#add_link_options("-Wl,-Bsymbolic-functions")
	endif()

	file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/check-version-script.sym" "TEST { global: *; };")
	list(APPEND CMAKE_REQUIRED_LIBRARIES "-Wl,--version-script,${CMAKE_CURRENT_BINARY_DIR}/check-version-script.sym")
	check_c_source_compiles(
	"
	int main (void)
	{
	  return 0;
	}
	"
	VERSION_SCRIPT_WORKS
	)
	list(REMOVE_ITEM CMAKE_REQUIRED_LIBRARIES "-Wl,--version-script,${CMAKE_CURRENT_BINARY_DIR}/check-version-script.sym")
	if (VERSION_SCRIPT_WORKS)
		set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--version-script,${CMAKE_CURRENT_SOURCE_DIR}/json-c.sym")
	endif()
endif()

set(JSON_C_PUBLIC_HEADERS
    # Note: config.h is _not_ included here
    ${PROJECT_BINARY_DIR}/json_config.h

    ${PROJECT_SOURCE_DIR}/json.h
    ${PROJECT_SOURCE_DIR}/arraylist.h
    ${PROJECT_SOURCE_DIR}/debug.h
    ${PROJECT_SOURCE_DIR}/json_c_version.h
    ${PROJECT_SOURCE_DIR}/json_inttypes.h
    ${PROJECT_SOURCE_DIR}/json_object.h
    ${PROJECT_SOURCE_DIR}/json_object_iterator.h
    ${PROJECT_SOURCE_DIR}/json_pointer.h
    ${PROJECT_SOURCE_DIR}/json_tokener.h
    ${PROJECT_SOURCE_DIR}/json_types.h
    ${PROJECT_SOURCE_DIR}/json_util.h
    ${PROJECT_SOURCE_DIR}/json_visit.h
    ${PROJECT_SOURCE_DIR}/linkhash.h
    ${PROJECT_SOURCE_DIR}/printbuf.h
)

set(JSON_C_HEADERS
    ${JSON_C_PUBLIC_HEADERS}
    ${PROJECT_SOURCE_DIR}/json_object_private.h
    ${PROJECT_SOURCE_DIR}/random_seed.h
    ${PROJECT_SOURCE_DIR}/strerror_override.h
    ${PROJECT_SOURCE_DIR}/strerror_override_private.h
    ${PROJECT_SOURCE_DIR}/math_compat.h
    ${PROJECT_SOURCE_DIR}/snprintf_compat.h
    ${PROJECT_SOURCE_DIR}/strdup_compat.h
    ${PROJECT_SOURCE_DIR}/vasprintf_compat.h
)

set(JSON_C_SOURCES
    ${PROJECT_SOURCE_DIR}/arraylist.c
    ${PROJECT_SOURCE_DIR}/debug.c
    ${PROJECT_SOURCE_DIR}/json_c_version.c
    ${PROJECT_SOURCE_DIR}/json_object.c
    ${PROJECT_SOURCE_DIR}/json_object_iterator.c
    ${PROJECT_SOURCE_DIR}/json_pointer.c
    ${PROJECT_SOURCE_DIR}/json_tokener.c
    ${PROJECT_SOURCE_DIR}/json_util.c
    ${PROJECT_SOURCE_DIR}/json_visit.c
    ${PROJECT_SOURCE_DIR}/linkhash.c
    ${PROJECT_SOURCE_DIR}/printbuf.c
    ${PROJECT_SOURCE_DIR}/random_seed.c
    ${PROJECT_SOURCE_DIR}/strerror_override.c
)

include_directories(${PROJECT_SOURCE_DIR})
include_directories(${PROJECT_BINARY_DIR})

set(LIB_NAME ${PROJECT_NAME})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${JSON_C_SOURCES} ${JSON_C_HEADERS})
    if(MSVC)
        set_target_properties(${LIB_NAME} PROPERTIES IMPORT_SUFFIX "_i.lib")
    endif()

    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${VERSION}
        SOVERSION ${JSON_C_MAJOR_VERSION}
        DEFINE_SYMBOL JSONC_DLL_EXPORTS)
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${JSON_C_SOURCES} ${JSON_C_HEADERS})
    set_target_properties(${LIB_NAME} PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION "${FRAMEWORK_VERSION}"
        VERSION ${VERSION}
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
        MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
        MACOSX_FRAMEWORK_IDENTIFIER org.jsonc.jsonc
        XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
        PUBLIC_HEADER "${JSON_C_PUBLIC_HEADERS}")
else()
    add_definitions(-DJSONC_STATIC)
    add_library(${LIB_NAME} STATIC ${JSON_C_SOURCES} ${JSON_C_HEADERS})
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
    install(FILES ${JSON_C_PUBLIC_HEADERS} DESTINATION ${INSTALL_INC_DIR} COMPONENT headers)
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
                 COMMAND ${name})
    endmacro()

    add_jsonc_test(test1)
    add_jsonc_test(test2)
    add_jsonc_test(test4)
    add_jsonc_test(testReplaceExisting)
    add_jsonc_test(test_cast)
    add_jsonc_test(test_null)
    add_jsonc_test(test_locale)
    add_jsonc_test(test_charcase)
    add_jsonc_test(test_compare)
    add_jsonc_test(test_float)
    add_jsonc_test(test_int_add)
    add_jsonc_test(test_set_value)
    # add_jsonc_test(test_util_file)
    add_jsonc_test(test_printbuf)
    add_jsonc_test(test_set_serializer)
    add_jsonc_test(test_parse_int64)
    add_jsonc_test(test_parse)
    add_jsonc_test(test_visit)
    add_jsonc_test(test_double_serializer)
    add_jsonc_test(test_object_iterator)
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
