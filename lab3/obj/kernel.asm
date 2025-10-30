
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 1. 使用临时寄存器 t1 计算栈顶的精确地址
    lui t1, %hi(bootstacktop)
ffffffffc0200040:	c0205337          	lui	t1,0xc0205
    addi t1, t1, %lo(bootstacktop)
ffffffffc0200044:	00030313          	mv	t1,t1
    # 2. 将精确地址一次性地、安全地传给 sp
    mv sp, t1
ffffffffc0200048:	811a                	mv	sp,t1
    # 现在栈指针已经完美设置，可以安全地调用任何C函数了
    # 然后跳转到 kern_init (不再返回)
    lui t0, %hi(kern_init)
ffffffffc020004a:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020004e:	05428293          	addi	t0,t0,84 # ffffffffc0200054 <kern_init>
    jr t0
ffffffffc0200052:	8282                	jr	t0

ffffffffc0200054 <kern_init>:
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    // 先清零 BSS，再读取并保存 DTB 的内存信息，避免被清零覆盖（为了解释变化 正式上传时我觉得应该删去这句话）
    memset(edata, 0, end - edata);
ffffffffc0200054:	00006517          	auipc	a0,0x6
ffffffffc0200058:	fd450513          	addi	a0,a0,-44 # ffffffffc0206028 <free_area>
ffffffffc020005c:	00006617          	auipc	a2,0x6
ffffffffc0200060:	44460613          	addi	a2,a2,1092 # ffffffffc02064a0 <end>
int kern_init(void) {
ffffffffc0200064:	1141                	addi	sp,sp,-16 # ffffffffc0204ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200066:	8e09                	sub	a2,a2,a0
ffffffffc0200068:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020006a:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020006c:	63b010ef          	jal	ffffffffc0201ea6 <memset>
    dtb_init();
ffffffffc0200070:	3c6000ef          	jal	ffffffffc0200436 <dtb_init>
    cons_init();  // init the console
ffffffffc0200074:	3b4000ef          	jal	ffffffffc0200428 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200078:	00002517          	auipc	a0,0x2
ffffffffc020007c:	e4050513          	addi	a0,a0,-448 # ffffffffc0201eb8 <etext>
ffffffffc0200080:	08c000ef          	jal	ffffffffc020010c <cputs>

    print_kerninfo();
ffffffffc0200084:	0e4000ef          	jal	ffffffffc0200168 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200088:	700000ef          	jal	ffffffffc0200788 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020008c:	6b0010ef          	jal	ffffffffc020173c <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc0200090:	6f8000ef          	jal	ffffffffc0200788 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200094:	352000ef          	jal	ffffffffc02003e6 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200098:	6e4000ef          	jal	ffffffffc020077c <intr_enable>

    /* do nothing */
    while (1)
ffffffffc020009c:	a001                	j	ffffffffc020009c <kern_init+0x48>

ffffffffc020009e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
ffffffffc02000a0:	ec06                	sd	ra,24(sp)
ffffffffc02000a2:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc02000a4:	386000ef          	jal	ffffffffc020042a <cons_putc>
    (*cnt) ++;
ffffffffc02000a8:	65a2                	ld	a1,8(sp)
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
ffffffffc02000ac:	419c                	lw	a5,0(a1)
ffffffffc02000ae:	2785                	addiw	a5,a5,1
ffffffffc02000b0:	c19c                	sw	a5,0(a1)
}
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b6:	1101                	addi	sp,sp,-32
ffffffffc02000b8:	862a                	mv	a2,a0
ffffffffc02000ba:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000bc:	00000517          	auipc	a0,0x0
ffffffffc02000c0:	fe250513          	addi	a0,a0,-30 # ffffffffc020009e <cputch>
ffffffffc02000c4:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	0b5010ef          	jal	ffffffffc020197e <vprintfmt>
    return cnt;
}
ffffffffc02000ce:	60e2                	ld	ra,24(sp)
ffffffffc02000d0:	4532                	lw	a0,12(sp)
ffffffffc02000d2:	6105                	addi	sp,sp,32
ffffffffc02000d4:	8082                	ret

ffffffffc02000d6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d8:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc02000dc:	f42e                	sd	a1,40(sp)
ffffffffc02000de:	f832                	sd	a2,48(sp)
ffffffffc02000e0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e2:	862a                	mv	a2,a0
ffffffffc02000e4:	004c                	addi	a1,sp,4
ffffffffc02000e6:	00000517          	auipc	a0,0x0
ffffffffc02000ea:	fb850513          	addi	a0,a0,-72 # ffffffffc020009e <cputch>
ffffffffc02000ee:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000f0:	ec06                	sd	ra,24(sp)
ffffffffc02000f2:	e0ba                	sd	a4,64(sp)
ffffffffc02000f4:	e4be                	sd	a5,72(sp)
ffffffffc02000f6:	e8c2                	sd	a6,80(sp)
ffffffffc02000f8:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc02000fa:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc02000fc:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000fe:	081010ef          	jal	ffffffffc020197e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200102:	60e2                	ld	ra,24(sp)
ffffffffc0200104:	4512                	lw	a0,4(sp)
ffffffffc0200106:	6125                	addi	sp,sp,96
ffffffffc0200108:	8082                	ret

ffffffffc020010a <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc020010a:	a605                	j	ffffffffc020042a <cons_putc>

ffffffffc020010c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc020010c:	1101                	addi	sp,sp,-32
ffffffffc020010e:	e822                	sd	s0,16(sp)
ffffffffc0200110:	ec06                	sd	ra,24(sp)
ffffffffc0200112:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200114:	00054503          	lbu	a0,0(a0)
ffffffffc0200118:	c51d                	beqz	a0,ffffffffc0200146 <cputs+0x3a>
ffffffffc020011a:	e426                	sd	s1,8(sp)
ffffffffc020011c:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc020011e:	4481                	li	s1,0
    cons_putc(c);
ffffffffc0200120:	30a000ef          	jal	ffffffffc020042a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200124:	00044503          	lbu	a0,0(s0)
ffffffffc0200128:	0405                	addi	s0,s0,1
ffffffffc020012a:	87a6                	mv	a5,s1
    (*cnt) ++;
ffffffffc020012c:	2485                	addiw	s1,s1,1
    while ((c = *str ++) != '\0') {
ffffffffc020012e:	f96d                	bnez	a0,ffffffffc0200120 <cputs+0x14>
    cons_putc(c);
ffffffffc0200130:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc0200132:	0027841b          	addiw	s0,a5,2
ffffffffc0200136:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc0200138:	2f2000ef          	jal	ffffffffc020042a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020013c:	60e2                	ld	ra,24(sp)
ffffffffc020013e:	8522                	mv	a0,s0
ffffffffc0200140:	6442                	ld	s0,16(sp)
ffffffffc0200142:	6105                	addi	sp,sp,32
ffffffffc0200144:	8082                	ret
    cons_putc(c);
ffffffffc0200146:	4529                	li	a0,10
ffffffffc0200148:	2e2000ef          	jal	ffffffffc020042a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020014c:	4405                	li	s0,1
}
ffffffffc020014e:	60e2                	ld	ra,24(sp)
ffffffffc0200150:	8522                	mv	a0,s0
ffffffffc0200152:	6442                	ld	s0,16(sp)
ffffffffc0200154:	6105                	addi	sp,sp,32
ffffffffc0200156:	8082                	ret

ffffffffc0200158 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200158:	1141                	addi	sp,sp,-16
ffffffffc020015a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020015c:	2d6000ef          	jal	ffffffffc0200432 <cons_getc>
ffffffffc0200160:	dd75                	beqz	a0,ffffffffc020015c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
ffffffffc0200164:	0141                	addi	sp,sp,16
ffffffffc0200166:	8082                	ret

ffffffffc0200168 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200168:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	d6e50513          	addi	a0,a0,-658 # ffffffffc0201ed8 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200172:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200174:	f63ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200178:	00000597          	auipc	a1,0x0
ffffffffc020017c:	edc58593          	addi	a1,a1,-292 # ffffffffc0200054 <kern_init>
ffffffffc0200180:	00002517          	auipc	a0,0x2
ffffffffc0200184:	d7850513          	addi	a0,a0,-648 # ffffffffc0201ef8 <etext+0x40>
ffffffffc0200188:	f4fff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020018c:	00002597          	auipc	a1,0x2
ffffffffc0200190:	d2c58593          	addi	a1,a1,-724 # ffffffffc0201eb8 <etext>
ffffffffc0200194:	00002517          	auipc	a0,0x2
ffffffffc0200198:	d8450513          	addi	a0,a0,-636 # ffffffffc0201f18 <etext+0x60>
ffffffffc020019c:	f3bff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001a0:	00006597          	auipc	a1,0x6
ffffffffc02001a4:	e8858593          	addi	a1,a1,-376 # ffffffffc0206028 <free_area>
ffffffffc02001a8:	00002517          	auipc	a0,0x2
ffffffffc02001ac:	d9050513          	addi	a0,a0,-624 # ffffffffc0201f38 <etext+0x80>
ffffffffc02001b0:	f27ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001b4:	00006597          	auipc	a1,0x6
ffffffffc02001b8:	2ec58593          	addi	a1,a1,748 # ffffffffc02064a0 <end>
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	d9c50513          	addi	a0,a0,-612 # ffffffffc0201f58 <etext+0xa0>
ffffffffc02001c4:	f13ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c8:	00000717          	auipc	a4,0x0
ffffffffc02001cc:	e8c70713          	addi	a4,a4,-372 # ffffffffc0200054 <kern_init>
ffffffffc02001d0:	00006797          	auipc	a5,0x6
ffffffffc02001d4:	6cf78793          	addi	a5,a5,1743 # ffffffffc020689f <end+0x3ff>
ffffffffc02001d8:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001da:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001de:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e4:	95be                	add	a1,a1,a5
ffffffffc02001e6:	85a9                	srai	a1,a1,0xa
ffffffffc02001e8:	00002517          	auipc	a0,0x2
ffffffffc02001ec:	d9050513          	addi	a0,a0,-624 # ffffffffc0201f78 <etext+0xc0>
}
ffffffffc02001f0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f2:	b5d5                	j	ffffffffc02000d6 <cprintf>

