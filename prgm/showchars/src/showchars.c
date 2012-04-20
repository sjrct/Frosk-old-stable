//
// showchars.c
//
// written by sjrct
//

#include <fapi.h>

int main()
{
	int i, j;
	int ink1, ink2;
	
	ink1 = getink();
	ink2 = ((ink1 << 4) | (ink1 >> 4));
	
	for (i = 0; i < 0x100; i += 0x20) {
		puth(i);
		puts("+ = ");
		
		setink(ink2);
		for (j = 0; j < 0x20; j++) {
			if ((j & 0x7) == 0 && j != 0) {
				setink(ink1);
				puts("  ");
				setink(ink2);
			}
			
			if (i + j == '\n' || i + j == 0x8) putc(' ');
			else putc(i + j);
		}
		setink(ink1);
		
		putc('\n');
	}
	
	return 0;
}
