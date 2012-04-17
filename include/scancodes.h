//
// scancodes.h
//
// written by sjrct
//

#ifndef _SCANCODES_H_
#define _SCANCODES_H_

#define SC_ESCAPE        0x01	
#define SC_NUM_1         0x02
#define SC_NUM_2         0x03
#define SC_NUM_3         0x04
#define SC_NUM_4         0x05
#define SC_NUM_5         0x06
#define SC_NUM_6         0x07
#define SC_NUM_7         0x08
#define SC_NUM_8         0x09
#define SC_NUM_9         0x0A
#define SC_NUM_0         0x0B
#define SC_MINUS         0x0C
#define SC_EQUALS        0x0D
#define SC_BACKSPACE     0x0E
#define SC_TAB           0x0F
#define SC_LET_Q         0x10
#define SC_LET_W         0x11
#define SC_LET_E         0x12
#define SC_LET_R         0x13
#define SC_LET_T         0x14
#define SC_LET_Y         0x15
#define SC_LET_U         0x16
#define SC_LET_I         0x17
#define SC_LET_O         0x18
#define SC_LET_P         0x19
#define SC_LBRACKET      0x1A
#define SC_RBRACKET      0x1B
#define SC_ENTER         0x1C
#define SC_LCTRL         0x1D
#define SC_LET_A         0x1E
#define SC_LET_S         0x1F
#define SC_LET_D         0x20
#define SC_LET_F         0x21
#define SC_LET_G         0x22
#define SC_LET_H         0x23
#define SC_LET_J         0x24
#define SC_LET_K         0x25
#define SC_LET_L         0x26
#define SC_SEMICOLON     0x27
#define SC_APOSTROPHE    0x28
#define SC_TILDE         0x29
#define SC_LSHIFT        0x2A
#define SC_BACKSLASH     0x2B
#define SC_LET_Z         0x2C
#define SC_LET_X         0x2D
#define SC_LET_C         0x2E
#define SC_LET_V         0x2F
#define SC_LET_B         0x30
#define SC_LET_N         0x31
#define SC_LET_M         0x32
#define SC_COMMA         0x33
#define SC_PERIOD        0x34
#define SC_SLASH         0x35
#define SC_RSHIFT        0x36
#define SC_KEYPAD_ASTRSK 0x37
#define SC_LALT          0x38
#define SC_SPACEBAR      0x39
#define SC_CAPS_LOCK     0x3A
#define SC_F1            0x3B
#define SC_F2            0x3C
#define SC_F3            0x3D
#define SC_F4            0x3E
#define SC_F5            0x3F
#define SC_F6            0x40
#define SC_F7            0x41
#define SC_F8            0x42
#define SC_F9            0x43
#define SC_F10           0x44
#define SC_NUM_LOCK      0x45
#define SC_SCROLL_LOCK   0x46
#define SC_KEYPAD_7      0x47
#define SC_HOME          0x47
#define SC_KEYPAD_8      0x48
#define SC_UP_ARROW      0x48
#define SC_KEYPAD_9      0x49
#define SC_PGUP          0x49
#define SC_KEYPAD_MINUS  0x4A
#define SC_KEYPAD_4      0x4B
#define SC_LEFT_ARROW    0x4B
#define SC_KEYPAD_5      0x4C
#define SC_KEYPAD_6      0x4D
#define SC_RIGHT_ARROW   0x4D
#define SC_KEYPAD_PLUS   0x4E
#define SC_KEYPAD_1      0x4F
#define SC_END           0x4F
#define SC_KEYPAD_2      0x50
#define SC_DOWN_ARROW    0x50
#define SC_KEYPAD_3      0x51
#define SC_PGDOWN        0x51
#define SC_KEYPAD_0      0x52
#define SC_INSERT        0x52
#define SC_KEYPAD_PERIOD 0x53
#define SC_DELETE        0x53
#define SC_SUPER         0x56
#define SC_F11           0x57
#define SC_F12           0x58

#define SC_ESCAPED_0     0xE0
#define SC_ESCAPED_1     0xE1

#define SC_BREAK 0x80
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