ffffffffc02001f4 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f4:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02001f6:	00002617          	auipc	a2,0x2
ffffffffc02001fa:	db260613          	addi	a2,a2,-590 # ffffffffc0201fa8 <etext+0xf0>
ffffffffc02001fe:	04d00593          	li	a1,77
ffffffffc0200202:	00002517          	auipc	a0,0x2
ffffffffc0200206:	dbe50513          	addi	a0,a0,-578 # ffffffffc0201fc0 <etext+0x108>
void print_stackframe(void) {
ffffffffc020020a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020c:	17c000ef          	jal	ffffffffc0200388 <__panic>

ffffffffc0200210 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200210:	1101                	addi	sp,sp,-32
ffffffffc0200212:	e822                	sd	s0,16(sp)
ffffffffc0200214:	e426                	sd	s1,8(sp)
ffffffffc0200216:	ec06                	sd	ra,24(sp)
ffffffffc0200218:	00003417          	auipc	s0,0x3
ffffffffc020021c:	a9040413          	addi	s0,s0,-1392 # ffffffffc0202ca8 <commands>
ffffffffc0200220:	00003497          	auipc	s1,0x3
ffffffffc0200224:	ad048493          	addi	s1,s1,-1328 # ffffffffc0202cf0 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200228:	6410                	ld	a2,8(s0)
ffffffffc020022a:	600c                	ld	a1,0(s0)
ffffffffc020022c:	00002517          	auipc	a0,0x2
ffffffffc0200230:	dac50513          	addi	a0,a0,-596 # ffffffffc0201fd8 <etext+0x120>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200234:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200236:	ea1ff0ef          	jal	ffffffffc02000d6 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020023a:	fe9417e3          	bne	s0,s1,ffffffffc0200228 <mon_help+0x18>
    }
    return 0;
}
ffffffffc020023e:	60e2                	ld	ra,24(sp)
ffffffffc0200240:	6442                	ld	s0,16(sp)
ffffffffc0200242:	64a2                	ld	s1,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	6105                	addi	sp,sp,32
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	f1bff0ef          	jal	ffffffffc0200168 <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f97ff0ef          	jal	ffffffffc02001f4 <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7131                	addi	sp,sp,-192
ffffffffc020026c:	e952                	sd	s4,144(sp)
ffffffffc020026e:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	d7850513          	addi	a0,a0,-648 # ffffffffc0201fe8 <etext+0x130>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	fd06                	sd	ra,184(sp)
ffffffffc020027a:	f922                	sd	s0,176(sp)
ffffffffc020027c:	f526                	sd	s1,168(sp)
ffffffffc020027e:	ed4e                	sd	s3,152(sp)
ffffffffc0200280:	e556                	sd	s5,136(sp)
ffffffffc0200282:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200284:	e53ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200288:	00002517          	auipc	a0,0x2
ffffffffc020028c:	d8850513          	addi	a0,a0,-632 # ffffffffc0202010 <etext+0x158>
ffffffffc0200290:	e47ff0ef          	jal	ffffffffc02000d6 <cprintf>
    if (tf != NULL) {
ffffffffc0200294:	000a0563          	beqz	s4,ffffffffc020029e <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc0200298:	8552                	mv	a0,s4
ffffffffc020029a:	6ce000ef          	jal	ffffffffc0200968 <print_trapframe>
ffffffffc020029e:	00003a97          	auipc	s5,0x3
ffffffffc02002a2:	a0aa8a93          	addi	s5,s5,-1526 # ffffffffc0202ca8 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc02002a6:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002a8:	00002517          	auipc	a0,0x2
ffffffffc02002ac:	d9050513          	addi	a0,a0,-624 # ffffffffc0202038 <etext+0x180>
ffffffffc02002b0:	235010ef          	jal	ffffffffc0201ce4 <readline>
ffffffffc02002b4:	842a                	mv	s0,a0
ffffffffc02002b6:	d96d                	beqz	a0,ffffffffc02002a8 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002bc:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002be:	e99d                	bnez	a1,ffffffffc02002f4 <kmonitor+0x8a>
    int argc = 0;
ffffffffc02002c0:	8b26                	mv	s6,s1
    if (argc == 0) {
ffffffffc02002c2:	fe0b03e3          	beqz	s6,ffffffffc02002a8 <kmonitor+0x3e>
ffffffffc02002c6:	00003497          	auipc	s1,0x3
ffffffffc02002ca:	9e248493          	addi	s1,s1,-1566 # ffffffffc0202ca8 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d0:	6582                	ld	a1,0(sp)
ffffffffc02002d2:	6088                	ld	a0,0(s1)
ffffffffc02002d4:	365010ef          	jal	ffffffffc0201e38 <strcmp>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d8:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002da:	c149                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002dc:	2405                	addiw	s0,s0,1
ffffffffc02002de:	04e1                	addi	s1,s1,24
ffffffffc02002e0:	fef418e3          	bne	s0,a5,ffffffffc02002d0 <kmonitor+0x66>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002517          	auipc	a0,0x2
ffffffffc02002ea:	d8250513          	addi	a0,a0,-638 # ffffffffc0202068 <etext+0x1b0>
ffffffffc02002ee:	de9ff0ef          	jal	ffffffffc02000d6 <cprintf>
    return 0;
ffffffffc02002f2:	bf5d                	j	ffffffffc02002a8 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f4:	00002517          	auipc	a0,0x2
ffffffffc02002f8:	d4c50513          	addi	a0,a0,-692 # ffffffffc0202040 <etext+0x188>
ffffffffc02002fc:	399010ef          	jal	ffffffffc0201e94 <strchr>
ffffffffc0200300:	c901                	beqz	a0,ffffffffc0200310 <kmonitor+0xa6>
ffffffffc0200302:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200306:	00040023          	sb	zero,0(s0)
ffffffffc020030a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	d9d5                	beqz	a1,ffffffffc02002c0 <kmonitor+0x56>
ffffffffc020030e:	b7dd                	j	ffffffffc02002f4 <kmonitor+0x8a>
        if (*buf == '\0') {
ffffffffc0200310:	00044783          	lbu	a5,0(s0)
ffffffffc0200314:	d7d5                	beqz	a5,ffffffffc02002c0 <kmonitor+0x56>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	03348b63          	beq	s1,s3,ffffffffc020034c <kmonitor+0xe2>
        argv[argc ++] = buf;
ffffffffc020031a:	00349793          	slli	a5,s1,0x3
ffffffffc020031e:	978a                	add	a5,a5,sp
ffffffffc0200320:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200322:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200326:	2485                	addiw	s1,s1,1
ffffffffc0200328:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020032a:	e591                	bnez	a1,ffffffffc0200336 <kmonitor+0xcc>
ffffffffc020032c:	bf59                	j	ffffffffc02002c2 <kmonitor+0x58>
ffffffffc020032e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200332:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200334:	d5d1                	beqz	a1,ffffffffc02002c0 <kmonitor+0x56>
ffffffffc0200336:	00002517          	auipc	a0,0x2
ffffffffc020033a:	d0a50513          	addi	a0,a0,-758 # ffffffffc0202040 <etext+0x188>
ffffffffc020033e:	357010ef          	jal	ffffffffc0201e94 <strchr>
ffffffffc0200342:	d575                	beqz	a0,ffffffffc020032e <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	00044583          	lbu	a1,0(s0)
ffffffffc0200348:	dda5                	beqz	a1,ffffffffc02002c0 <kmonitor+0x56>
ffffffffc020034a:	b76d                	j	ffffffffc02002f4 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020034c:	45c1                	li	a1,16
ffffffffc020034e:	00002517          	auipc	a0,0x2
ffffffffc0200352:	cfa50513          	addi	a0,a0,-774 # ffffffffc0202048 <etext+0x190>
ffffffffc0200356:	d81ff0ef          	jal	ffffffffc02000d6 <cprintf>
ffffffffc020035a:	b7c1                	j	ffffffffc020031a <kmonitor+0xb0>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020035c:	00141793          	slli	a5,s0,0x1
ffffffffc0200360:	97a2                	add	a5,a5,s0
ffffffffc0200362:	078e                	slli	a5,a5,0x3
ffffffffc0200364:	97d6                	add	a5,a5,s5
ffffffffc0200366:	6b9c                	ld	a5,16(a5)
ffffffffc0200368:	fffb051b          	addiw	a0,s6,-1
ffffffffc020036c:	8652                	mv	a2,s4
ffffffffc020036e:	002c                	addi	a1,sp,8
ffffffffc0200370:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200372:	f2055be3          	bgez	a0,ffffffffc02002a8 <kmonitor+0x3e>
}
ffffffffc0200376:	70ea                	ld	ra,184(sp)
ffffffffc0200378:	744a                	ld	s0,176(sp)
ffffffffc020037a:	74aa                	ld	s1,168(sp)
ffffffffc020037c:	69ea                	ld	s3,152(sp)
ffffffffc020037e:	6a4a                	ld	s4,144(sp)
ffffffffc0200380:	6aaa                	ld	s5,136(sp)
ffffffffc0200382:	6b0a                	ld	s6,128(sp)
ffffffffc0200384:	6129                	addi	sp,sp,192
ffffffffc0200386:	8082                	ret

ffffffffc0200388 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200388:	00006317          	auipc	t1,0x6
ffffffffc020038c:	0b832303          	lw	t1,184(t1) # ffffffffc0206440 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200390:	715d                	addi	sp,sp,-80
ffffffffc0200392:	ec06                	sd	ra,24(sp)
ffffffffc0200394:	f436                	sd	a3,40(sp)
ffffffffc0200396:	f83a                	sd	a4,48(sp)
ffffffffc0200398:	fc3e                	sd	a5,56(sp)
ffffffffc020039a:	e0c2                	sd	a6,64(sp)
ffffffffc020039c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020039e:	02031e63          	bnez	t1,ffffffffc02003da <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003a2:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003a4:	103c                	addi	a5,sp,40
ffffffffc02003a6:	e822                	sd	s0,16(sp)
ffffffffc02003a8:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003aa:	862e                	mv	a2,a1
ffffffffc02003ac:	85aa                	mv	a1,a0
ffffffffc02003ae:	00002517          	auipc	a0,0x2
ffffffffc02003b2:	d6250513          	addi	a0,a0,-670 # ffffffffc0202110 <etext+0x258>
    is_panic = 1;
ffffffffc02003b6:	00006697          	auipc	a3,0x6
ffffffffc02003ba:	08e6a523          	sw	a4,138(a3) # ffffffffc0206440 <is_panic>
    va_start(ap, fmt);
ffffffffc02003be:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003c0:	d17ff0ef          	jal	ffffffffc02000d6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003c4:	65a2                	ld	a1,8(sp)
ffffffffc02003c6:	8522                	mv	a0,s0
ffffffffc02003c8:	cefff0ef          	jal	ffffffffc02000b6 <vcprintf>
    cprintf("\n");
ffffffffc02003cc:	00002517          	auipc	a0,0x2
ffffffffc02003d0:	d6450513          	addi	a0,a0,-668 # ffffffffc0202130 <etext+0x278>
ffffffffc02003d4:	d03ff0ef          	jal	ffffffffc02000d6 <cprintf>
ffffffffc02003d8:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003da:	3a8000ef          	jal	ffffffffc0200782 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003de:	4501                	li	a0,0
ffffffffc02003e0:	e8bff0ef          	jal	ffffffffc020026a <kmonitor>
    while (1) {
ffffffffc02003e4:	bfed                	j	ffffffffc02003de <__panic+0x56>

ffffffffc02003e6 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc02003e6:	1141                	addi	sp,sp,-16
ffffffffc02003e8:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc02003ea:	02000793          	li	a5,32
ffffffffc02003ee:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003f2:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003f6:	67e1                	lui	a5,0x18
ffffffffc02003f8:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003fc:	953e                	add	a0,a0,a5
ffffffffc02003fe:	1b7010ef          	jal	ffffffffc0201db4 <sbi_set_timer>
}
ffffffffc0200402:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200404:	00006797          	auipc	a5,0x6
ffffffffc0200408:	0407b223          	sd	zero,68(a5) # ffffffffc0206448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040c:	00002517          	auipc	a0,0x2
ffffffffc0200410:	d2c50513          	addi	a0,a0,-724 # ffffffffc0202138 <etext+0x280>
}
ffffffffc0200414:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200416:	b1c1                	j	ffffffffc02000d6 <cprintf>

ffffffffc0200418 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	1910106f          	j	ffffffffc0201db4 <sbi_set_timer>

ffffffffc0200428 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200428:	8082                	ret

ffffffffc020042a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020042a:	0ff57513          	zext.b	a0,a0
ffffffffc020042e:	16d0106f          	j	ffffffffc0201d9a <sbi_console_putchar>

ffffffffc0200432 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200432:	19d0106f          	j	ffffffffc0201dce <sbi_console_getchar>

ffffffffc0200436 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200436:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc0200438:	00002517          	auipc	a0,0x2
ffffffffc020043c:	d2050513          	addi	a0,a0,-736 # ffffffffc0202158 <etext+0x2a0>
void dtb_init(void) {
ffffffffc0200440:	f406                	sd	ra,40(sp)
ffffffffc0200442:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc0200444:	c93ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200448:	00006597          	auipc	a1,0x6
ffffffffc020044c:	bb85b583          	ld	a1,-1096(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200450:	00002517          	auipc	a0,0x2
ffffffffc0200454:	d1850513          	addi	a0,a0,-744 # ffffffffc0202168 <etext+0x2b0>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200458:	00006417          	auipc	s0,0x6
ffffffffc020045c:	bb040413          	addi	s0,s0,-1104 # ffffffffc0206008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200460:	c77ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200464:	600c                	ld	a1,0(s0)
ffffffffc0200466:	00002517          	auipc	a0,0x2
ffffffffc020046a:	d1250513          	addi	a0,a0,-750 # ffffffffc0202178 <etext+0x2c0>
ffffffffc020046e:	c69ff0ef          	jal	ffffffffc02000d6 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200472:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200474:	00002517          	auipc	a0,0x2
ffffffffc0200478:	d1c50513          	addi	a0,a0,-740 # ffffffffc0202190 <etext+0x2d8>
    if (boot_dtb == 0) {
ffffffffc020047c:	10070163          	beqz	a4,ffffffffc020057e <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200480:	57f5                	li	a5,-3
ffffffffc0200482:	07fa                	slli	a5,a5,0x1e
ffffffffc0200484:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200486:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc0200488:	d00e06b7          	lui	a3,0xd00e0
ffffffffc020048c:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfed9a4d>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200490:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200494:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200498:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020049c:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a0:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a4:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a6:	8e49                	or	a2,a2,a0
ffffffffc02004a8:	0ff7f793          	zext.b	a5,a5
ffffffffc02004ac:	8dd1                	or	a1,a1,a2
ffffffffc02004ae:	07a2                	slli	a5,a5,0x8
ffffffffc02004b0:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b2:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc02004b6:	0cd59863          	bne	a1,a3,ffffffffc0200586 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02004ba:	4710                	lw	a2,8(a4)
ffffffffc02004bc:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02004be:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c0:	0086541b          	srliw	s0,a2,0x8
ffffffffc02004c4:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c8:	01865e1b          	srliw	t3,a2,0x18
ffffffffc02004cc:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004d0:	0186151b          	slliw	a0,a2,0x18
ffffffffc02004d4:	0186959b          	slliw	a1,a3,0x18
ffffffffc02004d8:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004dc:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e0:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004e4:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02004e8:	01c56533          	or	a0,a0,t3
ffffffffc02004ec:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f0:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f4:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f8:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fc:	0ff6f693          	zext.b	a3,a3
ffffffffc0200500:	8c49                	or	s0,s0,a0
ffffffffc0200502:	0622                	slli	a2,a2,0x8
ffffffffc0200504:	8fcd                	or	a5,a5,a1
ffffffffc0200506:	06a2                	slli	a3,a3,0x8
ffffffffc0200508:	8c51                	or	s0,s0,a2
ffffffffc020050a:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020050c:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020050e:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200510:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200512:	9381                	srli	a5,a5,0x20
ffffffffc0200514:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200516:	4301                	li	t1,0
        switch (token) {
ffffffffc0200518:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020051a:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020051c:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc0200520:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200522:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200524:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200528:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020052c:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200530:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200534:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200538:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020053c:	8ed1                	or	a3,a3,a2
ffffffffc020053e:	0ff77713          	zext.b	a4,a4
ffffffffc0200542:	8fd5                	or	a5,a5,a3
ffffffffc0200544:	0722                	slli	a4,a4,0x8
ffffffffc0200546:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc0200548:	05178763          	beq	a5,a7,ffffffffc0200596 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020054c:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc020054e:	00f8e963          	bltu	a7,a5,ffffffffc0200560 <dtb_init+0x12a>
ffffffffc0200552:	07c78d63          	beq	a5,t3,ffffffffc02005cc <dtb_init+0x196>
ffffffffc0200556:	4709                	li	a4,2
ffffffffc0200558:	00e79763          	bne	a5,a4,ffffffffc0200566 <dtb_init+0x130>
ffffffffc020055c:	4301                	li	t1,0
ffffffffc020055e:	b7d1                	j	ffffffffc0200522 <dtb_init+0xec>
ffffffffc0200560:	4711                	li	a4,4
ffffffffc0200562:	fce780e3          	beq	a5,a4,ffffffffc0200522 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	cf250513          	addi	a0,a0,-782 # ffffffffc0202258 <etext+0x3a0>
ffffffffc020056e:	b69ff0ef          	jal	ffffffffc02000d6 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200572:	64e2                	ld	s1,24(sp)
ffffffffc0200574:	6942                	ld	s2,16(sp)
ffffffffc0200576:	00002517          	auipc	a0,0x2
ffffffffc020057a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0202290 <etext+0x3d8>
}
ffffffffc020057e:	7402                	ld	s0,32(sp)
ffffffffc0200580:	70a2                	ld	ra,40(sp)
ffffffffc0200582:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200584:	be89                	j	ffffffffc02000d6 <cprintf>
}
ffffffffc0200586:	7402                	ld	s0,32(sp)
ffffffffc0200588:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	c2650513          	addi	a0,a0,-986 # ffffffffc02021b0 <etext+0x2f8>
}
ffffffffc0200592:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200594:	b689                	j	ffffffffc02000d6 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200596:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200598:	0087579b          	srliw	a5,a4,0x8
ffffffffc020059c:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005a0:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005a4:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005a8:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ac:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005b0:	8ed1                	or	a3,a3,a2
ffffffffc02005b2:	0ff77713          	zext.b	a4,a4
ffffffffc02005b6:	8fd5                	or	a5,a5,a3
ffffffffc02005b8:	0722                	slli	a4,a4,0x8
ffffffffc02005ba:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02005bc:	04031463          	bnez	t1,ffffffffc0200604 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02005c0:	1782                	slli	a5,a5,0x20
ffffffffc02005c2:	9381                	srli	a5,a5,0x20
ffffffffc02005c4:	043d                	addi	s0,s0,15
ffffffffc02005c6:	943e                	add	s0,s0,a5
ffffffffc02005c8:	9871                	andi	s0,s0,-4
                break;
ffffffffc02005ca:	bfa1                	j	ffffffffc0200522 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc02005cc:	8522                	mv	a0,s0
ffffffffc02005ce:	e01a                	sd	t1,0(sp)
ffffffffc02005d0:	035010ef          	jal	ffffffffc0201e04 <strlen>
ffffffffc02005d4:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005d6:	4619                	li	a2,6
ffffffffc02005d8:	8522                	mv	a0,s0
ffffffffc02005da:	00002597          	auipc	a1,0x2
ffffffffc02005de:	bfe58593          	addi	a1,a1,-1026 # ffffffffc02021d8 <etext+0x320>
ffffffffc02005e2:	08b010ef          	jal	ffffffffc0201e6c <strncmp>
ffffffffc02005e6:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02005e8:	0411                	addi	s0,s0,4
ffffffffc02005ea:	0004879b          	sext.w	a5,s1
ffffffffc02005ee:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005f0:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02005f4:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005f6:	00a36333          	or	t1,t1,a0
                break;
ffffffffc02005fa:	00ff0837          	lui	a6,0xff0
ffffffffc02005fe:	488d                	li	a7,3
ffffffffc0200600:	4e05                	li	t3,1
ffffffffc0200602:	b705                	j	ffffffffc0200522 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200604:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200606:	00002597          	auipc	a1,0x2
ffffffffc020060a:	bda58593          	addi	a1,a1,-1062 # ffffffffc02021e0 <etext+0x328>
ffffffffc020060e:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200610:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200614:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200618:	0187169b          	slliw	a3,a4,0x18
ffffffffc020061c:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200620:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200624:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200628:	8ed1                	or	a3,a3,a2
ffffffffc020062a:	0ff77713          	zext.b	a4,a4
ffffffffc020062e:	0722                	slli	a4,a4,0x8
ffffffffc0200630:	8d55                	or	a0,a0,a3
ffffffffc0200632:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200634:	1502                	slli	a0,a0,0x20
ffffffffc0200636:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200638:	954a                	add	a0,a0,s2
ffffffffc020063a:	e01a                	sd	t1,0(sp)
ffffffffc020063c:	7fc010ef          	jal	ffffffffc0201e38 <strcmp>
ffffffffc0200640:	67a2                	ld	a5,8(sp)
ffffffffc0200642:	473d                	li	a4,15
ffffffffc0200644:	6302                	ld	t1,0(sp)
ffffffffc0200646:	00ff0837          	lui	a6,0xff0
ffffffffc020064a:	488d                	li	a7,3
ffffffffc020064c:	4e05                	li	t3,1
ffffffffc020064e:	f6f779e3          	bgeu	a4,a5,ffffffffc02005c0 <dtb_init+0x18a>
ffffffffc0200652:	f53d                	bnez	a0,ffffffffc02005c0 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200654:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200658:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020065c:	00002517          	auipc	a0,0x2
ffffffffc0200660:	b8c50513          	addi	a0,a0,-1140 # ffffffffc02021e8 <etext+0x330>
           fdt32_to_cpu(x >> 32);
ffffffffc0200664:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200668:	0087d31b          	srliw	t1,a5,0x8
ffffffffc020066c:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200670:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200674:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200678:	0187959b          	slliw	a1,a5,0x18
ffffffffc020067c:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200680:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200684:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200688:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020068c:	01037333          	and	t1,t1,a6
ffffffffc0200690:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200694:	01e5e5b3          	or	a1,a1,t5
ffffffffc0200698:	0ff7f793          	zext.b	a5,a5
ffffffffc020069c:	01de6e33          	or	t3,t3,t4
ffffffffc02006a0:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a4:	01067633          	and	a2,a2,a6
ffffffffc02006a8:	0086d31b          	srliw	t1,a3,0x8
ffffffffc02006ac:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b0:	07a2                	slli	a5,a5,0x8
ffffffffc02006b2:	0108d89b          	srliw	a7,a7,0x10
ffffffffc02006b6:	0186df1b          	srliw	t5,a3,0x18
ffffffffc02006ba:	01875e9b          	srliw	t4,a4,0x18
ffffffffc02006be:	8ddd                	or	a1,a1,a5
ffffffffc02006c0:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c4:	0186979b          	slliw	a5,a3,0x18
ffffffffc02006c8:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006cc:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d0:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d4:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d8:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006dc:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006e0:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e4:	08a2                	slli	a7,a7,0x8
ffffffffc02006e6:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ea:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ee:	0ff6f693          	zext.b	a3,a3
ffffffffc02006f2:	01de6833          	or	a6,t3,t4
ffffffffc02006f6:	0ff77713          	zext.b	a4,a4
ffffffffc02006fa:	01166633          	or	a2,a2,a7
ffffffffc02006fe:	0067e7b3          	or	a5,a5,t1
ffffffffc0200702:	06a2                	slli	a3,a3,0x8
ffffffffc0200704:	01046433          	or	s0,s0,a6
ffffffffc0200708:	0722                	slli	a4,a4,0x8
ffffffffc020070a:	8fd5                	or	a5,a5,a3
ffffffffc020070c:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc020070e:	1582                	slli	a1,a1,0x20
ffffffffc0200710:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200712:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200714:	9201                	srli	a2,a2,0x20
ffffffffc0200716:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200718:	1402                	slli	s0,s0,0x20
ffffffffc020071a:	00b7e4b3          	or	s1,a5,a1
ffffffffc020071e:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200720:	9b7ff0ef          	jal	ffffffffc02000d6 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200724:	85a6                	mv	a1,s1
ffffffffc0200726:	00002517          	auipc	a0,0x2
ffffffffc020072a:	ae250513          	addi	a0,a0,-1310 # ffffffffc0202208 <etext+0x350>
ffffffffc020072e:	9a9ff0ef          	jal	ffffffffc02000d6 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200732:	01445613          	srli	a2,s0,0x14
ffffffffc0200736:	85a2                	mv	a1,s0
ffffffffc0200738:	00002517          	auipc	a0,0x2
ffffffffc020073c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0202220 <etext+0x368>
ffffffffc0200740:	997ff0ef          	jal	ffffffffc02000d6 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200744:	009405b3          	add	a1,s0,s1
ffffffffc0200748:	15fd                	addi	a1,a1,-1
ffffffffc020074a:	00002517          	auipc	a0,0x2
ffffffffc020074e:	af650513          	addi	a0,a0,-1290 # ffffffffc0202240 <etext+0x388>
ffffffffc0200752:	985ff0ef          	jal	ffffffffc02000d6 <cprintf>
        memory_base = mem_base;
ffffffffc0200756:	00006797          	auipc	a5,0x6
ffffffffc020075a:	d097b123          	sd	s1,-766(a5) # ffffffffc0206458 <memory_base>
        memory_size = mem_size;
ffffffffc020075e:	00006797          	auipc	a5,0x6
ffffffffc0200762:	ce87b923          	sd	s0,-782(a5) # ffffffffc0206450 <memory_size>
ffffffffc0200766:	b531                	j	ffffffffc0200572 <dtb_init+0x13c>

ffffffffc0200768 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200768:	00006517          	auipc	a0,0x6
ffffffffc020076c:	cf053503          	ld	a0,-784(a0) # ffffffffc0206458 <memory_base>
ffffffffc0200770:	8082                	ret

ffffffffc0200772 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc0200772:	00006517          	auipc	a0,0x6
ffffffffc0200776:	cde53503          	ld	a0,-802(a0) # ffffffffc0206450 <memory_size>
ffffffffc020077a:	8082                	ret

ffffffffc020077c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020077c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200780:	8082                	ret

ffffffffc0200782 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200782:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200786:	8082                	ret

ffffffffc0200788 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200788:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020078c:	00000797          	auipc	a5,0x0
ffffffffc0200790:	32478793          	addi	a5,a5,804 # ffffffffc0200ab0 <__alltraps>
ffffffffc0200794:	10579073          	csrw	stvec,a5
}
ffffffffc0200798:	8082                	ret

ffffffffc020079a <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020079a:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020079c:	1141                	addi	sp,sp,-16
ffffffffc020079e:	e022                	sd	s0,0(sp)
ffffffffc02007a0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02007a2:	00002517          	auipc	a0,0x2
ffffffffc02007a6:	b0650513          	addi	a0,a0,-1274 # ffffffffc02022a8 <etext+0x3f0>
void print_regs(struct pushregs *gpr) {
ffffffffc02007aa:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02007ac:	92bff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02007b0:	640c                	ld	a1,8(s0)
ffffffffc02007b2:	00002517          	auipc	a0,0x2
ffffffffc02007b6:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02022c0 <etext+0x408>
ffffffffc02007ba:	91dff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02007be:	680c                	ld	a1,16(s0)
ffffffffc02007c0:	00002517          	auipc	a0,0x2
ffffffffc02007c4:	b1850513          	addi	a0,a0,-1256 # ffffffffc02022d8 <etext+0x420>
ffffffffc02007c8:	90fff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02007cc:	6c0c                	ld	a1,24(s0)
ffffffffc02007ce:	00002517          	auipc	a0,0x2
ffffffffc02007d2:	b2250513          	addi	a0,a0,-1246 # ffffffffc02022f0 <etext+0x438>
ffffffffc02007d6:	901ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02007da:	700c                	ld	a1,32(s0)
ffffffffc02007dc:	00002517          	auipc	a0,0x2
ffffffffc02007e0:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0202308 <etext+0x450>
ffffffffc02007e4:	8f3ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02007e8:	740c                	ld	a1,40(s0)
ffffffffc02007ea:	00002517          	auipc	a0,0x2
ffffffffc02007ee:	b3650513          	addi	a0,a0,-1226 # ffffffffc0202320 <etext+0x468>
ffffffffc02007f2:	8e5ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02007f6:	780c                	ld	a1,48(s0)
ffffffffc02007f8:	00002517          	auipc	a0,0x2
ffffffffc02007fc:	b4050513          	addi	a0,a0,-1216 # ffffffffc0202338 <etext+0x480>
ffffffffc0200800:	8d7ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200804:	7c0c                	ld	a1,56(s0)
ffffffffc0200806:	00002517          	auipc	a0,0x2
ffffffffc020080a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0202350 <etext+0x498>
ffffffffc020080e:	8c9ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200812:	602c                	ld	a1,64(s0)
ffffffffc0200814:	00002517          	auipc	a0,0x2
ffffffffc0200818:	b5450513          	addi	a0,a0,-1196 # ffffffffc0202368 <etext+0x4b0>
ffffffffc020081c:	8bbff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200820:	642c                	ld	a1,72(s0)
ffffffffc0200822:	00002517          	auipc	a0,0x2
ffffffffc0200826:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0202380 <etext+0x4c8>
ffffffffc020082a:	8adff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020082e:	682c                	ld	a1,80(s0)
ffffffffc0200830:	00002517          	auipc	a0,0x2
ffffffffc0200834:	b6850513          	addi	a0,a0,-1176 # ffffffffc0202398 <etext+0x4e0>
ffffffffc0200838:	89fff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020083c:	6c2c                	ld	a1,88(s0)
ffffffffc020083e:	00002517          	auipc	a0,0x2
ffffffffc0200842:	b7250513          	addi	a0,a0,-1166 # ffffffffc02023b0 <etext+0x4f8>
ffffffffc0200846:	891ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020084a:	702c                	ld	a1,96(s0)
ffffffffc020084c:	00002517          	auipc	a0,0x2
ffffffffc0200850:	b7c50513          	addi	a0,a0,-1156 # ffffffffc02023c8 <etext+0x510>
ffffffffc0200854:	883ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200858:	742c                	ld	a1,104(s0)
ffffffffc020085a:	00002517          	auipc	a0,0x2
ffffffffc020085e:	b8650513          	addi	a0,a0,-1146 # ffffffffc02023e0 <etext+0x528>
ffffffffc0200862:	875ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200866:	782c                	ld	a1,112(s0)
ffffffffc0200868:	00002517          	auipc	a0,0x2
ffffffffc020086c:	b9050513          	addi	a0,a0,-1136 # ffffffffc02023f8 <etext+0x540>
ffffffffc0200870:	867ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200874:	7c2c                	ld	a1,120(s0)
ffffffffc0200876:	00002517          	auipc	a0,0x2
ffffffffc020087a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0202410 <etext+0x558>
ffffffffc020087e:	859ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200882:	604c                	ld	a1,128(s0)
ffffffffc0200884:	00002517          	auipc	a0,0x2
ffffffffc0200888:	ba450513          	addi	a0,a0,-1116 # ffffffffc0202428 <etext+0x570>
ffffffffc020088c:	84bff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200890:	644c                	ld	a1,136(s0)
ffffffffc0200892:	00002517          	auipc	a0,0x2
ffffffffc0200896:	bae50513          	addi	a0,a0,-1106 # ffffffffc0202440 <etext+0x588>
ffffffffc020089a:	83dff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020089e:	684c                	ld	a1,144(s0)
ffffffffc02008a0:	00002517          	auipc	a0,0x2
ffffffffc02008a4:	bb850513          	addi	a0,a0,-1096 # ffffffffc0202458 <etext+0x5a0>
ffffffffc02008a8:	82fff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02008ac:	6c4c                	ld	a1,152(s0)
ffffffffc02008ae:	00002517          	auipc	a0,0x2
ffffffffc02008b2:	bc250513          	addi	a0,a0,-1086 # ffffffffc0202470 <etext+0x5b8>
ffffffffc02008b6:	821ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02008ba:	704c                	ld	a1,160(s0)
ffffffffc02008bc:	00002517          	auipc	a0,0x2
ffffffffc02008c0:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0202488 <etext+0x5d0>
ffffffffc02008c4:	813ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02008c8:	744c                	ld	a1,168(s0)
ffffffffc02008ca:	00002517          	auipc	a0,0x2
ffffffffc02008ce:	bd650513          	addi	a0,a0,-1066 # ffffffffc02024a0 <etext+0x5e8>
ffffffffc02008d2:	805ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02008d6:	784c                	ld	a1,176(s0)
ffffffffc02008d8:	00002517          	auipc	a0,0x2
ffffffffc02008dc:	be050513          	addi	a0,a0,-1056 # ffffffffc02024b8 <etext+0x600>
ffffffffc02008e0:	ff6ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02008e4:	7c4c                	ld	a1,184(s0)
ffffffffc02008e6:	00002517          	auipc	a0,0x2
ffffffffc02008ea:	bea50513          	addi	a0,a0,-1046 # ffffffffc02024d0 <etext+0x618>
ffffffffc02008ee:	fe8ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02008f2:	606c                	ld	a1,192(s0)
ffffffffc02008f4:	00002517          	auipc	a0,0x2
ffffffffc02008f8:	bf450513          	addi	a0,a0,-1036 # ffffffffc02024e8 <etext+0x630>
ffffffffc02008fc:	fdaff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200900:	646c                	ld	a1,200(s0)
ffffffffc0200902:	00002517          	auipc	a0,0x2
ffffffffc0200906:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0202500 <etext+0x648>
ffffffffc020090a:	fccff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc020090e:	686c                	ld	a1,208(s0)
ffffffffc0200910:	00002517          	auipc	a0,0x2
ffffffffc0200914:	c0850513          	addi	a0,a0,-1016 # ffffffffc0202518 <etext+0x660>
ffffffffc0200918:	fbeff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc020091c:	6c6c                	ld	a1,216(s0)
ffffffffc020091e:	00002517          	auipc	a0,0x2
ffffffffc0200922:	c1250513          	addi	a0,a0,-1006 # ffffffffc0202530 <etext+0x678>
ffffffffc0200926:	fb0ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020092a:	706c                	ld	a1,224(s0)
ffffffffc020092c:	00002517          	auipc	a0,0x2
ffffffffc0200930:	c1c50513          	addi	a0,a0,-996 # ffffffffc0202548 <etext+0x690>
ffffffffc0200934:	fa2ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200938:	746c                	ld	a1,232(s0)
ffffffffc020093a:	00002517          	auipc	a0,0x2
ffffffffc020093e:	c2650513          	addi	a0,a0,-986 # ffffffffc0202560 <etext+0x6a8>
ffffffffc0200942:	f94ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200946:	786c                	ld	a1,240(s0)
ffffffffc0200948:	00002517          	auipc	a0,0x2
ffffffffc020094c:	c3050513          	addi	a0,a0,-976 # ffffffffc0202578 <etext+0x6c0>
ffffffffc0200950:	f86ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200954:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200956:	6402                	ld	s0,0(sp)
ffffffffc0200958:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020095a:	00002517          	auipc	a0,0x2
ffffffffc020095e:	c3650513          	addi	a0,a0,-970 # ffffffffc0202590 <etext+0x6d8>
}
ffffffffc0200962:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200964:	f72ff06f          	j	ffffffffc02000d6 <cprintf>

ffffffffc0200968 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200968:	1141                	addi	sp,sp,-16
ffffffffc020096a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020096c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020096e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200970:	00002517          	auipc	a0,0x2
ffffffffc0200974:	c3850513          	addi	a0,a0,-968 # ffffffffc02025a8 <etext+0x6f0>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200978:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020097a:	f5cff0ef          	jal	ffffffffc02000d6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020097e:	8522                	mv	a0,s0
ffffffffc0200980:	e1bff0ef          	jal	ffffffffc020079a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200984:	10043583          	ld	a1,256(s0)
ffffffffc0200988:	00002517          	auipc	a0,0x2
ffffffffc020098c:	c3850513          	addi	a0,a0,-968 # ffffffffc02025c0 <etext+0x708>
ffffffffc0200990:	f46ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200994:	10843583          	ld	a1,264(s0)
ffffffffc0200998:	00002517          	auipc	a0,0x2
ffffffffc020099c:	c4050513          	addi	a0,a0,-960 # ffffffffc02025d8 <etext+0x720>
ffffffffc02009a0:	f36ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc02009a4:	11043583          	ld	a1,272(s0)
ffffffffc02009a8:	00002517          	auipc	a0,0x2
ffffffffc02009ac:	c4850513          	addi	a0,a0,-952 # ffffffffc02025f0 <etext+0x738>
ffffffffc02009b0:	f26ff0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02009b4:	11843583          	ld	a1,280(s0)
}
ffffffffc02009b8:	6402                	ld	s0,0(sp)
ffffffffc02009ba:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02009bc:	00002517          	auipc	a0,0x2
ffffffffc02009c0:	c4c50513          	addi	a0,a0,-948 # ffffffffc0202608 <etext+0x750>
}
ffffffffc02009c4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02009c6:	f10ff06f          	j	ffffffffc02000d6 <cprintf>

