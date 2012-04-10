//
// frosk.c
//
// written by sjrct
//

#include <frosk.h>

#define PUSH_PARAM(X)   __asm__("push %0;" : : "g" (X))
#define SYSCALL(X,R)    __asm__("int $0x40;" : "=a" (R) : "a" (X) )
#define DRVRCALL(X,R,D) __asm__("int $0x41;" : "=a" (R) : "a" (X), "c" (D) )

int __syscall0(int f)
{
	int r;
	SYSCALL(f,r);
	return r;
}

int __syscall1(int f, int x)
{
	int r;
	PUSH_PARAM(x);
	SYSCALL(f,r);
	asm("add $4,%esp");
	return r;
}

int __syscall2(int f, int x, int y)
{
	int r;
	PUSH_PARAM(y);
	PUSH_PARAM(x);
	SYSCALL(f,r);
	asm("add $8,%esp");
	return r;
}

int __syscall3(int f, int x, int y, int z)
{
	int r;
	PUSH_PARAM(z);
	PUSH_PARAM(y);
	PUSH_PARAM(x);
	SYSCALL(f,r);
	asm("add $12,%esp");
	return r;
}

int __syscall4(int f, int x, int y, int z, int v)
{
	int r;
	PUSH_PARAM(v);
	PUSH_PARAM(z);
	PUSH_PARAM(y);
	PUSH_PARAM(x);
	SYSCALL(f,r);
	asm("add $16,%esp");
	return r;
}

int __syscall5(int f, int x, int y, int z, int v, int t)
{
	int r;
	PUSH_PARAM(t);
	PUSH_PARAM(v);
	PUSH_PARAM(z);
	PUSH_PARAM(y);
	PUSH_PARAM(x);
	SYSCALL(f,r);
	asm("add $20,%esp");
	return r;
}

int __drvrcall0(int f, int d)
{
	int r;
	DRVRCALL(f,r,d);
	return r;
}

int __drvrcall1(int f, int d, int x)
{
	int r;
	PUSH_PARAM(x);
	DRVRCALL(f,r,d);
	asm("add $4,%esp");
	return r;
}

int __drvrcall2(int f, int d, int x, int y)
{
	int r;
	PUSH_PARAM(y);
	PUSH_PARAM(x);
	DRVRCALL(f,r,d);
	asm("add $8,%esp");
	return r;
}

int __drvrcall3(int f, int d, int x, int y, int z)
{
	int r;
	PUSH_PARAM(z);
	PUSH_PARAM(y);
	PUSH_PARAM(x);
	DRVRCALL(f,r,d);
	asm("add $12,%esp");
	return r;
}

int __drvrcall4(int f, int d, int x, int y, int z, int v)
{
	int r;
	PUSH_PARAM(v);
	PUSH_PARAM(z);
	PUSH_PARAM(y);
	PUSH_PARAM(x);
	DRVRCALL(f,r,d);
	asm("add $16,%esp");
	return r;
}
