//
// frusr.h
//
// written by sjrct
//

#ifndef _FRUSR_H_
#define _FRUSR_H_

#define _CD_LOCATION 0x8

int chg_cd(const char * dir);
inline int get_cd();
int get_hn_str(int handle, char * buffer, int bsize);

#endif
