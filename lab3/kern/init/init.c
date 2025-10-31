#include <clock.h>
#include <console.h>
#include <defs.h>
#include <intr.h>
#include <kdebug.h>
#include <kmonitor.h>
#include <pmm.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <dtb.h>

int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

// 添加测试函数声明
void test_exceptions(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    dtb_init();
    cons_init();  // init the console
    
    const char *message = "(THU.CST) os is loading ...\0";
    cputs(message);

    print_kerninfo();

    // grade_backtrace();
    
    // 修复：idt_init() 只调用一次
    idt_init();  // init interrupt descriptor table

    pmm_init();  // init physical memory management

    // 在这里添加异常测试 - 确保异常处理已初始化但中断尚未开启
    test_exceptions();

    clock_init();   // init clock interrupt
    intr_enable();  // enable irq interrupt

    /* do nothing */
    while (1)
        ;
}

// 添加测试函数实现
void test_exceptions(void) {
    cprintf("\n===== Testing Exception Handlers =====\n");
    
    // 测试1: 非法指令异常
    cprintf("Test 1: Triggering illegal instruction exception...\n");
    // 使用内联汇编插入明确的非法指令
    asm volatile(".word 0x00000000\n"  // 这是一个明确的非法指令
                 "nop\n"               // 异常处理后继续执行到这里
                 ::: "memory");
    
    cprintf("Illegal instruction test completed.\n\n");
    
    // 测试2: 断点异常  
    cprintf("Test 2: Triggering breakpoint exception...\n");
    // 使用 ebreak 指令触发断点
    asm volatile("ebreak\n"
                 "nop\n"               // 异常处理后继续执行到这里
                 ::: "memory");
    
    cprintf("Breakpoint test completed.\n\n");
    
    cprintf("===== All Exception Tests Finished =====\n\n");
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline)) grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (uintptr_t)&arg0, arg1, (uintptr_t)&arg1);
}

void __attribute__((noinline)) grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void grade_backtrace(void) { grade_backtrace0(0, (uintptr_t)kern_init, 0xffff0000); }
