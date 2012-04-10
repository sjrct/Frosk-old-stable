//
// parser.c
//
// written by sjrct
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "parser.h"
#include "error.h"

static void ignore_whitespace()
{
	int c;
	while (isspace(c = getc(stdin)) && c != EOF);
	ungetc(c, stdin);
}

static char next_token(char ** ret)
{
	int i = -1, c;
	*ret = NULL;
	
	ignore_whitespace();

	do {
		i++;
		c = getc(stdin);

		if (i % 128 == 0)
			*ret = realloc(*ret, i + 128);

		(*ret)[i] = c;
	}
	while (c != ']' && c != ',' && c != '=' && c != EOF);

	(*ret)[i] = '\0';
	
	while ( i > 0 && isspace( (*ret)[i - 1] )) {
		(*ret)[--i] = '\0';
	}

	return c;
}

void parse_next(parse_struct * ps)
{
	int type, c, p, d;
	char * tok1 = NULL;
	char * tok2 = NULL;
	parse_struct sub;
	
	ps->owner = 0;
	ps->name = NULL;

	ignore_whitespace();
	p = type = getc(stdin);
	if (type == EOF) {
		ps->valid = 0;
		return;
	}

	ignore_whitespace();
	c = getc(stdin);
	if (c != ':') error(EXPECTED_COLON, &p);
	p = c;

	ignore_whitespace();
	c = getc(stdin);
	if (c != '[') error(EXPECTED_LBRACKET, &p);

	switch (type)
	{
	////////// Parse Branches \\\\\\\\\\/
	case 'b':
		ps->flags = FL_BRANCH;
		ps->u.dir.size = 0;
	
		do {
			if (tok1 != NULL) free(tok1);
			p = d = next_token(&tok1);

			if (tok1[0] == '#') {
				if (strcmp(tok1, "#protected") == 0) ps->flags |= FL_PROTECTED;
				else error(BAD_BRANCH_FLAG, tok1);
			} else {
				if (d != '=') error(EXPECTED_EQUALS, tok1);
				
				ignore_whitespace();

				if (strcmp(tok1, "contents") == 0) {
					c = getc(stdin);
					if (c != '{') error(EXPECTED_LBRACE, NULL);
					
					ps->u.dir.contents = NULL;
					
					while (1) {
						ignore_whitespace();

						c = getc(stdin);
						if (c == EOF) error(UNEXPECTED_EOF, NULL);
						if (c == '}') break;
						ungetc(c, stdin);
						
						parse_next(&sub);
						if (!sub.valid) error(UNEXPECTED_EOF, NULL);
						
						if (ps->u.dir.size % (0x20 * sizeof(parse_struct)) == 0) {
							ps->u.dir.contents = realloc(ps->u.dir.contents,
								ps->u.dir.size + (0x20 * sizeof(parse_struct)));
						}
						
						ps->u.dir.contents[ps->u.dir.size++] = sub;
					}
					
					ignore_whitespace();
					d = getc(stdin);
				} else {
					if (tok2 != NULL) free(tok2);
					d = next_token(&tok2);
					
					if (strcmp(tok1, "name") == 0) {
						ps->name = tok2;
						tok2 = NULL;
					}
					else if (strcmp(tok1, "owner") == 0) {
						ps->owner = atoi(tok2);
					}
					else error(BAD_BRANCH_FIELD, tok1);
				}
			}
		}
		while (p != ']' && d != ']');

		break;

	////////// Parse Files \\\\\\\\\\/
	case 'f':
		ps->flags = 0;

		do {
			if (tok1 != NULL) free(tok1);
			d = next_token(&tok1);

			if (tok1[0] == '#') {
				if (strcmp(tok1, "#protected") == 0) ps->flags |= FL_PROTECTED;
				else if (strcmp(tok1, "#executable") == 0) ps->flags |= FL_EXECUTABLE;
				else error(BAD_FILE_FLAG, tok1);
			} else {
				if (d != '=') error(EXPECTED_EQUALS, tok1);

				if (tok2 != NULL) free(tok2);
				d = next_token(&tok2);
				
				if (strcmp(tok1, "name") == 0) {
					ps->name = tok2;
					tok2 = NULL;
				}
				else if (strcmp(tok1, "owner") == 0) {
					ps->owner = atoi(tok2);
				}
				else if (strcmp(tok1, "actual") == 0) {
					ps->u.actual_file = tok2;
					tok2 = NULL;
				}
				else error(BAD_FILE_FIELD, tok1);
			}
		}
		while (p != ']' && d != ']');
		
		break;

	////////// Parse Indirects \\\\\\\\\\/
	case 'i':
		ps->flags = FL_INDIRECT;

		break;
	
	default:
		error(UNRECOGNIZED_TYPE, &type);
	}
	
	if (tok1 == NULL) free(tok1);
	if (tok2 == NULL) free(tok2);
	
	ps->valid = 1;
}
