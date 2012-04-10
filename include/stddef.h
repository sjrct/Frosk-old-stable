//
// stddef.h
//
// written by sjrct
//

#ifndef _STDDEF_H_
#define _STDDEF_H_

// for a 32-bit system
typedef long size_t;
typedef void* ptrdiff_t;

#ifndef NULL
	#define NULL	((void*)0)
#endif

// this might throw warnings
#define offsetof(st, m) ((size_t) &(((st*)0)->m))

#endif