ffffffffc02009ca <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc02009ca:	11853783          	ld	a5,280(a0)
ffffffffc02009ce:	472d                	li	a4,11
ffffffffc02009d0:	0786                	slli	a5,a5,0x1
ffffffffc02009d2:	8385                	srli	a5,a5,0x1
ffffffffc02009d4:	08f76a63          	bltu	a4,a5,ffffffffc0200a68 <interrupt_handler+0x9e>
ffffffffc02009d8:	00002717          	auipc	a4,0x2
ffffffffc02009dc:	31870713          	addi	a4,a4,792 # ffffffffc0202cf0 <commands+0x48>
ffffffffc02009e0:	078a                	slli	a5,a5,0x2
ffffffffc02009e2:	97ba                	add	a5,a5,a4
ffffffffc02009e4:	439c                	lw	a5,0(a5)
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ea:	00002517          	auipc	a0,0x2
ffffffffc02009ee:	c9650513          	addi	a0,a0,-874 # ffffffffc0202680 <etext+0x7c8>
ffffffffc02009f2:	ee4ff06f          	j	ffffffffc02000d6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f6:	00002517          	auipc	a0,0x2
ffffffffc02009fa:	c6a50513          	addi	a0,a0,-918 # ffffffffc0202660 <etext+0x7a8>
ffffffffc02009fe:	ed8ff06f          	j	ffffffffc02000d6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a02:	00002517          	auipc	a0,0x2
ffffffffc0200a06:	c1e50513          	addi	a0,a0,-994 # ffffffffc0202620 <etext+0x768>
ffffffffc0200a0a:	eccff06f          	j	ffffffffc02000d6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc0200a0e:	00002517          	auipc	a0,0x2
ffffffffc0200a12:	c9250513          	addi	a0,a0,-878 # ffffffffc02026a0 <etext+0x7e8>
ffffffffc0200a16:	ec0ff06f          	j	ffffffffc02000d6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a1a:	1141                	addi	sp,sp,-16
ffffffffc0200a1c:	e406                	sd	ra,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            // cprintf("Supervisor timer interrupt\n");
            clock_set_next_event();
ffffffffc0200a1e:	9fbff0ef          	jal	ffffffffc0200418 <clock_set_next_event>
            static int ticks = 0;
            static int num = 0;
            ticks++;
