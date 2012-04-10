//
// stdarg.h
//
// written by sjrct
//

#ifndef _STDARG_H_
#define _STDARG_H_

#define va_list       __builtin_va_list

#define va_start(v,c) __builtin_va_start(v,c)
#define va_end(v)     __builtin_va_end(v)
#define va_arg(v,t)   __builtin_va_arg(v,t)

#endif
