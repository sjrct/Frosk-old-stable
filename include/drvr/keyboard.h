//
// drvr/keyboard.h
//
// written by sjrct
//

#ifndef _DRVR_KEYBOARD_H_
#define _DRVR_KEYBOARD_H_

#include <fapi.h>

#define _DRVR_KB_ID 1

#define kbdrvr_init() __drvrcall0(0,_DRVR_KB_ID)
#define getsc()       __drvrcall0(1,_DRVR_KB_ID)
#define trygetsc()    __drvrcall0(2,_DRVR_KB_ID)
#define getbufsize()  __drvrcall0(3,_DRVR_KB_ID)
#define flushbuf(C)   __drvrcall1(4,_DRVR_KB_ID,C)

#endif