ffffffffc0200a22:	00006597          	auipc	a1,0x6
ffffffffc0200a26:	a425a583          	lw	a1,-1470(a1) # ffffffffc0206464 <ticks.1>
            if (ticks == 100){
ffffffffc0200a2a:	06400793          	li	a5,100
            ticks++;
ffffffffc0200a2e:	2585                	addiw	a1,a1,1
ffffffffc0200a30:	00006717          	auipc	a4,0x6
ffffffffc0200a34:	a2b72a23          	sw	a1,-1484(a4) # ffffffffc0206464 <ticks.1>
            if (ticks == 100){
ffffffffc0200a38:	02f58963          	beq	a1,a5,ffffffffc0200a6a <interrupt_handler+0xa0>
                cprintf("%d ticks\n", ticks);
                num++;
                ticks=0;
            }
            if (num == 10){
ffffffffc0200a3c:	00006797          	auipc	a5,0x6
ffffffffc0200a40:	a247a783          	lw	a5,-1500(a5) # ffffffffc0206460 <num.0>
ffffffffc0200a44:	4729                	li	a4,10
ffffffffc0200a46:	04e78663          	beq	a5,a4,ffffffffc0200a92 <interrupt_handler+0xc8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a4a:	60a2                	ld	ra,8(sp)
ffffffffc0200a4c:	0141                	addi	sp,sp,16
ffffffffc0200a4e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a50:	00002517          	auipc	a0,0x2
ffffffffc0200a54:	c7850513          	addi	a0,a0,-904 # ffffffffc02026c8 <etext+0x810>
ffffffffc0200a58:	e7eff06f          	j	ffffffffc02000d6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a5c:	00002517          	auipc	a0,0x2
ffffffffc0200a60:	be450513          	addi	a0,a0,-1052 # ffffffffc0202640 <etext+0x788>
ffffffffc0200a64:	e72ff06f          	j	ffffffffc02000d6 <cprintf>
            print_trapframe(tf);
ffffffffc0200a68:	b701                	j	ffffffffc0200968 <print_trapframe>
                cprintf("%d ticks\n", ticks);
ffffffffc0200a6a:	00002517          	auipc	a0,0x2
ffffffffc0200a6e:	c4e50513          	addi	a0,a0,-946 # ffffffffc02026b8 <etext+0x800>
ffffffffc0200a72:	e64ff0ef          	jal	ffffffffc02000d6 <cprintf>
                num++;
ffffffffc0200a76:	00006797          	auipc	a5,0x6
ffffffffc0200a7a:	9ea7a783          	lw	a5,-1558(a5) # ffffffffc0206460 <num.0>
                ticks=0;
ffffffffc0200a7e:	00006717          	auipc	a4,0x6
ffffffffc0200a82:	9e072323          	sw	zero,-1562(a4) # ffffffffc0206464 <ticks.1>
                num++;
ffffffffc0200a86:	2785                	addiw	a5,a5,1
ffffffffc0200a88:	00006717          	auipc	a4,0x6
ffffffffc0200a8c:	9cf72c23          	sw	a5,-1576(a4) # ffffffffc0206460 <num.0>
                ticks=0;
ffffffffc0200a90:	bf55                	j	ffffffffc0200a44 <interrupt_handler+0x7a>
}
ffffffffc0200a92:	60a2                	ld	ra,8(sp)
ffffffffc0200a94:	0141                	addi	sp,sp,16
                sbi_shutdown();
ffffffffc0200a96:	3540106f          	j	ffffffffc0201dea <sbi_shutdown>

ffffffffc0200a9a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a9a:	11853783          	ld	a5,280(a0)
ffffffffc0200a9e:	0007c763          	bltz	a5,ffffffffc0200aac <trap+0x12>
    switch (tf->cause) {
ffffffffc0200aa2:	472d                	li	a4,11
ffffffffc0200aa4:	00f76363          	bltu	a4,a5,ffffffffc0200aaa <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200aa8:	8082                	ret
            print_trapframe(tf);
ffffffffc0200aaa:	bd7d                	j	ffffffffc0200968 <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200aac:	bf39                	j	ffffffffc02009ca <interrupt_handler>
	...

ffffffffc0200ab0 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200ab0:	14011073          	csrw	sscratch,sp
ffffffffc0200ab4:	712d                	addi	sp,sp,-288
ffffffffc0200ab6:	e002                	sd	zero,0(sp)
ffffffffc0200ab8:	e406                	sd	ra,8(sp)
ffffffffc0200aba:	ec0e                	sd	gp,24(sp)
ffffffffc0200abc:	f012                	sd	tp,32(sp)
ffffffffc0200abe:	f416                	sd	t0,40(sp)
ffffffffc0200ac0:	f81a                	sd	t1,48(sp)
ffffffffc0200ac2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ac4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ac6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ac8:	e8aa                	sd	a0,80(sp)
ffffffffc0200aca:	ecae                	sd	a1,88(sp)
ffffffffc0200acc:	f0b2                	sd	a2,96(sp)
ffffffffc0200ace:	f4b6                	sd	a3,104(sp)
ffffffffc0200ad0:	f8ba                	sd	a4,112(sp)
ffffffffc0200ad2:	fcbe                	sd	a5,120(sp)
ffffffffc0200ad4:	e142                	sd	a6,128(sp)
ffffffffc0200ad6:	e546                	sd	a7,136(sp)
ffffffffc0200ad8:	e94a                	sd	s2,144(sp)
ffffffffc0200ada:	ed4e                	sd	s3,152(sp)
ffffffffc0200adc:	f152                	sd	s4,160(sp)
ffffffffc0200ade:	f556                	sd	s5,168(sp)
ffffffffc0200ae0:	f95a                	sd	s6,176(sp)
ffffffffc0200ae2:	fd5e                	sd	s7,184(sp)
ffffffffc0200ae4:	e1e2                	sd	s8,192(sp)
ffffffffc0200ae6:	e5e6                	sd	s9,200(sp)
ffffffffc0200ae8:	e9ea                	sd	s10,208(sp)
ffffffffc0200aea:	edee                	sd	s11,216(sp)
ffffffffc0200aec:	f1f2                	sd	t3,224(sp)
ffffffffc0200aee:	f5f6                	sd	t4,232(sp)
ffffffffc0200af0:	f9fa                	sd	t5,240(sp)
ffffffffc0200af2:	fdfe                	sd	t6,248(sp)
ffffffffc0200af4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200af8:	100024f3          	csrr	s1,sstatus
ffffffffc0200afc:	14102973          	csrr	s2,sepc
ffffffffc0200b00:	143029f3          	csrr	s3,stval
ffffffffc0200b04:	14202a73          	csrr	s4,scause
ffffffffc0200b08:	e822                	sd	s0,16(sp)
ffffffffc0200b0a:	e226                	sd	s1,256(sp)
ffffffffc0200b0c:	e64a                	sd	s2,264(sp)
ffffffffc0200b0e:	ea4e                	sd	s3,272(sp)
ffffffffc0200b10:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b12:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b14:	f87ff0ef          	jal	ffffffffc0200a9a <trap>

ffffffffc0200b18 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b18:	6492                	ld	s1,256(sp)
ffffffffc0200b1a:	6932                	ld	s2,264(sp)
ffffffffc0200b1c:	10049073          	csrw	sstatus,s1
ffffffffc0200b20:	14191073          	csrw	sepc,s2
ffffffffc0200b24:	60a2                	ld	ra,8(sp)
ffffffffc0200b26:	61e2                	ld	gp,24(sp)
ffffffffc0200b28:	7202                	ld	tp,32(sp)
ffffffffc0200b2a:	72a2                	ld	t0,40(sp)
ffffffffc0200b2c:	7342                	ld	t1,48(sp)
ffffffffc0200b2e:	73e2                	ld	t2,56(sp)
ffffffffc0200b30:	6406                	ld	s0,64(sp)
ffffffffc0200b32:	64a6                	ld	s1,72(sp)
ffffffffc0200b34:	6546                	ld	a0,80(sp)
ffffffffc0200b36:	65e6                	ld	a1,88(sp)
ffffffffc0200b38:	7606                	ld	a2,96(sp)
ffffffffc0200b3a:	76a6                	ld	a3,104(sp)
ffffffffc0200b3c:	7746                	ld	a4,112(sp)
ffffffffc0200b3e:	77e6                	ld	a5,120(sp)
ffffffffc0200b40:	680a                	ld	a6,128(sp)
ffffffffc0200b42:	68aa                	ld	a7,136(sp)
ffffffffc0200b44:	694a                	ld	s2,144(sp)
ffffffffc0200b46:	69ea                	ld	s3,152(sp)
ffffffffc0200b48:	7a0a                	ld	s4,160(sp)
ffffffffc0200b4a:	7aaa                	ld	s5,168(sp)
ffffffffc0200b4c:	7b4a                	ld	s6,176(sp)
ffffffffc0200b4e:	7bea                	ld	s7,184(sp)
ffffffffc0200b50:	6c0e                	ld	s8,192(sp)
ffffffffc0200b52:	6cae                	ld	s9,200(sp)
ffffffffc0200b54:	6d4e                	ld	s10,208(sp)
ffffffffc0200b56:	6dee                	ld	s11,216(sp)
ffffffffc0200b58:	7e0e                	ld	t3,224(sp)
ffffffffc0200b5a:	7eae                	ld	t4,232(sp)
ffffffffc0200b5c:	7f4e                	ld	t5,240(sp)
ffffffffc0200b5e:	7fee                	ld	t6,248(sp)
ffffffffc0200b60:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200b62:	10200073          	sret

ffffffffc0200b66 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b66:	00005797          	auipc	a5,0x5
ffffffffc0200b6a:	4c278793          	addi	a5,a5,1218 # ffffffffc0206028 <free_area>
ffffffffc0200b6e:	e79c                	sd	a5,8(a5)
ffffffffc0200b70:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b72:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b76:	8082                	ret

ffffffffc0200b78 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b78:	00005517          	auipc	a0,0x5
ffffffffc0200b7c:	4c056503          	lwu	a0,1216(a0) # ffffffffc0206038 <free_area+0x10>
ffffffffc0200b80:	8082                	ret

ffffffffc0200b82 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b82:	711d                	addi	sp,sp,-96
ffffffffc0200b84:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b86:	00005917          	auipc	s2,0x5
ffffffffc0200b8a:	4a290913          	addi	s2,s2,1186 # ffffffffc0206028 <free_area>
ffffffffc0200b8e:	00893783          	ld	a5,8(s2)
ffffffffc0200b92:	ec86                	sd	ra,88(sp)
ffffffffc0200b94:	e8a2                	sd	s0,80(sp)
ffffffffc0200b96:	e4a6                	sd	s1,72(sp)
ffffffffc0200b98:	fc4e                	sd	s3,56(sp)
ffffffffc0200b9a:	f852                	sd	s4,48(sp)
ffffffffc0200b9c:	f456                	sd	s5,40(sp)
ffffffffc0200b9e:	f05a                	sd	s6,32(sp)
ffffffffc0200ba0:	ec5e                	sd	s7,24(sp)
ffffffffc0200ba2:	e862                	sd	s8,16(sp)
ffffffffc0200ba4:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ba6:	31278b63          	beq	a5,s2,ffffffffc0200ebc <default_check+0x33a>
    int count = 0, total = 0;
ffffffffc0200baa:	4401                	li	s0,0
ffffffffc0200bac:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bae:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bb2:	8b09                	andi	a4,a4,2
ffffffffc0200bb4:	30070863          	beqz	a4,ffffffffc0200ec4 <default_check+0x342>
        count ++, total += p->property;
ffffffffc0200bb8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bbc:	679c                	ld	a5,8(a5)
ffffffffc0200bbe:	2485                	addiw	s1,s1,1
ffffffffc0200bc0:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bc2:	ff2796e3          	bne	a5,s2,ffffffffc0200bae <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200bc6:	89a2                	mv	s3,s0
ffffffffc0200bc8:	33f000ef          	jal	ffffffffc0201706 <nr_free_pages>
ffffffffc0200bcc:	75351c63          	bne	a0,s3,ffffffffc0201324 <default_check+0x7a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bd0:	4505                	li	a0,1
ffffffffc0200bd2:	2c3000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200bd6:	8aaa                	mv	s5,a0
ffffffffc0200bd8:	48050663          	beqz	a0,ffffffffc0201064 <default_check+0x4e2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bdc:	4505                	li	a0,1
ffffffffc0200bde:	2b7000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200be2:	89aa                	mv	s3,a0
ffffffffc0200be4:	76050063          	beqz	a0,ffffffffc0201344 <default_check+0x7c2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200be8:	4505                	li	a0,1
ffffffffc0200bea:	2ab000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200bee:	8a2a                	mv	s4,a0
ffffffffc0200bf0:	4e050a63          	beqz	a0,ffffffffc02010e4 <default_check+0x562>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bf4:	40aa87b3          	sub	a5,s5,a0
ffffffffc0200bf8:	40a98733          	sub	a4,s3,a0
ffffffffc0200bfc:	0017b793          	seqz	a5,a5
ffffffffc0200c00:	00173713          	seqz	a4,a4
ffffffffc0200c04:	8fd9                	or	a5,a5,a4
ffffffffc0200c06:	32079f63          	bnez	a5,ffffffffc0200f44 <default_check+0x3c2>
ffffffffc0200c0a:	333a8d63          	beq	s5,s3,ffffffffc0200f44 <default_check+0x3c2>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c0e:	000aa783          	lw	a5,0(s5)
ffffffffc0200c12:	2c079963          	bnez	a5,ffffffffc0200ee4 <default_check+0x362>
ffffffffc0200c16:	0009a783          	lw	a5,0(s3)
ffffffffc0200c1a:	2c079563          	bnez	a5,ffffffffc0200ee4 <default_check+0x362>
ffffffffc0200c1e:	411c                	lw	a5,0(a0)
ffffffffc0200c20:	2c079263          	bnez	a5,ffffffffc0200ee4 <default_check+0x362>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c24:	00006797          	auipc	a5,0x6
ffffffffc0200c28:	86c7b783          	ld	a5,-1940(a5) # ffffffffc0206490 <pages>
ffffffffc0200c2c:	ccccd737          	lui	a4,0xccccd
ffffffffc0200c30:	ccd70713          	addi	a4,a4,-819 # ffffffffcccccccd <end+0xcac682d>
ffffffffc0200c34:	02071693          	slli	a3,a4,0x20
ffffffffc0200c38:	96ba                	add	a3,a3,a4
ffffffffc0200c3a:	40fa8733          	sub	a4,s5,a5
ffffffffc0200c3e:	870d                	srai	a4,a4,0x3
ffffffffc0200c40:	02d70733          	mul	a4,a4,a3
ffffffffc0200c44:	00002517          	auipc	a0,0x2
ffffffffc0200c48:	2a453503          	ld	a0,676(a0) # ffffffffc0202ee8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c4c:	00006697          	auipc	a3,0x6
ffffffffc0200c50:	83c6b683          	ld	a3,-1988(a3) # ffffffffc0206488 <npage>
ffffffffc0200c54:	06b2                	slli	a3,a3,0xc
ffffffffc0200c56:	972a                	add	a4,a4,a0

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c58:	0732                	slli	a4,a4,0xc
ffffffffc0200c5a:	2cd77563          	bgeu	a4,a3,ffffffffc0200f24 <default_check+0x3a2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c5e:	ccccd5b7          	lui	a1,0xccccd
ffffffffc0200c62:	ccd58593          	addi	a1,a1,-819 # ffffffffcccccccd <end+0xcac682d>
ffffffffc0200c66:	02059613          	slli	a2,a1,0x20
ffffffffc0200c6a:	40f98733          	sub	a4,s3,a5
ffffffffc0200c6e:	962e                	add	a2,a2,a1
ffffffffc0200c70:	870d                	srai	a4,a4,0x3
ffffffffc0200c72:	02c70733          	mul	a4,a4,a2
ffffffffc0200c76:	972a                	add	a4,a4,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c78:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c7a:	4ed77563          	bgeu	a4,a3,ffffffffc0201164 <default_check+0x5e2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c7e:	40fa07b3          	sub	a5,s4,a5
ffffffffc0200c82:	878d                	srai	a5,a5,0x3
ffffffffc0200c84:	02c787b3          	mul	a5,a5,a2
ffffffffc0200c88:	97aa                	add	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c8a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c8c:	32d7fc63          	bgeu	a5,a3,ffffffffc0200fc4 <default_check+0x442>
    assert(alloc_page() == NULL);
ffffffffc0200c90:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c92:	00093c03          	ld	s8,0(s2)
ffffffffc0200c96:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c9a:	00005b17          	auipc	s6,0x5
ffffffffc0200c9e:	39eb2b03          	lw	s6,926(s6) # ffffffffc0206038 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0200ca2:	01293023          	sd	s2,0(s2)
ffffffffc0200ca6:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0200caa:	00005797          	auipc	a5,0x5
ffffffffc0200cae:	3807a723          	sw	zero,910(a5) # ffffffffc0206038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200cb2:	1e3000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200cb6:	2e051763          	bnez	a0,ffffffffc0200fa4 <default_check+0x422>
    free_page(p0);
ffffffffc0200cba:	8556                	mv	a0,s5
ffffffffc0200cbc:	4585                	li	a1,1
ffffffffc0200cbe:	211000ef          	jal	ffffffffc02016ce <free_pages>
    free_page(p1);
ffffffffc0200cc2:	854e                	mv	a0,s3
ffffffffc0200cc4:	4585                	li	a1,1
ffffffffc0200cc6:	209000ef          	jal	ffffffffc02016ce <free_pages>
    free_page(p2);
ffffffffc0200cca:	8552                	mv	a0,s4
ffffffffc0200ccc:	4585                	li	a1,1
ffffffffc0200cce:	201000ef          	jal	ffffffffc02016ce <free_pages>
    assert(nr_free == 3);
ffffffffc0200cd2:	00005717          	auipc	a4,0x5
ffffffffc0200cd6:	36672703          	lw	a4,870(a4) # ffffffffc0206038 <free_area+0x10>
ffffffffc0200cda:	478d                	li	a5,3
ffffffffc0200cdc:	2af71463          	bne	a4,a5,ffffffffc0200f84 <default_check+0x402>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ce0:	4505                	li	a0,1
ffffffffc0200ce2:	1b3000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200ce6:	89aa                	mv	s3,a0
ffffffffc0200ce8:	26050e63          	beqz	a0,ffffffffc0200f64 <default_check+0x3e2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cec:	4505                	li	a0,1
ffffffffc0200cee:	1a7000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200cf2:	8aaa                	mv	s5,a0
ffffffffc0200cf4:	3c050863          	beqz	a0,ffffffffc02010c4 <default_check+0x542>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cf8:	4505                	li	a0,1
ffffffffc0200cfa:	19b000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200cfe:	8a2a                	mv	s4,a0
ffffffffc0200d00:	3a050263          	beqz	a0,ffffffffc02010a4 <default_check+0x522>
    assert(alloc_page() == NULL);
ffffffffc0200d04:	4505                	li	a0,1
ffffffffc0200d06:	18f000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200d0a:	36051d63          	bnez	a0,ffffffffc0201084 <default_check+0x502>
    free_page(p0);
ffffffffc0200d0e:	4585                	li	a1,1
ffffffffc0200d10:	854e                	mv	a0,s3
ffffffffc0200d12:	1bd000ef          	jal	ffffffffc02016ce <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d16:	00893783          	ld	a5,8(s2)
ffffffffc0200d1a:	1f278563          	beq	a5,s2,ffffffffc0200f04 <default_check+0x382>
    assert((p = alloc_page()) == p0);
ffffffffc0200d1e:	4505                	li	a0,1
ffffffffc0200d20:	175000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200d24:	8caa                	mv	s9,a0
ffffffffc0200d26:	30a99f63          	bne	s3,a0,ffffffffc0201044 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200d2a:	4505                	li	a0,1
ffffffffc0200d2c:	169000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200d30:	2e051a63          	bnez	a0,ffffffffc0201024 <default_check+0x4a2>
    assert(nr_free == 0);
ffffffffc0200d34:	00005797          	auipc	a5,0x5
ffffffffc0200d38:	3047a783          	lw	a5,772(a5) # ffffffffc0206038 <free_area+0x10>
ffffffffc0200d3c:	2c079463          	bnez	a5,ffffffffc0201004 <default_check+0x482>
    free_page(p);
ffffffffc0200d40:	8566                	mv	a0,s9
ffffffffc0200d42:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d44:	01893023          	sd	s8,0(s2)
ffffffffc0200d48:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0200d4c:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0200d50:	17f000ef          	jal	ffffffffc02016ce <free_pages>
    free_page(p1);
ffffffffc0200d54:	8556                	mv	a0,s5
ffffffffc0200d56:	4585                	li	a1,1
ffffffffc0200d58:	177000ef          	jal	ffffffffc02016ce <free_pages>
    free_page(p2);
ffffffffc0200d5c:	8552                	mv	a0,s4
ffffffffc0200d5e:	4585                	li	a1,1
ffffffffc0200d60:	16f000ef          	jal	ffffffffc02016ce <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d64:	4515                	li	a0,5
ffffffffc0200d66:	12f000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200d6a:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d6c:	26050c63          	beqz	a0,ffffffffc0200fe4 <default_check+0x462>
ffffffffc0200d70:	651c                	ld	a5,8(a0)
ffffffffc0200d72:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d74:	8b85                	andi	a5,a5,1
ffffffffc0200d76:	54079763          	bnez	a5,ffffffffc02012c4 <default_check+0x742>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d7a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d7c:	00093b83          	ld	s7,0(s2)
ffffffffc0200d80:	00893b03          	ld	s6,8(s2)
ffffffffc0200d84:	01293023          	sd	s2,0(s2)
ffffffffc0200d88:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0200d8c:	109000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200d90:	50051a63          	bnez	a0,ffffffffc02012a4 <default_check+0x722>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d94:	05098a13          	addi	s4,s3,80
ffffffffc0200d98:	8552                	mv	a0,s4
ffffffffc0200d9a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d9c:	00005c17          	auipc	s8,0x5
ffffffffc0200da0:	29cc2c03          	lw	s8,668(s8) # ffffffffc0206038 <free_area+0x10>
    nr_free = 0;
ffffffffc0200da4:	00005797          	auipc	a5,0x5
ffffffffc0200da8:	2807aa23          	sw	zero,660(a5) # ffffffffc0206038 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200dac:	123000ef          	jal	ffffffffc02016ce <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200db0:	4511                	li	a0,4
ffffffffc0200db2:	0e3000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200db6:	4c051763          	bnez	a0,ffffffffc0201284 <default_check+0x702>
ffffffffc0200dba:	0589b783          	ld	a5,88(s3)
ffffffffc0200dbe:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200dc0:	8b85                	andi	a5,a5,1
ffffffffc0200dc2:	4a078163          	beqz	a5,ffffffffc0201264 <default_check+0x6e2>
ffffffffc0200dc6:	0609a503          	lw	a0,96(s3)
ffffffffc0200dca:	478d                	li	a5,3
ffffffffc0200dcc:	48f51c63          	bne	a0,a5,ffffffffc0201264 <default_check+0x6e2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200dd0:	0c5000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200dd4:	8aaa                	mv	s5,a0
ffffffffc0200dd6:	46050763          	beqz	a0,ffffffffc0201244 <default_check+0x6c2>
    assert(alloc_page() == NULL);
ffffffffc0200dda:	4505                	li	a0,1
ffffffffc0200ddc:	0b9000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200de0:	44051263          	bnez	a0,ffffffffc0201224 <default_check+0x6a2>
    assert(p0 + 2 == p1);
ffffffffc0200de4:	435a1063          	bne	s4,s5,ffffffffc0201204 <default_check+0x682>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200de8:	4585                	li	a1,1
ffffffffc0200dea:	854e                	mv	a0,s3
ffffffffc0200dec:	0e3000ef          	jal	ffffffffc02016ce <free_pages>
    free_pages(p1, 3);
ffffffffc0200df0:	8552                	mv	a0,s4
ffffffffc0200df2:	458d                	li	a1,3
ffffffffc0200df4:	0db000ef          	jal	ffffffffc02016ce <free_pages>
ffffffffc0200df8:	0089b783          	ld	a5,8(s3)
ffffffffc0200dfc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200dfe:	8b85                	andi	a5,a5,1
ffffffffc0200e00:	3e078263          	beqz	a5,ffffffffc02011e4 <default_check+0x662>
ffffffffc0200e04:	0109aa83          	lw	s5,16(s3)
ffffffffc0200e08:	4785                	li	a5,1
ffffffffc0200e0a:	3cfa9d63          	bne	s5,a5,ffffffffc02011e4 <default_check+0x662>
ffffffffc0200e0e:	008a3783          	ld	a5,8(s4)
ffffffffc0200e12:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e14:	8b85                	andi	a5,a5,1
ffffffffc0200e16:	3a078763          	beqz	a5,ffffffffc02011c4 <default_check+0x642>
ffffffffc0200e1a:	010a2703          	lw	a4,16(s4)
ffffffffc0200e1e:	478d                	li	a5,3
ffffffffc0200e20:	3af71263          	bne	a4,a5,ffffffffc02011c4 <default_check+0x642>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e24:	8556                	mv	a0,s5
ffffffffc0200e26:	06f000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200e2a:	36a99d63          	bne	s3,a0,ffffffffc02011a4 <default_check+0x622>
    free_page(p0);
ffffffffc0200e2e:	85d6                	mv	a1,s5
ffffffffc0200e30:	09f000ef          	jal	ffffffffc02016ce <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e34:	4509                	li	a0,2
ffffffffc0200e36:	05f000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200e3a:	34aa1563          	bne	s4,a0,ffffffffc0201184 <default_check+0x602>

    free_pages(p0, 2);
ffffffffc0200e3e:	4589                	li	a1,2
ffffffffc0200e40:	08f000ef          	jal	ffffffffc02016ce <free_pages>
    free_page(p2);
ffffffffc0200e44:	02898513          	addi	a0,s3,40
ffffffffc0200e48:	85d6                	mv	a1,s5
ffffffffc0200e4a:	085000ef          	jal	ffffffffc02016ce <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e4e:	4515                	li	a0,5
ffffffffc0200e50:	045000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200e54:	89aa                	mv	s3,a0
ffffffffc0200e56:	48050763          	beqz	a0,ffffffffc02012e4 <default_check+0x762>
    assert(alloc_page() == NULL);
ffffffffc0200e5a:	8556                	mv	a0,s5
ffffffffc0200e5c:	039000ef          	jal	ffffffffc0201694 <alloc_pages>
ffffffffc0200e60:	2e051263          	bnez	a0,ffffffffc0201144 <default_check+0x5c2>

    assert(nr_free == 0);
ffffffffc0200e64:	00005797          	auipc	a5,0x5
ffffffffc0200e68:	1d47a783          	lw	a5,468(a5) # ffffffffc0206038 <free_area+0x10>
ffffffffc0200e6c:	2a079c63          	bnez	a5,ffffffffc0201124 <default_check+0x5a2>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e70:	854e                	mv	a0,s3
ffffffffc0200e72:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0200e74:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0200e78:	01793023          	sd	s7,0(s2)
ffffffffc0200e7c:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc0200e80:	04f000ef          	jal	ffffffffc02016ce <free_pages>
    return listelm->next;
ffffffffc0200e84:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e88:	01278963          	beq	a5,s2,ffffffffc0200e9a <default_check+0x318>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e8c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e90:	679c                	ld	a5,8(a5)
ffffffffc0200e92:	34fd                	addiw	s1,s1,-1
ffffffffc0200e94:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e96:	ff279be3          	bne	a5,s2,ffffffffc0200e8c <default_check+0x30a>
    }
    assert(count == 0);
ffffffffc0200e9a:	26049563          	bnez	s1,ffffffffc0201104 <default_check+0x582>
    assert(total == 0);
ffffffffc0200e9e:	46041363          	bnez	s0,ffffffffc0201304 <default_check+0x782>
}
ffffffffc0200ea2:	60e6                	ld	ra,88(sp)
ffffffffc0200ea4:	6446                	ld	s0,80(sp)
ffffffffc0200ea6:	64a6                	ld	s1,72(sp)
ffffffffc0200ea8:	6906                	ld	s2,64(sp)
ffffffffc0200eaa:	79e2                	ld	s3,56(sp)
ffffffffc0200eac:	7a42                	ld	s4,48(sp)
ffffffffc0200eae:	7aa2                	ld	s5,40(sp)
ffffffffc0200eb0:	7b02                	ld	s6,32(sp)
ffffffffc0200eb2:	6be2                	ld	s7,24(sp)
ffffffffc0200eb4:	6c42                	ld	s8,16(sp)
ffffffffc0200eb6:	6ca2                	ld	s9,8(sp)
ffffffffc0200eb8:	6125                	addi	sp,sp,96
ffffffffc0200eba:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ebc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ebe:	4401                	li	s0,0
ffffffffc0200ec0:	4481                	li	s1,0
ffffffffc0200ec2:	b319                	j	ffffffffc0200bc8 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc0200ec4:	00002697          	auipc	a3,0x2
ffffffffc0200ec8:	82468693          	addi	a3,a3,-2012 # ffffffffc02026e8 <etext+0x830>
ffffffffc0200ecc:	00002617          	auipc	a2,0x2
ffffffffc0200ed0:	82c60613          	addi	a2,a2,-2004 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200ed4:	0f000593          	li	a1,240
ffffffffc0200ed8:	00002517          	auipc	a0,0x2
ffffffffc0200edc:	83850513          	addi	a0,a0,-1992 # ffffffffc0202710 <etext+0x858>
ffffffffc0200ee0:	ca8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ee4:	00002697          	auipc	a3,0x2
ffffffffc0200ee8:	8ec68693          	addi	a3,a3,-1812 # ffffffffc02027d0 <etext+0x918>
ffffffffc0200eec:	00002617          	auipc	a2,0x2
ffffffffc0200ef0:	80c60613          	addi	a2,a2,-2036 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200ef4:	0be00593          	li	a1,190
ffffffffc0200ef8:	00002517          	auipc	a0,0x2
ffffffffc0200efc:	81850513          	addi	a0,a0,-2024 # ffffffffc0202710 <etext+0x858>
ffffffffc0200f00:	c88ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f04:	00002697          	auipc	a3,0x2
ffffffffc0200f08:	99468693          	addi	a3,a3,-1644 # ffffffffc0202898 <etext+0x9e0>
ffffffffc0200f0c:	00001617          	auipc	a2,0x1
ffffffffc0200f10:	7ec60613          	addi	a2,a2,2028 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200f14:	0d900593          	li	a1,217
ffffffffc0200f18:	00001517          	auipc	a0,0x1
ffffffffc0200f1c:	7f850513          	addi	a0,a0,2040 # ffffffffc0202710 <etext+0x858>
ffffffffc0200f20:	c68ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f24:	00002697          	auipc	a3,0x2
ffffffffc0200f28:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0202810 <etext+0x958>
ffffffffc0200f2c:	00001617          	auipc	a2,0x1
ffffffffc0200f30:	7cc60613          	addi	a2,a2,1996 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200f34:	0c000593          	li	a1,192
ffffffffc0200f38:	00001517          	auipc	a0,0x1
ffffffffc0200f3c:	7d850513          	addi	a0,a0,2008 # ffffffffc0202710 <etext+0x858>
ffffffffc0200f40:	c48ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f44:	00002697          	auipc	a3,0x2
ffffffffc0200f48:	86468693          	addi	a3,a3,-1948 # ffffffffc02027a8 <etext+0x8f0>
ffffffffc0200f4c:	00001617          	auipc	a2,0x1
ffffffffc0200f50:	7ac60613          	addi	a2,a2,1964 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200f54:	0bd00593          	li	a1,189
ffffffffc0200f58:	00001517          	auipc	a0,0x1
ffffffffc0200f5c:	7b850513          	addi	a0,a0,1976 # ffffffffc0202710 <etext+0x858>
ffffffffc0200f60:	c28ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f64:	00001697          	auipc	a3,0x1
ffffffffc0200f68:	7e468693          	addi	a3,a3,2020 # ffffffffc0202748 <etext+0x890>
ffffffffc0200f6c:	00001617          	auipc	a2,0x1
ffffffffc0200f70:	78c60613          	addi	a2,a2,1932 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200f74:	0d200593          	li	a1,210
ffffffffc0200f78:	00001517          	auipc	a0,0x1
ffffffffc0200f7c:	79850513          	addi	a0,a0,1944 # ffffffffc0202710 <etext+0x858>
ffffffffc0200f80:	c08ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(nr_free == 3);
ffffffffc0200f84:	00002697          	auipc	a3,0x2
ffffffffc0200f88:	90468693          	addi	a3,a3,-1788 # ffffffffc0202888 <etext+0x9d0>
ffffffffc0200f8c:	00001617          	auipc	a2,0x1
ffffffffc0200f90:	76c60613          	addi	a2,a2,1900 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200f94:	0d000593          	li	a1,208
ffffffffc0200f98:	00001517          	auipc	a0,0x1
ffffffffc0200f9c:	77850513          	addi	a0,a0,1912 # ffffffffc0202710 <etext+0x858>
ffffffffc0200fa0:	be8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa4:	00002697          	auipc	a3,0x2
ffffffffc0200fa8:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0202870 <etext+0x9b8>
ffffffffc0200fac:	00001617          	auipc	a2,0x1
ffffffffc0200fb0:	74c60613          	addi	a2,a2,1868 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200fb4:	0cb00593          	li	a1,203
ffffffffc0200fb8:	00001517          	auipc	a0,0x1
ffffffffc0200fbc:	75850513          	addi	a0,a0,1880 # ffffffffc0202710 <etext+0x858>
ffffffffc0200fc0:	bc8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fc4:	00002697          	auipc	a3,0x2
ffffffffc0200fc8:	88c68693          	addi	a3,a3,-1908 # ffffffffc0202850 <etext+0x998>
ffffffffc0200fcc:	00001617          	auipc	a2,0x1
ffffffffc0200fd0:	72c60613          	addi	a2,a2,1836 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200fd4:	0c200593          	li	a1,194
ffffffffc0200fd8:	00001517          	auipc	a0,0x1
ffffffffc0200fdc:	73850513          	addi	a0,a0,1848 # ffffffffc0202710 <etext+0x858>
ffffffffc0200fe0:	ba8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(p0 != NULL);
ffffffffc0200fe4:	00002697          	auipc	a3,0x2
ffffffffc0200fe8:	8fc68693          	addi	a3,a3,-1796 # ffffffffc02028e0 <etext+0xa28>
ffffffffc0200fec:	00001617          	auipc	a2,0x1
ffffffffc0200ff0:	70c60613          	addi	a2,a2,1804 # ffffffffc02026f8 <etext+0x840>
ffffffffc0200ff4:	0f800593          	li	a1,248
ffffffffc0200ff8:	00001517          	auipc	a0,0x1
ffffffffc0200ffc:	71850513          	addi	a0,a0,1816 # ffffffffc0202710 <etext+0x858>
ffffffffc0201000:	b88ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(nr_free == 0);
ffffffffc0201004:	00002697          	auipc	a3,0x2
ffffffffc0201008:	8cc68693          	addi	a3,a3,-1844 # ffffffffc02028d0 <etext+0xa18>
ffffffffc020100c:	00001617          	auipc	a2,0x1
ffffffffc0201010:	6ec60613          	addi	a2,a2,1772 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201014:	0df00593          	li	a1,223
ffffffffc0201018:	00001517          	auipc	a0,0x1
ffffffffc020101c:	6f850513          	addi	a0,a0,1784 # ffffffffc0202710 <etext+0x858>
ffffffffc0201020:	b68ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201024:	00002697          	auipc	a3,0x2
ffffffffc0201028:	84c68693          	addi	a3,a3,-1972 # ffffffffc0202870 <etext+0x9b8>
ffffffffc020102c:	00001617          	auipc	a2,0x1
ffffffffc0201030:	6cc60613          	addi	a2,a2,1740 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201034:	0dd00593          	li	a1,221
ffffffffc0201038:	00001517          	auipc	a0,0x1
ffffffffc020103c:	6d850513          	addi	a0,a0,1752 # ffffffffc0202710 <etext+0x858>
ffffffffc0201040:	b48ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201044:	00002697          	auipc	a3,0x2
ffffffffc0201048:	86c68693          	addi	a3,a3,-1940 # ffffffffc02028b0 <etext+0x9f8>
ffffffffc020104c:	00001617          	auipc	a2,0x1
ffffffffc0201050:	6ac60613          	addi	a2,a2,1708 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201054:	0dc00593          	li	a1,220
ffffffffc0201058:	00001517          	auipc	a0,0x1
ffffffffc020105c:	6b850513          	addi	a0,a0,1720 # ffffffffc0202710 <etext+0x858>
ffffffffc0201060:	b28ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201064:	00001697          	auipc	a3,0x1
ffffffffc0201068:	6e468693          	addi	a3,a3,1764 # ffffffffc0202748 <etext+0x890>
ffffffffc020106c:	00001617          	auipc	a2,0x1
ffffffffc0201070:	68c60613          	addi	a2,a2,1676 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201074:	0b900593          	li	a1,185
ffffffffc0201078:	00001517          	auipc	a0,0x1
ffffffffc020107c:	69850513          	addi	a0,a0,1688 # ffffffffc0202710 <etext+0x858>
ffffffffc0201080:	b08ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201084:	00001697          	auipc	a3,0x1
ffffffffc0201088:	7ec68693          	addi	a3,a3,2028 # ffffffffc0202870 <etext+0x9b8>
ffffffffc020108c:	00001617          	auipc	a2,0x1
ffffffffc0201090:	66c60613          	addi	a2,a2,1644 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201094:	0d600593          	li	a1,214
ffffffffc0201098:	00001517          	auipc	a0,0x1
ffffffffc020109c:	67850513          	addi	a0,a0,1656 # ffffffffc0202710 <etext+0x858>
ffffffffc02010a0:	ae8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010a4:	00001697          	auipc	a3,0x1
ffffffffc02010a8:	6e468693          	addi	a3,a3,1764 # ffffffffc0202788 <etext+0x8d0>
ffffffffc02010ac:	00001617          	auipc	a2,0x1
ffffffffc02010b0:	64c60613          	addi	a2,a2,1612 # ffffffffc02026f8 <etext+0x840>
ffffffffc02010b4:	0d400593          	li	a1,212
ffffffffc02010b8:	00001517          	auipc	a0,0x1
ffffffffc02010bc:	65850513          	addi	a0,a0,1624 # ffffffffc0202710 <etext+0x858>
ffffffffc02010c0:	ac8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010c4:	00001697          	auipc	a3,0x1
ffffffffc02010c8:	6a468693          	addi	a3,a3,1700 # ffffffffc0202768 <etext+0x8b0>
ffffffffc02010cc:	00001617          	auipc	a2,0x1
ffffffffc02010d0:	62c60613          	addi	a2,a2,1580 # ffffffffc02026f8 <etext+0x840>
ffffffffc02010d4:	0d300593          	li	a1,211
ffffffffc02010d8:	00001517          	auipc	a0,0x1
ffffffffc02010dc:	63850513          	addi	a0,a0,1592 # ffffffffc0202710 <etext+0x858>
ffffffffc02010e0:	aa8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010e4:	00001697          	auipc	a3,0x1
ffffffffc02010e8:	6a468693          	addi	a3,a3,1700 # ffffffffc0202788 <etext+0x8d0>
ffffffffc02010ec:	00001617          	auipc	a2,0x1
ffffffffc02010f0:	60c60613          	addi	a2,a2,1548 # ffffffffc02026f8 <etext+0x840>
ffffffffc02010f4:	0bb00593          	li	a1,187
ffffffffc02010f8:	00001517          	auipc	a0,0x1
ffffffffc02010fc:	61850513          	addi	a0,a0,1560 # ffffffffc0202710 <etext+0x858>
ffffffffc0201100:	a88ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(count == 0);
ffffffffc0201104:	00002697          	auipc	a3,0x2
ffffffffc0201108:	92c68693          	addi	a3,a3,-1748 # ffffffffc0202a30 <etext+0xb78>
ffffffffc020110c:	00001617          	auipc	a2,0x1
ffffffffc0201110:	5ec60613          	addi	a2,a2,1516 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201114:	12500593          	li	a1,293
ffffffffc0201118:	00001517          	auipc	a0,0x1
ffffffffc020111c:	5f850513          	addi	a0,a0,1528 # ffffffffc0202710 <etext+0x858>
ffffffffc0201120:	a68ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(nr_free == 0);
ffffffffc0201124:	00001697          	auipc	a3,0x1
ffffffffc0201128:	7ac68693          	addi	a3,a3,1964 # ffffffffc02028d0 <etext+0xa18>
ffffffffc020112c:	00001617          	auipc	a2,0x1
ffffffffc0201130:	5cc60613          	addi	a2,a2,1484 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201134:	11a00593          	li	a1,282
ffffffffc0201138:	00001517          	auipc	a0,0x1
ffffffffc020113c:	5d850513          	addi	a0,a0,1496 # ffffffffc0202710 <etext+0x858>
ffffffffc0201140:	a48ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201144:	00001697          	auipc	a3,0x1
ffffffffc0201148:	72c68693          	addi	a3,a3,1836 # ffffffffc0202870 <etext+0x9b8>
ffffffffc020114c:	00001617          	auipc	a2,0x1
ffffffffc0201150:	5ac60613          	addi	a2,a2,1452 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201154:	11800593          	li	a1,280
ffffffffc0201158:	00001517          	auipc	a0,0x1
ffffffffc020115c:	5b850513          	addi	a0,a0,1464 # ffffffffc0202710 <etext+0x858>
ffffffffc0201160:	a28ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201164:	00001697          	auipc	a3,0x1
ffffffffc0201168:	6cc68693          	addi	a3,a3,1740 # ffffffffc0202830 <etext+0x978>
ffffffffc020116c:	00001617          	auipc	a2,0x1
ffffffffc0201170:	58c60613          	addi	a2,a2,1420 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201174:	0c100593          	li	a1,193
ffffffffc0201178:	00001517          	auipc	a0,0x1
ffffffffc020117c:	59850513          	addi	a0,a0,1432 # ffffffffc0202710 <etext+0x858>
ffffffffc0201180:	a08ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201184:	00002697          	auipc	a3,0x2
ffffffffc0201188:	86c68693          	addi	a3,a3,-1940 # ffffffffc02029f0 <etext+0xb38>
ffffffffc020118c:	00001617          	auipc	a2,0x1
ffffffffc0201190:	56c60613          	addi	a2,a2,1388 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201194:	11200593          	li	a1,274
ffffffffc0201198:	00001517          	auipc	a0,0x1
ffffffffc020119c:	57850513          	addi	a0,a0,1400 # ffffffffc0202710 <etext+0x858>
ffffffffc02011a0:	9e8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011a4:	00002697          	auipc	a3,0x2
ffffffffc02011a8:	82c68693          	addi	a3,a3,-2004 # ffffffffc02029d0 <etext+0xb18>
ffffffffc02011ac:	00001617          	auipc	a2,0x1
ffffffffc02011b0:	54c60613          	addi	a2,a2,1356 # ffffffffc02026f8 <etext+0x840>
ffffffffc02011b4:	11000593          	li	a1,272
ffffffffc02011b8:	00001517          	auipc	a0,0x1
ffffffffc02011bc:	55850513          	addi	a0,a0,1368 # ffffffffc0202710 <etext+0x858>
ffffffffc02011c0:	9c8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011c4:	00001697          	auipc	a3,0x1
ffffffffc02011c8:	7e468693          	addi	a3,a3,2020 # ffffffffc02029a8 <etext+0xaf0>
ffffffffc02011cc:	00001617          	auipc	a2,0x1
ffffffffc02011d0:	52c60613          	addi	a2,a2,1324 # ffffffffc02026f8 <etext+0x840>
ffffffffc02011d4:	10e00593          	li	a1,270
ffffffffc02011d8:	00001517          	auipc	a0,0x1
ffffffffc02011dc:	53850513          	addi	a0,a0,1336 # ffffffffc0202710 <etext+0x858>
ffffffffc02011e0:	9a8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011e4:	00001697          	auipc	a3,0x1
ffffffffc02011e8:	79c68693          	addi	a3,a3,1948 # ffffffffc0202980 <etext+0xac8>
ffffffffc02011ec:	00001617          	auipc	a2,0x1
ffffffffc02011f0:	50c60613          	addi	a2,a2,1292 # ffffffffc02026f8 <etext+0x840>
ffffffffc02011f4:	10d00593          	li	a1,269
ffffffffc02011f8:	00001517          	auipc	a0,0x1
ffffffffc02011fc:	51850513          	addi	a0,a0,1304 # ffffffffc0202710 <etext+0x858>
ffffffffc0201200:	988ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201204:	00001697          	auipc	a3,0x1
ffffffffc0201208:	76c68693          	addi	a3,a3,1900 # ffffffffc0202970 <etext+0xab8>
ffffffffc020120c:	00001617          	auipc	a2,0x1
ffffffffc0201210:	4ec60613          	addi	a2,a2,1260 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201214:	10800593          	li	a1,264
ffffffffc0201218:	00001517          	auipc	a0,0x1
ffffffffc020121c:	4f850513          	addi	a0,a0,1272 # ffffffffc0202710 <etext+0x858>
ffffffffc0201220:	968ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201224:	00001697          	auipc	a3,0x1
ffffffffc0201228:	64c68693          	addi	a3,a3,1612 # ffffffffc0202870 <etext+0x9b8>
ffffffffc020122c:	00001617          	auipc	a2,0x1
ffffffffc0201230:	4cc60613          	addi	a2,a2,1228 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201234:	10700593          	li	a1,263
ffffffffc0201238:	00001517          	auipc	a0,0x1
ffffffffc020123c:	4d850513          	addi	a0,a0,1240 # ffffffffc0202710 <etext+0x858>
ffffffffc0201240:	948ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201244:	00001697          	auipc	a3,0x1
ffffffffc0201248:	70c68693          	addi	a3,a3,1804 # ffffffffc0202950 <etext+0xa98>
ffffffffc020124c:	00001617          	auipc	a2,0x1
ffffffffc0201250:	4ac60613          	addi	a2,a2,1196 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201254:	10600593          	li	a1,262
ffffffffc0201258:	00001517          	auipc	a0,0x1
ffffffffc020125c:	4b850513          	addi	a0,a0,1208 # ffffffffc0202710 <etext+0x858>
ffffffffc0201260:	928ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201264:	00001697          	auipc	a3,0x1
ffffffffc0201268:	6bc68693          	addi	a3,a3,1724 # ffffffffc0202920 <etext+0xa68>
ffffffffc020126c:	00001617          	auipc	a2,0x1
ffffffffc0201270:	48c60613          	addi	a2,a2,1164 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201274:	10500593          	li	a1,261
ffffffffc0201278:	00001517          	auipc	a0,0x1
ffffffffc020127c:	49850513          	addi	a0,a0,1176 # ffffffffc0202710 <etext+0x858>
ffffffffc0201280:	908ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201284:	00001697          	auipc	a3,0x1
ffffffffc0201288:	68468693          	addi	a3,a3,1668 # ffffffffc0202908 <etext+0xa50>
ffffffffc020128c:	00001617          	auipc	a2,0x1
ffffffffc0201290:	46c60613          	addi	a2,a2,1132 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201294:	10400593          	li	a1,260
ffffffffc0201298:	00001517          	auipc	a0,0x1
ffffffffc020129c:	47850513          	addi	a0,a0,1144 # ffffffffc0202710 <etext+0x858>
ffffffffc02012a0:	8e8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012a4:	00001697          	auipc	a3,0x1
ffffffffc02012a8:	5cc68693          	addi	a3,a3,1484 # ffffffffc0202870 <etext+0x9b8>
ffffffffc02012ac:	00001617          	auipc	a2,0x1
ffffffffc02012b0:	44c60613          	addi	a2,a2,1100 # ffffffffc02026f8 <etext+0x840>
ffffffffc02012b4:	0fe00593          	li	a1,254
ffffffffc02012b8:	00001517          	auipc	a0,0x1
ffffffffc02012bc:	45850513          	addi	a0,a0,1112 # ffffffffc0202710 <etext+0x858>
ffffffffc02012c0:	8c8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(!PageProperty(p0));
ffffffffc02012c4:	00001697          	auipc	a3,0x1
ffffffffc02012c8:	62c68693          	addi	a3,a3,1580 # ffffffffc02028f0 <etext+0xa38>
ffffffffc02012cc:	00001617          	auipc	a2,0x1
ffffffffc02012d0:	42c60613          	addi	a2,a2,1068 # ffffffffc02026f8 <etext+0x840>
ffffffffc02012d4:	0f900593          	li	a1,249
ffffffffc02012d8:	00001517          	auipc	a0,0x1
ffffffffc02012dc:	43850513          	addi	a0,a0,1080 # ffffffffc0202710 <etext+0x858>
ffffffffc02012e0:	8a8ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012e4:	00001697          	auipc	a3,0x1
ffffffffc02012e8:	72c68693          	addi	a3,a3,1836 # ffffffffc0202a10 <etext+0xb58>
ffffffffc02012ec:	00001617          	auipc	a2,0x1
ffffffffc02012f0:	40c60613          	addi	a2,a2,1036 # ffffffffc02026f8 <etext+0x840>
ffffffffc02012f4:	11700593          	li	a1,279
ffffffffc02012f8:	00001517          	auipc	a0,0x1
ffffffffc02012fc:	41850513          	addi	a0,a0,1048 # ffffffffc0202710 <etext+0x858>
ffffffffc0201300:	888ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(total == 0);
ffffffffc0201304:	00001697          	auipc	a3,0x1
ffffffffc0201308:	73c68693          	addi	a3,a3,1852 # ffffffffc0202a40 <etext+0xb88>
ffffffffc020130c:	00001617          	auipc	a2,0x1
ffffffffc0201310:	3ec60613          	addi	a2,a2,1004 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201314:	12600593          	li	a1,294
ffffffffc0201318:	00001517          	auipc	a0,0x1
ffffffffc020131c:	3f850513          	addi	a0,a0,1016 # ffffffffc0202710 <etext+0x858>
ffffffffc0201320:	868ff0ef          	jal	ffffffffc0200388 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201324:	00001697          	auipc	a3,0x1
ffffffffc0201328:	40468693          	addi	a3,a3,1028 # ffffffffc0202728 <etext+0x870>
ffffffffc020132c:	00001617          	auipc	a2,0x1
ffffffffc0201330:	3cc60613          	addi	a2,a2,972 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201334:	0f300593          	li	a1,243
ffffffffc0201338:	00001517          	auipc	a0,0x1
ffffffffc020133c:	3d850513          	addi	a0,a0,984 # ffffffffc0202710 <etext+0x858>
ffffffffc0201340:	848ff0ef          	jal	ffffffffc0200388 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201344:	00001697          	auipc	a3,0x1
ffffffffc0201348:	42468693          	addi	a3,a3,1060 # ffffffffc0202768 <etext+0x8b0>
ffffffffc020134c:	00001617          	auipc	a2,0x1
ffffffffc0201350:	3ac60613          	addi	a2,a2,940 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201354:	0ba00593          	li	a1,186
ffffffffc0201358:	00001517          	auipc	a0,0x1
ffffffffc020135c:	3b850513          	addi	a0,a0,952 # ffffffffc0202710 <etext+0x858>
ffffffffc0201360:	828ff0ef          	jal	ffffffffc0200388 <__panic>

