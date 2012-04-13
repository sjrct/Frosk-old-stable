//
// stdlib.c
//
// written by sjrct
//
// note: does not contain code for every stdlib.h function
//

#include <frosk.h>
#include <stdlib.h>

int abs(int x)
{
	if (x < 0) return -x;
	return x;
}

long labs(long x)
{
	if (x < 0) return -x;
	return x;
}

div_t div(int x, int y)
{
	div_t r;
	r.quot = x / y;
	r.rem = x % y;
	return r;
}

ldiv_t ldiv(long x, long y)
{
	ldiv_t r;
	r.quot = x / y;
	r.rem = x % y;
	return r;
}

void exit(int status)
{
	kill_current();
}
