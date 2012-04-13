//
// scdisp.c
//
// written by sjrct
//

#include <fapi.h>
#include <scancodes.h>

int main()
{
	int sc;

	puts("Press escape to exit.\n");
	while (1) {
		sc = getsc();
		if (sc == SC_ESCAPE) break;
		puth(sc);
	}

	return 0;
}
