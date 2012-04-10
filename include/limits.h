//
// limits.h
//
// this is for a 32-bit x86 system
//
// written by sjrct
//

#ifndef _LIMITS_H_
#define _LIMITS_H_

// the byte size on the machine
#define CHAR_BIT    8


// char limits
#define SCHAR_MAX   0x7f
#define SCHAR_MIN   0xff
#define UCHAR_MAX   0xff


//
// limits of chars without regard to sign
//
// the macro __CHAR_UNSIGNED__ is a GNU C extension, and is defined when chars
// default to unsigned, not signed.  This should jiggle with most compilers
// seeing that GNU C extensions are quite widely accepted, and that most 
// compilers default to signed characters anyway
//
#ifdef __CHAR_UNSIGNED__
  #define CHAR_MAX  UCHAR_MAX
  #define CHAR_MIN  0
#else
  #define CHAR_MAX  SCHAR_MAX
  #define CHAR_MIN  SCHAR_MIN
#endif


// short limits
#define SHRT_MAX    0x7fff
#define SHRT_MIN    0xffff
#define USHRT_MAX   0xffff


// int limits
#define INT_MAX     0x7fffffff
#define INT_MIN     0xffffffff
#define UINT_MAX    0xffffffff


// long limits, for a 32-bit system or LLP64 systems
#define LONG_MAX    INT_MAX
#define LONG_MIN    INT_MIN
#define ULONG_MAX   UINT_MAX

#endif
