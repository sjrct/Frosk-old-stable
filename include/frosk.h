//
// frosk.h
//
// written by sjrct
//

#ifndef _FROSK_H_
#define _FROSK_H_

#include <f300.h>

#define THREAD_PRIORITY_IDLE 0
#define THREAD_PRIORITY_LOW  1
#define THREAD_PRIORITY_NORM 2
#define THREAD_PRIORITY_HIGH 3
#define THREAD_PRIORITY_AYP  4

int __syscall0(int f);
int __syscall1(int f, int x);
int __syscall2(int f, int x, int y);
int __syscall3(int f, int x, int y, int z);
int __syscall4(int f, int x, int y, int z, int v);
int __syscall5(int f, int x, int y, int z, int v, int t);

int __drvrcall0(int f, int d);
int __drvrcall1(int f, int d, int x);
int __drvrcall2(int f, int d, int x, int y);
int __drvrcall3(int f, int d, int x, int y, int z);
int __drvrcall4(int f, int d, int x, int y, int z, int v);

#define f300_locate_node(X)       __syscall1(0,(int)X)
#define f300_get_node(X,Y)        __syscall2(1,(int)X,Y)
#define f300_resolve_ptr(X)       __syscall1(2,X)
#define ata_read_pio(X,Y,Z,T)     __syscall4(3,(int)X,Y,Z,T)
#define create_process(X,Y,Z,V,T) __syscall5(4,(int)X,Y,Z,V,(int)T)
#define create_drvr(X)            __syscall1(5,(int)X)
#define drvr_exists(X)            __syscall1(6,X)
#define wait_thread(X)            __syscall1(8,X)
#define f300_find_first(X)        __syscall1(9,X)
#define f300_find_next(X)         __syscall1(10,X)
#define ata_write_pio(X,Y,Z,T)    __syscall4(11,X,Y,Z,T)
#define f300_create_node(X,Y,Z)   __syscall3(12,X,Y,(int)Z)
#define kill_current()            __syscall0(13)
#define _debug_puth(X)            __syscall1(14,X)
#define _debug_puts(X)            __syscall1(15,X)

#endif
