//
// f300.h
//
// written by sjrct
//

#ifndef _F300_H_
#define _F300_H_

#define F300_USED       0x01
#define F300_STRING     0x02
#define F300_DIRECTORY  0x04
#define F300_EXECUTABLE 0x08
#define F300_PROTECTED  0x10
#define F300_INDIRECT   0x20

#define F300_BLOCK_SIZE 0x1000

typedef unsigned f300_ptr;
typedef unsigned f300_ures_ptr;
typedef unsigned long long f300_lba;

#pragma pack(push, 1)
typedef struct {
	char flags;

	union {
		struct {
			char flags_ext;
			unsigned short owner;
			f300_ures_ptr name;
			f300_ures_ptr first_blstr;
			f300_ures_ptr next;
		} file;

		struct {
			char flags_ext;
			unsigned short owner;
			f300_ures_ptr name;
			f300_ures_ptr first_file;
			f300_ures_ptr next;
		} dir;
		
		struct {
			// TODO
		} indirect;

		struct {
			unsigned char low_blocks;
			unsigned short high_blocks;
			f300_ures_ptr next;
			unsigned long long lba;
		} blstr;
	
		struct {
			unsigned char size;
		} string;
	} u;
} f300_node;
#pragma pack(pop)

#define f300_get_string(X) ((char*)(&X) + 2)
#define f300_get_blocks(X) (X.u.blstr.low_blocks | (X.u.blstr.high_blocks << 8))

#endif
