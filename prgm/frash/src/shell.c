//
// shell.c
//
// written by sjrct
//

#include <fapi.h>
#include <scancodes.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 128

char* getstr();
int gettok(char*, char*);
void change_dir(char * new, char * dest);
int exec_prgm(const char * fn, char * argsu);

int main()
{
	int d, handle, wait;
	char * str;
	char cd[60];
	char tok[MAX_SIZE];
	char copy[MAX_SIZE + 6];

	setink(COL4_GREEN);
	setcursorsize(0xd,0xe);
	cls();
	kbdrvr_init();
	
	puts("frash\n");
	
	change_dir("!", cd);
	
	while (1) {
		puts(cd);
		puts("> ");

		str = getstr();

		wait = 1;
		if (str[0] == '&') {
			wait = 0;
			str++;
		}
				
		d = gettok(str, tok);

		if (strcmp(tok, "cd") == 0 && d == ' ') {
			gettok(str + 3, tok);
			change_dir(tok, cd);			
		}
		else if (strcmp(tok, "exit") == 0) {
			break;
		}
		else {
			handle = exec_prgm(tok, str);
			if (handle == 0) {
				strcpy(copy, "!prgm/");
				strcpy(copy + 6, tok);
				handle = exec_prgm(copy, str);
				
				if (handle == 0) {
					puts("Error: Cannot execute file.\n");
					continue;
				}
			}
			
			if (wait) wait_thread(handle);
		}
	}
	
	return 0;
}

void change_dir(char * new, char * dest)
{
	if (!chg_cd(new)) {
		puts("Error: No such directory.\n");
		return;
	}
	
	if (get_hn_str(get_cd(), dest, 59) == 0) {
		dest[58] = '~';
		dest[59] = '\0';
	}
}

int gettok(char * str, char * dest)
{
	int i = 0, d;
	
	while (i < MAX_SIZE) {
		if (str[i] == '\0' || str[i] == ' ' || str[i] == '\n') {
			d = str[i];
			dest[i] = '\0';
			return d;
		}

		dest[i] = str[i];
		i++;
	}

	str[i - 1] = '\0';
	return '\0';
}

char* getstr()
{
	unsigned sc;
	int i = 0, c = 0, lshift, rshift;
	static char str[MAX_SIZE];
	
	lshift = rshift = 0;
	
	showcursor();
	
	do {
		sc = getsc();
		
		if (sc == SC_LSHIFT) lshift = 1;
		else if (sc == (SC_LSHIFT | SC_BREAK)) lshift = 0;
		else if (sc == SC_RSHIFT) rshift = 1;
		else if (sc == (SC_RSHIFT | SC_BREAK)) rshift = 0;
		
		if (!IS_KEY_BREAK(sc) && sc < ASCII_MAP_SIZE) {
			if (lshift || rshift) c = shift_sc_to_ascii_map[sc];
			else c = sc_to_ascii_map[sc];

			if (c != 0) {
				if (c == 8) {	// backspace
					if (i > 0) {
						putc(c);
						i--;
					}
				}
				else {
					putc(c);
					if (i != MAX_SIZE - 1) str[i++] = c;
				}
			}
		}
	} while (c != '\n');
	
	str[i] = '\0';
	
	hidecursor();
	
	return str;
}

char * read_file(const char * fn)
{
	f300_ptr node_id;
	f300_node node;
	int blocks;
	char * buf;

	node_id = f300_locate_node(fn);
	if (node_id == 0) return NULL;
	
	f300_get_node(&node, node_id);
	f300_get_node(&node, f300_resolve_ptr(node.u.file.first_blstr));

	blocks = f300_get_blocks(node);
	buf = malloc(blocks * F300_BLOCK_SIZE);

	ata_read_pio(buf, 0,
		(unsigned)(node.u.blstr.lba * (F300_BLOCK_SIZE / 512)),
		blocks * (F300_BLOCK_SIZE / 512));
	
	return buf;
}

int exec_prgm(const char * fn, char * argsu)
{
	int h, i, argc;
	char *args[10];
	char *buf;
	
	buf = read_file(fn);
	if (buf == NULL) return 0;

	i = argc = 0;
	if (argsu[0] != '\0') {
		args[0] = argsu;
		while (argsu[i] != '\0') {
			if (argsu[i] == ' ' || argsu[i] == '\n') {
				argsu[i] = '\0';
				if (argc < 10 - 1) {
					args[++argc] = argsu + i + 1;
				}
			}
			i++;
		}
	}

	h = create_process(buf, get_cd(), THREAD_PRIORITY_NORM, argc, args);
	free(buf);
	return h;
}
