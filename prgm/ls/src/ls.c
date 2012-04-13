//
// ls.c
//
// written by sjrct
//

#include <fapi.h>

int main(int argc, char ** argv)
{
	f300_ptr ptr;
	f300_node node;
	int ink;
	char name[128];
	
	if (argc > 1) {
		ptr = f300_locate_node(argv[1]);
		f300_get_node(&node, ptr);
		
		if (!(node.flags & F300_DIRECTORY)) {
			puts(argv[1]);
			puts(" is not a directory.\n");
			return -1;
		}
	} else {
		ptr = get_cd();
	}
	
	ptr = f300_find_first(ptr);
	ink = getink();
	
	while (ptr != 0) {
		get_hn_str(ptr, name, 128);
		f300_get_node(&node, ptr);

		if (node.flags & F300_DIRECTORY) setink(COL4_LGREEN);
		puts(name);
		putc('\n');
		if (node.flags & F300_DIRECTORY) setink(ink);

		ptr = f300_find_next(ptr);
	}

	return 0;
}
