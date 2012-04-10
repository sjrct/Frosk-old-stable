//
// fs.c
//
// written by sjrct
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fs.h"
#include "error.h"

static long long find_free_blocks(int c)
{
	static long long used_blocks = 1;
	long long r = used_blocks;
	used_blocks += c;
	return r;
}

static fs_tbl_dir * new_ftd()
{
	int i;
	fs_tbl_dir * n;

	n = malloc(sizeof(fs_tbl_dir));
	n->next = NULL;
	n->used = 0;
	n->lba = find_free_blocks(2);
	
	for (i = 0; i < 255; i++)
		n->nodes[i].u.normal.flags = 0;
	
	return n;
}

static int find_free_nodes(file_system * fs, int c, fs_tbl_dir ** out)
{
	int i, j;

	*out = fs->first;
	while ( (*out)->next != NULL && (*out)->used + c > 255) {
		*out = (*out)->next;
	}
	
	if ((*out)->used + c > 255) {
		(*out)->next = new_ftd();
	}
	
	i = (*out)->used;
	(*out)->used += c;
	
	for (j = i; j < (*out)->used; j++)
		(*out)->nodes[j].type = STRING_EXT;
	
	return i;
}

static f300_ptr calc_f300_ptr(file_system * fs, fs_tbl_dir * tbl, int i)
{
	f300_ptr p;
	fs_tbl_dir * c = fs->first;
	
	if (i > 255) ierror(BAD_I_IN_PTR_CALC, &i);
	
	p = 0;
	while (c != tbl) {
		if (c->next == NULL) ierror(BAD_TBL_IN_PTR_CALC, tbl);
		c = c->next;
		p++;
	}
	
	p = ((p << 8) | (i & 255)) + 1;
	return p;
}

void create_fs(file_system * fs)
{
	fs->pre_branch = 0;
	fs->root_branch = 0;
	
	fs->first = new_ftd();
	fs->first->used = 1;
}

static int count_blocks(char * fn)
{
	int bc;
	FILE * f = fopen(fn, "r");
	
	if (f == NULL) {
		warning(FILE_NOT_FOUND, fn);
		return 0;
	}
	
	fseek(f, 0, SEEK_END);
	bc = ftell(f);
	bc = bc % BLOCK_SIZE == 0 ? bc / BLOCK_SIZE : bc / BLOCK_SIZE + 1;
	
	fclose(f);
	
	return bc;
}

static f300_ptr add_fs_node_helper(file_system * fs, parse_struct * ps, f300_ptr next)
{
	int l, lu, ndi, nsi, bsi, i;
	fs_tbl_dir *ndtbl, *nstbl, *bstbl;
	f300_ptr nptr;
	
	ndi = find_free_nodes(fs, 1, &ndtbl);
	ndtbl->nodes[ndi].type = NORMAL;
	ndtbl->nodes[ndi].u.normal.flags = ps->flags | FL_USED;
	ndtbl->nodes[ndi].u.normal.owner = ps->owner;
	ndtbl->nodes[ndi].u.normal.next = next;
	
	l = strlen(ps->name);
	lu = l / 16;
	if (l % 16 != 0) lu++;
	if (lu > 255) error(MAX_STR_SIZE_EXCEEDED, ps->name);
	
	nsi = find_free_nodes(fs, lu, &nstbl);
	nstbl->nodes[nsi].type = STRING;
	nstbl->nodes[nsi].u.str.flags = FL_USED | FL_STRING;
	nstbl->nodes[nsi].u.str.usize = lu;
	nstbl->nodes[nsi].u.str.str = ps->name;
	
	ndtbl->nodes[ndi].u.normal.name = calc_f300_ptr(fs, nstbl, nsi);
	
	if (ps->flags & FL_BRANCH) {
		nptr = 0;
		for (i = ps->u.dir.size - 1; i >= 0; i--) {
			nptr = add_fs_node_helper(fs, ps->u.dir.contents + i, nptr);
		}
		ndtbl->nodes[ndi].u.normal.first = nptr;
	}
	else if (ps->flags & FL_INDIRECT) {
		// TODO
	}
	else {
		// TODO check block count, to see if it exceeds 2^24
		
		bsi = find_free_nodes(fs, 1, &bstbl);
		bstbl->nodes[bsi].type = BLOCK_STRUCT;
		bstbl->nodes[bsi].u.block_struct.flags = FL_USED;
		l = count_blocks(ps->u.actual_file);
		bstbl->nodes[bsi].u.block_struct.blocks = l;
		bstbl->nodes[bsi].u.block_struct.lba = find_free_blocks(l);
		bstbl->nodes[bsi].u.block_struct.next = 0;

		ndtbl->nodes[ndi].u.normal.actual = ps->u.actual_file;		
		ndtbl->nodes[ndi].u.normal.first = calc_f300_ptr(fs, bstbl, bsi);
	}
	
	return calc_f300_ptr(fs, ndtbl, ndi);
}

