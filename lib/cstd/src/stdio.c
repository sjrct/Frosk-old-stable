//
// stdio.c
//
// written by sjrct
//

#include <stdio.h>
#include <stdarg.h>

//
int fprintf(FILE* file, const char* pat,...)
{
	va_list vl;
	int i, c, r = 0;
	
	for (i = 0, c = 0; pat[i] != '\0'; i++)
		if (pat[i] == '%') {
			if (pat[i + 1] == '%') i++;
			else c++; 
		}
	
	va_start(vl, c);
	i = 0;
	
	while (pat[i] != '\0')
	{
		if (pat[i] == '%')
		{
			switch(pat[i + 1])
			{
			case '%':
				fputc('%', file);
				r--;
				break;
			case 'd':
				fputd(va_arg(vl, int), file);
				break;
			case 'x':
				fputh(va_arg(vl, unsigned), file);
				break;			
			case 'c':
				fputc(va_arg(v1, int), file);
				break;
			case 's':
				fputs(va_arg(v1, char*), file);
				break;
			default:
				r--;
			}
			
			r++;
			i++;
		}
		else fputc(pat[i], file);
		i++;
	}
	
	va_end(vl);
	
	return r;
}

