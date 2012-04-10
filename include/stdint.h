//
// stdint.h
//
// written by sjrct
//
// should work on 32-bit systems and LP64/LLP64 systems, but not ILP64 systems
// this is w/ the exception of (u)intptr_t, which only works on 32-bit systems
//

#ifndef _STDINT_H_
#define _STDINT_H_

#include <limits.h>


// 8-bit integers
typedef signed char   int8_t;
typedef unsigned char uint8_t;

typedef int8_t  int_least8_t;
typedef uint8_t uint_least8_t;

typedef int8_t  int_fast8_t;
typedef uint8_t uint_fast8_t;

#define INT8_MIN  SCHAR_MIN
#define INT8_MAX  SCHAR_MAX
#define UINT8_MAX UCHAR_MAX

#define INT_LEAST8_MIN  INT8_MIN
#define INT_LEAST8_MAX  INT8_MAX
#define UINT_LEAST8_MAX UINT8_MAX

#define INT_FAST8_MIN  INT8_MIN
#define INT_FAST8_MAX  INT8_MAX
#define UINT_FAST8_MAX UINT8_MAX


// 16-bit integers
typedef signed short   int16_t;
typedef unsigned short uint16_t;

typedef int16_t  int_least16_t;
typedef uint16_t uint_least16_t;

typedef int16_t  int_fast16_t;
typedef uint16_t uint_fast16_t;

#define INT16_MIN  SHRT_MIN
#define INT16_MAX  SHRT_MAX
#define UINT16_MAX USHRT_MAX

#define INT_LEAST16_MIN  INT16_MIN
#define INT_LEAST16_MAX  INT16_MAX
#define UINT_LEAST16_MAX UINT16_MAX

#define INT_FAST16_MIN  INT16_MIN
#define INT_FAST16_MAX  INT16_MAX
#define UINT_FAST16_MAX UINT16_MAX


// 32-bit integers
typedef signed int         int32_t;
typedef unsigned int       uint32_t;

typedef int32_t  int_least32_t;
typedef uint32_t uint_least32_t;

typedef int32_t  int_fast32_t;
typedef uint32_t uint_fast32_t;

#define INT32_MIN  INT_MIN
#define INT32_MAX  INT_MAX
#define UINT32_MAX UINT_MAX

#define INT_LEAST32_MIN  INT32_MIN
#define INT_LEAST32_MAX  INT32_MAX
#define UINT_LEAST32_MAX UINT32_MAX

#define INT_FAST32_MIN  INT32_MIN
#define INT_FAST32_MAX  INT32_MAX
#define UINT_FAST32_MAX UINT32_MAX


// 64-bit integers
typedef signed long long   int64_t;
typedef unsigned long long int64_t;

typedef int64_t  int_least64_t;
typedef uint64_t uint_least64_t;

typedef int64_t  int_fast64_t;
typedef uint64_t uint_fast64_t;

#define INT64_MIN  0xffffffffffffffff // not defined in limits.h
#define INT64_MAX  0x7fffffffffffffff
#define UINT64_MAX 0xffffffffffffffff

#define INT_LEAST64_MIN  INT64_MIN
#define INT_LEAST64_MAX  INT64_MAX
#define UINT_LEAST64_MAX UINT64_MAX

#define INT_FAST64_MIN  INT64_MIN
#define INT_FAST64_MAX  INT64_MAX
#define UINT_FAST64_MAX UINT64_MAX


// largest sized integer
typedef int64_t  intmax_t;
typedef uint64_t uintmax_t;

#define INTMAX_MIN  INT64_MIN
#define INTMAX_MAX  INT64_MAX
#define UINTMAX_MAX UINT64_MAX


// integers for pointers, ONLY for 32-bit systems
typedef int32_t  intptr_t;
typedef uint32_t uintptr_t;

#define INTPTR_MIN  INT32_MIN
#define INTPTR_MAX  INT32_MAX
#define UINTPTR_MAX UINT32_MAX

#endif
