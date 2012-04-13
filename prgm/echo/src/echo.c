//
// echo.c
//
// written by sjrct
//

#include <fapi.h>

int main(int argc, char ** argv)
{
	int i;
	
	for (i = 1; i < argc; i++) {
		puts(argv[i]);
		putc(' ');
	}
	
	putc('\n');

	return 0;
}
