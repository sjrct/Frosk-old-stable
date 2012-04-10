//
// time.c
//
// written by sjrct
//

#include <time.h>

// unlike the standard, gets clocks elapsed since startup and not since the
//   begining of the program's execution
clock_t clock()
{
	unsigned ax, dx;
	clock_t r;

	asm("rdtsc" : "=a" (ax), "=d" (dx));

	r = ((clock_t)dx) << 32;
	r |= ax;
	
	return r;
}

time_t mktime(struct tm * tm2)
{
	int i;
	struct tm_ * tm = (struct tm_*)tm2;
	time_t t = 0;
	
	for (i = 1970; i < tm->year; i++) {
		t += 365 * 24 * 60 * 60;
		if (isleapyear(i)) t += 24 * 60 * 60;
	}
	
	t += tm->yday * 24 * 60 * 60;
	t += tm->hour * 60 * 60;
	t += tm->min * 60;
	t += tm->sec;
	
	return t;
}

char * asctime(const struct tm * tm2)
{
	struct tm_ * tm = (struct tm_*)tm2;
	static char timestr[] = "Www Mmm dd hh:mm:ss yyyy\n";
	
	// TODO
	
	return timestr;
}
