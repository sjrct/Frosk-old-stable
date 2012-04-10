//
// stdio.h
//
// written by sjrct
//

#ifndef _STDIO_H_
#define _STDIO_H_

void fputs(const char* str, FILE* f);
void puts(const char* str);
void fputc(int c, FILE* f);
void fputd(int n, FILE* f);
void fputh(int n, FILE* f);

#define putc(C) fputc(C,stdout)
#define putd(N) fputd(N,stdout)
#define puth(N) fputh(N,stdout)

int fprintf(FILE* file, const char* str,...);
int fscanf(FILE* file, const char* str,...);

#define printf(args...) fprintf(stdout, args)
#define scanf(args...) fscanf(stdin, args)

#endif
