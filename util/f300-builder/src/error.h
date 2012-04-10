//
// error.h
//
// written by sjrct
//

#ifndef _ERROR_H_
#define _ERROR_H_

typedef enum
{
	UNEXPECTED_EOF,
	EXPECTED_COLON,
	EXPECTED_LBRACKET,
	EXPECTED_LBRACE,
	EXPECTED_EQUALS,
	BAD_BRANCH_FLAG,
	BAD_FILE_FLAG,
	BAD_INDIRECT_FLAG,
	BAD_BRANCH_FIELD,
	BAD_FILE_FIELD,
	BAD_INDIRECT_FIELD,
	STRAY_NODE,
	MAX_STR_SIZE_EXCEEDED,
	UNRECOGNIZED_TYPE
} error_id;

typedef enum
{
	BAD_ERROR,
	BAD_I_IN_PTR_CALC,
	BAD_TBL_IN_PTR_CALC
} ierror_id;

typedef enum
{
	FILE_NOT_FOUND
} warning_id;

void error(error_id, void *);
void ierror(ierror_id, void *);
void warning(warning_id, void *);

#endif
