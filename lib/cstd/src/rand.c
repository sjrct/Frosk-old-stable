//
// rand.c
//
// written by sjrct, I just kinda wung it
//

#include <stdlib.h>

static unsigned int seed;
static int rot = 0;

void srand(unsigned int s)
{
	seed = s;
}

// seems to work well with not repeating and not favoriting
// algorithim (compliments to myself) is basically:
//  -Xor by constant, I used one with equal bits off and on
//  -rotate by 1 more (or 0 if first, or last = 32) than last value rotated by
//  -add some constant
int rand()
{
	seed ^= 0xa93517f1;
	seed = (seed >> rot) | (seed << ((sizeof(int) * 8) - rot));
	rot++;
	if (rot > 31) rot = 0; 
	seed += 1231;
	return seed;
}
