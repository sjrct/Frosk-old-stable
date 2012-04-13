//
// stack_check.c
//
// written by sjrct
//

#include <fapi.h>
#include <time.h>

void stack_check();

int main()
{
	stack_check();
	return 0;
}

void stack_check()
{
	int x;
	clock_t f, c;
	
	asm("mov %%esp, %0" : "=g" (x));
	puth(x);

	f = clock();
	do {
		c = clock();
	} while (c - f < 0x2000000);

	stack_check();
}
