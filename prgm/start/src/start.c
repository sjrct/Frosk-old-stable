//
// start.c
//
// written by sjrct
//

#include <fapi.h>
#include <stdlib.h>

void load_drvr(const char * fn);
void exec_prgm(const char * fn);
void operate_file(const char * fn, void (*oper)(const char*));
void foo();

int main()
{
	chg_cd("!");
	operate_file("!sys/start_drvrs", load_drvr);
	operate_file("!sys/start_prgms", exec_prgm);
	return 0;
}

void foo()
{
	while(1);
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

void operate_file(const char * fn, void (*oper)(const char*))
{
	char *buf, *str;

	buf = read_file(fn);
	if (buf == NULL) return;
	str = buf;
	
	while (*buf != '\0') {
		if (*buf == '\n') {
			*buf = '\0';
			oper(str);
			str = buf + 1;
		}
		buf++;
	}
	
	free(buf);
}

void exec_prgm(const char * fn)
{
	char * buf = read_file(fn);
	if (buf == NULL) return;
	create_process(buf, get_cd(), THREAD_PRIORITY_NORM, 0, NULL);
	free(buf);
}

void load_drvr(const char * fn)
{
	char * buf = read_file(fn);
	if (buf == NULL) return;
	create_drvr(buf);
	free(buf);
}
