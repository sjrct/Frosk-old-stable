//
// showcolors.c
//
// written by sjrct
//

#include <fapi.h>

int main()
{
	int i, old;
	
	old = getink();
		
	for (i = 0; i <= 0x7; i++) {
		puth(i);
		puts(" = ");
		setink(i);
		putc(0xdb);	// 0xdb should be like a reverse space
		setink(old);

		puth(i | 8);
		puts(" = ");
		setink(i | 8);
		putc(0xdb);
		setink(old);
		
		putc('\n');
	}

	return 0;
}
