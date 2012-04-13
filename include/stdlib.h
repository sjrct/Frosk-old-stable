//
// stdlib.h
//
// written by sjrct
//

#ifndef _STDLIB_H_
#define _STDLIB_H_

#include <stddef.h>

typedef struct {
	int quot;
	int rem;
} div_t;

typedef struct {
	long quot;
	long rem;
} ldiv_t;

void srand(unsigned int seed);
int rand();

void * malloc(unsigned size);
void free(void * ptr);

int abs(int);
long labs(long);
div_t div(int, int);
ldiv_t ldiv(long, long);

void exit(int status);

#endif
