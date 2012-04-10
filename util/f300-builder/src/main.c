//
// main.c
//
// written by sjrct
//

#include <stdio.h>
#include "fs.h"

int main()
{
	parse_struct ps;
	file_system fs;

	create_fs(&fs);

	while (1) {
		parse_next(&ps);
		if (!ps.valid) break;
		add_fs_node(&fs, &ps);
	}

	write_fs(&fs);

	return 0;
}