ffffffffc0201364 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201364:	1141                	addi	sp,sp,-16
ffffffffc0201366:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201368:	14058c63          	beqz	a1,ffffffffc02014c0 <default_free_pages+0x15c>
    for (; p != base + n; p ++) {
ffffffffc020136c:	00259713          	slli	a4,a1,0x2
ffffffffc0201370:	972e                	add	a4,a4,a1
ffffffffc0201372:	070e                	slli	a4,a4,0x3
ffffffffc0201374:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201378:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020137a:	c30d                	beqz	a4,ffffffffc020139c <default_free_pages+0x38>
ffffffffc020137c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020137e:	8b05                	andi	a4,a4,1
ffffffffc0201380:	12071063          	bnez	a4,ffffffffc02014a0 <default_free_pages+0x13c>
ffffffffc0201384:	6798                	ld	a4,8(a5)
ffffffffc0201386:	8b09                	andi	a4,a4,2
ffffffffc0201388:	10071c63          	bnez	a4,ffffffffc02014a0 <default_free_pages+0x13c>
        p->flags = 0;
ffffffffc020138c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201390:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201394:	02878793          	addi	a5,a5,40
ffffffffc0201398:	fed792e3          	bne	a5,a3,ffffffffc020137c <default_free_pages+0x18>
    base->property = n;
ffffffffc020139c:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020139e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013a2:	4789                	li	a5,2
ffffffffc02013a4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02013a8:	00005717          	auipc	a4,0x5
ffffffffc02013ac:	c9072703          	lw	a4,-880(a4) # ffffffffc0206038 <free_area+0x10>
ffffffffc02013b0:	00005697          	auipc	a3,0x5
ffffffffc02013b4:	c7868693          	addi	a3,a3,-904 # ffffffffc0206028 <free_area>
    return list->next == list;
ffffffffc02013b8:	669c                	ld	a5,8(a3)
ffffffffc02013ba:	9f2d                	addw	a4,a4,a1
ffffffffc02013bc:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02013be:	0ad78563          	beq	a5,a3,ffffffffc0201468 <default_free_pages+0x104>
            struct Page* page = le2page(le, page_link);
ffffffffc02013c2:	fe878713          	addi	a4,a5,-24
ffffffffc02013c6:	4581                	li	a1,0
ffffffffc02013c8:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02013cc:	00e56a63          	bltu	a0,a4,ffffffffc02013e0 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02013d0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013d2:	06d70263          	beq	a4,a3,ffffffffc0201436 <default_free_pages+0xd2>
    struct Page *p = base;
ffffffffc02013d6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013d8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02013dc:	fee57ae3          	bgeu	a0,a4,ffffffffc02013d0 <default_free_pages+0x6c>
ffffffffc02013e0:	c199                	beqz	a1,ffffffffc02013e6 <default_free_pages+0x82>
ffffffffc02013e2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013e6:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013e8:	e390                	sd	a2,0(a5)
ffffffffc02013ea:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc02013ec:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc02013ee:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc02013f0:	02d70063          	beq	a4,a3,ffffffffc0201410 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02013f4:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02013f8:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc02013fc:	02081613          	slli	a2,a6,0x20
ffffffffc0201400:	9201                	srli	a2,a2,0x20
ffffffffc0201402:	00261793          	slli	a5,a2,0x2
ffffffffc0201406:	97b2                	add	a5,a5,a2
ffffffffc0201408:	078e                	slli	a5,a5,0x3
ffffffffc020140a:	97ae                	add	a5,a5,a1
ffffffffc020140c:	02f50f63          	beq	a0,a5,ffffffffc020144a <default_free_pages+0xe6>
    return listelm->next;
ffffffffc0201410:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201412:	00d70f63          	beq	a4,a3,ffffffffc0201430 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201416:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201418:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020141c:	02059613          	slli	a2,a1,0x20
ffffffffc0201420:	9201                	srli	a2,a2,0x20
ffffffffc0201422:	00261793          	slli	a5,a2,0x2
ffffffffc0201426:	97b2                	add	a5,a5,a2
ffffffffc0201428:	078e                	slli	a5,a5,0x3
ffffffffc020142a:	97aa                	add	a5,a5,a0
ffffffffc020142c:	04f68a63          	beq	a3,a5,ffffffffc0201480 <default_free_pages+0x11c>
}
ffffffffc0201430:	60a2                	ld	ra,8(sp)
ffffffffc0201432:	0141                	addi	sp,sp,16
ffffffffc0201434:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201436:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201438:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020143a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020143c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020143e:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201440:	02d70d63          	beq	a4,a3,ffffffffc020147a <default_free_pages+0x116>
ffffffffc0201444:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201446:	87ba                	mv	a5,a4
ffffffffc0201448:	bf41                	j	ffffffffc02013d8 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc020144a:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020144c:	5675                	li	a2,-3
ffffffffc020144e:	010787bb          	addw	a5,a5,a6
ffffffffc0201452:	fef72c23          	sw	a5,-8(a4)
ffffffffc0201456:	60c8b02f          	amoand.d	zero,a2,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020145a:	6d10                	ld	a2,24(a0)
ffffffffc020145c:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc020145e:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201460:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201462:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201464:	e390                	sd	a2,0(a5)
ffffffffc0201466:	b775                	j	ffffffffc0201412 <default_free_pages+0xae>
}
ffffffffc0201468:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020146a:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc020146e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201470:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201472:	e398                	sd	a4,0(a5)
ffffffffc0201474:	e798                	sd	a4,8(a5)
}
ffffffffc0201476:	0141                	addi	sp,sp,16
ffffffffc0201478:	8082                	ret
ffffffffc020147a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020147c:	873e                	mv	a4,a5
ffffffffc020147e:	bf8d                	j	ffffffffc02013f0 <default_free_pages+0x8c>
            base->property += p->property;
