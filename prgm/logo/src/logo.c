//
// logo.c
//
// written by sjrct
//

#include <fapi.h>
#include <scancodes.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SCREEN_WIDTH  80
#define SCREEN_HEIGHT 15	//image height

static char * disp;
static char * logo = 
"              _________________                        ___                      "
"             /                /                       /   /                     "
"            /   _____________/                       /   /                      "
"           /   /                                    /   /   .---.               "
"          /   /                                    /   /  .`   .`               "
"         /   /_______                             /   / .`   .`                 "
"        /           /                            /   /.`   .`                   "
"       /   ________/                            /        .`                     "
"      /   /   __ ___                           /       .`                       "
"     /   /   /  `   `,   .---.    .----.      /   /\\   \\                        " 
"    /   /   /   ,--./  .`     ;  /  .--'     /   /  \\   \\                       "
"   /   /   /  ,`      /  ..   /  \\  '-.     /   /    \\   \\                      "
"  /   /   /  /       /  / /  /    `--. \\   /   /      \\   \\                     "
" /   /   /  /       /   ``  /    .---' /  /   /        \\   \\                    "
"/___/   /__/        `.____.'    '.___.'  /___/          \\___\\                   ";

void delay(clock_t clocks);

int main()
{
	unsigned i, len = strlen(logo);
	disp = malloc(len + 1);
	
	for (i = 0; i < len; i++) {
		do disp[i] = rand() % 0x30 + 0x40;
		while (disp[i] == logo[i]);
	}
	disp[len] = '\0';
	
	srand(clock());
	cls();
	puts(disp);
	
	while (strcmp(logo, disp) != 0)
	{
		do {
			i = rand() % len;
		} while (disp[i] == logo[i]);

		disp[i] = logo[i];
		outc(i % 80, i / 80, disp[i]);
		delay(0x20000);
	}
	
	return 0;
}

void delay(clock_t clocks)
{
	clock_t s, c;
	s = clock();
	do c = clock();
	while (c - s < clocks);
}
