//
// string.h
//
// Written by naitsirhc
// modified by sjrct
//


#ifndef _STRING_H_
#define _STRING_H_

#include <stddef.h>

size_t strlen(const char *);
char* strcpy(char *, const  char *);
char* strcat(char *, const char *);
int strcmp(const char *, const char *);
int strncmp(const char *, const  char *, size_t);

void* memmove(void *, const void *, size_t);
void* memcpy(void *, const void *, size_t);

#endif