ffffffffc0201480:	ff872783          	lw	a5,-8(a4)
ffffffffc0201484:	56f5                	li	a3,-3
ffffffffc0201486:	9fad                	addw	a5,a5,a1
ffffffffc0201488:	c91c                	sw	a5,16(a0)
ffffffffc020148a:	ff070793          	addi	a5,a4,-16
ffffffffc020148e:	60d7b02f          	amoand.d	zero,a3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201492:	6314                	ld	a3,0(a4)
ffffffffc0201494:	671c                	ld	a5,8(a4)
}
ffffffffc0201496:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201498:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020149a:	e394                	sd	a3,0(a5)
ffffffffc020149c:	0141                	addi	sp,sp,16
ffffffffc020149e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014a0:	00001697          	auipc	a3,0x1
ffffffffc02014a4:	5b868693          	addi	a3,a3,1464 # ffffffffc0202a58 <etext+0xba0>
ffffffffc02014a8:	00001617          	auipc	a2,0x1
ffffffffc02014ac:	25060613          	addi	a2,a2,592 # ffffffffc02026f8 <etext+0x840>
ffffffffc02014b0:	08300593          	li	a1,131
ffffffffc02014b4:	00001517          	auipc	a0,0x1
ffffffffc02014b8:	25c50513          	addi	a0,a0,604 # ffffffffc0202710 <etext+0x858>
ffffffffc02014bc:	ecdfe0ef          	jal	ffffffffc0200388 <__panic>
    assert(n > 0);
ffffffffc02014c0:	00001697          	auipc	a3,0x1
ffffffffc02014c4:	59068693          	addi	a3,a3,1424 # ffffffffc0202a50 <etext+0xb98>
ffffffffc02014c8:	00001617          	auipc	a2,0x1
ffffffffc02014cc:	23060613          	addi	a2,a2,560 # ffffffffc02026f8 <etext+0x840>
ffffffffc02014d0:	08000593          	li	a1,128
ffffffffc02014d4:	00001517          	auipc	a0,0x1
ffffffffc02014d8:	23c50513          	addi	a0,a0,572 # ffffffffc0202710 <etext+0x858>
ffffffffc02014dc:	eadfe0ef          	jal	ffffffffc0200388 <__panic>

ffffffffc02014e0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02014e0:	cd41                	beqz	a0,ffffffffc0201578 <default_alloc_pages+0x98>
    if (n > nr_free) {
ffffffffc02014e2:	00005597          	auipc	a1,0x5
ffffffffc02014e6:	b565a583          	lw	a1,-1194(a1) # ffffffffc0206038 <free_area+0x10>
ffffffffc02014ea:	86aa                	mv	a3,a0
ffffffffc02014ec:	02059793          	slli	a5,a1,0x20
ffffffffc02014f0:	9381                	srli	a5,a5,0x20
ffffffffc02014f2:	00a7ef63          	bltu	a5,a0,ffffffffc0201510 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc02014f6:	00005617          	auipc	a2,0x5
ffffffffc02014fa:	b3260613          	addi	a2,a2,-1230 # ffffffffc0206028 <free_area>
ffffffffc02014fe:	87b2                	mv	a5,a2
ffffffffc0201500:	a029                	j	ffffffffc020150a <default_alloc_pages+0x2a>
        if (p->property >= n) {
ffffffffc0201502:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0201506:	00d77763          	bgeu	a4,a3,ffffffffc0201514 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc020150a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020150c:	fec79be3          	bne	a5,a2,ffffffffc0201502 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0201510:	4501                	li	a0,0
}
ffffffffc0201512:	8082                	ret
        if (page->property > n) {
ffffffffc0201514:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc0201518:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020151c:	6798                	ld	a4,8(a5)
ffffffffc020151e:	02089313          	slli	t1,a7,0x20
ffffffffc0201522:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc0201526:	00e83423          	sd	a4,8(a6) # ff0008 <kern_entry-0xffffffffbf20fff8>
    next->prev = prev;
ffffffffc020152a:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc020152e:	fe878513          	addi	a0,a5,-24
        if (page->property > n) {
ffffffffc0201532:	0266fc63          	bgeu	a3,t1,ffffffffc020156a <default_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc0201536:	00269713          	slli	a4,a3,0x2
ffffffffc020153a:	9736                	add	a4,a4,a3
ffffffffc020153c:	070e                	slli	a4,a4,0x3
            p->property = page->property - n;
ffffffffc020153e:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc0201542:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201544:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201548:	00870313          	addi	t1,a4,8
ffffffffc020154c:	4889                	li	a7,2
ffffffffc020154e:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201552:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc0201556:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc020155a:	0068b023          	sd	t1,0(a7)
ffffffffc020155e:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc0201562:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0201566:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc020156a:	9d95                	subw	a1,a1,a3
ffffffffc020156c:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020156e:	5775                	li	a4,-3
ffffffffc0201570:	17c1                	addi	a5,a5,-16
ffffffffc0201572:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201576:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201578:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020157a:	00001697          	auipc	a3,0x1
ffffffffc020157e:	4d668693          	addi	a3,a3,1238 # ffffffffc0202a50 <etext+0xb98>
ffffffffc0201582:	00001617          	auipc	a2,0x1
ffffffffc0201586:	17660613          	addi	a2,a2,374 # ffffffffc02026f8 <etext+0x840>
ffffffffc020158a:	06200593          	li	a1,98
ffffffffc020158e:	00001517          	auipc	a0,0x1
ffffffffc0201592:	18250513          	addi	a0,a0,386 # ffffffffc0202710 <etext+0x858>
default_alloc_pages(size_t n) {
ffffffffc0201596:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201598:	df1fe0ef          	jal	ffffffffc0200388 <__panic>

ffffffffc020159c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020159c:	1141                	addi	sp,sp,-16
ffffffffc020159e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015a0:	c9f1                	beqz	a1,ffffffffc0201674 <default_init_memmap+0xd8>
    for (; p != base + n; p ++) {
ffffffffc02015a2:	00259713          	slli	a4,a1,0x2
ffffffffc02015a6:	972e                	add	a4,a4,a1
ffffffffc02015a8:	070e                	slli	a4,a4,0x3
ffffffffc02015aa:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02015ae:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02015b0:	cf11                	beqz	a4,ffffffffc02015cc <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015b2:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02015b4:	8b05                	andi	a4,a4,1
ffffffffc02015b6:	cf59                	beqz	a4,ffffffffc0201654 <default_init_memmap+0xb8>
        p->flags = p->property = 0;
ffffffffc02015b8:	0007a823          	sw	zero,16(a5)
ffffffffc02015bc:	0007b423          	sd	zero,8(a5)
ffffffffc02015c0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015c4:	02878793          	addi	a5,a5,40
ffffffffc02015c8:	fed795e3          	bne	a5,a3,ffffffffc02015b2 <default_init_memmap+0x16>
    base->property = n;
ffffffffc02015cc:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015ce:	4789                	li	a5,2
ffffffffc02015d0:	00850713          	addi	a4,a0,8
ffffffffc02015d4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02015d8:	00005717          	auipc	a4,0x5
ffffffffc02015dc:	a6072703          	lw	a4,-1440(a4) # ffffffffc0206038 <free_area+0x10>
ffffffffc02015e0:	00005697          	auipc	a3,0x5
ffffffffc02015e4:	a4868693          	addi	a3,a3,-1464 # ffffffffc0206028 <free_area>
    return list->next == list;
ffffffffc02015e8:	669c                	ld	a5,8(a3)
ffffffffc02015ea:	9f2d                	addw	a4,a4,a1
ffffffffc02015ec:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ee:	04d78663          	beq	a5,a3,ffffffffc020163a <default_init_memmap+0x9e>
            struct Page* page = le2page(le, page_link);
ffffffffc02015f2:	fe878713          	addi	a4,a5,-24
ffffffffc02015f6:	4581                	li	a1,0
ffffffffc02015f8:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02015fc:	00e56a63          	bltu	a0,a4,ffffffffc0201610 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201600:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201602:	02d70263          	beq	a4,a3,ffffffffc0201626 <default_init_memmap+0x8a>
    struct Page *p = base;
ffffffffc0201606:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201608:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020160c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201600 <default_init_memmap+0x64>
ffffffffc0201610:	c199                	beqz	a1,ffffffffc0201616 <default_init_memmap+0x7a>
ffffffffc0201612:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201616:	6398                	ld	a4,0(a5)
}
ffffffffc0201618:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020161a:	e390                	sd	a2,0(a5)
ffffffffc020161c:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc020161e:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201620:	f11c                	sd	a5,32(a0)
ffffffffc0201622:	0141                	addi	sp,sp,16
ffffffffc0201624:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201626:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201628:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020162a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020162c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020162e:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201630:	00d70e63          	beq	a4,a3,ffffffffc020164c <default_init_memmap+0xb0>
ffffffffc0201634:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201636:	87ba                	mv	a5,a4
ffffffffc0201638:	bfc1                	j	ffffffffc0201608 <default_init_memmap+0x6c>
}
ffffffffc020163a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020163c:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201640:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201642:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201644:	e398                	sd	a4,0(a5)
ffffffffc0201646:	e798                	sd	a4,8(a5)
}
ffffffffc0201648:	0141                	addi	sp,sp,16
ffffffffc020164a:	8082                	ret
ffffffffc020164c:	60a2                	ld	ra,8(sp)
ffffffffc020164e:	e290                	sd	a2,0(a3)
ffffffffc0201650:	0141                	addi	sp,sp,16
ffffffffc0201652:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201654:	00001697          	auipc	a3,0x1
ffffffffc0201658:	42c68693          	addi	a3,a3,1068 # ffffffffc0202a80 <etext+0xbc8>
ffffffffc020165c:	00001617          	auipc	a2,0x1
ffffffffc0201660:	09c60613          	addi	a2,a2,156 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201664:	04900593          	li	a1,73
ffffffffc0201668:	00001517          	auipc	a0,0x1
ffffffffc020166c:	0a850513          	addi	a0,a0,168 # ffffffffc0202710 <etext+0x858>
ffffffffc0201670:	d19fe0ef          	jal	ffffffffc0200388 <__panic>
    assert(n > 0);
ffffffffc0201674:	00001697          	auipc	a3,0x1
ffffffffc0201678:	3dc68693          	addi	a3,a3,988 # ffffffffc0202a50 <etext+0xb98>
ffffffffc020167c:	00001617          	auipc	a2,0x1
ffffffffc0201680:	07c60613          	addi	a2,a2,124 # ffffffffc02026f8 <etext+0x840>
ffffffffc0201684:	04600593          	li	a1,70
ffffffffc0201688:	00001517          	auipc	a0,0x1
ffffffffc020168c:	08850513          	addi	a0,a0,136 # ffffffffc0202710 <etext+0x858>
ffffffffc0201690:	cf9fe0ef          	jal	ffffffffc0200388 <__panic>

ffffffffc0201694 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201694:	100027f3          	csrr	a5,sstatus
ffffffffc0201698:	8b89                	andi	a5,a5,2
ffffffffc020169a:	e799                	bnez	a5,ffffffffc02016a8 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020169c:	00005797          	auipc	a5,0x5
ffffffffc02016a0:	dcc7b783          	ld	a5,-564(a5) # ffffffffc0206468 <pmm_manager>
ffffffffc02016a4:	6f9c                	ld	a5,24(a5)
ffffffffc02016a6:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02016a8:	1101                	addi	sp,sp,-32
ffffffffc02016aa:	ec06                	sd	ra,24(sp)
ffffffffc02016ac:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02016ae:	8d4ff0ef          	jal	ffffffffc0200782 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02016b2:	00005797          	auipc	a5,0x5
ffffffffc02016b6:	db67b783          	ld	a5,-586(a5) # ffffffffc0206468 <pmm_manager>
ffffffffc02016ba:	6522                	ld	a0,8(sp)
ffffffffc02016bc:	6f9c                	ld	a5,24(a5)
ffffffffc02016be:	9782                	jalr	a5
ffffffffc02016c0:	e42a                	sd	a0,8(sp)
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02016c2:	8baff0ef          	jal	ffffffffc020077c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02016c6:	60e2                	ld	ra,24(sp)
ffffffffc02016c8:	6522                	ld	a0,8(sp)
ffffffffc02016ca:	6105                	addi	sp,sp,32
ffffffffc02016cc:	8082                	ret

ffffffffc02016ce <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016ce:	100027f3          	csrr	a5,sstatus
ffffffffc02016d2:	8b89                	andi	a5,a5,2
ffffffffc02016d4:	e799                	bnez	a5,ffffffffc02016e2 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02016d6:	00005797          	auipc	a5,0x5
ffffffffc02016da:	d927b783          	ld	a5,-622(a5) # ffffffffc0206468 <pmm_manager>
ffffffffc02016de:	739c                	ld	a5,32(a5)
ffffffffc02016e0:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02016e2:	1101                	addi	sp,sp,-32
ffffffffc02016e4:	ec06                	sd	ra,24(sp)
ffffffffc02016e6:	e42e                	sd	a1,8(sp)
ffffffffc02016e8:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc02016ea:	898ff0ef          	jal	ffffffffc0200782 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02016ee:	00005797          	auipc	a5,0x5
ffffffffc02016f2:	d7a7b783          	ld	a5,-646(a5) # ffffffffc0206468 <pmm_manager>
ffffffffc02016f6:	65a2                	ld	a1,8(sp)
ffffffffc02016f8:	6502                	ld	a0,0(sp)
ffffffffc02016fa:	739c                	ld	a5,32(a5)
ffffffffc02016fc:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02016fe:	60e2                	ld	ra,24(sp)
ffffffffc0201700:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201702:	87aff06f          	j	ffffffffc020077c <intr_enable>

ffffffffc0201706 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201706:	100027f3          	csrr	a5,sstatus
ffffffffc020170a:	8b89                	andi	a5,a5,2
ffffffffc020170c:	e799                	bnez	a5,ffffffffc020171a <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020170e:	00005797          	auipc	a5,0x5
ffffffffc0201712:	d5a7b783          	ld	a5,-678(a5) # ffffffffc0206468 <pmm_manager>
ffffffffc0201716:	779c                	ld	a5,40(a5)
ffffffffc0201718:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020171a:	1101                	addi	sp,sp,-32
ffffffffc020171c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020171e:	864ff0ef          	jal	ffffffffc0200782 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201722:	00005797          	auipc	a5,0x5
ffffffffc0201726:	d467b783          	ld	a5,-698(a5) # ffffffffc0206468 <pmm_manager>
ffffffffc020172a:	779c                	ld	a5,40(a5)
ffffffffc020172c:	9782                	jalr	a5
ffffffffc020172e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201730:	84cff0ef          	jal	ffffffffc020077c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201734:	60e2                	ld	ra,24(sp)
ffffffffc0201736:	6522                	ld	a0,8(sp)
ffffffffc0201738:	6105                	addi	sp,sp,32
ffffffffc020173a:	8082                	ret

ffffffffc020173c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020173c:	00001797          	auipc	a5,0x1
ffffffffc0201740:	5e478793          	addi	a5,a5,1508 # ffffffffc0202d20 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201744:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201746:	7139                	addi	sp,sp,-64
ffffffffc0201748:	fc06                	sd	ra,56(sp)
ffffffffc020174a:	f822                	sd	s0,48(sp)
ffffffffc020174c:	f426                	sd	s1,40(sp)
ffffffffc020174e:	ec4e                	sd	s3,24(sp)
ffffffffc0201750:	f04a                	sd	s2,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201752:	00005417          	auipc	s0,0x5
ffffffffc0201756:	d1640413          	addi	s0,s0,-746 # ffffffffc0206468 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020175a:	00001517          	auipc	a0,0x1
ffffffffc020175e:	34e50513          	addi	a0,a0,846 # ffffffffc0202aa8 <etext+0xbf0>
    pmm_manager = &default_pmm_manager;
ffffffffc0201762:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201764:	973fe0ef          	jal	ffffffffc02000d6 <cprintf>
    pmm_manager->init();
ffffffffc0201768:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020176a:	00005497          	auipc	s1,0x5
ffffffffc020176e:	d1648493          	addi	s1,s1,-746 # ffffffffc0206480 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201772:	679c                	ld	a5,8(a5)
ffffffffc0201774:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201776:	57f5                	li	a5,-3
ffffffffc0201778:	07fa                	slli	a5,a5,0x1e
ffffffffc020177a:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc020177c:	fedfe0ef          	jal	ffffffffc0200768 <get_memory_base>
ffffffffc0201780:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0201782:	ff1fe0ef          	jal	ffffffffc0200772 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0201786:	16050063          	beqz	a0,ffffffffc02018e6 <pmm_init+0x1aa>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020178a:	00a98933          	add	s2,s3,a0
ffffffffc020178e:	e42a                	sd	a0,8(sp)
    cprintf("physcial memory map:\n");
ffffffffc0201790:	00001517          	auipc	a0,0x1
ffffffffc0201794:	36050513          	addi	a0,a0,864 # ffffffffc0202af0 <etext+0xc38>
ffffffffc0201798:	93ffe0ef          	jal	ffffffffc02000d6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020179c:	65a2                	ld	a1,8(sp)
ffffffffc020179e:	864e                	mv	a2,s3
ffffffffc02017a0:	fff90693          	addi	a3,s2,-1
ffffffffc02017a4:	00001517          	auipc	a0,0x1
ffffffffc02017a8:	36450513          	addi	a0,a0,868 # ffffffffc0202b08 <etext+0xc50>
ffffffffc02017ac:	92bfe0ef          	jal	ffffffffc02000d6 <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc02017b0:	c80007b7          	lui	a5,0xc8000
ffffffffc02017b4:	864a                	mv	a2,s2
ffffffffc02017b6:	0d27e563          	bltu	a5,s2,ffffffffc0201880 <pmm_init+0x144>
ffffffffc02017ba:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02017bc:	00006697          	auipc	a3,0x6
ffffffffc02017c0:	ce368693          	addi	a3,a3,-797 # ffffffffc020749f <end+0xfff>
ffffffffc02017c4:	8efd                	and	a3,a3,a5
    npage = maxpa / PGSIZE;
ffffffffc02017c6:	8231                	srli	a2,a2,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02017c8:	00005817          	auipc	a6,0x5
ffffffffc02017cc:	cc880813          	addi	a6,a6,-824 # ffffffffc0206490 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02017d0:	00005517          	auipc	a0,0x5
ffffffffc02017d4:	cb850513          	addi	a0,a0,-840 # ffffffffc0206488 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02017d8:	00d83023          	sd	a3,0(a6)
    npage = maxpa / PGSIZE;
ffffffffc02017dc:	e110                	sd	a2,0(a0)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02017de:	00080737          	lui	a4,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02017e2:	87b6                	mv	a5,a3
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02017e4:	02e60a63          	beq	a2,a4,ffffffffc0201818 <pmm_init+0xdc>
ffffffffc02017e8:	4701                	li	a4,0
ffffffffc02017ea:	4781                	li	a5,0
ffffffffc02017ec:	4305                	li	t1,1
ffffffffc02017ee:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc02017f2:	96ba                	add	a3,a3,a4
ffffffffc02017f4:	06a1                	addi	a3,a3,8
ffffffffc02017f6:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02017fa:	6110                	ld	a2,0(a0)
ffffffffc02017fc:	0785                	addi	a5,a5,1 # fffffffffffff001 <end+0x3fdf8b61>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02017fe:	00083683          	ld	a3,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201802:	011605b3          	add	a1,a2,a7
ffffffffc0201806:	02870713          	addi	a4,a4,40 # 80028 <kern_entry-0xffffffffc017ffd8>
ffffffffc020180a:	feb7e4e3          	bltu	a5,a1,ffffffffc02017f2 <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020180e:	00259793          	slli	a5,a1,0x2
ffffffffc0201812:	97ae                	add	a5,a5,a1
ffffffffc0201814:	078e                	slli	a5,a5,0x3
ffffffffc0201816:	97b6                	add	a5,a5,a3
ffffffffc0201818:	c0200737          	lui	a4,0xc0200
ffffffffc020181c:	0ae7e863          	bltu	a5,a4,ffffffffc02018cc <pmm_init+0x190>
ffffffffc0201820:	608c                	ld	a1,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0201822:	777d                	lui	a4,0xfffff
ffffffffc0201824:	00e97933          	and	s2,s2,a4
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201828:	8f8d                	sub	a5,a5,a1
    if (freemem < mem_end) {
ffffffffc020182a:	0527ed63          	bltu	a5,s2,ffffffffc0201884 <pmm_init+0x148>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020182e:	601c                	ld	a5,0(s0)
ffffffffc0201830:	7b9c                	ld	a5,48(a5)
ffffffffc0201832:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201834:	00001517          	auipc	a0,0x1
ffffffffc0201838:	35c50513          	addi	a0,a0,860 # ffffffffc0202b90 <etext+0xcd8>
ffffffffc020183c:	89bfe0ef          	jal	ffffffffc02000d6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201840:	00003597          	auipc	a1,0x3
ffffffffc0201844:	7c058593          	addi	a1,a1,1984 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201848:	00005797          	auipc	a5,0x5
ffffffffc020184c:	c2b7b823          	sd	a1,-976(a5) # ffffffffc0206478 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201850:	c02007b7          	lui	a5,0xc0200
ffffffffc0201854:	0af5e563          	bltu	a1,a5,ffffffffc02018fe <pmm_init+0x1c2>
ffffffffc0201858:	609c                	ld	a5,0(s1)
}
ffffffffc020185a:	7442                	ld	s0,48(sp)
ffffffffc020185c:	70e2                	ld	ra,56(sp)
ffffffffc020185e:	74a2                	ld	s1,40(sp)
ffffffffc0201860:	7902                	ld	s2,32(sp)
ffffffffc0201862:	69e2                	ld	s3,24(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201864:	40f586b3          	sub	a3,a1,a5
ffffffffc0201868:	00005797          	auipc	a5,0x5
ffffffffc020186c:	c0d7b423          	sd	a3,-1016(a5) # ffffffffc0206470 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201870:	00001517          	auipc	a0,0x1
ffffffffc0201874:	34050513          	addi	a0,a0,832 # ffffffffc0202bb0 <etext+0xcf8>
ffffffffc0201878:	8636                	mv	a2,a3
}
ffffffffc020187a:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020187c:	85bfe06f          	j	ffffffffc02000d6 <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc0201880:	863e                	mv	a2,a5
ffffffffc0201882:	bf25                	j	ffffffffc02017ba <pmm_init+0x7e>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201884:	6585                	lui	a1,0x1
ffffffffc0201886:	15fd                	addi	a1,a1,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0201888:	97ae                	add	a5,a5,a1
ffffffffc020188a:	8ff9                	and	a5,a5,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020188c:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201890:	02c77263          	bgeu	a4,a2,ffffffffc02018b4 <pmm_init+0x178>
    pmm_manager->init_memmap(base, n);
ffffffffc0201894:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201896:	fff805b7          	lui	a1,0xfff80
ffffffffc020189a:	972e                	add	a4,a4,a1
ffffffffc020189c:	00271513          	slli	a0,a4,0x2
ffffffffc02018a0:	953a                	add	a0,a0,a4
ffffffffc02018a2:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02018a4:	40f90933          	sub	s2,s2,a5
ffffffffc02018a8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02018aa:	00c95593          	srli	a1,s2,0xc
ffffffffc02018ae:	9536                	add	a0,a0,a3
ffffffffc02018b0:	9702                	jalr	a4
}
ffffffffc02018b2:	bfb5                	j	ffffffffc020182e <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc02018b4:	00001617          	auipc	a2,0x1
ffffffffc02018b8:	2ac60613          	addi	a2,a2,684 # ffffffffc0202b60 <etext+0xca8>
ffffffffc02018bc:	06b00593          	li	a1,107
ffffffffc02018c0:	00001517          	auipc	a0,0x1
ffffffffc02018c4:	2c050513          	addi	a0,a0,704 # ffffffffc0202b80 <etext+0xcc8>
ffffffffc02018c8:	ac1fe0ef          	jal	ffffffffc0200388 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02018cc:	86be                	mv	a3,a5
ffffffffc02018ce:	00001617          	auipc	a2,0x1
ffffffffc02018d2:	26a60613          	addi	a2,a2,618 # ffffffffc0202b38 <etext+0xc80>
ffffffffc02018d6:	07100593          	li	a1,113
ffffffffc02018da:	00001517          	auipc	a0,0x1
ffffffffc02018de:	20650513          	addi	a0,a0,518 # ffffffffc0202ae0 <etext+0xc28>
ffffffffc02018e2:	aa7fe0ef          	jal	ffffffffc0200388 <__panic>
        panic("DTB memory info not available");
ffffffffc02018e6:	00001617          	auipc	a2,0x1
ffffffffc02018ea:	1da60613          	addi	a2,a2,474 # ffffffffc0202ac0 <etext+0xc08>
ffffffffc02018ee:	05a00593          	li	a1,90
ffffffffc02018f2:	00001517          	auipc	a0,0x1
ffffffffc02018f6:	1ee50513          	addi	a0,a0,494 # ffffffffc0202ae0 <etext+0xc28>
ffffffffc02018fa:	a8ffe0ef          	jal	ffffffffc0200388 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02018fe:	86ae                	mv	a3,a1
ffffffffc0201900:	00001617          	auipc	a2,0x1
ffffffffc0201904:	23860613          	addi	a2,a2,568 # ffffffffc0202b38 <etext+0xc80>
ffffffffc0201908:	08c00593          	li	a1,140
ffffffffc020190c:	00001517          	auipc	a0,0x1
ffffffffc0201910:	1d450513          	addi	a0,a0,468 # ffffffffc0202ae0 <etext+0xc28>
ffffffffc0201914:	a75fe0ef          	jal	ffffffffc0200388 <__panic>

ffffffffc0201918 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201918:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020191a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020191e:	f022                	sd	s0,32(sp)
ffffffffc0201920:	ec26                	sd	s1,24(sp)
ffffffffc0201922:	e84a                	sd	s2,16(sp)
ffffffffc0201924:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201926:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020192a:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc020192c:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201930:	fff7041b          	addiw	s0,a4,-1 # ffffffffffffefff <end+0x3fdf8b5f>
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201934:	84aa                	mv	s1,a0
ffffffffc0201936:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc0201938:	03067d63          	bgeu	a2,a6,ffffffffc0201972 <printnum+0x5a>
ffffffffc020193c:	e44e                	sd	s3,8(sp)
ffffffffc020193e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201940:	4785                	li	a5,1
ffffffffc0201942:	00e7d763          	bge	a5,a4,ffffffffc0201950 <printnum+0x38>
            putch(padc, putdat);
ffffffffc0201946:	85ca                	mv	a1,s2
ffffffffc0201948:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc020194a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020194c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020194e:	fc65                	bnez	s0,ffffffffc0201946 <printnum+0x2e>
ffffffffc0201950:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201952:	00001797          	auipc	a5,0x1
ffffffffc0201956:	29e78793          	addi	a5,a5,670 # ffffffffc0202bf0 <etext+0xd38>
ffffffffc020195a:	97d2                	add	a5,a5,s4
}
ffffffffc020195c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020195e:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0201962:	70a2                	ld	ra,40(sp)
ffffffffc0201964:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201966:	85ca                	mv	a1,s2
ffffffffc0201968:	87a6                	mv	a5,s1
}
ffffffffc020196a:	6942                	ld	s2,16(sp)
ffffffffc020196c:	64e2                	ld	s1,24(sp)
ffffffffc020196e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201970:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201972:	03065633          	divu	a2,a2,a6
ffffffffc0201976:	8722                	mv	a4,s0
ffffffffc0201978:	fa1ff0ef          	jal	ffffffffc0201918 <printnum>
ffffffffc020197c:	bfd9                	j	ffffffffc0201952 <printnum+0x3a>

