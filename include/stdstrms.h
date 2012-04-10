//
// stdstrms.h
//
// written by sjrct
//

#ifndef _STDSTRMS_H_
#define _STDSTRMS_H_

#include <fdrv.h>

#define STREAM_STDOUT   0
#define STREAM_STDIN    1
#define STREAM_STDERR   2

#ifndef EOI
  #define EOI -1
#endif

#define stream_push_last(S,C)   __drvcall2(DRV_STD_STREAMS,1,S,C)
#define stream_pop_first(S)     __drvcall1(DRV_STD_STREAMS,2,S)
#define stream_get_length(S)    __drvcall1(DRV_STD_STREAMS,3,S)
#define stream_set_flush(S,f)   __drvcall2(DRV_STD_STREAMS,4,S,F)

#endif
