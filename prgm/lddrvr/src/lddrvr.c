//
// lddrvr.c
//
// written by sjrct
//

#include <fapi.h>
#include <stdlib.h>

void lddrvr(const char *);

int main(int argc, char ** argv)
{
	int i;

	if (argc == 1) {
		// TODO display loaded drivers
		return 0;
	}

	for (i = 1; i < argc; i++) {
		lddrvr(argv[i]);
	}
	
	// TODO sort drivers
	
	return 0;
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

void lddrvr(const char * fn)
{
	char * buf = read_file(fn);
	
	if (buf == NULL) {
		puts("Could read file \'");
		puts(fn);
		puts("\'.\n");
		return;
	}
	
	if (drvr_exists( ((int*)buf)[5] )) {
		puts("Driver with id ");
		puth(((int*)buf)[5]);
		puts(" already exists.\n");
		return;
	}
	
	puts("asf\n");
	while (1) {}
	
	create_drvr(buf);
	free(buf);
}