ffffffffc020197e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020197e:	7119                	addi	sp,sp,-128
ffffffffc0201980:	f4a6                	sd	s1,104(sp)
ffffffffc0201982:	f0ca                	sd	s2,96(sp)
ffffffffc0201984:	ecce                	sd	s3,88(sp)
ffffffffc0201986:	e8d2                	sd	s4,80(sp)
ffffffffc0201988:	e4d6                	sd	s5,72(sp)
ffffffffc020198a:	e0da                	sd	s6,64(sp)
ffffffffc020198c:	f862                	sd	s8,48(sp)
ffffffffc020198e:	fc86                	sd	ra,120(sp)
ffffffffc0201990:	f8a2                	sd	s0,112(sp)
ffffffffc0201992:	fc5e                	sd	s7,56(sp)
ffffffffc0201994:	f466                	sd	s9,40(sp)
ffffffffc0201996:	f06a                	sd	s10,32(sp)
ffffffffc0201998:	ec6e                	sd	s11,24(sp)
ffffffffc020199a:	84aa                	mv	s1,a0
ffffffffc020199c:	8c32                	mv	s8,a2
ffffffffc020199e:	8a36                	mv	s4,a3
ffffffffc02019a0:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02019a2:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019a6:	05500b13          	li	s6,85
ffffffffc02019aa:	00001a97          	auipc	s5,0x1
ffffffffc02019ae:	3aea8a93          	addi	s5,s5,942 # ffffffffc0202d58 <default_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02019b2:	000c4503          	lbu	a0,0(s8)
ffffffffc02019b6:	001c0413          	addi	s0,s8,1
ffffffffc02019ba:	01350a63          	beq	a0,s3,ffffffffc02019ce <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc02019be:	cd0d                	beqz	a0,ffffffffc02019f8 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc02019c0:	85ca                	mv	a1,s2
ffffffffc02019c2:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02019c4:	00044503          	lbu	a0,0(s0)
ffffffffc02019c8:	0405                	addi	s0,s0,1
ffffffffc02019ca:	ff351ae3          	bne	a0,s3,ffffffffc02019be <vprintfmt+0x40>
        width = precision = -1;
ffffffffc02019ce:	5cfd                	li	s9,-1
ffffffffc02019d0:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc02019d2:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc02019d6:	4b81                	li	s7,0
ffffffffc02019d8:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019da:	00044683          	lbu	a3,0(s0)
ffffffffc02019de:	00140c13          	addi	s8,s0,1
ffffffffc02019e2:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02019e6:	0ff5f593          	zext.b	a1,a1
ffffffffc02019ea:	02bb6663          	bltu	s6,a1,ffffffffc0201a16 <vprintfmt+0x98>
ffffffffc02019ee:	058a                	slli	a1,a1,0x2
ffffffffc02019f0:	95d6                	add	a1,a1,s5
ffffffffc02019f2:	4198                	lw	a4,0(a1)
ffffffffc02019f4:	9756                	add	a4,a4,s5
ffffffffc02019f6:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02019f8:	70e6                	ld	ra,120(sp)
ffffffffc02019fa:	7446                	ld	s0,112(sp)
ffffffffc02019fc:	74a6                	ld	s1,104(sp)
ffffffffc02019fe:	7906                	ld	s2,96(sp)
ffffffffc0201a00:	69e6                	ld	s3,88(sp)
ffffffffc0201a02:	6a46                	ld	s4,80(sp)
ffffffffc0201a04:	6aa6                	ld	s5,72(sp)
ffffffffc0201a06:	6b06                	ld	s6,64(sp)
ffffffffc0201a08:	7be2                	ld	s7,56(sp)
ffffffffc0201a0a:	7c42                	ld	s8,48(sp)
ffffffffc0201a0c:	7ca2                	ld	s9,40(sp)
ffffffffc0201a0e:	7d02                	ld	s10,32(sp)
ffffffffc0201a10:	6de2                	ld	s11,24(sp)
ffffffffc0201a12:	6109                	addi	sp,sp,128
ffffffffc0201a14:	8082                	ret
            putch('%', putdat);
ffffffffc0201a16:	85ca                	mv	a1,s2
ffffffffc0201a18:	02500513          	li	a0,37
ffffffffc0201a1c:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201a1e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201a22:	02500713          	li	a4,37
ffffffffc0201a26:	8c22                	mv	s8,s0
ffffffffc0201a28:	f8e785e3          	beq	a5,a4,ffffffffc02019b2 <vprintfmt+0x34>
ffffffffc0201a2c:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0201a30:	1c7d                	addi	s8,s8,-1
ffffffffc0201a32:	fee79de3          	bne	a5,a4,ffffffffc0201a2c <vprintfmt+0xae>
ffffffffc0201a36:	bfb5                	j	ffffffffc02019b2 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0201a38:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0201a3c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc0201a3e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc0201a42:	fd06071b          	addiw	a4,a2,-48
ffffffffc0201a46:	24e56a63          	bltu	a0,a4,ffffffffc0201c9a <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc0201a4a:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a4c:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc0201a4e:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc0201a52:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201a56:	0197073b          	addw	a4,a4,s9
ffffffffc0201a5a:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201a5e:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201a60:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201a64:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201a66:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201a6a:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc0201a6e:	feb570e3          	bgeu	a0,a1,ffffffffc0201a4e <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0201a72:	f60d54e3          	bgez	s10,ffffffffc02019da <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0201a76:	8d66                	mv	s10,s9
ffffffffc0201a78:	5cfd                	li	s9,-1
ffffffffc0201a7a:	b785                	j	ffffffffc02019da <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a7c:	8db6                	mv	s11,a3
ffffffffc0201a7e:	8462                	mv	s0,s8
ffffffffc0201a80:	bfa9                	j	ffffffffc02019da <vprintfmt+0x5c>
ffffffffc0201a82:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0201a84:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0201a86:	bf91                	j	ffffffffc02019da <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0201a88:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201a8a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201a8e:	00f74463          	blt	a4,a5,ffffffffc0201a96 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0201a92:	1a078763          	beqz	a5,ffffffffc0201c40 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0201a96:	000a3603          	ld	a2,0(s4)
ffffffffc0201a9a:	46c1                	li	a3,16
ffffffffc0201a9c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201a9e:	000d879b          	sext.w	a5,s11
ffffffffc0201aa2:	876a                	mv	a4,s10
ffffffffc0201aa4:	85ca                	mv	a1,s2
ffffffffc0201aa6:	8526                	mv	a0,s1
ffffffffc0201aa8:	e71ff0ef          	jal	ffffffffc0201918 <printnum>
            break;
ffffffffc0201aac:	b719                	j	ffffffffc02019b2 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0201aae:	000a2503          	lw	a0,0(s4)
ffffffffc0201ab2:	85ca                	mv	a1,s2
ffffffffc0201ab4:	0a21                	addi	s4,s4,8
ffffffffc0201ab6:	9482                	jalr	s1
            break;
ffffffffc0201ab8:	bded                	j	ffffffffc02019b2 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201aba:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201abc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201ac0:	00f74463          	blt	a4,a5,ffffffffc0201ac8 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201ac4:	16078963          	beqz	a5,ffffffffc0201c36 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0201ac8:	000a3603          	ld	a2,0(s4)
ffffffffc0201acc:	46a9                	li	a3,10
ffffffffc0201ace:	8a2e                	mv	s4,a1
ffffffffc0201ad0:	b7f9                	j	ffffffffc0201a9e <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0201ad2:	85ca                	mv	a1,s2
ffffffffc0201ad4:	03000513          	li	a0,48
ffffffffc0201ad8:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc0201ada:	85ca                	mv	a1,s2
ffffffffc0201adc:	07800513          	li	a0,120
ffffffffc0201ae0:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201ae2:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0201ae6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201ae8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201aea:	bf55                	j	ffffffffc0201a9e <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc0201aec:	85ca                	mv	a1,s2
ffffffffc0201aee:	02500513          	li	a0,37
ffffffffc0201af2:	9482                	jalr	s1
            break;
ffffffffc0201af4:	bd7d                	j	ffffffffc02019b2 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0201af6:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201afa:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0201afc:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0201afe:	bf95                	j	ffffffffc0201a72 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0201b00:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b02:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b06:	00f74463          	blt	a4,a5,ffffffffc0201b0e <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0201b0a:	12078163          	beqz	a5,ffffffffc0201c2c <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc0201b0e:	000a3603          	ld	a2,0(s4)
ffffffffc0201b12:	46a1                	li	a3,8
ffffffffc0201b14:	8a2e                	mv	s4,a1
ffffffffc0201b16:	b761                	j	ffffffffc0201a9e <vprintfmt+0x120>
            if (width < 0)
