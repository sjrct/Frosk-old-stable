//
// drvr/text.h
//
// written by sjrct
//

#ifndef _DRVR_TEXT_H_
#define _DRVR_TEXT_H_

#include <fapi.h>

#define _DRVR_TEXT_ID 0x10

#define COL4_BLACK   0x0
#define COL4_BLUE    0x1
#define COL4_GREEN   0x2
#define COL4_AQUA    0x3
#define COL4_RED     0x4
#define COL4_PURPLE  0x5
#define COL4_YELLOW  0x6
#define COL4_WHILE   0x7
#define COL4_GREY   0x8
#define COL4_LBLUE   0x9
#define COL4_LGREEN  0xa
#define COL4_LAQUA   0xb
#define COL4_LRED    0xc
#define COL4_LPURPLE 0xd
#define COL4_LYELLOW 0xe
#define COL4_BWHITE  0xf

#define COL4_MAKE(F,B) ((B << 4) | F)

#define textdrvr_init()    __drvrcall0(0,_DRVR_TEXT_ID,X)
#define putc(X)            __drvrcall1(1,_DRVR_TEXT_ID,X)
#define puts(X)            __drvrcall1(2,_DRVR_TEXT_ID,(int)X)
#define puth(X)            __drvrcall1(3,_DRVR_TEXT_ID,X)
#define puti(X)            __drvrcall1(4,_DRVR_TEXT_ID,X)
#define setink(C)          __drvrcall1(5,_DRVR_TEXT_ID,C)
#define getink()           __drvrcall0(6,_DRVR_TEXT_ID)
#define cls()              __drvrcall0(7,_DRVR_TEXT_ID)
#define outc(X,Y,C)        __drvrcall3(8,_DRVR_TEXT_ID,X,Y,C)
#define showcursor()       __drvrcall0(9,_DRVR_TEXT_ID)
#define hidecursor()       __drvrcall0(10,_DRVR_TEXT_ID)
#define setcursor(X,Y)     __drvrcall2(11,_DRVR_TEXT_ID,X,Y)
#define getcursorx()       __drvrcall0(12,_DRVR_TEXT_ID)
#define getcursory()       __drvrcall0(13,_DRVR_TEXT_ID)
#define setcursorsize(T,B) __drvrcall2(14,_DRVR_TEXT_ID,T,B)
#define setblinkrate(X)    __drvrcall1(15,_DRVR_TEXT_ID,X)

#endif
