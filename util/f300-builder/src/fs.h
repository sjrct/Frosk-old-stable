//
// fs.h
//
// written by sjrct
//

#ifndef _FS_H_
#define _FS_H_

#include "parser.h"

#define BLOCK_SIZE 0x1000

typedef unsigned int f300_ptr;

typedef struct fs_node
{
	enum {
		NORMAL,
		BLOCK_STRUCT,
		STRING,
		STRING_EXT,
		HEADER
	} type;

	union {
		struct {
			unsigned short flags;
			unsigned short owner;
			f300_ptr name; 
			f300_ptr first;
			f300_ptr next;
			char * actual;
		} normal;

		struct {
			unsigned char flags;
			unsigned blocks;
			f300_ptr next;
			long long lba;
		} block_struct;

		struct {
			unsigned char flags;
			unsigned char usize;
			char * str;
		} str;
		
		struct {
			f300_ptr pre;
			f300_ptr root;
			f300_ptr first_free;
			f300_ptr idk;
		} header;
	} u;
} fs_node;

typedef struct fs_tbl_dir
{
	long long lba;
	int used;
	fs_node nodes[255];
	struct fs_tbl_dir * next;
} fs_tbl_dir;

typedef struct
{
	f300_ptr pre_branch;
	f300_ptr root_branch;
	fs_tbl_dir * first;
} file_system;

void create_fs(file_system *);
void add_fs_node(file_system *, parse_struct *);
void write_fs(file_system *); 

#endif
