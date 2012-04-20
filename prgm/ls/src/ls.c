//
// ls.c
//
// written by sjrct
//

#include <fapi.h>
#include <string.h>

#define SCREEN_WIDTH 80

static int nodeperline = 0;
static int showhidden = 0;

int main(int argc, char ** argv)
{
	f300_ptr ptr;
	f300_node node;
	int ink, i, cc;
	static int first = 1;
	char name[128];
	
	ptr = get_cd();

	for (i = 1; i < argc; i++) {
		if (argv[i][0] == '#') {
			switch (argv[i][1])
			{
			case 'a':
				showhidden = 1;
				break;
			case '1':
				nodeperline = 1;
				break;
			default:
				puts("Flag '#");
				puts(argv[i]);
				puts("'not recognized.\n");
				return -1;
			}
		} else {
			ptr = f300_locate_node(argv[1]);
			f300_get_node(&node, ptr);
		
			if (!(node.flags & F300_DIRECTORY)) {
				puts(argv[1]);
				puts(" is not a directory.\n");
				return -1;
			}
		}
	}
	
	ptr = f300_find_first(ptr);
	ink = getink();
	
	while (ptr != 0) {
		get_hn_str(ptr, name, 128);
		f300_get_node(&node, ptr);

		if (name[0] != '.' || showhidden) {
			if (!first) {
				if (nodeperline) putc('\n');
				else {
					cc += strlen(name) + 1;
					if (cc > SCREEN_WIDTH) {
						putc('\n');
						cc = strlen(name);
					} else putc(' ');
				}
			} else {
				cc += strlen(name);
				first = 0;
			}
			
			if (node.flags & F300_DIRECTORY) setink(COL4_LGREEN);
			puts(name);
			if (node.flags & F300_DIRECTORY) setink(ink);
		}

		ptr = f300_find_next(ptr);
	}
	
	putc('\n');

	return 0;
}
