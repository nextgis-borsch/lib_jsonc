#ifndef __math_compat_h
#define __math_compat_h

/* Define isnan, isinf, infinity and nan on Windows/MSVC */

#ifndef HAVE_DECL_ISNAN
# ifdef HAVE_DECL__ISNAN
#include <float.h>
#define isnan(x) _isnan(x)
# endif
#endif

#ifndef HAVE_DECL_ISINF
# ifdef HAVE_DECL__FINITE
#include <float.h>
#define isinf(x) (!_finite(x))
# endif
#endif

#if !defined HAVE_DECL_INFINITY && !defined INFINITY
#include <float.h>
#define INFINITY (DBL_MAX + DBL_MAX)
#define HAVE_DECL_INFINITY
#endif

#if !defined HAVE_DECL_NAN && !defined NAN
#define NAN (INFINITY - INFINITY)
#define HAVE_DECL_NAN
#endif

#endif