ffffffffc0201b18:	876a                	mv	a4,s10
ffffffffc0201b1a:	000d5363          	bgez	s10,ffffffffc0201b20 <vprintfmt+0x1a2>
ffffffffc0201b1e:	4701                	li	a4,0
ffffffffc0201b20:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b24:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201b26:	bd55                	j	ffffffffc02019da <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc0201b28:	000d841b          	sext.w	s0,s11
ffffffffc0201b2c:	fd340793          	addi	a5,s0,-45
ffffffffc0201b30:	00f037b3          	snez	a5,a5
ffffffffc0201b34:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201b38:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc0201b3c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201b3e:	008a0793          	addi	a5,s4,8
ffffffffc0201b42:	e43e                	sd	a5,8(sp)
ffffffffc0201b44:	100d8c63          	beqz	s11,ffffffffc0201c5c <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0201b48:	12071363          	bnez	a4,ffffffffc0201c6e <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b4c:	000dc783          	lbu	a5,0(s11)
ffffffffc0201b50:	0007851b          	sext.w	a0,a5
ffffffffc0201b54:	c78d                	beqz	a5,ffffffffc0201b7e <vprintfmt+0x200>
ffffffffc0201b56:	0d85                	addi	s11,s11,1
ffffffffc0201b58:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b5a:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b5e:	000cc563          	bltz	s9,ffffffffc0201b68 <vprintfmt+0x1ea>
ffffffffc0201b62:	3cfd                	addiw	s9,s9,-1
ffffffffc0201b64:	008c8d63          	beq	s9,s0,ffffffffc0201b7e <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b68:	020b9663          	bnez	s7,ffffffffc0201b94 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc0201b6c:	85ca                	mv	a1,s2
ffffffffc0201b6e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b70:	000dc783          	lbu	a5,0(s11)
ffffffffc0201b74:	0d85                	addi	s11,s11,1
ffffffffc0201b76:	3d7d                	addiw	s10,s10,-1
ffffffffc0201b78:	0007851b          	sext.w	a0,a5
ffffffffc0201b7c:	f3ed                	bnez	a5,ffffffffc0201b5e <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc0201b7e:	01a05963          	blez	s10,ffffffffc0201b90 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0201b82:	85ca                	mv	a1,s2
ffffffffc0201b84:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0201b88:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0201b8a:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0201b8c:	fe0d1be3          	bnez	s10,ffffffffc0201b82 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201b90:	6a22                	ld	s4,8(sp)
ffffffffc0201b92:	b505                	j	ffffffffc02019b2 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b94:	3781                	addiw	a5,a5,-32
ffffffffc0201b96:	fcfa7be3          	bgeu	s4,a5,ffffffffc0201b6c <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0201b9a:	03f00513          	li	a0,63
ffffffffc0201b9e:	85ca                	mv	a1,s2
ffffffffc0201ba0:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ba2:	000dc783          	lbu	a5,0(s11)
ffffffffc0201ba6:	0d85                	addi	s11,s11,1
ffffffffc0201ba8:	3d7d                	addiw	s10,s10,-1
ffffffffc0201baa:	0007851b          	sext.w	a0,a5
ffffffffc0201bae:	dbe1                	beqz	a5,ffffffffc0201b7e <vprintfmt+0x200>
ffffffffc0201bb0:	fa0cd9e3          	bgez	s9,ffffffffc0201b62 <vprintfmt+0x1e4>
ffffffffc0201bb4:	b7c5                	j	ffffffffc0201b94 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0201bb6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201bba:	4619                	li	a2,6
            err = va_arg(ap, int);
ffffffffc0201bbc:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201bbe:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0201bc2:	8fb9                	xor	a5,a5,a4
ffffffffc0201bc4:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201bc8:	02d64563          	blt	a2,a3,ffffffffc0201bf2 <vprintfmt+0x274>
ffffffffc0201bcc:	00001797          	auipc	a5,0x1
ffffffffc0201bd0:	2e478793          	addi	a5,a5,740 # ffffffffc0202eb0 <error_string>
ffffffffc0201bd4:	00369713          	slli	a4,a3,0x3
ffffffffc0201bd8:	97ba                	add	a5,a5,a4
ffffffffc0201bda:	639c                	ld	a5,0(a5)
ffffffffc0201bdc:	cb99                	beqz	a5,ffffffffc0201bf2 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201bde:	86be                	mv	a3,a5
ffffffffc0201be0:	00001617          	auipc	a2,0x1
ffffffffc0201be4:	04060613          	addi	a2,a2,64 # ffffffffc0202c20 <etext+0xd68>
ffffffffc0201be8:	85ca                	mv	a1,s2
ffffffffc0201bea:	8526                	mv	a0,s1
ffffffffc0201bec:	0d8000ef          	jal	ffffffffc0201cc4 <printfmt>
ffffffffc0201bf0:	b3c9                	j	ffffffffc02019b2 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201bf2:	00001617          	auipc	a2,0x1
ffffffffc0201bf6:	01e60613          	addi	a2,a2,30 # ffffffffc0202c10 <etext+0xd58>
ffffffffc0201bfa:	85ca                	mv	a1,s2
ffffffffc0201bfc:	8526                	mv	a0,s1
ffffffffc0201bfe:	0c6000ef          	jal	ffffffffc0201cc4 <printfmt>
ffffffffc0201c02:	bb45                	j	ffffffffc02019b2 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201c04:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c06:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0201c0a:	00f74363          	blt	a4,a5,ffffffffc0201c10 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc0201c0e:	cf81                	beqz	a5,ffffffffc0201c26 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc0201c10:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201c14:	02044b63          	bltz	s0,ffffffffc0201c4a <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0201c18:	8622                	mv	a2,s0
ffffffffc0201c1a:	8a5e                	mv	s4,s7
ffffffffc0201c1c:	46a9                	li	a3,10
ffffffffc0201c1e:	b541                	j	ffffffffc0201a9e <vprintfmt+0x120>
            lflag ++;
ffffffffc0201c20:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c22:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201c24:	bb5d                	j	ffffffffc02019da <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0201c26:	000a2403          	lw	s0,0(s4)
ffffffffc0201c2a:	b7ed                	j	ffffffffc0201c14 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc0201c2c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c30:	46a1                	li	a3,8
ffffffffc0201c32:	8a2e                	mv	s4,a1
ffffffffc0201c34:	b5ad                	j	ffffffffc0201a9e <vprintfmt+0x120>
ffffffffc0201c36:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c3a:	46a9                	li	a3,10
ffffffffc0201c3c:	8a2e                	mv	s4,a1
ffffffffc0201c3e:	b585                	j	ffffffffc0201a9e <vprintfmt+0x120>
ffffffffc0201c40:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c44:	46c1                	li	a3,16
ffffffffc0201c46:	8a2e                	mv	s4,a1
ffffffffc0201c48:	bd99                	j	ffffffffc0201a9e <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc0201c4a:	85ca                	mv	a1,s2
ffffffffc0201c4c:	02d00513          	li	a0,45
ffffffffc0201c50:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc0201c52:	40800633          	neg	a2,s0
ffffffffc0201c56:	8a5e                	mv	s4,s7
ffffffffc0201c58:	46a9                	li	a3,10
ffffffffc0201c5a:	b591                	j	ffffffffc0201a9e <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc0201c5c:	e329                	bnez	a4,ffffffffc0201c9e <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c5e:	02800793          	li	a5,40
ffffffffc0201c62:	853e                	mv	a0,a5
ffffffffc0201c64:	00001d97          	auipc	s11,0x1
ffffffffc0201c68:	fa5d8d93          	addi	s11,s11,-91 # ffffffffc0202c09 <etext+0xd51>
ffffffffc0201c6c:	b5f5                	j	ffffffffc0201b58 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c6e:	85e6                	mv	a1,s9
ffffffffc0201c70:	856e                	mv	a0,s11
ffffffffc0201c72:	1aa000ef          	jal	ffffffffc0201e1c <strnlen>
ffffffffc0201c76:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0201c7a:	01a05863          	blez	s10,ffffffffc0201c8a <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc0201c7e:	85ca                	mv	a1,s2
ffffffffc0201c80:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c82:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0201c84:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c86:	fe0d1ce3          	bnez	s10,ffffffffc0201c7e <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c8a:	000dc783          	lbu	a5,0(s11)
ffffffffc0201c8e:	0007851b          	sext.w	a0,a5
ffffffffc0201c92:	ec0792e3          	bnez	a5,ffffffffc0201b56 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c96:	6a22                	ld	s4,8(sp)
ffffffffc0201c98:	bb29                	j	ffffffffc02019b2 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c9a:	8462                	mv	s0,s8
ffffffffc0201c9c:	bbd9                	j	ffffffffc0201a72 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c9e:	85e6                	mv	a1,s9
ffffffffc0201ca0:	00001517          	auipc	a0,0x1
ffffffffc0201ca4:	f6850513          	addi	a0,a0,-152 # ffffffffc0202c08 <etext+0xd50>
ffffffffc0201ca8:	174000ef          	jal	ffffffffc0201e1c <strnlen>
ffffffffc0201cac:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cb0:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0201cb4:	00001d97          	auipc	s11,0x1
ffffffffc0201cb8:	f54d8d93          	addi	s11,s11,-172 # ffffffffc0202c08 <etext+0xd50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cbc:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cbe:	fda040e3          	bgtz	s10,ffffffffc0201c7e <vprintfmt+0x300>
ffffffffc0201cc2:	bd51                	j	ffffffffc0201b56 <vprintfmt+0x1d8>

ffffffffc0201cc4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201cc4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201cc6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201cca:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201ccc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201cce:	ec06                	sd	ra,24(sp)
ffffffffc0201cd0:	f83a                	sd	a4,48(sp)
ffffffffc0201cd2:	fc3e                	sd	a5,56(sp)
ffffffffc0201cd4:	e0c2                	sd	a6,64(sp)
ffffffffc0201cd6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201cd8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201cda:	ca5ff0ef          	jal	ffffffffc020197e <vprintfmt>
}
ffffffffc0201cde:	60e2                	ld	ra,24(sp)
ffffffffc0201ce0:	6161                	addi	sp,sp,80
ffffffffc0201ce2:	8082                	ret

ffffffffc0201ce4 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201ce4:	7179                	addi	sp,sp,-48
ffffffffc0201ce6:	f406                	sd	ra,40(sp)
ffffffffc0201ce8:	f022                	sd	s0,32(sp)
ffffffffc0201cea:	ec26                	sd	s1,24(sp)
ffffffffc0201cec:	e84a                	sd	s2,16(sp)
ffffffffc0201cee:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc0201cf0:	c901                	beqz	a0,ffffffffc0201d00 <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc0201cf2:	85aa                	mv	a1,a0
ffffffffc0201cf4:	00001517          	auipc	a0,0x1
ffffffffc0201cf8:	f2c50513          	addi	a0,a0,-212 # ffffffffc0202c20 <etext+0xd68>
ffffffffc0201cfc:	bdafe0ef          	jal	ffffffffc02000d6 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc0201d00:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d02:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc0201d04:	00004997          	auipc	s3,0x4
ffffffffc0201d08:	33c98993          	addi	s3,s3,828 # ffffffffc0206040 <buf>
        c = getchar();
ffffffffc0201d0c:	c4cfe0ef          	jal	ffffffffc0200158 <getchar>
ffffffffc0201d10:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201d12:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d16:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201d1a:	ff650693          	addi	a3,a0,-10
ffffffffc0201d1e:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0201d22:	02054963          	bltz	a0,ffffffffc0201d54 <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d26:	02a95f63          	bge	s2,a0,ffffffffc0201d64 <readline+0x80>
ffffffffc0201d2a:	cf0d                	beqz	a4,ffffffffc0201d64 <readline+0x80>
            cputchar(c);
ffffffffc0201d2c:	bdefe0ef          	jal	ffffffffc020010a <cputchar>
            buf[i ++] = c;
ffffffffc0201d30:	009987b3          	add	a5,s3,s1
ffffffffc0201d34:	00878023          	sb	s0,0(a5)
ffffffffc0201d38:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc0201d3a:	c1efe0ef          	jal	ffffffffc0200158 <getchar>
ffffffffc0201d3e:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc0201d40:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d44:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc0201d48:	ff650693          	addi	a3,a0,-10
ffffffffc0201d4c:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0201d50:	fc055be3          	bgez	a0,ffffffffc0201d26 <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc0201d54:	70a2                	ld	ra,40(sp)
ffffffffc0201d56:	7402                	ld	s0,32(sp)
ffffffffc0201d58:	64e2                	ld	s1,24(sp)
ffffffffc0201d5a:	6942                	ld	s2,16(sp)
ffffffffc0201d5c:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc0201d5e:	4501                	li	a0,0
}
ffffffffc0201d60:	6145                	addi	sp,sp,48
ffffffffc0201d62:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc0201d64:	eb81                	bnez	a5,ffffffffc0201d74 <readline+0x90>
            cputchar(c);
ffffffffc0201d66:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc0201d68:	00905663          	blez	s1,ffffffffc0201d74 <readline+0x90>
            cputchar(c);
ffffffffc0201d6c:	b9efe0ef          	jal	ffffffffc020010a <cputchar>
            i --;
ffffffffc0201d70:	34fd                	addiw	s1,s1,-1
ffffffffc0201d72:	bf69                	j	ffffffffc0201d0c <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc0201d74:	c291                	beqz	a3,ffffffffc0201d78 <readline+0x94>
ffffffffc0201d76:	fa59                	bnez	a2,ffffffffc0201d0c <readline+0x28>
            cputchar(c);
ffffffffc0201d78:	8522                	mv	a0,s0
ffffffffc0201d7a:	b90fe0ef          	jal	ffffffffc020010a <cputchar>
            buf[i] = '\0';
ffffffffc0201d7e:	00004517          	auipc	a0,0x4
ffffffffc0201d82:	2c250513          	addi	a0,a0,706 # ffffffffc0206040 <buf>
ffffffffc0201d86:	94aa                	add	s1,s1,a0
ffffffffc0201d88:	00048023          	sb	zero,0(s1)
}
ffffffffc0201d8c:	70a2                	ld	ra,40(sp)
ffffffffc0201d8e:	7402                	ld	s0,32(sp)
ffffffffc0201d90:	64e2                	ld	s1,24(sp)
ffffffffc0201d92:	6942                	ld	s2,16(sp)
ffffffffc0201d94:	69a2                	ld	s3,8(sp)
ffffffffc0201d96:	6145                	addi	sp,sp,48
ffffffffc0201d98:	8082                	ret

ffffffffc0201d9a <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201d9a:	00004717          	auipc	a4,0x4
ffffffffc0201d9e:	28673703          	ld	a4,646(a4) # ffffffffc0206020 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201da2:	4781                	li	a5,0
ffffffffc0201da4:	88ba                	mv	a7,a4
ffffffffc0201da6:	852a                	mv	a0,a0
ffffffffc0201da8:	85be                	mv	a1,a5
ffffffffc0201daa:	863e                	mv	a2,a5
ffffffffc0201dac:	00000073          	ecall
ffffffffc0201db0:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201db2:	8082                	ret

ffffffffc0201db4 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201db4:	00004717          	auipc	a4,0x4
ffffffffc0201db8:	6e473703          	ld	a4,1764(a4) # ffffffffc0206498 <SBI_SET_TIMER>
ffffffffc0201dbc:	4781                	li	a5,0
ffffffffc0201dbe:	88ba                	mv	a7,a4
ffffffffc0201dc0:	852a                	mv	a0,a0
ffffffffc0201dc2:	85be                	mv	a1,a5
ffffffffc0201dc4:	863e                	mv	a2,a5
ffffffffc0201dc6:	00000073          	ecall
ffffffffc0201dca:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201dcc:	8082                	ret

ffffffffc0201dce <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201dce:	00004797          	auipc	a5,0x4
ffffffffc0201dd2:	24a7b783          	ld	a5,586(a5) # ffffffffc0206018 <SBI_CONSOLE_GETCHAR>
ffffffffc0201dd6:	4501                	li	a0,0
ffffffffc0201dd8:	88be                	mv	a7,a5
ffffffffc0201dda:	852a                	mv	a0,a0
ffffffffc0201ddc:	85aa                	mv	a1,a0
ffffffffc0201dde:	862a                	mv	a2,a0
ffffffffc0201de0:	00000073          	ecall
ffffffffc0201de4:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201de6:	2501                	sext.w	a0,a0
ffffffffc0201de8:	8082                	ret

ffffffffc0201dea <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201dea:	00004717          	auipc	a4,0x4
ffffffffc0201dee:	22673703          	ld	a4,550(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc0201df2:	4781                	li	a5,0
ffffffffc0201df4:	88ba                	mv	a7,a4
ffffffffc0201df6:	853e                	mv	a0,a5
ffffffffc0201df8:	85be                	mv	a1,a5
ffffffffc0201dfa:	863e                	mv	a2,a5
ffffffffc0201dfc:	00000073          	ecall
ffffffffc0201e00:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201e02:	8082                	ret

ffffffffc0201e04 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201e04:	00054783          	lbu	a5,0(a0)
ffffffffc0201e08:	cb81                	beqz	a5,ffffffffc0201e18 <strlen+0x14>
    size_t cnt = 0;
ffffffffc0201e0a:	4781                	li	a5,0
        cnt ++;
ffffffffc0201e0c:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0201e0e:	00f50733          	add	a4,a0,a5
ffffffffc0201e12:	00074703          	lbu	a4,0(a4)
ffffffffc0201e16:	fb7d                	bnez	a4,ffffffffc0201e0c <strlen+0x8>
    }
    return cnt;
}
ffffffffc0201e18:	853e                	mv	a0,a5
ffffffffc0201e1a:	8082                	ret

ffffffffc0201e1c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201e1c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201e1e:	e589                	bnez	a1,ffffffffc0201e28 <strnlen+0xc>
ffffffffc0201e20:	a811                	j	ffffffffc0201e34 <strnlen+0x18>
        cnt ++;
ffffffffc0201e22:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201e24:	00f58863          	beq	a1,a5,ffffffffc0201e34 <strnlen+0x18>
ffffffffc0201e28:	00f50733          	add	a4,a0,a5
ffffffffc0201e2c:	00074703          	lbu	a4,0(a4)
ffffffffc0201e30:	fb6d                	bnez	a4,ffffffffc0201e22 <strnlen+0x6>
ffffffffc0201e32:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201e34:	852e                	mv	a0,a1
ffffffffc0201e36:	8082                	ret

ffffffffc0201e38 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201e38:	00054783          	lbu	a5,0(a0)
ffffffffc0201e3c:	e791                	bnez	a5,ffffffffc0201e48 <strcmp+0x10>
ffffffffc0201e3e:	a01d                	j	ffffffffc0201e64 <strcmp+0x2c>
ffffffffc0201e40:	00054783          	lbu	a5,0(a0)
ffffffffc0201e44:	cb99                	beqz	a5,ffffffffc0201e5a <strcmp+0x22>
ffffffffc0201e46:	0585                	addi	a1,a1,1 # fffffffffff80001 <end+0x3fd79b61>
ffffffffc0201e48:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0201e4c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201e4e:	fef709e3          	beq	a4,a5,ffffffffc0201e40 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201e52:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201e56:	9d19                	subw	a0,a0,a4
ffffffffc0201e58:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201e5a:	0015c703          	lbu	a4,1(a1)
ffffffffc0201e5e:	4501                	li	a0,0
}
ffffffffc0201e60:	9d19                	subw	a0,a0,a4
ffffffffc0201e62:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201e64:	0005c703          	lbu	a4,0(a1)
ffffffffc0201e68:	4501                	li	a0,0
ffffffffc0201e6a:	b7f5                	j	ffffffffc0201e56 <strcmp+0x1e>

ffffffffc0201e6c <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201e6c:	ce01                	beqz	a2,ffffffffc0201e84 <strncmp+0x18>
ffffffffc0201e6e:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201e72:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201e74:	cb91                	beqz	a5,ffffffffc0201e88 <strncmp+0x1c>
ffffffffc0201e76:	0005c703          	lbu	a4,0(a1)
ffffffffc0201e7a:	00f71763          	bne	a4,a5,ffffffffc0201e88 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0201e7e:	0505                	addi	a0,a0,1
ffffffffc0201e80:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201e82:	f675                	bnez	a2,ffffffffc0201e6e <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201e84:	4501                	li	a0,0
ffffffffc0201e86:	8082                	ret
ffffffffc0201e88:	00054503          	lbu	a0,0(a0)
ffffffffc0201e8c:	0005c783          	lbu	a5,0(a1)
ffffffffc0201e90:	9d1d                	subw	a0,a0,a5
}
ffffffffc0201e92:	8082                	ret

ffffffffc0201e94 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201e94:	a021                	j	ffffffffc0201e9c <strchr+0x8>
        if (*s == c) {
ffffffffc0201e96:	00f58763          	beq	a1,a5,ffffffffc0201ea4 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0201e9a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201e9c:	00054783          	lbu	a5,0(a0)
ffffffffc0201ea0:	fbfd                	bnez	a5,ffffffffc0201e96 <strchr+0x2>
    }
    return NULL;
ffffffffc0201ea2:	4501                	li	a0,0
}
ffffffffc0201ea4:	8082                	ret

ffffffffc0201ea6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201ea6:	ca01                	beqz	a2,ffffffffc0201eb6 <memset+0x10>
ffffffffc0201ea8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201eaa:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201eac:	0785                	addi	a5,a5,1
ffffffffc0201eae:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201eb2:	fef61de3          	bne	a2,a5,ffffffffc0201eac <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201eb6:	8082                	ret
