#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

volatile int global_data[1024]; // 4KB

int main(void) {
    global_data[0] = 100;
    cprintf("Dirty COW Test: Initial value = %d, addr = %x\n", global_data[0], global_data);
    int pid = fork();
    if (pid == 0) {
        // Child
        cprintf("Child: Attempting to write to global_data...\n");
        global_data[0] = 200; // Trigger COW
        cprintf("Child: Wrote 200. Exiting.\n");
        exit(0);
    } else {
        // Parent
        wait();
        cprintf("Parent: global_data = %d\n", global_data[0]);
        if (global_data[0] == 200) {
            cprintf("VULNERABILITY REPRODUCED: Parent memory modified!\n");
        } else {
            cprintf("SAFE: Parent memory unchanged.\n");
        }
        exit(0);
    }
    return 0;
}
