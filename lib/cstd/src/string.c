//
// string.c
//
// Written by naitsirhc
// modified by sjrct
//
// TODO: test + write remaining functions
//

#include <string.h>
#include <stdlib.h>

size_t strlen(const char * str)
{
	size_t i = 0;
	while(str[i] != '\0')
		i++;
	return i;
}

char* strcpy(char * out, const char * in)
{
	size_t i = 0;
	do {
		out[i] = in[i];
		i++;
	} while(in[i - 1] != '\0');
	return out;
}

char* strncpy(char * out, const char * in, size_t n)
{
	size_t i;
	for (i = 0; i < n && in[i] != '\0'; i++) {
		out[i] = in[i];
	}
	out[i] = '\0';
	return out;
}

char* strcat(char * dest, const char * src)
{
	strcpy(dest + strlen(dest), src);
	return dest;
}

int strcmp(const char * str1, const char * str2)
{
	size_t i = -1;
	do {
		i++;
		if (str1[i] != str2[i])
			return i + 1;
	} while (str1[i] != '\0');
	return 0;
}

int strncmp(const char * str1, const char * str2, size_t len)
{
	size_t i;
	for (i = 0; i < len; i++)
	{
		if(str1[i] != str2[i])
		{
			return 0;
		}
		if (str1[i] == '\0') break;
	}
	return 1;
}

char * strtok(char * str, const char * delims)
{
	size_t i = 0, j;
	int sr, b = 1;
	char * r;
	
	while (str[i] != '\0') {
		sr = 1;
		j = 0;
		while (delims[j] != '\0') {
			if (str[i] == delims[j]) {
				if (b) {
					sr = 0;
					break;
				}
				str[i] = '\0';
				return r;
			}
			j++;
		}
		
		if (sr) {
			b = 0;
			r = str + i;
		}
		i++;
	}
	
	return r;
}

void * memcpy(void * dest, const void * src, size_t num)
{
	size_t i;
	for (i = 0; i < num; i++)
		((char*)dest)[i] = ((char*)src)[i];	
	return dest;
}

void * memmove(void * dest, const void * src, size_t num)
{
	size_t i;
	char *imm = malloc(num);
	
	for (i = 0; i < num; i++)
		imm[i] = ((char*)src)[i];
	for (i = 0; i < num; i++);
		((char*)dest)[i] = imm[i];
	
	free(imm);
	return dest;
}

int memcmp(const void * m1, const void * m2, size_t n)
{
	size_t i;
	for (i = 0; i < n; i++)
		if (((char*)m1)[i] != ((char*)m2)[i]) return 0;
	return 1;
}
