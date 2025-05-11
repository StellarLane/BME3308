#include <reg51.h>

extern int sqr_C(int a, int b);
extern int sqr_ASM(int a, int b);

int main() {

	int a = 3;
	int b = 4;
	int c = 0;
	c = sqr_C(a, b);
	c = 0;
	c = sqr_ASM(a, b);
	return 0;
}