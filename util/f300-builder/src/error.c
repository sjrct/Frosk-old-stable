//
// error.c
//
// written by sjrct
//

#include <stdio.h>
#include <stdlib.h>
#include "error.h"

void error(error_id id, void * data)
{
	switch (id)
	{
	case UNEXPECTED_EOF:
		fprintf(stderr, "Error: Unexpected end of file.\n");
		break;
	case EXPECTED_COLON:
		fprintf(stderr, "Error: Expected ':' after '%c'.\n", *((char*)data));
		break;
	case EXPECTED_LBRACKET:
		fprintf(stderr, "Error: Expected '[' after '%c'.\n", *((char*)data));
		break;
	case EXPECTED_EQUALS:
		fprintf(stderr, "Error: Expected '=' after '%s'.\n", (char*)data);
		break;
	case EXPECTED_LBRACE:
		fprintf(stderr, "Error: Expected '{' after 'contents='.\n");
		break;
	case BAD_BRANCH_FLAG:
		fprintf(stderr, "Error: Flag '%s' is invalid for branches.\n", (char*)data);
		break;
	case BAD_FILE_FLAG:
		fprintf(stderr, "Error: Flag '%s' is invalid for files.\n", (char*)data);
		break;
	case BAD_INDIRECT_FLAG:
		fprintf(stderr, "Error: Flag '%s' is invalid for indirects.\n", (char*)data);
		break;
	case BAD_BRANCH_FIELD:
		fprintf(stderr, "Error: Field '%s' is invalid for branches.\n", (char*)data);
		break;
	case BAD_FILE_FIELD:
		fprintf(stderr, "Error: Field '%s' is invalid for files.\n", (char*)data);
		break;
	case BAD_INDIRECT_FIELD:
		fprintf(stderr, "Error: Field '%s' is invalid for indirects.\n", (char*)data);
		break;
	case MAX_STR_SIZE_EXCEEDED:
		fprintf(stderr, "Error: String '%s' exceeds maximium string size.\n", (char*)data);
		break;
	case STRAY_NODE:
		fprintf(stderr, "Error: Stray node '%s'.\n", (char*)data);
		break;
	case UNRECOGNIZED_TYPE:
		fprintf(stderr, "Error: Unrecognized type '%c'.\n", *((char*)data));
		break;
	default:
		ierror(BAD_ERROR, "error");
	}
	exit(-1);
}

void ierror(ierror_id id, void * data)
{
	switch (id)
	{
	case BAD_ERROR:
		fprintf(stderr, "Internal Error: Bad %s.\n", (char*)data);
		break;
	case BAD_I_IN_PTR_CALC:
		fprintf(stderr, "Internal Error: The 'i' value '%d' given to 'calc_f300_ptr' is invalid.\n", *((int*)data));
	case BAD_TBL_IN_PTR_CALC:
		fprintf(stderr, "Internal Error: The 'tbl' value '%p' given to 'calc_f300_ptr' is invalid.\n", data);
		break;
	default:
		ierror(BAD_ERROR, "internal error (sup dawg)");
		break;
	}
	exit(-2);
}

void warning(warning_id id, void * data)
{
	switch (id)
	{
	case FILE_NOT_FOUND:
		fprintf(stderr, "Warning: File '%s' not found.\n", (char*)data);
		break;
	default:
		error(BAD_ERROR, "warning");
	}
}
