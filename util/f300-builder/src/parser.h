//
// parser.h
//
// written by sjrct
//

#ifndef _PARSER_H_
#define _PARSER_H_

#define FL_USED       0x01
#define FL_STRING     0x02
#define FL_BRANCH     0x04
#define FL_EXECUTABLE 0x08
#define FL_PROTECTED  0x10
#define FL_INDIRECT   0x20

typedef struct parse_struct
{
	int valid;

	int flags;
	char * name;
	int owner;

	union {
		char * actual_file;

		struct {
			int size;
			struct parse_struct * contents;
		} dir;
	} u;
} parse_struct;

void parse_next(parse_struct *);

#endif
