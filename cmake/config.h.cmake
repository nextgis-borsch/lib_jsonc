/*
 * $Id$
 *
 * Copyright (c) 2004, 2005 Metaparadigm Pte. Ltd.
 * Michael Clark <michael@metaparadigm.com>
 *
 * This library is free software; you can redistribute it and/or modify
 * it under the terms of the MIT license. See COPYING for details.
 *
 */

#define PACKAGE_STRING "JSON C Library 0.2"
#define PACKAGE_BUGREPORT "michael@metaparadigm.com"
#define PACKAGE_NAME "JSON C Library"
#define PACKAGE_TARNAME "json-c"
#define PACKAGE_VERSION "0.2"

#include "symbol_renames.h"

/* config.h.in.  Generated from configure.ac by autoheader.  */

#ifndef __GNUC__
#define __attribute__(x) /* DO NOTHING */
#endif

/* Define to 1 if you have the <fcntl.h> header file. */
#cmakedefine01 HAVE_FCNTL_H

/* Define to 1 if you have the <inttypes.h> header file. */
#cmakedefine01 HAVE_INTTYPES_H

/* Define to 1 if you have the `open' function. */
#cmakedefine01 HAVE_OPEN

/* Define to 1 if your system has a GNU libc compatible `realloc' function,
   and to 0 otherwise. */
#cmakedefine01 HAVE_REALLOC

/* Define to 1 if you have the `snprintf' function. */
#cmakedefine01 HAVE_SNPRINTF

/* Define to 1 if you have the `strdup' function. */
#cmakedefine01 HAVE_STRDUP

/* Define to 1 if you have the <stdarg.h> header file. */
#cmakedefine01 HAVE_STDARG_H

/* Define to 1 if you have the <strings.h> header file. */
#cmakedefine01 HAVE_STRINGS_H

/* Define to 1 if you have the <syslog.h> header file. */
#cmakedefine01 HAVE_SYSLOG_H

/* Define to 1 if you have the <sys/param.h> header file. */
#cmakedefine01 HAVE_SYS_PARAM_H

/* Define to 1 if you have the <sys/stat.h> header file. */
#cmakedefine01 HAVE_SYS_STAT_H

/* Define to 1 if you have the <sys/types.h> header file. */
#cmakedefine01 HAVE_SYS_TYPES_H

/* Define to 1 if you have the <unistd.h> header file. */
#cmakedefine01 HAVE_UNISTD_H

/* Define to 1 if you have the `vsyslog' function. */
#cmakedefine01 HAVE_VSYSLOG

/* Define to 1 if you have the `strncasecmp' function. */
#ifndef HAVE_STRNCASECMP
#cmakedefine01 HAVE_STRNCASECMP
#endif

#if defined(_MSC_VER) && !defined(strncasecmp)
   /* MSC has the version as _strnicmp */
#define strncasecmp _strnicmp
#endif

/* Define to 1 if you have the ANSI C header files. */
#cmakedefine01 STDC_HEADERS