void add_fs_node(file_system * fs, parse_struct * ps)
{
	f300_ptr ptr;
	
	if (!(ps->flags & FL_BRANCH)) error(STRAY_NODE, ps->name);

	ptr = add_fs_node_helper(fs, ps, 0);	

	if (strcmp(ps->name, "!") == 0) {
		fs->root_branch = ptr;
	}
	else if (strcmp(ps->name, "$") == 0)  {
		fs->pre_branch = ptr;
	}
	else error(STRAY_NODE, ps->name);
}

static void write_fs_node(fs_node * node)
{
	unsigned i;
	
	if (node->type == STRING_EXT) return;
	

	if (!(node->u.normal.flags & FL_USED) && node->type != HEADER) {
		for (i = 0; i < 16; i++) fputc('\0', stdout);
	} else {
		if (node->type == NORMAL) {
			fwrite((char*)(&node->u.normal.flags), sizeof(short), 1, stdout);
			fwrite((char*)(&node->u.normal.owner), sizeof(short), 1, stdout);
			fwrite((char*)(&node->u.normal.name), sizeof(f300_ptr), 1, stdout);
			fwrite((char*)(&node->u.normal.first), sizeof(f300_ptr), 1, stdout);
			fwrite((char*)(&node->u.normal.next), sizeof(f300_ptr), 1, stdout);
		}
		else if (node->type == BLOCK_STRUCT) {
			i = node->u.block_struct.blocks << 8;
			i |= (unsigned)node->u.block_struct.flags;
			fwrite((char*)(&i), sizeof(unsigned), 1, stdout);
			fwrite((char*)(&node->u.block_struct.next), sizeof(f300_ptr), 1, stdout);
			fwrite((char*)(&node->u.block_struct.lba), sizeof(long long), 1, stdout);
		}
		else if (node->type == STRING) {
			fputc(node->u.str.flags, stdout);
			fputc(node->u.str.usize, stdout);
		
			i = 0;
			do {
				fputc(node->u.str.str[i], stdout);
				i++;
			}
			while (node->u.str.str[i - 1] != 0);
		
			i += 2;
			while (i % 16 != 0) {
				fputc('\0', stdout);
				i++;
			}
		}
		else if (node->type == HEADER) {
			fwrite((char*)(&node->u.header.pre), sizeof(f300_ptr), 1, stdout);			
			fwrite((char*)(&node->u.header.root), sizeof(f300_ptr), 1, stdout);			
			fwrite((char*)(&node->u.header.first_free), sizeof(f300_ptr), 1, stdout);			
			fwrite((char*)(&node->u.header.idk), sizeof(f300_ptr), 1, stdout);			
		}
	}
}

static void write_fs_tbl_dir(fs_tbl_dir * tbl, long long blba)
{
	int i;

	fputc(0x00, stdout);
	fputc(0xf3, stdout);

	for (i = 0; i < 6; i++)
		fputc(0x00, stdout);
	
	fwrite((char*)(&blba), sizeof(long long), 1, stdout);

	for (i = 0; i < 255; i++) {
		write_fs_node(tbl->nodes + i);
	}
}

static void write_file(const char * fn)
{
	FILE * f = fopen(fn, "r");
	int c, i = 0;
	
	if (f == NULL) return;
	
	while (1) {
		c = fgetc(f);
		if (c == EOF) break;
		fputc(c, stdout);
		i++;
	}
	
	while (i % BLOCK_SIZE != 0) {
		fputc('\0', stdout);
		i++;
	}
	
	fclose(f);
}

void write_fs(file_system * fs)
{
	int i, ffi;
	f300_ptr ffptr;
	fs_tbl_dir *fftbl, *cur = fs->first;
		
	ffi = find_free_nodes(fs, 1, &fftbl);
	ffptr = calc_f300_ptr(fs, fftbl, ffi);
	
	fftbl->nodes[ffi].type = BLOCK_STRUCT;
	fftbl->nodes[ffi].u.block_struct.flags = FL_USED;
	fftbl->nodes[ffi].u.block_struct.next = ffptr;
	fftbl->nodes[ffi].u.block_struct.blocks = 0;
	fftbl->nodes[ffi].u.block_struct.lba = find_free_blocks(0);
	
	cur->nodes[0].type = HEADER;
	cur->nodes[0].u.header.root = fs->root_branch;
	cur->nodes[0].u.header.pre = fs->pre_branch;
	cur->nodes[0].u.header.first_free = ffptr;
		
	while (cur != NULL) {
		write_fs_tbl_dir(cur, cur->lba + 1);
		write_fs_tbl_dir(cur, cur->lba);

		for (i = 0; i < cur->used; i++)
			if (cur->nodes[i].type == NORMAL && !(cur->nodes[i].u.normal.flags & FL_BRANCH))
				write_file(cur->nodes[i].u.normal.actual);

		cur = cur->next;
	}
}
