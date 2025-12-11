#include <ulib.h>
#include <stdio.h>
#include <stdlib.h>

static char buf[4096] = { 'A', 0 };

int main(void)
{
    int pid = fork();
    if (pid == 0)
    {
        buf[0] = 'B'; // 触发 COW
        cprintf("[child] buf=%c\n", buf[0]);
        exit(0);
    }
    else if (pid > 0)
    {
        wait();
        cprintf("[parent] buf=%c\n", buf[0]);
        exit(0);
    }
    else
    {
        cprintf("fork failed\n");
        exit(-1);
    }
}
