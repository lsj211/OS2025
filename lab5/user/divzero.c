#include <stdio.h>
#include <ulib.h>

int zero;

int
main(void) {

    int result;
    /* Use hardware division directly so DIV by 0 returns -1 per RISC-V spec
     * instead of being optimized away under C's undefined behavior. */
    asm volatile("divw %0, %1, %2" : "=r"(result) : "r"(1), "r"(zero));
    cprintf("value is %d.\n", result);
    
    // cprintf("value is %d.\n", 1 / zero);
    panic("FAIL: T.T\n");
}

