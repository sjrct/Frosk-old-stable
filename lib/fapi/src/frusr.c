//
// frusr.c
//
// written by sjrct
//

#include <fapi.h>

// changes the current directory
// return 0 if fails, 1 otherwise
int chg_cd(const char * dir)
{
	f300_node node;
	f300_ptr nb;
	
	nb = f300_locate_node(dir);
	if (nb == 0) return 0;
	
	f300_get_node(&node, nb);
	if (!(node.flags & F300_DIRECTORY)) return 0;
	
	*((f300_ptr*)_CD_LOCATION) = nb;
	
	return 1;
}


// gets a handle to the current directory
inline int get_cd()
{
	return *((int*)_CD_LOCATION);
}


// fills a buffer with the name of the given node
// returns 1 if the name fits in the buffer, 0 if not, -1 if not valid handle
int get_hn_str(int handle, char * buffer, int bsize)
{
	int size, bi, si, ni;
	char * str;
	f300_ures_ptr ptr;
	f300_node node;
	
	if (bsize <= 0) return 0;

	f300_get_node(&node, handle);
	if (node.flags & F300_STRING) return -1;
	
	ptr = node.u.file.name;
	f300_get_node(&node, f300_resolve_ptr(ptr));
	size = node.u.string.size;
	
	if (size == 0) {
		buffer[0] = '\0';
		return 1;
	}

	bi = 0;
	str = (char*)(&node);
	
	for (si = 2; si < 16; si++) {
		if (bi >= bsize - 1) {
			buffer[bi] = '\0';
			return 0;
		}
		buffer[bi++] = str[si];
	}

	for (ni = 1; ni < size; ni++) {
		ptr += 16;
		f300_get_node(&str, f300_resolve_ptr(ptr));

		for (si = 0; si < 16; si++) {
			if (bi >= bsize - 1) {
				buffer[bi] = '\0';
				return 0;
			}
			buffer[bi++] = str[si];
		}
	}
	
	if (bi == bsize) {
		buffer[bi - 1] == '\0';
		return 0;
	}
	
	buffer[bi] == '\0';
	return 1;
}

