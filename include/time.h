//
// time.h
//
// written by sjrct
//

#ifndef _TIME_H_
#define _TIME_H_

typedef unsigned long long clock_t;
typedef unsigned long long time_t;

// the tm & tm_ struct should have their elements in the same order
struct tm
{
	int tm_sec;
	int tm_min;
	int tm_hour;
	int tm_mday;
	int tm_mon;
	int tm_year;
	int tm_wday;
	int tm_yday;
	int tm_isdst;
};

struct tm_
{
	int sec;
	int min;
	int hour;
	int mday;
	int mon;
	int year;
	int wday;
	int yday;
	int isdst;
};

clock_t clock();
time_t time(time_t *);
time_t mktime(struct tm *);
char * asctime(const struct tm *);

#define difftime(X,Y) ((double)(X - Y))
#define isleapyear(X) ((X % 4 == 0) && !(X % 400 == 0))

#define CLOCKS_PER_SEC /*todo*/
#define CLK_TCK CLOCKS_PER_SEC

#endif
