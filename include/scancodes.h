//
// scancodes.h
//
// written by sjrct
//

#ifndef _SCANCODES_H_
#define _SCANCODES_H_

#define SC_LCTRL  0x1D
#define SC_LSHIFT 0x2A
#define SC_RSHIFT 0x36
#define SC_LALT   0x38
#define SC_RCTRL  0xE01D
#define SC_RALT   0xE038

#define SC_BREAK  0x80

#define IS_KEY_BREAK(X) (X & SC_BREAK)

const char sc_to_ascii_map[] =
{
	0x0, 0x0, '1', '2', '3', // 0-4
	'4', '5', '6', '7', '8',
	'9', '0', '-', '=', 0x8, // 10-14
	'\t','q', 'w', 'e', 'r',
	't', 'y', 'u', 'i', 'o', // 20-24
	'p', '[', ']','\n', 0x0,
	'a', 's', 'd', 'f', 'g', // 30-34
	'h', 'j', 'k', 'l', ';',
	'\'','`', 0x0,'\\', 'z', // 40-44
	'x', 'c', 'v', 'b', 'n',
	'm', ',', '.', '/', 0x0, // 50-54
	0x0, 0x0, ' '
};

const char shift_sc_to_ascii_map[] =
{
	0x0, 0x0, '!', '@', '#', // 0-4
	'$', '%', '^', '&', '*',
	'(', ')', '_', '+', 0x8, // 10-14
	'\t','Q', 'W', 'E', 'R',
	'T', 'Y', 'U', 'I', 'O', // 20-24
	'P', '{', '}','\n', 0x0,
	'A', 'S', 'D', 'F', 'G', // 30-34
	'H', 'J', 'K', 'L', ':',
	'\"','~', 0x0, '|', 'Z', // 40-44
	'X', 'C', 'V', 'B', 'N',
	'M', '<', '>', '?', 0x0, // 50-54
	0x0, 0x0, ' '
};

#define ASCII_MAP_SIZE 58

#endif
