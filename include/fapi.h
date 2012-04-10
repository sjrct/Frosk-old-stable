//
// fapi.h
//
// written by sjrct
//

#ifndef _FAPI_H_
#define _FAPI_H_

#ifndef NULL
  #define NULL ((void*)0)
#endif

#include <frosk.h>
#include <frusr.h>

#ifndef _DRVR_NO_KEYBOARD
  #include <drvr/keyboard.h>
  #define _DRVR_KEYBOARD
#endif

#ifdef _DRVR_GRAPHICS_COLOR
  #include <drvr/graphics/color.h>
#else
  #ifdef _DRVR_GRAPICS_MONOCHROME
    #include <drvr/graphics/monochrome.h>
  #else
    #include <drvr/graphics/text.h>
    #define _DRVR_GRAPHICS_TEXT
  #endif
#endif

#endif
