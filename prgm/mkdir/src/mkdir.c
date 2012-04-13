//
// mkdir.c
//
// written by sjrct
//

#include <fapi.h>

void mkdir(char*);

int main(int argc, char ** argv)
{
	int i;

	for (i = 1; i < argc; i++) {
		mkdir(argv[i]);
	}

	return 0;
}

void mkdir(char * s)
{
	if (f300_locate_node(s) == 0) {
		f300_create_node(get_cd(), F300_DIRECTORY, s);
	} else {
		puts("Error: \'");
		puts(s);
		puts("\' already exists.\n");
	}
}
