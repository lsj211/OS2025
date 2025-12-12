
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000b297          	auipc	t0,0xb
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020b000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000b297          	auipc	t0,0xb
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020b008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc020003c:	c020a137          	lui	sp,0xc020a

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	00097517          	auipc	a0,0x97
ffffffffc020004e:	46e50513          	addi	a0,a0,1134 # ffffffffc02974b8 <buf>
ffffffffc0200052:	0009c617          	auipc	a2,0x9c
ffffffffc0200056:	90e60613          	addi	a2,a2,-1778 # ffffffffc029b960 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc0209ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	097050ef          	jal	ffffffffc02058f8 <memset>
    dtb_init();
ffffffffc0200066:	552000ef          	jal	ffffffffc02005b8 <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	4dc000ef          	jal	ffffffffc0200546 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	8ba58593          	addi	a1,a1,-1862 # ffffffffc0205928 <etext+0x6>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	8d250513          	addi	a0,a0,-1838 # ffffffffc0205948 <etext+0x26>
ffffffffc020007e:	116000ef          	jal	ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	1a4000ef          	jal	ffffffffc0200226 <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	740020ef          	jal	ffffffffc02027c6 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	081000ef          	jal	ffffffffc020090a <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	07f000ef          	jal	ffffffffc020090c <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	345030ef          	jal	ffffffffc0203bd6 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	7ad040ef          	jal	ffffffffc0205042 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	45a000ef          	jal	ffffffffc02004f4 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	061000ef          	jal	ffffffffc02008fe <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	140050ef          	jal	ffffffffc02051e2 <cpu_idle>

ffffffffc02000a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000a6:	7179                	addi	sp,sp,-48
ffffffffc02000a8:	f406                	sd	ra,40(sp)
ffffffffc02000aa:	f022                	sd	s0,32(sp)
ffffffffc02000ac:	ec26                	sd	s1,24(sp)
ffffffffc02000ae:	e84a                	sd	s2,16(sp)
ffffffffc02000b0:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc02000b2:	c901                	beqz	a0,ffffffffc02000c2 <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc02000b4:	85aa                	mv	a1,a0
ffffffffc02000b6:	00006517          	auipc	a0,0x6
ffffffffc02000ba:	89a50513          	addi	a0,a0,-1894 # ffffffffc0205950 <etext+0x2e>
ffffffffc02000be:	0d6000ef          	jal	ffffffffc0200194 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02000c2:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c4:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc02000c6:	00097997          	auipc	s3,0x97
ffffffffc02000ca:	3f298993          	addi	s3,s3,1010 # ffffffffc02974b8 <buf>
        c = getchar();
ffffffffc02000ce:	148000ef          	jal	ffffffffc0200216 <getchar>
ffffffffc02000d2:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000d4:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d8:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000dc:	ff650693          	addi	a3,a0,-10
ffffffffc02000e0:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc02000e4:	02054963          	bltz	a0,ffffffffc0200116 <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000e8:	02a95f63          	bge	s2,a0,ffffffffc0200126 <readline+0x80>
ffffffffc02000ec:	cf0d                	beqz	a4,ffffffffc0200126 <readline+0x80>
            cputchar(c);
ffffffffc02000ee:	0da000ef          	jal	ffffffffc02001c8 <cputchar>
            buf[i ++] = c;
ffffffffc02000f2:	009987b3          	add	a5,s3,s1
ffffffffc02000f6:	00878023          	sb	s0,0(a5)
ffffffffc02000fa:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc02000fc:	11a000ef          	jal	ffffffffc0200216 <getchar>
ffffffffc0200100:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc0200102:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200106:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc020010a:	ff650693          	addi	a3,a0,-10
ffffffffc020010e:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0200112:	fc055be3          	bgez	a0,ffffffffc02000e8 <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc0200116:	70a2                	ld	ra,40(sp)
ffffffffc0200118:	7402                	ld	s0,32(sp)
ffffffffc020011a:	64e2                	ld	s1,24(sp)
ffffffffc020011c:	6942                	ld	s2,16(sp)
ffffffffc020011e:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc0200120:	4501                	li	a0,0
}
ffffffffc0200122:	6145                	addi	sp,sp,48
ffffffffc0200124:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc0200126:	eb81                	bnez	a5,ffffffffc0200136 <readline+0x90>
            cputchar(c);
ffffffffc0200128:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc020012a:	00905663          	blez	s1,ffffffffc0200136 <readline+0x90>
            cputchar(c);
ffffffffc020012e:	09a000ef          	jal	ffffffffc02001c8 <cputchar>
            i --;
ffffffffc0200132:	34fd                	addiw	s1,s1,-1
ffffffffc0200134:	bf69                	j	ffffffffc02000ce <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc0200136:	c291                	beqz	a3,ffffffffc020013a <readline+0x94>
ffffffffc0200138:	fa59                	bnez	a2,ffffffffc02000ce <readline+0x28>
            cputchar(c);
ffffffffc020013a:	8522                	mv	a0,s0
ffffffffc020013c:	08c000ef          	jal	ffffffffc02001c8 <cputchar>
            buf[i] = '\0';
ffffffffc0200140:	00097517          	auipc	a0,0x97
ffffffffc0200144:	37850513          	addi	a0,a0,888 # ffffffffc02974b8 <buf>
ffffffffc0200148:	94aa                	add	s1,s1,a0
ffffffffc020014a:	00048023          	sb	zero,0(s1)
}
ffffffffc020014e:	70a2                	ld	ra,40(sp)
ffffffffc0200150:	7402                	ld	s0,32(sp)
ffffffffc0200152:	64e2                	ld	s1,24(sp)
ffffffffc0200154:	6942                	ld	s2,16(sp)
ffffffffc0200156:	69a2                	ld	s3,8(sp)
ffffffffc0200158:	6145                	addi	sp,sp,48
ffffffffc020015a:	8082                	ret

ffffffffc020015c <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015c:	1101                	addi	sp,sp,-32
ffffffffc020015e:	ec06                	sd	ra,24(sp)
ffffffffc0200160:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc0200162:	3e6000ef          	jal	ffffffffc0200548 <cons_putc>
    (*cnt)++;
ffffffffc0200166:	65a2                	ld	a1,8(sp)
}
ffffffffc0200168:	60e2                	ld	ra,24(sp)
    (*cnt)++;
ffffffffc020016a:	419c                	lw	a5,0(a1)
ffffffffc020016c:	2785                	addiw	a5,a5,1
ffffffffc020016e:	c19c                	sw	a5,0(a1)
}
ffffffffc0200170:	6105                	addi	sp,sp,32
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe250513          	addi	a0,a0,-30 # ffffffffc020015c <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
{
ffffffffc0200184:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200186:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200188:	356050ef          	jal	ffffffffc02054de <vprintfmt>
    return cnt;
}
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200194:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200196:	02810313          	addi	t1,sp,40
{
ffffffffc020019a:	f42e                	sd	a1,40(sp)
ffffffffc020019c:	f832                	sd	a2,48(sp)
ffffffffc020019e:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a0:	862a                	mv	a2,a0
ffffffffc02001a2:	004c                	addi	a1,sp,4
ffffffffc02001a4:	00000517          	auipc	a0,0x0
ffffffffc02001a8:	fb850513          	addi	a0,a0,-72 # ffffffffc020015c <cputch>
ffffffffc02001ac:	869a                	mv	a3,t1
{
ffffffffc02001ae:	ec06                	sd	ra,24(sp)
ffffffffc02001b0:	e0ba                	sd	a4,64(sp)
ffffffffc02001b2:	e4be                	sd	a5,72(sp)
ffffffffc02001b4:	e8c2                	sd	a6,80(sp)
ffffffffc02001b6:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc02001b8:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001bc:	322050ef          	jal	ffffffffc02054de <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c0:	60e2                	ld	ra,24(sp)
ffffffffc02001c2:	4512                	lw	a0,4(sp)
ffffffffc02001c4:	6125                	addi	sp,sp,96
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001c8:	a641                	j	ffffffffc0200548 <cons_putc>

ffffffffc02001ca <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc02001ca:	1101                	addi	sp,sp,-32
ffffffffc02001cc:	e822                	sd	s0,16(sp)
ffffffffc02001ce:	ec06                	sd	ra,24(sp)
ffffffffc02001d0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc02001d2:	00054503          	lbu	a0,0(a0)
ffffffffc02001d6:	c51d                	beqz	a0,ffffffffc0200204 <cputs+0x3a>
ffffffffc02001d8:	e426                	sd	s1,8(sp)
ffffffffc02001da:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc02001dc:	4481                	li	s1,0
    cons_putc(c);
ffffffffc02001de:	36a000ef          	jal	ffffffffc0200548 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc02001e2:	00044503          	lbu	a0,0(s0)
ffffffffc02001e6:	0405                	addi	s0,s0,1
ffffffffc02001e8:	87a6                	mv	a5,s1
    (*cnt)++;
ffffffffc02001ea:	2485                	addiw	s1,s1,1
    while ((c = *str++) != '\0')
ffffffffc02001ec:	f96d                	bnez	a0,ffffffffc02001de <cputs+0x14>
    cons_putc(c);
ffffffffc02001ee:	4529                	li	a0,10
    (*cnt)++;
ffffffffc02001f0:	0027841b          	addiw	s0,a5,2
ffffffffc02001f4:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001f6:	352000ef          	jal	ffffffffc0200548 <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001fa:	60e2                	ld	ra,24(sp)
ffffffffc02001fc:	8522                	mv	a0,s0
ffffffffc02001fe:	6442                	ld	s0,16(sp)
ffffffffc0200200:	6105                	addi	sp,sp,32
ffffffffc0200202:	8082                	ret
    cons_putc(c);
ffffffffc0200204:	4529                	li	a0,10
ffffffffc0200206:	342000ef          	jal	ffffffffc0200548 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc020020a:	4405                	li	s0,1
}
ffffffffc020020c:	60e2                	ld	ra,24(sp)
ffffffffc020020e:	8522                	mv	a0,s0
ffffffffc0200210:	6442                	ld	s0,16(sp)
ffffffffc0200212:	6105                	addi	sp,sp,32
ffffffffc0200214:	8082                	ret

ffffffffc0200216 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc0200216:	1141                	addi	sp,sp,-16
ffffffffc0200218:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020021a:	362000ef          	jal	ffffffffc020057c <cons_getc>
ffffffffc020021e:	dd75                	beqz	a0,ffffffffc020021a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200220:	60a2                	ld	ra,8(sp)
ffffffffc0200222:	0141                	addi	sp,sp,16
ffffffffc0200224:	8082                	ret

ffffffffc0200226 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc0200226:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	00005517          	auipc	a0,0x5
ffffffffc020022c:	73050513          	addi	a0,a0,1840 # ffffffffc0205958 <etext+0x36>
{
ffffffffc0200230:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200232:	f63ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200236:	00000597          	auipc	a1,0x0
ffffffffc020023a:	e1458593          	addi	a1,a1,-492 # ffffffffc020004a <kern_init>
ffffffffc020023e:	00005517          	auipc	a0,0x5
ffffffffc0200242:	73a50513          	addi	a0,a0,1850 # ffffffffc0205978 <etext+0x56>
ffffffffc0200246:	f4fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020024a:	00005597          	auipc	a1,0x5
ffffffffc020024e:	6d858593          	addi	a1,a1,1752 # ffffffffc0205922 <etext>
ffffffffc0200252:	00005517          	auipc	a0,0x5
ffffffffc0200256:	74650513          	addi	a0,a0,1862 # ffffffffc0205998 <etext+0x76>
ffffffffc020025a:	f3bff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025e:	00097597          	auipc	a1,0x97
ffffffffc0200262:	25a58593          	addi	a1,a1,602 # ffffffffc02974b8 <buf>
ffffffffc0200266:	00005517          	auipc	a0,0x5
ffffffffc020026a:	75250513          	addi	a0,a0,1874 # ffffffffc02059b8 <etext+0x96>
ffffffffc020026e:	f27ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200272:	0009b597          	auipc	a1,0x9b
ffffffffc0200276:	6ee58593          	addi	a1,a1,1774 # ffffffffc029b960 <end>
ffffffffc020027a:	00005517          	auipc	a0,0x5
ffffffffc020027e:	75e50513          	addi	a0,a0,1886 # ffffffffc02059d8 <etext+0xb6>
ffffffffc0200282:	f13ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200286:	00000717          	auipc	a4,0x0
ffffffffc020028a:	dc470713          	addi	a4,a4,-572 # ffffffffc020004a <kern_init>
ffffffffc020028e:	0009c797          	auipc	a5,0x9c
ffffffffc0200292:	ad178793          	addi	a5,a5,-1327 # ffffffffc029bd5f <end+0x3ff>
ffffffffc0200296:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200298:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020029c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a2:	95be                	add	a1,a1,a5
ffffffffc02002a4:	85a9                	srai	a1,a1,0xa
ffffffffc02002a6:	00005517          	auipc	a0,0x5
ffffffffc02002aa:	75250513          	addi	a0,a0,1874 # ffffffffc02059f8 <etext+0xd6>
}
ffffffffc02002ae:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	b5d5                	j	ffffffffc0200194 <cprintf>

ffffffffc02002b2 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b4:	00005617          	auipc	a2,0x5
ffffffffc02002b8:	77460613          	addi	a2,a2,1908 # ffffffffc0205a28 <etext+0x106>
ffffffffc02002bc:	04f00593          	li	a1,79
ffffffffc02002c0:	00005517          	auipc	a0,0x5
ffffffffc02002c4:	78050513          	addi	a0,a0,1920 # ffffffffc0205a40 <etext+0x11e>
{
ffffffffc02002c8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ca:	17c000ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02002ce <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02002ce:	1101                	addi	sp,sp,-32
ffffffffc02002d0:	e822                	sd	s0,16(sp)
ffffffffc02002d2:	e426                	sd	s1,8(sp)
ffffffffc02002d4:	ec06                	sd	ra,24(sp)
ffffffffc02002d6:	00007417          	auipc	s0,0x7
ffffffffc02002da:	3ca40413          	addi	s0,s0,970 # ffffffffc02076a0 <commands>
ffffffffc02002de:	00007497          	auipc	s1,0x7
ffffffffc02002e2:	40a48493          	addi	s1,s1,1034 # ffffffffc02076e8 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e6:	6410                	ld	a2,8(s0)
ffffffffc02002e8:	600c                	ld	a1,0(s0)
ffffffffc02002ea:	00005517          	auipc	a0,0x5
ffffffffc02002ee:	76e50513          	addi	a0,a0,1902 # ffffffffc0205a58 <etext+0x136>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02002f2:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002f4:	ea1ff0ef          	jal	ffffffffc0200194 <cprintf>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02002f8:	fe9417e3          	bne	s0,s1,ffffffffc02002e6 <mon_help+0x18>
    }
    return 0;
}
ffffffffc02002fc:	60e2                	ld	ra,24(sp)
ffffffffc02002fe:	6442                	ld	s0,16(sp)
ffffffffc0200300:	64a2                	ld	s1,8(sp)
ffffffffc0200302:	4501                	li	a0,0
ffffffffc0200304:	6105                	addi	sp,sp,32
ffffffffc0200306:	8082                	ret

ffffffffc0200308 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200308:	1141                	addi	sp,sp,-16
ffffffffc020030a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020030c:	f1bff0ef          	jal	ffffffffc0200226 <print_kerninfo>
    return 0;
}
ffffffffc0200310:	60a2                	ld	ra,8(sp)
ffffffffc0200312:	4501                	li	a0,0
ffffffffc0200314:	0141                	addi	sp,sp,16
ffffffffc0200316:	8082                	ret

ffffffffc0200318 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200318:	1141                	addi	sp,sp,-16
ffffffffc020031a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020031c:	f97ff0ef          	jal	ffffffffc02002b2 <print_stackframe>
    return 0;
}
ffffffffc0200320:	60a2                	ld	ra,8(sp)
ffffffffc0200322:	4501                	li	a0,0
ffffffffc0200324:	0141                	addi	sp,sp,16
ffffffffc0200326:	8082                	ret

ffffffffc0200328 <kmonitor>:
{
ffffffffc0200328:	7131                	addi	sp,sp,-192
ffffffffc020032a:	e952                	sd	s4,144(sp)
ffffffffc020032c:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020032e:	00005517          	auipc	a0,0x5
ffffffffc0200332:	73a50513          	addi	a0,a0,1850 # ffffffffc0205a68 <etext+0x146>
{
ffffffffc0200336:	fd06                	sd	ra,184(sp)
ffffffffc0200338:	f922                	sd	s0,176(sp)
ffffffffc020033a:	f526                	sd	s1,168(sp)
ffffffffc020033c:	ed4e                	sd	s3,152(sp)
ffffffffc020033e:	e556                	sd	s5,136(sp)
ffffffffc0200340:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200342:	e53ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200346:	00005517          	auipc	a0,0x5
ffffffffc020034a:	74a50513          	addi	a0,a0,1866 # ffffffffc0205a90 <etext+0x16e>
ffffffffc020034e:	e47ff0ef          	jal	ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc0200352:	000a0563          	beqz	s4,ffffffffc020035c <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc0200356:	8552                	mv	a0,s4
ffffffffc0200358:	79c000ef          	jal	ffffffffc0200af4 <print_trapframe>
ffffffffc020035c:	00007a97          	auipc	s5,0x7
ffffffffc0200360:	344a8a93          	addi	s5,s5,836 # ffffffffc02076a0 <commands>
        if (argc == MAXARGS - 1)
ffffffffc0200364:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL)
ffffffffc0200366:	00005517          	auipc	a0,0x5
ffffffffc020036a:	75250513          	addi	a0,a0,1874 # ffffffffc0205ab8 <etext+0x196>
ffffffffc020036e:	d39ff0ef          	jal	ffffffffc02000a6 <readline>
ffffffffc0200372:	842a                	mv	s0,a0
ffffffffc0200374:	d96d                	beqz	a0,ffffffffc0200366 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200376:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020037a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020037c:	e99d                	bnez	a1,ffffffffc02003b2 <kmonitor+0x8a>
    int argc = 0;
ffffffffc020037e:	8b26                	mv	s6,s1
    if (argc == 0)
ffffffffc0200380:	fe0b03e3          	beqz	s6,ffffffffc0200366 <kmonitor+0x3e>
ffffffffc0200384:	00007497          	auipc	s1,0x7
ffffffffc0200388:	31c48493          	addi	s1,s1,796 # ffffffffc02076a0 <commands>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020038c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc020038e:	6582                	ld	a1,0(sp)
ffffffffc0200390:	6088                	ld	a0,0(s1)
ffffffffc0200392:	4f8050ef          	jal	ffffffffc020588a <strcmp>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200396:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200398:	c149                	beqz	a0,ffffffffc020041a <kmonitor+0xf2>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020039a:	2405                	addiw	s0,s0,1
ffffffffc020039c:	04e1                	addi	s1,s1,24
ffffffffc020039e:	fef418e3          	bne	s0,a5,ffffffffc020038e <kmonitor+0x66>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003a2:	6582                	ld	a1,0(sp)
ffffffffc02003a4:	00005517          	auipc	a0,0x5
ffffffffc02003a8:	74450513          	addi	a0,a0,1860 # ffffffffc0205ae8 <etext+0x1c6>
ffffffffc02003ac:	de9ff0ef          	jal	ffffffffc0200194 <cprintf>
    return 0;
ffffffffc02003b0:	bf5d                	j	ffffffffc0200366 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003b2:	00005517          	auipc	a0,0x5
ffffffffc02003b6:	70e50513          	addi	a0,a0,1806 # ffffffffc0205ac0 <etext+0x19e>
ffffffffc02003ba:	52c050ef          	jal	ffffffffc02058e6 <strchr>
ffffffffc02003be:	c901                	beqz	a0,ffffffffc02003ce <kmonitor+0xa6>
ffffffffc02003c0:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc02003c4:	00040023          	sb	zero,0(s0)
ffffffffc02003c8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003ca:	d9d5                	beqz	a1,ffffffffc020037e <kmonitor+0x56>
ffffffffc02003cc:	b7dd                	j	ffffffffc02003b2 <kmonitor+0x8a>
        if (*buf == '\0')
ffffffffc02003ce:	00044783          	lbu	a5,0(s0)
ffffffffc02003d2:	d7d5                	beqz	a5,ffffffffc020037e <kmonitor+0x56>
        if (argc == MAXARGS - 1)
ffffffffc02003d4:	03348b63          	beq	s1,s3,ffffffffc020040a <kmonitor+0xe2>
        argv[argc++] = buf;
ffffffffc02003d8:	00349793          	slli	a5,s1,0x3
ffffffffc02003dc:	978a                	add	a5,a5,sp
ffffffffc02003de:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc02003e0:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc02003e4:	2485                	addiw	s1,s1,1
ffffffffc02003e6:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc02003e8:	e591                	bnez	a1,ffffffffc02003f4 <kmonitor+0xcc>
ffffffffc02003ea:	bf59                	j	ffffffffc0200380 <kmonitor+0x58>
ffffffffc02003ec:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc02003f0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc02003f2:	d5d1                	beqz	a1,ffffffffc020037e <kmonitor+0x56>
ffffffffc02003f4:	00005517          	auipc	a0,0x5
ffffffffc02003f8:	6cc50513          	addi	a0,a0,1740 # ffffffffc0205ac0 <etext+0x19e>
ffffffffc02003fc:	4ea050ef          	jal	ffffffffc02058e6 <strchr>
ffffffffc0200400:	d575                	beqz	a0,ffffffffc02003ec <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200402:	00044583          	lbu	a1,0(s0)
ffffffffc0200406:	dda5                	beqz	a1,ffffffffc020037e <kmonitor+0x56>
ffffffffc0200408:	b76d                	j	ffffffffc02003b2 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020040a:	45c1                	li	a1,16
ffffffffc020040c:	00005517          	auipc	a0,0x5
ffffffffc0200410:	6bc50513          	addi	a0,a0,1724 # ffffffffc0205ac8 <etext+0x1a6>
ffffffffc0200414:	d81ff0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0200418:	b7c1                	j	ffffffffc02003d8 <kmonitor+0xb0>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020041a:	00141793          	slli	a5,s0,0x1
ffffffffc020041e:	97a2                	add	a5,a5,s0
ffffffffc0200420:	078e                	slli	a5,a5,0x3
ffffffffc0200422:	97d6                	add	a5,a5,s5
ffffffffc0200424:	6b9c                	ld	a5,16(a5)
ffffffffc0200426:	fffb051b          	addiw	a0,s6,-1
ffffffffc020042a:	8652                	mv	a2,s4
ffffffffc020042c:	002c                	addi	a1,sp,8
ffffffffc020042e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc0200430:	f2055be3          	bgez	a0,ffffffffc0200366 <kmonitor+0x3e>
}
ffffffffc0200434:	70ea                	ld	ra,184(sp)
ffffffffc0200436:	744a                	ld	s0,176(sp)
ffffffffc0200438:	74aa                	ld	s1,168(sp)
ffffffffc020043a:	69ea                	ld	s3,152(sp)
ffffffffc020043c:	6a4a                	ld	s4,144(sp)
ffffffffc020043e:	6aaa                	ld	s5,136(sp)
ffffffffc0200440:	6b0a                	ld	s6,128(sp)
ffffffffc0200442:	6129                	addi	sp,sp,192
ffffffffc0200444:	8082                	ret

ffffffffc0200446 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc0200446:	0009b317          	auipc	t1,0x9b
ffffffffc020044a:	49a33303          	ld	t1,1178(t1) # ffffffffc029b8e0 <is_panic>
{
ffffffffc020044e:	715d                	addi	sp,sp,-80
ffffffffc0200450:	ec06                	sd	ra,24(sp)
ffffffffc0200452:	f436                	sd	a3,40(sp)
ffffffffc0200454:	f83a                	sd	a4,48(sp)
ffffffffc0200456:	fc3e                	sd	a5,56(sp)
ffffffffc0200458:	e0c2                	sd	a6,64(sp)
ffffffffc020045a:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc020045c:	02031e63          	bnez	t1,ffffffffc0200498 <__panic+0x52>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200460:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200462:	103c                	addi	a5,sp,40
ffffffffc0200464:	e822                	sd	s0,16(sp)
ffffffffc0200466:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200468:	862e                	mv	a2,a1
ffffffffc020046a:	85aa                	mv	a1,a0
ffffffffc020046c:	00005517          	auipc	a0,0x5
ffffffffc0200470:	72450513          	addi	a0,a0,1828 # ffffffffc0205b90 <etext+0x26e>
    is_panic = 1;
ffffffffc0200474:	0009b697          	auipc	a3,0x9b
ffffffffc0200478:	46e6b623          	sd	a4,1132(a3) # ffffffffc029b8e0 <is_panic>
    va_start(ap, fmt);
ffffffffc020047c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047e:	d17ff0ef          	jal	ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200482:	65a2                	ld	a1,8(sp)
ffffffffc0200484:	8522                	mv	a0,s0
ffffffffc0200486:	cefff0ef          	jal	ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc020048a:	00005517          	auipc	a0,0x5
ffffffffc020048e:	72650513          	addi	a0,a0,1830 # ffffffffc0205bb0 <etext+0x28e>
ffffffffc0200492:	d03ff0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0200496:	6442                	ld	s0,16(sp)
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200498:	4501                	li	a0,0
ffffffffc020049a:	4581                	li	a1,0
ffffffffc020049c:	4601                	li	a2,0
ffffffffc020049e:	48a1                	li	a7,8
ffffffffc02004a0:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004a4:	460000ef          	jal	ffffffffc0200904 <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	e7fff0ef          	jal	ffffffffc0200328 <kmonitor>
    while (1)
ffffffffc02004ae:	bfed                	j	ffffffffc02004a8 <__panic+0x62>

ffffffffc02004b0 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc02004b0:	715d                	addi	sp,sp,-80
ffffffffc02004b2:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004b4:	02810313          	addi	t1,sp,40
{
ffffffffc02004b8:	8432                	mv	s0,a2
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ba:	862e                	mv	a2,a1
ffffffffc02004bc:	85aa                	mv	a1,a0
ffffffffc02004be:	00005517          	auipc	a0,0x5
ffffffffc02004c2:	6fa50513          	addi	a0,a0,1786 # ffffffffc0205bb8 <etext+0x296>
{
ffffffffc02004c6:	ec06                	sd	ra,24(sp)
ffffffffc02004c8:	f436                	sd	a3,40(sp)
ffffffffc02004ca:	f83a                	sd	a4,48(sp)
ffffffffc02004cc:	fc3e                	sd	a5,56(sp)
ffffffffc02004ce:	e0c2                	sd	a6,64(sp)
ffffffffc02004d0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02004d2:	e41a                	sd	t1,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004d4:	cc1ff0ef          	jal	ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004d8:	65a2                	ld	a1,8(sp)
ffffffffc02004da:	8522                	mv	a0,s0
ffffffffc02004dc:	c99ff0ef          	jal	ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc02004e0:	00005517          	auipc	a0,0x5
ffffffffc02004e4:	6d050513          	addi	a0,a0,1744 # ffffffffc0205bb0 <etext+0x28e>
ffffffffc02004e8:	cadff0ef          	jal	ffffffffc0200194 <cprintf>
    va_end(ap);
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6442                	ld	s0,16(sp)
ffffffffc02004f0:	6161                	addi	sp,sp,80
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004f4:	67e1                	lui	a5,0x18
ffffffffc02004f6:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xe4b8>
ffffffffc02004fa:	0009b717          	auipc	a4,0x9b
ffffffffc02004fe:	3ef73723          	sd	a5,1006(a4) # ffffffffc029b8e8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200502:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200506:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200508:	953e                	add	a0,a0,a5
ffffffffc020050a:	4601                	li	a2,0
ffffffffc020050c:	4881                	li	a7,0
ffffffffc020050e:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200512:	02000793          	li	a5,32
ffffffffc0200516:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020051a:	00005517          	auipc	a0,0x5
ffffffffc020051e:	6be50513          	addi	a0,a0,1726 # ffffffffc0205bd8 <etext+0x2b6>
    ticks = 0;
ffffffffc0200522:	0009b797          	auipc	a5,0x9b
ffffffffc0200526:	3c07b723          	sd	zero,974(a5) # ffffffffc029b8f0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020052a:	b1ad                	j	ffffffffc0200194 <cprintf>

ffffffffc020052c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020052c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200530:	0009b797          	auipc	a5,0x9b
ffffffffc0200534:	3b87b783          	ld	a5,952(a5) # ffffffffc029b8e8 <timebase>
ffffffffc0200538:	4581                	li	a1,0
ffffffffc020053a:	4601                	li	a2,0
ffffffffc020053c:	953e                	add	a0,a0,a5
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
ffffffffc0200544:	8082                	ret

ffffffffc0200546 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200546:	8082                	ret

ffffffffc0200548 <cons_putc>:
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200548:	100027f3          	csrr	a5,sstatus
ffffffffc020054c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020054e:	0ff57513          	zext.b	a0,a0
ffffffffc0200552:	e799                	bnez	a5,ffffffffc0200560 <cons_putc+0x18>
ffffffffc0200554:	4581                	li	a1,0
ffffffffc0200556:	4601                	li	a2,0
ffffffffc0200558:	4885                	li	a7,1
ffffffffc020055a:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc020055e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200560:	1101                	addi	sp,sp,-32
ffffffffc0200562:	ec06                	sd	ra,24(sp)
ffffffffc0200564:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200566:	39e000ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc020056a:	6522                	ld	a0,8(sp)
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4885                	li	a7,1
ffffffffc0200572:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200576:	60e2                	ld	ra,24(sp)
ffffffffc0200578:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc020057a:	a651                	j	ffffffffc02008fe <intr_enable>

ffffffffc020057c <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020057c:	100027f3          	csrr	a5,sstatus
ffffffffc0200580:	8b89                	andi	a5,a5,2
ffffffffc0200582:	eb89                	bnez	a5,ffffffffc0200594 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200584:	4501                	li	a0,0
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4889                	li	a7,2
ffffffffc020058c:	00000073          	ecall
ffffffffc0200590:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200592:	8082                	ret
int cons_getc(void) {
ffffffffc0200594:	1101                	addi	sp,sp,-32
ffffffffc0200596:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200598:	36c000ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc020059c:	4501                	li	a0,0
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4889                	li	a7,2
ffffffffc02005a4:	00000073          	ecall
ffffffffc02005a8:	2501                	sext.w	a0,a0
ffffffffc02005aa:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005ac:	352000ef          	jal	ffffffffc02008fe <intr_enable>
}
ffffffffc02005b0:	60e2                	ld	ra,24(sp)
ffffffffc02005b2:	6522                	ld	a0,8(sp)
ffffffffc02005b4:	6105                	addi	sp,sp,32
ffffffffc02005b6:	8082                	ret

ffffffffc02005b8 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02005b8:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc02005ba:	00005517          	auipc	a0,0x5
ffffffffc02005be:	63e50513          	addi	a0,a0,1598 # ffffffffc0205bf8 <etext+0x2d6>
void dtb_init(void) {
ffffffffc02005c2:	f406                	sd	ra,40(sp)
ffffffffc02005c4:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc02005c6:	bcfff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005ca:	0000b597          	auipc	a1,0xb
ffffffffc02005ce:	a365b583          	ld	a1,-1482(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc02005d2:	00005517          	auipc	a0,0x5
ffffffffc02005d6:	63650513          	addi	a0,a0,1590 # ffffffffc0205c08 <etext+0x2e6>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005da:	0000b417          	auipc	s0,0xb
ffffffffc02005de:	a2e40413          	addi	s0,s0,-1490 # ffffffffc020b008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005e2:	bb3ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005e6:	600c                	ld	a1,0(s0)
ffffffffc02005e8:	00005517          	auipc	a0,0x5
ffffffffc02005ec:	63050513          	addi	a0,a0,1584 # ffffffffc0205c18 <etext+0x2f6>
ffffffffc02005f0:	ba5ff0ef          	jal	ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02005f4:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02005f6:	00005517          	auipc	a0,0x5
ffffffffc02005fa:	63a50513          	addi	a0,a0,1594 # ffffffffc0205c30 <etext+0x30e>
    if (boot_dtb == 0) {
ffffffffc02005fe:	10070163          	beqz	a4,ffffffffc0200700 <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200602:	57f5                	li	a5,-3
ffffffffc0200604:	07fa                	slli	a5,a5,0x1e
ffffffffc0200606:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200608:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc020060a:	d00e06b7          	lui	a3,0xd00e0
ffffffffc020060e:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe4458d>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200612:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200616:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020061a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020061e:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200622:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200626:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200628:	8e49                	or	a2,a2,a0
ffffffffc020062a:	0ff7f793          	zext.b	a5,a5
ffffffffc020062e:	8dd1                	or	a1,a1,a2
ffffffffc0200630:	07a2                	slli	a5,a5,0x8
ffffffffc0200632:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200634:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc0200638:	0cd59863          	bne	a1,a3,ffffffffc0200708 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc020063c:	4710                	lw	a2,8(a4)
ffffffffc020063e:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200640:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200642:	0086541b          	srliw	s0,a2,0x8
ffffffffc0200646:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020064a:	01865e1b          	srliw	t3,a2,0x18
ffffffffc020064e:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200652:	0186151b          	slliw	a0,a2,0x18
ffffffffc0200656:	0186959b          	slliw	a1,a3,0x18
ffffffffc020065a:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020065e:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200662:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200666:	0106d69b          	srliw	a3,a3,0x10
ffffffffc020066a:	01c56533          	or	a0,a0,t3
ffffffffc020066e:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200672:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200676:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067a:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067e:	0ff6f693          	zext.b	a3,a3
ffffffffc0200682:	8c49                	or	s0,s0,a0
ffffffffc0200684:	0622                	slli	a2,a2,0x8
ffffffffc0200686:	8fcd                	or	a5,a5,a1
ffffffffc0200688:	06a2                	slli	a3,a3,0x8
ffffffffc020068a:	8c51                	or	s0,s0,a2
ffffffffc020068c:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020068e:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200690:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200692:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200694:	9381                	srli	a5,a5,0x20
ffffffffc0200696:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200698:	4301                	li	t1,0
        switch (token) {
ffffffffc020069a:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020069c:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020069e:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc02006a2:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006a4:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a6:	0087579b          	srliw	a5,a4,0x8
ffffffffc02006aa:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ae:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006b2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b6:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ba:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006be:	8ed1                	or	a3,a3,a2
ffffffffc02006c0:	0ff77713          	zext.b	a4,a4
ffffffffc02006c4:	8fd5                	or	a5,a5,a3
ffffffffc02006c6:	0722                	slli	a4,a4,0x8
ffffffffc02006c8:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc02006ca:	05178763          	beq	a5,a7,ffffffffc0200718 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006ce:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc02006d0:	00f8e963          	bltu	a7,a5,ffffffffc02006e2 <dtb_init+0x12a>
ffffffffc02006d4:	07c78d63          	beq	a5,t3,ffffffffc020074e <dtb_init+0x196>
ffffffffc02006d8:	4709                	li	a4,2
ffffffffc02006da:	00e79763          	bne	a5,a4,ffffffffc02006e8 <dtb_init+0x130>
ffffffffc02006de:	4301                	li	t1,0
ffffffffc02006e0:	b7d1                	j	ffffffffc02006a4 <dtb_init+0xec>
ffffffffc02006e2:	4711                	li	a4,4
ffffffffc02006e4:	fce780e3          	beq	a5,a4,ffffffffc02006a4 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02006e8:	00005517          	auipc	a0,0x5
ffffffffc02006ec:	61050513          	addi	a0,a0,1552 # ffffffffc0205cf8 <etext+0x3d6>
ffffffffc02006f0:	aa5ff0ef          	jal	ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006f4:	64e2                	ld	s1,24(sp)
ffffffffc02006f6:	6942                	ld	s2,16(sp)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	63850513          	addi	a0,a0,1592 # ffffffffc0205d30 <etext+0x40e>
}
ffffffffc0200700:	7402                	ld	s0,32(sp)
ffffffffc0200702:	70a2                	ld	ra,40(sp)
ffffffffc0200704:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200706:	b479                	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200708:	7402                	ld	s0,32(sp)
ffffffffc020070a:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020070c:	00005517          	auipc	a0,0x5
ffffffffc0200710:	54450513          	addi	a0,a0,1348 # ffffffffc0205c50 <etext+0x32e>
}
ffffffffc0200714:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200716:	bcbd                	j	ffffffffc0200194 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200718:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020071a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020071e:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200722:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200726:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020072a:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020072e:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200732:	8ed1                	or	a3,a3,a2
ffffffffc0200734:	0ff77713          	zext.b	a4,a4
ffffffffc0200738:	8fd5                	or	a5,a5,a3
ffffffffc020073a:	0722                	slli	a4,a4,0x8
ffffffffc020073c:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020073e:	04031463          	bnez	t1,ffffffffc0200786 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200742:	1782                	slli	a5,a5,0x20
ffffffffc0200744:	9381                	srli	a5,a5,0x20
ffffffffc0200746:	043d                	addi	s0,s0,15
ffffffffc0200748:	943e                	add	s0,s0,a5
ffffffffc020074a:	9871                	andi	s0,s0,-4
                break;
ffffffffc020074c:	bfa1                	j	ffffffffc02006a4 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc020074e:	8522                	mv	a0,s0
ffffffffc0200750:	e01a                	sd	t1,0(sp)
ffffffffc0200752:	0f2050ef          	jal	ffffffffc0205844 <strlen>
ffffffffc0200756:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200758:	4619                	li	a2,6
ffffffffc020075a:	8522                	mv	a0,s0
ffffffffc020075c:	00005597          	auipc	a1,0x5
ffffffffc0200760:	51c58593          	addi	a1,a1,1308 # ffffffffc0205c78 <etext+0x356>
ffffffffc0200764:	15a050ef          	jal	ffffffffc02058be <strncmp>
ffffffffc0200768:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020076a:	0411                	addi	s0,s0,4
ffffffffc020076c:	0004879b          	sext.w	a5,s1
ffffffffc0200770:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200772:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200776:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200778:	00a36333          	or	t1,t1,a0
                break;
ffffffffc020077c:	00ff0837          	lui	a6,0xff0
ffffffffc0200780:	488d                	li	a7,3
ffffffffc0200782:	4e05                	li	t3,1
ffffffffc0200784:	b705                	j	ffffffffc02006a4 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200786:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200788:	00005597          	auipc	a1,0x5
ffffffffc020078c:	4f858593          	addi	a1,a1,1272 # ffffffffc0205c80 <etext+0x35e>
ffffffffc0200790:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200792:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200796:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020079a:	0187169b          	slliw	a3,a4,0x18
ffffffffc020079e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a2:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007a6:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007aa:	8ed1                	or	a3,a3,a2
ffffffffc02007ac:	0ff77713          	zext.b	a4,a4
ffffffffc02007b0:	0722                	slli	a4,a4,0x8
ffffffffc02007b2:	8d55                	or	a0,a0,a3
ffffffffc02007b4:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02007b6:	1502                	slli	a0,a0,0x20
ffffffffc02007b8:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007ba:	954a                	add	a0,a0,s2
ffffffffc02007bc:	e01a                	sd	t1,0(sp)
ffffffffc02007be:	0cc050ef          	jal	ffffffffc020588a <strcmp>
ffffffffc02007c2:	67a2                	ld	a5,8(sp)
ffffffffc02007c4:	473d                	li	a4,15
ffffffffc02007c6:	6302                	ld	t1,0(sp)
ffffffffc02007c8:	00ff0837          	lui	a6,0xff0
ffffffffc02007cc:	488d                	li	a7,3
ffffffffc02007ce:	4e05                	li	t3,1
ffffffffc02007d0:	f6f779e3          	bgeu	a4,a5,ffffffffc0200742 <dtb_init+0x18a>
ffffffffc02007d4:	f53d                	bnez	a0,ffffffffc0200742 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02007d6:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02007da:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007de:	00005517          	auipc	a0,0x5
ffffffffc02007e2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0205c88 <etext+0x366>
           fdt32_to_cpu(x >> 32);
ffffffffc02007e6:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ea:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02007ee:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02007f2:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007f6:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007fa:	0187959b          	slliw	a1,a5,0x18
ffffffffc02007fe:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200802:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200806:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020080a:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080e:	01037333          	and	t1,t1,a6
ffffffffc0200812:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200816:	01e5e5b3          	or	a1,a1,t5
ffffffffc020081a:	0ff7f793          	zext.b	a5,a5
ffffffffc020081e:	01de6e33          	or	t3,t3,t4
ffffffffc0200822:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200826:	01067633          	and	a2,a2,a6
ffffffffc020082a:	0086d31b          	srliw	t1,a3,0x8
ffffffffc020082e:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200832:	07a2                	slli	a5,a5,0x8
ffffffffc0200834:	0108d89b          	srliw	a7,a7,0x10
ffffffffc0200838:	0186df1b          	srliw	t5,a3,0x18
ffffffffc020083c:	01875e9b          	srliw	t4,a4,0x18
ffffffffc0200840:	8ddd                	or	a1,a1,a5
ffffffffc0200842:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200846:	0186979b          	slliw	a5,a3,0x18
ffffffffc020084a:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020084e:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200852:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200856:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020085a:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020085e:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200862:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200866:	08a2                	slli	a7,a7,0x8
ffffffffc0200868:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020086c:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200870:	0ff6f693          	zext.b	a3,a3
ffffffffc0200874:	01de6833          	or	a6,t3,t4
ffffffffc0200878:	0ff77713          	zext.b	a4,a4
ffffffffc020087c:	01166633          	or	a2,a2,a7
ffffffffc0200880:	0067e7b3          	or	a5,a5,t1
ffffffffc0200884:	06a2                	slli	a3,a3,0x8
ffffffffc0200886:	01046433          	or	s0,s0,a6
ffffffffc020088a:	0722                	slli	a4,a4,0x8
ffffffffc020088c:	8fd5                	or	a5,a5,a3
ffffffffc020088e:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc0200890:	1582                	slli	a1,a1,0x20
ffffffffc0200892:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200894:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200896:	9201                	srli	a2,a2,0x20
ffffffffc0200898:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020089a:	1402                	slli	s0,s0,0x20
ffffffffc020089c:	00b7e4b3          	or	s1,a5,a1
ffffffffc02008a0:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc02008a2:	8f3ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc02008a6:	85a6                	mv	a1,s1
ffffffffc02008a8:	00005517          	auipc	a0,0x5
ffffffffc02008ac:	40050513          	addi	a0,a0,1024 # ffffffffc0205ca8 <etext+0x386>
ffffffffc02008b0:	8e5ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02008b4:	01445613          	srli	a2,s0,0x14
ffffffffc02008b8:	85a2                	mv	a1,s0
ffffffffc02008ba:	00005517          	auipc	a0,0x5
ffffffffc02008be:	40650513          	addi	a0,a0,1030 # ffffffffc0205cc0 <etext+0x39e>
ffffffffc02008c2:	8d3ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008c6:	009405b3          	add	a1,s0,s1
ffffffffc02008ca:	15fd                	addi	a1,a1,-1
ffffffffc02008cc:	00005517          	auipc	a0,0x5
ffffffffc02008d0:	41450513          	addi	a0,a0,1044 # ffffffffc0205ce0 <etext+0x3be>
ffffffffc02008d4:	8c1ff0ef          	jal	ffffffffc0200194 <cprintf>
        memory_base = mem_base;
ffffffffc02008d8:	0009b797          	auipc	a5,0x9b
ffffffffc02008dc:	0297b423          	sd	s1,40(a5) # ffffffffc029b900 <memory_base>
        memory_size = mem_size;
ffffffffc02008e0:	0009b797          	auipc	a5,0x9b
ffffffffc02008e4:	0087bc23          	sd	s0,24(a5) # ffffffffc029b8f8 <memory_size>
ffffffffc02008e8:	b531                	j	ffffffffc02006f4 <dtb_init+0x13c>

ffffffffc02008ea <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008ea:	0009b517          	auipc	a0,0x9b
ffffffffc02008ee:	01653503          	ld	a0,22(a0) # ffffffffc029b900 <memory_base>
ffffffffc02008f2:	8082                	ret

ffffffffc02008f4 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008f4:	0009b517          	auipc	a0,0x9b
ffffffffc02008f8:	00453503          	ld	a0,4(a0) # ffffffffc029b8f8 <memory_size>
ffffffffc02008fc:	8082                	ret

ffffffffc02008fe <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02008fe:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200902:	8082                	ret

ffffffffc0200904 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200904:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200908:	8082                	ret

ffffffffc020090a <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020090a:	8082                	ret

ffffffffc020090c <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020090c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200910:	00000797          	auipc	a5,0x0
ffffffffc0200914:	53c78793          	addi	a5,a5,1340 # ffffffffc0200e4c <__alltraps>
ffffffffc0200918:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020091c:	000407b7          	lui	a5,0x40
ffffffffc0200920:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200924:	8082                	ret

ffffffffc0200926 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200926:	610c                	ld	a1,0(a0)
{
ffffffffc0200928:	1141                	addi	sp,sp,-16
ffffffffc020092a:	e022                	sd	s0,0(sp)
ffffffffc020092c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020092e:	00005517          	auipc	a0,0x5
ffffffffc0200932:	41a50513          	addi	a0,a0,1050 # ffffffffc0205d48 <etext+0x426>
{
ffffffffc0200936:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200938:	85dff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020093c:	640c                	ld	a1,8(s0)
ffffffffc020093e:	00005517          	auipc	a0,0x5
ffffffffc0200942:	42250513          	addi	a0,a0,1058 # ffffffffc0205d60 <etext+0x43e>
ffffffffc0200946:	84fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020094a:	680c                	ld	a1,16(s0)
ffffffffc020094c:	00005517          	auipc	a0,0x5
ffffffffc0200950:	42c50513          	addi	a0,a0,1068 # ffffffffc0205d78 <etext+0x456>
ffffffffc0200954:	841ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200958:	6c0c                	ld	a1,24(s0)
ffffffffc020095a:	00005517          	auipc	a0,0x5
ffffffffc020095e:	43650513          	addi	a0,a0,1078 # ffffffffc0205d90 <etext+0x46e>
ffffffffc0200962:	833ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200966:	700c                	ld	a1,32(s0)
ffffffffc0200968:	00005517          	auipc	a0,0x5
ffffffffc020096c:	44050513          	addi	a0,a0,1088 # ffffffffc0205da8 <etext+0x486>
ffffffffc0200970:	825ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200974:	740c                	ld	a1,40(s0)
ffffffffc0200976:	00005517          	auipc	a0,0x5
ffffffffc020097a:	44a50513          	addi	a0,a0,1098 # ffffffffc0205dc0 <etext+0x49e>
ffffffffc020097e:	817ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200982:	780c                	ld	a1,48(s0)
ffffffffc0200984:	00005517          	auipc	a0,0x5
ffffffffc0200988:	45450513          	addi	a0,a0,1108 # ffffffffc0205dd8 <etext+0x4b6>
ffffffffc020098c:	809ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200990:	7c0c                	ld	a1,56(s0)
ffffffffc0200992:	00005517          	auipc	a0,0x5
ffffffffc0200996:	45e50513          	addi	a0,a0,1118 # ffffffffc0205df0 <etext+0x4ce>
ffffffffc020099a:	ffaff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc020099e:	602c                	ld	a1,64(s0)
ffffffffc02009a0:	00005517          	auipc	a0,0x5
ffffffffc02009a4:	46850513          	addi	a0,a0,1128 # ffffffffc0205e08 <etext+0x4e6>
ffffffffc02009a8:	fecff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009ac:	642c                	ld	a1,72(s0)
ffffffffc02009ae:	00005517          	auipc	a0,0x5
ffffffffc02009b2:	47250513          	addi	a0,a0,1138 # ffffffffc0205e20 <etext+0x4fe>
ffffffffc02009b6:	fdeff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009ba:	682c                	ld	a1,80(s0)
ffffffffc02009bc:	00005517          	auipc	a0,0x5
ffffffffc02009c0:	47c50513          	addi	a0,a0,1148 # ffffffffc0205e38 <etext+0x516>
ffffffffc02009c4:	fd0ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009c8:	6c2c                	ld	a1,88(s0)
ffffffffc02009ca:	00005517          	auipc	a0,0x5
ffffffffc02009ce:	48650513          	addi	a0,a0,1158 # ffffffffc0205e50 <etext+0x52e>
ffffffffc02009d2:	fc2ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009d6:	702c                	ld	a1,96(s0)
ffffffffc02009d8:	00005517          	auipc	a0,0x5
ffffffffc02009dc:	49050513          	addi	a0,a0,1168 # ffffffffc0205e68 <etext+0x546>
ffffffffc02009e0:	fb4ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02009e4:	742c                	ld	a1,104(s0)
ffffffffc02009e6:	00005517          	auipc	a0,0x5
ffffffffc02009ea:	49a50513          	addi	a0,a0,1178 # ffffffffc0205e80 <etext+0x55e>
ffffffffc02009ee:	fa6ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02009f2:	782c                	ld	a1,112(s0)
ffffffffc02009f4:	00005517          	auipc	a0,0x5
ffffffffc02009f8:	4a450513          	addi	a0,a0,1188 # ffffffffc0205e98 <etext+0x576>
ffffffffc02009fc:	f98ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a00:	7c2c                	ld	a1,120(s0)
ffffffffc0200a02:	00005517          	auipc	a0,0x5
ffffffffc0200a06:	4ae50513          	addi	a0,a0,1198 # ffffffffc0205eb0 <etext+0x58e>
ffffffffc0200a0a:	f8aff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a0e:	604c                	ld	a1,128(s0)
ffffffffc0200a10:	00005517          	auipc	a0,0x5
ffffffffc0200a14:	4b850513          	addi	a0,a0,1208 # ffffffffc0205ec8 <etext+0x5a6>
ffffffffc0200a18:	f7cff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a1c:	644c                	ld	a1,136(s0)
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	4c250513          	addi	a0,a0,1218 # ffffffffc0205ee0 <etext+0x5be>
ffffffffc0200a26:	f6eff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a2a:	684c                	ld	a1,144(s0)
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205ef8 <etext+0x5d6>
ffffffffc0200a34:	f60ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a38:	6c4c                	ld	a1,152(s0)
ffffffffc0200a3a:	00005517          	auipc	a0,0x5
ffffffffc0200a3e:	4d650513          	addi	a0,a0,1238 # ffffffffc0205f10 <etext+0x5ee>
ffffffffc0200a42:	f52ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a46:	704c                	ld	a1,160(s0)
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	4e050513          	addi	a0,a0,1248 # ffffffffc0205f28 <etext+0x606>
ffffffffc0200a50:	f44ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a54:	744c                	ld	a1,168(s0)
ffffffffc0200a56:	00005517          	auipc	a0,0x5
ffffffffc0200a5a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0205f40 <etext+0x61e>
ffffffffc0200a5e:	f36ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a62:	784c                	ld	a1,176(s0)
ffffffffc0200a64:	00005517          	auipc	a0,0x5
ffffffffc0200a68:	4f450513          	addi	a0,a0,1268 # ffffffffc0205f58 <etext+0x636>
ffffffffc0200a6c:	f28ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a70:	7c4c                	ld	a1,184(s0)
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	4fe50513          	addi	a0,a0,1278 # ffffffffc0205f70 <etext+0x64e>
ffffffffc0200a7a:	f1aff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200a7e:	606c                	ld	a1,192(s0)
ffffffffc0200a80:	00005517          	auipc	a0,0x5
ffffffffc0200a84:	50850513          	addi	a0,a0,1288 # ffffffffc0205f88 <etext+0x666>
ffffffffc0200a88:	f0cff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a8c:	646c                	ld	a1,200(s0)
ffffffffc0200a8e:	00005517          	auipc	a0,0x5
ffffffffc0200a92:	51250513          	addi	a0,a0,1298 # ffffffffc0205fa0 <etext+0x67e>
ffffffffc0200a96:	efeff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a9a:	686c                	ld	a1,208(s0)
ffffffffc0200a9c:	00005517          	auipc	a0,0x5
ffffffffc0200aa0:	51c50513          	addi	a0,a0,1308 # ffffffffc0205fb8 <etext+0x696>
ffffffffc0200aa4:	ef0ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200aa8:	6c6c                	ld	a1,216(s0)
ffffffffc0200aaa:	00005517          	auipc	a0,0x5
ffffffffc0200aae:	52650513          	addi	a0,a0,1318 # ffffffffc0205fd0 <etext+0x6ae>
ffffffffc0200ab2:	ee2ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ab6:	706c                	ld	a1,224(s0)
ffffffffc0200ab8:	00005517          	auipc	a0,0x5
ffffffffc0200abc:	53050513          	addi	a0,a0,1328 # ffffffffc0205fe8 <etext+0x6c6>
ffffffffc0200ac0:	ed4ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200ac4:	746c                	ld	a1,232(s0)
ffffffffc0200ac6:	00005517          	auipc	a0,0x5
ffffffffc0200aca:	53a50513          	addi	a0,a0,1338 # ffffffffc0206000 <etext+0x6de>
ffffffffc0200ace:	ec6ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200ad2:	786c                	ld	a1,240(s0)
ffffffffc0200ad4:	00005517          	auipc	a0,0x5
ffffffffc0200ad8:	54450513          	addi	a0,a0,1348 # ffffffffc0206018 <etext+0x6f6>
ffffffffc0200adc:	eb8ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae0:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200ae2:	6402                	ld	s0,0(sp)
ffffffffc0200ae4:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae6:	00005517          	auipc	a0,0x5
ffffffffc0200aea:	54a50513          	addi	a0,a0,1354 # ffffffffc0206030 <etext+0x70e>
}
ffffffffc0200aee:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200af0:	ea4ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200af4 <print_trapframe>:
{
ffffffffc0200af4:	1141                	addi	sp,sp,-16
ffffffffc0200af6:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200af8:	85aa                	mv	a1,a0
{
ffffffffc0200afa:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200afc:	00005517          	auipc	a0,0x5
ffffffffc0200b00:	54c50513          	addi	a0,a0,1356 # ffffffffc0206048 <etext+0x726>
{
ffffffffc0200b04:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b06:	e8eff0ef          	jal	ffffffffc0200194 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b0a:	8522                	mv	a0,s0
ffffffffc0200b0c:	e1bff0ef          	jal	ffffffffc0200926 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b10:	10043583          	ld	a1,256(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	54c50513          	addi	a0,a0,1356 # ffffffffc0206060 <etext+0x73e>
ffffffffc0200b1c:	e78ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b20:	10843583          	ld	a1,264(s0)
ffffffffc0200b24:	00005517          	auipc	a0,0x5
ffffffffc0200b28:	55450513          	addi	a0,a0,1364 # ffffffffc0206078 <etext+0x756>
ffffffffc0200b2c:	e68ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200b30:	11043583          	ld	a1,272(s0)
ffffffffc0200b34:	00005517          	auipc	a0,0x5
ffffffffc0200b38:	55c50513          	addi	a0,a0,1372 # ffffffffc0206090 <etext+0x76e>
ffffffffc0200b3c:	e58ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b40:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b44:	6402                	ld	s0,0(sp)
ffffffffc0200b46:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b48:	00005517          	auipc	a0,0x5
ffffffffc0200b4c:	55850513          	addi	a0,a0,1368 # ffffffffc02060a0 <etext+0x77e>
}
ffffffffc0200b50:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b52:	e42ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200b56 <interrupt_handler>:
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
ffffffffc0200b56:	11853783          	ld	a5,280(a0)
ffffffffc0200b5a:	472d                	li	a4,11
ffffffffc0200b5c:	0786                	slli	a5,a5,0x1
ffffffffc0200b5e:	8385                	srli	a5,a5,0x1
ffffffffc0200b60:	0af76463          	bltu	a4,a5,ffffffffc0200c08 <interrupt_handler+0xb2>
ffffffffc0200b64:	00007717          	auipc	a4,0x7
ffffffffc0200b68:	b8470713          	addi	a4,a4,-1148 # ffffffffc02076e8 <commands+0x48>
ffffffffc0200b6c:	078a                	slli	a5,a5,0x2
ffffffffc0200b6e:	97ba                	add	a5,a5,a4
ffffffffc0200b70:	439c                	lw	a5,0(a5)
ffffffffc0200b72:	97ba                	add	a5,a5,a4
ffffffffc0200b74:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	5a250513          	addi	a0,a0,1442 # ffffffffc0206118 <etext+0x7f6>
ffffffffc0200b7e:	e16ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200b82:	00005517          	auipc	a0,0x5
ffffffffc0200b86:	57650513          	addi	a0,a0,1398 # ffffffffc02060f8 <etext+0x7d6>
ffffffffc0200b8a:	e0aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200b8e:	00005517          	auipc	a0,0x5
ffffffffc0200b92:	52a50513          	addi	a0,a0,1322 # ffffffffc02060b8 <etext+0x796>
ffffffffc0200b96:	dfeff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b9a:	00005517          	auipc	a0,0x5
ffffffffc0200b9e:	53e50513          	addi	a0,a0,1342 # ffffffffc02060d8 <etext+0x7b6>
ffffffffc0200ba2:	df2ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200ba6:	1141                	addi	sp,sp,-16
ffffffffc0200ba8:	e406                	sd	ra,8(sp)
        //     ticks=0;
        // }
        // if (num == 10){
        //     sbi_shutdown();
        // } 
        clock_set_next_event();
ffffffffc0200baa:	983ff0ef          	jal	ffffffffc020052c <clock_set_next_event>
        ticks++;
ffffffffc0200bae:	0009b797          	auipc	a5,0x9b
ffffffffc0200bb2:	d4278793          	addi	a5,a5,-702 # ffffffffc029b8f0 <ticks>
ffffffffc0200bb6:	6394                	ld	a3,0(a5)
        if (ticks % TICK_NUM == 0)
ffffffffc0200bb8:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200bbc:	28f70713          	addi	a4,a4,655 # 28f5c28f <_binary_obj___user_exit_out_size+0x28f520a7>
        ticks++;
ffffffffc0200bc0:	0685                	addi	a3,a3,1
ffffffffc0200bc2:	e394                	sd	a3,0(a5)
        if (ticks % TICK_NUM == 0)
ffffffffc0200bc4:	6390                	ld	a2,0(a5)
ffffffffc0200bc6:	5c28f6b7          	lui	a3,0x5c28f
ffffffffc0200bca:	1702                	slli	a4,a4,0x20
ffffffffc0200bcc:	5c368693          	addi	a3,a3,1475 # 5c28f5c3 <_binary_obj___user_exit_out_size+0x5c2853db>
ffffffffc0200bd0:	9736                	add	a4,a4,a3
ffffffffc0200bd2:	00265793          	srli	a5,a2,0x2
ffffffffc0200bd6:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200bda:	06400713          	li	a4,100
ffffffffc0200bde:	8389                	srli	a5,a5,0x2
ffffffffc0200be0:	02e787b3          	mul	a5,a5,a4
ffffffffc0200be4:	00f61963          	bne	a2,a5,ffffffffc0200bf6 <interrupt_handler+0xa0>
        {
            if (current != NULL)
ffffffffc0200be8:	0009b797          	auipc	a5,0x9b
ffffffffc0200bec:	d607b783          	ld	a5,-672(a5) # ffffffffc029b948 <current>
ffffffffc0200bf0:	c399                	beqz	a5,ffffffffc0200bf6 <interrupt_handler+0xa0>
            {
                current->need_resched = 1;
ffffffffc0200bf2:	4705                	li	a4,1
ffffffffc0200bf4:	ef98                	sd	a4,24(a5)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200bf6:	60a2                	ld	ra,8(sp)
ffffffffc0200bf8:	0141                	addi	sp,sp,16
ffffffffc0200bfa:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200bfc:	00005517          	auipc	a0,0x5
ffffffffc0200c00:	53c50513          	addi	a0,a0,1340 # ffffffffc0206138 <etext+0x816>
ffffffffc0200c04:	d90ff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200c08:	b5f5                	j	ffffffffc0200af4 <print_trapframe>

ffffffffc0200c0a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200c0a:	11853783          	ld	a5,280(a0)
ffffffffc0200c0e:	473d                	li	a4,15
ffffffffc0200c10:	18f76c63          	bltu	a4,a5,ffffffffc0200da8 <exception_handler+0x19e>
ffffffffc0200c14:	00007717          	auipc	a4,0x7
ffffffffc0200c18:	b0470713          	addi	a4,a4,-1276 # ffffffffc0207718 <commands+0x78>
ffffffffc0200c1c:	078a                	slli	a5,a5,0x2
ffffffffc0200c1e:	97ba                	add	a5,a5,a4
ffffffffc0200c20:	439c                	lw	a5,0(a5)
{
ffffffffc0200c22:	1101                	addi	sp,sp,-32
ffffffffc0200c24:	ec06                	sd	ra,24(sp)
    switch (tf->cause)
ffffffffc0200c26:	97ba                	add	a5,a5,a4
ffffffffc0200c28:	86aa                	mv	a3,a0
ffffffffc0200c2a:	8782                	jr	a5
ffffffffc0200c2c:	e42a                	sd	a0,8(sp)
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200c2e:	00005517          	auipc	a0,0x5
ffffffffc0200c32:	61250513          	addi	a0,a0,1554 # ffffffffc0206240 <etext+0x91e>
ffffffffc0200c36:	d5eff0ef          	jal	ffffffffc0200194 <cprintf>
        tf->epc += 4;
ffffffffc0200c3a:	66a2                	ld	a3,8(sp)
ffffffffc0200c3c:	1086b783          	ld	a5,264(a3)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c40:	60e2                	ld	ra,24(sp)
        tf->epc += 4;
ffffffffc0200c42:	0791                	addi	a5,a5,4
ffffffffc0200c44:	10f6b423          	sd	a5,264(a3)
}
ffffffffc0200c48:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200c4a:	79c0406f          	j	ffffffffc02053e6 <syscall>
}
ffffffffc0200c4e:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200c50:	00005517          	auipc	a0,0x5
ffffffffc0200c54:	61050513          	addi	a0,a0,1552 # ffffffffc0206260 <etext+0x93e>
}
ffffffffc0200c58:	6105                	addi	sp,sp,32
        cprintf("Environment call from H-mode\n");
ffffffffc0200c5a:	d3aff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c5e:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200c60:	00005517          	auipc	a0,0x5
ffffffffc0200c64:	62050513          	addi	a0,a0,1568 # ffffffffc0206280 <etext+0x95e>
}
ffffffffc0200c68:	6105                	addi	sp,sp,32
        cprintf("Environment call from M-mode\n");
ffffffffc0200c6a:	d2aff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c6e:	e42a                	sd	a0,8(sp)
        cprintf("Instruction page fault\n");
ffffffffc0200c70:	00005517          	auipc	a0,0x5
ffffffffc0200c74:	63050513          	addi	a0,a0,1584 # ffffffffc02062a0 <etext+0x97e>
ffffffffc0200c78:	d1cff0ef          	jal	ffffffffc0200194 <cprintf>
        goto pgfault;
ffffffffc0200c7c:	66a2                	ld	a3,8(sp)
        if (current == NULL || current->mm == NULL)
ffffffffc0200c7e:	0009b797          	auipc	a5,0x9b
ffffffffc0200c82:	cca7b783          	ld	a5,-822(a5) # ffffffffc029b948 <current>
ffffffffc0200c86:	12078263          	beqz	a5,ffffffffc0200daa <exception_handler+0x1a0>
ffffffffc0200c8a:	7788                	ld	a0,40(a5)
ffffffffc0200c8c:	10050f63          	beqz	a0,ffffffffc0200daa <exception_handler+0x1a0>
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0)
ffffffffc0200c90:	1106b603          	ld	a2,272(a3)
ffffffffc0200c94:	1186a583          	lw	a1,280(a3)
ffffffffc0200c98:	e436                	sd	a3,8(sp)
ffffffffc0200c9a:	357020ef          	jal	ffffffffc02037f0 <do_pgfault>
ffffffffc0200c9e:	66a2                	ld	a3,8(sp)
ffffffffc0200ca0:	0c051863          	bnez	a0,ffffffffc0200d70 <exception_handler+0x166>
}
ffffffffc0200ca4:	60e2                	ld	ra,24(sp)
ffffffffc0200ca6:	6105                	addi	sp,sp,32
ffffffffc0200ca8:	8082                	ret
ffffffffc0200caa:	e42a                	sd	a0,8(sp)
        cprintf("Load page fault\n");
ffffffffc0200cac:	00005517          	auipc	a0,0x5
ffffffffc0200cb0:	60c50513          	addi	a0,a0,1548 # ffffffffc02062b8 <etext+0x996>
ffffffffc0200cb4:	ce0ff0ef          	jal	ffffffffc0200194 <cprintf>
        goto pgfault;
ffffffffc0200cb8:	66a2                	ld	a3,8(sp)
ffffffffc0200cba:	b7d1                	j	ffffffffc0200c7e <exception_handler+0x74>
ffffffffc0200cbc:	e42a                	sd	a0,8(sp)
        cprintf("Store/AMO page fault\n");
ffffffffc0200cbe:	00005517          	auipc	a0,0x5
ffffffffc0200cc2:	61250513          	addi	a0,a0,1554 # ffffffffc02062d0 <etext+0x9ae>
ffffffffc0200cc6:	cceff0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0200cca:	66a2                	ld	a3,8(sp)
ffffffffc0200ccc:	bf4d                	j	ffffffffc0200c7e <exception_handler+0x74>
}
ffffffffc0200cce:	60e2                	ld	ra,24(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200cd0:	00005517          	auipc	a0,0x5
ffffffffc0200cd4:	48850513          	addi	a0,a0,1160 # ffffffffc0206158 <etext+0x836>
}
ffffffffc0200cd8:	6105                	addi	sp,sp,32
        cprintf("Instruction address misaligned\n");
ffffffffc0200cda:	cbaff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200cde:	60e2                	ld	ra,24(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200ce0:	00005517          	auipc	a0,0x5
ffffffffc0200ce4:	49850513          	addi	a0,a0,1176 # ffffffffc0206178 <etext+0x856>
}
ffffffffc0200ce8:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200cea:	caaff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200cee:	60e2                	ld	ra,24(sp)
        cprintf("Illegal instruction\n");
ffffffffc0200cf0:	00005517          	auipc	a0,0x5
ffffffffc0200cf4:	4a850513          	addi	a0,a0,1192 # ffffffffc0206198 <etext+0x876>
}
ffffffffc0200cf8:	6105                	addi	sp,sp,32
        cprintf("Illegal instruction\n");
ffffffffc0200cfa:	c9aff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200cfe:	e42a                	sd	a0,8(sp)
        cprintf("Breakpoint\n");
ffffffffc0200d00:	00005517          	auipc	a0,0x5
ffffffffc0200d04:	4b050513          	addi	a0,a0,1200 # ffffffffc02061b0 <etext+0x88e>
ffffffffc0200d08:	c8cff0ef          	jal	ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200d0c:	66a2                	ld	a3,8(sp)
ffffffffc0200d0e:	47a9                	li	a5,10
ffffffffc0200d10:	66d8                	ld	a4,136(a3)
ffffffffc0200d12:	f8f719e3          	bne	a4,a5,ffffffffc0200ca4 <exception_handler+0x9a>
            tf->epc += 4;
ffffffffc0200d16:	1086b783          	ld	a5,264(a3)
ffffffffc0200d1a:	0791                	addi	a5,a5,4
ffffffffc0200d1c:	10f6b423          	sd	a5,264(a3)
            syscall();
ffffffffc0200d20:	6c6040ef          	jal	ffffffffc02053e6 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200d24:	0009b717          	auipc	a4,0x9b
ffffffffc0200d28:	c2473703          	ld	a4,-988(a4) # ffffffffc029b948 <current>
ffffffffc0200d2c:	6522                	ld	a0,8(sp)
}
ffffffffc0200d2e:	60e2                	ld	ra,24(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200d30:	6b0c                	ld	a1,16(a4)
ffffffffc0200d32:	6789                	lui	a5,0x2
ffffffffc0200d34:	95be                	add	a1,a1,a5
}
ffffffffc0200d36:	6105                	addi	sp,sp,32
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200d38:	a2cd                	j	ffffffffc0200f1a <kernel_execve_ret>
}
ffffffffc0200d3a:	60e2                	ld	ra,24(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200d3c:	00005517          	auipc	a0,0x5
ffffffffc0200d40:	48450513          	addi	a0,a0,1156 # ffffffffc02061c0 <etext+0x89e>
}
ffffffffc0200d44:	6105                	addi	sp,sp,32
        cprintf("Load address misaligned\n");
ffffffffc0200d46:	c4eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200d4a:	60e2                	ld	ra,24(sp)
        cprintf("Load access fault\n");
ffffffffc0200d4c:	00005517          	auipc	a0,0x5
ffffffffc0200d50:	49450513          	addi	a0,a0,1172 # ffffffffc02061e0 <etext+0x8be>
}
ffffffffc0200d54:	6105                	addi	sp,sp,32
        cprintf("Load access fault\n");
ffffffffc0200d56:	c3eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200d5a:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200d5c:	00005517          	auipc	a0,0x5
ffffffffc0200d60:	4cc50513          	addi	a0,a0,1228 # ffffffffc0206228 <etext+0x906>
}
ffffffffc0200d64:	6105                	addi	sp,sp,32
        cprintf("Store/AMO access fault\n");
ffffffffc0200d66:	c2eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200d6a:	60e2                	ld	ra,24(sp)
ffffffffc0200d6c:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200d6e:	b359                	j	ffffffffc0200af4 <print_trapframe>
            cprintf("unhandled page fault from user, addr: %p\n", tf->tval);
ffffffffc0200d70:	1106b583          	ld	a1,272(a3)
ffffffffc0200d74:	00005517          	auipc	a0,0x5
ffffffffc0200d78:	59c50513          	addi	a0,a0,1436 # ffffffffc0206310 <etext+0x9ee>
ffffffffc0200d7c:	c18ff0ef          	jal	ffffffffc0200194 <cprintf>
            print_trapframe(tf);
ffffffffc0200d80:	6522                	ld	a0,8(sp)
ffffffffc0200d82:	d73ff0ef          	jal	ffffffffc0200af4 <print_trapframe>
}
ffffffffc0200d86:	60e2                	ld	ra,24(sp)
            do_exit(-E_KILLED);
ffffffffc0200d88:	555d                	li	a0,-9
}
ffffffffc0200d8a:	6105                	addi	sp,sp,32
            do_exit(-E_KILLED);
ffffffffc0200d8c:	00f0306f          	j	ffffffffc020459a <do_exit>
        panic("AMO address misaligned\n");
ffffffffc0200d90:	00005617          	auipc	a2,0x5
ffffffffc0200d94:	46860613          	addi	a2,a2,1128 # ffffffffc02061f8 <etext+0x8d6>
ffffffffc0200d98:	0c800593          	li	a1,200
ffffffffc0200d9c:	00005517          	auipc	a0,0x5
ffffffffc0200da0:	47450513          	addi	a0,a0,1140 # ffffffffc0206210 <etext+0x8ee>
ffffffffc0200da4:	ea2ff0ef          	jal	ffffffffc0200446 <__panic>
        print_trapframe(tf);
ffffffffc0200da8:	b3b1                	j	ffffffffc0200af4 <print_trapframe>
            print_trapframe(tf);
ffffffffc0200daa:	8536                	mv	a0,a3
ffffffffc0200dac:	d49ff0ef          	jal	ffffffffc0200af4 <print_trapframe>
            panic("unhandled page fault in kernel.\n");
ffffffffc0200db0:	00005617          	auipc	a2,0x5
ffffffffc0200db4:	53860613          	addi	a2,a2,1336 # ffffffffc02062e8 <etext+0x9c6>
ffffffffc0200db8:	0eb00593          	li	a1,235
ffffffffc0200dbc:	00005517          	auipc	a0,0x5
ffffffffc0200dc0:	45450513          	addi	a0,a0,1108 # ffffffffc0206210 <etext+0x8ee>
ffffffffc0200dc4:	e82ff0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0200dc8 <trap>:
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200dc8:	0009b717          	auipc	a4,0x9b
ffffffffc0200dcc:	b8073703          	ld	a4,-1152(a4) # ffffffffc029b948 <current>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200dd0:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200dd4:	cf21                	beqz	a4,ffffffffc0200e2c <trap+0x64>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200dd6:	10053603          	ld	a2,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200dda:	0a073803          	ld	a6,160(a4)
{
ffffffffc0200dde:	1101                	addi	sp,sp,-32
ffffffffc0200de0:	ec06                	sd	ra,24(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200de2:	10067613          	andi	a2,a2,256
        current->tf = tf;
ffffffffc0200de6:	f348                	sd	a0,160(a4)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200de8:	e432                	sd	a2,8(sp)
ffffffffc0200dea:	e042                	sd	a6,0(sp)
ffffffffc0200dec:	0205c763          	bltz	a1,ffffffffc0200e1a <trap+0x52>
        exception_handler(tf);
ffffffffc0200df0:	e1bff0ef          	jal	ffffffffc0200c0a <exception_handler>
ffffffffc0200df4:	6622                	ld	a2,8(sp)
ffffffffc0200df6:	6802                	ld	a6,0(sp)
ffffffffc0200df8:	0009b697          	auipc	a3,0x9b
ffffffffc0200dfc:	b5068693          	addi	a3,a3,-1200 # ffffffffc029b948 <current>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e00:	6298                	ld	a4,0(a3)
ffffffffc0200e02:	0b073023          	sd	a6,160(a4)
        if (!in_kernel)
ffffffffc0200e06:	e619                	bnez	a2,ffffffffc0200e14 <trap+0x4c>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e08:	0b072783          	lw	a5,176(a4)
ffffffffc0200e0c:	8b85                	andi	a5,a5,1
ffffffffc0200e0e:	e79d                	bnez	a5,ffffffffc0200e3c <trap+0x74>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e10:	6f1c                	ld	a5,24(a4)
ffffffffc0200e12:	e38d                	bnez	a5,ffffffffc0200e34 <trap+0x6c>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e14:	60e2                	ld	ra,24(sp)
ffffffffc0200e16:	6105                	addi	sp,sp,32
ffffffffc0200e18:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e1a:	d3dff0ef          	jal	ffffffffc0200b56 <interrupt_handler>
ffffffffc0200e1e:	6802                	ld	a6,0(sp)
ffffffffc0200e20:	6622                	ld	a2,8(sp)
ffffffffc0200e22:	0009b697          	auipc	a3,0x9b
ffffffffc0200e26:	b2668693          	addi	a3,a3,-1242 # ffffffffc029b948 <current>
ffffffffc0200e2a:	bfd9                	j	ffffffffc0200e00 <trap+0x38>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e2c:	0005c363          	bltz	a1,ffffffffc0200e32 <trap+0x6a>
        exception_handler(tf);
ffffffffc0200e30:	bbe9                	j	ffffffffc0200c0a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200e32:	b315                	j	ffffffffc0200b56 <interrupt_handler>
}
ffffffffc0200e34:	60e2                	ld	ra,24(sp)
ffffffffc0200e36:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200e38:	4c20406f          	j	ffffffffc02052fa <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e3c:	555d                	li	a0,-9
ffffffffc0200e3e:	75c030ef          	jal	ffffffffc020459a <do_exit>
            if (current->need_resched)
ffffffffc0200e42:	0009b717          	auipc	a4,0x9b
ffffffffc0200e46:	b0673703          	ld	a4,-1274(a4) # ffffffffc029b948 <current>
ffffffffc0200e4a:	b7d9                	j	ffffffffc0200e10 <trap+0x48>

ffffffffc0200e4c <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200e4c:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200e50:	00011463          	bnez	sp,ffffffffc0200e58 <__alltraps+0xc>
ffffffffc0200e54:	14002173          	csrr	sp,sscratch
ffffffffc0200e58:	712d                	addi	sp,sp,-288
ffffffffc0200e5a:	e002                	sd	zero,0(sp)
ffffffffc0200e5c:	e406                	sd	ra,8(sp)
ffffffffc0200e5e:	ec0e                	sd	gp,24(sp)
ffffffffc0200e60:	f012                	sd	tp,32(sp)
ffffffffc0200e62:	f416                	sd	t0,40(sp)
ffffffffc0200e64:	f81a                	sd	t1,48(sp)
ffffffffc0200e66:	fc1e                	sd	t2,56(sp)
ffffffffc0200e68:	e0a2                	sd	s0,64(sp)
ffffffffc0200e6a:	e4a6                	sd	s1,72(sp)
ffffffffc0200e6c:	e8aa                	sd	a0,80(sp)
ffffffffc0200e6e:	ecae                	sd	a1,88(sp)
ffffffffc0200e70:	f0b2                	sd	a2,96(sp)
ffffffffc0200e72:	f4b6                	sd	a3,104(sp)
ffffffffc0200e74:	f8ba                	sd	a4,112(sp)
ffffffffc0200e76:	fcbe                	sd	a5,120(sp)
ffffffffc0200e78:	e142                	sd	a6,128(sp)
ffffffffc0200e7a:	e546                	sd	a7,136(sp)
ffffffffc0200e7c:	e94a                	sd	s2,144(sp)
ffffffffc0200e7e:	ed4e                	sd	s3,152(sp)
ffffffffc0200e80:	f152                	sd	s4,160(sp)
ffffffffc0200e82:	f556                	sd	s5,168(sp)
ffffffffc0200e84:	f95a                	sd	s6,176(sp)
ffffffffc0200e86:	fd5e                	sd	s7,184(sp)
ffffffffc0200e88:	e1e2                	sd	s8,192(sp)
ffffffffc0200e8a:	e5e6                	sd	s9,200(sp)
ffffffffc0200e8c:	e9ea                	sd	s10,208(sp)
ffffffffc0200e8e:	edee                	sd	s11,216(sp)
ffffffffc0200e90:	f1f2                	sd	t3,224(sp)
ffffffffc0200e92:	f5f6                	sd	t4,232(sp)
ffffffffc0200e94:	f9fa                	sd	t5,240(sp)
ffffffffc0200e96:	fdfe                	sd	t6,248(sp)
ffffffffc0200e98:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200e9c:	100024f3          	csrr	s1,sstatus
ffffffffc0200ea0:	14102973          	csrr	s2,sepc
ffffffffc0200ea4:	143029f3          	csrr	s3,stval
ffffffffc0200ea8:	14202a73          	csrr	s4,scause
ffffffffc0200eac:	e822                	sd	s0,16(sp)
ffffffffc0200eae:	e226                	sd	s1,256(sp)
ffffffffc0200eb0:	e64a                	sd	s2,264(sp)
ffffffffc0200eb2:	ea4e                	sd	s3,272(sp)
ffffffffc0200eb4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200eb6:	850a                	mv	a0,sp
    jal trap
ffffffffc0200eb8:	f11ff0ef          	jal	ffffffffc0200dc8 <trap>

ffffffffc0200ebc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ebc:	6492                	ld	s1,256(sp)
ffffffffc0200ebe:	6932                	ld	s2,264(sp)
ffffffffc0200ec0:	1004f413          	andi	s0,s1,256
ffffffffc0200ec4:	e401                	bnez	s0,ffffffffc0200ecc <__trapret+0x10>
ffffffffc0200ec6:	1200                	addi	s0,sp,288
ffffffffc0200ec8:	14041073          	csrw	sscratch,s0
ffffffffc0200ecc:	10049073          	csrw	sstatus,s1
ffffffffc0200ed0:	14191073          	csrw	sepc,s2
ffffffffc0200ed4:	60a2                	ld	ra,8(sp)
ffffffffc0200ed6:	61e2                	ld	gp,24(sp)
ffffffffc0200ed8:	7202                	ld	tp,32(sp)
ffffffffc0200eda:	72a2                	ld	t0,40(sp)
ffffffffc0200edc:	7342                	ld	t1,48(sp)
ffffffffc0200ede:	73e2                	ld	t2,56(sp)
ffffffffc0200ee0:	6406                	ld	s0,64(sp)
ffffffffc0200ee2:	64a6                	ld	s1,72(sp)
ffffffffc0200ee4:	6546                	ld	a0,80(sp)
ffffffffc0200ee6:	65e6                	ld	a1,88(sp)
ffffffffc0200ee8:	7606                	ld	a2,96(sp)
ffffffffc0200eea:	76a6                	ld	a3,104(sp)
ffffffffc0200eec:	7746                	ld	a4,112(sp)
ffffffffc0200eee:	77e6                	ld	a5,120(sp)
ffffffffc0200ef0:	680a                	ld	a6,128(sp)
ffffffffc0200ef2:	68aa                	ld	a7,136(sp)
ffffffffc0200ef4:	694a                	ld	s2,144(sp)
ffffffffc0200ef6:	69ea                	ld	s3,152(sp)
ffffffffc0200ef8:	7a0a                	ld	s4,160(sp)
ffffffffc0200efa:	7aaa                	ld	s5,168(sp)
ffffffffc0200efc:	7b4a                	ld	s6,176(sp)
ffffffffc0200efe:	7bea                	ld	s7,184(sp)
ffffffffc0200f00:	6c0e                	ld	s8,192(sp)
ffffffffc0200f02:	6cae                	ld	s9,200(sp)
ffffffffc0200f04:	6d4e                	ld	s10,208(sp)
ffffffffc0200f06:	6dee                	ld	s11,216(sp)
ffffffffc0200f08:	7e0e                	ld	t3,224(sp)
ffffffffc0200f0a:	7eae                	ld	t4,232(sp)
ffffffffc0200f0c:	7f4e                	ld	t5,240(sp)
ffffffffc0200f0e:	7fee                	ld	t6,248(sp)
ffffffffc0200f10:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200f12:	10200073          	sret

ffffffffc0200f16 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f16:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200f18:	b755                	j	ffffffffc0200ebc <__trapret>

ffffffffc0200f1a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200f1a:	ee058593          	addi	a1,a1,-288

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200f1e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200f22:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200f26:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200f2a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200f2e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200f32:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200f36:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200f3a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200f3e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200f40:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200f42:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200f44:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200f46:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200f48:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200f4a:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200f4c:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200f4e:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200f50:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200f52:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200f54:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200f56:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200f58:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200f5a:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200f5c:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200f5e:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200f60:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200f62:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200f64:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200f66:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200f68:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200f6a:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200f6c:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200f6e:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200f70:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200f72:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200f74:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200f76:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200f78:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200f7a:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200f7c:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200f7e:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200f80:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200f82:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200f84:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200f86:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200f88:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200f8a:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200f8c:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200f8e:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200f90:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200f92:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200f94:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200f96:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200f98:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200f9a:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200f9c:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200f9e:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200fa0:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200fa2:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200fa4:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200fa6:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200fa8:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200faa:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200fac:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200fae:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200fb0:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200fb2:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200fb4:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200fb6:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200fb8:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200fba:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200fbc:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200fbe:	812e                	mv	sp,a1
ffffffffc0200fc0:	bdf5                	j	ffffffffc0200ebc <__trapret>

ffffffffc0200fc2 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200fc2:	00097797          	auipc	a5,0x97
ffffffffc0200fc6:	8f678793          	addi	a5,a5,-1802 # ffffffffc02978b8 <free_area>
ffffffffc0200fca:	e79c                	sd	a5,8(a5)
ffffffffc0200fcc:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200fce:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200fd2:	8082                	ret

ffffffffc0200fd4 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200fd4:	00097517          	auipc	a0,0x97
ffffffffc0200fd8:	8f456503          	lwu	a0,-1804(a0) # ffffffffc02978c8 <free_area+0x10>
ffffffffc0200fdc:	8082                	ret

ffffffffc0200fde <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0200fde:	711d                	addi	sp,sp,-96
ffffffffc0200fe0:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200fe2:	00097917          	auipc	s2,0x97
ffffffffc0200fe6:	8d690913          	addi	s2,s2,-1834 # ffffffffc02978b8 <free_area>
ffffffffc0200fea:	00893783          	ld	a5,8(s2)
ffffffffc0200fee:	ec86                	sd	ra,88(sp)
ffffffffc0200ff0:	e8a2                	sd	s0,80(sp)
ffffffffc0200ff2:	e4a6                	sd	s1,72(sp)
ffffffffc0200ff4:	fc4e                	sd	s3,56(sp)
ffffffffc0200ff6:	f852                	sd	s4,48(sp)
ffffffffc0200ff8:	f456                	sd	s5,40(sp)
ffffffffc0200ffa:	f05a                	sd	s6,32(sp)
ffffffffc0200ffc:	ec5e                	sd	s7,24(sp)
ffffffffc0200ffe:	e862                	sd	s8,16(sp)
ffffffffc0201000:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201002:	2f278363          	beq	a5,s2,ffffffffc02012e8 <default_check+0x30a>
    int count = 0, total = 0;
ffffffffc0201006:	4401                	li	s0,0
ffffffffc0201008:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020100a:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020100e:	8b09                	andi	a4,a4,2
ffffffffc0201010:	2e070063          	beqz	a4,ffffffffc02012f0 <default_check+0x312>
        count++, total += p->property;
ffffffffc0201014:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201018:	679c                	ld	a5,8(a5)
ffffffffc020101a:	2485                	addiw	s1,s1,1
ffffffffc020101c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020101e:	ff2796e3          	bne	a5,s2,ffffffffc020100a <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0201022:	89a2                	mv	s3,s0
ffffffffc0201024:	741000ef          	jal	ffffffffc0201f64 <nr_free_pages>
ffffffffc0201028:	73351463          	bne	a0,s3,ffffffffc0201750 <default_check+0x772>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020102c:	4505                	li	a0,1
ffffffffc020102e:	6c5000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201032:	8a2a                	mv	s4,a0
ffffffffc0201034:	44050e63          	beqz	a0,ffffffffc0201490 <default_check+0x4b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201038:	4505                	li	a0,1
ffffffffc020103a:	6b9000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc020103e:	89aa                	mv	s3,a0
ffffffffc0201040:	72050863          	beqz	a0,ffffffffc0201770 <default_check+0x792>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201044:	4505                	li	a0,1
ffffffffc0201046:	6ad000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc020104a:	8aaa                	mv	s5,a0
ffffffffc020104c:	4c050263          	beqz	a0,ffffffffc0201510 <default_check+0x532>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201050:	40a987b3          	sub	a5,s3,a0
ffffffffc0201054:	40aa0733          	sub	a4,s4,a0
ffffffffc0201058:	0017b793          	seqz	a5,a5
ffffffffc020105c:	00173713          	seqz	a4,a4
ffffffffc0201060:	8fd9                	or	a5,a5,a4
ffffffffc0201062:	30079763          	bnez	a5,ffffffffc0201370 <default_check+0x392>
ffffffffc0201066:	313a0563          	beq	s4,s3,ffffffffc0201370 <default_check+0x392>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020106a:	000a2783          	lw	a5,0(s4)
ffffffffc020106e:	2a079163          	bnez	a5,ffffffffc0201310 <default_check+0x332>
ffffffffc0201072:	0009a783          	lw	a5,0(s3)
ffffffffc0201076:	28079d63          	bnez	a5,ffffffffc0201310 <default_check+0x332>
ffffffffc020107a:	411c                	lw	a5,0(a0)
ffffffffc020107c:	28079a63          	bnez	a5,ffffffffc0201310 <default_check+0x332>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0201080:	0009b797          	auipc	a5,0x9b
ffffffffc0201084:	8b87b783          	ld	a5,-1864(a5) # ffffffffc029b938 <pages>
ffffffffc0201088:	00007617          	auipc	a2,0x7
ffffffffc020108c:	a2863603          	ld	a2,-1496(a2) # ffffffffc0207ab0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201090:	0009b697          	auipc	a3,0x9b
ffffffffc0201094:	8a06b683          	ld	a3,-1888(a3) # ffffffffc029b930 <npage>
ffffffffc0201098:	40fa0733          	sub	a4,s4,a5
ffffffffc020109c:	8719                	srai	a4,a4,0x6
ffffffffc020109e:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc02010a0:	0732                	slli	a4,a4,0xc
ffffffffc02010a2:	06b2                	slli	a3,a3,0xc
ffffffffc02010a4:	2ad77663          	bgeu	a4,a3,ffffffffc0201350 <default_check+0x372>
    return page - pages + nbase;
ffffffffc02010a8:	40f98733          	sub	a4,s3,a5
ffffffffc02010ac:	8719                	srai	a4,a4,0x6
ffffffffc02010ae:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010b0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010b2:	4cd77f63          	bgeu	a4,a3,ffffffffc0201590 <default_check+0x5b2>
    return page - pages + nbase;
ffffffffc02010b6:	40f507b3          	sub	a5,a0,a5
ffffffffc02010ba:	8799                	srai	a5,a5,0x6
ffffffffc02010bc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010be:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02010c0:	32d7f863          	bgeu	a5,a3,ffffffffc02013f0 <default_check+0x412>
    assert(alloc_page() == NULL);
ffffffffc02010c4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010c6:	00093c03          	ld	s8,0(s2)
ffffffffc02010ca:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02010ce:	00096b17          	auipc	s6,0x96
ffffffffc02010d2:	7fab2b03          	lw	s6,2042(s6) # ffffffffc02978c8 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc02010d6:	01293023          	sd	s2,0(s2)
ffffffffc02010da:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc02010de:	00096797          	auipc	a5,0x96
ffffffffc02010e2:	7e07a523          	sw	zero,2026(a5) # ffffffffc02978c8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02010e6:	60d000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc02010ea:	2e051363          	bnez	a0,ffffffffc02013d0 <default_check+0x3f2>
    free_page(p0);
ffffffffc02010ee:	8552                	mv	a0,s4
ffffffffc02010f0:	4585                	li	a1,1
ffffffffc02010f2:	63b000ef          	jal	ffffffffc0201f2c <free_pages>
    free_page(p1);
ffffffffc02010f6:	854e                	mv	a0,s3
ffffffffc02010f8:	4585                	li	a1,1
ffffffffc02010fa:	633000ef          	jal	ffffffffc0201f2c <free_pages>
    free_page(p2);
ffffffffc02010fe:	8556                	mv	a0,s5
ffffffffc0201100:	4585                	li	a1,1
ffffffffc0201102:	62b000ef          	jal	ffffffffc0201f2c <free_pages>
    assert(nr_free == 3);
ffffffffc0201106:	00096717          	auipc	a4,0x96
ffffffffc020110a:	7c272703          	lw	a4,1986(a4) # ffffffffc02978c8 <free_area+0x10>
ffffffffc020110e:	478d                	li	a5,3
ffffffffc0201110:	2af71063          	bne	a4,a5,ffffffffc02013b0 <default_check+0x3d2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201114:	4505                	li	a0,1
ffffffffc0201116:	5dd000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc020111a:	89aa                	mv	s3,a0
ffffffffc020111c:	26050a63          	beqz	a0,ffffffffc0201390 <default_check+0x3b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201120:	4505                	li	a0,1
ffffffffc0201122:	5d1000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201126:	8aaa                	mv	s5,a0
ffffffffc0201128:	3c050463          	beqz	a0,ffffffffc02014f0 <default_check+0x512>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020112c:	4505                	li	a0,1
ffffffffc020112e:	5c5000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201132:	8a2a                	mv	s4,a0
ffffffffc0201134:	38050e63          	beqz	a0,ffffffffc02014d0 <default_check+0x4f2>
    assert(alloc_page() == NULL);
ffffffffc0201138:	4505                	li	a0,1
ffffffffc020113a:	5b9000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc020113e:	36051963          	bnez	a0,ffffffffc02014b0 <default_check+0x4d2>
    free_page(p0);
ffffffffc0201142:	4585                	li	a1,1
ffffffffc0201144:	854e                	mv	a0,s3
ffffffffc0201146:	5e7000ef          	jal	ffffffffc0201f2c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020114a:	00893783          	ld	a5,8(s2)
ffffffffc020114e:	1f278163          	beq	a5,s2,ffffffffc0201330 <default_check+0x352>
    assert((p = alloc_page()) == p0);
ffffffffc0201152:	4505                	li	a0,1
ffffffffc0201154:	59f000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201158:	8caa                	mv	s9,a0
ffffffffc020115a:	30a99b63          	bne	s3,a0,ffffffffc0201470 <default_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc020115e:	4505                	li	a0,1
ffffffffc0201160:	593000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201164:	2e051663          	bnez	a0,ffffffffc0201450 <default_check+0x472>
    assert(nr_free == 0);
ffffffffc0201168:	00096797          	auipc	a5,0x96
ffffffffc020116c:	7607a783          	lw	a5,1888(a5) # ffffffffc02978c8 <free_area+0x10>
ffffffffc0201170:	2c079063          	bnez	a5,ffffffffc0201430 <default_check+0x452>
    free_page(p);
ffffffffc0201174:	8566                	mv	a0,s9
ffffffffc0201176:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201178:	01893023          	sd	s8,0(s2)
ffffffffc020117c:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0201180:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0201184:	5a9000ef          	jal	ffffffffc0201f2c <free_pages>
    free_page(p1);
ffffffffc0201188:	8556                	mv	a0,s5
ffffffffc020118a:	4585                	li	a1,1
ffffffffc020118c:	5a1000ef          	jal	ffffffffc0201f2c <free_pages>
    free_page(p2);
ffffffffc0201190:	8552                	mv	a0,s4
ffffffffc0201192:	4585                	li	a1,1
ffffffffc0201194:	599000ef          	jal	ffffffffc0201f2c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201198:	4515                	li	a0,5
ffffffffc020119a:	559000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc020119e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02011a0:	26050863          	beqz	a0,ffffffffc0201410 <default_check+0x432>
ffffffffc02011a4:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc02011a6:	8b89                	andi	a5,a5,2
ffffffffc02011a8:	54079463          	bnez	a5,ffffffffc02016f0 <default_check+0x712>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02011ac:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02011ae:	00093b83          	ld	s7,0(s2)
ffffffffc02011b2:	00893b03          	ld	s6,8(s2)
ffffffffc02011b6:	01293023          	sd	s2,0(s2)
ffffffffc02011ba:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc02011be:	535000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc02011c2:	50051763          	bnez	a0,ffffffffc02016d0 <default_check+0x6f2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02011c6:	08098a13          	addi	s4,s3,128
ffffffffc02011ca:	8552                	mv	a0,s4
ffffffffc02011cc:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02011ce:	00096c17          	auipc	s8,0x96
ffffffffc02011d2:	6fac2c03          	lw	s8,1786(s8) # ffffffffc02978c8 <free_area+0x10>
    nr_free = 0;
ffffffffc02011d6:	00096797          	auipc	a5,0x96
ffffffffc02011da:	6e07a923          	sw	zero,1778(a5) # ffffffffc02978c8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02011de:	54f000ef          	jal	ffffffffc0201f2c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02011e2:	4511                	li	a0,4
ffffffffc02011e4:	50f000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc02011e8:	4c051463          	bnez	a0,ffffffffc02016b0 <default_check+0x6d2>
ffffffffc02011ec:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011f0:	8b89                	andi	a5,a5,2
ffffffffc02011f2:	48078f63          	beqz	a5,ffffffffc0201690 <default_check+0x6b2>
ffffffffc02011f6:	0909a503          	lw	a0,144(s3)
ffffffffc02011fa:	478d                	li	a5,3
ffffffffc02011fc:	48f51a63          	bne	a0,a5,ffffffffc0201690 <default_check+0x6b2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201200:	4f3000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201204:	8aaa                	mv	s5,a0
ffffffffc0201206:	46050563          	beqz	a0,ffffffffc0201670 <default_check+0x692>
    assert(alloc_page() == NULL);
ffffffffc020120a:	4505                	li	a0,1
ffffffffc020120c:	4e7000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201210:	44051063          	bnez	a0,ffffffffc0201650 <default_check+0x672>
    assert(p0 + 2 == p1);
ffffffffc0201214:	415a1e63          	bne	s4,s5,ffffffffc0201630 <default_check+0x652>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201218:	4585                	li	a1,1
ffffffffc020121a:	854e                	mv	a0,s3
ffffffffc020121c:	511000ef          	jal	ffffffffc0201f2c <free_pages>
    free_pages(p1, 3);
ffffffffc0201220:	8552                	mv	a0,s4
ffffffffc0201222:	458d                	li	a1,3
ffffffffc0201224:	509000ef          	jal	ffffffffc0201f2c <free_pages>
ffffffffc0201228:	0089b783          	ld	a5,8(s3)
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020122c:	8b89                	andi	a5,a5,2
ffffffffc020122e:	3e078163          	beqz	a5,ffffffffc0201610 <default_check+0x632>
ffffffffc0201232:	0109aa83          	lw	s5,16(s3)
ffffffffc0201236:	4785                	li	a5,1
ffffffffc0201238:	3cfa9c63          	bne	s5,a5,ffffffffc0201610 <default_check+0x632>
ffffffffc020123c:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201240:	8b89                	andi	a5,a5,2
ffffffffc0201242:	3a078763          	beqz	a5,ffffffffc02015f0 <default_check+0x612>
ffffffffc0201246:	010a2703          	lw	a4,16(s4)
ffffffffc020124a:	478d                	li	a5,3
ffffffffc020124c:	3af71263          	bne	a4,a5,ffffffffc02015f0 <default_check+0x612>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201250:	8556                	mv	a0,s5
ffffffffc0201252:	4a1000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201256:	36a99d63          	bne	s3,a0,ffffffffc02015d0 <default_check+0x5f2>
    free_page(p0);
ffffffffc020125a:	85d6                	mv	a1,s5
ffffffffc020125c:	4d1000ef          	jal	ffffffffc0201f2c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201260:	4509                	li	a0,2
ffffffffc0201262:	491000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201266:	34aa1563          	bne	s4,a0,ffffffffc02015b0 <default_check+0x5d2>

    free_pages(p0, 2);
ffffffffc020126a:	4589                	li	a1,2
ffffffffc020126c:	4c1000ef          	jal	ffffffffc0201f2c <free_pages>
    free_page(p2);
ffffffffc0201270:	04098513          	addi	a0,s3,64
ffffffffc0201274:	85d6                	mv	a1,s5
ffffffffc0201276:	4b7000ef          	jal	ffffffffc0201f2c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020127a:	4515                	li	a0,5
ffffffffc020127c:	477000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0201280:	89aa                	mv	s3,a0
ffffffffc0201282:	48050763          	beqz	a0,ffffffffc0201710 <default_check+0x732>
    assert(alloc_page() == NULL);
ffffffffc0201286:	8556                	mv	a0,s5
ffffffffc0201288:	46b000ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc020128c:	2e051263          	bnez	a0,ffffffffc0201570 <default_check+0x592>

    assert(nr_free == 0);
ffffffffc0201290:	00096797          	auipc	a5,0x96
ffffffffc0201294:	6387a783          	lw	a5,1592(a5) # ffffffffc02978c8 <free_area+0x10>
ffffffffc0201298:	2a079c63          	bnez	a5,ffffffffc0201550 <default_check+0x572>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020129c:	854e                	mv	a0,s3
ffffffffc020129e:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc02012a0:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc02012a4:	01793023          	sd	s7,0(s2)
ffffffffc02012a8:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc02012ac:	481000ef          	jal	ffffffffc0201f2c <free_pages>
    return listelm->next;
ffffffffc02012b0:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02012b4:	01278963          	beq	a5,s2,ffffffffc02012c6 <default_check+0x2e8>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02012b8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02012bc:	679c                	ld	a5,8(a5)
ffffffffc02012be:	34fd                	addiw	s1,s1,-1
ffffffffc02012c0:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02012c2:	ff279be3          	bne	a5,s2,ffffffffc02012b8 <default_check+0x2da>
    }
    assert(count == 0);
ffffffffc02012c6:	26049563          	bnez	s1,ffffffffc0201530 <default_check+0x552>
    assert(total == 0);
ffffffffc02012ca:	46041363          	bnez	s0,ffffffffc0201730 <default_check+0x752>
}
ffffffffc02012ce:	60e6                	ld	ra,88(sp)
ffffffffc02012d0:	6446                	ld	s0,80(sp)
ffffffffc02012d2:	64a6                	ld	s1,72(sp)
ffffffffc02012d4:	6906                	ld	s2,64(sp)
ffffffffc02012d6:	79e2                	ld	s3,56(sp)
ffffffffc02012d8:	7a42                	ld	s4,48(sp)
ffffffffc02012da:	7aa2                	ld	s5,40(sp)
ffffffffc02012dc:	7b02                	ld	s6,32(sp)
ffffffffc02012de:	6be2                	ld	s7,24(sp)
ffffffffc02012e0:	6c42                	ld	s8,16(sp)
ffffffffc02012e2:	6ca2                	ld	s9,8(sp)
ffffffffc02012e4:	6125                	addi	sp,sp,96
ffffffffc02012e6:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc02012e8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02012ea:	4401                	li	s0,0
ffffffffc02012ec:	4481                	li	s1,0
ffffffffc02012ee:	bb1d                	j	ffffffffc0201024 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc02012f0:	00005697          	auipc	a3,0x5
ffffffffc02012f4:	05068693          	addi	a3,a3,80 # ffffffffc0206340 <etext+0xa1e>
ffffffffc02012f8:	00005617          	auipc	a2,0x5
ffffffffc02012fc:	05860613          	addi	a2,a2,88 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201300:	11000593          	li	a1,272
ffffffffc0201304:	00005517          	auipc	a0,0x5
ffffffffc0201308:	06450513          	addi	a0,a0,100 # ffffffffc0206368 <etext+0xa46>
ffffffffc020130c:	93aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201310:	00005697          	auipc	a3,0x5
ffffffffc0201314:	11868693          	addi	a3,a3,280 # ffffffffc0206428 <etext+0xb06>
ffffffffc0201318:	00005617          	auipc	a2,0x5
ffffffffc020131c:	03860613          	addi	a2,a2,56 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201320:	0dc00593          	li	a1,220
ffffffffc0201324:	00005517          	auipc	a0,0x5
ffffffffc0201328:	04450513          	addi	a0,a0,68 # ffffffffc0206368 <etext+0xa46>
ffffffffc020132c:	91aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201330:	00005697          	auipc	a3,0x5
ffffffffc0201334:	1c068693          	addi	a3,a3,448 # ffffffffc02064f0 <etext+0xbce>
ffffffffc0201338:	00005617          	auipc	a2,0x5
ffffffffc020133c:	01860613          	addi	a2,a2,24 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201340:	0f700593          	li	a1,247
ffffffffc0201344:	00005517          	auipc	a0,0x5
ffffffffc0201348:	02450513          	addi	a0,a0,36 # ffffffffc0206368 <etext+0xa46>
ffffffffc020134c:	8faff0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201350:	00005697          	auipc	a3,0x5
ffffffffc0201354:	11868693          	addi	a3,a3,280 # ffffffffc0206468 <etext+0xb46>
ffffffffc0201358:	00005617          	auipc	a2,0x5
ffffffffc020135c:	ff860613          	addi	a2,a2,-8 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201360:	0de00593          	li	a1,222
ffffffffc0201364:	00005517          	auipc	a0,0x5
ffffffffc0201368:	00450513          	addi	a0,a0,4 # ffffffffc0206368 <etext+0xa46>
ffffffffc020136c:	8daff0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201370:	00005697          	auipc	a3,0x5
ffffffffc0201374:	09068693          	addi	a3,a3,144 # ffffffffc0206400 <etext+0xade>
ffffffffc0201378:	00005617          	auipc	a2,0x5
ffffffffc020137c:	fd860613          	addi	a2,a2,-40 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201380:	0db00593          	li	a1,219
ffffffffc0201384:	00005517          	auipc	a0,0x5
ffffffffc0201388:	fe450513          	addi	a0,a0,-28 # ffffffffc0206368 <etext+0xa46>
ffffffffc020138c:	8baff0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201390:	00005697          	auipc	a3,0x5
ffffffffc0201394:	01068693          	addi	a3,a3,16 # ffffffffc02063a0 <etext+0xa7e>
ffffffffc0201398:	00005617          	auipc	a2,0x5
ffffffffc020139c:	fb860613          	addi	a2,a2,-72 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02013a0:	0f000593          	li	a1,240
ffffffffc02013a4:	00005517          	auipc	a0,0x5
ffffffffc02013a8:	fc450513          	addi	a0,a0,-60 # ffffffffc0206368 <etext+0xa46>
ffffffffc02013ac:	89aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 3);
ffffffffc02013b0:	00005697          	auipc	a3,0x5
ffffffffc02013b4:	13068693          	addi	a3,a3,304 # ffffffffc02064e0 <etext+0xbbe>
ffffffffc02013b8:	00005617          	auipc	a2,0x5
ffffffffc02013bc:	f9860613          	addi	a2,a2,-104 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02013c0:	0ee00593          	li	a1,238
ffffffffc02013c4:	00005517          	auipc	a0,0x5
ffffffffc02013c8:	fa450513          	addi	a0,a0,-92 # ffffffffc0206368 <etext+0xa46>
ffffffffc02013cc:	87aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013d0:	00005697          	auipc	a3,0x5
ffffffffc02013d4:	0f868693          	addi	a3,a3,248 # ffffffffc02064c8 <etext+0xba6>
ffffffffc02013d8:	00005617          	auipc	a2,0x5
ffffffffc02013dc:	f7860613          	addi	a2,a2,-136 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02013e0:	0e900593          	li	a1,233
ffffffffc02013e4:	00005517          	auipc	a0,0x5
ffffffffc02013e8:	f8450513          	addi	a0,a0,-124 # ffffffffc0206368 <etext+0xa46>
ffffffffc02013ec:	85aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02013f0:	00005697          	auipc	a3,0x5
ffffffffc02013f4:	0b868693          	addi	a3,a3,184 # ffffffffc02064a8 <etext+0xb86>
ffffffffc02013f8:	00005617          	auipc	a2,0x5
ffffffffc02013fc:	f5860613          	addi	a2,a2,-168 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201400:	0e000593          	li	a1,224
ffffffffc0201404:	00005517          	auipc	a0,0x5
ffffffffc0201408:	f6450513          	addi	a0,a0,-156 # ffffffffc0206368 <etext+0xa46>
ffffffffc020140c:	83aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 != NULL);
ffffffffc0201410:	00005697          	auipc	a3,0x5
ffffffffc0201414:	12868693          	addi	a3,a3,296 # ffffffffc0206538 <etext+0xc16>
ffffffffc0201418:	00005617          	auipc	a2,0x5
ffffffffc020141c:	f3860613          	addi	a2,a2,-200 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201420:	11800593          	li	a1,280
ffffffffc0201424:	00005517          	auipc	a0,0x5
ffffffffc0201428:	f4450513          	addi	a0,a0,-188 # ffffffffc0206368 <etext+0xa46>
ffffffffc020142c:	81aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc0201430:	00005697          	auipc	a3,0x5
ffffffffc0201434:	0f868693          	addi	a3,a3,248 # ffffffffc0206528 <etext+0xc06>
ffffffffc0201438:	00005617          	auipc	a2,0x5
ffffffffc020143c:	f1860613          	addi	a2,a2,-232 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201440:	0fd00593          	li	a1,253
ffffffffc0201444:	00005517          	auipc	a0,0x5
ffffffffc0201448:	f2450513          	addi	a0,a0,-220 # ffffffffc0206368 <etext+0xa46>
ffffffffc020144c:	ffbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201450:	00005697          	auipc	a3,0x5
ffffffffc0201454:	07868693          	addi	a3,a3,120 # ffffffffc02064c8 <etext+0xba6>
ffffffffc0201458:	00005617          	auipc	a2,0x5
ffffffffc020145c:	ef860613          	addi	a2,a2,-264 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201460:	0fb00593          	li	a1,251
ffffffffc0201464:	00005517          	auipc	a0,0x5
ffffffffc0201468:	f0450513          	addi	a0,a0,-252 # ffffffffc0206368 <etext+0xa46>
ffffffffc020146c:	fdbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201470:	00005697          	auipc	a3,0x5
ffffffffc0201474:	09868693          	addi	a3,a3,152 # ffffffffc0206508 <etext+0xbe6>
ffffffffc0201478:	00005617          	auipc	a2,0x5
ffffffffc020147c:	ed860613          	addi	a2,a2,-296 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201480:	0fa00593          	li	a1,250
ffffffffc0201484:	00005517          	auipc	a0,0x5
ffffffffc0201488:	ee450513          	addi	a0,a0,-284 # ffffffffc0206368 <etext+0xa46>
ffffffffc020148c:	fbbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201490:	00005697          	auipc	a3,0x5
ffffffffc0201494:	f1068693          	addi	a3,a3,-240 # ffffffffc02063a0 <etext+0xa7e>
ffffffffc0201498:	00005617          	auipc	a2,0x5
ffffffffc020149c:	eb860613          	addi	a2,a2,-328 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02014a0:	0d700593          	li	a1,215
ffffffffc02014a4:	00005517          	auipc	a0,0x5
ffffffffc02014a8:	ec450513          	addi	a0,a0,-316 # ffffffffc0206368 <etext+0xa46>
ffffffffc02014ac:	f9bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014b0:	00005697          	auipc	a3,0x5
ffffffffc02014b4:	01868693          	addi	a3,a3,24 # ffffffffc02064c8 <etext+0xba6>
ffffffffc02014b8:	00005617          	auipc	a2,0x5
ffffffffc02014bc:	e9860613          	addi	a2,a2,-360 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02014c0:	0f400593          	li	a1,244
ffffffffc02014c4:	00005517          	auipc	a0,0x5
ffffffffc02014c8:	ea450513          	addi	a0,a0,-348 # ffffffffc0206368 <etext+0xa46>
ffffffffc02014cc:	f7bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014d0:	00005697          	auipc	a3,0x5
ffffffffc02014d4:	f1068693          	addi	a3,a3,-240 # ffffffffc02063e0 <etext+0xabe>
ffffffffc02014d8:	00005617          	auipc	a2,0x5
ffffffffc02014dc:	e7860613          	addi	a2,a2,-392 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02014e0:	0f200593          	li	a1,242
ffffffffc02014e4:	00005517          	auipc	a0,0x5
ffffffffc02014e8:	e8450513          	addi	a0,a0,-380 # ffffffffc0206368 <etext+0xa46>
ffffffffc02014ec:	f5bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014f0:	00005697          	auipc	a3,0x5
ffffffffc02014f4:	ed068693          	addi	a3,a3,-304 # ffffffffc02063c0 <etext+0xa9e>
ffffffffc02014f8:	00005617          	auipc	a2,0x5
ffffffffc02014fc:	e5860613          	addi	a2,a2,-424 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201500:	0f100593          	li	a1,241
ffffffffc0201504:	00005517          	auipc	a0,0x5
ffffffffc0201508:	e6450513          	addi	a0,a0,-412 # ffffffffc0206368 <etext+0xa46>
ffffffffc020150c:	f3bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201510:	00005697          	auipc	a3,0x5
ffffffffc0201514:	ed068693          	addi	a3,a3,-304 # ffffffffc02063e0 <etext+0xabe>
ffffffffc0201518:	00005617          	auipc	a2,0x5
ffffffffc020151c:	e3860613          	addi	a2,a2,-456 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201520:	0d900593          	li	a1,217
ffffffffc0201524:	00005517          	auipc	a0,0x5
ffffffffc0201528:	e4450513          	addi	a0,a0,-444 # ffffffffc0206368 <etext+0xa46>
ffffffffc020152c:	f1bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(count == 0);
ffffffffc0201530:	00005697          	auipc	a3,0x5
ffffffffc0201534:	15868693          	addi	a3,a3,344 # ffffffffc0206688 <etext+0xd66>
ffffffffc0201538:	00005617          	auipc	a2,0x5
ffffffffc020153c:	e1860613          	addi	a2,a2,-488 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201540:	14600593          	li	a1,326
ffffffffc0201544:	00005517          	auipc	a0,0x5
ffffffffc0201548:	e2450513          	addi	a0,a0,-476 # ffffffffc0206368 <etext+0xa46>
ffffffffc020154c:	efbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc0201550:	00005697          	auipc	a3,0x5
ffffffffc0201554:	fd868693          	addi	a3,a3,-40 # ffffffffc0206528 <etext+0xc06>
ffffffffc0201558:	00005617          	auipc	a2,0x5
ffffffffc020155c:	df860613          	addi	a2,a2,-520 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201560:	13a00593          	li	a1,314
ffffffffc0201564:	00005517          	auipc	a0,0x5
ffffffffc0201568:	e0450513          	addi	a0,a0,-508 # ffffffffc0206368 <etext+0xa46>
ffffffffc020156c:	edbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201570:	00005697          	auipc	a3,0x5
ffffffffc0201574:	f5868693          	addi	a3,a3,-168 # ffffffffc02064c8 <etext+0xba6>
ffffffffc0201578:	00005617          	auipc	a2,0x5
ffffffffc020157c:	dd860613          	addi	a2,a2,-552 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201580:	13800593          	li	a1,312
ffffffffc0201584:	00005517          	auipc	a0,0x5
ffffffffc0201588:	de450513          	addi	a0,a0,-540 # ffffffffc0206368 <etext+0xa46>
ffffffffc020158c:	ebbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201590:	00005697          	auipc	a3,0x5
ffffffffc0201594:	ef868693          	addi	a3,a3,-264 # ffffffffc0206488 <etext+0xb66>
ffffffffc0201598:	00005617          	auipc	a2,0x5
ffffffffc020159c:	db860613          	addi	a2,a2,-584 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02015a0:	0df00593          	li	a1,223
ffffffffc02015a4:	00005517          	auipc	a0,0x5
ffffffffc02015a8:	dc450513          	addi	a0,a0,-572 # ffffffffc0206368 <etext+0xa46>
ffffffffc02015ac:	e9bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02015b0:	00005697          	auipc	a3,0x5
ffffffffc02015b4:	09868693          	addi	a3,a3,152 # ffffffffc0206648 <etext+0xd26>
ffffffffc02015b8:	00005617          	auipc	a2,0x5
ffffffffc02015bc:	d9860613          	addi	a2,a2,-616 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02015c0:	13200593          	li	a1,306
ffffffffc02015c4:	00005517          	auipc	a0,0x5
ffffffffc02015c8:	da450513          	addi	a0,a0,-604 # ffffffffc0206368 <etext+0xa46>
ffffffffc02015cc:	e7bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02015d0:	00005697          	auipc	a3,0x5
ffffffffc02015d4:	05868693          	addi	a3,a3,88 # ffffffffc0206628 <etext+0xd06>
ffffffffc02015d8:	00005617          	auipc	a2,0x5
ffffffffc02015dc:	d7860613          	addi	a2,a2,-648 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02015e0:	13000593          	li	a1,304
ffffffffc02015e4:	00005517          	auipc	a0,0x5
ffffffffc02015e8:	d8450513          	addi	a0,a0,-636 # ffffffffc0206368 <etext+0xa46>
ffffffffc02015ec:	e5bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02015f0:	00005697          	auipc	a3,0x5
ffffffffc02015f4:	01068693          	addi	a3,a3,16 # ffffffffc0206600 <etext+0xcde>
ffffffffc02015f8:	00005617          	auipc	a2,0x5
ffffffffc02015fc:	d5860613          	addi	a2,a2,-680 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201600:	12e00593          	li	a1,302
ffffffffc0201604:	00005517          	auipc	a0,0x5
ffffffffc0201608:	d6450513          	addi	a0,a0,-668 # ffffffffc0206368 <etext+0xa46>
ffffffffc020160c:	e3bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201610:	00005697          	auipc	a3,0x5
ffffffffc0201614:	fc868693          	addi	a3,a3,-56 # ffffffffc02065d8 <etext+0xcb6>
ffffffffc0201618:	00005617          	auipc	a2,0x5
ffffffffc020161c:	d3860613          	addi	a2,a2,-712 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201620:	12d00593          	li	a1,301
ffffffffc0201624:	00005517          	auipc	a0,0x5
ffffffffc0201628:	d4450513          	addi	a0,a0,-700 # ffffffffc0206368 <etext+0xa46>
ffffffffc020162c:	e1bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201630:	00005697          	auipc	a3,0x5
ffffffffc0201634:	f9868693          	addi	a3,a3,-104 # ffffffffc02065c8 <etext+0xca6>
ffffffffc0201638:	00005617          	auipc	a2,0x5
ffffffffc020163c:	d1860613          	addi	a2,a2,-744 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201640:	12800593          	li	a1,296
ffffffffc0201644:	00005517          	auipc	a0,0x5
ffffffffc0201648:	d2450513          	addi	a0,a0,-732 # ffffffffc0206368 <etext+0xa46>
ffffffffc020164c:	dfbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201650:	00005697          	auipc	a3,0x5
ffffffffc0201654:	e7868693          	addi	a3,a3,-392 # ffffffffc02064c8 <etext+0xba6>
ffffffffc0201658:	00005617          	auipc	a2,0x5
ffffffffc020165c:	cf860613          	addi	a2,a2,-776 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201660:	12700593          	li	a1,295
ffffffffc0201664:	00005517          	auipc	a0,0x5
ffffffffc0201668:	d0450513          	addi	a0,a0,-764 # ffffffffc0206368 <etext+0xa46>
ffffffffc020166c:	ddbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201670:	00005697          	auipc	a3,0x5
ffffffffc0201674:	f3868693          	addi	a3,a3,-200 # ffffffffc02065a8 <etext+0xc86>
ffffffffc0201678:	00005617          	auipc	a2,0x5
ffffffffc020167c:	cd860613          	addi	a2,a2,-808 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201680:	12600593          	li	a1,294
ffffffffc0201684:	00005517          	auipc	a0,0x5
ffffffffc0201688:	ce450513          	addi	a0,a0,-796 # ffffffffc0206368 <etext+0xa46>
ffffffffc020168c:	dbbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201690:	00005697          	auipc	a3,0x5
ffffffffc0201694:	ee868693          	addi	a3,a3,-280 # ffffffffc0206578 <etext+0xc56>
ffffffffc0201698:	00005617          	auipc	a2,0x5
ffffffffc020169c:	cb860613          	addi	a2,a2,-840 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02016a0:	12500593          	li	a1,293
ffffffffc02016a4:	00005517          	auipc	a0,0x5
ffffffffc02016a8:	cc450513          	addi	a0,a0,-828 # ffffffffc0206368 <etext+0xa46>
ffffffffc02016ac:	d9bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02016b0:	00005697          	auipc	a3,0x5
ffffffffc02016b4:	eb068693          	addi	a3,a3,-336 # ffffffffc0206560 <etext+0xc3e>
ffffffffc02016b8:	00005617          	auipc	a2,0x5
ffffffffc02016bc:	c9860613          	addi	a2,a2,-872 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02016c0:	12400593          	li	a1,292
ffffffffc02016c4:	00005517          	auipc	a0,0x5
ffffffffc02016c8:	ca450513          	addi	a0,a0,-860 # ffffffffc0206368 <etext+0xa46>
ffffffffc02016cc:	d7bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016d0:	00005697          	auipc	a3,0x5
ffffffffc02016d4:	df868693          	addi	a3,a3,-520 # ffffffffc02064c8 <etext+0xba6>
ffffffffc02016d8:	00005617          	auipc	a2,0x5
ffffffffc02016dc:	c7860613          	addi	a2,a2,-904 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02016e0:	11e00593          	li	a1,286
ffffffffc02016e4:	00005517          	auipc	a0,0x5
ffffffffc02016e8:	c8450513          	addi	a0,a0,-892 # ffffffffc0206368 <etext+0xa46>
ffffffffc02016ec:	d5bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(!PageProperty(p0));
ffffffffc02016f0:	00005697          	auipc	a3,0x5
ffffffffc02016f4:	e5868693          	addi	a3,a3,-424 # ffffffffc0206548 <etext+0xc26>
ffffffffc02016f8:	00005617          	auipc	a2,0x5
ffffffffc02016fc:	c5860613          	addi	a2,a2,-936 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201700:	11900593          	li	a1,281
ffffffffc0201704:	00005517          	auipc	a0,0x5
ffffffffc0201708:	c6450513          	addi	a0,a0,-924 # ffffffffc0206368 <etext+0xa46>
ffffffffc020170c:	d3bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201710:	00005697          	auipc	a3,0x5
ffffffffc0201714:	f5868693          	addi	a3,a3,-168 # ffffffffc0206668 <etext+0xd46>
ffffffffc0201718:	00005617          	auipc	a2,0x5
ffffffffc020171c:	c3860613          	addi	a2,a2,-968 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201720:	13700593          	li	a1,311
ffffffffc0201724:	00005517          	auipc	a0,0x5
ffffffffc0201728:	c4450513          	addi	a0,a0,-956 # ffffffffc0206368 <etext+0xa46>
ffffffffc020172c:	d1bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(total == 0);
ffffffffc0201730:	00005697          	auipc	a3,0x5
ffffffffc0201734:	f6868693          	addi	a3,a3,-152 # ffffffffc0206698 <etext+0xd76>
ffffffffc0201738:	00005617          	auipc	a2,0x5
ffffffffc020173c:	c1860613          	addi	a2,a2,-1000 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201740:	14700593          	li	a1,327
ffffffffc0201744:	00005517          	auipc	a0,0x5
ffffffffc0201748:	c2450513          	addi	a0,a0,-988 # ffffffffc0206368 <etext+0xa46>
ffffffffc020174c:	cfbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201750:	00005697          	auipc	a3,0x5
ffffffffc0201754:	c3068693          	addi	a3,a3,-976 # ffffffffc0206380 <etext+0xa5e>
ffffffffc0201758:	00005617          	auipc	a2,0x5
ffffffffc020175c:	bf860613          	addi	a2,a2,-1032 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201760:	11300593          	li	a1,275
ffffffffc0201764:	00005517          	auipc	a0,0x5
ffffffffc0201768:	c0450513          	addi	a0,a0,-1020 # ffffffffc0206368 <etext+0xa46>
ffffffffc020176c:	cdbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201770:	00005697          	auipc	a3,0x5
ffffffffc0201774:	c5068693          	addi	a3,a3,-944 # ffffffffc02063c0 <etext+0xa9e>
ffffffffc0201778:	00005617          	auipc	a2,0x5
ffffffffc020177c:	bd860613          	addi	a2,a2,-1064 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201780:	0d800593          	li	a1,216
ffffffffc0201784:	00005517          	auipc	a0,0x5
ffffffffc0201788:	be450513          	addi	a0,a0,-1052 # ffffffffc0206368 <etext+0xa46>
ffffffffc020178c:	cbbfe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201790 <default_free_pages>:
{
ffffffffc0201790:	1141                	addi	sp,sp,-16
ffffffffc0201792:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201794:	14058663          	beqz	a1,ffffffffc02018e0 <default_free_pages+0x150>
    for (; p != base + n; p++)
ffffffffc0201798:	00659713          	slli	a4,a1,0x6
ffffffffc020179c:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02017a0:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02017a2:	c30d                	beqz	a4,ffffffffc02017c4 <default_free_pages+0x34>
ffffffffc02017a4:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017a6:	8b05                	andi	a4,a4,1
ffffffffc02017a8:	10071c63          	bnez	a4,ffffffffc02018c0 <default_free_pages+0x130>
ffffffffc02017ac:	6798                	ld	a4,8(a5)
ffffffffc02017ae:	8b09                	andi	a4,a4,2
ffffffffc02017b0:	10071863          	bnez	a4,ffffffffc02018c0 <default_free_pages+0x130>
        p->flags = 0;
ffffffffc02017b4:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02017b8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02017bc:	04078793          	addi	a5,a5,64
ffffffffc02017c0:	fed792e3          	bne	a5,a3,ffffffffc02017a4 <default_free_pages+0x14>
    base->property = n;
ffffffffc02017c4:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02017c6:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017ca:	4789                	li	a5,2
ffffffffc02017cc:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02017d0:	00096717          	auipc	a4,0x96
ffffffffc02017d4:	0f872703          	lw	a4,248(a4) # ffffffffc02978c8 <free_area+0x10>
ffffffffc02017d8:	00096697          	auipc	a3,0x96
ffffffffc02017dc:	0e068693          	addi	a3,a3,224 # ffffffffc02978b8 <free_area>
    return list->next == list;
ffffffffc02017e0:	669c                	ld	a5,8(a3)
ffffffffc02017e2:	9f2d                	addw	a4,a4,a1
ffffffffc02017e4:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc02017e6:	0ad78163          	beq	a5,a3,ffffffffc0201888 <default_free_pages+0xf8>
            struct Page *page = le2page(le, page_link);
ffffffffc02017ea:	fe878713          	addi	a4,a5,-24
ffffffffc02017ee:	4581                	li	a1,0
ffffffffc02017f0:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc02017f4:	00e56a63          	bltu	a0,a4,ffffffffc0201808 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02017f8:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02017fa:	04d70c63          	beq	a4,a3,ffffffffc0201852 <default_free_pages+0xc2>
    struct Page *p = base;
ffffffffc02017fe:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201800:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201804:	fee57ae3          	bgeu	a0,a4,ffffffffc02017f8 <default_free_pages+0x68>
ffffffffc0201808:	c199                	beqz	a1,ffffffffc020180e <default_free_pages+0x7e>
ffffffffc020180a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020180e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201810:	e390                	sd	a2,0(a5)
ffffffffc0201812:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc0201814:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201816:	f11c                	sd	a5,32(a0)
    if (le != &free_list)
ffffffffc0201818:	00d70d63          	beq	a4,a3,ffffffffc0201832 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc020181c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201820:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0201824:	02059813          	slli	a6,a1,0x20
ffffffffc0201828:	01a85793          	srli	a5,a6,0x1a
ffffffffc020182c:	97b2                	add	a5,a5,a2
ffffffffc020182e:	02f50c63          	beq	a0,a5,ffffffffc0201866 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201832:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0201834:	00d78c63          	beq	a5,a3,ffffffffc020184c <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0201838:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020183a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc020183e:	02061593          	slli	a1,a2,0x20
ffffffffc0201842:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201846:	972a                	add	a4,a4,a0
ffffffffc0201848:	04e68c63          	beq	a3,a4,ffffffffc02018a0 <default_free_pages+0x110>
}
ffffffffc020184c:	60a2                	ld	ra,8(sp)
ffffffffc020184e:	0141                	addi	sp,sp,16
ffffffffc0201850:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201852:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201854:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201856:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201858:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020185a:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc020185c:	02d70f63          	beq	a4,a3,ffffffffc020189a <default_free_pages+0x10a>
ffffffffc0201860:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201862:	87ba                	mv	a5,a4
ffffffffc0201864:	bf71                	j	ffffffffc0201800 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201866:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201868:	5875                	li	a6,-3
ffffffffc020186a:	9fad                	addw	a5,a5,a1
ffffffffc020186c:	fef72c23          	sw	a5,-8(a4)
ffffffffc0201870:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201874:	01853803          	ld	a6,24(a0)
ffffffffc0201878:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020187a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020187c:	00b83423          	sd	a1,8(a6) # ff0008 <_binary_obj___user_exit_out_size+0xfe5e20>
    return listelm->next;
ffffffffc0201880:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201882:	0105b023          	sd	a6,0(a1)
ffffffffc0201886:	b77d                	j	ffffffffc0201834 <default_free_pages+0xa4>
}
ffffffffc0201888:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020188a:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc020188e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201890:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201892:	e398                	sd	a4,0(a5)
ffffffffc0201894:	e798                	sd	a4,8(a5)
}
ffffffffc0201896:	0141                	addi	sp,sp,16
ffffffffc0201898:	8082                	ret
ffffffffc020189a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020189c:	873e                	mv	a4,a5
ffffffffc020189e:	bfad                	j	ffffffffc0201818 <default_free_pages+0x88>
            base->property += p->property;
ffffffffc02018a0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02018a4:	56f5                	li	a3,-3
ffffffffc02018a6:	9f31                	addw	a4,a4,a2
ffffffffc02018a8:	c918                	sw	a4,16(a0)
ffffffffc02018aa:	ff078713          	addi	a4,a5,-16
ffffffffc02018ae:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02018b2:	6398                	ld	a4,0(a5)
ffffffffc02018b4:	679c                	ld	a5,8(a5)
}
ffffffffc02018b6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02018b8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02018ba:	e398                	sd	a4,0(a5)
ffffffffc02018bc:	0141                	addi	sp,sp,16
ffffffffc02018be:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02018c0:	00005697          	auipc	a3,0x5
ffffffffc02018c4:	df068693          	addi	a3,a3,-528 # ffffffffc02066b0 <etext+0xd8e>
ffffffffc02018c8:	00005617          	auipc	a2,0x5
ffffffffc02018cc:	a8860613          	addi	a2,a2,-1400 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02018d0:	09400593          	li	a1,148
ffffffffc02018d4:	00005517          	auipc	a0,0x5
ffffffffc02018d8:	a9450513          	addi	a0,a0,-1388 # ffffffffc0206368 <etext+0xa46>
ffffffffc02018dc:	b6bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc02018e0:	00005697          	auipc	a3,0x5
ffffffffc02018e4:	dc868693          	addi	a3,a3,-568 # ffffffffc02066a8 <etext+0xd86>
ffffffffc02018e8:	00005617          	auipc	a2,0x5
ffffffffc02018ec:	a6860613          	addi	a2,a2,-1432 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02018f0:	09000593          	li	a1,144
ffffffffc02018f4:	00005517          	auipc	a0,0x5
ffffffffc02018f8:	a7450513          	addi	a0,a0,-1420 # ffffffffc0206368 <etext+0xa46>
ffffffffc02018fc:	b4bfe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201900 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201900:	c951                	beqz	a0,ffffffffc0201994 <default_alloc_pages+0x94>
    if (n > nr_free)
ffffffffc0201902:	00096597          	auipc	a1,0x96
ffffffffc0201906:	fc65a583          	lw	a1,-58(a1) # ffffffffc02978c8 <free_area+0x10>
ffffffffc020190a:	86aa                	mv	a3,a0
ffffffffc020190c:	02059793          	slli	a5,a1,0x20
ffffffffc0201910:	9381                	srli	a5,a5,0x20
ffffffffc0201912:	00a7ef63          	bltu	a5,a0,ffffffffc0201930 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc0201916:	00096617          	auipc	a2,0x96
ffffffffc020191a:	fa260613          	addi	a2,a2,-94 # ffffffffc02978b8 <free_area>
ffffffffc020191e:	87b2                	mv	a5,a2
ffffffffc0201920:	a029                	j	ffffffffc020192a <default_alloc_pages+0x2a>
        if (p->property >= n)
ffffffffc0201922:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0201926:	00d77763          	bgeu	a4,a3,ffffffffc0201934 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc020192a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020192c:	fec79be3          	bne	a5,a2,ffffffffc0201922 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0201930:	4501                	li	a0,0
}
ffffffffc0201932:	8082                	ret
        if (page->property > n)
ffffffffc0201934:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc0201938:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020193c:	6798                	ld	a4,8(a5)
ffffffffc020193e:	02089313          	slli	t1,a7,0x20
ffffffffc0201942:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc0201946:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020194a:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc020194e:	fe878513          	addi	a0,a5,-24
        if (page->property > n)
ffffffffc0201952:	0266fa63          	bgeu	a3,t1,ffffffffc0201986 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0201956:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc020195a:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc020195e:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201960:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201964:	00870313          	addi	t1,a4,8
ffffffffc0201968:	4889                	li	a7,2
ffffffffc020196a:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020196e:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc0201972:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc0201976:	0068b023          	sd	t1,0(a7)
ffffffffc020197a:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc020197e:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0201982:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc0201986:	9d95                	subw	a1,a1,a3
ffffffffc0201988:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020198a:	5775                	li	a4,-3
ffffffffc020198c:	17c1                	addi	a5,a5,-16
ffffffffc020198e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201992:	8082                	ret
{
ffffffffc0201994:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201996:	00005697          	auipc	a3,0x5
ffffffffc020199a:	d1268693          	addi	a3,a3,-750 # ffffffffc02066a8 <etext+0xd86>
ffffffffc020199e:	00005617          	auipc	a2,0x5
ffffffffc02019a2:	9b260613          	addi	a2,a2,-1614 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02019a6:	06c00593          	li	a1,108
ffffffffc02019aa:	00005517          	auipc	a0,0x5
ffffffffc02019ae:	9be50513          	addi	a0,a0,-1602 # ffffffffc0206368 <etext+0xa46>
{
ffffffffc02019b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02019b4:	a93fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02019b8 <default_init_memmap>:
{
ffffffffc02019b8:	1141                	addi	sp,sp,-16
ffffffffc02019ba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02019bc:	c9e1                	beqz	a1,ffffffffc0201a8c <default_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc02019be:	00659713          	slli	a4,a1,0x6
ffffffffc02019c2:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02019c6:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02019c8:	cf11                	beqz	a4,ffffffffc02019e4 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02019ca:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02019cc:	8b05                	andi	a4,a4,1
ffffffffc02019ce:	cf59                	beqz	a4,ffffffffc0201a6c <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02019d0:	0007a823          	sw	zero,16(a5)
ffffffffc02019d4:	0007b423          	sd	zero,8(a5)
ffffffffc02019d8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02019dc:	04078793          	addi	a5,a5,64
ffffffffc02019e0:	fed795e3          	bne	a5,a3,ffffffffc02019ca <default_init_memmap+0x12>
    base->property = n;
ffffffffc02019e4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019e6:	4789                	li	a5,2
ffffffffc02019e8:	00850713          	addi	a4,a0,8
ffffffffc02019ec:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02019f0:	00096717          	auipc	a4,0x96
ffffffffc02019f4:	ed872703          	lw	a4,-296(a4) # ffffffffc02978c8 <free_area+0x10>
ffffffffc02019f8:	00096697          	auipc	a3,0x96
ffffffffc02019fc:	ec068693          	addi	a3,a3,-320 # ffffffffc02978b8 <free_area>
    return list->next == list;
ffffffffc0201a00:	669c                	ld	a5,8(a3)
ffffffffc0201a02:	9f2d                	addw	a4,a4,a1
ffffffffc0201a04:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc0201a06:	04d78663          	beq	a5,a3,ffffffffc0201a52 <default_init_memmap+0x9a>
            struct Page *page = le2page(le, page_link);
ffffffffc0201a0a:	fe878713          	addi	a4,a5,-24
ffffffffc0201a0e:	4581                	li	a1,0
ffffffffc0201a10:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc0201a14:	00e56a63          	bltu	a0,a4,ffffffffc0201a28 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201a18:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201a1a:	02d70263          	beq	a4,a3,ffffffffc0201a3e <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc0201a1e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201a20:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201a24:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a18 <default_init_memmap+0x60>
ffffffffc0201a28:	c199                	beqz	a1,ffffffffc0201a2e <default_init_memmap+0x76>
ffffffffc0201a2a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201a2e:	6398                	ld	a4,0(a5)
}
ffffffffc0201a30:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201a32:	e390                	sd	a2,0(a5)
ffffffffc0201a34:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0201a36:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201a38:	f11c                	sd	a5,32(a0)
ffffffffc0201a3a:	0141                	addi	sp,sp,16
ffffffffc0201a3c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201a3e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201a40:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201a42:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201a44:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201a46:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc0201a48:	00d70e63          	beq	a4,a3,ffffffffc0201a64 <default_init_memmap+0xac>
ffffffffc0201a4c:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201a4e:	87ba                	mv	a5,a4
ffffffffc0201a50:	bfc1                	j	ffffffffc0201a20 <default_init_memmap+0x68>
}
ffffffffc0201a52:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201a54:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201a58:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201a5a:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201a5c:	e398                	sd	a4,0(a5)
ffffffffc0201a5e:	e798                	sd	a4,8(a5)
}
ffffffffc0201a60:	0141                	addi	sp,sp,16
ffffffffc0201a62:	8082                	ret
ffffffffc0201a64:	60a2                	ld	ra,8(sp)
ffffffffc0201a66:	e290                	sd	a2,0(a3)
ffffffffc0201a68:	0141                	addi	sp,sp,16
ffffffffc0201a6a:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201a6c:	00005697          	auipc	a3,0x5
ffffffffc0201a70:	c6c68693          	addi	a3,a3,-916 # ffffffffc02066d8 <etext+0xdb6>
ffffffffc0201a74:	00005617          	auipc	a2,0x5
ffffffffc0201a78:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201a7c:	04b00593          	li	a1,75
ffffffffc0201a80:	00005517          	auipc	a0,0x5
ffffffffc0201a84:	8e850513          	addi	a0,a0,-1816 # ffffffffc0206368 <etext+0xa46>
ffffffffc0201a88:	9bffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc0201a8c:	00005697          	auipc	a3,0x5
ffffffffc0201a90:	c1c68693          	addi	a3,a3,-996 # ffffffffc02066a8 <etext+0xd86>
ffffffffc0201a94:	00005617          	auipc	a2,0x5
ffffffffc0201a98:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201a9c:	04700593          	li	a1,71
ffffffffc0201aa0:	00005517          	auipc	a0,0x5
ffffffffc0201aa4:	8c850513          	addi	a0,a0,-1848 # ffffffffc0206368 <etext+0xa46>
ffffffffc0201aa8:	99ffe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201aac <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201aac:	c531                	beqz	a0,ffffffffc0201af8 <slob_free+0x4c>
		return;

	if (size)
ffffffffc0201aae:	e9b9                	bnez	a1,ffffffffc0201b04 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ab0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ab4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201ab6:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ab8:	efb1                	bnez	a5,ffffffffc0201b14 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201aba:	00096797          	auipc	a5,0x96
ffffffffc0201abe:	9ee7b783          	ld	a5,-1554(a5) # ffffffffc02974a8 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ac2:	873e                	mv	a4,a5
ffffffffc0201ac4:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ac6:	02a77a63          	bgeu	a4,a0,ffffffffc0201afa <slob_free+0x4e>
ffffffffc0201aca:	00f56463          	bltu	a0,a5,ffffffffc0201ad2 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ace:	fef76ae3          	bltu	a4,a5,ffffffffc0201ac2 <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc0201ad2:	4110                	lw	a2,0(a0)
ffffffffc0201ad4:	00461693          	slli	a3,a2,0x4
ffffffffc0201ad8:	96aa                	add	a3,a3,a0
ffffffffc0201ada:	0ad78463          	beq	a5,a3,ffffffffc0201b82 <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201ade:	4310                	lw	a2,0(a4)
ffffffffc0201ae0:	e51c                	sd	a5,8(a0)
ffffffffc0201ae2:	00461693          	slli	a3,a2,0x4
ffffffffc0201ae6:	96ba                	add	a3,a3,a4
ffffffffc0201ae8:	08d50163          	beq	a0,a3,ffffffffc0201b6a <slob_free+0xbe>
ffffffffc0201aec:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc0201aee:	00096797          	auipc	a5,0x96
ffffffffc0201af2:	9ae7bd23          	sd	a4,-1606(a5) # ffffffffc02974a8 <slobfree>
    if (flag)
ffffffffc0201af6:	e9a5                	bnez	a1,ffffffffc0201b66 <slob_free+0xba>
ffffffffc0201af8:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201afa:	fcf574e3          	bgeu	a0,a5,ffffffffc0201ac2 <slob_free+0x16>
ffffffffc0201afe:	fcf762e3          	bltu	a4,a5,ffffffffc0201ac2 <slob_free+0x16>
ffffffffc0201b02:	bfc1                	j	ffffffffc0201ad2 <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc0201b04:	25bd                	addiw	a1,a1,15
ffffffffc0201b06:	8191                	srli	a1,a1,0x4
ffffffffc0201b08:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b0a:	100027f3          	csrr	a5,sstatus
ffffffffc0201b0e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b10:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b12:	d7c5                	beqz	a5,ffffffffc0201aba <slob_free+0xe>
{
ffffffffc0201b14:	1101                	addi	sp,sp,-32
ffffffffc0201b16:	e42a                	sd	a0,8(sp)
ffffffffc0201b18:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201b1a:	debfe0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0201b1e:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b20:	00096797          	auipc	a5,0x96
ffffffffc0201b24:	9887b783          	ld	a5,-1656(a5) # ffffffffc02974a8 <slobfree>
ffffffffc0201b28:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b2a:	873e                	mv	a4,a5
ffffffffc0201b2c:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b2e:	06a77663          	bgeu	a4,a0,ffffffffc0201b9a <slob_free+0xee>
ffffffffc0201b32:	00f56463          	bltu	a0,a5,ffffffffc0201b3a <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b36:	fef76ae3          	bltu	a4,a5,ffffffffc0201b2a <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc0201b3a:	4110                	lw	a2,0(a0)
ffffffffc0201b3c:	00461693          	slli	a3,a2,0x4
ffffffffc0201b40:	96aa                	add	a3,a3,a0
ffffffffc0201b42:	06d78363          	beq	a5,a3,ffffffffc0201ba8 <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc0201b46:	4310                	lw	a2,0(a4)
ffffffffc0201b48:	e51c                	sd	a5,8(a0)
ffffffffc0201b4a:	00461693          	slli	a3,a2,0x4
ffffffffc0201b4e:	96ba                	add	a3,a3,a4
ffffffffc0201b50:	06d50163          	beq	a0,a3,ffffffffc0201bb2 <slob_free+0x106>
ffffffffc0201b54:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc0201b56:	00096797          	auipc	a5,0x96
ffffffffc0201b5a:	94e7b923          	sd	a4,-1710(a5) # ffffffffc02974a8 <slobfree>
    if (flag)
ffffffffc0201b5e:	e1a9                	bnez	a1,ffffffffc0201ba0 <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201b60:	60e2                	ld	ra,24(sp)
ffffffffc0201b62:	6105                	addi	sp,sp,32
ffffffffc0201b64:	8082                	ret
        intr_enable();
ffffffffc0201b66:	d99fe06f          	j	ffffffffc02008fe <intr_enable>
		cur->units += b->units;
ffffffffc0201b6a:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201b6c:	853e                	mv	a0,a5
ffffffffc0201b6e:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc0201b70:	00c687bb          	addw	a5,a3,a2
ffffffffc0201b74:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc0201b76:	00096797          	auipc	a5,0x96
ffffffffc0201b7a:	92e7b923          	sd	a4,-1742(a5) # ffffffffc02974a8 <slobfree>
    if (flag)
ffffffffc0201b7e:	ddad                	beqz	a1,ffffffffc0201af8 <slob_free+0x4c>
ffffffffc0201b80:	b7dd                	j	ffffffffc0201b66 <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc0201b82:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201b84:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201b86:	9eb1                	addw	a3,a3,a2
ffffffffc0201b88:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc0201b8a:	4310                	lw	a2,0(a4)
ffffffffc0201b8c:	e51c                	sd	a5,8(a0)
ffffffffc0201b8e:	00461693          	slli	a3,a2,0x4
ffffffffc0201b92:	96ba                	add	a3,a3,a4
ffffffffc0201b94:	f4d51ce3          	bne	a0,a3,ffffffffc0201aec <slob_free+0x40>
ffffffffc0201b98:	bfc9                	j	ffffffffc0201b6a <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b9a:	f8f56ee3          	bltu	a0,a5,ffffffffc0201b36 <slob_free+0x8a>
ffffffffc0201b9e:	b771                	j	ffffffffc0201b2a <slob_free+0x7e>
}
ffffffffc0201ba0:	60e2                	ld	ra,24(sp)
ffffffffc0201ba2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201ba4:	d5bfe06f          	j	ffffffffc02008fe <intr_enable>
		b->units += cur->next->units;
ffffffffc0201ba8:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201baa:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201bac:	9eb1                	addw	a3,a3,a2
ffffffffc0201bae:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0201bb0:	bf59                	j	ffffffffc0201b46 <slob_free+0x9a>
		cur->units += b->units;
ffffffffc0201bb2:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201bb4:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc0201bb6:	00c687bb          	addw	a5,a3,a2
ffffffffc0201bba:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201bbc:	bf61                	j	ffffffffc0201b54 <slob_free+0xa8>

ffffffffc0201bbe <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bbe:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201bc0:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bc2:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201bc6:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bc8:	32a000ef          	jal	ffffffffc0201ef2 <alloc_pages>
	if (!page)
ffffffffc0201bcc:	c91d                	beqz	a0,ffffffffc0201c02 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201bce:	0009a697          	auipc	a3,0x9a
ffffffffc0201bd2:	d6a6b683          	ld	a3,-662(a3) # ffffffffc029b938 <pages>
ffffffffc0201bd6:	00006797          	auipc	a5,0x6
ffffffffc0201bda:	eda7b783          	ld	a5,-294(a5) # ffffffffc0207ab0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201bde:	0009a717          	auipc	a4,0x9a
ffffffffc0201be2:	d5273703          	ld	a4,-686(a4) # ffffffffc029b930 <npage>
    return page - pages + nbase;
ffffffffc0201be6:	8d15                	sub	a0,a0,a3
ffffffffc0201be8:	8519                	srai	a0,a0,0x6
ffffffffc0201bea:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201bec:	00c51793          	slli	a5,a0,0xc
ffffffffc0201bf0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bf2:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201bf4:	00e7fa63          	bgeu	a5,a4,ffffffffc0201c08 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201bf8:	0009a797          	auipc	a5,0x9a
ffffffffc0201bfc:	d307b783          	ld	a5,-720(a5) # ffffffffc029b928 <va_pa_offset>
ffffffffc0201c00:	953e                	add	a0,a0,a5
}
ffffffffc0201c02:	60a2                	ld	ra,8(sp)
ffffffffc0201c04:	0141                	addi	sp,sp,16
ffffffffc0201c06:	8082                	ret
ffffffffc0201c08:	86aa                	mv	a3,a0
ffffffffc0201c0a:	00005617          	auipc	a2,0x5
ffffffffc0201c0e:	af660613          	addi	a2,a2,-1290 # ffffffffc0206700 <etext+0xdde>
ffffffffc0201c12:	07100593          	li	a1,113
ffffffffc0201c16:	00005517          	auipc	a0,0x5
ffffffffc0201c1a:	b1250513          	addi	a0,a0,-1262 # ffffffffc0206728 <etext+0xe06>
ffffffffc0201c1e:	829fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201c22 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201c22:	7179                	addi	sp,sp,-48
ffffffffc0201c24:	f406                	sd	ra,40(sp)
ffffffffc0201c26:	f022                	sd	s0,32(sp)
ffffffffc0201c28:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201c2a:	01050713          	addi	a4,a0,16
ffffffffc0201c2e:	6785                	lui	a5,0x1
ffffffffc0201c30:	0af77e63          	bgeu	a4,a5,ffffffffc0201cec <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201c34:	00f50413          	addi	s0,a0,15
ffffffffc0201c38:	8011                	srli	s0,s0,0x4
ffffffffc0201c3a:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c3c:	100025f3          	csrr	a1,sstatus
ffffffffc0201c40:	8989                	andi	a1,a1,2
ffffffffc0201c42:	edd1                	bnez	a1,ffffffffc0201cde <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201c44:	00096497          	auipc	s1,0x96
ffffffffc0201c48:	86448493          	addi	s1,s1,-1948 # ffffffffc02974a8 <slobfree>
ffffffffc0201c4c:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c4e:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201c50:	4314                	lw	a3,0(a4)
ffffffffc0201c52:	0886da63          	bge	a3,s0,ffffffffc0201ce6 <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc0201c56:	00e60a63          	beq	a2,a4,ffffffffc0201c6a <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c5a:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201c5c:	4394                	lw	a3,0(a5)
ffffffffc0201c5e:	0286d863          	bge	a3,s0,ffffffffc0201c8e <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201c62:	6090                	ld	a2,0(s1)
ffffffffc0201c64:	873e                	mv	a4,a5
ffffffffc0201c66:	fee61ae3          	bne	a2,a4,ffffffffc0201c5a <slob_alloc.constprop.0+0x38>
    if (flag)
ffffffffc0201c6a:	e9b1                	bnez	a1,ffffffffc0201cbe <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201c6c:	4501                	li	a0,0
ffffffffc0201c6e:	f51ff0ef          	jal	ffffffffc0201bbe <__slob_get_free_pages.constprop.0>
ffffffffc0201c72:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201c74:	c915                	beqz	a0,ffffffffc0201ca8 <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201c76:	6585                	lui	a1,0x1
ffffffffc0201c78:	e35ff0ef          	jal	ffffffffc0201aac <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c7c:	100025f3          	csrr	a1,sstatus
ffffffffc0201c80:	8989                	andi	a1,a1,2
ffffffffc0201c82:	e98d                	bnez	a1,ffffffffc0201cb4 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201c84:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c86:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201c88:	4394                	lw	a3,0(a5)
ffffffffc0201c8a:	fc86cce3          	blt	a3,s0,ffffffffc0201c62 <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201c8e:	04d40563          	beq	s0,a3,ffffffffc0201cd8 <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201c92:	00441613          	slli	a2,s0,0x4
ffffffffc0201c96:	963e                	add	a2,a2,a5
ffffffffc0201c98:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201c9a:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201c9c:	9e81                	subw	a3,a3,s0
ffffffffc0201c9e:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201ca0:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201ca2:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201ca4:	e098                	sd	a4,0(s1)
    if (flag)
ffffffffc0201ca6:	ed99                	bnez	a1,ffffffffc0201cc4 <slob_alloc.constprop.0+0xa2>
}
ffffffffc0201ca8:	70a2                	ld	ra,40(sp)
ffffffffc0201caa:	7402                	ld	s0,32(sp)
ffffffffc0201cac:	64e2                	ld	s1,24(sp)
ffffffffc0201cae:	853e                	mv	a0,a5
ffffffffc0201cb0:	6145                	addi	sp,sp,48
ffffffffc0201cb2:	8082                	ret
        intr_disable();
ffffffffc0201cb4:	c51fe0ef          	jal	ffffffffc0200904 <intr_disable>
			cur = slobfree;
ffffffffc0201cb8:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0201cba:	4585                	li	a1,1
ffffffffc0201cbc:	b7e9                	j	ffffffffc0201c86 <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc0201cbe:	c41fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201cc2:	b76d                	j	ffffffffc0201c6c <slob_alloc.constprop.0+0x4a>
ffffffffc0201cc4:	e43e                	sd	a5,8(sp)
ffffffffc0201cc6:	c39fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201cca:	67a2                	ld	a5,8(sp)
}
ffffffffc0201ccc:	70a2                	ld	ra,40(sp)
ffffffffc0201cce:	7402                	ld	s0,32(sp)
ffffffffc0201cd0:	64e2                	ld	s1,24(sp)
ffffffffc0201cd2:	853e                	mv	a0,a5
ffffffffc0201cd4:	6145                	addi	sp,sp,48
ffffffffc0201cd6:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201cd8:	6794                	ld	a3,8(a5)
ffffffffc0201cda:	e714                	sd	a3,8(a4)
ffffffffc0201cdc:	b7e1                	j	ffffffffc0201ca4 <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc0201cde:	c27fe0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0201ce2:	4585                	li	a1,1
ffffffffc0201ce4:	b785                	j	ffffffffc0201c44 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201ce6:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201ce8:	8732                	mv	a4,a2
ffffffffc0201cea:	b755                	j	ffffffffc0201c8e <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201cec:	00005697          	auipc	a3,0x5
ffffffffc0201cf0:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0206738 <etext+0xe16>
ffffffffc0201cf4:	00004617          	auipc	a2,0x4
ffffffffc0201cf8:	65c60613          	addi	a2,a2,1628 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0201cfc:	06300593          	li	a1,99
ffffffffc0201d00:	00005517          	auipc	a0,0x5
ffffffffc0201d04:	a5850513          	addi	a0,a0,-1448 # ffffffffc0206758 <etext+0xe36>
ffffffffc0201d08:	f3efe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201d0c <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201d0c:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201d0e:	00005517          	auipc	a0,0x5
ffffffffc0201d12:	a6250513          	addi	a0,a0,-1438 # ffffffffc0206770 <etext+0xe4e>
{
ffffffffc0201d16:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201d18:	c7cfe0ef          	jal	ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201d1c:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d1e:	00005517          	auipc	a0,0x5
ffffffffc0201d22:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0206788 <etext+0xe66>
}
ffffffffc0201d26:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d28:	c6cfe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201d2c <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201d2c:	4501                	li	a0,0
ffffffffc0201d2e:	8082                	ret

ffffffffc0201d30 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201d30:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d32:	6685                	lui	a3,0x1
{
ffffffffc0201d34:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d36:	16bd                	addi	a3,a3,-17 # fef <_binary_obj___user_softint_out_size-0x7c01>
ffffffffc0201d38:	04a6f963          	bgeu	a3,a0,ffffffffc0201d8a <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201d3c:	e42a                	sd	a0,8(sp)
ffffffffc0201d3e:	4561                	li	a0,24
ffffffffc0201d40:	e822                	sd	s0,16(sp)
ffffffffc0201d42:	ee1ff0ef          	jal	ffffffffc0201c22 <slob_alloc.constprop.0>
ffffffffc0201d46:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201d48:	c541                	beqz	a0,ffffffffc0201dd0 <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201d4a:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201d4c:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201d4e:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201d50:	00f75763          	bge	a4,a5,ffffffffc0201d5e <kmalloc+0x2e>
ffffffffc0201d54:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201d58:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201d5a:	fef74de3          	blt	a4,a5,ffffffffc0201d54 <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201d5e:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201d60:	e5fff0ef          	jal	ffffffffc0201bbe <__slob_get_free_pages.constprop.0>
ffffffffc0201d64:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201d66:	cd31                	beqz	a0,ffffffffc0201dc2 <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201d68:	100027f3          	csrr	a5,sstatus
ffffffffc0201d6c:	8b89                	andi	a5,a5,2
ffffffffc0201d6e:	eb85                	bnez	a5,ffffffffc0201d9e <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201d70:	0009a797          	auipc	a5,0x9a
ffffffffc0201d74:	b987b783          	ld	a5,-1128(a5) # ffffffffc029b908 <bigblocks>
		bigblocks = bb;
ffffffffc0201d78:	0009a717          	auipc	a4,0x9a
ffffffffc0201d7c:	b8873823          	sd	s0,-1136(a4) # ffffffffc029b908 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201d80:	e81c                	sd	a5,16(s0)
    if (flag)
ffffffffc0201d82:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201d84:	60e2                	ld	ra,24(sp)
ffffffffc0201d86:	6105                	addi	sp,sp,32
ffffffffc0201d88:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201d8a:	0541                	addi	a0,a0,16
ffffffffc0201d8c:	e97ff0ef          	jal	ffffffffc0201c22 <slob_alloc.constprop.0>
ffffffffc0201d90:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201d92:	0541                	addi	a0,a0,16
ffffffffc0201d94:	fbe5                	bnez	a5,ffffffffc0201d84 <kmalloc+0x54>
		return 0;
ffffffffc0201d96:	4501                	li	a0,0
}
ffffffffc0201d98:	60e2                	ld	ra,24(sp)
ffffffffc0201d9a:	6105                	addi	sp,sp,32
ffffffffc0201d9c:	8082                	ret
        intr_disable();
ffffffffc0201d9e:	b67fe0ef          	jal	ffffffffc0200904 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201da2:	0009a797          	auipc	a5,0x9a
ffffffffc0201da6:	b667b783          	ld	a5,-1178(a5) # ffffffffc029b908 <bigblocks>
		bigblocks = bb;
ffffffffc0201daa:	0009a717          	auipc	a4,0x9a
ffffffffc0201dae:	b4873f23          	sd	s0,-1186(a4) # ffffffffc029b908 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201db2:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc0201db4:	b4bfe0ef          	jal	ffffffffc02008fe <intr_enable>
		return bb->pages;
ffffffffc0201db8:	6408                	ld	a0,8(s0)
}
ffffffffc0201dba:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201dbc:	6442                	ld	s0,16(sp)
}
ffffffffc0201dbe:	6105                	addi	sp,sp,32
ffffffffc0201dc0:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dc2:	8522                	mv	a0,s0
ffffffffc0201dc4:	45e1                	li	a1,24
ffffffffc0201dc6:	ce7ff0ef          	jal	ffffffffc0201aac <slob_free>
		return 0;
ffffffffc0201dca:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dcc:	6442                	ld	s0,16(sp)
ffffffffc0201dce:	b7e9                	j	ffffffffc0201d98 <kmalloc+0x68>
ffffffffc0201dd0:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201dd2:	4501                	li	a0,0
ffffffffc0201dd4:	b7d1                	j	ffffffffc0201d98 <kmalloc+0x68>

ffffffffc0201dd6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201dd6:	c571                	beqz	a0,ffffffffc0201ea2 <kfree+0xcc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201dd8:	03451793          	slli	a5,a0,0x34
ffffffffc0201ddc:	e3e1                	bnez	a5,ffffffffc0201e9c <kfree+0xc6>
{
ffffffffc0201dde:	1101                	addi	sp,sp,-32
ffffffffc0201de0:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201de2:	100027f3          	csrr	a5,sstatus
ffffffffc0201de6:	8b89                	andi	a5,a5,2
ffffffffc0201de8:	e7c1                	bnez	a5,ffffffffc0201e70 <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201dea:	0009a797          	auipc	a5,0x9a
ffffffffc0201dee:	b1e7b783          	ld	a5,-1250(a5) # ffffffffc029b908 <bigblocks>
    return 0;
ffffffffc0201df2:	4581                	li	a1,0
ffffffffc0201df4:	cbad                	beqz	a5,ffffffffc0201e66 <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201df6:	0009a617          	auipc	a2,0x9a
ffffffffc0201dfa:	b1260613          	addi	a2,a2,-1262 # ffffffffc029b908 <bigblocks>
ffffffffc0201dfe:	a021                	j	ffffffffc0201e06 <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e00:	01070613          	addi	a2,a4,16
ffffffffc0201e04:	c3a5                	beqz	a5,ffffffffc0201e64 <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201e06:	6794                	ld	a3,8(a5)
ffffffffc0201e08:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201e0a:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201e0c:	fea69ae3          	bne	a3,a0,ffffffffc0201e00 <kfree+0x2a>
				*last = bb->next;
ffffffffc0201e10:	e21c                	sd	a5,0(a2)
    if (flag)
ffffffffc0201e12:	edb5                	bnez	a1,ffffffffc0201e8e <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201e14:	c02007b7          	lui	a5,0xc0200
ffffffffc0201e18:	0af56263          	bltu	a0,a5,ffffffffc0201ebc <kfree+0xe6>
ffffffffc0201e1c:	0009a797          	auipc	a5,0x9a
ffffffffc0201e20:	b0c7b783          	ld	a5,-1268(a5) # ffffffffc029b928 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201e24:	0009a697          	auipc	a3,0x9a
ffffffffc0201e28:	b0c6b683          	ld	a3,-1268(a3) # ffffffffc029b930 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201e2c:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201e2e:	00c55793          	srli	a5,a0,0xc
ffffffffc0201e32:	06d7f963          	bgeu	a5,a3,ffffffffc0201ea4 <kfree+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e36:	00006617          	auipc	a2,0x6
ffffffffc0201e3a:	c7a63603          	ld	a2,-902(a2) # ffffffffc0207ab0 <nbase>
ffffffffc0201e3e:	0009a517          	auipc	a0,0x9a
ffffffffc0201e42:	afa53503          	ld	a0,-1286(a0) # ffffffffc029b938 <pages>
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201e46:	4314                	lw	a3,0(a4)
ffffffffc0201e48:	8f91                	sub	a5,a5,a2
ffffffffc0201e4a:	079a                	slli	a5,a5,0x6
ffffffffc0201e4c:	4585                	li	a1,1
ffffffffc0201e4e:	953e                	add	a0,a0,a5
ffffffffc0201e50:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201e54:	e03a                	sd	a4,0(sp)
ffffffffc0201e56:	0d6000ef          	jal	ffffffffc0201f2c <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e5a:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201e5c:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e5e:	45e1                	li	a1,24
}
ffffffffc0201e60:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e62:	b1a9                	j	ffffffffc0201aac <slob_free>
ffffffffc0201e64:	e185                	bnez	a1,ffffffffc0201e84 <kfree+0xae>
}
ffffffffc0201e66:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e68:	1541                	addi	a0,a0,-16
ffffffffc0201e6a:	4581                	li	a1,0
}
ffffffffc0201e6c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e6e:	b93d                	j	ffffffffc0201aac <slob_free>
        intr_disable();
ffffffffc0201e70:	e02a                	sd	a0,0(sp)
ffffffffc0201e72:	a93fe0ef          	jal	ffffffffc0200904 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e76:	0009a797          	auipc	a5,0x9a
ffffffffc0201e7a:	a927b783          	ld	a5,-1390(a5) # ffffffffc029b908 <bigblocks>
ffffffffc0201e7e:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc0201e80:	4585                	li	a1,1
ffffffffc0201e82:	fbb5                	bnez	a5,ffffffffc0201df6 <kfree+0x20>
ffffffffc0201e84:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc0201e86:	a79fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201e8a:	6502                	ld	a0,0(sp)
ffffffffc0201e8c:	bfe9                	j	ffffffffc0201e66 <kfree+0x90>
ffffffffc0201e8e:	e42a                	sd	a0,8(sp)
ffffffffc0201e90:	e03a                	sd	a4,0(sp)
ffffffffc0201e92:	a6dfe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201e96:	6522                	ld	a0,8(sp)
ffffffffc0201e98:	6702                	ld	a4,0(sp)
ffffffffc0201e9a:	bfad                	j	ffffffffc0201e14 <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e9c:	1541                	addi	a0,a0,-16
ffffffffc0201e9e:	4581                	li	a1,0
ffffffffc0201ea0:	b131                	j	ffffffffc0201aac <slob_free>
ffffffffc0201ea2:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201ea4:	00005617          	auipc	a2,0x5
ffffffffc0201ea8:	92c60613          	addi	a2,a2,-1748 # ffffffffc02067d0 <etext+0xeae>
ffffffffc0201eac:	06900593          	li	a1,105
ffffffffc0201eb0:	00005517          	auipc	a0,0x5
ffffffffc0201eb4:	87850513          	addi	a0,a0,-1928 # ffffffffc0206728 <etext+0xe06>
ffffffffc0201eb8:	d8efe0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201ebc:	86aa                	mv	a3,a0
ffffffffc0201ebe:	00005617          	auipc	a2,0x5
ffffffffc0201ec2:	8ea60613          	addi	a2,a2,-1814 # ffffffffc02067a8 <etext+0xe86>
ffffffffc0201ec6:	07700593          	li	a1,119
ffffffffc0201eca:	00005517          	auipc	a0,0x5
ffffffffc0201ece:	85e50513          	addi	a0,a0,-1954 # ffffffffc0206728 <etext+0xe06>
ffffffffc0201ed2:	d74fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201ed6 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201ed6:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201ed8:	00005617          	auipc	a2,0x5
ffffffffc0201edc:	8f860613          	addi	a2,a2,-1800 # ffffffffc02067d0 <etext+0xeae>
ffffffffc0201ee0:	06900593          	li	a1,105
ffffffffc0201ee4:	00005517          	auipc	a0,0x5
ffffffffc0201ee8:	84450513          	addi	a0,a0,-1980 # ffffffffc0206728 <etext+0xe06>
pa2page(uintptr_t pa)
ffffffffc0201eec:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201eee:	d58fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201ef2 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ef2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ef6:	8b89                	andi	a5,a5,2
ffffffffc0201ef8:	e799                	bnez	a5,ffffffffc0201f06 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201efa:	0009a797          	auipc	a5,0x9a
ffffffffc0201efe:	a167b783          	ld	a5,-1514(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0201f02:	6f9c                	ld	a5,24(a5)
ffffffffc0201f04:	8782                	jr	a5
{
ffffffffc0201f06:	1101                	addi	sp,sp,-32
ffffffffc0201f08:	ec06                	sd	ra,24(sp)
ffffffffc0201f0a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201f0c:	9f9fe0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f10:	0009a797          	auipc	a5,0x9a
ffffffffc0201f14:	a007b783          	ld	a5,-1536(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0201f18:	6522                	ld	a0,8(sp)
ffffffffc0201f1a:	6f9c                	ld	a5,24(a5)
ffffffffc0201f1c:	9782                	jalr	a5
ffffffffc0201f1e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201f20:	9dffe0ef          	jal	ffffffffc02008fe <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201f24:	60e2                	ld	ra,24(sp)
ffffffffc0201f26:	6522                	ld	a0,8(sp)
ffffffffc0201f28:	6105                	addi	sp,sp,32
ffffffffc0201f2a:	8082                	ret

ffffffffc0201f2c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f2c:	100027f3          	csrr	a5,sstatus
ffffffffc0201f30:	8b89                	andi	a5,a5,2
ffffffffc0201f32:	e799                	bnez	a5,ffffffffc0201f40 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201f34:	0009a797          	auipc	a5,0x9a
ffffffffc0201f38:	9dc7b783          	ld	a5,-1572(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0201f3c:	739c                	ld	a5,32(a5)
ffffffffc0201f3e:	8782                	jr	a5
{
ffffffffc0201f40:	1101                	addi	sp,sp,-32
ffffffffc0201f42:	ec06                	sd	ra,24(sp)
ffffffffc0201f44:	e42e                	sd	a1,8(sp)
ffffffffc0201f46:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201f48:	9bdfe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f4c:	0009a797          	auipc	a5,0x9a
ffffffffc0201f50:	9c47b783          	ld	a5,-1596(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0201f54:	65a2                	ld	a1,8(sp)
ffffffffc0201f56:	6502                	ld	a0,0(sp)
ffffffffc0201f58:	739c                	ld	a5,32(a5)
ffffffffc0201f5a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f5c:	60e2                	ld	ra,24(sp)
ffffffffc0201f5e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f60:	99ffe06f          	j	ffffffffc02008fe <intr_enable>

ffffffffc0201f64 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f64:	100027f3          	csrr	a5,sstatus
ffffffffc0201f68:	8b89                	andi	a5,a5,2
ffffffffc0201f6a:	e799                	bnez	a5,ffffffffc0201f78 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f6c:	0009a797          	auipc	a5,0x9a
ffffffffc0201f70:	9a47b783          	ld	a5,-1628(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0201f74:	779c                	ld	a5,40(a5)
ffffffffc0201f76:	8782                	jr	a5
{
ffffffffc0201f78:	1101                	addi	sp,sp,-32
ffffffffc0201f7a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201f7c:	989fe0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f80:	0009a797          	auipc	a5,0x9a
ffffffffc0201f84:	9907b783          	ld	a5,-1648(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0201f88:	779c                	ld	a5,40(a5)
ffffffffc0201f8a:	9782                	jalr	a5
ffffffffc0201f8c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201f8e:	971fe0ef          	jal	ffffffffc02008fe <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f92:	60e2                	ld	ra,24(sp)
ffffffffc0201f94:	6522                	ld	a0,8(sp)
ffffffffc0201f96:	6105                	addi	sp,sp,32
ffffffffc0201f98:	8082                	ret

ffffffffc0201f9a <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f9a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201f9e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201fa2:	078e                	slli	a5,a5,0x3
ffffffffc0201fa4:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201fa8:	6314                	ld	a3,0(a4)
{
ffffffffc0201faa:	7139                	addi	sp,sp,-64
ffffffffc0201fac:	f822                	sd	s0,48(sp)
ffffffffc0201fae:	f426                	sd	s1,40(sp)
ffffffffc0201fb0:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201fb2:	0016f793          	andi	a5,a3,1
{
ffffffffc0201fb6:	842e                	mv	s0,a1
ffffffffc0201fb8:	8832                	mv	a6,a2
ffffffffc0201fba:	0009a497          	auipc	s1,0x9a
ffffffffc0201fbe:	97648493          	addi	s1,s1,-1674 # ffffffffc029b930 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201fc2:	ebd1                	bnez	a5,ffffffffc0202056 <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fc4:	16060d63          	beqz	a2,ffffffffc020213e <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fc8:	100027f3          	csrr	a5,sstatus
ffffffffc0201fcc:	8b89                	andi	a5,a5,2
ffffffffc0201fce:	16079e63          	bnez	a5,ffffffffc020214a <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fd2:	0009a797          	auipc	a5,0x9a
ffffffffc0201fd6:	93e7b783          	ld	a5,-1730(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0201fda:	4505                	li	a0,1
ffffffffc0201fdc:	e43a                	sd	a4,8(sp)
ffffffffc0201fde:	6f9c                	ld	a5,24(a5)
ffffffffc0201fe0:	e832                	sd	a2,16(sp)
ffffffffc0201fe2:	9782                	jalr	a5
ffffffffc0201fe4:	6722                	ld	a4,8(sp)
ffffffffc0201fe6:	6842                	ld	a6,16(sp)
ffffffffc0201fe8:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fea:	14078a63          	beqz	a5,ffffffffc020213e <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201fee:	0009a517          	auipc	a0,0x9a
ffffffffc0201ff2:	94a53503          	ld	a0,-1718(a0) # ffffffffc029b938 <pages>
ffffffffc0201ff6:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ffa:	0009a497          	auipc	s1,0x9a
ffffffffc0201ffe:	93648493          	addi	s1,s1,-1738 # ffffffffc029b930 <npage>
ffffffffc0202002:	40a78533          	sub	a0,a5,a0
ffffffffc0202006:	8519                	srai	a0,a0,0x6
ffffffffc0202008:	9546                	add	a0,a0,a7
ffffffffc020200a:	6090                	ld	a2,0(s1)
ffffffffc020200c:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc0202010:	4585                	li	a1,1
ffffffffc0202012:	82b1                	srli	a3,a3,0xc
ffffffffc0202014:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202016:	0532                	slli	a0,a0,0xc
ffffffffc0202018:	1ac6f763          	bgeu	a3,a2,ffffffffc02021c6 <get_pte+0x22c>
ffffffffc020201c:	0009a697          	auipc	a3,0x9a
ffffffffc0202020:	90c6b683          	ld	a3,-1780(a3) # ffffffffc029b928 <va_pa_offset>
ffffffffc0202024:	6605                	lui	a2,0x1
ffffffffc0202026:	4581                	li	a1,0
ffffffffc0202028:	9536                	add	a0,a0,a3
ffffffffc020202a:	ec42                	sd	a6,24(sp)
ffffffffc020202c:	e83e                	sd	a5,16(sp)
ffffffffc020202e:	e43a                	sd	a4,8(sp)
ffffffffc0202030:	0c9030ef          	jal	ffffffffc02058f8 <memset>
    return page - pages + nbase;
ffffffffc0202034:	0009a697          	auipc	a3,0x9a
ffffffffc0202038:	9046b683          	ld	a3,-1788(a3) # ffffffffc029b938 <pages>
ffffffffc020203c:	67c2                	ld	a5,16(sp)
ffffffffc020203e:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202042:	6722                	ld	a4,8(sp)
ffffffffc0202044:	40d786b3          	sub	a3,a5,a3
ffffffffc0202048:	8699                	srai	a3,a3,0x6
ffffffffc020204a:	96c6                	add	a3,a3,a7
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020204c:	06aa                	slli	a3,a3,0xa
ffffffffc020204e:	6862                	ld	a6,24(sp)
ffffffffc0202050:	0116e693          	ori	a3,a3,17
ffffffffc0202054:	e314                	sd	a3,0(a4)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202056:	c006f693          	andi	a3,a3,-1024
ffffffffc020205a:	6098                	ld	a4,0(s1)
ffffffffc020205c:	068a                	slli	a3,a3,0x2
ffffffffc020205e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202062:	14e7f663          	bgeu	a5,a4,ffffffffc02021ae <get_pte+0x214>
ffffffffc0202066:	0009a897          	auipc	a7,0x9a
ffffffffc020206a:	8c288893          	addi	a7,a7,-1854 # ffffffffc029b928 <va_pa_offset>
ffffffffc020206e:	0008b603          	ld	a2,0(a7)
ffffffffc0202072:	01545793          	srli	a5,s0,0x15
ffffffffc0202076:	1ff7f793          	andi	a5,a5,511
ffffffffc020207a:	96b2                	add	a3,a3,a2
ffffffffc020207c:	078e                	slli	a5,a5,0x3
ffffffffc020207e:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0202080:	6394                	ld	a3,0(a5)
ffffffffc0202082:	0016f613          	andi	a2,a3,1
ffffffffc0202086:	e659                	bnez	a2,ffffffffc0202114 <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202088:	0a080b63          	beqz	a6,ffffffffc020213e <get_pte+0x1a4>
ffffffffc020208c:	10002773          	csrr	a4,sstatus
ffffffffc0202090:	8b09                	andi	a4,a4,2
ffffffffc0202092:	ef71                	bnez	a4,ffffffffc020216e <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202094:	0009a717          	auipc	a4,0x9a
ffffffffc0202098:	87c73703          	ld	a4,-1924(a4) # ffffffffc029b910 <pmm_manager>
ffffffffc020209c:	4505                	li	a0,1
ffffffffc020209e:	e43e                	sd	a5,8(sp)
ffffffffc02020a0:	6f18                	ld	a4,24(a4)
ffffffffc02020a2:	9702                	jalr	a4
ffffffffc02020a4:	67a2                	ld	a5,8(sp)
ffffffffc02020a6:	872a                	mv	a4,a0
ffffffffc02020a8:	0009a897          	auipc	a7,0x9a
ffffffffc02020ac:	88088893          	addi	a7,a7,-1920 # ffffffffc029b928 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02020b0:	c759                	beqz	a4,ffffffffc020213e <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc02020b2:	0009a697          	auipc	a3,0x9a
ffffffffc02020b6:	8866b683          	ld	a3,-1914(a3) # ffffffffc029b938 <pages>
ffffffffc02020ba:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020be:	608c                	ld	a1,0(s1)
ffffffffc02020c0:	40d706b3          	sub	a3,a4,a3
ffffffffc02020c4:	8699                	srai	a3,a3,0x6
ffffffffc02020c6:	96c2                	add	a3,a3,a6
ffffffffc02020c8:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc02020cc:	4505                	li	a0,1
ffffffffc02020ce:	8231                	srli	a2,a2,0xc
ffffffffc02020d0:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc02020d2:	06b2                	slli	a3,a3,0xc
ffffffffc02020d4:	10b67663          	bgeu	a2,a1,ffffffffc02021e0 <get_pte+0x246>
ffffffffc02020d8:	0008b503          	ld	a0,0(a7)
ffffffffc02020dc:	6605                	lui	a2,0x1
ffffffffc02020de:	4581                	li	a1,0
ffffffffc02020e0:	9536                	add	a0,a0,a3
ffffffffc02020e2:	e83a                	sd	a4,16(sp)
ffffffffc02020e4:	e43e                	sd	a5,8(sp)
ffffffffc02020e6:	013030ef          	jal	ffffffffc02058f8 <memset>
    return page - pages + nbase;
ffffffffc02020ea:	0009a697          	auipc	a3,0x9a
ffffffffc02020ee:	84e6b683          	ld	a3,-1970(a3) # ffffffffc029b938 <pages>
ffffffffc02020f2:	6742                	ld	a4,16(sp)
ffffffffc02020f4:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02020f8:	67a2                	ld	a5,8(sp)
ffffffffc02020fa:	40d706b3          	sub	a3,a4,a3
ffffffffc02020fe:	8699                	srai	a3,a3,0x6
ffffffffc0202100:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202102:	06aa                	slli	a3,a3,0xa
ffffffffc0202104:	0116e693          	ori	a3,a3,17
ffffffffc0202108:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020210a:	6098                	ld	a4,0(s1)
ffffffffc020210c:	0009a897          	auipc	a7,0x9a
ffffffffc0202110:	81c88893          	addi	a7,a7,-2020 # ffffffffc029b928 <va_pa_offset>
ffffffffc0202114:	c006f693          	andi	a3,a3,-1024
ffffffffc0202118:	068a                	slli	a3,a3,0x2
ffffffffc020211a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020211e:	06e7fc63          	bgeu	a5,a4,ffffffffc0202196 <get_pte+0x1fc>
ffffffffc0202122:	0008b783          	ld	a5,0(a7)
ffffffffc0202126:	8031                	srli	s0,s0,0xc
ffffffffc0202128:	1ff47413          	andi	s0,s0,511
ffffffffc020212c:	040e                	slli	s0,s0,0x3
ffffffffc020212e:	96be                	add	a3,a3,a5
}
ffffffffc0202130:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202132:	00868533          	add	a0,a3,s0
}
ffffffffc0202136:	7442                	ld	s0,48(sp)
ffffffffc0202138:	74a2                	ld	s1,40(sp)
ffffffffc020213a:	6121                	addi	sp,sp,64
ffffffffc020213c:	8082                	ret
ffffffffc020213e:	70e2                	ld	ra,56(sp)
ffffffffc0202140:	7442                	ld	s0,48(sp)
ffffffffc0202142:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc0202144:	4501                	li	a0,0
}
ffffffffc0202146:	6121                	addi	sp,sp,64
ffffffffc0202148:	8082                	ret
        intr_disable();
ffffffffc020214a:	e83a                	sd	a4,16(sp)
ffffffffc020214c:	ec32                	sd	a2,24(sp)
ffffffffc020214e:	fb6fe0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202152:	00099797          	auipc	a5,0x99
ffffffffc0202156:	7be7b783          	ld	a5,1982(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc020215a:	4505                	li	a0,1
ffffffffc020215c:	6f9c                	ld	a5,24(a5)
ffffffffc020215e:	9782                	jalr	a5
ffffffffc0202160:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202162:	f9cfe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202166:	6862                	ld	a6,24(sp)
ffffffffc0202168:	6742                	ld	a4,16(sp)
ffffffffc020216a:	67a2                	ld	a5,8(sp)
ffffffffc020216c:	bdbd                	j	ffffffffc0201fea <get_pte+0x50>
        intr_disable();
ffffffffc020216e:	e83e                	sd	a5,16(sp)
ffffffffc0202170:	f94fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202174:	00099717          	auipc	a4,0x99
ffffffffc0202178:	79c73703          	ld	a4,1948(a4) # ffffffffc029b910 <pmm_manager>
ffffffffc020217c:	4505                	li	a0,1
ffffffffc020217e:	6f18                	ld	a4,24(a4)
ffffffffc0202180:	9702                	jalr	a4
ffffffffc0202182:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202184:	f7afe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202188:	6722                	ld	a4,8(sp)
ffffffffc020218a:	67c2                	ld	a5,16(sp)
ffffffffc020218c:	00099897          	auipc	a7,0x99
ffffffffc0202190:	79c88893          	addi	a7,a7,1948 # ffffffffc029b928 <va_pa_offset>
ffffffffc0202194:	bf31                	j	ffffffffc02020b0 <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202196:	00004617          	auipc	a2,0x4
ffffffffc020219a:	56a60613          	addi	a2,a2,1386 # ffffffffc0206700 <etext+0xdde>
ffffffffc020219e:	0fa00593          	li	a1,250
ffffffffc02021a2:	00004517          	auipc	a0,0x4
ffffffffc02021a6:	64e50513          	addi	a0,a0,1614 # ffffffffc02067f0 <etext+0xece>
ffffffffc02021aa:	a9cfe0ef          	jal	ffffffffc0200446 <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02021ae:	00004617          	auipc	a2,0x4
ffffffffc02021b2:	55260613          	addi	a2,a2,1362 # ffffffffc0206700 <etext+0xdde>
ffffffffc02021b6:	0ed00593          	li	a1,237
ffffffffc02021ba:	00004517          	auipc	a0,0x4
ffffffffc02021be:	63650513          	addi	a0,a0,1590 # ffffffffc02067f0 <etext+0xece>
ffffffffc02021c2:	a84fe0ef          	jal	ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02021c6:	86aa                	mv	a3,a0
ffffffffc02021c8:	00004617          	auipc	a2,0x4
ffffffffc02021cc:	53860613          	addi	a2,a2,1336 # ffffffffc0206700 <etext+0xdde>
ffffffffc02021d0:	0e900593          	li	a1,233
ffffffffc02021d4:	00004517          	auipc	a0,0x4
ffffffffc02021d8:	61c50513          	addi	a0,a0,1564 # ffffffffc02067f0 <etext+0xece>
ffffffffc02021dc:	a6afe0ef          	jal	ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02021e0:	00004617          	auipc	a2,0x4
ffffffffc02021e4:	52060613          	addi	a2,a2,1312 # ffffffffc0206700 <etext+0xdde>
ffffffffc02021e8:	0f700593          	li	a1,247
ffffffffc02021ec:	00004517          	auipc	a0,0x4
ffffffffc02021f0:	60450513          	addi	a0,a0,1540 # ffffffffc02067f0 <etext+0xece>
ffffffffc02021f4:	a52fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02021f8 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc02021f8:	1141                	addi	sp,sp,-16
ffffffffc02021fa:	e022                	sd	s0,0(sp)
ffffffffc02021fc:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02021fe:	4601                	li	a2,0
{
ffffffffc0202200:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202202:	d99ff0ef          	jal	ffffffffc0201f9a <get_pte>
    if (ptep_store != NULL)
ffffffffc0202206:	c011                	beqz	s0,ffffffffc020220a <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202208:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020220a:	c511                	beqz	a0,ffffffffc0202216 <get_page+0x1e>
ffffffffc020220c:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020220e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202210:	0017f713          	andi	a4,a5,1
ffffffffc0202214:	e709                	bnez	a4,ffffffffc020221e <get_page+0x26>
}
ffffffffc0202216:	60a2                	ld	ra,8(sp)
ffffffffc0202218:	6402                	ld	s0,0(sp)
ffffffffc020221a:	0141                	addi	sp,sp,16
ffffffffc020221c:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc020221e:	00099717          	auipc	a4,0x99
ffffffffc0202222:	71273703          	ld	a4,1810(a4) # ffffffffc029b930 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202226:	078a                	slli	a5,a5,0x2
ffffffffc0202228:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020222a:	00e7ff63          	bgeu	a5,a4,ffffffffc0202248 <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc020222e:	00099517          	auipc	a0,0x99
ffffffffc0202232:	70a53503          	ld	a0,1802(a0) # ffffffffc029b938 <pages>
ffffffffc0202236:	60a2                	ld	ra,8(sp)
ffffffffc0202238:	6402                	ld	s0,0(sp)
ffffffffc020223a:	079a                	slli	a5,a5,0x6
ffffffffc020223c:	fe000737          	lui	a4,0xfe000
ffffffffc0202240:	97ba                	add	a5,a5,a4
ffffffffc0202242:	953e                	add	a0,a0,a5
ffffffffc0202244:	0141                	addi	sp,sp,16
ffffffffc0202246:	8082                	ret
ffffffffc0202248:	c8fff0ef          	jal	ffffffffc0201ed6 <pa2page.part.0>

ffffffffc020224c <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc020224c:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020224e:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202252:	e486                	sd	ra,72(sp)
ffffffffc0202254:	e0a2                	sd	s0,64(sp)
ffffffffc0202256:	fc26                	sd	s1,56(sp)
ffffffffc0202258:	f84a                	sd	s2,48(sp)
ffffffffc020225a:	f44e                	sd	s3,40(sp)
ffffffffc020225c:	f052                	sd	s4,32(sp)
ffffffffc020225e:	ec56                	sd	s5,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202260:	03479713          	slli	a4,a5,0x34
ffffffffc0202264:	ef61                	bnez	a4,ffffffffc020233c <unmap_range+0xf0>
    assert(USER_ACCESS(start, end));
ffffffffc0202266:	00200a37          	lui	s4,0x200
ffffffffc020226a:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc020226e:	0145b733          	sltu	a4,a1,s4
ffffffffc0202272:	0017b793          	seqz	a5,a5
ffffffffc0202276:	8fd9                	or	a5,a5,a4
ffffffffc0202278:	842e                	mv	s0,a1
ffffffffc020227a:	84b2                	mv	s1,a2
ffffffffc020227c:	e3e5                	bnez	a5,ffffffffc020235c <unmap_range+0x110>
ffffffffc020227e:	4785                	li	a5,1
ffffffffc0202280:	07fe                	slli	a5,a5,0x1f
ffffffffc0202282:	0785                	addi	a5,a5,1
ffffffffc0202284:	892a                	mv	s2,a0
ffffffffc0202286:	6985                	lui	s3,0x1
    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202288:	ffe00ab7          	lui	s5,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc020228c:	0cf67863          	bgeu	a2,a5,ffffffffc020235c <unmap_range+0x110>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202290:	4601                	li	a2,0
ffffffffc0202292:	85a2                	mv	a1,s0
ffffffffc0202294:	854a                	mv	a0,s2
ffffffffc0202296:	d05ff0ef          	jal	ffffffffc0201f9a <get_pte>
ffffffffc020229a:	87aa                	mv	a5,a0
        if (ptep == NULL)
ffffffffc020229c:	cd31                	beqz	a0,ffffffffc02022f8 <unmap_range+0xac>
            continue;
        }
        if (*ptep != 0)
ffffffffc020229e:	6118                	ld	a4,0(a0)
ffffffffc02022a0:	ef11                	bnez	a4,ffffffffc02022bc <unmap_range+0x70>
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02022a2:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02022a4:	c019                	beqz	s0,ffffffffc02022aa <unmap_range+0x5e>
ffffffffc02022a6:	fe9465e3          	bltu	s0,s1,ffffffffc0202290 <unmap_range+0x44>
}
ffffffffc02022aa:	60a6                	ld	ra,72(sp)
ffffffffc02022ac:	6406                	ld	s0,64(sp)
ffffffffc02022ae:	74e2                	ld	s1,56(sp)
ffffffffc02022b0:	7942                	ld	s2,48(sp)
ffffffffc02022b2:	79a2                	ld	s3,40(sp)
ffffffffc02022b4:	7a02                	ld	s4,32(sp)
ffffffffc02022b6:	6ae2                	ld	s5,24(sp)
ffffffffc02022b8:	6161                	addi	sp,sp,80
ffffffffc02022ba:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc02022bc:	00177693          	andi	a3,a4,1
ffffffffc02022c0:	d2ed                	beqz	a3,ffffffffc02022a2 <unmap_range+0x56>
    if (PPN(pa) >= npage)
ffffffffc02022c2:	00099697          	auipc	a3,0x99
ffffffffc02022c6:	66e6b683          	ld	a3,1646(a3) # ffffffffc029b930 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02022ca:	070a                	slli	a4,a4,0x2
ffffffffc02022cc:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02022ce:	0ad77763          	bgeu	a4,a3,ffffffffc020237c <unmap_range+0x130>
    return &pages[PPN(pa) - nbase];
ffffffffc02022d2:	00099517          	auipc	a0,0x99
ffffffffc02022d6:	66653503          	ld	a0,1638(a0) # ffffffffc029b938 <pages>
ffffffffc02022da:	071a                	slli	a4,a4,0x6
ffffffffc02022dc:	fe0006b7          	lui	a3,0xfe000
ffffffffc02022e0:	9736                	add	a4,a4,a3
ffffffffc02022e2:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc02022e4:	4118                	lw	a4,0(a0)
ffffffffc02022e6:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd6469f>
ffffffffc02022e8:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02022ea:	cb19                	beqz	a4,ffffffffc0202300 <unmap_range+0xb4>
        *ptep = 0;
ffffffffc02022ec:	0007b023          	sd	zero,0(a5)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02022f0:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02022f4:	944e                	add	s0,s0,s3
ffffffffc02022f6:	b77d                	j	ffffffffc02022a4 <unmap_range+0x58>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02022f8:	9452                	add	s0,s0,s4
ffffffffc02022fa:	01547433          	and	s0,s0,s5
            continue;
ffffffffc02022fe:	b75d                	j	ffffffffc02022a4 <unmap_range+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202300:	10002773          	csrr	a4,sstatus
ffffffffc0202304:	8b09                	andi	a4,a4,2
ffffffffc0202306:	eb19                	bnez	a4,ffffffffc020231c <unmap_range+0xd0>
        pmm_manager->free_pages(base, n);
ffffffffc0202308:	00099717          	auipc	a4,0x99
ffffffffc020230c:	60873703          	ld	a4,1544(a4) # ffffffffc029b910 <pmm_manager>
ffffffffc0202310:	4585                	li	a1,1
ffffffffc0202312:	e03e                	sd	a5,0(sp)
ffffffffc0202314:	7318                	ld	a4,32(a4)
ffffffffc0202316:	9702                	jalr	a4
    if (flag)
ffffffffc0202318:	6782                	ld	a5,0(sp)
ffffffffc020231a:	bfc9                	j	ffffffffc02022ec <unmap_range+0xa0>
        intr_disable();
ffffffffc020231c:	e43e                	sd	a5,8(sp)
ffffffffc020231e:	e02a                	sd	a0,0(sp)
ffffffffc0202320:	de4fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202324:	00099717          	auipc	a4,0x99
ffffffffc0202328:	5ec73703          	ld	a4,1516(a4) # ffffffffc029b910 <pmm_manager>
ffffffffc020232c:	6502                	ld	a0,0(sp)
ffffffffc020232e:	4585                	li	a1,1
ffffffffc0202330:	7318                	ld	a4,32(a4)
ffffffffc0202332:	9702                	jalr	a4
        intr_enable();
ffffffffc0202334:	dcafe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202338:	67a2                	ld	a5,8(sp)
ffffffffc020233a:	bf4d                	j	ffffffffc02022ec <unmap_range+0xa0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020233c:	00004697          	auipc	a3,0x4
ffffffffc0202340:	4c468693          	addi	a3,a3,1220 # ffffffffc0206800 <etext+0xede>
ffffffffc0202344:	00004617          	auipc	a2,0x4
ffffffffc0202348:	00c60613          	addi	a2,a2,12 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020234c:	12000593          	li	a1,288
ffffffffc0202350:	00004517          	auipc	a0,0x4
ffffffffc0202354:	4a050513          	addi	a0,a0,1184 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202358:	8eefe0ef          	jal	ffffffffc0200446 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020235c:	00004697          	auipc	a3,0x4
ffffffffc0202360:	4d468693          	addi	a3,a3,1236 # ffffffffc0206830 <etext+0xf0e>
ffffffffc0202364:	00004617          	auipc	a2,0x4
ffffffffc0202368:	fec60613          	addi	a2,a2,-20 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020236c:	12100593          	li	a1,289
ffffffffc0202370:	00004517          	auipc	a0,0x4
ffffffffc0202374:	48050513          	addi	a0,a0,1152 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202378:	8cefe0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc020237c:	b5bff0ef          	jal	ffffffffc0201ed6 <pa2page.part.0>

ffffffffc0202380 <exit_range>:
{
ffffffffc0202380:	7135                	addi	sp,sp,-160
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202382:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202386:	ed06                	sd	ra,152(sp)
ffffffffc0202388:	e922                	sd	s0,144(sp)
ffffffffc020238a:	e526                	sd	s1,136(sp)
ffffffffc020238c:	e14a                	sd	s2,128(sp)
ffffffffc020238e:	fcce                	sd	s3,120(sp)
ffffffffc0202390:	f8d2                	sd	s4,112(sp)
ffffffffc0202392:	f4d6                	sd	s5,104(sp)
ffffffffc0202394:	f0da                	sd	s6,96(sp)
ffffffffc0202396:	ecde                	sd	s7,88(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202398:	17d2                	slli	a5,a5,0x34
ffffffffc020239a:	22079263          	bnez	a5,ffffffffc02025be <exit_range+0x23e>
    assert(USER_ACCESS(start, end));
ffffffffc020239e:	00200937          	lui	s2,0x200
ffffffffc02023a2:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc02023a6:	0125b733          	sltu	a4,a1,s2
ffffffffc02023aa:	0017b793          	seqz	a5,a5
ffffffffc02023ae:	8fd9                	or	a5,a5,a4
ffffffffc02023b0:	26079263          	bnez	a5,ffffffffc0202614 <exit_range+0x294>
ffffffffc02023b4:	4785                	li	a5,1
ffffffffc02023b6:	07fe                	slli	a5,a5,0x1f
ffffffffc02023b8:	0785                	addi	a5,a5,1
ffffffffc02023ba:	24f67d63          	bgeu	a2,a5,ffffffffc0202614 <exit_range+0x294>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02023be:	c00004b7          	lui	s1,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02023c2:	ffe007b7          	lui	a5,0xffe00
ffffffffc02023c6:	8a2a                	mv	s4,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02023c8:	8ced                	and	s1,s1,a1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02023ca:	00f5f833          	and	a6,a1,a5
    if (PPN(pa) >= npage)
ffffffffc02023ce:	00099a97          	auipc	s5,0x99
ffffffffc02023d2:	562a8a93          	addi	s5,s5,1378 # ffffffffc029b930 <npage>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02023d6:	400009b7          	lui	s3,0x40000
ffffffffc02023da:	a809                	j	ffffffffc02023ec <exit_range+0x6c>
        d1start += PDSIZE;
ffffffffc02023dc:	013487b3          	add	a5,s1,s3
ffffffffc02023e0:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc02023e4:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc02023e6:	c3f1                	beqz	a5,ffffffffc02024aa <exit_range+0x12a>
ffffffffc02023e8:	0cc7f163          	bgeu	a5,a2,ffffffffc02024aa <exit_range+0x12a>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02023ec:	01e4d413          	srli	s0,s1,0x1e
ffffffffc02023f0:	1ff47413          	andi	s0,s0,511
ffffffffc02023f4:	040e                	slli	s0,s0,0x3
ffffffffc02023f6:	9452                	add	s0,s0,s4
ffffffffc02023f8:	00043883          	ld	a7,0(s0)
        if (pde1 & PTE_V)
ffffffffc02023fc:	0018f793          	andi	a5,a7,1
ffffffffc0202400:	dff1                	beqz	a5,ffffffffc02023dc <exit_range+0x5c>
ffffffffc0202402:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202406:	088a                	slli	a7,a7,0x2
ffffffffc0202408:	00c8d893          	srli	a7,a7,0xc
    if (PPN(pa) >= npage)
ffffffffc020240c:	20f8f263          	bgeu	a7,a5,ffffffffc0202610 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202410:	fff802b7          	lui	t0,0xfff80
ffffffffc0202414:	00588f33          	add	t5,a7,t0
    return page - pages + nbase;
ffffffffc0202418:	000803b7          	lui	t2,0x80
ffffffffc020241c:	007f0733          	add	a4,t5,t2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202420:	00c71e13          	slli	t3,a4,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202424:	0f1a                	slli	t5,t5,0x6
    return KADDR(page2pa(page));
ffffffffc0202426:	1cf77863          	bgeu	a4,a5,ffffffffc02025f6 <exit_range+0x276>
ffffffffc020242a:	00099f97          	auipc	t6,0x99
ffffffffc020242e:	4fef8f93          	addi	t6,t6,1278 # ffffffffc029b928 <va_pa_offset>
ffffffffc0202432:	000fb783          	ld	a5,0(t6)
            free_pd0 = 1;
ffffffffc0202436:	4e85                	li	t4,1
ffffffffc0202438:	6b05                	lui	s6,0x1
ffffffffc020243a:	9e3e                	add	t3,t3,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020243c:	01348333          	add	t1,s1,s3
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202440:	01585713          	srli	a4,a6,0x15
ffffffffc0202444:	1ff77713          	andi	a4,a4,511
ffffffffc0202448:	070e                	slli	a4,a4,0x3
ffffffffc020244a:	9772                	add	a4,a4,t3
ffffffffc020244c:	631c                	ld	a5,0(a4)
                if (pde0 & PTE_V)
ffffffffc020244e:	0017f693          	andi	a3,a5,1
ffffffffc0202452:	e6bd                	bnez	a3,ffffffffc02024c0 <exit_range+0x140>
                    free_pd0 = 0;
ffffffffc0202454:	4e81                	li	t4,0
                d0start += PTSIZE;
ffffffffc0202456:	984a                	add	a6,a6,s2
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202458:	00080863          	beqz	a6,ffffffffc0202468 <exit_range+0xe8>
ffffffffc020245c:	879a                	mv	a5,t1
ffffffffc020245e:	00667363          	bgeu	a2,t1,ffffffffc0202464 <exit_range+0xe4>
ffffffffc0202462:	87b2                	mv	a5,a2
ffffffffc0202464:	fcf86ee3          	bltu	a6,a5,ffffffffc0202440 <exit_range+0xc0>
            if (free_pd0)
ffffffffc0202468:	f60e8ae3          	beqz	t4,ffffffffc02023dc <exit_range+0x5c>
    if (PPN(pa) >= npage)
ffffffffc020246c:	000ab783          	ld	a5,0(s5)
ffffffffc0202470:	1af8f063          	bgeu	a7,a5,ffffffffc0202610 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202474:	00099517          	auipc	a0,0x99
ffffffffc0202478:	4c453503          	ld	a0,1220(a0) # ffffffffc029b938 <pages>
ffffffffc020247c:	957a                	add	a0,a0,t5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020247e:	100027f3          	csrr	a5,sstatus
ffffffffc0202482:	8b89                	andi	a5,a5,2
ffffffffc0202484:	10079b63          	bnez	a5,ffffffffc020259a <exit_range+0x21a>
        pmm_manager->free_pages(base, n);
ffffffffc0202488:	00099797          	auipc	a5,0x99
ffffffffc020248c:	4887b783          	ld	a5,1160(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0202490:	4585                	li	a1,1
ffffffffc0202492:	e432                	sd	a2,8(sp)
ffffffffc0202494:	739c                	ld	a5,32(a5)
ffffffffc0202496:	9782                	jalr	a5
ffffffffc0202498:	6622                	ld	a2,8(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc020249a:	00043023          	sd	zero,0(s0)
        d1start += PDSIZE;
ffffffffc020249e:	013487b3          	add	a5,s1,s3
ffffffffc02024a2:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc02024a6:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc02024a8:	f3a1                	bnez	a5,ffffffffc02023e8 <exit_range+0x68>
}
ffffffffc02024aa:	60ea                	ld	ra,152(sp)
ffffffffc02024ac:	644a                	ld	s0,144(sp)
ffffffffc02024ae:	64aa                	ld	s1,136(sp)
ffffffffc02024b0:	690a                	ld	s2,128(sp)
ffffffffc02024b2:	79e6                	ld	s3,120(sp)
ffffffffc02024b4:	7a46                	ld	s4,112(sp)
ffffffffc02024b6:	7aa6                	ld	s5,104(sp)
ffffffffc02024b8:	7b06                	ld	s6,96(sp)
ffffffffc02024ba:	6be6                	ld	s7,88(sp)
ffffffffc02024bc:	610d                	addi	sp,sp,160
ffffffffc02024be:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02024c0:	000ab503          	ld	a0,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024c4:	078a                	slli	a5,a5,0x2
ffffffffc02024c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02024c8:	14a7f463          	bgeu	a5,a0,ffffffffc0202610 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc02024cc:	9796                	add	a5,a5,t0
    return page - pages + nbase;
ffffffffc02024ce:	00778bb3          	add	s7,a5,t2
    return &pages[PPN(pa) - nbase];
ffffffffc02024d2:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024d6:	00cb9693          	slli	a3,s7,0xc
    return KADDR(page2pa(page));
ffffffffc02024da:	10abf263          	bgeu	s7,a0,ffffffffc02025de <exit_range+0x25e>
ffffffffc02024de:	000fb783          	ld	a5,0(t6)
ffffffffc02024e2:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024e4:	01668533          	add	a0,a3,s6
                        if (pt[i] & PTE_V)
ffffffffc02024e8:	629c                	ld	a5,0(a3)
ffffffffc02024ea:	8b85                	andi	a5,a5,1
ffffffffc02024ec:	f7ad                	bnez	a5,ffffffffc0202456 <exit_range+0xd6>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024ee:	06a1                	addi	a3,a3,8
ffffffffc02024f0:	fea69ce3          	bne	a3,a0,ffffffffc02024e8 <exit_range+0x168>
    return &pages[PPN(pa) - nbase];
ffffffffc02024f4:	00099517          	auipc	a0,0x99
ffffffffc02024f8:	44453503          	ld	a0,1092(a0) # ffffffffc029b938 <pages>
ffffffffc02024fc:	952e                	add	a0,a0,a1
ffffffffc02024fe:	100027f3          	csrr	a5,sstatus
ffffffffc0202502:	8b89                	andi	a5,a5,2
ffffffffc0202504:	e3b9                	bnez	a5,ffffffffc020254a <exit_range+0x1ca>
        pmm_manager->free_pages(base, n);
ffffffffc0202506:	00099797          	auipc	a5,0x99
ffffffffc020250a:	40a7b783          	ld	a5,1034(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc020250e:	4585                	li	a1,1
ffffffffc0202510:	e0b2                	sd	a2,64(sp)
ffffffffc0202512:	739c                	ld	a5,32(a5)
ffffffffc0202514:	fc1a                	sd	t1,56(sp)
ffffffffc0202516:	f846                	sd	a7,48(sp)
ffffffffc0202518:	f47a                	sd	t5,40(sp)
ffffffffc020251a:	f072                	sd	t3,32(sp)
ffffffffc020251c:	ec76                	sd	t4,24(sp)
ffffffffc020251e:	e842                	sd	a6,16(sp)
ffffffffc0202520:	e43a                	sd	a4,8(sp)
ffffffffc0202522:	9782                	jalr	a5
    if (flag)
ffffffffc0202524:	6722                	ld	a4,8(sp)
ffffffffc0202526:	6842                	ld	a6,16(sp)
ffffffffc0202528:	6ee2                	ld	t4,24(sp)
ffffffffc020252a:	7e02                	ld	t3,32(sp)
ffffffffc020252c:	7f22                	ld	t5,40(sp)
ffffffffc020252e:	78c2                	ld	a7,48(sp)
ffffffffc0202530:	7362                	ld	t1,56(sp)
ffffffffc0202532:	6606                	ld	a2,64(sp)
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202534:	fff802b7          	lui	t0,0xfff80
ffffffffc0202538:	000803b7          	lui	t2,0x80
ffffffffc020253c:	00099f97          	auipc	t6,0x99
ffffffffc0202540:	3ecf8f93          	addi	t6,t6,1004 # ffffffffc029b928 <va_pa_offset>
ffffffffc0202544:	00073023          	sd	zero,0(a4)
ffffffffc0202548:	b739                	j	ffffffffc0202456 <exit_range+0xd6>
        intr_disable();
ffffffffc020254a:	e4b2                	sd	a2,72(sp)
ffffffffc020254c:	e09a                	sd	t1,64(sp)
ffffffffc020254e:	fc46                	sd	a7,56(sp)
ffffffffc0202550:	f47a                	sd	t5,40(sp)
ffffffffc0202552:	f072                	sd	t3,32(sp)
ffffffffc0202554:	ec76                	sd	t4,24(sp)
ffffffffc0202556:	e842                	sd	a6,16(sp)
ffffffffc0202558:	e43a                	sd	a4,8(sp)
ffffffffc020255a:	f82a                	sd	a0,48(sp)
ffffffffc020255c:	ba8fe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202560:	00099797          	auipc	a5,0x99
ffffffffc0202564:	3b07b783          	ld	a5,944(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0202568:	7542                	ld	a0,48(sp)
ffffffffc020256a:	4585                	li	a1,1
ffffffffc020256c:	739c                	ld	a5,32(a5)
ffffffffc020256e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202570:	b8efe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202574:	6722                	ld	a4,8(sp)
ffffffffc0202576:	6626                	ld	a2,72(sp)
ffffffffc0202578:	6306                	ld	t1,64(sp)
ffffffffc020257a:	78e2                	ld	a7,56(sp)
ffffffffc020257c:	7f22                	ld	t5,40(sp)
ffffffffc020257e:	7e02                	ld	t3,32(sp)
ffffffffc0202580:	6ee2                	ld	t4,24(sp)
ffffffffc0202582:	6842                	ld	a6,16(sp)
ffffffffc0202584:	00099f97          	auipc	t6,0x99
ffffffffc0202588:	3a4f8f93          	addi	t6,t6,932 # ffffffffc029b928 <va_pa_offset>
ffffffffc020258c:	000803b7          	lui	t2,0x80
ffffffffc0202590:	fff802b7          	lui	t0,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202594:	00073023          	sd	zero,0(a4)
ffffffffc0202598:	bd7d                	j	ffffffffc0202456 <exit_range+0xd6>
        intr_disable();
ffffffffc020259a:	e832                	sd	a2,16(sp)
ffffffffc020259c:	e42a                	sd	a0,8(sp)
ffffffffc020259e:	b66fe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025a2:	00099797          	auipc	a5,0x99
ffffffffc02025a6:	36e7b783          	ld	a5,878(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc02025aa:	6522                	ld	a0,8(sp)
ffffffffc02025ac:	4585                	li	a1,1
ffffffffc02025ae:	739c                	ld	a5,32(a5)
ffffffffc02025b0:	9782                	jalr	a5
        intr_enable();
ffffffffc02025b2:	b4cfe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02025b6:	6642                	ld	a2,16(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc02025b8:	00043023          	sd	zero,0(s0)
ffffffffc02025bc:	b5cd                	j	ffffffffc020249e <exit_range+0x11e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02025be:	00004697          	auipc	a3,0x4
ffffffffc02025c2:	24268693          	addi	a3,a3,578 # ffffffffc0206800 <etext+0xede>
ffffffffc02025c6:	00004617          	auipc	a2,0x4
ffffffffc02025ca:	d8a60613          	addi	a2,a2,-630 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02025ce:	13500593          	li	a1,309
ffffffffc02025d2:	00004517          	auipc	a0,0x4
ffffffffc02025d6:	21e50513          	addi	a0,a0,542 # ffffffffc02067f0 <etext+0xece>
ffffffffc02025da:	e6dfd0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02025de:	00004617          	auipc	a2,0x4
ffffffffc02025e2:	12260613          	addi	a2,a2,290 # ffffffffc0206700 <etext+0xdde>
ffffffffc02025e6:	07100593          	li	a1,113
ffffffffc02025ea:	00004517          	auipc	a0,0x4
ffffffffc02025ee:	13e50513          	addi	a0,a0,318 # ffffffffc0206728 <etext+0xe06>
ffffffffc02025f2:	e55fd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc02025f6:	86f2                	mv	a3,t3
ffffffffc02025f8:	00004617          	auipc	a2,0x4
ffffffffc02025fc:	10860613          	addi	a2,a2,264 # ffffffffc0206700 <etext+0xdde>
ffffffffc0202600:	07100593          	li	a1,113
ffffffffc0202604:	00004517          	auipc	a0,0x4
ffffffffc0202608:	12450513          	addi	a0,a0,292 # ffffffffc0206728 <etext+0xe06>
ffffffffc020260c:	e3bfd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0202610:	8c7ff0ef          	jal	ffffffffc0201ed6 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202614:	00004697          	auipc	a3,0x4
ffffffffc0202618:	21c68693          	addi	a3,a3,540 # ffffffffc0206830 <etext+0xf0e>
ffffffffc020261c:	00004617          	auipc	a2,0x4
ffffffffc0202620:	d3460613          	addi	a2,a2,-716 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0202624:	13600593          	li	a1,310
ffffffffc0202628:	00004517          	auipc	a0,0x4
ffffffffc020262c:	1c850513          	addi	a0,a0,456 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202630:	e17fd0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0202634 <page_remove>:
{
ffffffffc0202634:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202636:	4601                	li	a2,0
{
ffffffffc0202638:	e822                	sd	s0,16(sp)
ffffffffc020263a:	ec06                	sd	ra,24(sp)
ffffffffc020263c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020263e:	95dff0ef          	jal	ffffffffc0201f9a <get_pte>
    if (ptep != NULL)
ffffffffc0202642:	c511                	beqz	a0,ffffffffc020264e <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc0202644:	6118                	ld	a4,0(a0)
ffffffffc0202646:	87aa                	mv	a5,a0
ffffffffc0202648:	00177693          	andi	a3,a4,1
ffffffffc020264c:	e689                	bnez	a3,ffffffffc0202656 <page_remove+0x22>
}
ffffffffc020264e:	60e2                	ld	ra,24(sp)
ffffffffc0202650:	6442                	ld	s0,16(sp)
ffffffffc0202652:	6105                	addi	sp,sp,32
ffffffffc0202654:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202656:	00099697          	auipc	a3,0x99
ffffffffc020265a:	2da6b683          	ld	a3,730(a3) # ffffffffc029b930 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc020265e:	070a                	slli	a4,a4,0x2
ffffffffc0202660:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202662:	06d77563          	bgeu	a4,a3,ffffffffc02026cc <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202666:	00099517          	auipc	a0,0x99
ffffffffc020266a:	2d253503          	ld	a0,722(a0) # ffffffffc029b938 <pages>
ffffffffc020266e:	071a                	slli	a4,a4,0x6
ffffffffc0202670:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202674:	9736                	add	a4,a4,a3
ffffffffc0202676:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202678:	4118                	lw	a4,0(a0)
ffffffffc020267a:	377d                	addiw	a4,a4,-1
ffffffffc020267c:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc020267e:	cb09                	beqz	a4,ffffffffc0202690 <page_remove+0x5c>
        *ptep = 0;
ffffffffc0202680:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202684:	12040073          	sfence.vma	s0
}
ffffffffc0202688:	60e2                	ld	ra,24(sp)
ffffffffc020268a:	6442                	ld	s0,16(sp)
ffffffffc020268c:	6105                	addi	sp,sp,32
ffffffffc020268e:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202690:	10002773          	csrr	a4,sstatus
ffffffffc0202694:	8b09                	andi	a4,a4,2
ffffffffc0202696:	eb19                	bnez	a4,ffffffffc02026ac <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc0202698:	00099717          	auipc	a4,0x99
ffffffffc020269c:	27873703          	ld	a4,632(a4) # ffffffffc029b910 <pmm_manager>
ffffffffc02026a0:	4585                	li	a1,1
ffffffffc02026a2:	e03e                	sd	a5,0(sp)
ffffffffc02026a4:	7318                	ld	a4,32(a4)
ffffffffc02026a6:	9702                	jalr	a4
    if (flag)
ffffffffc02026a8:	6782                	ld	a5,0(sp)
ffffffffc02026aa:	bfd9                	j	ffffffffc0202680 <page_remove+0x4c>
        intr_disable();
ffffffffc02026ac:	e43e                	sd	a5,8(sp)
ffffffffc02026ae:	e02a                	sd	a0,0(sp)
ffffffffc02026b0:	a54fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc02026b4:	00099717          	auipc	a4,0x99
ffffffffc02026b8:	25c73703          	ld	a4,604(a4) # ffffffffc029b910 <pmm_manager>
ffffffffc02026bc:	6502                	ld	a0,0(sp)
ffffffffc02026be:	4585                	li	a1,1
ffffffffc02026c0:	7318                	ld	a4,32(a4)
ffffffffc02026c2:	9702                	jalr	a4
        intr_enable();
ffffffffc02026c4:	a3afe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02026c8:	67a2                	ld	a5,8(sp)
ffffffffc02026ca:	bf5d                	j	ffffffffc0202680 <page_remove+0x4c>
ffffffffc02026cc:	80bff0ef          	jal	ffffffffc0201ed6 <pa2page.part.0>

ffffffffc02026d0 <page_insert>:
{
ffffffffc02026d0:	7139                	addi	sp,sp,-64
ffffffffc02026d2:	f426                	sd	s1,40(sp)
ffffffffc02026d4:	84b2                	mv	s1,a2
ffffffffc02026d6:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026d8:	4605                	li	a2,1
{
ffffffffc02026da:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026dc:	85a6                	mv	a1,s1
{
ffffffffc02026de:	fc06                	sd	ra,56(sp)
ffffffffc02026e0:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026e2:	8b9ff0ef          	jal	ffffffffc0201f9a <get_pte>
    if (ptep == NULL)
ffffffffc02026e6:	cd61                	beqz	a0,ffffffffc02027be <page_insert+0xee>
    page->ref += 1;
ffffffffc02026e8:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc02026ea:	611c                	ld	a5,0(a0)
ffffffffc02026ec:	66a2                	ld	a3,8(sp)
ffffffffc02026ee:	0015861b          	addiw	a2,a1,1 # 1001 <_binary_obj___user_softint_out_size-0x7bef>
ffffffffc02026f2:	c010                	sw	a2,0(s0)
ffffffffc02026f4:	0017f613          	andi	a2,a5,1
ffffffffc02026f8:	872a                	mv	a4,a0
ffffffffc02026fa:	e61d                	bnez	a2,ffffffffc0202728 <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc02026fc:	00099617          	auipc	a2,0x99
ffffffffc0202700:	23c63603          	ld	a2,572(a2) # ffffffffc029b938 <pages>
    return page - pages + nbase;
ffffffffc0202704:	8c11                	sub	s0,s0,a2
ffffffffc0202706:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202708:	200007b7          	lui	a5,0x20000
ffffffffc020270c:	042a                	slli	s0,s0,0xa
ffffffffc020270e:	943e                	add	s0,s0,a5
ffffffffc0202710:	8ec1                	or	a3,a3,s0
ffffffffc0202712:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202716:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202718:	12048073          	sfence.vma	s1
    return 0;
ffffffffc020271c:	4501                	li	a0,0
}
ffffffffc020271e:	70e2                	ld	ra,56(sp)
ffffffffc0202720:	7442                	ld	s0,48(sp)
ffffffffc0202722:	74a2                	ld	s1,40(sp)
ffffffffc0202724:	6121                	addi	sp,sp,64
ffffffffc0202726:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202728:	00099617          	auipc	a2,0x99
ffffffffc020272c:	20863603          	ld	a2,520(a2) # ffffffffc029b930 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202730:	078a                	slli	a5,a5,0x2
ffffffffc0202732:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202734:	08c7f763          	bgeu	a5,a2,ffffffffc02027c2 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202738:	00099617          	auipc	a2,0x99
ffffffffc020273c:	20063603          	ld	a2,512(a2) # ffffffffc029b938 <pages>
ffffffffc0202740:	fe000537          	lui	a0,0xfe000
ffffffffc0202744:	079a                	slli	a5,a5,0x6
ffffffffc0202746:	97aa                	add	a5,a5,a0
ffffffffc0202748:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc020274c:	00a40963          	beq	s0,a0,ffffffffc020275e <page_insert+0x8e>
    page->ref -= 1;
ffffffffc0202750:	411c                	lw	a5,0(a0)
ffffffffc0202752:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_obj___user_exit_out_size+0x1fff5e17>
ffffffffc0202754:	c11c                	sw	a5,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202756:	c791                	beqz	a5,ffffffffc0202762 <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202758:	12048073          	sfence.vma	s1
}
ffffffffc020275c:	b765                	j	ffffffffc0202704 <page_insert+0x34>
ffffffffc020275e:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc0202760:	b755                	j	ffffffffc0202704 <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202762:	100027f3          	csrr	a5,sstatus
ffffffffc0202766:	8b89                	andi	a5,a5,2
ffffffffc0202768:	e39d                	bnez	a5,ffffffffc020278e <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc020276a:	00099797          	auipc	a5,0x99
ffffffffc020276e:	1a67b783          	ld	a5,422(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc0202772:	4585                	li	a1,1
ffffffffc0202774:	e83a                	sd	a4,16(sp)
ffffffffc0202776:	739c                	ld	a5,32(a5)
ffffffffc0202778:	e436                	sd	a3,8(sp)
ffffffffc020277a:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020277c:	00099617          	auipc	a2,0x99
ffffffffc0202780:	1bc63603          	ld	a2,444(a2) # ffffffffc029b938 <pages>
ffffffffc0202784:	66a2                	ld	a3,8(sp)
ffffffffc0202786:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202788:	12048073          	sfence.vma	s1
ffffffffc020278c:	bfa5                	j	ffffffffc0202704 <page_insert+0x34>
        intr_disable();
ffffffffc020278e:	ec3a                	sd	a4,24(sp)
ffffffffc0202790:	e836                	sd	a3,16(sp)
ffffffffc0202792:	e42a                	sd	a0,8(sp)
ffffffffc0202794:	970fe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202798:	00099797          	auipc	a5,0x99
ffffffffc020279c:	1787b783          	ld	a5,376(a5) # ffffffffc029b910 <pmm_manager>
ffffffffc02027a0:	6522                	ld	a0,8(sp)
ffffffffc02027a2:	4585                	li	a1,1
ffffffffc02027a4:	739c                	ld	a5,32(a5)
ffffffffc02027a6:	9782                	jalr	a5
        intr_enable();
ffffffffc02027a8:	956fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02027ac:	00099617          	auipc	a2,0x99
ffffffffc02027b0:	18c63603          	ld	a2,396(a2) # ffffffffc029b938 <pages>
ffffffffc02027b4:	6762                	ld	a4,24(sp)
ffffffffc02027b6:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027b8:	12048073          	sfence.vma	s1
ffffffffc02027bc:	b7a1                	j	ffffffffc0202704 <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc02027be:	5571                	li	a0,-4
ffffffffc02027c0:	bfb9                	j	ffffffffc020271e <page_insert+0x4e>
ffffffffc02027c2:	f14ff0ef          	jal	ffffffffc0201ed6 <pa2page.part.0>

ffffffffc02027c6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02027c6:	00005797          	auipc	a5,0x5
ffffffffc02027ca:	f9278793          	addi	a5,a5,-110 # ffffffffc0207758 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027ce:	638c                	ld	a1,0(a5)
{
ffffffffc02027d0:	7159                	addi	sp,sp,-112
ffffffffc02027d2:	f486                	sd	ra,104(sp)
ffffffffc02027d4:	e8ca                	sd	s2,80(sp)
ffffffffc02027d6:	e4ce                	sd	s3,72(sp)
ffffffffc02027d8:	f85a                	sd	s6,48(sp)
ffffffffc02027da:	f0a2                	sd	s0,96(sp)
ffffffffc02027dc:	eca6                	sd	s1,88(sp)
ffffffffc02027de:	e0d2                	sd	s4,64(sp)
ffffffffc02027e0:	fc56                	sd	s5,56(sp)
ffffffffc02027e2:	f45e                	sd	s7,40(sp)
ffffffffc02027e4:	f062                	sd	s8,32(sp)
ffffffffc02027e6:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02027e8:	00099b17          	auipc	s6,0x99
ffffffffc02027ec:	128b0b13          	addi	s6,s6,296 # ffffffffc029b910 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027f0:	00004517          	auipc	a0,0x4
ffffffffc02027f4:	05850513          	addi	a0,a0,88 # ffffffffc0206848 <etext+0xf26>
    pmm_manager = &default_pmm_manager;
ffffffffc02027f8:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027fc:	999fd0ef          	jal	ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc0202800:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202804:	00099997          	auipc	s3,0x99
ffffffffc0202808:	12498993          	addi	s3,s3,292 # ffffffffc029b928 <va_pa_offset>
    pmm_manager->init();
ffffffffc020280c:	679c                	ld	a5,8(a5)
ffffffffc020280e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202810:	57f5                	li	a5,-3
ffffffffc0202812:	07fa                	slli	a5,a5,0x1e
ffffffffc0202814:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202818:	8d2fe0ef          	jal	ffffffffc02008ea <get_memory_base>
ffffffffc020281c:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc020281e:	8d6fe0ef          	jal	ffffffffc02008f4 <get_memory_size>
    if (mem_size == 0)
ffffffffc0202822:	70050e63          	beqz	a0,ffffffffc0202f3e <pmm_init+0x778>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202826:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202828:	00004517          	auipc	a0,0x4
ffffffffc020282c:	05850513          	addi	a0,a0,88 # ffffffffc0206880 <etext+0xf5e>
ffffffffc0202830:	965fd0ef          	jal	ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202834:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202838:	864a                	mv	a2,s2
ffffffffc020283a:	85a6                	mv	a1,s1
ffffffffc020283c:	fff40693          	addi	a3,s0,-1
ffffffffc0202840:	00004517          	auipc	a0,0x4
ffffffffc0202844:	05850513          	addi	a0,a0,88 # ffffffffc0206898 <etext+0xf76>
ffffffffc0202848:	94dfd0ef          	jal	ffffffffc0200194 <cprintf>
    if (maxpa > KERNTOP)
ffffffffc020284c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202850:	8522                	mv	a0,s0
ffffffffc0202852:	5287ed63          	bltu	a5,s0,ffffffffc0202d8c <pmm_init+0x5c6>
ffffffffc0202856:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202858:	0009a617          	auipc	a2,0x9a
ffffffffc020285c:	10760613          	addi	a2,a2,263 # ffffffffc029c95f <end+0xfff>
ffffffffc0202860:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc0202862:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202864:	00099b97          	auipc	s7,0x99
ffffffffc0202868:	0d4b8b93          	addi	s7,s7,212 # ffffffffc029b938 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020286c:	00099497          	auipc	s1,0x99
ffffffffc0202870:	0c448493          	addi	s1,s1,196 # ffffffffc029b930 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202874:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc0202878:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020287a:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020287e:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202880:	02f50763          	beq	a0,a5,ffffffffc02028ae <pmm_init+0xe8>
ffffffffc0202884:	4701                	li	a4,0
ffffffffc0202886:	4585                	li	a1,1
ffffffffc0202888:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc020288c:	00671793          	slli	a5,a4,0x6
ffffffffc0202890:	97b2                	add	a5,a5,a2
ffffffffc0202892:	07a1                	addi	a5,a5,8 # 80008 <_binary_obj___user_exit_out_size+0x75e20>
ffffffffc0202894:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202898:	6088                	ld	a0,0(s1)
ffffffffc020289a:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020289c:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028a0:	00d507b3          	add	a5,a0,a3
ffffffffc02028a4:	fef764e3          	bltu	a4,a5,ffffffffc020288c <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028a8:	079a                	slli	a5,a5,0x6
ffffffffc02028aa:	00f606b3          	add	a3,a2,a5
ffffffffc02028ae:	c02007b7          	lui	a5,0xc0200
ffffffffc02028b2:	16f6eee3          	bltu	a3,a5,ffffffffc020322e <pmm_init+0xa68>
ffffffffc02028b6:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02028ba:	77fd                	lui	a5,0xfffff
ffffffffc02028bc:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028be:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc02028c0:	4e86ed63          	bltu	a3,s0,ffffffffc0202dba <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02028c4:	00004517          	auipc	a0,0x4
ffffffffc02028c8:	ffc50513          	addi	a0,a0,-4 # ffffffffc02068c0 <etext+0xf9e>
ffffffffc02028cc:	8c9fd0ef          	jal	ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc02028d0:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02028d4:	00099917          	auipc	s2,0x99
ffffffffc02028d8:	04c90913          	addi	s2,s2,76 # ffffffffc029b920 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02028dc:	7b9c                	ld	a5,48(a5)
ffffffffc02028de:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02028e0:	00004517          	auipc	a0,0x4
ffffffffc02028e4:	ff850513          	addi	a0,a0,-8 # ffffffffc02068d8 <etext+0xfb6>
ffffffffc02028e8:	8adfd0ef          	jal	ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02028ec:	00007697          	auipc	a3,0x7
ffffffffc02028f0:	71468693          	addi	a3,a3,1812 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc02028f4:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02028f8:	c02007b7          	lui	a5,0xc0200
ffffffffc02028fc:	2af6eee3          	bltu	a3,a5,ffffffffc02033b8 <pmm_init+0xbf2>
ffffffffc0202900:	0009b783          	ld	a5,0(s3)
ffffffffc0202904:	8e9d                	sub	a3,a3,a5
ffffffffc0202906:	00099797          	auipc	a5,0x99
ffffffffc020290a:	00d7b923          	sd	a3,18(a5) # ffffffffc029b918 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020290e:	100027f3          	csrr	a5,sstatus
ffffffffc0202912:	8b89                	andi	a5,a5,2
ffffffffc0202914:	48079963          	bnez	a5,ffffffffc0202da6 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202918:	000b3783          	ld	a5,0(s6)
ffffffffc020291c:	779c                	ld	a5,40(a5)
ffffffffc020291e:	9782                	jalr	a5
ffffffffc0202920:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202922:	6098                	ld	a4,0(s1)
ffffffffc0202924:	c80007b7          	lui	a5,0xc8000
ffffffffc0202928:	83b1                	srli	a5,a5,0xc
ffffffffc020292a:	66e7e663          	bltu	a5,a4,ffffffffc0202f96 <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020292e:	00093503          	ld	a0,0(s2)
ffffffffc0202932:	64050263          	beqz	a0,ffffffffc0202f76 <pmm_init+0x7b0>
ffffffffc0202936:	03451793          	slli	a5,a0,0x34
ffffffffc020293a:	62079e63          	bnez	a5,ffffffffc0202f76 <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020293e:	4601                	li	a2,0
ffffffffc0202940:	4581                	li	a1,0
ffffffffc0202942:	8b7ff0ef          	jal	ffffffffc02021f8 <get_page>
ffffffffc0202946:	240519e3          	bnez	a0,ffffffffc0203398 <pmm_init+0xbd2>
ffffffffc020294a:	100027f3          	csrr	a5,sstatus
ffffffffc020294e:	8b89                	andi	a5,a5,2
ffffffffc0202950:	44079063          	bnez	a5,ffffffffc0202d90 <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202954:	000b3783          	ld	a5,0(s6)
ffffffffc0202958:	4505                	li	a0,1
ffffffffc020295a:	6f9c                	ld	a5,24(a5)
ffffffffc020295c:	9782                	jalr	a5
ffffffffc020295e:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202960:	00093503          	ld	a0,0(s2)
ffffffffc0202964:	4681                	li	a3,0
ffffffffc0202966:	4601                	li	a2,0
ffffffffc0202968:	85d2                	mv	a1,s4
ffffffffc020296a:	d67ff0ef          	jal	ffffffffc02026d0 <page_insert>
ffffffffc020296e:	280511e3          	bnez	a0,ffffffffc02033f0 <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202972:	00093503          	ld	a0,0(s2)
ffffffffc0202976:	4601                	li	a2,0
ffffffffc0202978:	4581                	li	a1,0
ffffffffc020297a:	e20ff0ef          	jal	ffffffffc0201f9a <get_pte>
ffffffffc020297e:	240509e3          	beqz	a0,ffffffffc02033d0 <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc0202982:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202984:	0017f713          	andi	a4,a5,1
ffffffffc0202988:	58070f63          	beqz	a4,ffffffffc0202f26 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc020298c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020298e:	078a                	slli	a5,a5,0x2
ffffffffc0202990:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202992:	58e7f863          	bgeu	a5,a4,ffffffffc0202f22 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202996:	000bb683          	ld	a3,0(s7)
ffffffffc020299a:	079a                	slli	a5,a5,0x6
ffffffffc020299c:	fe000637          	lui	a2,0xfe000
ffffffffc02029a0:	97b2                	add	a5,a5,a2
ffffffffc02029a2:	97b6                	add	a5,a5,a3
ffffffffc02029a4:	14fa1ae3          	bne	s4,a5,ffffffffc02032f8 <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc02029a8:	000a2683          	lw	a3,0(s4) # 200000 <_binary_obj___user_exit_out_size+0x1f5e18>
ffffffffc02029ac:	4785                	li	a5,1
ffffffffc02029ae:	12f695e3          	bne	a3,a5,ffffffffc02032d8 <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02029b2:	00093503          	ld	a0,0(s2)
ffffffffc02029b6:	77fd                	lui	a5,0xfffff
ffffffffc02029b8:	6114                	ld	a3,0(a0)
ffffffffc02029ba:	068a                	slli	a3,a3,0x2
ffffffffc02029bc:	8efd                	and	a3,a3,a5
ffffffffc02029be:	00c6d613          	srli	a2,a3,0xc
ffffffffc02029c2:	0ee67fe3          	bgeu	a2,a4,ffffffffc02032c0 <pmm_init+0xafa>
ffffffffc02029c6:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029ca:	96e2                	add	a3,a3,s8
ffffffffc02029cc:	0006ba83          	ld	s5,0(a3)
ffffffffc02029d0:	0a8a                	slli	s5,s5,0x2
ffffffffc02029d2:	00fafab3          	and	s5,s5,a5
ffffffffc02029d6:	00cad793          	srli	a5,s5,0xc
ffffffffc02029da:	0ce7f6e3          	bgeu	a5,a4,ffffffffc02032a6 <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029de:	4601                	li	a2,0
ffffffffc02029e0:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029e2:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029e4:	db6ff0ef          	jal	ffffffffc0201f9a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029e8:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029ea:	05851ee3          	bne	a0,s8,ffffffffc0203246 <pmm_init+0xa80>
ffffffffc02029ee:	100027f3          	csrr	a5,sstatus
ffffffffc02029f2:	8b89                	andi	a5,a5,2
ffffffffc02029f4:	3e079b63          	bnez	a5,ffffffffc0202dea <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc02029f8:	000b3783          	ld	a5,0(s6)
ffffffffc02029fc:	4505                	li	a0,1
ffffffffc02029fe:	6f9c                	ld	a5,24(a5)
ffffffffc0202a00:	9782                	jalr	a5
ffffffffc0202a02:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202a04:	00093503          	ld	a0,0(s2)
ffffffffc0202a08:	46d1                	li	a3,20
ffffffffc0202a0a:	6605                	lui	a2,0x1
ffffffffc0202a0c:	85e2                	mv	a1,s8
ffffffffc0202a0e:	cc3ff0ef          	jal	ffffffffc02026d0 <page_insert>
ffffffffc0202a12:	06051ae3          	bnez	a0,ffffffffc0203286 <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a16:	00093503          	ld	a0,0(s2)
ffffffffc0202a1a:	4601                	li	a2,0
ffffffffc0202a1c:	6585                	lui	a1,0x1
ffffffffc0202a1e:	d7cff0ef          	jal	ffffffffc0201f9a <get_pte>
ffffffffc0202a22:	040502e3          	beqz	a0,ffffffffc0203266 <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc0202a26:	611c                	ld	a5,0(a0)
ffffffffc0202a28:	0107f713          	andi	a4,a5,16
ffffffffc0202a2c:	7e070163          	beqz	a4,ffffffffc020320e <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc0202a30:	8b91                	andi	a5,a5,4
ffffffffc0202a32:	7a078e63          	beqz	a5,ffffffffc02031ee <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202a36:	00093503          	ld	a0,0(s2)
ffffffffc0202a3a:	611c                	ld	a5,0(a0)
ffffffffc0202a3c:	8bc1                	andi	a5,a5,16
ffffffffc0202a3e:	78078863          	beqz	a5,ffffffffc02031ce <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc0202a42:	000c2703          	lw	a4,0(s8)
ffffffffc0202a46:	4785                	li	a5,1
ffffffffc0202a48:	76f71363          	bne	a4,a5,ffffffffc02031ae <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202a4c:	4681                	li	a3,0
ffffffffc0202a4e:	6605                	lui	a2,0x1
ffffffffc0202a50:	85d2                	mv	a1,s4
ffffffffc0202a52:	c7fff0ef          	jal	ffffffffc02026d0 <page_insert>
ffffffffc0202a56:	72051c63          	bnez	a0,ffffffffc020318e <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc0202a5a:	000a2703          	lw	a4,0(s4)
ffffffffc0202a5e:	4789                	li	a5,2
ffffffffc0202a60:	70f71763          	bne	a4,a5,ffffffffc020316e <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc0202a64:	000c2783          	lw	a5,0(s8)
ffffffffc0202a68:	6e079363          	bnez	a5,ffffffffc020314e <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a6c:	00093503          	ld	a0,0(s2)
ffffffffc0202a70:	4601                	li	a2,0
ffffffffc0202a72:	6585                	lui	a1,0x1
ffffffffc0202a74:	d26ff0ef          	jal	ffffffffc0201f9a <get_pte>
ffffffffc0202a78:	6a050b63          	beqz	a0,ffffffffc020312e <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a7c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202a7e:	00177793          	andi	a5,a4,1
ffffffffc0202a82:	4a078263          	beqz	a5,ffffffffc0202f26 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202a86:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a88:	00271793          	slli	a5,a4,0x2
ffffffffc0202a8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a8e:	48d7fa63          	bgeu	a5,a3,ffffffffc0202f22 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a92:	000bb683          	ld	a3,0(s7)
ffffffffc0202a96:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202a9a:	97d6                	add	a5,a5,s5
ffffffffc0202a9c:	079a                	slli	a5,a5,0x6
ffffffffc0202a9e:	97b6                	add	a5,a5,a3
ffffffffc0202aa0:	66fa1763          	bne	s4,a5,ffffffffc020310e <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202aa4:	8b41                	andi	a4,a4,16
ffffffffc0202aa6:	64071463          	bnez	a4,ffffffffc02030ee <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202aaa:	00093503          	ld	a0,0(s2)
ffffffffc0202aae:	4581                	li	a1,0
ffffffffc0202ab0:	b85ff0ef          	jal	ffffffffc0202634 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202ab4:	000a2c83          	lw	s9,0(s4)
ffffffffc0202ab8:	4785                	li	a5,1
ffffffffc0202aba:	60fc9a63          	bne	s9,a5,ffffffffc02030ce <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0202abe:	000c2783          	lw	a5,0(s8)
ffffffffc0202ac2:	5e079663          	bnez	a5,ffffffffc02030ae <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202ac6:	00093503          	ld	a0,0(s2)
ffffffffc0202aca:	6585                	lui	a1,0x1
ffffffffc0202acc:	b69ff0ef          	jal	ffffffffc0202634 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202ad0:	000a2783          	lw	a5,0(s4)
ffffffffc0202ad4:	52079d63          	bnez	a5,ffffffffc020300e <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc0202ad8:	000c2783          	lw	a5,0(s8)
ffffffffc0202adc:	50079963          	bnez	a5,ffffffffc0202fee <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202ae0:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202ae4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ae6:	000a3783          	ld	a5,0(s4)
ffffffffc0202aea:	078a                	slli	a5,a5,0x2
ffffffffc0202aec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202aee:	42e7fa63          	bgeu	a5,a4,ffffffffc0202f22 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202af2:	000bb503          	ld	a0,0(s7)
ffffffffc0202af6:	97d6                	add	a5,a5,s5
ffffffffc0202af8:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202afa:	00f506b3          	add	a3,a0,a5
ffffffffc0202afe:	4294                	lw	a3,0(a3)
ffffffffc0202b00:	4d969763          	bne	a3,s9,ffffffffc0202fce <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc0202b04:	8799                	srai	a5,a5,0x6
ffffffffc0202b06:	00080637          	lui	a2,0x80
ffffffffc0202b0a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b0c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202b10:	4ae7f363          	bgeu	a5,a4,ffffffffc0202fb6 <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202b14:	0009b783          	ld	a5,0(s3)
ffffffffc0202b18:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b1a:	639c                	ld	a5,0(a5)
ffffffffc0202b1c:	078a                	slli	a5,a5,0x2
ffffffffc0202b1e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b20:	40e7f163          	bgeu	a5,a4,ffffffffc0202f22 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b24:	8f91                	sub	a5,a5,a2
ffffffffc0202b26:	079a                	slli	a5,a5,0x6
ffffffffc0202b28:	953e                	add	a0,a0,a5
ffffffffc0202b2a:	100027f3          	csrr	a5,sstatus
ffffffffc0202b2e:	8b89                	andi	a5,a5,2
ffffffffc0202b30:	30079863          	bnez	a5,ffffffffc0202e40 <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc0202b34:	000b3783          	ld	a5,0(s6)
ffffffffc0202b38:	4585                	li	a1,1
ffffffffc0202b3a:	739c                	ld	a5,32(a5)
ffffffffc0202b3c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b3e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202b42:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b44:	078a                	slli	a5,a5,0x2
ffffffffc0202b46:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b48:	3ce7fd63          	bgeu	a5,a4,ffffffffc0202f22 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b4c:	000bb503          	ld	a0,0(s7)
ffffffffc0202b50:	fe000737          	lui	a4,0xfe000
ffffffffc0202b54:	079a                	slli	a5,a5,0x6
ffffffffc0202b56:	97ba                	add	a5,a5,a4
ffffffffc0202b58:	953e                	add	a0,a0,a5
ffffffffc0202b5a:	100027f3          	csrr	a5,sstatus
ffffffffc0202b5e:	8b89                	andi	a5,a5,2
ffffffffc0202b60:	2c079463          	bnez	a5,ffffffffc0202e28 <pmm_init+0x662>
ffffffffc0202b64:	000b3783          	ld	a5,0(s6)
ffffffffc0202b68:	4585                	li	a1,1
ffffffffc0202b6a:	739c                	ld	a5,32(a5)
ffffffffc0202b6c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202b6e:	00093783          	ld	a5,0(s2)
ffffffffc0202b72:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd636a0>
    asm volatile("sfence.vma");
ffffffffc0202b76:	12000073          	sfence.vma
ffffffffc0202b7a:	100027f3          	csrr	a5,sstatus
ffffffffc0202b7e:	8b89                	andi	a5,a5,2
ffffffffc0202b80:	28079a63          	bnez	a5,ffffffffc0202e14 <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b84:	000b3783          	ld	a5,0(s6)
ffffffffc0202b88:	779c                	ld	a5,40(a5)
ffffffffc0202b8a:	9782                	jalr	a5
ffffffffc0202b8c:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202b8e:	4d441063          	bne	s0,s4,ffffffffc020304e <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202b92:	00004517          	auipc	a0,0x4
ffffffffc0202b96:	09650513          	addi	a0,a0,150 # ffffffffc0206c28 <etext+0x1306>
ffffffffc0202b9a:	dfafd0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0202b9e:	100027f3          	csrr	a5,sstatus
ffffffffc0202ba2:	8b89                	andi	a5,a5,2
ffffffffc0202ba4:	24079e63          	bnez	a5,ffffffffc0202e00 <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ba8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bac:	779c                	ld	a5,40(a5)
ffffffffc0202bae:	9782                	jalr	a5
ffffffffc0202bb0:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bb2:	609c                	ld	a5,0(s1)
ffffffffc0202bb4:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bb8:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bba:	00c79713          	slli	a4,a5,0xc
ffffffffc0202bbe:	6a85                	lui	s5,0x1
ffffffffc0202bc0:	02e47c63          	bgeu	s0,a4,ffffffffc0202bf8 <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202bc4:	00c45713          	srli	a4,s0,0xc
ffffffffc0202bc8:	30f77063          	bgeu	a4,a5,ffffffffc0202ec8 <pmm_init+0x702>
ffffffffc0202bcc:	0009b583          	ld	a1,0(s3)
ffffffffc0202bd0:	00093503          	ld	a0,0(s2)
ffffffffc0202bd4:	4601                	li	a2,0
ffffffffc0202bd6:	95a2                	add	a1,a1,s0
ffffffffc0202bd8:	bc2ff0ef          	jal	ffffffffc0201f9a <get_pte>
ffffffffc0202bdc:	32050363          	beqz	a0,ffffffffc0202f02 <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202be0:	611c                	ld	a5,0(a0)
ffffffffc0202be2:	078a                	slli	a5,a5,0x2
ffffffffc0202be4:	0147f7b3          	and	a5,a5,s4
ffffffffc0202be8:	2e879d63          	bne	a5,s0,ffffffffc0202ee2 <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bec:	609c                	ld	a5,0(s1)
ffffffffc0202bee:	9456                	add	s0,s0,s5
ffffffffc0202bf0:	00c79713          	slli	a4,a5,0xc
ffffffffc0202bf4:	fce468e3          	bltu	s0,a4,ffffffffc0202bc4 <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202bf8:	00093783          	ld	a5,0(s2)
ffffffffc0202bfc:	639c                	ld	a5,0(a5)
ffffffffc0202bfe:	42079863          	bnez	a5,ffffffffc020302e <pmm_init+0x868>
ffffffffc0202c02:	100027f3          	csrr	a5,sstatus
ffffffffc0202c06:	8b89                	andi	a5,a5,2
ffffffffc0202c08:	24079863          	bnez	a5,ffffffffc0202e58 <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c0c:	000b3783          	ld	a5,0(s6)
ffffffffc0202c10:	4505                	li	a0,1
ffffffffc0202c12:	6f9c                	ld	a5,24(a5)
ffffffffc0202c14:	9782                	jalr	a5
ffffffffc0202c16:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c18:	00093503          	ld	a0,0(s2)
ffffffffc0202c1c:	4699                	li	a3,6
ffffffffc0202c1e:	10000613          	li	a2,256
ffffffffc0202c22:	85a2                	mv	a1,s0
ffffffffc0202c24:	aadff0ef          	jal	ffffffffc02026d0 <page_insert>
ffffffffc0202c28:	46051363          	bnez	a0,ffffffffc020308e <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc0202c2c:	4018                	lw	a4,0(s0)
ffffffffc0202c2e:	4785                	li	a5,1
ffffffffc0202c30:	42f71f63          	bne	a4,a5,ffffffffc020306e <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202c34:	00093503          	ld	a0,0(s2)
ffffffffc0202c38:	6605                	lui	a2,0x1
ffffffffc0202c3a:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x7af0>
ffffffffc0202c3e:	4699                	li	a3,6
ffffffffc0202c40:	85a2                	mv	a1,s0
ffffffffc0202c42:	a8fff0ef          	jal	ffffffffc02026d0 <page_insert>
ffffffffc0202c46:	72051963          	bnez	a0,ffffffffc0203378 <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0202c4a:	4018                	lw	a4,0(s0)
ffffffffc0202c4c:	4789                	li	a5,2
ffffffffc0202c4e:	70f71563          	bne	a4,a5,ffffffffc0203358 <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202c52:	00004597          	auipc	a1,0x4
ffffffffc0202c56:	11e58593          	addi	a1,a1,286 # ffffffffc0206d70 <etext+0x144e>
ffffffffc0202c5a:	10000513          	li	a0,256
ffffffffc0202c5e:	41b020ef          	jal	ffffffffc0205878 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202c62:	6585                	lui	a1,0x1
ffffffffc0202c64:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x7af0>
ffffffffc0202c68:	10000513          	li	a0,256
ffffffffc0202c6c:	41f020ef          	jal	ffffffffc020588a <strcmp>
ffffffffc0202c70:	6c051463          	bnez	a0,ffffffffc0203338 <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0202c74:	000bb683          	ld	a3,0(s7)
ffffffffc0202c78:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202c7c:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202c7e:	40d406b3          	sub	a3,s0,a3
ffffffffc0202c82:	8699                	srai	a3,a3,0x6
ffffffffc0202c84:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202c86:	00c69793          	slli	a5,a3,0xc
ffffffffc0202c8a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c8c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202c8e:	32e7f463          	bgeu	a5,a4,ffffffffc0202fb6 <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c92:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202c96:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c9a:	97b6                	add	a5,a5,a3
ffffffffc0202c9c:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_exit_out_size+0x75f18>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ca0:	3a5020ef          	jal	ffffffffc0205844 <strlen>
ffffffffc0202ca4:	66051a63          	bnez	a0,ffffffffc0203318 <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202ca8:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202cac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cae:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd636a0>
ffffffffc0202cb2:	078a                	slli	a5,a5,0x2
ffffffffc0202cb4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cb6:	26e7f663          	bgeu	a5,a4,ffffffffc0202f22 <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cba:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202cbe:	2ee7fc63          	bgeu	a5,a4,ffffffffc0202fb6 <pmm_init+0x7f0>
ffffffffc0202cc2:	0009b783          	ld	a5,0(s3)
ffffffffc0202cc6:	00f689b3          	add	s3,a3,a5
ffffffffc0202cca:	100027f3          	csrr	a5,sstatus
ffffffffc0202cce:	8b89                	andi	a5,a5,2
ffffffffc0202cd0:	1e079163          	bnez	a5,ffffffffc0202eb2 <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc0202cd4:	000b3783          	ld	a5,0(s6)
ffffffffc0202cd8:	8522                	mv	a0,s0
ffffffffc0202cda:	4585                	li	a1,1
ffffffffc0202cdc:	739c                	ld	a5,32(a5)
ffffffffc0202cde:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ce0:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc0202ce4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ce6:	078a                	slli	a5,a5,0x2
ffffffffc0202ce8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cea:	22e7fc63          	bgeu	a5,a4,ffffffffc0202f22 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cee:	000bb503          	ld	a0,0(s7)
ffffffffc0202cf2:	fe000737          	lui	a4,0xfe000
ffffffffc0202cf6:	079a                	slli	a5,a5,0x6
ffffffffc0202cf8:	97ba                	add	a5,a5,a4
ffffffffc0202cfa:	953e                	add	a0,a0,a5
ffffffffc0202cfc:	100027f3          	csrr	a5,sstatus
ffffffffc0202d00:	8b89                	andi	a5,a5,2
ffffffffc0202d02:	18079c63          	bnez	a5,ffffffffc0202e9a <pmm_init+0x6d4>
ffffffffc0202d06:	000b3783          	ld	a5,0(s6)
ffffffffc0202d0a:	4585                	li	a1,1
ffffffffc0202d0c:	739c                	ld	a5,32(a5)
ffffffffc0202d0e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d10:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202d14:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d16:	078a                	slli	a5,a5,0x2
ffffffffc0202d18:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d1a:	20e7f463          	bgeu	a5,a4,ffffffffc0202f22 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d1e:	000bb503          	ld	a0,0(s7)
ffffffffc0202d22:	fe000737          	lui	a4,0xfe000
ffffffffc0202d26:	079a                	slli	a5,a5,0x6
ffffffffc0202d28:	97ba                	add	a5,a5,a4
ffffffffc0202d2a:	953e                	add	a0,a0,a5
ffffffffc0202d2c:	100027f3          	csrr	a5,sstatus
ffffffffc0202d30:	8b89                	andi	a5,a5,2
ffffffffc0202d32:	14079863          	bnez	a5,ffffffffc0202e82 <pmm_init+0x6bc>
ffffffffc0202d36:	000b3783          	ld	a5,0(s6)
ffffffffc0202d3a:	4585                	li	a1,1
ffffffffc0202d3c:	739c                	ld	a5,32(a5)
ffffffffc0202d3e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202d40:	00093783          	ld	a5,0(s2)
ffffffffc0202d44:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202d48:	12000073          	sfence.vma
ffffffffc0202d4c:	100027f3          	csrr	a5,sstatus
ffffffffc0202d50:	8b89                	andi	a5,a5,2
ffffffffc0202d52:	10079e63          	bnez	a5,ffffffffc0202e6e <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d56:	000b3783          	ld	a5,0(s6)
ffffffffc0202d5a:	779c                	ld	a5,40(a5)
ffffffffc0202d5c:	9782                	jalr	a5
ffffffffc0202d5e:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202d60:	1e8c1b63          	bne	s8,s0,ffffffffc0202f56 <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202d64:	00004517          	auipc	a0,0x4
ffffffffc0202d68:	08450513          	addi	a0,a0,132 # ffffffffc0206de8 <etext+0x14c6>
ffffffffc0202d6c:	c28fd0ef          	jal	ffffffffc0200194 <cprintf>
}
ffffffffc0202d70:	7406                	ld	s0,96(sp)
ffffffffc0202d72:	70a6                	ld	ra,104(sp)
ffffffffc0202d74:	64e6                	ld	s1,88(sp)
ffffffffc0202d76:	6946                	ld	s2,80(sp)
ffffffffc0202d78:	69a6                	ld	s3,72(sp)
ffffffffc0202d7a:	6a06                	ld	s4,64(sp)
ffffffffc0202d7c:	7ae2                	ld	s5,56(sp)
ffffffffc0202d7e:	7b42                	ld	s6,48(sp)
ffffffffc0202d80:	7ba2                	ld	s7,40(sp)
ffffffffc0202d82:	7c02                	ld	s8,32(sp)
ffffffffc0202d84:	6ce2                	ld	s9,24(sp)
ffffffffc0202d86:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202d88:	f85fe06f          	j	ffffffffc0201d0c <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0202d8c:	853e                	mv	a0,a5
ffffffffc0202d8e:	b4e1                	j	ffffffffc0202856 <pmm_init+0x90>
        intr_disable();
ffffffffc0202d90:	b75fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202d94:	000b3783          	ld	a5,0(s6)
ffffffffc0202d98:	4505                	li	a0,1
ffffffffc0202d9a:	6f9c                	ld	a5,24(a5)
ffffffffc0202d9c:	9782                	jalr	a5
ffffffffc0202d9e:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202da0:	b5ffd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202da4:	be75                	j	ffffffffc0202960 <pmm_init+0x19a>
        intr_disable();
ffffffffc0202da6:	b5ffd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202daa:	000b3783          	ld	a5,0(s6)
ffffffffc0202dae:	779c                	ld	a5,40(a5)
ffffffffc0202db0:	9782                	jalr	a5
ffffffffc0202db2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202db4:	b4bfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202db8:	b6ad                	j	ffffffffc0202922 <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202dba:	6705                	lui	a4,0x1
ffffffffc0202dbc:	177d                	addi	a4,a4,-1 # fff <_binary_obj___user_softint_out_size-0x7bf1>
ffffffffc0202dbe:	96ba                	add	a3,a3,a4
ffffffffc0202dc0:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202dc2:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202dc6:	14a77e63          	bgeu	a4,a0,ffffffffc0202f22 <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc0202dca:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202dce:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202dd0:	071a                	slli	a4,a4,0x6
ffffffffc0202dd2:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202dd6:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202dd8:	6a9c                	ld	a5,16(a3)
ffffffffc0202dda:	00c45593          	srli	a1,s0,0xc
ffffffffc0202dde:	00e60533          	add	a0,a2,a4
ffffffffc0202de2:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202de4:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202de8:	bcf1                	j	ffffffffc02028c4 <pmm_init+0xfe>
        intr_disable();
ffffffffc0202dea:	b1bfd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202dee:	000b3783          	ld	a5,0(s6)
ffffffffc0202df2:	4505                	li	a0,1
ffffffffc0202df4:	6f9c                	ld	a5,24(a5)
ffffffffc0202df6:	9782                	jalr	a5
ffffffffc0202df8:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202dfa:	b05fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202dfe:	b119                	j	ffffffffc0202a04 <pmm_init+0x23e>
        intr_disable();
ffffffffc0202e00:	b05fd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e04:	000b3783          	ld	a5,0(s6)
ffffffffc0202e08:	779c                	ld	a5,40(a5)
ffffffffc0202e0a:	9782                	jalr	a5
ffffffffc0202e0c:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e0e:	af1fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e12:	b345                	j	ffffffffc0202bb2 <pmm_init+0x3ec>
        intr_disable();
ffffffffc0202e14:	af1fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202e18:	000b3783          	ld	a5,0(s6)
ffffffffc0202e1c:	779c                	ld	a5,40(a5)
ffffffffc0202e1e:	9782                	jalr	a5
ffffffffc0202e20:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e22:	addfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e26:	b3a5                	j	ffffffffc0202b8e <pmm_init+0x3c8>
ffffffffc0202e28:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e2a:	adbfd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e2e:	000b3783          	ld	a5,0(s6)
ffffffffc0202e32:	6522                	ld	a0,8(sp)
ffffffffc0202e34:	4585                	li	a1,1
ffffffffc0202e36:	739c                	ld	a5,32(a5)
ffffffffc0202e38:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e3a:	ac5fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e3e:	bb05                	j	ffffffffc0202b6e <pmm_init+0x3a8>
ffffffffc0202e40:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e42:	ac3fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202e46:	000b3783          	ld	a5,0(s6)
ffffffffc0202e4a:	6522                	ld	a0,8(sp)
ffffffffc0202e4c:	4585                	li	a1,1
ffffffffc0202e4e:	739c                	ld	a5,32(a5)
ffffffffc0202e50:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e52:	aadfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e56:	b1e5                	j	ffffffffc0202b3e <pmm_init+0x378>
        intr_disable();
ffffffffc0202e58:	aadfd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e5c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e60:	4505                	li	a0,1
ffffffffc0202e62:	6f9c                	ld	a5,24(a5)
ffffffffc0202e64:	9782                	jalr	a5
ffffffffc0202e66:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e68:	a97fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e6c:	b375                	j	ffffffffc0202c18 <pmm_init+0x452>
        intr_disable();
ffffffffc0202e6e:	a97fd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e72:	000b3783          	ld	a5,0(s6)
ffffffffc0202e76:	779c                	ld	a5,40(a5)
ffffffffc0202e78:	9782                	jalr	a5
ffffffffc0202e7a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e7c:	a83fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e80:	b5c5                	j	ffffffffc0202d60 <pmm_init+0x59a>
ffffffffc0202e82:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e84:	a81fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e88:	000b3783          	ld	a5,0(s6)
ffffffffc0202e8c:	6522                	ld	a0,8(sp)
ffffffffc0202e8e:	4585                	li	a1,1
ffffffffc0202e90:	739c                	ld	a5,32(a5)
ffffffffc0202e92:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e94:	a6bfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e98:	b565                	j	ffffffffc0202d40 <pmm_init+0x57a>
ffffffffc0202e9a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e9c:	a69fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202ea0:	000b3783          	ld	a5,0(s6)
ffffffffc0202ea4:	6522                	ld	a0,8(sp)
ffffffffc0202ea6:	4585                	li	a1,1
ffffffffc0202ea8:	739c                	ld	a5,32(a5)
ffffffffc0202eaa:	9782                	jalr	a5
        intr_enable();
ffffffffc0202eac:	a53fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202eb0:	b585                	j	ffffffffc0202d10 <pmm_init+0x54a>
        intr_disable();
ffffffffc0202eb2:	a53fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202eb6:	000b3783          	ld	a5,0(s6)
ffffffffc0202eba:	8522                	mv	a0,s0
ffffffffc0202ebc:	4585                	li	a1,1
ffffffffc0202ebe:	739c                	ld	a5,32(a5)
ffffffffc0202ec0:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ec2:	a3dfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202ec6:	bd29                	j	ffffffffc0202ce0 <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202ec8:	86a2                	mv	a3,s0
ffffffffc0202eca:	00004617          	auipc	a2,0x4
ffffffffc0202ece:	83660613          	addi	a2,a2,-1994 # ffffffffc0206700 <etext+0xdde>
ffffffffc0202ed2:	26000593          	li	a1,608
ffffffffc0202ed6:	00004517          	auipc	a0,0x4
ffffffffc0202eda:	91a50513          	addi	a0,a0,-1766 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202ede:	d68fd0ef          	jal	ffffffffc0200446 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202ee2:	00004697          	auipc	a3,0x4
ffffffffc0202ee6:	da668693          	addi	a3,a3,-602 # ffffffffc0206c88 <etext+0x1366>
ffffffffc0202eea:	00003617          	auipc	a2,0x3
ffffffffc0202eee:	46660613          	addi	a2,a2,1126 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0202ef2:	26100593          	li	a1,609
ffffffffc0202ef6:	00004517          	auipc	a0,0x4
ffffffffc0202efa:	8fa50513          	addi	a0,a0,-1798 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202efe:	d48fd0ef          	jal	ffffffffc0200446 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f02:	00004697          	auipc	a3,0x4
ffffffffc0202f06:	d4668693          	addi	a3,a3,-698 # ffffffffc0206c48 <etext+0x1326>
ffffffffc0202f0a:	00003617          	auipc	a2,0x3
ffffffffc0202f0e:	44660613          	addi	a2,a2,1094 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0202f12:	26000593          	li	a1,608
ffffffffc0202f16:	00004517          	auipc	a0,0x4
ffffffffc0202f1a:	8da50513          	addi	a0,a0,-1830 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202f1e:	d28fd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0202f22:	fb5fe0ef          	jal	ffffffffc0201ed6 <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc0202f26:	00004617          	auipc	a2,0x4
ffffffffc0202f2a:	ac260613          	addi	a2,a2,-1342 # ffffffffc02069e8 <etext+0x10c6>
ffffffffc0202f2e:	07f00593          	li	a1,127
ffffffffc0202f32:	00003517          	auipc	a0,0x3
ffffffffc0202f36:	7f650513          	addi	a0,a0,2038 # ffffffffc0206728 <etext+0xe06>
ffffffffc0202f3a:	d0cfd0ef          	jal	ffffffffc0200446 <__panic>
        panic("DTB memory info not available");
ffffffffc0202f3e:	00004617          	auipc	a2,0x4
ffffffffc0202f42:	92260613          	addi	a2,a2,-1758 # ffffffffc0206860 <etext+0xf3e>
ffffffffc0202f46:	06500593          	li	a1,101
ffffffffc0202f4a:	00004517          	auipc	a0,0x4
ffffffffc0202f4e:	8a650513          	addi	a0,a0,-1882 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202f52:	cf4fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202f56:	00004697          	auipc	a3,0x4
ffffffffc0202f5a:	caa68693          	addi	a3,a3,-854 # ffffffffc0206c00 <etext+0x12de>
ffffffffc0202f5e:	00003617          	auipc	a2,0x3
ffffffffc0202f62:	3f260613          	addi	a2,a2,1010 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0202f66:	27b00593          	li	a1,635
ffffffffc0202f6a:	00004517          	auipc	a0,0x4
ffffffffc0202f6e:	88650513          	addi	a0,a0,-1914 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202f72:	cd4fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202f76:	00004697          	auipc	a3,0x4
ffffffffc0202f7a:	9a268693          	addi	a3,a3,-1630 # ffffffffc0206918 <etext+0xff6>
ffffffffc0202f7e:	00003617          	auipc	a2,0x3
ffffffffc0202f82:	3d260613          	addi	a2,a2,978 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0202f86:	22200593          	li	a1,546
ffffffffc0202f8a:	00004517          	auipc	a0,0x4
ffffffffc0202f8e:	86650513          	addi	a0,a0,-1946 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202f92:	cb4fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202f96:	00004697          	auipc	a3,0x4
ffffffffc0202f9a:	96268693          	addi	a3,a3,-1694 # ffffffffc02068f8 <etext+0xfd6>
ffffffffc0202f9e:	00003617          	auipc	a2,0x3
ffffffffc0202fa2:	3b260613          	addi	a2,a2,946 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0202fa6:	22100593          	li	a1,545
ffffffffc0202faa:	00004517          	auipc	a0,0x4
ffffffffc0202fae:	84650513          	addi	a0,a0,-1978 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202fb2:	c94fd0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202fb6:	00003617          	auipc	a2,0x3
ffffffffc0202fba:	74a60613          	addi	a2,a2,1866 # ffffffffc0206700 <etext+0xdde>
ffffffffc0202fbe:	07100593          	li	a1,113
ffffffffc0202fc2:	00003517          	auipc	a0,0x3
ffffffffc0202fc6:	76650513          	addi	a0,a0,1894 # ffffffffc0206728 <etext+0xe06>
ffffffffc0202fca:	c7cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202fce:	00004697          	auipc	a3,0x4
ffffffffc0202fd2:	c0268693          	addi	a3,a3,-1022 # ffffffffc0206bd0 <etext+0x12ae>
ffffffffc0202fd6:	00003617          	auipc	a2,0x3
ffffffffc0202fda:	37a60613          	addi	a2,a2,890 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0202fde:	24900593          	li	a1,585
ffffffffc0202fe2:	00004517          	auipc	a0,0x4
ffffffffc0202fe6:	80e50513          	addi	a0,a0,-2034 # ffffffffc02067f0 <etext+0xece>
ffffffffc0202fea:	c5cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fee:	00004697          	auipc	a3,0x4
ffffffffc0202ff2:	b9a68693          	addi	a3,a3,-1126 # ffffffffc0206b88 <etext+0x1266>
ffffffffc0202ff6:	00003617          	auipc	a2,0x3
ffffffffc0202ffa:	35a60613          	addi	a2,a2,858 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0202ffe:	24700593          	li	a1,583
ffffffffc0203002:	00003517          	auipc	a0,0x3
ffffffffc0203006:	7ee50513          	addi	a0,a0,2030 # ffffffffc02067f0 <etext+0xece>
ffffffffc020300a:	c3cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020300e:	00004697          	auipc	a3,0x4
ffffffffc0203012:	baa68693          	addi	a3,a3,-1110 # ffffffffc0206bb8 <etext+0x1296>
ffffffffc0203016:	00003617          	auipc	a2,0x3
ffffffffc020301a:	33a60613          	addi	a2,a2,826 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020301e:	24600593          	li	a1,582
ffffffffc0203022:	00003517          	auipc	a0,0x3
ffffffffc0203026:	7ce50513          	addi	a0,a0,1998 # ffffffffc02067f0 <etext+0xece>
ffffffffc020302a:	c1cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc020302e:	00004697          	auipc	a3,0x4
ffffffffc0203032:	c7268693          	addi	a3,a3,-910 # ffffffffc0206ca0 <etext+0x137e>
ffffffffc0203036:	00003617          	auipc	a2,0x3
ffffffffc020303a:	31a60613          	addi	a2,a2,794 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020303e:	26400593          	li	a1,612
ffffffffc0203042:	00003517          	auipc	a0,0x3
ffffffffc0203046:	7ae50513          	addi	a0,a0,1966 # ffffffffc02067f0 <etext+0xece>
ffffffffc020304a:	bfcfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020304e:	00004697          	auipc	a3,0x4
ffffffffc0203052:	bb268693          	addi	a3,a3,-1102 # ffffffffc0206c00 <etext+0x12de>
ffffffffc0203056:	00003617          	auipc	a2,0x3
ffffffffc020305a:	2fa60613          	addi	a2,a2,762 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020305e:	25100593          	li	a1,593
ffffffffc0203062:	00003517          	auipc	a0,0x3
ffffffffc0203066:	78e50513          	addi	a0,a0,1934 # ffffffffc02067f0 <etext+0xece>
ffffffffc020306a:	bdcfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020306e:	00004697          	auipc	a3,0x4
ffffffffc0203072:	c8a68693          	addi	a3,a3,-886 # ffffffffc0206cf8 <etext+0x13d6>
ffffffffc0203076:	00003617          	auipc	a2,0x3
ffffffffc020307a:	2da60613          	addi	a2,a2,730 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020307e:	26900593          	li	a1,617
ffffffffc0203082:	00003517          	auipc	a0,0x3
ffffffffc0203086:	76e50513          	addi	a0,a0,1902 # ffffffffc02067f0 <etext+0xece>
ffffffffc020308a:	bbcfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020308e:	00004697          	auipc	a3,0x4
ffffffffc0203092:	c2a68693          	addi	a3,a3,-982 # ffffffffc0206cb8 <etext+0x1396>
ffffffffc0203096:	00003617          	auipc	a2,0x3
ffffffffc020309a:	2ba60613          	addi	a2,a2,698 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020309e:	26800593          	li	a1,616
ffffffffc02030a2:	00003517          	auipc	a0,0x3
ffffffffc02030a6:	74e50513          	addi	a0,a0,1870 # ffffffffc02067f0 <etext+0xece>
ffffffffc02030aa:	b9cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030ae:	00004697          	auipc	a3,0x4
ffffffffc02030b2:	ada68693          	addi	a3,a3,-1318 # ffffffffc0206b88 <etext+0x1266>
ffffffffc02030b6:	00003617          	auipc	a2,0x3
ffffffffc02030ba:	29a60613          	addi	a2,a2,666 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02030be:	24300593          	li	a1,579
ffffffffc02030c2:	00003517          	auipc	a0,0x3
ffffffffc02030c6:	72e50513          	addi	a0,a0,1838 # ffffffffc02067f0 <etext+0xece>
ffffffffc02030ca:	b7cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02030ce:	00004697          	auipc	a3,0x4
ffffffffc02030d2:	95a68693          	addi	a3,a3,-1702 # ffffffffc0206a28 <etext+0x1106>
ffffffffc02030d6:	00003617          	auipc	a2,0x3
ffffffffc02030da:	27a60613          	addi	a2,a2,634 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02030de:	24200593          	li	a1,578
ffffffffc02030e2:	00003517          	auipc	a0,0x3
ffffffffc02030e6:	70e50513          	addi	a0,a0,1806 # ffffffffc02067f0 <etext+0xece>
ffffffffc02030ea:	b5cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02030ee:	00004697          	auipc	a3,0x4
ffffffffc02030f2:	ab268693          	addi	a3,a3,-1358 # ffffffffc0206ba0 <etext+0x127e>
ffffffffc02030f6:	00003617          	auipc	a2,0x3
ffffffffc02030fa:	25a60613          	addi	a2,a2,602 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02030fe:	23f00593          	li	a1,575
ffffffffc0203102:	00003517          	auipc	a0,0x3
ffffffffc0203106:	6ee50513          	addi	a0,a0,1774 # ffffffffc02067f0 <etext+0xece>
ffffffffc020310a:	b3cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020310e:	00004697          	auipc	a3,0x4
ffffffffc0203112:	90268693          	addi	a3,a3,-1790 # ffffffffc0206a10 <etext+0x10ee>
ffffffffc0203116:	00003617          	auipc	a2,0x3
ffffffffc020311a:	23a60613          	addi	a2,a2,570 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020311e:	23e00593          	li	a1,574
ffffffffc0203122:	00003517          	auipc	a0,0x3
ffffffffc0203126:	6ce50513          	addi	a0,a0,1742 # ffffffffc02067f0 <etext+0xece>
ffffffffc020312a:	b1cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020312e:	00004697          	auipc	a3,0x4
ffffffffc0203132:	98268693          	addi	a3,a3,-1662 # ffffffffc0206ab0 <etext+0x118e>
ffffffffc0203136:	00003617          	auipc	a2,0x3
ffffffffc020313a:	21a60613          	addi	a2,a2,538 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020313e:	23d00593          	li	a1,573
ffffffffc0203142:	00003517          	auipc	a0,0x3
ffffffffc0203146:	6ae50513          	addi	a0,a0,1710 # ffffffffc02067f0 <etext+0xece>
ffffffffc020314a:	afcfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020314e:	00004697          	auipc	a3,0x4
ffffffffc0203152:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0206b88 <etext+0x1266>
ffffffffc0203156:	00003617          	auipc	a2,0x3
ffffffffc020315a:	1fa60613          	addi	a2,a2,506 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020315e:	23c00593          	li	a1,572
ffffffffc0203162:	00003517          	auipc	a0,0x3
ffffffffc0203166:	68e50513          	addi	a0,a0,1678 # ffffffffc02067f0 <etext+0xece>
ffffffffc020316a:	adcfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020316e:	00004697          	auipc	a3,0x4
ffffffffc0203172:	a0268693          	addi	a3,a3,-1534 # ffffffffc0206b70 <etext+0x124e>
ffffffffc0203176:	00003617          	auipc	a2,0x3
ffffffffc020317a:	1da60613          	addi	a2,a2,474 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020317e:	23b00593          	li	a1,571
ffffffffc0203182:	00003517          	auipc	a0,0x3
ffffffffc0203186:	66e50513          	addi	a0,a0,1646 # ffffffffc02067f0 <etext+0xece>
ffffffffc020318a:	abcfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc020318e:	00004697          	auipc	a3,0x4
ffffffffc0203192:	9b268693          	addi	a3,a3,-1614 # ffffffffc0206b40 <etext+0x121e>
ffffffffc0203196:	00003617          	auipc	a2,0x3
ffffffffc020319a:	1ba60613          	addi	a2,a2,442 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020319e:	23a00593          	li	a1,570
ffffffffc02031a2:	00003517          	auipc	a0,0x3
ffffffffc02031a6:	64e50513          	addi	a0,a0,1614 # ffffffffc02067f0 <etext+0xece>
ffffffffc02031aa:	a9cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02031ae:	00004697          	auipc	a3,0x4
ffffffffc02031b2:	97a68693          	addi	a3,a3,-1670 # ffffffffc0206b28 <etext+0x1206>
ffffffffc02031b6:	00003617          	auipc	a2,0x3
ffffffffc02031ba:	19a60613          	addi	a2,a2,410 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02031be:	23800593          	li	a1,568
ffffffffc02031c2:	00003517          	auipc	a0,0x3
ffffffffc02031c6:	62e50513          	addi	a0,a0,1582 # ffffffffc02067f0 <etext+0xece>
ffffffffc02031ca:	a7cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02031ce:	00004697          	auipc	a3,0x4
ffffffffc02031d2:	93a68693          	addi	a3,a3,-1734 # ffffffffc0206b08 <etext+0x11e6>
ffffffffc02031d6:	00003617          	auipc	a2,0x3
ffffffffc02031da:	17a60613          	addi	a2,a2,378 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02031de:	23700593          	li	a1,567
ffffffffc02031e2:	00003517          	auipc	a0,0x3
ffffffffc02031e6:	60e50513          	addi	a0,a0,1550 # ffffffffc02067f0 <etext+0xece>
ffffffffc02031ea:	a5cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02031ee:	00004697          	auipc	a3,0x4
ffffffffc02031f2:	90a68693          	addi	a3,a3,-1782 # ffffffffc0206af8 <etext+0x11d6>
ffffffffc02031f6:	00003617          	auipc	a2,0x3
ffffffffc02031fa:	15a60613          	addi	a2,a2,346 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02031fe:	23600593          	li	a1,566
ffffffffc0203202:	00003517          	auipc	a0,0x3
ffffffffc0203206:	5ee50513          	addi	a0,a0,1518 # ffffffffc02067f0 <etext+0xece>
ffffffffc020320a:	a3cfd0ef          	jal	ffffffffc0200446 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020320e:	00004697          	auipc	a3,0x4
ffffffffc0203212:	8da68693          	addi	a3,a3,-1830 # ffffffffc0206ae8 <etext+0x11c6>
ffffffffc0203216:	00003617          	auipc	a2,0x3
ffffffffc020321a:	13a60613          	addi	a2,a2,314 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020321e:	23500593          	li	a1,565
ffffffffc0203222:	00003517          	auipc	a0,0x3
ffffffffc0203226:	5ce50513          	addi	a0,a0,1486 # ffffffffc02067f0 <etext+0xece>
ffffffffc020322a:	a1cfd0ef          	jal	ffffffffc0200446 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020322e:	00003617          	auipc	a2,0x3
ffffffffc0203232:	57a60613          	addi	a2,a2,1402 # ffffffffc02067a8 <etext+0xe86>
ffffffffc0203236:	08100593          	li	a1,129
ffffffffc020323a:	00003517          	auipc	a0,0x3
ffffffffc020323e:	5b650513          	addi	a0,a0,1462 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203242:	a04fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203246:	00003697          	auipc	a3,0x3
ffffffffc020324a:	7fa68693          	addi	a3,a3,2042 # ffffffffc0206a40 <etext+0x111e>
ffffffffc020324e:	00003617          	auipc	a2,0x3
ffffffffc0203252:	10260613          	addi	a2,a2,258 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203256:	23000593          	li	a1,560
ffffffffc020325a:	00003517          	auipc	a0,0x3
ffffffffc020325e:	59650513          	addi	a0,a0,1430 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203262:	9e4fd0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203266:	00004697          	auipc	a3,0x4
ffffffffc020326a:	84a68693          	addi	a3,a3,-1974 # ffffffffc0206ab0 <etext+0x118e>
ffffffffc020326e:	00003617          	auipc	a2,0x3
ffffffffc0203272:	0e260613          	addi	a2,a2,226 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203276:	23400593          	li	a1,564
ffffffffc020327a:	00003517          	auipc	a0,0x3
ffffffffc020327e:	57650513          	addi	a0,a0,1398 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203282:	9c4fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203286:	00003697          	auipc	a3,0x3
ffffffffc020328a:	7ea68693          	addi	a3,a3,2026 # ffffffffc0206a70 <etext+0x114e>
ffffffffc020328e:	00003617          	auipc	a2,0x3
ffffffffc0203292:	0c260613          	addi	a2,a2,194 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203296:	23300593          	li	a1,563
ffffffffc020329a:	00003517          	auipc	a0,0x3
ffffffffc020329e:	55650513          	addi	a0,a0,1366 # ffffffffc02067f0 <etext+0xece>
ffffffffc02032a2:	9a4fd0ef          	jal	ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032a6:	86d6                	mv	a3,s5
ffffffffc02032a8:	00003617          	auipc	a2,0x3
ffffffffc02032ac:	45860613          	addi	a2,a2,1112 # ffffffffc0206700 <etext+0xdde>
ffffffffc02032b0:	22f00593          	li	a1,559
ffffffffc02032b4:	00003517          	auipc	a0,0x3
ffffffffc02032b8:	53c50513          	addi	a0,a0,1340 # ffffffffc02067f0 <etext+0xece>
ffffffffc02032bc:	98afd0ef          	jal	ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02032c0:	00003617          	auipc	a2,0x3
ffffffffc02032c4:	44060613          	addi	a2,a2,1088 # ffffffffc0206700 <etext+0xdde>
ffffffffc02032c8:	22e00593          	li	a1,558
ffffffffc02032cc:	00003517          	auipc	a0,0x3
ffffffffc02032d0:	52450513          	addi	a0,a0,1316 # ffffffffc02067f0 <etext+0xece>
ffffffffc02032d4:	972fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02032d8:	00003697          	auipc	a3,0x3
ffffffffc02032dc:	75068693          	addi	a3,a3,1872 # ffffffffc0206a28 <etext+0x1106>
ffffffffc02032e0:	00003617          	auipc	a2,0x3
ffffffffc02032e4:	07060613          	addi	a2,a2,112 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02032e8:	22c00593          	li	a1,556
ffffffffc02032ec:	00003517          	auipc	a0,0x3
ffffffffc02032f0:	50450513          	addi	a0,a0,1284 # ffffffffc02067f0 <etext+0xece>
ffffffffc02032f4:	952fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02032f8:	00003697          	auipc	a3,0x3
ffffffffc02032fc:	71868693          	addi	a3,a3,1816 # ffffffffc0206a10 <etext+0x10ee>
ffffffffc0203300:	00003617          	auipc	a2,0x3
ffffffffc0203304:	05060613          	addi	a2,a2,80 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203308:	22b00593          	li	a1,555
ffffffffc020330c:	00003517          	auipc	a0,0x3
ffffffffc0203310:	4e450513          	addi	a0,a0,1252 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203314:	932fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203318:	00004697          	auipc	a3,0x4
ffffffffc020331c:	aa868693          	addi	a3,a3,-1368 # ffffffffc0206dc0 <etext+0x149e>
ffffffffc0203320:	00003617          	auipc	a2,0x3
ffffffffc0203324:	03060613          	addi	a2,a2,48 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203328:	27200593          	li	a1,626
ffffffffc020332c:	00003517          	auipc	a0,0x3
ffffffffc0203330:	4c450513          	addi	a0,a0,1220 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203334:	912fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203338:	00004697          	auipc	a3,0x4
ffffffffc020333c:	a5068693          	addi	a3,a3,-1456 # ffffffffc0206d88 <etext+0x1466>
ffffffffc0203340:	00003617          	auipc	a2,0x3
ffffffffc0203344:	01060613          	addi	a2,a2,16 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203348:	26f00593          	li	a1,623
ffffffffc020334c:	00003517          	auipc	a0,0x3
ffffffffc0203350:	4a450513          	addi	a0,a0,1188 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203354:	8f2fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203358:	00004697          	auipc	a3,0x4
ffffffffc020335c:	a0068693          	addi	a3,a3,-1536 # ffffffffc0206d58 <etext+0x1436>
ffffffffc0203360:	00003617          	auipc	a2,0x3
ffffffffc0203364:	ff060613          	addi	a2,a2,-16 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203368:	26b00593          	li	a1,619
ffffffffc020336c:	00003517          	auipc	a0,0x3
ffffffffc0203370:	48450513          	addi	a0,a0,1156 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203374:	8d2fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203378:	00004697          	auipc	a3,0x4
ffffffffc020337c:	99868693          	addi	a3,a3,-1640 # ffffffffc0206d10 <etext+0x13ee>
ffffffffc0203380:	00003617          	auipc	a2,0x3
ffffffffc0203384:	fd060613          	addi	a2,a2,-48 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203388:	26a00593          	li	a1,618
ffffffffc020338c:	00003517          	auipc	a0,0x3
ffffffffc0203390:	46450513          	addi	a0,a0,1124 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203394:	8b2fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0203398:	00003697          	auipc	a3,0x3
ffffffffc020339c:	5c068693          	addi	a3,a3,1472 # ffffffffc0206958 <etext+0x1036>
ffffffffc02033a0:	00003617          	auipc	a2,0x3
ffffffffc02033a4:	fb060613          	addi	a2,a2,-80 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02033a8:	22300593          	li	a1,547
ffffffffc02033ac:	00003517          	auipc	a0,0x3
ffffffffc02033b0:	44450513          	addi	a0,a0,1092 # ffffffffc02067f0 <etext+0xece>
ffffffffc02033b4:	892fd0ef          	jal	ffffffffc0200446 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02033b8:	00003617          	auipc	a2,0x3
ffffffffc02033bc:	3f060613          	addi	a2,a2,1008 # ffffffffc02067a8 <etext+0xe86>
ffffffffc02033c0:	0c900593          	li	a1,201
ffffffffc02033c4:	00003517          	auipc	a0,0x3
ffffffffc02033c8:	42c50513          	addi	a0,a0,1068 # ffffffffc02067f0 <etext+0xece>
ffffffffc02033cc:	87afd0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02033d0:	00003697          	auipc	a3,0x3
ffffffffc02033d4:	5e868693          	addi	a3,a3,1512 # ffffffffc02069b8 <etext+0x1096>
ffffffffc02033d8:	00003617          	auipc	a2,0x3
ffffffffc02033dc:	f7860613          	addi	a2,a2,-136 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02033e0:	22a00593          	li	a1,554
ffffffffc02033e4:	00003517          	auipc	a0,0x3
ffffffffc02033e8:	40c50513          	addi	a0,a0,1036 # ffffffffc02067f0 <etext+0xece>
ffffffffc02033ec:	85afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02033f0:	00003697          	auipc	a3,0x3
ffffffffc02033f4:	59868693          	addi	a3,a3,1432 # ffffffffc0206988 <etext+0x1066>
ffffffffc02033f8:	00003617          	auipc	a2,0x3
ffffffffc02033fc:	f5860613          	addi	a2,a2,-168 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203400:	22700593          	li	a1,551
ffffffffc0203404:	00003517          	auipc	a0,0x3
ffffffffc0203408:	3ec50513          	addi	a0,a0,1004 # ffffffffc02067f0 <etext+0xece>
ffffffffc020340c:	83afd0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203410 <copy_range>:
{
ffffffffc0203410:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203412:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203416:	f486                	sd	ra,104(sp)
ffffffffc0203418:	f0a2                	sd	s0,96(sp)
ffffffffc020341a:	eca6                	sd	s1,88(sp)
ffffffffc020341c:	e8ca                	sd	s2,80(sp)
ffffffffc020341e:	e4ce                	sd	s3,72(sp)
ffffffffc0203420:	e0d2                	sd	s4,64(sp)
ffffffffc0203422:	fc56                	sd	s5,56(sp)
ffffffffc0203424:	f85a                	sd	s6,48(sp)
ffffffffc0203426:	f45e                	sd	s7,40(sp)
ffffffffc0203428:	f062                	sd	s8,32(sp)
ffffffffc020342a:	ec66                	sd	s9,24(sp)
ffffffffc020342c:	e86a                	sd	s10,16(sp)
ffffffffc020342e:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203430:	03479713          	slli	a4,a5,0x34
ffffffffc0203434:	24071563          	bnez	a4,ffffffffc020367e <copy_range+0x26e>
    assert(USER_ACCESS(start, end));
ffffffffc0203438:	002007b7          	lui	a5,0x200
ffffffffc020343c:	00d63733          	sltu	a4,a2,a3
ffffffffc0203440:	00f637b3          	sltu	a5,a2,a5
ffffffffc0203444:	00173713          	seqz	a4,a4
ffffffffc0203448:	8fd9                	or	a5,a5,a4
ffffffffc020344a:	8432                	mv	s0,a2
ffffffffc020344c:	8936                	mv	s2,a3
ffffffffc020344e:	20079863          	bnez	a5,ffffffffc020365e <copy_range+0x24e>
ffffffffc0203452:	4785                	li	a5,1
ffffffffc0203454:	07fe                	slli	a5,a5,0x1f
ffffffffc0203456:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_exit_out_size+0x1f5e19>
ffffffffc0203458:	20f6f363          	bgeu	a3,a5,ffffffffc020365e <copy_range+0x24e>
ffffffffc020345c:	5b7d                	li	s6,-1
ffffffffc020345e:	8c2a                	mv	s8,a0
ffffffffc0203460:	8a2e                	mv	s4,a1
ffffffffc0203462:	6a85                	lui	s5,0x1
ffffffffc0203464:	00cb5b13          	srli	s6,s6,0xc
    if (PPN(pa) >= npage)
ffffffffc0203468:	00098d17          	auipc	s10,0x98
ffffffffc020346c:	4c8d0d13          	addi	s10,s10,1224 # ffffffffc029b930 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203470:	00098c97          	auipc	s9,0x98
ffffffffc0203474:	4c8c8c93          	addi	s9,s9,1224 # ffffffffc029b938 <pages>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203478:	4601                	li	a2,0
ffffffffc020347a:	85a2                	mv	a1,s0
ffffffffc020347c:	8552                	mv	a0,s4
ffffffffc020347e:	b1dfe0ef          	jal	ffffffffc0201f9a <get_pte>
ffffffffc0203482:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203484:	c96d                	beqz	a0,ffffffffc0203576 <copy_range+0x166>
        if (*ptep & PTE_V)
ffffffffc0203486:	611c                	ld	a5,0(a0)
ffffffffc0203488:	8b85                	andi	a5,a5,1
ffffffffc020348a:	e78d                	bnez	a5,ffffffffc02034b4 <copy_range+0xa4>
        start += PGSIZE;
ffffffffc020348c:	9456                	add	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020348e:	c019                	beqz	s0,ffffffffc0203494 <copy_range+0x84>
ffffffffc0203490:	ff2464e3          	bltu	s0,s2,ffffffffc0203478 <copy_range+0x68>
    return 0;
ffffffffc0203494:	4501                	li	a0,0
}
ffffffffc0203496:	70a6                	ld	ra,104(sp)
ffffffffc0203498:	7406                	ld	s0,96(sp)
ffffffffc020349a:	64e6                	ld	s1,88(sp)
ffffffffc020349c:	6946                	ld	s2,80(sp)
ffffffffc020349e:	69a6                	ld	s3,72(sp)
ffffffffc02034a0:	6a06                	ld	s4,64(sp)
ffffffffc02034a2:	7ae2                	ld	s5,56(sp)
ffffffffc02034a4:	7b42                	ld	s6,48(sp)
ffffffffc02034a6:	7ba2                	ld	s7,40(sp)
ffffffffc02034a8:	7c02                	ld	s8,32(sp)
ffffffffc02034aa:	6ce2                	ld	s9,24(sp)
ffffffffc02034ac:	6d42                	ld	s10,16(sp)
ffffffffc02034ae:	6da2                	ld	s11,8(sp)
ffffffffc02034b0:	6165                	addi	sp,sp,112
ffffffffc02034b2:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc02034b4:	4605                	li	a2,1
ffffffffc02034b6:	85a2                	mv	a1,s0
ffffffffc02034b8:	8562                	mv	a0,s8
ffffffffc02034ba:	ae1fe0ef          	jal	ffffffffc0201f9a <get_pte>
ffffffffc02034be:	c955                	beqz	a0,ffffffffc0203572 <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02034c0:	0004b983          	ld	s3,0(s1)
    if (!(pte & PTE_V))
ffffffffc02034c4:	0019f793          	andi	a5,s3,1
ffffffffc02034c8:	16078263          	beqz	a5,ffffffffc020362c <copy_range+0x21c>
    if (PPN(pa) >= npage)
ffffffffc02034cc:	000d3783          	ld	a5,0(s10)
    return pa2page(PTE_ADDR(pte));
ffffffffc02034d0:	00299713          	slli	a4,s3,0x2
ffffffffc02034d4:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02034d6:	12f77f63          	bgeu	a4,a5,ffffffffc0203614 <copy_range+0x204>
    return &pages[PPN(pa) - nbase];
ffffffffc02034da:	000cb783          	ld	a5,0(s9)
ffffffffc02034de:	fff806b7          	lui	a3,0xfff80
ffffffffc02034e2:	9736                	add	a4,a4,a3
ffffffffc02034e4:	071a                	slli	a4,a4,0x6
ffffffffc02034e6:	00e78db3          	add	s11,a5,a4
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02034ea:	10002773          	csrr	a4,sstatus
ffffffffc02034ee:	8b09                	andi	a4,a4,2
ffffffffc02034f0:	eb51                	bnez	a4,ffffffffc0203584 <copy_range+0x174>
        page = pmm_manager->alloc_pages(n);
ffffffffc02034f2:	00098b97          	auipc	s7,0x98
ffffffffc02034f6:	41eb8b93          	addi	s7,s7,1054 # ffffffffc029b910 <pmm_manager>
ffffffffc02034fa:	000bb703          	ld	a4,0(s7)
ffffffffc02034fe:	4505                	li	a0,1
ffffffffc0203500:	6f18                	ld	a4,24(a4)
ffffffffc0203502:	9702                	jalr	a4
ffffffffc0203504:	84aa                	mv	s1,a0
            assert(page != NULL);
ffffffffc0203506:	0e0d8763          	beqz	s11,ffffffffc02035f4 <copy_range+0x1e4>
            assert(npage != NULL);
ffffffffc020350a:	c4e9                	beqz	s1,ffffffffc02035d4 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc020350c:	000cb503          	ld	a0,0(s9)
ffffffffc0203510:	000806b7          	lui	a3,0x80
    return KADDR(page2pa(page));
ffffffffc0203514:	000d3703          	ld	a4,0(s10)
    return page - pages + nbase;
ffffffffc0203518:	40ad85b3          	sub	a1,s11,a0
ffffffffc020351c:	8599                	srai	a1,a1,0x6
ffffffffc020351e:	95b6                	add	a1,a1,a3
    return KADDR(page2pa(page));
ffffffffc0203520:	0165f7b3          	and	a5,a1,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203524:	05b2                	slli	a1,a1,0xc
    return KADDR(page2pa(page));
ffffffffc0203526:	10e7ff63          	bgeu	a5,a4,ffffffffc0203644 <copy_range+0x234>
    return page - pages + nbase;
ffffffffc020352a:	40a48533          	sub	a0,s1,a0
ffffffffc020352e:	8519                	srai	a0,a0,0x6
ffffffffc0203530:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0203532:	016577b3          	and	a5,a0,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203536:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0203538:	08e7f163          	bgeu	a5,a4,ffffffffc02035ba <copy_range+0x1aa>
ffffffffc020353c:	00098797          	auipc	a5,0x98
ffffffffc0203540:	3ec7b783          	ld	a5,1004(a5) # ffffffffc029b928 <va_pa_offset>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE); 
ffffffffc0203544:	6605                	lui	a2,0x1
ffffffffc0203546:	95be                	add	a1,a1,a5
ffffffffc0203548:	953e                	add	a0,a0,a5
ffffffffc020354a:	3c0020ef          	jal	ffffffffc020590a <memcpy>
            ret = page_insert(to, npage, start, perm); 
ffffffffc020354e:	01f9f693          	andi	a3,s3,31
ffffffffc0203552:	8622                	mv	a2,s0
ffffffffc0203554:	85a6                	mv	a1,s1
ffffffffc0203556:	8562                	mv	a0,s8
ffffffffc0203558:	978ff0ef          	jal	ffffffffc02026d0 <page_insert>
            if (ret != 0)                              
ffffffffc020355c:	d905                	beqz	a0,ffffffffc020348c <copy_range+0x7c>
ffffffffc020355e:	100027f3          	csrr	a5,sstatus
ffffffffc0203562:	8b89                	andi	a5,a5,2
ffffffffc0203564:	ef9d                	bnez	a5,ffffffffc02035a2 <copy_range+0x192>
        pmm_manager->free_pages(base, n);
ffffffffc0203566:	000bb783          	ld	a5,0(s7)
ffffffffc020356a:	8526                	mv	a0,s1
ffffffffc020356c:	4585                	li	a1,1
ffffffffc020356e:	739c                	ld	a5,32(a5)
ffffffffc0203570:	9782                	jalr	a5
                return -E_NO_MEM;
ffffffffc0203572:	5571                	li	a0,-4
ffffffffc0203574:	b70d                	j	ffffffffc0203496 <copy_range+0x86>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203576:	002007b7          	lui	a5,0x200
ffffffffc020357a:	97a2                	add	a5,a5,s0
ffffffffc020357c:	ffe00437          	lui	s0,0xffe00
ffffffffc0203580:	8c7d                	and	s0,s0,a5
            continue;
ffffffffc0203582:	b731                	j	ffffffffc020348e <copy_range+0x7e>
        intr_disable();
ffffffffc0203584:	b80fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203588:	00098b97          	auipc	s7,0x98
ffffffffc020358c:	388b8b93          	addi	s7,s7,904 # ffffffffc029b910 <pmm_manager>
ffffffffc0203590:	000bb703          	ld	a4,0(s7)
ffffffffc0203594:	4505                	li	a0,1
ffffffffc0203596:	6f18                	ld	a4,24(a4)
ffffffffc0203598:	9702                	jalr	a4
ffffffffc020359a:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc020359c:	b62fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02035a0:	b79d                	j	ffffffffc0203506 <copy_range+0xf6>
        intr_disable();
ffffffffc02035a2:	b62fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02035a6:	000bb783          	ld	a5,0(s7)
ffffffffc02035aa:	8526                	mv	a0,s1
ffffffffc02035ac:	4585                	li	a1,1
ffffffffc02035ae:	739c                	ld	a5,32(a5)
ffffffffc02035b0:	9782                	jalr	a5
        intr_enable();
ffffffffc02035b2:	b4cfd0ef          	jal	ffffffffc02008fe <intr_enable>
                return -E_NO_MEM;
ffffffffc02035b6:	5571                	li	a0,-4
ffffffffc02035b8:	bdf9                	j	ffffffffc0203496 <copy_range+0x86>
ffffffffc02035ba:	86aa                	mv	a3,a0
ffffffffc02035bc:	00003617          	auipc	a2,0x3
ffffffffc02035c0:	14460613          	addi	a2,a2,324 # ffffffffc0206700 <etext+0xdde>
ffffffffc02035c4:	07100593          	li	a1,113
ffffffffc02035c8:	00003517          	auipc	a0,0x3
ffffffffc02035cc:	16050513          	addi	a0,a0,352 # ffffffffc0206728 <etext+0xe06>
ffffffffc02035d0:	e77fc0ef          	jal	ffffffffc0200446 <__panic>
            assert(npage != NULL);
ffffffffc02035d4:	00004697          	auipc	a3,0x4
ffffffffc02035d8:	84468693          	addi	a3,a3,-1980 # ffffffffc0206e18 <etext+0x14f6>
ffffffffc02035dc:	00003617          	auipc	a2,0x3
ffffffffc02035e0:	d7460613          	addi	a2,a2,-652 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02035e4:	19500593          	li	a1,405
ffffffffc02035e8:	00003517          	auipc	a0,0x3
ffffffffc02035ec:	20850513          	addi	a0,a0,520 # ffffffffc02067f0 <etext+0xece>
ffffffffc02035f0:	e57fc0ef          	jal	ffffffffc0200446 <__panic>
            assert(page != NULL);
ffffffffc02035f4:	00004697          	auipc	a3,0x4
ffffffffc02035f8:	81468693          	addi	a3,a3,-2028 # ffffffffc0206e08 <etext+0x14e6>
ffffffffc02035fc:	00003617          	auipc	a2,0x3
ffffffffc0203600:	d5460613          	addi	a2,a2,-684 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203604:	19400593          	li	a1,404
ffffffffc0203608:	00003517          	auipc	a0,0x3
ffffffffc020360c:	1e850513          	addi	a0,a0,488 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203610:	e37fc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203614:	00003617          	auipc	a2,0x3
ffffffffc0203618:	1bc60613          	addi	a2,a2,444 # ffffffffc02067d0 <etext+0xeae>
ffffffffc020361c:	06900593          	li	a1,105
ffffffffc0203620:	00003517          	auipc	a0,0x3
ffffffffc0203624:	10850513          	addi	a0,a0,264 # ffffffffc0206728 <etext+0xe06>
ffffffffc0203628:	e1ffc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020362c:	00003617          	auipc	a2,0x3
ffffffffc0203630:	3bc60613          	addi	a2,a2,956 # ffffffffc02069e8 <etext+0x10c6>
ffffffffc0203634:	07f00593          	li	a1,127
ffffffffc0203638:	00003517          	auipc	a0,0x3
ffffffffc020363c:	0f050513          	addi	a0,a0,240 # ffffffffc0206728 <etext+0xe06>
ffffffffc0203640:	e07fc0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203644:	86ae                	mv	a3,a1
ffffffffc0203646:	00003617          	auipc	a2,0x3
ffffffffc020364a:	0ba60613          	addi	a2,a2,186 # ffffffffc0206700 <etext+0xdde>
ffffffffc020364e:	07100593          	li	a1,113
ffffffffc0203652:	00003517          	auipc	a0,0x3
ffffffffc0203656:	0d650513          	addi	a0,a0,214 # ffffffffc0206728 <etext+0xe06>
ffffffffc020365a:	dedfc0ef          	jal	ffffffffc0200446 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020365e:	00003697          	auipc	a3,0x3
ffffffffc0203662:	1d268693          	addi	a3,a3,466 # ffffffffc0206830 <etext+0xf0e>
ffffffffc0203666:	00003617          	auipc	a2,0x3
ffffffffc020366a:	cea60613          	addi	a2,a2,-790 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020366e:	17c00593          	li	a1,380
ffffffffc0203672:	00003517          	auipc	a0,0x3
ffffffffc0203676:	17e50513          	addi	a0,a0,382 # ffffffffc02067f0 <etext+0xece>
ffffffffc020367a:	dcdfc0ef          	jal	ffffffffc0200446 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020367e:	00003697          	auipc	a3,0x3
ffffffffc0203682:	18268693          	addi	a3,a3,386 # ffffffffc0206800 <etext+0xede>
ffffffffc0203686:	00003617          	auipc	a2,0x3
ffffffffc020368a:	cca60613          	addi	a2,a2,-822 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020368e:	17b00593          	li	a1,379
ffffffffc0203692:	00003517          	auipc	a0,0x3
ffffffffc0203696:	15e50513          	addi	a0,a0,350 # ffffffffc02067f0 <etext+0xece>
ffffffffc020369a:	dadfc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020369e <pgdir_alloc_page>:
{
ffffffffc020369e:	7139                	addi	sp,sp,-64
ffffffffc02036a0:	f426                	sd	s1,40(sp)
ffffffffc02036a2:	f04a                	sd	s2,32(sp)
ffffffffc02036a4:	ec4e                	sd	s3,24(sp)
ffffffffc02036a6:	fc06                	sd	ra,56(sp)
ffffffffc02036a8:	f822                	sd	s0,48(sp)
ffffffffc02036aa:	892a                	mv	s2,a0
ffffffffc02036ac:	84ae                	mv	s1,a1
ffffffffc02036ae:	89b2                	mv	s3,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02036b0:	100027f3          	csrr	a5,sstatus
ffffffffc02036b4:	8b89                	andi	a5,a5,2
ffffffffc02036b6:	ebb5                	bnez	a5,ffffffffc020372a <pgdir_alloc_page+0x8c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02036b8:	00098417          	auipc	s0,0x98
ffffffffc02036bc:	25840413          	addi	s0,s0,600 # ffffffffc029b910 <pmm_manager>
ffffffffc02036c0:	601c                	ld	a5,0(s0)
ffffffffc02036c2:	4505                	li	a0,1
ffffffffc02036c4:	6f9c                	ld	a5,24(a5)
ffffffffc02036c6:	9782                	jalr	a5
ffffffffc02036c8:	85aa                	mv	a1,a0
    if (page != NULL)
ffffffffc02036ca:	c5b9                	beqz	a1,ffffffffc0203718 <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc02036cc:	86ce                	mv	a3,s3
ffffffffc02036ce:	854a                	mv	a0,s2
ffffffffc02036d0:	8626                	mv	a2,s1
ffffffffc02036d2:	e42e                	sd	a1,8(sp)
ffffffffc02036d4:	ffdfe0ef          	jal	ffffffffc02026d0 <page_insert>
ffffffffc02036d8:	65a2                	ld	a1,8(sp)
ffffffffc02036da:	e515                	bnez	a0,ffffffffc0203706 <pgdir_alloc_page+0x68>
        assert(page_ref(page) == 1);
ffffffffc02036dc:	4198                	lw	a4,0(a1)
        page->pra_vaddr = la;
ffffffffc02036de:	fd84                	sd	s1,56(a1)
        assert(page_ref(page) == 1);
ffffffffc02036e0:	4785                	li	a5,1
ffffffffc02036e2:	02f70c63          	beq	a4,a5,ffffffffc020371a <pgdir_alloc_page+0x7c>
ffffffffc02036e6:	00003697          	auipc	a3,0x3
ffffffffc02036ea:	74268693          	addi	a3,a3,1858 # ffffffffc0206e28 <etext+0x1506>
ffffffffc02036ee:	00003617          	auipc	a2,0x3
ffffffffc02036f2:	c6260613          	addi	a2,a2,-926 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02036f6:	20800593          	li	a1,520
ffffffffc02036fa:	00003517          	auipc	a0,0x3
ffffffffc02036fe:	0f650513          	addi	a0,a0,246 # ffffffffc02067f0 <etext+0xece>
ffffffffc0203702:	d45fc0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0203706:	100027f3          	csrr	a5,sstatus
ffffffffc020370a:	8b89                	andi	a5,a5,2
ffffffffc020370c:	ef95                	bnez	a5,ffffffffc0203748 <pgdir_alloc_page+0xaa>
        pmm_manager->free_pages(base, n);
ffffffffc020370e:	601c                	ld	a5,0(s0)
ffffffffc0203710:	852e                	mv	a0,a1
ffffffffc0203712:	4585                	li	a1,1
ffffffffc0203714:	739c                	ld	a5,32(a5)
ffffffffc0203716:	9782                	jalr	a5
            return NULL;
ffffffffc0203718:	4581                	li	a1,0
}
ffffffffc020371a:	70e2                	ld	ra,56(sp)
ffffffffc020371c:	7442                	ld	s0,48(sp)
ffffffffc020371e:	74a2                	ld	s1,40(sp)
ffffffffc0203720:	7902                	ld	s2,32(sp)
ffffffffc0203722:	69e2                	ld	s3,24(sp)
ffffffffc0203724:	852e                	mv	a0,a1
ffffffffc0203726:	6121                	addi	sp,sp,64
ffffffffc0203728:	8082                	ret
        intr_disable();
ffffffffc020372a:	9dafd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020372e:	00098417          	auipc	s0,0x98
ffffffffc0203732:	1e240413          	addi	s0,s0,482 # ffffffffc029b910 <pmm_manager>
ffffffffc0203736:	601c                	ld	a5,0(s0)
ffffffffc0203738:	4505                	li	a0,1
ffffffffc020373a:	6f9c                	ld	a5,24(a5)
ffffffffc020373c:	9782                	jalr	a5
ffffffffc020373e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0203740:	9befd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203744:	65a2                	ld	a1,8(sp)
ffffffffc0203746:	b751                	j	ffffffffc02036ca <pgdir_alloc_page+0x2c>
        intr_disable();
ffffffffc0203748:	9bcfd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020374c:	601c                	ld	a5,0(s0)
ffffffffc020374e:	6522                	ld	a0,8(sp)
ffffffffc0203750:	4585                	li	a1,1
ffffffffc0203752:	739c                	ld	a5,32(a5)
ffffffffc0203754:	9782                	jalr	a5
        intr_enable();
ffffffffc0203756:	9a8fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020375a:	bf7d                	j	ffffffffc0203718 <pgdir_alloc_page+0x7a>

ffffffffc020375c <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc020375c:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020375e:	00003697          	auipc	a3,0x3
ffffffffc0203762:	6e268693          	addi	a3,a3,1762 # ffffffffc0206e40 <etext+0x151e>
ffffffffc0203766:	00003617          	auipc	a2,0x3
ffffffffc020376a:	bea60613          	addi	a2,a2,-1046 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020376e:	0a500593          	li	a1,165
ffffffffc0203772:	00003517          	auipc	a0,0x3
ffffffffc0203776:	6ee50513          	addi	a0,a0,1774 # ffffffffc0206e60 <etext+0x153e>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc020377a:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020377c:	ccbfc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203780 <mm_create>:
{
ffffffffc0203780:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203782:	04000513          	li	a0,64
{
ffffffffc0203786:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203788:	da8fe0ef          	jal	ffffffffc0201d30 <kmalloc>
    if (mm != NULL)
ffffffffc020378c:	cd19                	beqz	a0,ffffffffc02037aa <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc020378e:	e508                	sd	a0,8(a0)
ffffffffc0203790:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203792:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203796:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020379a:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020379e:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc02037a2:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc02037a6:	02053c23          	sd	zero,56(a0)
}
ffffffffc02037aa:	60a2                	ld	ra,8(sp)
ffffffffc02037ac:	0141                	addi	sp,sp,16
ffffffffc02037ae:	8082                	ret

ffffffffc02037b0 <find_vma>:
    if (mm != NULL)
ffffffffc02037b0:	c505                	beqz	a0,ffffffffc02037d8 <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc02037b2:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02037b4:	c781                	beqz	a5,ffffffffc02037bc <find_vma+0xc>
ffffffffc02037b6:	6798                	ld	a4,8(a5)
ffffffffc02037b8:	02e5f363          	bgeu	a1,a4,ffffffffc02037de <find_vma+0x2e>
    return listelm->next;
ffffffffc02037bc:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc02037be:	00f50d63          	beq	a0,a5,ffffffffc02037d8 <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc02037c2:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f5e00>
ffffffffc02037c6:	00e5e663          	bltu	a1,a4,ffffffffc02037d2 <find_vma+0x22>
ffffffffc02037ca:	ff07b703          	ld	a4,-16(a5)
ffffffffc02037ce:	00e5ee63          	bltu	a1,a4,ffffffffc02037ea <find_vma+0x3a>
ffffffffc02037d2:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc02037d4:	fef517e3          	bne	a0,a5,ffffffffc02037c2 <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc02037d8:	4781                	li	a5,0
}
ffffffffc02037da:	853e                	mv	a0,a5
ffffffffc02037dc:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02037de:	6b98                	ld	a4,16(a5)
ffffffffc02037e0:	fce5fee3          	bgeu	a1,a4,ffffffffc02037bc <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02037e4:	e91c                	sd	a5,16(a0)
}
ffffffffc02037e6:	853e                	mv	a0,a5
ffffffffc02037e8:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02037ea:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc02037ec:	e91c                	sd	a5,16(a0)
ffffffffc02037ee:	bfe5                	j	ffffffffc02037e6 <find_vma+0x36>

ffffffffc02037f0 <do_pgfault>:
    if (mm == NULL)
ffffffffc02037f0:	c961                	beqz	a0,ffffffffc02038c0 <do_pgfault+0xd0>
{
ffffffffc02037f2:	7179                	addi	sp,sp,-48
    uintptr_t la = ROUNDDOWN(addr, PGSIZE);
ffffffffc02037f4:	77fd                	lui	a5,0xfffff
{
ffffffffc02037f6:	f022                	sd	s0,32(sp)
    uintptr_t la = ROUNDDOWN(addr, PGSIZE);
ffffffffc02037f8:	00f67433          	and	s0,a2,a5
    struct vma_struct *vma = find_vma(mm, la);
ffffffffc02037fc:	85a2                	mv	a1,s0
{
ffffffffc02037fe:	ec26                	sd	s1,24(sp)
ffffffffc0203800:	f406                	sd	ra,40(sp)
ffffffffc0203802:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, la);
ffffffffc0203804:	fadff0ef          	jal	ffffffffc02037b0 <find_vma>
    if (vma == NULL || la < vma->vm_start)
ffffffffc0203808:	c55d                	beqz	a0,ffffffffc02038b6 <do_pgfault+0xc6>
ffffffffc020380a:	651c                	ld	a5,8(a0)
ffffffffc020380c:	0af46563          	bltu	s0,a5,ffffffffc02038b6 <do_pgfault+0xc6>
    if (vma->vm_flags & VM_READ)
ffffffffc0203810:	4d1c                	lw	a5,24(a0)
ffffffffc0203812:	e84a                	sd	s2,16(sp)
        perm |= PTE_R;
ffffffffc0203814:	494d                	li	s2,19
    if (vma->vm_flags & VM_READ)
ffffffffc0203816:	0017f713          	andi	a4,a5,1
ffffffffc020381a:	cb15                	beqz	a4,ffffffffc020384e <do_pgfault+0x5e>
    if (vma->vm_flags & VM_WRITE)
ffffffffc020381c:	0027f713          	andi	a4,a5,2
ffffffffc0203820:	c311                	beqz	a4,ffffffffc0203824 <do_pgfault+0x34>
        perm |= (PTE_W | PTE_R);
ffffffffc0203822:	495d                	li	s2,23
    if (vma->vm_flags & VM_EXEC)
ffffffffc0203824:	8b91                	andi	a5,a5,4
ffffffffc0203826:	e38d                	bnez	a5,ffffffffc0203848 <do_pgfault+0x58>
    pte_t *ptep = get_pte(mm->pgdir, la, 1);
ffffffffc0203828:	6c88                	ld	a0,24(s1)
ffffffffc020382a:	4605                	li	a2,1
ffffffffc020382c:	85a2                	mv	a1,s0
ffffffffc020382e:	f6cfe0ef          	jal	ffffffffc0201f9a <get_pte>
    if (ptep == NULL)
ffffffffc0203832:	c541                	beqz	a0,ffffffffc02038ba <do_pgfault+0xca>
    if (*ptep & PTE_V)
ffffffffc0203834:	611c                	ld	a5,0(a0)
        return 0;
ffffffffc0203836:	4501                	li	a0,0
    if (*ptep & PTE_V)
ffffffffc0203838:	8b85                	andi	a5,a5,1
ffffffffc020383a:	cf99                	beqz	a5,ffffffffc0203858 <do_pgfault+0x68>
ffffffffc020383c:	6942                	ld	s2,16(sp)
}
ffffffffc020383e:	70a2                	ld	ra,40(sp)
ffffffffc0203840:	7402                	ld	s0,32(sp)
ffffffffc0203842:	64e2                	ld	s1,24(sp)
ffffffffc0203844:	6145                	addi	sp,sp,48
ffffffffc0203846:	8082                	ret
        perm |= PTE_X;
ffffffffc0203848:	00896913          	ori	s2,s2,8
ffffffffc020384c:	bff1                	j	ffffffffc0203828 <do_pgfault+0x38>
    if (vma->vm_flags & VM_WRITE)
ffffffffc020384e:	0027f713          	andi	a4,a5,2
    uint32_t perm = PTE_U | PTE_V;
ffffffffc0203852:	4945                	li	s2,17
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203854:	db61                	beqz	a4,ffffffffc0203824 <do_pgfault+0x34>
ffffffffc0203856:	b7f1                	j	ffffffffc0203822 <do_pgfault+0x32>
    struct Page *page = alloc_page();
ffffffffc0203858:	4505                	li	a0,1
ffffffffc020385a:	e98fe0ef          	jal	ffffffffc0201ef2 <alloc_pages>
    if (page == NULL)
ffffffffc020385e:	cd31                	beqz	a0,ffffffffc02038ba <do_pgfault+0xca>
    return page - pages + nbase;
ffffffffc0203860:	00098697          	auipc	a3,0x98
ffffffffc0203864:	0d86b683          	ld	a3,216(a3) # ffffffffc029b938 <pages>
ffffffffc0203868:	00004717          	auipc	a4,0x4
ffffffffc020386c:	24873703          	ld	a4,584(a4) # ffffffffc0207ab0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0203870:	00098617          	auipc	a2,0x98
ffffffffc0203874:	0c063603          	ld	a2,192(a2) # ffffffffc029b930 <npage>
    return page - pages + nbase;
ffffffffc0203878:	40d506b3          	sub	a3,a0,a3
ffffffffc020387c:	8699                	srai	a3,a3,0x6
ffffffffc020387e:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0203880:	00c69713          	slli	a4,a3,0xc
ffffffffc0203884:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203886:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203888:	02c77e63          	bgeu	a4,a2,ffffffffc02038c4 <do_pgfault+0xd4>
ffffffffc020388c:	e42a                	sd	a0,8(sp)
ffffffffc020388e:	00098517          	auipc	a0,0x98
ffffffffc0203892:	09a53503          	ld	a0,154(a0) # ffffffffc029b928 <va_pa_offset>
    memset(page2kva(page), 0, PGSIZE);
ffffffffc0203896:	6605                	lui	a2,0x1
ffffffffc0203898:	4581                	li	a1,0
ffffffffc020389a:	9536                	add	a0,a0,a3
ffffffffc020389c:	05c020ef          	jal	ffffffffc02058f8 <memset>
    return page_insert(mm->pgdir, page, la, perm);
ffffffffc02038a0:	8622                	mv	a2,s0
}
ffffffffc02038a2:	7402                	ld	s0,32(sp)
    return page_insert(mm->pgdir, page, la, perm);
ffffffffc02038a4:	65a2                	ld	a1,8(sp)
ffffffffc02038a6:	6c88                	ld	a0,24(s1)
}
ffffffffc02038a8:	70a2                	ld	ra,40(sp)
ffffffffc02038aa:	64e2                	ld	s1,24(sp)
    return page_insert(mm->pgdir, page, la, perm);
ffffffffc02038ac:	86ca                	mv	a3,s2
ffffffffc02038ae:	6942                	ld	s2,16(sp)
}
ffffffffc02038b0:	6145                	addi	sp,sp,48
    return page_insert(mm->pgdir, page, la, perm);
ffffffffc02038b2:	e1ffe06f          	j	ffffffffc02026d0 <page_insert>
        return ret;
ffffffffc02038b6:	5575                	li	a0,-3
ffffffffc02038b8:	b759                	j	ffffffffc020383e <do_pgfault+0x4e>
ffffffffc02038ba:	6942                	ld	s2,16(sp)
        return -E_NO_MEM;
ffffffffc02038bc:	5571                	li	a0,-4
ffffffffc02038be:	b741                	j	ffffffffc020383e <do_pgfault+0x4e>
        return ret;
ffffffffc02038c0:	5575                	li	a0,-3
}
ffffffffc02038c2:	8082                	ret
ffffffffc02038c4:	00003617          	auipc	a2,0x3
ffffffffc02038c8:	e3c60613          	addi	a2,a2,-452 # ffffffffc0206700 <etext+0xdde>
ffffffffc02038cc:	07100593          	li	a1,113
ffffffffc02038d0:	00003517          	auipc	a0,0x3
ffffffffc02038d4:	e5850513          	addi	a0,a0,-424 # ffffffffc0206728 <etext+0xe06>
ffffffffc02038d8:	b6ffc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02038dc <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038dc:	6590                	ld	a2,8(a1)
ffffffffc02038de:	0105b803          	ld	a6,16(a1)
{
ffffffffc02038e2:	1141                	addi	sp,sp,-16
ffffffffc02038e4:	e406                	sd	ra,8(sp)
ffffffffc02038e6:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038e8:	01066763          	bltu	a2,a6,ffffffffc02038f6 <insert_vma_struct+0x1a>
ffffffffc02038ec:	a8b9                	j	ffffffffc020394a <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02038ee:	fe87b703          	ld	a4,-24(a5) # ffffffffffffefe8 <end+0x3fd63688>
ffffffffc02038f2:	04e66763          	bltu	a2,a4,ffffffffc0203940 <insert_vma_struct+0x64>
ffffffffc02038f6:	86be                	mv	a3,a5
ffffffffc02038f8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02038fa:	fef51ae3          	bne	a0,a5,ffffffffc02038ee <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02038fe:	02a68463          	beq	a3,a0,ffffffffc0203926 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203902:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203906:	fe86b883          	ld	a7,-24(a3)
ffffffffc020390a:	08e8f063          	bgeu	a7,a4,ffffffffc020398a <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020390e:	04e66e63          	bltu	a2,a4,ffffffffc020396a <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc0203912:	00f50a63          	beq	a0,a5,ffffffffc0203926 <insert_vma_struct+0x4a>
ffffffffc0203916:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020391a:	05076863          	bltu	a4,a6,ffffffffc020396a <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020391e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203922:	02c77263          	bgeu	a4,a2,ffffffffc0203946 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203926:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203928:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020392a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020392e:	e390                	sd	a2,0(a5)
ffffffffc0203930:	e690                	sd	a2,8(a3)
}
ffffffffc0203932:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203934:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203936:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203938:	2705                	addiw	a4,a4,1
ffffffffc020393a:	d118                	sw	a4,32(a0)
}
ffffffffc020393c:	0141                	addi	sp,sp,16
ffffffffc020393e:	8082                	ret
    if (le_prev != list)
ffffffffc0203940:	fca691e3          	bne	a3,a0,ffffffffc0203902 <insert_vma_struct+0x26>
ffffffffc0203944:	bfd9                	j	ffffffffc020391a <insert_vma_struct+0x3e>
ffffffffc0203946:	e17ff0ef          	jal	ffffffffc020375c <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020394a:	00003697          	auipc	a3,0x3
ffffffffc020394e:	52668693          	addi	a3,a3,1318 # ffffffffc0206e70 <etext+0x154e>
ffffffffc0203952:	00003617          	auipc	a2,0x3
ffffffffc0203956:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020395a:	0ab00593          	li	a1,171
ffffffffc020395e:	00003517          	auipc	a0,0x3
ffffffffc0203962:	50250513          	addi	a0,a0,1282 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203966:	ae1fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020396a:	00003697          	auipc	a3,0x3
ffffffffc020396e:	54668693          	addi	a3,a3,1350 # ffffffffc0206eb0 <etext+0x158e>
ffffffffc0203972:	00003617          	auipc	a2,0x3
ffffffffc0203976:	9de60613          	addi	a2,a2,-1570 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020397a:	0a400593          	li	a1,164
ffffffffc020397e:	00003517          	auipc	a0,0x3
ffffffffc0203982:	4e250513          	addi	a0,a0,1250 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203986:	ac1fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020398a:	00003697          	auipc	a3,0x3
ffffffffc020398e:	50668693          	addi	a3,a3,1286 # ffffffffc0206e90 <etext+0x156e>
ffffffffc0203992:	00003617          	auipc	a2,0x3
ffffffffc0203996:	9be60613          	addi	a2,a2,-1602 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020399a:	0a300593          	li	a1,163
ffffffffc020399e:	00003517          	auipc	a0,0x3
ffffffffc02039a2:	4c250513          	addi	a0,a0,1218 # ffffffffc0206e60 <etext+0x153e>
ffffffffc02039a6:	aa1fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02039aa <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc02039aa:	591c                	lw	a5,48(a0)
{
ffffffffc02039ac:	1141                	addi	sp,sp,-16
ffffffffc02039ae:	e406                	sd	ra,8(sp)
ffffffffc02039b0:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02039b2:	e78d                	bnez	a5,ffffffffc02039dc <mm_destroy+0x32>
ffffffffc02039b4:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02039b6:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc02039b8:	00a40c63          	beq	s0,a0,ffffffffc02039d0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02039bc:	6118                	ld	a4,0(a0)
ffffffffc02039be:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc02039c0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02039c2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02039c4:	e398                	sd	a4,0(a5)
ffffffffc02039c6:	c10fe0ef          	jal	ffffffffc0201dd6 <kfree>
    return listelm->next;
ffffffffc02039ca:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02039cc:	fea418e3          	bne	s0,a0,ffffffffc02039bc <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc02039d0:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02039d2:	6402                	ld	s0,0(sp)
ffffffffc02039d4:	60a2                	ld	ra,8(sp)
ffffffffc02039d6:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02039d8:	bfefe06f          	j	ffffffffc0201dd6 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02039dc:	00003697          	auipc	a3,0x3
ffffffffc02039e0:	4f468693          	addi	a3,a3,1268 # ffffffffc0206ed0 <etext+0x15ae>
ffffffffc02039e4:	00003617          	auipc	a2,0x3
ffffffffc02039e8:	96c60613          	addi	a2,a2,-1684 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02039ec:	0cf00593          	li	a1,207
ffffffffc02039f0:	00003517          	auipc	a0,0x3
ffffffffc02039f4:	47050513          	addi	a0,a0,1136 # ffffffffc0206e60 <etext+0x153e>
ffffffffc02039f8:	a4ffc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02039fc <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02039fc:	6785                	lui	a5,0x1
ffffffffc02039fe:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7bf1>
ffffffffc0203a00:	963e                	add	a2,a2,a5
    if (!USER_ACCESS(start, end))
ffffffffc0203a02:	4785                	li	a5,1
{
ffffffffc0203a04:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203a06:	962e                	add	a2,a2,a1
ffffffffc0203a08:	787d                	lui	a6,0xfffff
    if (!USER_ACCESS(start, end))
ffffffffc0203a0a:	07fe                	slli	a5,a5,0x1f
{
ffffffffc0203a0c:	f822                	sd	s0,48(sp)
ffffffffc0203a0e:	f426                	sd	s1,40(sp)
ffffffffc0203a10:	01067433          	and	s0,a2,a6
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203a14:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc0203a18:	0785                	addi	a5,a5,1
ffffffffc0203a1a:	0084b633          	sltu	a2,s1,s0
ffffffffc0203a1e:	00f437b3          	sltu	a5,s0,a5
ffffffffc0203a22:	00163613          	seqz	a2,a2
ffffffffc0203a26:	0017b793          	seqz	a5,a5
{
ffffffffc0203a2a:	fc06                	sd	ra,56(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0203a2c:	8fd1                	or	a5,a5,a2
ffffffffc0203a2e:	ebbd                	bnez	a5,ffffffffc0203aa4 <mm_map+0xa8>
ffffffffc0203a30:	002007b7          	lui	a5,0x200
ffffffffc0203a34:	06f4e863          	bltu	s1,a5,ffffffffc0203aa4 <mm_map+0xa8>
ffffffffc0203a38:	f04a                	sd	s2,32(sp)
ffffffffc0203a3a:	ec4e                	sd	s3,24(sp)
ffffffffc0203a3c:	e852                	sd	s4,16(sp)
ffffffffc0203a3e:	892a                	mv	s2,a0
ffffffffc0203a40:	89ba                	mv	s3,a4
ffffffffc0203a42:	8a36                	mv	s4,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203a44:	c135                	beqz	a0,ffffffffc0203aa8 <mm_map+0xac>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203a46:	85a6                	mv	a1,s1
ffffffffc0203a48:	d69ff0ef          	jal	ffffffffc02037b0 <find_vma>
ffffffffc0203a4c:	c501                	beqz	a0,ffffffffc0203a54 <mm_map+0x58>
ffffffffc0203a4e:	651c                	ld	a5,8(a0)
ffffffffc0203a50:	0487e763          	bltu	a5,s0,ffffffffc0203a9e <mm_map+0xa2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a54:	03000513          	li	a0,48
ffffffffc0203a58:	ad8fe0ef          	jal	ffffffffc0201d30 <kmalloc>
ffffffffc0203a5c:	85aa                	mv	a1,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0203a5e:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0203a60:	c59d                	beqz	a1,ffffffffc0203a8e <mm_map+0x92>
        vma->vm_start = vm_start;
ffffffffc0203a62:	e584                	sd	s1,8(a1)
        vma->vm_end = vm_end;
ffffffffc0203a64:	e980                	sd	s0,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203a66:	0145ac23          	sw	s4,24(a1)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0203a6a:	854a                	mv	a0,s2
ffffffffc0203a6c:	e42e                	sd	a1,8(sp)
ffffffffc0203a6e:	e6fff0ef          	jal	ffffffffc02038dc <insert_vma_struct>
    if (vma_store != NULL)
ffffffffc0203a72:	65a2                	ld	a1,8(sp)
ffffffffc0203a74:	00098463          	beqz	s3,ffffffffc0203a7c <mm_map+0x80>
    {
        *vma_store = vma;
ffffffffc0203a78:	00b9b023          	sd	a1,0(s3)
ffffffffc0203a7c:	7902                	ld	s2,32(sp)
ffffffffc0203a7e:	69e2                	ld	s3,24(sp)
ffffffffc0203a80:	6a42                	ld	s4,16(sp)
    }
    ret = 0;
ffffffffc0203a82:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc0203a84:	70e2                	ld	ra,56(sp)
ffffffffc0203a86:	7442                	ld	s0,48(sp)
ffffffffc0203a88:	74a2                	ld	s1,40(sp)
ffffffffc0203a8a:	6121                	addi	sp,sp,64
ffffffffc0203a8c:	8082                	ret
ffffffffc0203a8e:	70e2                	ld	ra,56(sp)
ffffffffc0203a90:	7442                	ld	s0,48(sp)
ffffffffc0203a92:	7902                	ld	s2,32(sp)
ffffffffc0203a94:	69e2                	ld	s3,24(sp)
ffffffffc0203a96:	6a42                	ld	s4,16(sp)
ffffffffc0203a98:	74a2                	ld	s1,40(sp)
ffffffffc0203a9a:	6121                	addi	sp,sp,64
ffffffffc0203a9c:	8082                	ret
ffffffffc0203a9e:	7902                	ld	s2,32(sp)
ffffffffc0203aa0:	69e2                	ld	s3,24(sp)
ffffffffc0203aa2:	6a42                	ld	s4,16(sp)
        return -E_INVAL;
ffffffffc0203aa4:	5575                	li	a0,-3
ffffffffc0203aa6:	bff9                	j	ffffffffc0203a84 <mm_map+0x88>
    assert(mm != NULL);
ffffffffc0203aa8:	00003697          	auipc	a3,0x3
ffffffffc0203aac:	44068693          	addi	a3,a3,1088 # ffffffffc0206ee8 <etext+0x15c6>
ffffffffc0203ab0:	00003617          	auipc	a2,0x3
ffffffffc0203ab4:	8a060613          	addi	a2,a2,-1888 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203ab8:	0e400593          	li	a1,228
ffffffffc0203abc:	00003517          	auipc	a0,0x3
ffffffffc0203ac0:	3a450513          	addi	a0,a0,932 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203ac4:	983fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203ac8 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203ac8:	7139                	addi	sp,sp,-64
ffffffffc0203aca:	fc06                	sd	ra,56(sp)
ffffffffc0203acc:	f822                	sd	s0,48(sp)
ffffffffc0203ace:	f426                	sd	s1,40(sp)
ffffffffc0203ad0:	f04a                	sd	s2,32(sp)
ffffffffc0203ad2:	ec4e                	sd	s3,24(sp)
ffffffffc0203ad4:	e852                	sd	s4,16(sp)
ffffffffc0203ad6:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203ad8:	c525                	beqz	a0,ffffffffc0203b40 <dup_mmap+0x78>
ffffffffc0203ada:	892a                	mv	s2,a0
ffffffffc0203adc:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203ade:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203ae0:	c1a5                	beqz	a1,ffffffffc0203b40 <dup_mmap+0x78>
    return listelm->prev;
ffffffffc0203ae2:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203ae4:	04848c63          	beq	s1,s0,ffffffffc0203b3c <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ae8:	03000513          	li	a0,48
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203aec:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203af0:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203af4:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203af8:	a38fe0ef          	jal	ffffffffc0201d30 <kmalloc>
    if (vma != NULL)
ffffffffc0203afc:	c515                	beqz	a0,ffffffffc0203b28 <dup_mmap+0x60>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203afe:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0203b00:	01553423          	sd	s5,8(a0)
ffffffffc0203b04:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b08:	01352c23          	sw	s3,24(a0)
        insert_vma_struct(to, nvma);
ffffffffc0203b0c:	854a                	mv	a0,s2
ffffffffc0203b0e:	dcfff0ef          	jal	ffffffffc02038dc <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203b12:	ff043683          	ld	a3,-16(s0)
ffffffffc0203b16:	fe843603          	ld	a2,-24(s0)
ffffffffc0203b1a:	6c8c                	ld	a1,24(s1)
ffffffffc0203b1c:	01893503          	ld	a0,24(s2)
ffffffffc0203b20:	4701                	li	a4,0
ffffffffc0203b22:	8efff0ef          	jal	ffffffffc0203410 <copy_range>
ffffffffc0203b26:	dd55                	beqz	a0,ffffffffc0203ae2 <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0203b28:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203b2a:	70e2                	ld	ra,56(sp)
ffffffffc0203b2c:	7442                	ld	s0,48(sp)
ffffffffc0203b2e:	74a2                	ld	s1,40(sp)
ffffffffc0203b30:	7902                	ld	s2,32(sp)
ffffffffc0203b32:	69e2                	ld	s3,24(sp)
ffffffffc0203b34:	6a42                	ld	s4,16(sp)
ffffffffc0203b36:	6aa2                	ld	s5,8(sp)
ffffffffc0203b38:	6121                	addi	sp,sp,64
ffffffffc0203b3a:	8082                	ret
    return 0;
ffffffffc0203b3c:	4501                	li	a0,0
ffffffffc0203b3e:	b7f5                	j	ffffffffc0203b2a <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc0203b40:	00003697          	auipc	a3,0x3
ffffffffc0203b44:	3b868693          	addi	a3,a3,952 # ffffffffc0206ef8 <etext+0x15d6>
ffffffffc0203b48:	00003617          	auipc	a2,0x3
ffffffffc0203b4c:	80860613          	addi	a2,a2,-2040 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203b50:	10000593          	li	a1,256
ffffffffc0203b54:	00003517          	auipc	a0,0x3
ffffffffc0203b58:	30c50513          	addi	a0,a0,780 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203b5c:	8ebfc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203b60 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203b60:	1101                	addi	sp,sp,-32
ffffffffc0203b62:	ec06                	sd	ra,24(sp)
ffffffffc0203b64:	e822                	sd	s0,16(sp)
ffffffffc0203b66:	e426                	sd	s1,8(sp)
ffffffffc0203b68:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203b6a:	c531                	beqz	a0,ffffffffc0203bb6 <exit_mmap+0x56>
ffffffffc0203b6c:	591c                	lw	a5,48(a0)
ffffffffc0203b6e:	84aa                	mv	s1,a0
ffffffffc0203b70:	e3b9                	bnez	a5,ffffffffc0203bb6 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203b72:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203b74:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203b78:	02850663          	beq	a0,s0,ffffffffc0203ba4 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203b7c:	ff043603          	ld	a2,-16(s0)
ffffffffc0203b80:	fe843583          	ld	a1,-24(s0)
ffffffffc0203b84:	854a                	mv	a0,s2
ffffffffc0203b86:	ec6fe0ef          	jal	ffffffffc020224c <unmap_range>
ffffffffc0203b8a:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203b8c:	fe8498e3          	bne	s1,s0,ffffffffc0203b7c <exit_mmap+0x1c>
ffffffffc0203b90:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203b92:	00848c63          	beq	s1,s0,ffffffffc0203baa <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203b96:	ff043603          	ld	a2,-16(s0)
ffffffffc0203b9a:	fe843583          	ld	a1,-24(s0)
ffffffffc0203b9e:	854a                	mv	a0,s2
ffffffffc0203ba0:	fe0fe0ef          	jal	ffffffffc0202380 <exit_range>
ffffffffc0203ba4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203ba6:	fe8498e3          	bne	s1,s0,ffffffffc0203b96 <exit_mmap+0x36>
    }
}
ffffffffc0203baa:	60e2                	ld	ra,24(sp)
ffffffffc0203bac:	6442                	ld	s0,16(sp)
ffffffffc0203bae:	64a2                	ld	s1,8(sp)
ffffffffc0203bb0:	6902                	ld	s2,0(sp)
ffffffffc0203bb2:	6105                	addi	sp,sp,32
ffffffffc0203bb4:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203bb6:	00003697          	auipc	a3,0x3
ffffffffc0203bba:	36268693          	addi	a3,a3,866 # ffffffffc0206f18 <etext+0x15f6>
ffffffffc0203bbe:	00002617          	auipc	a2,0x2
ffffffffc0203bc2:	79260613          	addi	a2,a2,1938 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203bc6:	11900593          	li	a1,281
ffffffffc0203bca:	00003517          	auipc	a0,0x3
ffffffffc0203bce:	29650513          	addi	a0,a0,662 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203bd2:	875fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203bd6 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203bd6:	7179                	addi	sp,sp,-48
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203bd8:	04000513          	li	a0,64
{
ffffffffc0203bdc:	f406                	sd	ra,40(sp)
ffffffffc0203bde:	f022                	sd	s0,32(sp)
ffffffffc0203be0:	ec26                	sd	s1,24(sp)
ffffffffc0203be2:	e84a                	sd	s2,16(sp)
ffffffffc0203be4:	e44e                	sd	s3,8(sp)
ffffffffc0203be6:	e052                	sd	s4,0(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203be8:	948fe0ef          	jal	ffffffffc0201d30 <kmalloc>
    if (mm != NULL)
ffffffffc0203bec:	16050c63          	beqz	a0,ffffffffc0203d64 <vmm_init+0x18e>
ffffffffc0203bf0:	842a                	mv	s0,a0
    elm->prev = elm->next = elm;
ffffffffc0203bf2:	e508                	sd	a0,8(a0)
ffffffffc0203bf4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203bf6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203bfa:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203bfe:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203c02:	02053423          	sd	zero,40(a0)
ffffffffc0203c06:	02052823          	sw	zero,48(a0)
ffffffffc0203c0a:	02053c23          	sd	zero,56(a0)
ffffffffc0203c0e:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c12:	03000513          	li	a0,48
ffffffffc0203c16:	91afe0ef          	jal	ffffffffc0201d30 <kmalloc>
    if (vma != NULL)
ffffffffc0203c1a:	12050563          	beqz	a0,ffffffffc0203d44 <vmm_init+0x16e>
        vma->vm_end = vm_end;
ffffffffc0203c1e:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203c22:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203c24:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203c28:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203c2a:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0203c2c:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc0203c2e:	8522                	mv	a0,s0
ffffffffc0203c30:	cadff0ef          	jal	ffffffffc02038dc <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203c34:	fcf9                	bnez	s1,ffffffffc0203c12 <vmm_init+0x3c>
ffffffffc0203c36:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c3a:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c3e:	03000513          	li	a0,48
ffffffffc0203c42:	8eefe0ef          	jal	ffffffffc0201d30 <kmalloc>
    if (vma != NULL)
ffffffffc0203c46:	12050f63          	beqz	a0,ffffffffc0203d84 <vmm_init+0x1ae>
        vma->vm_end = vm_end;
ffffffffc0203c4a:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203c4e:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203c50:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203c54:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203c56:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c58:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc0203c5a:	8522                	mv	a0,s0
ffffffffc0203c5c:	c81ff0ef          	jal	ffffffffc02038dc <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c60:	fd249fe3          	bne	s1,s2,ffffffffc0203c3e <vmm_init+0x68>
    return listelm->next;
ffffffffc0203c64:	641c                	ld	a5,8(s0)
ffffffffc0203c66:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203c68:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203c6c:	1ef40c63          	beq	s0,a5,ffffffffc0203e64 <vmm_init+0x28e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c70:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f5e00>
ffffffffc0203c74:	ffe70693          	addi	a3,a4,-2
ffffffffc0203c78:	12d61663          	bne	a2,a3,ffffffffc0203da4 <vmm_init+0x1ce>
ffffffffc0203c7c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203c80:	12e69263          	bne	a3,a4,ffffffffc0203da4 <vmm_init+0x1ce>
    for (i = 1; i <= step2; i++)
ffffffffc0203c84:	0715                	addi	a4,a4,5
ffffffffc0203c86:	679c                	ld	a5,8(a5)
ffffffffc0203c88:	feb712e3          	bne	a4,a1,ffffffffc0203c6c <vmm_init+0x96>
ffffffffc0203c8c:	491d                	li	s2,7
ffffffffc0203c8e:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203c90:	85a6                	mv	a1,s1
ffffffffc0203c92:	8522                	mv	a0,s0
ffffffffc0203c94:	b1dff0ef          	jal	ffffffffc02037b0 <find_vma>
ffffffffc0203c98:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203c9a:	20050563          	beqz	a0,ffffffffc0203ea4 <vmm_init+0x2ce>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203c9e:	00148593          	addi	a1,s1,1
ffffffffc0203ca2:	8522                	mv	a0,s0
ffffffffc0203ca4:	b0dff0ef          	jal	ffffffffc02037b0 <find_vma>
ffffffffc0203ca8:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203caa:	1c050d63          	beqz	a0,ffffffffc0203e84 <vmm_init+0x2ae>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203cae:	85ca                	mv	a1,s2
ffffffffc0203cb0:	8522                	mv	a0,s0
ffffffffc0203cb2:	affff0ef          	jal	ffffffffc02037b0 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203cb6:	18051763          	bnez	a0,ffffffffc0203e44 <vmm_init+0x26e>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203cba:	00348593          	addi	a1,s1,3
ffffffffc0203cbe:	8522                	mv	a0,s0
ffffffffc0203cc0:	af1ff0ef          	jal	ffffffffc02037b0 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203cc4:	16051063          	bnez	a0,ffffffffc0203e24 <vmm_init+0x24e>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203cc8:	00448593          	addi	a1,s1,4
ffffffffc0203ccc:	8522                	mv	a0,s0
ffffffffc0203cce:	ae3ff0ef          	jal	ffffffffc02037b0 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203cd2:	12051963          	bnez	a0,ffffffffc0203e04 <vmm_init+0x22e>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203cd6:	008a3783          	ld	a5,8(s4)
ffffffffc0203cda:	10979563          	bne	a5,s1,ffffffffc0203de4 <vmm_init+0x20e>
ffffffffc0203cde:	010a3783          	ld	a5,16(s4)
ffffffffc0203ce2:	11279163          	bne	a5,s2,ffffffffc0203de4 <vmm_init+0x20e>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203ce6:	0089b783          	ld	a5,8(s3)
ffffffffc0203cea:	0c979d63          	bne	a5,s1,ffffffffc0203dc4 <vmm_init+0x1ee>
ffffffffc0203cee:	0109b783          	ld	a5,16(s3)
ffffffffc0203cf2:	0d279963          	bne	a5,s2,ffffffffc0203dc4 <vmm_init+0x1ee>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203cf6:	0495                	addi	s1,s1,5
ffffffffc0203cf8:	1f900793          	li	a5,505
ffffffffc0203cfc:	0915                	addi	s2,s2,5
ffffffffc0203cfe:	f8f499e3          	bne	s1,a5,ffffffffc0203c90 <vmm_init+0xba>
ffffffffc0203d02:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203d04:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203d06:	85a6                	mv	a1,s1
ffffffffc0203d08:	8522                	mv	a0,s0
ffffffffc0203d0a:	aa7ff0ef          	jal	ffffffffc02037b0 <find_vma>
        if (vma_below_5 != NULL)
ffffffffc0203d0e:	1a051b63          	bnez	a0,ffffffffc0203ec4 <vmm_init+0x2ee>
    for (i = 4; i >= 0; i--)
ffffffffc0203d12:	14fd                	addi	s1,s1,-1
ffffffffc0203d14:	ff2499e3          	bne	s1,s2,ffffffffc0203d06 <vmm_init+0x130>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc0203d18:	8522                	mv	a0,s0
ffffffffc0203d1a:	c91ff0ef          	jal	ffffffffc02039aa <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203d1e:	00003517          	auipc	a0,0x3
ffffffffc0203d22:	36a50513          	addi	a0,a0,874 # ffffffffc0207088 <etext+0x1766>
ffffffffc0203d26:	c6efc0ef          	jal	ffffffffc0200194 <cprintf>
}
ffffffffc0203d2a:	7402                	ld	s0,32(sp)
ffffffffc0203d2c:	70a2                	ld	ra,40(sp)
ffffffffc0203d2e:	64e2                	ld	s1,24(sp)
ffffffffc0203d30:	6942                	ld	s2,16(sp)
ffffffffc0203d32:	69a2                	ld	s3,8(sp)
ffffffffc0203d34:	6a02                	ld	s4,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d36:	00003517          	auipc	a0,0x3
ffffffffc0203d3a:	37250513          	addi	a0,a0,882 # ffffffffc02070a8 <etext+0x1786>
}
ffffffffc0203d3e:	6145                	addi	sp,sp,48
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d40:	c54fc06f          	j	ffffffffc0200194 <cprintf>
        assert(vma != NULL);
ffffffffc0203d44:	00003697          	auipc	a3,0x3
ffffffffc0203d48:	1f468693          	addi	a3,a3,500 # ffffffffc0206f38 <etext+0x1616>
ffffffffc0203d4c:	00002617          	auipc	a2,0x2
ffffffffc0203d50:	60460613          	addi	a2,a2,1540 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203d54:	15d00593          	li	a1,349
ffffffffc0203d58:	00003517          	auipc	a0,0x3
ffffffffc0203d5c:	10850513          	addi	a0,a0,264 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203d60:	ee6fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(mm != NULL);
ffffffffc0203d64:	00003697          	auipc	a3,0x3
ffffffffc0203d68:	18468693          	addi	a3,a3,388 # ffffffffc0206ee8 <etext+0x15c6>
ffffffffc0203d6c:	00002617          	auipc	a2,0x2
ffffffffc0203d70:	5e460613          	addi	a2,a2,1508 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203d74:	15500593          	li	a1,341
ffffffffc0203d78:	00003517          	auipc	a0,0x3
ffffffffc0203d7c:	0e850513          	addi	a0,a0,232 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203d80:	ec6fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma != NULL);
ffffffffc0203d84:	00003697          	auipc	a3,0x3
ffffffffc0203d88:	1b468693          	addi	a3,a3,436 # ffffffffc0206f38 <etext+0x1616>
ffffffffc0203d8c:	00002617          	auipc	a2,0x2
ffffffffc0203d90:	5c460613          	addi	a2,a2,1476 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203d94:	16400593          	li	a1,356
ffffffffc0203d98:	00003517          	auipc	a0,0x3
ffffffffc0203d9c:	0c850513          	addi	a0,a0,200 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203da0:	ea6fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203da4:	00003697          	auipc	a3,0x3
ffffffffc0203da8:	1bc68693          	addi	a3,a3,444 # ffffffffc0206f60 <etext+0x163e>
ffffffffc0203dac:	00002617          	auipc	a2,0x2
ffffffffc0203db0:	5a460613          	addi	a2,a2,1444 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203db4:	16e00593          	li	a1,366
ffffffffc0203db8:	00003517          	auipc	a0,0x3
ffffffffc0203dbc:	0a850513          	addi	a0,a0,168 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203dc0:	e86fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203dc4:	00003697          	auipc	a3,0x3
ffffffffc0203dc8:	25468693          	addi	a3,a3,596 # ffffffffc0207018 <etext+0x16f6>
ffffffffc0203dcc:	00002617          	auipc	a2,0x2
ffffffffc0203dd0:	58460613          	addi	a2,a2,1412 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203dd4:	18000593          	li	a1,384
ffffffffc0203dd8:	00003517          	auipc	a0,0x3
ffffffffc0203ddc:	08850513          	addi	a0,a0,136 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203de0:	e66fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203de4:	00003697          	auipc	a3,0x3
ffffffffc0203de8:	20468693          	addi	a3,a3,516 # ffffffffc0206fe8 <etext+0x16c6>
ffffffffc0203dec:	00002617          	auipc	a2,0x2
ffffffffc0203df0:	56460613          	addi	a2,a2,1380 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203df4:	17f00593          	li	a1,383
ffffffffc0203df8:	00003517          	auipc	a0,0x3
ffffffffc0203dfc:	06850513          	addi	a0,a0,104 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203e00:	e46fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma5 == NULL);
ffffffffc0203e04:	00003697          	auipc	a3,0x3
ffffffffc0203e08:	1d468693          	addi	a3,a3,468 # ffffffffc0206fd8 <etext+0x16b6>
ffffffffc0203e0c:	00002617          	auipc	a2,0x2
ffffffffc0203e10:	54460613          	addi	a2,a2,1348 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203e14:	17d00593          	li	a1,381
ffffffffc0203e18:	00003517          	auipc	a0,0x3
ffffffffc0203e1c:	04850513          	addi	a0,a0,72 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203e20:	e26fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma4 == NULL);
ffffffffc0203e24:	00003697          	auipc	a3,0x3
ffffffffc0203e28:	1a468693          	addi	a3,a3,420 # ffffffffc0206fc8 <etext+0x16a6>
ffffffffc0203e2c:	00002617          	auipc	a2,0x2
ffffffffc0203e30:	52460613          	addi	a2,a2,1316 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203e34:	17b00593          	li	a1,379
ffffffffc0203e38:	00003517          	auipc	a0,0x3
ffffffffc0203e3c:	02850513          	addi	a0,a0,40 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203e40:	e06fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma3 == NULL);
ffffffffc0203e44:	00003697          	auipc	a3,0x3
ffffffffc0203e48:	17468693          	addi	a3,a3,372 # ffffffffc0206fb8 <etext+0x1696>
ffffffffc0203e4c:	00002617          	auipc	a2,0x2
ffffffffc0203e50:	50460613          	addi	a2,a2,1284 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203e54:	17900593          	li	a1,377
ffffffffc0203e58:	00003517          	auipc	a0,0x3
ffffffffc0203e5c:	00850513          	addi	a0,a0,8 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203e60:	de6fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203e64:	00003697          	auipc	a3,0x3
ffffffffc0203e68:	0e468693          	addi	a3,a3,228 # ffffffffc0206f48 <etext+0x1626>
ffffffffc0203e6c:	00002617          	auipc	a2,0x2
ffffffffc0203e70:	4e460613          	addi	a2,a2,1252 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203e74:	16c00593          	li	a1,364
ffffffffc0203e78:	00003517          	auipc	a0,0x3
ffffffffc0203e7c:	fe850513          	addi	a0,a0,-24 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203e80:	dc6fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma2 != NULL);
ffffffffc0203e84:	00003697          	auipc	a3,0x3
ffffffffc0203e88:	12468693          	addi	a3,a3,292 # ffffffffc0206fa8 <etext+0x1686>
ffffffffc0203e8c:	00002617          	auipc	a2,0x2
ffffffffc0203e90:	4c460613          	addi	a2,a2,1220 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203e94:	17700593          	li	a1,375
ffffffffc0203e98:	00003517          	auipc	a0,0x3
ffffffffc0203e9c:	fc850513          	addi	a0,a0,-56 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203ea0:	da6fc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma1 != NULL);
ffffffffc0203ea4:	00003697          	auipc	a3,0x3
ffffffffc0203ea8:	0f468693          	addi	a3,a3,244 # ffffffffc0206f98 <etext+0x1676>
ffffffffc0203eac:	00002617          	auipc	a2,0x2
ffffffffc0203eb0:	4a460613          	addi	a2,a2,1188 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203eb4:	17500593          	li	a1,373
ffffffffc0203eb8:	00003517          	auipc	a0,0x3
ffffffffc0203ebc:	fa850513          	addi	a0,a0,-88 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203ec0:	d86fc0ef          	jal	ffffffffc0200446 <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203ec4:	6914                	ld	a3,16(a0)
ffffffffc0203ec6:	6510                	ld	a2,8(a0)
ffffffffc0203ec8:	0004859b          	sext.w	a1,s1
ffffffffc0203ecc:	00003517          	auipc	a0,0x3
ffffffffc0203ed0:	17c50513          	addi	a0,a0,380 # ffffffffc0207048 <etext+0x1726>
ffffffffc0203ed4:	ac0fc0ef          	jal	ffffffffc0200194 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203ed8:	00003697          	auipc	a3,0x3
ffffffffc0203edc:	19868693          	addi	a3,a3,408 # ffffffffc0207070 <etext+0x174e>
ffffffffc0203ee0:	00002617          	auipc	a2,0x2
ffffffffc0203ee4:	47060613          	addi	a2,a2,1136 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0203ee8:	18a00593          	li	a1,394
ffffffffc0203eec:	00003517          	auipc	a0,0x3
ffffffffc0203ef0:	f7450513          	addi	a0,a0,-140 # ffffffffc0206e60 <etext+0x153e>
ffffffffc0203ef4:	d52fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203ef8 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203ef8:	7179                	addi	sp,sp,-48
ffffffffc0203efa:	f022                	sd	s0,32(sp)
ffffffffc0203efc:	f406                	sd	ra,40(sp)
ffffffffc0203efe:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203f00:	c52d                	beqz	a0,ffffffffc0203f6a <user_mem_check+0x72>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203f02:	002007b7          	lui	a5,0x200
ffffffffc0203f06:	04f5ed63          	bltu	a1,a5,ffffffffc0203f60 <user_mem_check+0x68>
ffffffffc0203f0a:	ec26                	sd	s1,24(sp)
ffffffffc0203f0c:	00c584b3          	add	s1,a1,a2
ffffffffc0203f10:	0695ff63          	bgeu	a1,s1,ffffffffc0203f8e <user_mem_check+0x96>
ffffffffc0203f14:	4785                	li	a5,1
ffffffffc0203f16:	07fe                	slli	a5,a5,0x1f
ffffffffc0203f18:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_exit_out_size+0x1f5e19>
ffffffffc0203f1a:	06f4fa63          	bgeu	s1,a5,ffffffffc0203f8e <user_mem_check+0x96>
ffffffffc0203f1e:	e84a                	sd	s2,16(sp)
ffffffffc0203f20:	e44e                	sd	s3,8(sp)
ffffffffc0203f22:	8936                	mv	s2,a3
ffffffffc0203f24:	89aa                	mv	s3,a0
ffffffffc0203f26:	a829                	j	ffffffffc0203f40 <user_mem_check+0x48>
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203f28:	6685                	lui	a3,0x1
ffffffffc0203f2a:	9736                	add	a4,a4,a3
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203f2c:	0027f693          	andi	a3,a5,2
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203f30:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203f32:	c685                	beqz	a3,ffffffffc0203f5a <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203f34:	c399                	beqz	a5,ffffffffc0203f3a <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203f36:	02e46263          	bltu	s0,a4,ffffffffc0203f5a <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203f3a:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203f3c:	04947b63          	bgeu	s0,s1,ffffffffc0203f92 <user_mem_check+0x9a>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203f40:	85a2                	mv	a1,s0
ffffffffc0203f42:	854e                	mv	a0,s3
ffffffffc0203f44:	86dff0ef          	jal	ffffffffc02037b0 <find_vma>
ffffffffc0203f48:	c909                	beqz	a0,ffffffffc0203f5a <user_mem_check+0x62>
ffffffffc0203f4a:	6518                	ld	a4,8(a0)
ffffffffc0203f4c:	00e46763          	bltu	s0,a4,ffffffffc0203f5a <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203f50:	4d1c                	lw	a5,24(a0)
ffffffffc0203f52:	fc091be3          	bnez	s2,ffffffffc0203f28 <user_mem_check+0x30>
ffffffffc0203f56:	8b85                	andi	a5,a5,1
ffffffffc0203f58:	f3ed                	bnez	a5,ffffffffc0203f3a <user_mem_check+0x42>
ffffffffc0203f5a:	64e2                	ld	s1,24(sp)
ffffffffc0203f5c:	6942                	ld	s2,16(sp)
ffffffffc0203f5e:	69a2                	ld	s3,8(sp)
            return 0;
ffffffffc0203f60:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203f62:	70a2                	ld	ra,40(sp)
ffffffffc0203f64:	7402                	ld	s0,32(sp)
ffffffffc0203f66:	6145                	addi	sp,sp,48
ffffffffc0203f68:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203f6a:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f6e:	fef5eae3          	bltu	a1,a5,ffffffffc0203f62 <user_mem_check+0x6a>
ffffffffc0203f72:	c80007b7          	lui	a5,0xc8000
ffffffffc0203f76:	962e                	add	a2,a2,a1
ffffffffc0203f78:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d646a1>
ffffffffc0203f7a:	00c5b433          	sltu	s0,a1,a2
ffffffffc0203f7e:	00f63633          	sltu	a2,a2,a5
ffffffffc0203f82:	70a2                	ld	ra,40(sp)
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203f84:	00867533          	and	a0,a2,s0
ffffffffc0203f88:	7402                	ld	s0,32(sp)
ffffffffc0203f8a:	6145                	addi	sp,sp,48
ffffffffc0203f8c:	8082                	ret
ffffffffc0203f8e:	64e2                	ld	s1,24(sp)
ffffffffc0203f90:	bfc1                	j	ffffffffc0203f60 <user_mem_check+0x68>
ffffffffc0203f92:	64e2                	ld	s1,24(sp)
ffffffffc0203f94:	6942                	ld	s2,16(sp)
ffffffffc0203f96:	69a2                	ld	s3,8(sp)
        return 1;
ffffffffc0203f98:	4505                	li	a0,1
ffffffffc0203f9a:	b7e1                	j	ffffffffc0203f62 <user_mem_check+0x6a>

ffffffffc0203f9c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203f9c:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203f9e:	9402                	jalr	s0

	jal do_exit
ffffffffc0203fa0:	5fa000ef          	jal	ffffffffc020459a <do_exit>

ffffffffc0203fa4 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203fa4:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fa6:	10800513          	li	a0,264
{
ffffffffc0203faa:	e022                	sd	s0,0(sp)
ffffffffc0203fac:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fae:	d83fd0ef          	jal	ffffffffc0201d30 <kmalloc>
ffffffffc0203fb2:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203fb4:	cd21                	beqz	a0,ffffffffc020400c <alloc_proc+0x68>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->state = PROC_UNINIT;
ffffffffc0203fb6:	57fd                	li	a5,-1
ffffffffc0203fb8:	1782                	slli	a5,a5,0x20
ffffffffc0203fba:	e11c                	sd	a5,0(a0)
        
        // 初始化进程ID为无效值
        proc->pid = -1;
        
        // 初始化运行次数为0
        proc->runs = 0;
ffffffffc0203fbc:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0203fc0:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0203fc4:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0203fc8:	02053023          	sd	zero,32(a0)
        
        // 初始化内存管理结构为NULL
        proc->mm = NULL;
ffffffffc0203fcc:	02053423          	sd	zero,40(a0)
        
        // 初始化上下文结构（全部置0）
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203fd0:	07000613          	li	a2,112
ffffffffc0203fd4:	4581                	li	a1,0
ffffffffc0203fd6:	03050513          	addi	a0,a0,48
ffffffffc0203fda:	11f010ef          	jal	ffffffffc02058f8 <memset>
        
        // 初始化陷阱帧指针为NULL
        proc->tf = NULL;
        
        // 初始化页目录表基址
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fde:	00098797          	auipc	a5,0x98
ffffffffc0203fe2:	93a7b783          	ld	a5,-1734(a5) # ffffffffc029b918 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc0203fe6:	0a043023          	sd	zero,160(s0)
        
        // 初始化进程标志为0
        proc->flags = 0;
ffffffffc0203fea:	0a042823          	sw	zero,176(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fee:	f45c                	sd	a5,168(s0)
        
        // 初始化进程名称为空字符串
        memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0203ff0:	0b440513          	addi	a0,s0,180
ffffffffc0203ff4:	4641                	li	a2,16
ffffffffc0203ff6:	4581                	li	a1,0
ffffffffc0203ff8:	101010ef          	jal	ffffffffc02058f8 <memset>

        proc->exit_code = 0;
ffffffffc0203ffc:	0e043423          	sd	zero,232(s0)
        proc->wait_state = 0;
        proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204000:	0e043823          	sd	zero,240(s0)
ffffffffc0204004:	0e043c23          	sd	zero,248(s0)
ffffffffc0204008:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc020400c:	60a2                	ld	ra,8(sp)
ffffffffc020400e:	8522                	mv	a0,s0
ffffffffc0204010:	6402                	ld	s0,0(sp)
ffffffffc0204012:	0141                	addi	sp,sp,16
ffffffffc0204014:	8082                	ret

ffffffffc0204016 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204016:	00098797          	auipc	a5,0x98
ffffffffc020401a:	9327b783          	ld	a5,-1742(a5) # ffffffffc029b948 <current>
ffffffffc020401e:	73c8                	ld	a0,160(a5)
ffffffffc0204020:	ef7fc06f          	j	ffffffffc0200f16 <forkrets>

ffffffffc0204024 <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204024:	00098797          	auipc	a5,0x98
ffffffffc0204028:	9247b783          	ld	a5,-1756(a5) # ffffffffc029b948 <current>
{
ffffffffc020402c:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc020402e:	00003617          	auipc	a2,0x3
ffffffffc0204032:	09260613          	addi	a2,a2,146 # ffffffffc02070c0 <etext+0x179e>
ffffffffc0204036:	43cc                	lw	a1,4(a5)
ffffffffc0204038:	00003517          	auipc	a0,0x3
ffffffffc020403c:	09850513          	addi	a0,a0,152 # ffffffffc02070d0 <etext+0x17ae>
{
ffffffffc0204040:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204042:	952fc0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0204046:	3fe06797          	auipc	a5,0x3fe06
ffffffffc020404a:	8ba78793          	addi	a5,a5,-1862 # 9900 <_binary_obj___user_forktest_out_size>
ffffffffc020404e:	e43e                	sd	a5,8(sp)
kernel_execve(const char *name, unsigned char *binary, size_t size)
ffffffffc0204050:	00003517          	auipc	a0,0x3
ffffffffc0204054:	07050513          	addi	a0,a0,112 # ffffffffc02070c0 <etext+0x179e>
ffffffffc0204058:	0003f797          	auipc	a5,0x3f
ffffffffc020405c:	72078793          	addi	a5,a5,1824 # ffffffffc0243778 <_binary_obj___user_forktest_out_start>
ffffffffc0204060:	f03e                	sd	a5,32(sp)
ffffffffc0204062:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204064:	e802                	sd	zero,16(sp)
ffffffffc0204066:	7de010ef          	jal	ffffffffc0205844 <strlen>
ffffffffc020406a:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc020406c:	4511                	li	a0,4
ffffffffc020406e:	55a2                	lw	a1,40(sp)
ffffffffc0204070:	4662                	lw	a2,24(sp)
ffffffffc0204072:	5682                	lw	a3,32(sp)
ffffffffc0204074:	4722                	lw	a4,8(sp)
ffffffffc0204076:	48a9                	li	a7,10
ffffffffc0204078:	9002                	ebreak
ffffffffc020407a:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc020407c:	65c2                	ld	a1,16(sp)
ffffffffc020407e:	00003517          	auipc	a0,0x3
ffffffffc0204082:	07a50513          	addi	a0,a0,122 # ffffffffc02070f8 <etext+0x17d6>
ffffffffc0204086:	90efc0ef          	jal	ffffffffc0200194 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc020408a:	00003617          	auipc	a2,0x3
ffffffffc020408e:	07e60613          	addi	a2,a2,126 # ffffffffc0207108 <etext+0x17e6>
ffffffffc0204092:	3d400593          	li	a1,980
ffffffffc0204096:	00003517          	auipc	a0,0x3
ffffffffc020409a:	09250513          	addi	a0,a0,146 # ffffffffc0207128 <etext+0x1806>
ffffffffc020409e:	ba8fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02040a2 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc02040a2:	6d14                	ld	a3,24(a0)
{
ffffffffc02040a4:	1141                	addi	sp,sp,-16
ffffffffc02040a6:	e406                	sd	ra,8(sp)
ffffffffc02040a8:	c02007b7          	lui	a5,0xc0200
ffffffffc02040ac:	02f6ee63          	bltu	a3,a5,ffffffffc02040e8 <put_pgdir+0x46>
ffffffffc02040b0:	00098717          	auipc	a4,0x98
ffffffffc02040b4:	87873703          	ld	a4,-1928(a4) # ffffffffc029b928 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc02040b8:	00098797          	auipc	a5,0x98
ffffffffc02040bc:	8787b783          	ld	a5,-1928(a5) # ffffffffc029b930 <npage>
    return pa2page(PADDR(kva));
ffffffffc02040c0:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02040c2:	82b1                	srli	a3,a3,0xc
ffffffffc02040c4:	02f6fe63          	bgeu	a3,a5,ffffffffc0204100 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02040c8:	00004797          	auipc	a5,0x4
ffffffffc02040cc:	9e87b783          	ld	a5,-1560(a5) # ffffffffc0207ab0 <nbase>
ffffffffc02040d0:	00098517          	auipc	a0,0x98
ffffffffc02040d4:	86853503          	ld	a0,-1944(a0) # ffffffffc029b938 <pages>
}
ffffffffc02040d8:	60a2                	ld	ra,8(sp)
ffffffffc02040da:	8e9d                	sub	a3,a3,a5
ffffffffc02040dc:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02040de:	4585                	li	a1,1
ffffffffc02040e0:	9536                	add	a0,a0,a3
}
ffffffffc02040e2:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02040e4:	e49fd06f          	j	ffffffffc0201f2c <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02040e8:	00002617          	auipc	a2,0x2
ffffffffc02040ec:	6c060613          	addi	a2,a2,1728 # ffffffffc02067a8 <etext+0xe86>
ffffffffc02040f0:	07700593          	li	a1,119
ffffffffc02040f4:	00002517          	auipc	a0,0x2
ffffffffc02040f8:	63450513          	addi	a0,a0,1588 # ffffffffc0206728 <etext+0xe06>
ffffffffc02040fc:	b4afc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204100:	00002617          	auipc	a2,0x2
ffffffffc0204104:	6d060613          	addi	a2,a2,1744 # ffffffffc02067d0 <etext+0xeae>
ffffffffc0204108:	06900593          	li	a1,105
ffffffffc020410c:	00002517          	auipc	a0,0x2
ffffffffc0204110:	61c50513          	addi	a0,a0,1564 # ffffffffc0206728 <etext+0xe06>
ffffffffc0204114:	b32fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204118 <proc_run>:
    if (proc != current)
ffffffffc0204118:	00098697          	auipc	a3,0x98
ffffffffc020411c:	8306b683          	ld	a3,-2000(a3) # ffffffffc029b948 <current>
ffffffffc0204120:	04a68463          	beq	a3,a0,ffffffffc0204168 <proc_run+0x50>
{
ffffffffc0204124:	1101                	addi	sp,sp,-32
ffffffffc0204126:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204128:	100027f3          	csrr	a5,sstatus
ffffffffc020412c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020412e:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204130:	ef8d                	bnez	a5,ffffffffc020416a <proc_run+0x52>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0204132:	755c                	ld	a5,168(a0)
ffffffffc0204134:	577d                	li	a4,-1
ffffffffc0204136:	177e                	slli	a4,a4,0x3f
ffffffffc0204138:	83b1                	srli	a5,a5,0xc
ffffffffc020413a:	e032                	sd	a2,0(sp)
        current = proc;
ffffffffc020413c:	00098597          	auipc	a1,0x98
ffffffffc0204140:	80a5b623          	sd	a0,-2036(a1) # ffffffffc029b948 <current>
ffffffffc0204144:	8fd9                	or	a5,a5,a4
ffffffffc0204146:	18079073          	csrw	satp,a5
        switch_to(&prev->context, &proc->context);
ffffffffc020414a:	03050593          	addi	a1,a0,48
ffffffffc020414e:	03068513          	addi	a0,a3,48
ffffffffc0204152:	0aa010ef          	jal	ffffffffc02051fc <switch_to>
    if (flag)
ffffffffc0204156:	6602                	ld	a2,0(sp)
ffffffffc0204158:	e601                	bnez	a2,ffffffffc0204160 <proc_run+0x48>
}
ffffffffc020415a:	60e2                	ld	ra,24(sp)
ffffffffc020415c:	6105                	addi	sp,sp,32
ffffffffc020415e:	8082                	ret
ffffffffc0204160:	60e2                	ld	ra,24(sp)
ffffffffc0204162:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204164:	f9afc06f          	j	ffffffffc02008fe <intr_enable>
ffffffffc0204168:	8082                	ret
ffffffffc020416a:	e42a                	sd	a0,8(sp)
ffffffffc020416c:	e036                	sd	a3,0(sp)
        intr_disable();
ffffffffc020416e:	f96fc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0204172:	6522                	ld	a0,8(sp)
ffffffffc0204174:	6682                	ld	a3,0(sp)
ffffffffc0204176:	4605                	li	a2,1
ffffffffc0204178:	bf6d                	j	ffffffffc0204132 <proc_run+0x1a>

ffffffffc020417a <do_fork>:
    if (nr_process >= MAX_PROCESS)
ffffffffc020417a:	00097797          	auipc	a5,0x97
ffffffffc020417e:	7c67a783          	lw	a5,1990(a5) # ffffffffc029b940 <nr_process>
{
ffffffffc0204182:	7119                	addi	sp,sp,-128
ffffffffc0204184:	ecce                	sd	s3,88(sp)
ffffffffc0204186:	fc86                	sd	ra,120(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204188:	6985                	lui	s3,0x1
ffffffffc020418a:	3537d163          	bge	a5,s3,ffffffffc02044cc <do_fork+0x352>
ffffffffc020418e:	f8a2                	sd	s0,112(sp)
ffffffffc0204190:	f4a6                	sd	s1,104(sp)
ffffffffc0204192:	f0ca                	sd	s2,96(sp)
ffffffffc0204194:	ec6e                	sd	s11,24(sp)
ffffffffc0204196:	892e                	mv	s2,a1
ffffffffc0204198:	84b2                	mv	s1,a2
ffffffffc020419a:	8daa                	mv	s11,a0
    if ((proc = alloc_proc()) == NULL) {
ffffffffc020419c:	e09ff0ef          	jal	ffffffffc0203fa4 <alloc_proc>
ffffffffc02041a0:	842a                	mv	s0,a0
ffffffffc02041a2:	30050163          	beqz	a0,ffffffffc02044a4 <do_fork+0x32a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02041a6:	4509                	li	a0,2
ffffffffc02041a8:	d4bfd0ef          	jal	ffffffffc0201ef2 <alloc_pages>
    if (page != NULL)
ffffffffc02041ac:	2e050963          	beqz	a0,ffffffffc020449e <do_fork+0x324>
ffffffffc02041b0:	e8d2                	sd	s4,80(sp)
    return page - pages + nbase;
ffffffffc02041b2:	00097a17          	auipc	s4,0x97
ffffffffc02041b6:	786a0a13          	addi	s4,s4,1926 # ffffffffc029b938 <pages>
ffffffffc02041ba:	000a3783          	ld	a5,0(s4)
ffffffffc02041be:	e4d6                	sd	s5,72(sp)
ffffffffc02041c0:	00004a97          	auipc	s5,0x4
ffffffffc02041c4:	8f0a8a93          	addi	s5,s5,-1808 # ffffffffc0207ab0 <nbase>
ffffffffc02041c8:	000ab703          	ld	a4,0(s5)
ffffffffc02041cc:	40f506b3          	sub	a3,a0,a5
ffffffffc02041d0:	e0da                	sd	s6,64(sp)
    return KADDR(page2pa(page));
ffffffffc02041d2:	00097b17          	auipc	s6,0x97
ffffffffc02041d6:	75eb0b13          	addi	s6,s6,1886 # ffffffffc029b930 <npage>
ffffffffc02041da:	f06a                	sd	s10,32(sp)
    return page - pages + nbase;
ffffffffc02041dc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02041de:	5d7d                	li	s10,-1
ffffffffc02041e0:	000b3783          	ld	a5,0(s6)
    return page - pages + nbase;
ffffffffc02041e4:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02041e6:	00cd5d13          	srli	s10,s10,0xc
ffffffffc02041ea:	01a6f633          	and	a2,a3,s10
ffffffffc02041ee:	fc5e                	sd	s7,56(sp)
ffffffffc02041f0:	f862                	sd	s8,48(sp)
ffffffffc02041f2:	f466                	sd	s9,40(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc02041f4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02041f6:	2ef67963          	bgeu	a2,a5,ffffffffc02044e8 <do_fork+0x36e>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02041fa:	00097c17          	auipc	s8,0x97
ffffffffc02041fe:	74ec0c13          	addi	s8,s8,1870 # ffffffffc029b948 <current>
ffffffffc0204202:	000c3803          	ld	a6,0(s8)
ffffffffc0204206:	00097b97          	auipc	s7,0x97
ffffffffc020420a:	722b8b93          	addi	s7,s7,1826 # ffffffffc029b928 <va_pa_offset>
ffffffffc020420e:	000bb783          	ld	a5,0(s7)
ffffffffc0204212:	02883c83          	ld	s9,40(a6) # fffffffffffff028 <end+0x3fd636c8>
ffffffffc0204216:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204218:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc020421a:	020c8a63          	beqz	s9,ffffffffc020424e <do_fork+0xd4>
    if (clone_flags & CLONE_VM)
ffffffffc020421e:	100df793          	andi	a5,s11,256
ffffffffc0204222:	1a078063          	beqz	a5,ffffffffc02043c2 <do_fork+0x248>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204226:	030ca703          	lw	a4,48(s9)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020422a:	018cb783          	ld	a5,24(s9)
ffffffffc020422e:	c02006b7          	lui	a3,0xc0200
ffffffffc0204232:	2705                	addiw	a4,a4,1
ffffffffc0204234:	02eca823          	sw	a4,48(s9)
    proc->mm = mm;
ffffffffc0204238:	03943423          	sd	s9,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020423c:	2cd7ee63          	bltu	a5,a3,ffffffffc0204518 <do_fork+0x39e>
ffffffffc0204240:	000bb703          	ld	a4,0(s7)
    current->wait_state = 0;
ffffffffc0204244:	000c3803          	ld	a6,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204248:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020424a:	8f99                	sub	a5,a5,a4
ffffffffc020424c:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020424e:	6789                	lui	a5,0x2
ffffffffc0204250:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6d10>
ffffffffc0204254:	96be                	add	a3,a3,a5
ffffffffc0204256:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204258:	87b6                	mv	a5,a3
ffffffffc020425a:	12048713          	addi	a4,s1,288
ffffffffc020425e:	6890                	ld	a2,16(s1)
ffffffffc0204260:	6088                	ld	a0,0(s1)
ffffffffc0204262:	648c                	ld	a1,8(s1)
ffffffffc0204264:	eb90                	sd	a2,16(a5)
ffffffffc0204266:	e388                	sd	a0,0(a5)
ffffffffc0204268:	e78c                	sd	a1,8(a5)
ffffffffc020426a:	6c90                	ld	a2,24(s1)
ffffffffc020426c:	02048493          	addi	s1,s1,32
ffffffffc0204270:	02078793          	addi	a5,a5,32
ffffffffc0204274:	fec7bc23          	sd	a2,-8(a5)
ffffffffc0204278:	fee493e3          	bne	s1,a4,ffffffffc020425e <do_fork+0xe4>
    proc->tf->gpr.a0 = 0;
ffffffffc020427c:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204280:	22090863          	beqz	s2,ffffffffc02044b0 <do_fork+0x336>
    if (++last_pid >= MAX_PID)
ffffffffc0204284:	00093597          	auipc	a1,0x93
ffffffffc0204288:	2305a583          	lw	a1,560(a1) # ffffffffc02974b4 <last_pid.1>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020428c:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204290:	00000797          	auipc	a5,0x0
ffffffffc0204294:	d8678793          	addi	a5,a5,-634 # ffffffffc0204016 <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc0204298:	2585                	addiw	a1,a1,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020429a:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020429c:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc020429e:	00093717          	auipc	a4,0x93
ffffffffc02042a2:	20b72b23          	sw	a1,534(a4) # ffffffffc02974b4 <last_pid.1>
ffffffffc02042a6:	6789                	lui	a5,0x2
ffffffffc02042a8:	20f5d663          	bge	a1,a5,ffffffffc02044b4 <do_fork+0x33a>
    if (last_pid >= next_safe)
ffffffffc02042ac:	00093797          	auipc	a5,0x93
ffffffffc02042b0:	2047a783          	lw	a5,516(a5) # ffffffffc02974b0 <next_safe.0>
ffffffffc02042b4:	00097497          	auipc	s1,0x97
ffffffffc02042b8:	61c48493          	addi	s1,s1,1564 # ffffffffc029b8d0 <proc_list>
ffffffffc02042bc:	06f5c563          	blt	a1,a5,ffffffffc0204326 <do_fork+0x1ac>
ffffffffc02042c0:	00097497          	auipc	s1,0x97
ffffffffc02042c4:	61048493          	addi	s1,s1,1552 # ffffffffc029b8d0 <proc_list>
ffffffffc02042c8:	0084b303          	ld	t1,8(s1)
        next_safe = MAX_PID;
ffffffffc02042cc:	6789                	lui	a5,0x2
ffffffffc02042ce:	00093717          	auipc	a4,0x93
ffffffffc02042d2:	1ef72123          	sw	a5,482(a4) # ffffffffc02974b0 <next_safe.0>
ffffffffc02042d6:	86ae                	mv	a3,a1
ffffffffc02042d8:	4501                	li	a0,0
        while ((le = list_next(le)) != list)
ffffffffc02042da:	04930063          	beq	t1,s1,ffffffffc020431a <do_fork+0x1a0>
ffffffffc02042de:	88aa                	mv	a7,a0
ffffffffc02042e0:	879a                	mv	a5,t1
ffffffffc02042e2:	6609                	lui	a2,0x2
ffffffffc02042e4:	a811                	j	ffffffffc02042f8 <do_fork+0x17e>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042e6:	00e6d663          	bge	a3,a4,ffffffffc02042f2 <do_fork+0x178>
ffffffffc02042ea:	00c75463          	bge	a4,a2,ffffffffc02042f2 <do_fork+0x178>
                next_safe = proc->pid;
ffffffffc02042ee:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042f0:	4885                	li	a7,1
ffffffffc02042f2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02042f4:	00978d63          	beq	a5,s1,ffffffffc020430e <do_fork+0x194>
            if (proc->pid == last_pid)
ffffffffc02042f8:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x6cb4>
ffffffffc02042fc:	fed715e3          	bne	a4,a3,ffffffffc02042e6 <do_fork+0x16c>
                if (++last_pid >= next_safe)
ffffffffc0204300:	2685                	addiw	a3,a3,1
ffffffffc0204302:	1ac6df63          	bge	a3,a2,ffffffffc02044c0 <do_fork+0x346>
ffffffffc0204306:	679c                	ld	a5,8(a5)
ffffffffc0204308:	4505                	li	a0,1
        while ((le = list_next(le)) != list)
ffffffffc020430a:	fe9797e3          	bne	a5,s1,ffffffffc02042f8 <do_fork+0x17e>
ffffffffc020430e:	00088663          	beqz	a7,ffffffffc020431a <do_fork+0x1a0>
ffffffffc0204312:	00093797          	auipc	a5,0x93
ffffffffc0204316:	18c7af23          	sw	a2,414(a5) # ffffffffc02974b0 <next_safe.0>
ffffffffc020431a:	c511                	beqz	a0,ffffffffc0204326 <do_fork+0x1ac>
ffffffffc020431c:	00093797          	auipc	a5,0x93
ffffffffc0204320:	18d7ac23          	sw	a3,408(a5) # ffffffffc02974b4 <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204324:	85b6                	mv	a1,a3
    proc->pid = get_pid();
ffffffffc0204326:	c04c                	sw	a1,4(s0)
    current->wait_state = 0;
ffffffffc0204328:	0e082623          	sw	zero,236(a6)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020432c:	4048                	lw	a0,4(s0)
    proc->parent = current;
ffffffffc020432e:	03043023          	sd	a6,32(s0)
    proc->wait_state = 0;
ffffffffc0204332:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204336:	10043023          	sd	zero,256(s0)
ffffffffc020433a:	0e043c23          	sd	zero,248(s0)
ffffffffc020433e:	0e043823          	sd	zero,240(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204342:	45a9                	li	a1,10
ffffffffc0204344:	11e010ef          	jal	ffffffffc0205462 <hash32>
ffffffffc0204348:	02051793          	slli	a5,a0,0x20
ffffffffc020434c:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204350:	00093797          	auipc	a5,0x93
ffffffffc0204354:	58078793          	addi	a5,a5,1408 # ffffffffc02978d0 <hash_list>
ffffffffc0204358:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020435a:	6518                	ld	a4,8(a0)
ffffffffc020435c:	0d840793          	addi	a5,s0,216
ffffffffc0204360:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0204362:	e31c                	sd	a5,0(a4)
ffffffffc0204364:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204366:	f078                	sd	a4,224(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204368:	0c840793          	addi	a5,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020436c:	7018                	ld	a4,32(s0)
    elm->prev = prev;
ffffffffc020436e:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204370:	e21c                	sd	a5,0(a2)
    proc->yptr = NULL;
ffffffffc0204372:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204376:	7b74                	ld	a3,240(a4)
ffffffffc0204378:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc020437a:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc020437c:	e464                	sd	s1,200(s0)
ffffffffc020437e:	10d43023          	sd	a3,256(s0)
ffffffffc0204382:	c299                	beqz	a3,ffffffffc0204388 <do_fork+0x20e>
        proc->optr->yptr = proc;
ffffffffc0204384:	fee0                	sd	s0,248(a3)
    proc->parent->cptr = proc;
ffffffffc0204386:	7018                	ld	a4,32(s0)
    nr_process++;
ffffffffc0204388:	00097797          	auipc	a5,0x97
ffffffffc020438c:	5b87a783          	lw	a5,1464(a5) # ffffffffc029b940 <nr_process>
    proc->parent->cptr = proc;
ffffffffc0204390:	fb60                	sd	s0,240(a4)
    wakeup_proc(proc);
ffffffffc0204392:	8522                	mv	a0,s0
    nr_process++;
ffffffffc0204394:	2785                	addiw	a5,a5,1
ffffffffc0204396:	00097717          	auipc	a4,0x97
ffffffffc020439a:	5af72523          	sw	a5,1450(a4) # ffffffffc029b940 <nr_process>
    wakeup_proc(proc);
ffffffffc020439e:	6c9000ef          	jal	ffffffffc0205266 <wakeup_proc>
    ret = proc->pid;
ffffffffc02043a2:	4048                	lw	a0,4(s0)
ffffffffc02043a4:	74a6                	ld	s1,104(sp)
ffffffffc02043a6:	7446                	ld	s0,112(sp)
ffffffffc02043a8:	7906                	ld	s2,96(sp)
ffffffffc02043aa:	6a46                	ld	s4,80(sp)
ffffffffc02043ac:	6aa6                	ld	s5,72(sp)
ffffffffc02043ae:	6b06                	ld	s6,64(sp)
ffffffffc02043b0:	7be2                	ld	s7,56(sp)
ffffffffc02043b2:	7c42                	ld	s8,48(sp)
ffffffffc02043b4:	7ca2                	ld	s9,40(sp)
ffffffffc02043b6:	7d02                	ld	s10,32(sp)
ffffffffc02043b8:	6de2                	ld	s11,24(sp)
}
ffffffffc02043ba:	70e6                	ld	ra,120(sp)
ffffffffc02043bc:	69e6                	ld	s3,88(sp)
ffffffffc02043be:	6109                	addi	sp,sp,128
ffffffffc02043c0:	8082                	ret
    if ((mm = mm_create()) == NULL)
ffffffffc02043c2:	e43a                	sd	a4,8(sp)
ffffffffc02043c4:	bbcff0ef          	jal	ffffffffc0203780 <mm_create>
ffffffffc02043c8:	8daa                	mv	s11,a0
ffffffffc02043ca:	c959                	beqz	a0,ffffffffc0204460 <do_fork+0x2e6>
    if ((page = alloc_page()) == NULL)
ffffffffc02043cc:	4505                	li	a0,1
ffffffffc02043ce:	b25fd0ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc02043d2:	c541                	beqz	a0,ffffffffc020445a <do_fork+0x2e0>
    return page - pages + nbase;
ffffffffc02043d4:	000a3683          	ld	a3,0(s4)
ffffffffc02043d8:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc02043da:	000b3783          	ld	a5,0(s6)
    return page - pages + nbase;
ffffffffc02043de:	40d506b3          	sub	a3,a0,a3
ffffffffc02043e2:	8699                	srai	a3,a3,0x6
ffffffffc02043e4:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02043e6:	01a6fd33          	and	s10,a3,s10
    return page2ppn(page) << PGSHIFT;
ffffffffc02043ea:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043ec:	0efd7e63          	bgeu	s10,a5,ffffffffc02044e8 <do_fork+0x36e>
ffffffffc02043f0:	000bb783          	ld	a5,0(s7)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02043f4:	00097597          	auipc	a1,0x97
ffffffffc02043f8:	52c5b583          	ld	a1,1324(a1) # ffffffffc029b920 <boot_pgdir_va>
ffffffffc02043fc:	864e                	mv	a2,s3
ffffffffc02043fe:	00f689b3          	add	s3,a3,a5
ffffffffc0204402:	854e                	mv	a0,s3
ffffffffc0204404:	506010ef          	jal	ffffffffc020590a <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204408:	038c8d13          	addi	s10,s9,56
    mm->pgdir = pgdir;
ffffffffc020440c:	013dbc23          	sd	s3,24(s11)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204410:	4785                	li	a5,1
ffffffffc0204412:	40fd37af          	amoor.d	a5,a5,(s10)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204416:	03f79713          	slli	a4,a5,0x3f
ffffffffc020441a:	03f75793          	srli	a5,a4,0x3f
ffffffffc020441e:	4985                	li	s3,1
ffffffffc0204420:	cb91                	beqz	a5,ffffffffc0204434 <do_fork+0x2ba>
    {
        schedule();
ffffffffc0204422:	6d9000ef          	jal	ffffffffc02052fa <schedule>
ffffffffc0204426:	413d37af          	amoor.d	a5,s3,(s10)
    while (!try_lock(lock))
ffffffffc020442a:	03f79713          	slli	a4,a5,0x3f
ffffffffc020442e:	03f75793          	srli	a5,a4,0x3f
ffffffffc0204432:	fbe5                	bnez	a5,ffffffffc0204422 <do_fork+0x2a8>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204434:	85e6                	mv	a1,s9
ffffffffc0204436:	856e                	mv	a0,s11
ffffffffc0204438:	e90ff0ef          	jal	ffffffffc0203ac8 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020443c:	57f9                	li	a5,-2
ffffffffc020443e:	60fd37af          	amoand.d	a5,a5,(s10)
ffffffffc0204442:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204444:	0e078763          	beqz	a5,ffffffffc0204532 <do_fork+0x3b8>
    if ((mm = mm_create()) == NULL)
ffffffffc0204448:	8cee                	mv	s9,s11
    if (ret != 0)
ffffffffc020444a:	dc050ee3          	beqz	a0,ffffffffc0204226 <do_fork+0xac>
    exit_mmap(mm);
ffffffffc020444e:	856e                	mv	a0,s11
ffffffffc0204450:	f10ff0ef          	jal	ffffffffc0203b60 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204454:	856e                	mv	a0,s11
ffffffffc0204456:	c4dff0ef          	jal	ffffffffc02040a2 <put_pgdir>
    mm_destroy(mm);
ffffffffc020445a:	856e                	mv	a0,s11
ffffffffc020445c:	d4eff0ef          	jal	ffffffffc02039aa <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204460:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204462:	c02007b7          	lui	a5,0xc0200
ffffffffc0204466:	08f6ed63          	bltu	a3,a5,ffffffffc0204500 <do_fork+0x386>
ffffffffc020446a:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage)
ffffffffc020446e:	000b3703          	ld	a4,0(s6)
    return pa2page(PADDR(kva));
ffffffffc0204472:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204476:	83b1                	srli	a5,a5,0xc
ffffffffc0204478:	04e7fc63          	bgeu	a5,a4,ffffffffc02044d0 <do_fork+0x356>
    return &pages[PPN(pa) - nbase];
ffffffffc020447c:	000ab703          	ld	a4,0(s5)
ffffffffc0204480:	000a3503          	ld	a0,0(s4)
ffffffffc0204484:	4589                	li	a1,2
ffffffffc0204486:	8f99                	sub	a5,a5,a4
ffffffffc0204488:	079a                	slli	a5,a5,0x6
ffffffffc020448a:	953e                	add	a0,a0,a5
ffffffffc020448c:	aa1fd0ef          	jal	ffffffffc0201f2c <free_pages>
}
ffffffffc0204490:	6a46                	ld	s4,80(sp)
ffffffffc0204492:	6aa6                	ld	s5,72(sp)
ffffffffc0204494:	6b06                	ld	s6,64(sp)
ffffffffc0204496:	7be2                	ld	s7,56(sp)
ffffffffc0204498:	7c42                	ld	s8,48(sp)
ffffffffc020449a:	7ca2                	ld	s9,40(sp)
ffffffffc020449c:	7d02                	ld	s10,32(sp)
    kfree(proc);
ffffffffc020449e:	8522                	mv	a0,s0
ffffffffc02044a0:	937fd0ef          	jal	ffffffffc0201dd6 <kfree>
    goto fork_out;
ffffffffc02044a4:	7446                	ld	s0,112(sp)
ffffffffc02044a6:	74a6                	ld	s1,104(sp)
ffffffffc02044a8:	7906                	ld	s2,96(sp)
ffffffffc02044aa:	6de2                	ld	s11,24(sp)
    ret = -E_NO_MEM;
ffffffffc02044ac:	5571                	li	a0,-4
    return ret;
ffffffffc02044ae:	b731                	j	ffffffffc02043ba <do_fork+0x240>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044b0:	8936                	mv	s2,a3
ffffffffc02044b2:	bbc9                	j	ffffffffc0204284 <do_fork+0x10a>
        last_pid = 1;
ffffffffc02044b4:	4585                	li	a1,1
ffffffffc02044b6:	00093797          	auipc	a5,0x93
ffffffffc02044ba:	feb7af23          	sw	a1,-2(a5) # ffffffffc02974b4 <last_pid.1>
        goto inside;
ffffffffc02044be:	b509                	j	ffffffffc02042c0 <do_fork+0x146>
                    if (last_pid >= MAX_PID)
ffffffffc02044c0:	6789                	lui	a5,0x2
ffffffffc02044c2:	00f6c363          	blt	a3,a5,ffffffffc02044c8 <do_fork+0x34e>
                        last_pid = 1;
ffffffffc02044c6:	4685                	li	a3,1
                    goto repeat;
ffffffffc02044c8:	4505                	li	a0,1
ffffffffc02044ca:	bd01                	j	ffffffffc02042da <do_fork+0x160>
    int ret = -E_NO_FREE_PROC;
ffffffffc02044cc:	556d                	li	a0,-5
ffffffffc02044ce:	b5f5                	j	ffffffffc02043ba <do_fork+0x240>
        panic("pa2page called with invalid pa");
ffffffffc02044d0:	00002617          	auipc	a2,0x2
ffffffffc02044d4:	30060613          	addi	a2,a2,768 # ffffffffc02067d0 <etext+0xeae>
ffffffffc02044d8:	06900593          	li	a1,105
ffffffffc02044dc:	00002517          	auipc	a0,0x2
ffffffffc02044e0:	24c50513          	addi	a0,a0,588 # ffffffffc0206728 <etext+0xe06>
ffffffffc02044e4:	f63fb0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02044e8:	00002617          	auipc	a2,0x2
ffffffffc02044ec:	21860613          	addi	a2,a2,536 # ffffffffc0206700 <etext+0xdde>
ffffffffc02044f0:	07100593          	li	a1,113
ffffffffc02044f4:	00002517          	auipc	a0,0x2
ffffffffc02044f8:	23450513          	addi	a0,a0,564 # ffffffffc0206728 <etext+0xe06>
ffffffffc02044fc:	f4bfb0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204500:	00002617          	auipc	a2,0x2
ffffffffc0204504:	2a860613          	addi	a2,a2,680 # ffffffffc02067a8 <etext+0xe86>
ffffffffc0204508:	07700593          	li	a1,119
ffffffffc020450c:	00002517          	auipc	a0,0x2
ffffffffc0204510:	21c50513          	addi	a0,a0,540 # ffffffffc0206728 <etext+0xe06>
ffffffffc0204514:	f33fb0ef          	jal	ffffffffc0200446 <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204518:	86be                	mv	a3,a5
ffffffffc020451a:	00002617          	auipc	a2,0x2
ffffffffc020451e:	28e60613          	addi	a2,a2,654 # ffffffffc02067a8 <etext+0xe86>
ffffffffc0204522:	1a200593          	li	a1,418
ffffffffc0204526:	00003517          	auipc	a0,0x3
ffffffffc020452a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0207128 <etext+0x1806>
ffffffffc020452e:	f19fb0ef          	jal	ffffffffc0200446 <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204532:	00003617          	auipc	a2,0x3
ffffffffc0204536:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0207140 <etext+0x181e>
ffffffffc020453a:	03f00593          	li	a1,63
ffffffffc020453e:	00003517          	auipc	a0,0x3
ffffffffc0204542:	c1250513          	addi	a0,a0,-1006 # ffffffffc0207150 <etext+0x182e>
ffffffffc0204546:	f01fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020454a <kernel_thread>:
{
ffffffffc020454a:	7129                	addi	sp,sp,-320
ffffffffc020454c:	fa22                	sd	s0,304(sp)
ffffffffc020454e:	f626                	sd	s1,296(sp)
ffffffffc0204550:	f24a                	sd	s2,288(sp)
ffffffffc0204552:	842a                	mv	s0,a0
ffffffffc0204554:	84ae                	mv	s1,a1
ffffffffc0204556:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204558:	850a                	mv	a0,sp
ffffffffc020455a:	12000613          	li	a2,288
ffffffffc020455e:	4581                	li	a1,0
{
ffffffffc0204560:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204562:	396010ef          	jal	ffffffffc02058f8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204566:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204568:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020456a:	100027f3          	csrr	a5,sstatus
ffffffffc020456e:	edd7f793          	andi	a5,a5,-291
ffffffffc0204572:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204576:	860a                	mv	a2,sp
ffffffffc0204578:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020457c:	00000717          	auipc	a4,0x0
ffffffffc0204580:	a2070713          	addi	a4,a4,-1504 # ffffffffc0203f9c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204584:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204586:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204588:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020458a:	bf1ff0ef          	jal	ffffffffc020417a <do_fork>
}
ffffffffc020458e:	70f2                	ld	ra,312(sp)
ffffffffc0204590:	7452                	ld	s0,304(sp)
ffffffffc0204592:	74b2                	ld	s1,296(sp)
ffffffffc0204594:	7912                	ld	s2,288(sp)
ffffffffc0204596:	6131                	addi	sp,sp,320
ffffffffc0204598:	8082                	ret

ffffffffc020459a <do_exit>:
{
ffffffffc020459a:	7179                	addi	sp,sp,-48
ffffffffc020459c:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc020459e:	00097417          	auipc	s0,0x97
ffffffffc02045a2:	3aa40413          	addi	s0,s0,938 # ffffffffc029b948 <current>
ffffffffc02045a6:	601c                	ld	a5,0(s0)
ffffffffc02045a8:	00097717          	auipc	a4,0x97
ffffffffc02045ac:	3b073703          	ld	a4,944(a4) # ffffffffc029b958 <idleproc>
{
ffffffffc02045b0:	f406                	sd	ra,40(sp)
ffffffffc02045b2:	ec26                	sd	s1,24(sp)
    if (current == idleproc)
ffffffffc02045b4:	0ce78b63          	beq	a5,a4,ffffffffc020468a <do_exit+0xf0>
    if (current == initproc)
ffffffffc02045b8:	00097497          	auipc	s1,0x97
ffffffffc02045bc:	39848493          	addi	s1,s1,920 # ffffffffc029b950 <initproc>
ffffffffc02045c0:	6098                	ld	a4,0(s1)
ffffffffc02045c2:	e84a                	sd	s2,16(sp)
ffffffffc02045c4:	0ee78a63          	beq	a5,a4,ffffffffc02046b8 <do_exit+0x11e>
ffffffffc02045c8:	892a                	mv	s2,a0
    struct mm_struct *mm = current->mm;
ffffffffc02045ca:	7788                	ld	a0,40(a5)
    if (mm != NULL)
ffffffffc02045cc:	c115                	beqz	a0,ffffffffc02045f0 <do_exit+0x56>
ffffffffc02045ce:	00097797          	auipc	a5,0x97
ffffffffc02045d2:	34a7b783          	ld	a5,842(a5) # ffffffffc029b918 <boot_pgdir_pa>
ffffffffc02045d6:	577d                	li	a4,-1
ffffffffc02045d8:	177e                	slli	a4,a4,0x3f
ffffffffc02045da:	83b1                	srli	a5,a5,0xc
ffffffffc02045dc:	8fd9                	or	a5,a5,a4
ffffffffc02045de:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02045e2:	591c                	lw	a5,48(a0)
ffffffffc02045e4:	37fd                	addiw	a5,a5,-1
ffffffffc02045e6:	d91c                	sw	a5,48(a0)
        if (mm_count_dec(mm) == 0)
ffffffffc02045e8:	cfd5                	beqz	a5,ffffffffc02046a4 <do_exit+0x10a>
        current->mm = NULL;
ffffffffc02045ea:	601c                	ld	a5,0(s0)
ffffffffc02045ec:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02045f0:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc02045f2:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02045f6:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045f8:	100027f3          	csrr	a5,sstatus
ffffffffc02045fc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045fe:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204600:	ebe1                	bnez	a5,ffffffffc02046d0 <do_exit+0x136>
        proc = current->parent;
ffffffffc0204602:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204604:	800007b7          	lui	a5,0x80000
ffffffffc0204608:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5e19>
        proc = current->parent;
ffffffffc020460a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020460c:	0ec52703          	lw	a4,236(a0)
ffffffffc0204610:	0cf70463          	beq	a4,a5,ffffffffc02046d8 <do_exit+0x13e>
        while (current->cptr != NULL)
ffffffffc0204614:	6018                	ld	a4,0(s0)
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204616:	800005b7          	lui	a1,0x80000
ffffffffc020461a:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5e19>
        while (current->cptr != NULL)
ffffffffc020461c:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020461e:	460d                	li	a2,3
        while (current->cptr != NULL)
ffffffffc0204620:	e789                	bnez	a5,ffffffffc020462a <do_exit+0x90>
ffffffffc0204622:	a83d                	j	ffffffffc0204660 <do_exit+0xc6>
ffffffffc0204624:	6018                	ld	a4,0(s0)
ffffffffc0204626:	7b7c                	ld	a5,240(a4)
ffffffffc0204628:	cf85                	beqz	a5,ffffffffc0204660 <do_exit+0xc6>
            current->cptr = proc->optr;
ffffffffc020462a:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020462e:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204630:	fb74                	sd	a3,240(a4)
            proc->yptr = NULL;
ffffffffc0204632:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204636:	7978                	ld	a4,240(a0)
ffffffffc0204638:	10e7b023          	sd	a4,256(a5)
ffffffffc020463c:	c311                	beqz	a4,ffffffffc0204640 <do_exit+0xa6>
                initproc->cptr->yptr = proc;
ffffffffc020463e:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204640:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204642:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204644:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204646:	fcc71fe3          	bne	a4,a2,ffffffffc0204624 <do_exit+0x8a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc020464a:	0ec52783          	lw	a5,236(a0)
ffffffffc020464e:	fcb79be3          	bne	a5,a1,ffffffffc0204624 <do_exit+0x8a>
                    wakeup_proc(initproc);
ffffffffc0204652:	415000ef          	jal	ffffffffc0205266 <wakeup_proc>
ffffffffc0204656:	800005b7          	lui	a1,0x80000
ffffffffc020465a:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5e19>
ffffffffc020465c:	460d                	li	a2,3
ffffffffc020465e:	b7d9                	j	ffffffffc0204624 <do_exit+0x8a>
    if (flag)
ffffffffc0204660:	02091263          	bnez	s2,ffffffffc0204684 <do_exit+0xea>
    schedule();
ffffffffc0204664:	497000ef          	jal	ffffffffc02052fa <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204668:	601c                	ld	a5,0(s0)
ffffffffc020466a:	00003617          	auipc	a2,0x3
ffffffffc020466e:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0207188 <etext+0x1866>
ffffffffc0204672:	25800593          	li	a1,600
ffffffffc0204676:	43d4                	lw	a3,4(a5)
ffffffffc0204678:	00003517          	auipc	a0,0x3
ffffffffc020467c:	ab050513          	addi	a0,a0,-1360 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204680:	dc7fb0ef          	jal	ffffffffc0200446 <__panic>
        intr_enable();
ffffffffc0204684:	a7afc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0204688:	bff1                	j	ffffffffc0204664 <do_exit+0xca>
        panic("idleproc exit.\n");
ffffffffc020468a:	00003617          	auipc	a2,0x3
ffffffffc020468e:	ade60613          	addi	a2,a2,-1314 # ffffffffc0207168 <etext+0x1846>
ffffffffc0204692:	22400593          	li	a1,548
ffffffffc0204696:	00003517          	auipc	a0,0x3
ffffffffc020469a:	a9250513          	addi	a0,a0,-1390 # ffffffffc0207128 <etext+0x1806>
ffffffffc020469e:	e84a                	sd	s2,16(sp)
ffffffffc02046a0:	da7fb0ef          	jal	ffffffffc0200446 <__panic>
            exit_mmap(mm);
ffffffffc02046a4:	e42a                	sd	a0,8(sp)
ffffffffc02046a6:	cbaff0ef          	jal	ffffffffc0203b60 <exit_mmap>
            put_pgdir(mm);
ffffffffc02046aa:	6522                	ld	a0,8(sp)
ffffffffc02046ac:	9f7ff0ef          	jal	ffffffffc02040a2 <put_pgdir>
            mm_destroy(mm);
ffffffffc02046b0:	6522                	ld	a0,8(sp)
ffffffffc02046b2:	af8ff0ef          	jal	ffffffffc02039aa <mm_destroy>
ffffffffc02046b6:	bf15                	j	ffffffffc02045ea <do_exit+0x50>
        panic("initproc exit.\n");
ffffffffc02046b8:	00003617          	auipc	a2,0x3
ffffffffc02046bc:	ac060613          	addi	a2,a2,-1344 # ffffffffc0207178 <etext+0x1856>
ffffffffc02046c0:	22800593          	li	a1,552
ffffffffc02046c4:	00003517          	auipc	a0,0x3
ffffffffc02046c8:	a6450513          	addi	a0,a0,-1436 # ffffffffc0207128 <etext+0x1806>
ffffffffc02046cc:	d7bfb0ef          	jal	ffffffffc0200446 <__panic>
        intr_disable();
ffffffffc02046d0:	a34fc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc02046d4:	4905                	li	s2,1
ffffffffc02046d6:	b735                	j	ffffffffc0204602 <do_exit+0x68>
            wakeup_proc(proc);
ffffffffc02046d8:	38f000ef          	jal	ffffffffc0205266 <wakeup_proc>
ffffffffc02046dc:	bf25                	j	ffffffffc0204614 <do_exit+0x7a>

ffffffffc02046de <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc02046de:	7179                	addi	sp,sp,-48
ffffffffc02046e0:	ec26                	sd	s1,24(sp)
ffffffffc02046e2:	e84a                	sd	s2,16(sp)
ffffffffc02046e4:	e44e                	sd	s3,8(sp)
ffffffffc02046e6:	f406                	sd	ra,40(sp)
ffffffffc02046e8:	f022                	sd	s0,32(sp)
ffffffffc02046ea:	84aa                	mv	s1,a0
ffffffffc02046ec:	892e                	mv	s2,a1
ffffffffc02046ee:	00097997          	auipc	s3,0x97
ffffffffc02046f2:	25a98993          	addi	s3,s3,602 # ffffffffc029b948 <current>
    if (pid != 0)
ffffffffc02046f6:	cd19                	beqz	a0,ffffffffc0204714 <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID)
ffffffffc02046f8:	6789                	lui	a5,0x2
ffffffffc02046fa:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6bf2>
ffffffffc02046fc:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204700:	12e7f563          	bgeu	a5,a4,ffffffffc020482a <do_wait.part.0+0x14c>
}
ffffffffc0204704:	70a2                	ld	ra,40(sp)
ffffffffc0204706:	7402                	ld	s0,32(sp)
ffffffffc0204708:	64e2                	ld	s1,24(sp)
ffffffffc020470a:	6942                	ld	s2,16(sp)
ffffffffc020470c:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc020470e:	5579                	li	a0,-2
}
ffffffffc0204710:	6145                	addi	sp,sp,48
ffffffffc0204712:	8082                	ret
        proc = current->cptr;
ffffffffc0204714:	0009b703          	ld	a4,0(s3)
ffffffffc0204718:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc020471a:	d46d                	beqz	s0,ffffffffc0204704 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020471c:	468d                	li	a3,3
ffffffffc020471e:	a021                	j	ffffffffc0204726 <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204720:	10043403          	ld	s0,256(s0)
ffffffffc0204724:	c075                	beqz	s0,ffffffffc0204808 <do_wait.part.0+0x12a>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204726:	401c                	lw	a5,0(s0)
ffffffffc0204728:	fed79ce3          	bne	a5,a3,ffffffffc0204720 <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc)
ffffffffc020472c:	00097797          	auipc	a5,0x97
ffffffffc0204730:	22c7b783          	ld	a5,556(a5) # ffffffffc029b958 <idleproc>
ffffffffc0204734:	14878263          	beq	a5,s0,ffffffffc0204878 <do_wait.part.0+0x19a>
ffffffffc0204738:	00097797          	auipc	a5,0x97
ffffffffc020473c:	2187b783          	ld	a5,536(a5) # ffffffffc029b950 <initproc>
ffffffffc0204740:	12f40c63          	beq	s0,a5,ffffffffc0204878 <do_wait.part.0+0x19a>
    if (code_store != NULL)
ffffffffc0204744:	00090663          	beqz	s2,ffffffffc0204750 <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc0204748:	0e842783          	lw	a5,232(s0)
ffffffffc020474c:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204750:	100027f3          	csrr	a5,sstatus
ffffffffc0204754:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204756:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204758:	10079963          	bnez	a5,ffffffffc020486a <do_wait.part.0+0x18c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020475c:	6c74                	ld	a3,216(s0)
ffffffffc020475e:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL)
ffffffffc0204760:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc0204764:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204766:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204768:	6474                	ld	a3,200(s0)
ffffffffc020476a:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc020476c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020476e:	e314                	sd	a3,0(a4)
ffffffffc0204770:	c789                	beqz	a5,ffffffffc020477a <do_wait.part.0+0x9c>
        proc->optr->yptr = proc->yptr;
ffffffffc0204772:	7c78                	ld	a4,248(s0)
ffffffffc0204774:	fff8                	sd	a4,248(a5)
        proc->yptr->optr = proc->optr;
ffffffffc0204776:	10043783          	ld	a5,256(s0)
    if (proc->yptr != NULL)
ffffffffc020477a:	7c78                	ld	a4,248(s0)
ffffffffc020477c:	c36d                	beqz	a4,ffffffffc020485e <do_wait.part.0+0x180>
        proc->yptr->optr = proc->optr;
ffffffffc020477e:	10f73023          	sd	a5,256(a4)
    nr_process--;
ffffffffc0204782:	00097797          	auipc	a5,0x97
ffffffffc0204786:	1be7a783          	lw	a5,446(a5) # ffffffffc029b940 <nr_process>
ffffffffc020478a:	37fd                	addiw	a5,a5,-1
ffffffffc020478c:	00097717          	auipc	a4,0x97
ffffffffc0204790:	1af72a23          	sw	a5,436(a4) # ffffffffc029b940 <nr_process>
    if (flag)
ffffffffc0204794:	e271                	bnez	a2,ffffffffc0204858 <do_wait.part.0+0x17a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204796:	6814                	ld	a3,16(s0)
ffffffffc0204798:	c02007b7          	lui	a5,0xc0200
ffffffffc020479c:	10f6e663          	bltu	a3,a5,ffffffffc02048a8 <do_wait.part.0+0x1ca>
ffffffffc02047a0:	00097717          	auipc	a4,0x97
ffffffffc02047a4:	18873703          	ld	a4,392(a4) # ffffffffc029b928 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc02047a8:	00097797          	auipc	a5,0x97
ffffffffc02047ac:	1887b783          	ld	a5,392(a5) # ffffffffc029b930 <npage>
    return pa2page(PADDR(kva));
ffffffffc02047b0:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02047b2:	82b1                	srli	a3,a3,0xc
ffffffffc02047b4:	0cf6fe63          	bgeu	a3,a5,ffffffffc0204890 <do_wait.part.0+0x1b2>
    return &pages[PPN(pa) - nbase];
ffffffffc02047b8:	00003797          	auipc	a5,0x3
ffffffffc02047bc:	2f87b783          	ld	a5,760(a5) # ffffffffc0207ab0 <nbase>
ffffffffc02047c0:	00097517          	auipc	a0,0x97
ffffffffc02047c4:	17853503          	ld	a0,376(a0) # ffffffffc029b938 <pages>
ffffffffc02047c8:	4589                	li	a1,2
ffffffffc02047ca:	8e9d                	sub	a3,a3,a5
ffffffffc02047cc:	069a                	slli	a3,a3,0x6
ffffffffc02047ce:	9536                	add	a0,a0,a3
ffffffffc02047d0:	f5cfd0ef          	jal	ffffffffc0201f2c <free_pages>
    kfree(proc);
ffffffffc02047d4:	8522                	mv	a0,s0
ffffffffc02047d6:	e00fd0ef          	jal	ffffffffc0201dd6 <kfree>
}
ffffffffc02047da:	70a2                	ld	ra,40(sp)
ffffffffc02047dc:	7402                	ld	s0,32(sp)
ffffffffc02047de:	64e2                	ld	s1,24(sp)
ffffffffc02047e0:	6942                	ld	s2,16(sp)
ffffffffc02047e2:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc02047e4:	4501                	li	a0,0
}
ffffffffc02047e6:	6145                	addi	sp,sp,48
ffffffffc02047e8:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc02047ea:	00097997          	auipc	s3,0x97
ffffffffc02047ee:	15e98993          	addi	s3,s3,350 # ffffffffc029b948 <current>
ffffffffc02047f2:	0009b703          	ld	a4,0(s3)
ffffffffc02047f6:	f487b683          	ld	a3,-184(a5)
ffffffffc02047fa:	f0e695e3          	bne	a3,a4,ffffffffc0204704 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02047fe:	f287a603          	lw	a2,-216(a5)
ffffffffc0204802:	468d                	li	a3,3
ffffffffc0204804:	06d60063          	beq	a2,a3,ffffffffc0204864 <do_wait.part.0+0x186>
        current->wait_state = WT_CHILD;
ffffffffc0204808:	800007b7          	lui	a5,0x80000
ffffffffc020480c:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5e19>
        current->state = PROC_SLEEPING;
ffffffffc020480e:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc0204810:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc0204814:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc0204816:	2e5000ef          	jal	ffffffffc02052fa <schedule>
        if (current->flags & PF_EXITING)
ffffffffc020481a:	0009b783          	ld	a5,0(s3)
ffffffffc020481e:	0b07a783          	lw	a5,176(a5)
ffffffffc0204822:	8b85                	andi	a5,a5,1
ffffffffc0204824:	e7b9                	bnez	a5,ffffffffc0204872 <do_wait.part.0+0x194>
    if (pid != 0)
ffffffffc0204826:	ee0487e3          	beqz	s1,ffffffffc0204714 <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020482a:	45a9                	li	a1,10
ffffffffc020482c:	8526                	mv	a0,s1
ffffffffc020482e:	435000ef          	jal	ffffffffc0205462 <hash32>
ffffffffc0204832:	02051793          	slli	a5,a0,0x20
ffffffffc0204836:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020483a:	00093797          	auipc	a5,0x93
ffffffffc020483e:	09678793          	addi	a5,a5,150 # ffffffffc02978d0 <hash_list>
ffffffffc0204842:	953e                	add	a0,a0,a5
ffffffffc0204844:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204846:	a029                	j	ffffffffc0204850 <do_wait.part.0+0x172>
            if (proc->pid == pid)
ffffffffc0204848:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020484c:	f8970fe3          	beq	a4,s1,ffffffffc02047ea <do_wait.part.0+0x10c>
    return listelm->next;
ffffffffc0204850:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204852:	fef51be3          	bne	a0,a5,ffffffffc0204848 <do_wait.part.0+0x16a>
ffffffffc0204856:	b57d                	j	ffffffffc0204704 <do_wait.part.0+0x26>
        intr_enable();
ffffffffc0204858:	8a6fc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020485c:	bf2d                	j	ffffffffc0204796 <do_wait.part.0+0xb8>
        proc->parent->cptr = proc->optr;
ffffffffc020485e:	7018                	ld	a4,32(s0)
ffffffffc0204860:	fb7c                	sd	a5,240(a4)
ffffffffc0204862:	b705                	j	ffffffffc0204782 <do_wait.part.0+0xa4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204864:	f2878413          	addi	s0,a5,-216
ffffffffc0204868:	b5d1                	j	ffffffffc020472c <do_wait.part.0+0x4e>
        intr_disable();
ffffffffc020486a:	89afc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc020486e:	4605                	li	a2,1
ffffffffc0204870:	b5f5                	j	ffffffffc020475c <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc0204872:	555d                	li	a0,-9
ffffffffc0204874:	d27ff0ef          	jal	ffffffffc020459a <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc0204878:	00003617          	auipc	a2,0x3
ffffffffc020487c:	93060613          	addi	a2,a2,-1744 # ffffffffc02071a8 <etext+0x1886>
ffffffffc0204880:	37c00593          	li	a1,892
ffffffffc0204884:	00003517          	auipc	a0,0x3
ffffffffc0204888:	8a450513          	addi	a0,a0,-1884 # ffffffffc0207128 <etext+0x1806>
ffffffffc020488c:	bbbfb0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204890:	00002617          	auipc	a2,0x2
ffffffffc0204894:	f4060613          	addi	a2,a2,-192 # ffffffffc02067d0 <etext+0xeae>
ffffffffc0204898:	06900593          	li	a1,105
ffffffffc020489c:	00002517          	auipc	a0,0x2
ffffffffc02048a0:	e8c50513          	addi	a0,a0,-372 # ffffffffc0206728 <etext+0xe06>
ffffffffc02048a4:	ba3fb0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02048a8:	00002617          	auipc	a2,0x2
ffffffffc02048ac:	f0060613          	addi	a2,a2,-256 # ffffffffc02067a8 <etext+0xe86>
ffffffffc02048b0:	07700593          	li	a1,119
ffffffffc02048b4:	00002517          	auipc	a0,0x2
ffffffffc02048b8:	e7450513          	addi	a0,a0,-396 # ffffffffc0206728 <etext+0xe06>
ffffffffc02048bc:	b8bfb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02048c0 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02048c0:	1141                	addi	sp,sp,-16
ffffffffc02048c2:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02048c4:	ea0fd0ef          	jal	ffffffffc0201f64 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02048c8:	c64fd0ef          	jal	ffffffffc0201d2c <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02048cc:	4601                	li	a2,0
ffffffffc02048ce:	4581                	li	a1,0
ffffffffc02048d0:	fffff517          	auipc	a0,0xfffff
ffffffffc02048d4:	75450513          	addi	a0,a0,1876 # ffffffffc0204024 <user_main>
ffffffffc02048d8:	c73ff0ef          	jal	ffffffffc020454a <kernel_thread>
    if (pid <= 0)
ffffffffc02048dc:	00a04563          	bgtz	a0,ffffffffc02048e6 <init_main+0x26>
ffffffffc02048e0:	a071                	j	ffffffffc020496c <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc02048e2:	219000ef          	jal	ffffffffc02052fa <schedule>
    if (code_store != NULL)
ffffffffc02048e6:	4581                	li	a1,0
ffffffffc02048e8:	4501                	li	a0,0
ffffffffc02048ea:	df5ff0ef          	jal	ffffffffc02046de <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc02048ee:	d975                	beqz	a0,ffffffffc02048e2 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02048f0:	00003517          	auipc	a0,0x3
ffffffffc02048f4:	8f850513          	addi	a0,a0,-1800 # ffffffffc02071e8 <etext+0x18c6>
ffffffffc02048f8:	89dfb0ef          	jal	ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02048fc:	00097797          	auipc	a5,0x97
ffffffffc0204900:	0547b783          	ld	a5,84(a5) # ffffffffc029b950 <initproc>
ffffffffc0204904:	7bf8                	ld	a4,240(a5)
ffffffffc0204906:	e339                	bnez	a4,ffffffffc020494c <init_main+0x8c>
ffffffffc0204908:	7ff8                	ld	a4,248(a5)
ffffffffc020490a:	e329                	bnez	a4,ffffffffc020494c <init_main+0x8c>
ffffffffc020490c:	1007b703          	ld	a4,256(a5)
ffffffffc0204910:	ef15                	bnez	a4,ffffffffc020494c <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204912:	00097697          	auipc	a3,0x97
ffffffffc0204916:	02e6a683          	lw	a3,46(a3) # ffffffffc029b940 <nr_process>
ffffffffc020491a:	4709                	li	a4,2
ffffffffc020491c:	0ae69463          	bne	a3,a4,ffffffffc02049c4 <init_main+0x104>
ffffffffc0204920:	00097697          	auipc	a3,0x97
ffffffffc0204924:	fb068693          	addi	a3,a3,-80 # ffffffffc029b8d0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204928:	6698                	ld	a4,8(a3)
ffffffffc020492a:	0c878793          	addi	a5,a5,200
ffffffffc020492e:	06f71b63          	bne	a4,a5,ffffffffc02049a4 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204932:	629c                	ld	a5,0(a3)
ffffffffc0204934:	04f71863          	bne	a4,a5,ffffffffc0204984 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204938:	00003517          	auipc	a0,0x3
ffffffffc020493c:	99850513          	addi	a0,a0,-1640 # ffffffffc02072d0 <etext+0x19ae>
ffffffffc0204940:	855fb0ef          	jal	ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0204944:	60a2                	ld	ra,8(sp)
ffffffffc0204946:	4501                	li	a0,0
ffffffffc0204948:	0141                	addi	sp,sp,16
ffffffffc020494a:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020494c:	00003697          	auipc	a3,0x3
ffffffffc0204950:	8c468693          	addi	a3,a3,-1852 # ffffffffc0207210 <etext+0x18ee>
ffffffffc0204954:	00002617          	auipc	a2,0x2
ffffffffc0204958:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206350 <etext+0xa2e>
ffffffffc020495c:	3ea00593          	li	a1,1002
ffffffffc0204960:	00002517          	auipc	a0,0x2
ffffffffc0204964:	7c850513          	addi	a0,a0,1992 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204968:	adffb0ef          	jal	ffffffffc0200446 <__panic>
        panic("create user_main failed.\n");
ffffffffc020496c:	00003617          	auipc	a2,0x3
ffffffffc0204970:	85c60613          	addi	a2,a2,-1956 # ffffffffc02071c8 <etext+0x18a6>
ffffffffc0204974:	3e100593          	li	a1,993
ffffffffc0204978:	00002517          	auipc	a0,0x2
ffffffffc020497c:	7b050513          	addi	a0,a0,1968 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204980:	ac7fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204984:	00003697          	auipc	a3,0x3
ffffffffc0204988:	91c68693          	addi	a3,a3,-1764 # ffffffffc02072a0 <etext+0x197e>
ffffffffc020498c:	00002617          	auipc	a2,0x2
ffffffffc0204990:	9c460613          	addi	a2,a2,-1596 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0204994:	3ed00593          	li	a1,1005
ffffffffc0204998:	00002517          	auipc	a0,0x2
ffffffffc020499c:	79050513          	addi	a0,a0,1936 # ffffffffc0207128 <etext+0x1806>
ffffffffc02049a0:	aa7fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02049a4:	00003697          	auipc	a3,0x3
ffffffffc02049a8:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0207270 <etext+0x194e>
ffffffffc02049ac:	00002617          	auipc	a2,0x2
ffffffffc02049b0:	9a460613          	addi	a2,a2,-1628 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02049b4:	3ec00593          	li	a1,1004
ffffffffc02049b8:	00002517          	auipc	a0,0x2
ffffffffc02049bc:	77050513          	addi	a0,a0,1904 # ffffffffc0207128 <etext+0x1806>
ffffffffc02049c0:	a87fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_process == 2);
ffffffffc02049c4:	00003697          	auipc	a3,0x3
ffffffffc02049c8:	89c68693          	addi	a3,a3,-1892 # ffffffffc0207260 <etext+0x193e>
ffffffffc02049cc:	00002617          	auipc	a2,0x2
ffffffffc02049d0:	98460613          	addi	a2,a2,-1660 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02049d4:	3eb00593          	li	a1,1003
ffffffffc02049d8:	00002517          	auipc	a0,0x2
ffffffffc02049dc:	75050513          	addi	a0,a0,1872 # ffffffffc0207128 <etext+0x1806>
ffffffffc02049e0:	a67fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02049e4 <do_execve>:
{
ffffffffc02049e4:	7171                	addi	sp,sp,-176
ffffffffc02049e6:	e8ea                	sd	s10,80(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02049e8:	00097d17          	auipc	s10,0x97
ffffffffc02049ec:	f60d0d13          	addi	s10,s10,-160 # ffffffffc029b948 <current>
ffffffffc02049f0:	000d3783          	ld	a5,0(s10)
{
ffffffffc02049f4:	e94a                	sd	s2,144(sp)
ffffffffc02049f6:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02049f8:	0287b903          	ld	s2,40(a5)
{
ffffffffc02049fc:	84ae                	mv	s1,a1
ffffffffc02049fe:	e54e                	sd	s3,136(sp)
ffffffffc0204a00:	ec32                	sd	a2,24(sp)
ffffffffc0204a02:	89aa                	mv	s3,a0
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a04:	85aa                	mv	a1,a0
ffffffffc0204a06:	8626                	mv	a2,s1
ffffffffc0204a08:	854a                	mv	a0,s2
ffffffffc0204a0a:	4681                	li	a3,0
{
ffffffffc0204a0c:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a0e:	ceaff0ef          	jal	ffffffffc0203ef8 <user_mem_check>
ffffffffc0204a12:	46050f63          	beqz	a0,ffffffffc0204e90 <do_execve+0x4ac>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204a16:	4641                	li	a2,16
ffffffffc0204a18:	1808                	addi	a0,sp,48
ffffffffc0204a1a:	4581                	li	a1,0
ffffffffc0204a1c:	6dd000ef          	jal	ffffffffc02058f8 <memset>
    if (len > PROC_NAME_LEN)
ffffffffc0204a20:	47bd                	li	a5,15
ffffffffc0204a22:	8626                	mv	a2,s1
ffffffffc0204a24:	0e97ef63          	bltu	a5,s1,ffffffffc0204b22 <do_execve+0x13e>
    memcpy(local_name, name, len);
ffffffffc0204a28:	85ce                	mv	a1,s3
ffffffffc0204a2a:	1808                	addi	a0,sp,48
ffffffffc0204a2c:	6df000ef          	jal	ffffffffc020590a <memcpy>
    if (mm != NULL)
ffffffffc0204a30:	10090063          	beqz	s2,ffffffffc0204b30 <do_execve+0x14c>
        cputs("mm != NULL");
ffffffffc0204a34:	00002517          	auipc	a0,0x2
ffffffffc0204a38:	4b450513          	addi	a0,a0,1204 # ffffffffc0206ee8 <etext+0x15c6>
ffffffffc0204a3c:	f8efb0ef          	jal	ffffffffc02001ca <cputs>
ffffffffc0204a40:	00097797          	auipc	a5,0x97
ffffffffc0204a44:	ed87b783          	ld	a5,-296(a5) # ffffffffc029b918 <boot_pgdir_pa>
ffffffffc0204a48:	577d                	li	a4,-1
ffffffffc0204a4a:	177e                	slli	a4,a4,0x3f
ffffffffc0204a4c:	83b1                	srli	a5,a5,0xc
ffffffffc0204a4e:	8fd9                	or	a5,a5,a4
ffffffffc0204a50:	18079073          	csrw	satp,a5
ffffffffc0204a54:	03092783          	lw	a5,48(s2)
ffffffffc0204a58:	37fd                	addiw	a5,a5,-1
ffffffffc0204a5a:	02f92823          	sw	a5,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0204a5e:	30078563          	beqz	a5,ffffffffc0204d68 <do_execve+0x384>
        current->mm = NULL;
ffffffffc0204a62:	000d3783          	ld	a5,0(s10)
ffffffffc0204a66:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204a6a:	d17fe0ef          	jal	ffffffffc0203780 <mm_create>
ffffffffc0204a6e:	892a                	mv	s2,a0
ffffffffc0204a70:	22050063          	beqz	a0,ffffffffc0204c90 <do_execve+0x2ac>
    if ((page = alloc_page()) == NULL)
ffffffffc0204a74:	4505                	li	a0,1
ffffffffc0204a76:	c7cfd0ef          	jal	ffffffffc0201ef2 <alloc_pages>
ffffffffc0204a7a:	42050063          	beqz	a0,ffffffffc0204e9a <do_execve+0x4b6>
    return page - pages + nbase;
ffffffffc0204a7e:	f0e2                	sd	s8,96(sp)
ffffffffc0204a80:	00097c17          	auipc	s8,0x97
ffffffffc0204a84:	eb8c0c13          	addi	s8,s8,-328 # ffffffffc029b938 <pages>
ffffffffc0204a88:	000c3783          	ld	a5,0(s8)
ffffffffc0204a8c:	f4de                	sd	s7,104(sp)
ffffffffc0204a8e:	00003b97          	auipc	s7,0x3
ffffffffc0204a92:	022bbb83          	ld	s7,34(s7) # ffffffffc0207ab0 <nbase>
ffffffffc0204a96:	40f506b3          	sub	a3,a0,a5
ffffffffc0204a9a:	ece6                	sd	s9,88(sp)
    return KADDR(page2pa(page));
ffffffffc0204a9c:	00097c97          	auipc	s9,0x97
ffffffffc0204aa0:	e94c8c93          	addi	s9,s9,-364 # ffffffffc029b930 <npage>
ffffffffc0204aa4:	f8da                	sd	s6,112(sp)
    return page - pages + nbase;
ffffffffc0204aa6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204aa8:	5b7d                	li	s6,-1
ffffffffc0204aaa:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0204aae:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204ab0:	00cb5713          	srli	a4,s6,0xc
ffffffffc0204ab4:	e83a                	sd	a4,16(sp)
ffffffffc0204ab6:	fcd6                	sd	s5,120(sp)
ffffffffc0204ab8:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204aba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204abc:	40f77263          	bgeu	a4,a5,ffffffffc0204ec0 <do_execve+0x4dc>
ffffffffc0204ac0:	00097a97          	auipc	s5,0x97
ffffffffc0204ac4:	e68a8a93          	addi	s5,s5,-408 # ffffffffc029b928 <va_pa_offset>
ffffffffc0204ac8:	000ab783          	ld	a5,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204acc:	00097597          	auipc	a1,0x97
ffffffffc0204ad0:	e545b583          	ld	a1,-428(a1) # ffffffffc029b920 <boot_pgdir_va>
ffffffffc0204ad4:	6605                	lui	a2,0x1
ffffffffc0204ad6:	00f684b3          	add	s1,a3,a5
ffffffffc0204ada:	8526                	mv	a0,s1
ffffffffc0204adc:	62f000ef          	jal	ffffffffc020590a <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204ae0:	66e2                	ld	a3,24(sp)
ffffffffc0204ae2:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204ae6:	00993c23          	sd	s1,24(s2)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204aea:	4298                	lw	a4,0(a3)
ffffffffc0204aec:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464ba397>
ffffffffc0204af0:	06f70863          	beq	a4,a5,ffffffffc0204b60 <do_execve+0x17c>
        ret = -E_INVAL_ELF;
ffffffffc0204af4:	54e1                	li	s1,-8
    put_pgdir(mm);
ffffffffc0204af6:	854a                	mv	a0,s2
ffffffffc0204af8:	daaff0ef          	jal	ffffffffc02040a2 <put_pgdir>
ffffffffc0204afc:	7ae6                	ld	s5,120(sp)
ffffffffc0204afe:	7b46                	ld	s6,112(sp)
ffffffffc0204b00:	7ba6                	ld	s7,104(sp)
ffffffffc0204b02:	7c06                	ld	s8,96(sp)
ffffffffc0204b04:	6ce6                	ld	s9,88(sp)
    mm_destroy(mm);
ffffffffc0204b06:	854a                	mv	a0,s2
ffffffffc0204b08:	ea3fe0ef          	jal	ffffffffc02039aa <mm_destroy>
    do_exit(ret);
ffffffffc0204b0c:	8526                	mv	a0,s1
ffffffffc0204b0e:	f122                	sd	s0,160(sp)
ffffffffc0204b10:	e152                	sd	s4,128(sp)
ffffffffc0204b12:	fcd6                	sd	s5,120(sp)
ffffffffc0204b14:	f8da                	sd	s6,112(sp)
ffffffffc0204b16:	f4de                	sd	s7,104(sp)
ffffffffc0204b18:	f0e2                	sd	s8,96(sp)
ffffffffc0204b1a:	ece6                	sd	s9,88(sp)
ffffffffc0204b1c:	e4ee                	sd	s11,72(sp)
ffffffffc0204b1e:	a7dff0ef          	jal	ffffffffc020459a <do_exit>
    if (len > PROC_NAME_LEN)
ffffffffc0204b22:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc0204b24:	85ce                	mv	a1,s3
ffffffffc0204b26:	1808                	addi	a0,sp,48
ffffffffc0204b28:	5e3000ef          	jal	ffffffffc020590a <memcpy>
    if (mm != NULL)
ffffffffc0204b2c:	f00914e3          	bnez	s2,ffffffffc0204a34 <do_execve+0x50>
    if (current->mm != NULL)
ffffffffc0204b30:	000d3783          	ld	a5,0(s10)
ffffffffc0204b34:	779c                	ld	a5,40(a5)
ffffffffc0204b36:	db95                	beqz	a5,ffffffffc0204a6a <do_execve+0x86>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204b38:	00002617          	auipc	a2,0x2
ffffffffc0204b3c:	7b860613          	addi	a2,a2,1976 # ffffffffc02072f0 <etext+0x19ce>
ffffffffc0204b40:	26400593          	li	a1,612
ffffffffc0204b44:	00002517          	auipc	a0,0x2
ffffffffc0204b48:	5e450513          	addi	a0,a0,1508 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204b4c:	f122                	sd	s0,160(sp)
ffffffffc0204b4e:	e152                	sd	s4,128(sp)
ffffffffc0204b50:	fcd6                	sd	s5,120(sp)
ffffffffc0204b52:	f8da                	sd	s6,112(sp)
ffffffffc0204b54:	f4de                	sd	s7,104(sp)
ffffffffc0204b56:	f0e2                	sd	s8,96(sp)
ffffffffc0204b58:	ece6                	sd	s9,88(sp)
ffffffffc0204b5a:	e4ee                	sd	s11,72(sp)
ffffffffc0204b5c:	8ebfb0ef          	jal	ffffffffc0200446 <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b60:	0386d703          	lhu	a4,56(a3)
ffffffffc0204b64:	e152                	sd	s4,128(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b66:	0206ba03          	ld	s4,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b6a:	00371793          	slli	a5,a4,0x3
ffffffffc0204b6e:	8f99                	sub	a5,a5,a4
ffffffffc0204b70:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b72:	9a36                	add	s4,s4,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b74:	97d2                	add	a5,a5,s4
ffffffffc0204b76:	f122                	sd	s0,160(sp)
ffffffffc0204b78:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204b7a:	00fa7e63          	bgeu	s4,a5,ffffffffc0204b96 <do_execve+0x1b2>
ffffffffc0204b7e:	e4ee                	sd	s11,72(sp)
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204b80:	000a2783          	lw	a5,0(s4)
ffffffffc0204b84:	4705                	li	a4,1
ffffffffc0204b86:	10e78763          	beq	a5,a4,ffffffffc0204c94 <do_execve+0x2b0>
    for (; ph < ph_end; ph++)
ffffffffc0204b8a:	77a2                	ld	a5,40(sp)
ffffffffc0204b8c:	038a0a13          	addi	s4,s4,56
ffffffffc0204b90:	fefa68e3          	bltu	s4,a5,ffffffffc0204b80 <do_execve+0x19c>
ffffffffc0204b94:	6da6                	ld	s11,72(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204b96:	4701                	li	a4,0
ffffffffc0204b98:	46ad                	li	a3,11
ffffffffc0204b9a:	00100637          	lui	a2,0x100
ffffffffc0204b9e:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204ba2:	854a                	mv	a0,s2
ffffffffc0204ba4:	e59fe0ef          	jal	ffffffffc02039fc <mm_map>
ffffffffc0204ba8:	84aa                	mv	s1,a0
ffffffffc0204baa:	1a051963          	bnez	a0,ffffffffc0204d5c <do_execve+0x378>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204bae:	01893503          	ld	a0,24(s2)
ffffffffc0204bb2:	467d                	li	a2,31
ffffffffc0204bb4:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204bb8:	ae7fe0ef          	jal	ffffffffc020369e <pgdir_alloc_page>
ffffffffc0204bbc:	3a050163          	beqz	a0,ffffffffc0204f5e <do_execve+0x57a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bc0:	01893503          	ld	a0,24(s2)
ffffffffc0204bc4:	467d                	li	a2,31
ffffffffc0204bc6:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204bca:	ad5fe0ef          	jal	ffffffffc020369e <pgdir_alloc_page>
ffffffffc0204bce:	36050763          	beqz	a0,ffffffffc0204f3c <do_execve+0x558>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bd2:	01893503          	ld	a0,24(s2)
ffffffffc0204bd6:	467d                	li	a2,31
ffffffffc0204bd8:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204bdc:	ac3fe0ef          	jal	ffffffffc020369e <pgdir_alloc_page>
ffffffffc0204be0:	32050d63          	beqz	a0,ffffffffc0204f1a <do_execve+0x536>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204be4:	01893503          	ld	a0,24(s2)
ffffffffc0204be8:	467d                	li	a2,31
ffffffffc0204bea:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204bee:	ab1fe0ef          	jal	ffffffffc020369e <pgdir_alloc_page>
ffffffffc0204bf2:	30050363          	beqz	a0,ffffffffc0204ef8 <do_execve+0x514>
    mm->mm_count += 1;
ffffffffc0204bf6:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0204bfa:	000d3603          	ld	a2,0(s10)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204bfe:	01893683          	ld	a3,24(s2)
ffffffffc0204c02:	2785                	addiw	a5,a5,1
ffffffffc0204c04:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0204c08:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5e40>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204c0c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c10:	2cf6e763          	bltu	a3,a5,ffffffffc0204ede <do_execve+0x4fa>
ffffffffc0204c14:	000ab783          	ld	a5,0(s5)
ffffffffc0204c18:	577d                	li	a4,-1
ffffffffc0204c1a:	177e                	slli	a4,a4,0x3f
ffffffffc0204c1c:	8e9d                	sub	a3,a3,a5
ffffffffc0204c1e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204c22:	f654                	sd	a3,168(a2)
ffffffffc0204c24:	8fd9                	or	a5,a5,a4
ffffffffc0204c26:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204c2a:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c2c:	4581                	li	a1,0
ffffffffc0204c2e:	12000613          	li	a2,288
ffffffffc0204c32:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204c34:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c38:	4c1000ef          	jal	ffffffffc02058f8 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204c3c:	67e2                	ld	a5,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c3e:	000d3983          	ld	s3,0(s10)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204c42:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;
ffffffffc0204c46:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204c48:	4785                	li	a5,1
ffffffffc0204c4a:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204c4c:	02096913          	ori	s2,s2,32
    tf->epc = elf->e_entry;
ffffffffc0204c50:	10e43423          	sd	a4,264(s0)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204c54:	e81c                	sd	a5,16(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204c56:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c5a:	4641                	li	a2,16
ffffffffc0204c5c:	4581                	li	a1,0
ffffffffc0204c5e:	0b498513          	addi	a0,s3,180
ffffffffc0204c62:	497000ef          	jal	ffffffffc02058f8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204c66:	180c                	addi	a1,sp,48
ffffffffc0204c68:	0b498513          	addi	a0,s3,180
ffffffffc0204c6c:	463d                	li	a2,15
ffffffffc0204c6e:	49d000ef          	jal	ffffffffc020590a <memcpy>
ffffffffc0204c72:	740a                	ld	s0,160(sp)
ffffffffc0204c74:	6a0a                	ld	s4,128(sp)
ffffffffc0204c76:	7ae6                	ld	s5,120(sp)
ffffffffc0204c78:	7b46                	ld	s6,112(sp)
ffffffffc0204c7a:	7ba6                	ld	s7,104(sp)
ffffffffc0204c7c:	7c06                	ld	s8,96(sp)
ffffffffc0204c7e:	6ce6                	ld	s9,88(sp)
}
ffffffffc0204c80:	70aa                	ld	ra,168(sp)
ffffffffc0204c82:	694a                	ld	s2,144(sp)
ffffffffc0204c84:	69aa                	ld	s3,136(sp)
ffffffffc0204c86:	6d46                	ld	s10,80(sp)
ffffffffc0204c88:	8526                	mv	a0,s1
ffffffffc0204c8a:	64ea                	ld	s1,152(sp)
ffffffffc0204c8c:	614d                	addi	sp,sp,176
ffffffffc0204c8e:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0204c90:	54f1                	li	s1,-4
ffffffffc0204c92:	bdad                	j	ffffffffc0204b0c <do_execve+0x128>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204c94:	028a3603          	ld	a2,40(s4)
ffffffffc0204c98:	020a3783          	ld	a5,32(s4)
ffffffffc0204c9c:	20f66363          	bltu	a2,a5,ffffffffc0204ea2 <do_execve+0x4be>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204ca0:	004a2783          	lw	a5,4(s4)
ffffffffc0204ca4:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204ca8:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204cac:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204cae:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204cb0:	c6f1                	beqz	a3,ffffffffc0204d7c <do_execve+0x398>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204cb2:	1c079763          	bnez	a5,ffffffffc0204e80 <do_execve+0x49c>
            perm |= (PTE_W | PTE_R);
ffffffffc0204cb6:	47dd                	li	a5,23
            vm_flags |= VM_WRITE;
ffffffffc0204cb8:	00276693          	ori	a3,a4,2
            perm |= (PTE_W | PTE_R);
ffffffffc0204cbc:	e43e                	sd	a5,8(sp)
        if (vm_flags & VM_EXEC)
ffffffffc0204cbe:	c709                	beqz	a4,ffffffffc0204cc8 <do_execve+0x2e4>
            perm |= PTE_X;
ffffffffc0204cc0:	67a2                	ld	a5,8(sp)
ffffffffc0204cc2:	0087e793          	ori	a5,a5,8
ffffffffc0204cc6:	e43e                	sd	a5,8(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204cc8:	010a3583          	ld	a1,16(s4)
ffffffffc0204ccc:	4701                	li	a4,0
ffffffffc0204cce:	854a                	mv	a0,s2
ffffffffc0204cd0:	d2dfe0ef          	jal	ffffffffc02039fc <mm_map>
ffffffffc0204cd4:	84aa                	mv	s1,a0
ffffffffc0204cd6:	1c051463          	bnez	a0,ffffffffc0204e9e <do_execve+0x4ba>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204cda:	010a3b03          	ld	s6,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204cde:	020a3483          	ld	s1,32(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204ce2:	77fd                	lui	a5,0xfffff
ffffffffc0204ce4:	00fb75b3          	and	a1,s6,a5
        end = ph->p_va + ph->p_filesz;
ffffffffc0204ce8:	94da                	add	s1,s1,s6
        while (start < end)
ffffffffc0204cea:	1a9b7563          	bgeu	s6,s1,ffffffffc0204e94 <do_execve+0x4b0>
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204cee:	008a3983          	ld	s3,8(s4)
ffffffffc0204cf2:	67e2                	ld	a5,24(sp)
ffffffffc0204cf4:	99be                	add	s3,s3,a5
ffffffffc0204cf6:	a881                	j	ffffffffc0204d46 <do_execve+0x362>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204cf8:	6785                	lui	a5,0x1
ffffffffc0204cfa:	00f58db3          	add	s11,a1,a5
                size -= la - end;
ffffffffc0204cfe:	41648633          	sub	a2,s1,s6
            if (end < la)
ffffffffc0204d02:	01b4e463          	bltu	s1,s11,ffffffffc0204d0a <do_execve+0x326>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d06:	416d8633          	sub	a2,s11,s6
    return page - pages + nbase;
ffffffffc0204d0a:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204d0e:	67c2                	ld	a5,16(sp)
ffffffffc0204d10:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc0204d14:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d18:	8699                	srai	a3,a3,0x6
ffffffffc0204d1a:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204d1c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d20:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d22:	18a87363          	bgeu	a6,a0,ffffffffc0204ea8 <do_execve+0x4c4>
ffffffffc0204d26:	000ab503          	ld	a0,0(s5)
ffffffffc0204d2a:	40bb05b3          	sub	a1,s6,a1
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204d2e:	e032                	sd	a2,0(sp)
ffffffffc0204d30:	9536                	add	a0,a0,a3
ffffffffc0204d32:	952e                	add	a0,a0,a1
ffffffffc0204d34:	85ce                	mv	a1,s3
ffffffffc0204d36:	3d5000ef          	jal	ffffffffc020590a <memcpy>
            start += size, from += size;
ffffffffc0204d3a:	6602                	ld	a2,0(sp)
ffffffffc0204d3c:	9b32                	add	s6,s6,a2
ffffffffc0204d3e:	99b2                	add	s3,s3,a2
        while (start < end)
ffffffffc0204d40:	049b7563          	bgeu	s6,s1,ffffffffc0204d8a <do_execve+0x3a6>
ffffffffc0204d44:	85ee                	mv	a1,s11
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204d46:	01893503          	ld	a0,24(s2)
ffffffffc0204d4a:	6622                	ld	a2,8(sp)
ffffffffc0204d4c:	e02e                	sd	a1,0(sp)
ffffffffc0204d4e:	951fe0ef          	jal	ffffffffc020369e <pgdir_alloc_page>
ffffffffc0204d52:	6582                	ld	a1,0(sp)
ffffffffc0204d54:	842a                	mv	s0,a0
ffffffffc0204d56:	f14d                	bnez	a0,ffffffffc0204cf8 <do_execve+0x314>
ffffffffc0204d58:	6da6                	ld	s11,72(sp)
        ret = -E_NO_MEM;
ffffffffc0204d5a:	54f1                	li	s1,-4
    exit_mmap(mm);
ffffffffc0204d5c:	854a                	mv	a0,s2
ffffffffc0204d5e:	e03fe0ef          	jal	ffffffffc0203b60 <exit_mmap>
ffffffffc0204d62:	740a                	ld	s0,160(sp)
ffffffffc0204d64:	6a0a                	ld	s4,128(sp)
ffffffffc0204d66:	bb41                	j	ffffffffc0204af6 <do_execve+0x112>
            exit_mmap(mm);
ffffffffc0204d68:	854a                	mv	a0,s2
ffffffffc0204d6a:	df7fe0ef          	jal	ffffffffc0203b60 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204d6e:	854a                	mv	a0,s2
ffffffffc0204d70:	b32ff0ef          	jal	ffffffffc02040a2 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204d74:	854a                	mv	a0,s2
ffffffffc0204d76:	c35fe0ef          	jal	ffffffffc02039aa <mm_destroy>
ffffffffc0204d7a:	b1e5                	j	ffffffffc0204a62 <do_execve+0x7e>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204d7c:	0e078e63          	beqz	a5,ffffffffc0204e78 <do_execve+0x494>
            perm |= PTE_R;
ffffffffc0204d80:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc0204d82:	00176693          	ori	a3,a4,1
            perm |= PTE_R;
ffffffffc0204d86:	e43e                	sd	a5,8(sp)
ffffffffc0204d88:	bf1d                	j	ffffffffc0204cbe <do_execve+0x2da>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204d8a:	010a3483          	ld	s1,16(s4)
ffffffffc0204d8e:	028a3683          	ld	a3,40(s4)
ffffffffc0204d92:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc0204d94:	07bb7c63          	bgeu	s6,s11,ffffffffc0204e0c <do_execve+0x428>
            if (start == end)
ffffffffc0204d98:	df6489e3          	beq	s1,s6,ffffffffc0204b8a <do_execve+0x1a6>
                size -= la - end;
ffffffffc0204d9c:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204da0:	0fb4f563          	bgeu	s1,s11,ffffffffc0204e8a <do_execve+0x4a6>
    return page - pages + nbase;
ffffffffc0204da4:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204da8:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0204dac:	40d406b3          	sub	a3,s0,a3
ffffffffc0204db0:	8699                	srai	a3,a3,0x6
ffffffffc0204db2:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204db4:	00c69593          	slli	a1,a3,0xc
ffffffffc0204db8:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204dba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204dbc:	0ec5f663          	bgeu	a1,a2,ffffffffc0204ea8 <do_execve+0x4c4>
ffffffffc0204dc0:	000ab603          	ld	a2,0(s5)
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204dc4:	6505                	lui	a0,0x1
ffffffffc0204dc6:	955a                	add	a0,a0,s6
ffffffffc0204dc8:	96b2                	add	a3,a3,a2
ffffffffc0204dca:	41b50533          	sub	a0,a0,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204dce:	9536                	add	a0,a0,a3
ffffffffc0204dd0:	864e                	mv	a2,s3
ffffffffc0204dd2:	4581                	li	a1,0
ffffffffc0204dd4:	325000ef          	jal	ffffffffc02058f8 <memset>
            start += size;
ffffffffc0204dd8:	9b4e                	add	s6,s6,s3
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204dda:	01b4b6b3          	sltu	a3,s1,s11
ffffffffc0204dde:	01b4f463          	bgeu	s1,s11,ffffffffc0204de6 <do_execve+0x402>
ffffffffc0204de2:	db6484e3          	beq	s1,s6,ffffffffc0204b8a <do_execve+0x1a6>
ffffffffc0204de6:	e299                	bnez	a3,ffffffffc0204dec <do_execve+0x408>
ffffffffc0204de8:	03bb0263          	beq	s6,s11,ffffffffc0204e0c <do_execve+0x428>
ffffffffc0204dec:	00002697          	auipc	a3,0x2
ffffffffc0204df0:	52c68693          	addi	a3,a3,1324 # ffffffffc0207318 <etext+0x19f6>
ffffffffc0204df4:	00001617          	auipc	a2,0x1
ffffffffc0204df8:	55c60613          	addi	a2,a2,1372 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0204dfc:	2cd00593          	li	a1,717
ffffffffc0204e00:	00002517          	auipc	a0,0x2
ffffffffc0204e04:	32850513          	addi	a0,a0,808 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204e08:	e3efb0ef          	jal	ffffffffc0200446 <__panic>
        while (start < end)
ffffffffc0204e0c:	d69b7fe3          	bgeu	s6,s1,ffffffffc0204b8a <do_execve+0x1a6>
ffffffffc0204e10:	56fd                	li	a3,-1
ffffffffc0204e12:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204e16:	f03e                	sd	a5,32(sp)
ffffffffc0204e18:	a0b9                	j	ffffffffc0204e66 <do_execve+0x482>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e1a:	6785                	lui	a5,0x1
ffffffffc0204e1c:	00fd8833          	add	a6,s11,a5
                size -= la - end;
ffffffffc0204e20:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204e24:	0104e463          	bltu	s1,a6,ffffffffc0204e2c <do_execve+0x448>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e28:	416809b3          	sub	s3,a6,s6
    return page - pages + nbase;
ffffffffc0204e2c:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204e30:	7782                	ld	a5,32(sp)
ffffffffc0204e32:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0204e36:	40d406b3          	sub	a3,s0,a3
ffffffffc0204e3a:	8699                	srai	a3,a3,0x6
ffffffffc0204e3c:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204e3e:	00f6f533          	and	a0,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e42:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e44:	06b57263          	bgeu	a0,a1,ffffffffc0204ea8 <do_execve+0x4c4>
ffffffffc0204e48:	000ab583          	ld	a1,0(s5)
ffffffffc0204e4c:	41bb0533          	sub	a0,s6,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e50:	864e                	mv	a2,s3
ffffffffc0204e52:	96ae                	add	a3,a3,a1
ffffffffc0204e54:	9536                	add	a0,a0,a3
ffffffffc0204e56:	4581                	li	a1,0
            start += size;
ffffffffc0204e58:	9b4e                	add	s6,s6,s3
ffffffffc0204e5a:	e042                	sd	a6,0(sp)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e5c:	29d000ef          	jal	ffffffffc02058f8 <memset>
        while (start < end)
ffffffffc0204e60:	d29b75e3          	bgeu	s6,s1,ffffffffc0204b8a <do_execve+0x1a6>
ffffffffc0204e64:	6d82                	ld	s11,0(sp)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204e66:	01893503          	ld	a0,24(s2)
ffffffffc0204e6a:	6622                	ld	a2,8(sp)
ffffffffc0204e6c:	85ee                	mv	a1,s11
ffffffffc0204e6e:	831fe0ef          	jal	ffffffffc020369e <pgdir_alloc_page>
ffffffffc0204e72:	842a                	mv	s0,a0
ffffffffc0204e74:	f15d                	bnez	a0,ffffffffc0204e1a <do_execve+0x436>
ffffffffc0204e76:	b5cd                	j	ffffffffc0204d58 <do_execve+0x374>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e78:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e7a:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e7c:	e43e                	sd	a5,8(sp)
ffffffffc0204e7e:	b581                	j	ffffffffc0204cbe <do_execve+0x2da>
            perm |= (PTE_W | PTE_R);
ffffffffc0204e80:	47dd                	li	a5,23
            vm_flags |= VM_READ;
ffffffffc0204e82:	00376693          	ori	a3,a4,3
            perm |= (PTE_W | PTE_R);
ffffffffc0204e86:	e43e                	sd	a5,8(sp)
ffffffffc0204e88:	bd1d                	j	ffffffffc0204cbe <do_execve+0x2da>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204e8a:	416d89b3          	sub	s3,s11,s6
ffffffffc0204e8e:	bf19                	j	ffffffffc0204da4 <do_execve+0x3c0>
        return -E_INVAL;
ffffffffc0204e90:	54f5                	li	s1,-3
ffffffffc0204e92:	b3fd                	j	ffffffffc0204c80 <do_execve+0x29c>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e94:	8dae                	mv	s11,a1
        while (start < end)
ffffffffc0204e96:	84da                	mv	s1,s6
ffffffffc0204e98:	bddd                	j	ffffffffc0204d8e <do_execve+0x3aa>
    int ret = -E_NO_MEM;
ffffffffc0204e9a:	54f1                	li	s1,-4
ffffffffc0204e9c:	b1ad                	j	ffffffffc0204b06 <do_execve+0x122>
ffffffffc0204e9e:	6da6                	ld	s11,72(sp)
ffffffffc0204ea0:	bd75                	j	ffffffffc0204d5c <do_execve+0x378>
            ret = -E_INVAL_ELF;
ffffffffc0204ea2:	6da6                	ld	s11,72(sp)
ffffffffc0204ea4:	54e1                	li	s1,-8
ffffffffc0204ea6:	bd5d                	j	ffffffffc0204d5c <do_execve+0x378>
ffffffffc0204ea8:	00002617          	auipc	a2,0x2
ffffffffc0204eac:	85860613          	addi	a2,a2,-1960 # ffffffffc0206700 <etext+0xdde>
ffffffffc0204eb0:	07100593          	li	a1,113
ffffffffc0204eb4:	00002517          	auipc	a0,0x2
ffffffffc0204eb8:	87450513          	addi	a0,a0,-1932 # ffffffffc0206728 <etext+0xe06>
ffffffffc0204ebc:	d8afb0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0204ec0:	00002617          	auipc	a2,0x2
ffffffffc0204ec4:	84060613          	addi	a2,a2,-1984 # ffffffffc0206700 <etext+0xdde>
ffffffffc0204ec8:	07100593          	li	a1,113
ffffffffc0204ecc:	00002517          	auipc	a0,0x2
ffffffffc0204ed0:	85c50513          	addi	a0,a0,-1956 # ffffffffc0206728 <etext+0xe06>
ffffffffc0204ed4:	f122                	sd	s0,160(sp)
ffffffffc0204ed6:	e152                	sd	s4,128(sp)
ffffffffc0204ed8:	e4ee                	sd	s11,72(sp)
ffffffffc0204eda:	d6cfb0ef          	jal	ffffffffc0200446 <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204ede:	00002617          	auipc	a2,0x2
ffffffffc0204ee2:	8ca60613          	addi	a2,a2,-1846 # ffffffffc02067a8 <etext+0xe86>
ffffffffc0204ee6:	2ec00593          	li	a1,748
ffffffffc0204eea:	00002517          	auipc	a0,0x2
ffffffffc0204eee:	23e50513          	addi	a0,a0,574 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204ef2:	e4ee                	sd	s11,72(sp)
ffffffffc0204ef4:	d52fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ef8:	00002697          	auipc	a3,0x2
ffffffffc0204efc:	53868693          	addi	a3,a3,1336 # ffffffffc0207430 <etext+0x1b0e>
ffffffffc0204f00:	00001617          	auipc	a2,0x1
ffffffffc0204f04:	45060613          	addi	a2,a2,1104 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0204f08:	2e700593          	li	a1,743
ffffffffc0204f0c:	00002517          	auipc	a0,0x2
ffffffffc0204f10:	21c50513          	addi	a0,a0,540 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204f14:	e4ee                	sd	s11,72(sp)
ffffffffc0204f16:	d30fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f1a:	00002697          	auipc	a3,0x2
ffffffffc0204f1e:	4ce68693          	addi	a3,a3,1230 # ffffffffc02073e8 <etext+0x1ac6>
ffffffffc0204f22:	00001617          	auipc	a2,0x1
ffffffffc0204f26:	42e60613          	addi	a2,a2,1070 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0204f2a:	2e600593          	li	a1,742
ffffffffc0204f2e:	00002517          	auipc	a0,0x2
ffffffffc0204f32:	1fa50513          	addi	a0,a0,506 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204f36:	e4ee                	sd	s11,72(sp)
ffffffffc0204f38:	d0efb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f3c:	00002697          	auipc	a3,0x2
ffffffffc0204f40:	46468693          	addi	a3,a3,1124 # ffffffffc02073a0 <etext+0x1a7e>
ffffffffc0204f44:	00001617          	auipc	a2,0x1
ffffffffc0204f48:	40c60613          	addi	a2,a2,1036 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0204f4c:	2e500593          	li	a1,741
ffffffffc0204f50:	00002517          	auipc	a0,0x2
ffffffffc0204f54:	1d850513          	addi	a0,a0,472 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204f58:	e4ee                	sd	s11,72(sp)
ffffffffc0204f5a:	cecfb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204f5e:	00002697          	auipc	a3,0x2
ffffffffc0204f62:	3fa68693          	addi	a3,a3,1018 # ffffffffc0207358 <etext+0x1a36>
ffffffffc0204f66:	00001617          	auipc	a2,0x1
ffffffffc0204f6a:	3ea60613          	addi	a2,a2,1002 # ffffffffc0206350 <etext+0xa2e>
ffffffffc0204f6e:	2e400593          	li	a1,740
ffffffffc0204f72:	00002517          	auipc	a0,0x2
ffffffffc0204f76:	1b650513          	addi	a0,a0,438 # ffffffffc0207128 <etext+0x1806>
ffffffffc0204f7a:	e4ee                	sd	s11,72(sp)
ffffffffc0204f7c:	ccafb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204f80 <do_yield>:
    current->need_resched = 1;
ffffffffc0204f80:	00097797          	auipc	a5,0x97
ffffffffc0204f84:	9c87b783          	ld	a5,-1592(a5) # ffffffffc029b948 <current>
ffffffffc0204f88:	4705                	li	a4,1
}
ffffffffc0204f8a:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0204f8c:	ef98                	sd	a4,24(a5)
}
ffffffffc0204f8e:	8082                	ret

ffffffffc0204f90 <do_wait>:
    if (code_store != NULL)
ffffffffc0204f90:	c59d                	beqz	a1,ffffffffc0204fbe <do_wait+0x2e>
{
ffffffffc0204f92:	1101                	addi	sp,sp,-32
ffffffffc0204f94:	e02a                	sd	a0,0(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204f96:	00097517          	auipc	a0,0x97
ffffffffc0204f9a:	9b253503          	ld	a0,-1614(a0) # ffffffffc029b948 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204f9e:	4685                	li	a3,1
ffffffffc0204fa0:	4611                	li	a2,4
ffffffffc0204fa2:	7508                	ld	a0,40(a0)
{
ffffffffc0204fa4:	ec06                	sd	ra,24(sp)
ffffffffc0204fa6:	e42e                	sd	a1,8(sp)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204fa8:	f51fe0ef          	jal	ffffffffc0203ef8 <user_mem_check>
ffffffffc0204fac:	6702                	ld	a4,0(sp)
ffffffffc0204fae:	67a2                	ld	a5,8(sp)
ffffffffc0204fb0:	c909                	beqz	a0,ffffffffc0204fc2 <do_wait+0x32>
}
ffffffffc0204fb2:	60e2                	ld	ra,24(sp)
ffffffffc0204fb4:	85be                	mv	a1,a5
ffffffffc0204fb6:	853a                	mv	a0,a4
ffffffffc0204fb8:	6105                	addi	sp,sp,32
ffffffffc0204fba:	f24ff06f          	j	ffffffffc02046de <do_wait.part.0>
ffffffffc0204fbe:	f20ff06f          	j	ffffffffc02046de <do_wait.part.0>
ffffffffc0204fc2:	60e2                	ld	ra,24(sp)
ffffffffc0204fc4:	5575                	li	a0,-3
ffffffffc0204fc6:	6105                	addi	sp,sp,32
ffffffffc0204fc8:	8082                	ret

ffffffffc0204fca <do_kill>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0204fca:	6789                	lui	a5,0x2
ffffffffc0204fcc:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204fd0:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6bf2>
ffffffffc0204fd2:	06e7e463          	bltu	a5,a4,ffffffffc020503a <do_kill+0x70>
{
ffffffffc0204fd6:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fd8:	45a9                	li	a1,10
{
ffffffffc0204fda:	ec06                	sd	ra,24(sp)
ffffffffc0204fdc:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fde:	484000ef          	jal	ffffffffc0205462 <hash32>
ffffffffc0204fe2:	02051793          	slli	a5,a0,0x20
ffffffffc0204fe6:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204fea:	00093797          	auipc	a5,0x93
ffffffffc0204fee:	8e678793          	addi	a5,a5,-1818 # ffffffffc02978d0 <hash_list>
ffffffffc0204ff2:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc0204ff4:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204ff6:	8536                	mv	a0,a3
        while ((le = list_next(le)) != list)
ffffffffc0204ff8:	a029                	j	ffffffffc0205002 <do_kill+0x38>
            if (proc->pid == pid)
ffffffffc0204ffa:	f2c52703          	lw	a4,-212(a0)
ffffffffc0204ffe:	00c70963          	beq	a4,a2,ffffffffc0205010 <do_kill+0x46>
ffffffffc0205002:	6508                	ld	a0,8(a0)
        while ((le = list_next(le)) != list)
ffffffffc0205004:	fea69be3          	bne	a3,a0,ffffffffc0204ffa <do_kill+0x30>
}
ffffffffc0205008:	60e2                	ld	ra,24(sp)
    return -E_INVAL;
ffffffffc020500a:	5575                	li	a0,-3
}
ffffffffc020500c:	6105                	addi	sp,sp,32
ffffffffc020500e:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0205010:	fd852703          	lw	a4,-40(a0)
ffffffffc0205014:	00177693          	andi	a3,a4,1
ffffffffc0205018:	e29d                	bnez	a3,ffffffffc020503e <do_kill+0x74>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc020501a:	4954                	lw	a3,20(a0)
            proc->flags |= PF_EXITING;
ffffffffc020501c:	00176713          	ori	a4,a4,1
ffffffffc0205020:	fce52c23          	sw	a4,-40(a0)
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205024:	0006c663          	bltz	a3,ffffffffc0205030 <do_kill+0x66>
            return 0;
ffffffffc0205028:	4501                	li	a0,0
}
ffffffffc020502a:	60e2                	ld	ra,24(sp)
ffffffffc020502c:	6105                	addi	sp,sp,32
ffffffffc020502e:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205030:	f2850513          	addi	a0,a0,-216
ffffffffc0205034:	232000ef          	jal	ffffffffc0205266 <wakeup_proc>
ffffffffc0205038:	bfc5                	j	ffffffffc0205028 <do_kill+0x5e>
    return -E_INVAL;
ffffffffc020503a:	5575                	li	a0,-3
}
ffffffffc020503c:	8082                	ret
        return -E_KILLED;
ffffffffc020503e:	555d                	li	a0,-9
ffffffffc0205040:	b7ed                	j	ffffffffc020502a <do_kill+0x60>

ffffffffc0205042 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0205042:	1101                	addi	sp,sp,-32
ffffffffc0205044:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205046:	00097797          	auipc	a5,0x97
ffffffffc020504a:	88a78793          	addi	a5,a5,-1910 # ffffffffc029b8d0 <proc_list>
ffffffffc020504e:	ec06                	sd	ra,24(sp)
ffffffffc0205050:	e822                	sd	s0,16(sp)
ffffffffc0205052:	e04a                	sd	s2,0(sp)
ffffffffc0205054:	00093497          	auipc	s1,0x93
ffffffffc0205058:	87c48493          	addi	s1,s1,-1924 # ffffffffc02978d0 <hash_list>
ffffffffc020505c:	e79c                	sd	a5,8(a5)
ffffffffc020505e:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0205060:	00097717          	auipc	a4,0x97
ffffffffc0205064:	87070713          	addi	a4,a4,-1936 # ffffffffc029b8d0 <proc_list>
ffffffffc0205068:	87a6                	mv	a5,s1
ffffffffc020506a:	e79c                	sd	a5,8(a5)
ffffffffc020506c:	e39c                	sd	a5,0(a5)
ffffffffc020506e:	07c1                	addi	a5,a5,16
ffffffffc0205070:	fee79de3          	bne	a5,a4,ffffffffc020506a <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0205074:	f31fe0ef          	jal	ffffffffc0203fa4 <alloc_proc>
ffffffffc0205078:	00097917          	auipc	s2,0x97
ffffffffc020507c:	8e090913          	addi	s2,s2,-1824 # ffffffffc029b958 <idleproc>
ffffffffc0205080:	00a93023          	sd	a0,0(s2)
ffffffffc0205084:	10050363          	beqz	a0,ffffffffc020518a <proc_init+0x148>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205088:	4789                	li	a5,2
ffffffffc020508a:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc020508c:	00003797          	auipc	a5,0x3
ffffffffc0205090:	f7478793          	addi	a5,a5,-140 # ffffffffc0208000 <bootstack>
ffffffffc0205094:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205096:	0b450413          	addi	s0,a0,180
    idleproc->need_resched = 1;
ffffffffc020509a:	4785                	li	a5,1
ffffffffc020509c:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020509e:	4641                	li	a2,16
ffffffffc02050a0:	8522                	mv	a0,s0
ffffffffc02050a2:	4581                	li	a1,0
ffffffffc02050a4:	055000ef          	jal	ffffffffc02058f8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050a8:	8522                	mv	a0,s0
ffffffffc02050aa:	463d                	li	a2,15
ffffffffc02050ac:	00002597          	auipc	a1,0x2
ffffffffc02050b0:	3e458593          	addi	a1,a1,996 # ffffffffc0207490 <etext+0x1b6e>
ffffffffc02050b4:	057000ef          	jal	ffffffffc020590a <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc02050b8:	00097797          	auipc	a5,0x97
ffffffffc02050bc:	8887a783          	lw	a5,-1912(a5) # ffffffffc029b940 <nr_process>

    current = idleproc;
ffffffffc02050c0:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02050c4:	4601                	li	a2,0
    nr_process++;
ffffffffc02050c6:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02050c8:	4581                	li	a1,0
ffffffffc02050ca:	fffff517          	auipc	a0,0xfffff
ffffffffc02050ce:	7f650513          	addi	a0,a0,2038 # ffffffffc02048c0 <init_main>
    current = idleproc;
ffffffffc02050d2:	00097697          	auipc	a3,0x97
ffffffffc02050d6:	86e6bb23          	sd	a4,-1930(a3) # ffffffffc029b948 <current>
    nr_process++;
ffffffffc02050da:	00097717          	auipc	a4,0x97
ffffffffc02050de:	86f72323          	sw	a5,-1946(a4) # ffffffffc029b940 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02050e2:	c68ff0ef          	jal	ffffffffc020454a <kernel_thread>
ffffffffc02050e6:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc02050e8:	08a05563          	blez	a0,ffffffffc0205172 <proc_init+0x130>
    if (0 < pid && pid < MAX_PID)
ffffffffc02050ec:	6789                	lui	a5,0x2
ffffffffc02050ee:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6bf2>
ffffffffc02050f0:	fff5071b          	addiw	a4,a0,-1
ffffffffc02050f4:	02e7e463          	bltu	a5,a4,ffffffffc020511c <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02050f8:	45a9                	li	a1,10
ffffffffc02050fa:	368000ef          	jal	ffffffffc0205462 <hash32>
ffffffffc02050fe:	02051713          	slli	a4,a0,0x20
ffffffffc0205102:	01c75793          	srli	a5,a4,0x1c
ffffffffc0205106:	00f486b3          	add	a3,s1,a5
ffffffffc020510a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc020510c:	a029                	j	ffffffffc0205116 <proc_init+0xd4>
            if (proc->pid == pid)
ffffffffc020510e:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205112:	04870d63          	beq	a4,s0,ffffffffc020516c <proc_init+0x12a>
    return listelm->next;
ffffffffc0205116:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205118:	fef69be3          	bne	a3,a5,ffffffffc020510e <proc_init+0xcc>
    return NULL;
ffffffffc020511c:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020511e:	0b478413          	addi	s0,a5,180
ffffffffc0205122:	4641                	li	a2,16
ffffffffc0205124:	4581                	li	a1,0
ffffffffc0205126:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205128:	00097717          	auipc	a4,0x97
ffffffffc020512c:	82f73423          	sd	a5,-2008(a4) # ffffffffc029b950 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205130:	7c8000ef          	jal	ffffffffc02058f8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205134:	8522                	mv	a0,s0
ffffffffc0205136:	463d                	li	a2,15
ffffffffc0205138:	00002597          	auipc	a1,0x2
ffffffffc020513c:	38058593          	addi	a1,a1,896 # ffffffffc02074b8 <etext+0x1b96>
ffffffffc0205140:	7ca000ef          	jal	ffffffffc020590a <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205144:	00093783          	ld	a5,0(s2)
ffffffffc0205148:	cfad                	beqz	a5,ffffffffc02051c2 <proc_init+0x180>
ffffffffc020514a:	43dc                	lw	a5,4(a5)
ffffffffc020514c:	ebbd                	bnez	a5,ffffffffc02051c2 <proc_init+0x180>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020514e:	00097797          	auipc	a5,0x97
ffffffffc0205152:	8027b783          	ld	a5,-2046(a5) # ffffffffc029b950 <initproc>
ffffffffc0205156:	c7b1                	beqz	a5,ffffffffc02051a2 <proc_init+0x160>
ffffffffc0205158:	43d8                	lw	a4,4(a5)
ffffffffc020515a:	4785                	li	a5,1
ffffffffc020515c:	04f71363          	bne	a4,a5,ffffffffc02051a2 <proc_init+0x160>
}
ffffffffc0205160:	60e2                	ld	ra,24(sp)
ffffffffc0205162:	6442                	ld	s0,16(sp)
ffffffffc0205164:	64a2                	ld	s1,8(sp)
ffffffffc0205166:	6902                	ld	s2,0(sp)
ffffffffc0205168:	6105                	addi	sp,sp,32
ffffffffc020516a:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020516c:	f2878793          	addi	a5,a5,-216
ffffffffc0205170:	b77d                	j	ffffffffc020511e <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc0205172:	00002617          	auipc	a2,0x2
ffffffffc0205176:	32660613          	addi	a2,a2,806 # ffffffffc0207498 <etext+0x1b76>
ffffffffc020517a:	41000593          	li	a1,1040
ffffffffc020517e:	00002517          	auipc	a0,0x2
ffffffffc0205182:	faa50513          	addi	a0,a0,-86 # ffffffffc0207128 <etext+0x1806>
ffffffffc0205186:	ac0fb0ef          	jal	ffffffffc0200446 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc020518a:	00002617          	auipc	a2,0x2
ffffffffc020518e:	2ee60613          	addi	a2,a2,750 # ffffffffc0207478 <etext+0x1b56>
ffffffffc0205192:	40100593          	li	a1,1025
ffffffffc0205196:	00002517          	auipc	a0,0x2
ffffffffc020519a:	f9250513          	addi	a0,a0,-110 # ffffffffc0207128 <etext+0x1806>
ffffffffc020519e:	aa8fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02051a2:	00002697          	auipc	a3,0x2
ffffffffc02051a6:	34668693          	addi	a3,a3,838 # ffffffffc02074e8 <etext+0x1bc6>
ffffffffc02051aa:	00001617          	auipc	a2,0x1
ffffffffc02051ae:	1a660613          	addi	a2,a2,422 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02051b2:	41700593          	li	a1,1047
ffffffffc02051b6:	00002517          	auipc	a0,0x2
ffffffffc02051ba:	f7250513          	addi	a0,a0,-142 # ffffffffc0207128 <etext+0x1806>
ffffffffc02051be:	a88fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02051c2:	00002697          	auipc	a3,0x2
ffffffffc02051c6:	2fe68693          	addi	a3,a3,766 # ffffffffc02074c0 <etext+0x1b9e>
ffffffffc02051ca:	00001617          	auipc	a2,0x1
ffffffffc02051ce:	18660613          	addi	a2,a2,390 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02051d2:	41600593          	li	a1,1046
ffffffffc02051d6:	00002517          	auipc	a0,0x2
ffffffffc02051da:	f5250513          	addi	a0,a0,-174 # ffffffffc0207128 <etext+0x1806>
ffffffffc02051de:	a68fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02051e2 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc02051e2:	1141                	addi	sp,sp,-16
ffffffffc02051e4:	e022                	sd	s0,0(sp)
ffffffffc02051e6:	e406                	sd	ra,8(sp)
ffffffffc02051e8:	00096417          	auipc	s0,0x96
ffffffffc02051ec:	76040413          	addi	s0,s0,1888 # ffffffffc029b948 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc02051f0:	6018                	ld	a4,0(s0)
ffffffffc02051f2:	6f1c                	ld	a5,24(a4)
ffffffffc02051f4:	dffd                	beqz	a5,ffffffffc02051f2 <cpu_idle+0x10>
        {
            schedule();
ffffffffc02051f6:	104000ef          	jal	ffffffffc02052fa <schedule>
ffffffffc02051fa:	bfdd                	j	ffffffffc02051f0 <cpu_idle+0xe>

ffffffffc02051fc <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02051fc:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205200:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205204:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205206:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205208:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020520c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205210:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205214:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205218:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020521c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205220:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205224:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205228:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020522c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205230:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205234:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205238:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020523a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020523c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205240:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205244:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205248:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020524c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205250:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205254:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205258:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020525c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205260:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205264:	8082                	ret

ffffffffc0205266 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205266:	4118                	lw	a4,0(a0)
{
ffffffffc0205268:	1101                	addi	sp,sp,-32
ffffffffc020526a:	ec06                	sd	ra,24(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020526c:	478d                	li	a5,3
ffffffffc020526e:	06f70763          	beq	a4,a5,ffffffffc02052dc <wakeup_proc+0x76>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205272:	100027f3          	csrr	a5,sstatus
ffffffffc0205276:	8b89                	andi	a5,a5,2
ffffffffc0205278:	eb91                	bnez	a5,ffffffffc020528c <wakeup_proc+0x26>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc020527a:	4789                	li	a5,2
ffffffffc020527c:	02f70763          	beq	a4,a5,ffffffffc02052aa <wakeup_proc+0x44>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205280:	60e2                	ld	ra,24(sp)
            proc->state = PROC_RUNNABLE;
ffffffffc0205282:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205284:	0e052623          	sw	zero,236(a0)
}
ffffffffc0205288:	6105                	addi	sp,sp,32
ffffffffc020528a:	8082                	ret
        intr_disable();
ffffffffc020528c:	e42a                	sd	a0,8(sp)
ffffffffc020528e:	e76fb0ef          	jal	ffffffffc0200904 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205292:	6522                	ld	a0,8(sp)
ffffffffc0205294:	4789                	li	a5,2
ffffffffc0205296:	4118                	lw	a4,0(a0)
ffffffffc0205298:	02f70663          	beq	a4,a5,ffffffffc02052c4 <wakeup_proc+0x5e>
            proc->state = PROC_RUNNABLE;
ffffffffc020529c:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc020529e:	0e052623          	sw	zero,236(a0)
}
ffffffffc02052a2:	60e2                	ld	ra,24(sp)
ffffffffc02052a4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02052a6:	e58fb06f          	j	ffffffffc02008fe <intr_enable>
ffffffffc02052aa:	60e2                	ld	ra,24(sp)
            warn("wakeup runnable process.\n");
ffffffffc02052ac:	00002617          	auipc	a2,0x2
ffffffffc02052b0:	29c60613          	addi	a2,a2,668 # ffffffffc0207548 <etext+0x1c26>
ffffffffc02052b4:	45d1                	li	a1,20
ffffffffc02052b6:	00002517          	auipc	a0,0x2
ffffffffc02052ba:	27a50513          	addi	a0,a0,634 # ffffffffc0207530 <etext+0x1c0e>
}
ffffffffc02052be:	6105                	addi	sp,sp,32
            warn("wakeup runnable process.\n");
ffffffffc02052c0:	9f0fb06f          	j	ffffffffc02004b0 <__warn>
ffffffffc02052c4:	00002617          	auipc	a2,0x2
ffffffffc02052c8:	28460613          	addi	a2,a2,644 # ffffffffc0207548 <etext+0x1c26>
ffffffffc02052cc:	45d1                	li	a1,20
ffffffffc02052ce:	00002517          	auipc	a0,0x2
ffffffffc02052d2:	26250513          	addi	a0,a0,610 # ffffffffc0207530 <etext+0x1c0e>
ffffffffc02052d6:	9dafb0ef          	jal	ffffffffc02004b0 <__warn>
    if (flag)
ffffffffc02052da:	b7e1                	j	ffffffffc02052a2 <wakeup_proc+0x3c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02052dc:	00002697          	auipc	a3,0x2
ffffffffc02052e0:	23468693          	addi	a3,a3,564 # ffffffffc0207510 <etext+0x1bee>
ffffffffc02052e4:	00001617          	auipc	a2,0x1
ffffffffc02052e8:	06c60613          	addi	a2,a2,108 # ffffffffc0206350 <etext+0xa2e>
ffffffffc02052ec:	45a5                	li	a1,9
ffffffffc02052ee:	00002517          	auipc	a0,0x2
ffffffffc02052f2:	24250513          	addi	a0,a0,578 # ffffffffc0207530 <etext+0x1c0e>
ffffffffc02052f6:	950fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02052fa <schedule>:

void schedule(void)
{
ffffffffc02052fa:	1101                	addi	sp,sp,-32
ffffffffc02052fc:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02052fe:	100027f3          	csrr	a5,sstatus
ffffffffc0205302:	8b89                	andi	a5,a5,2
ffffffffc0205304:	4301                	li	t1,0
ffffffffc0205306:	e3c1                	bnez	a5,ffffffffc0205386 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205308:	00096897          	auipc	a7,0x96
ffffffffc020530c:	6408b883          	ld	a7,1600(a7) # ffffffffc029b948 <current>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205310:	00096517          	auipc	a0,0x96
ffffffffc0205314:	64853503          	ld	a0,1608(a0) # ffffffffc029b958 <idleproc>
        current->need_resched = 0;
ffffffffc0205318:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020531c:	04a88f63          	beq	a7,a0,ffffffffc020537a <schedule+0x80>
ffffffffc0205320:	0c888693          	addi	a3,a7,200
ffffffffc0205324:	00096617          	auipc	a2,0x96
ffffffffc0205328:	5ac60613          	addi	a2,a2,1452 # ffffffffc029b8d0 <proc_list>
        le = last;
ffffffffc020532c:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020532e:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc0205330:	4809                	li	a6,2
ffffffffc0205332:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc0205334:	00c78863          	beq	a5,a2,ffffffffc0205344 <schedule+0x4a>
                if (next->state == PROC_RUNNABLE)
ffffffffc0205338:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020533c:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc0205340:	03070363          	beq	a4,a6,ffffffffc0205366 <schedule+0x6c>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc0205344:	fef697e3          	bne	a3,a5,ffffffffc0205332 <schedule+0x38>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205348:	ed99                	bnez	a1,ffffffffc0205366 <schedule+0x6c>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc020534a:	451c                	lw	a5,8(a0)
ffffffffc020534c:	2785                	addiw	a5,a5,1
ffffffffc020534e:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc0205350:	00a88663          	beq	a7,a0,ffffffffc020535c <schedule+0x62>
ffffffffc0205354:	e41a                	sd	t1,8(sp)
        {
            proc_run(next);
ffffffffc0205356:	dc3fe0ef          	jal	ffffffffc0204118 <proc_run>
ffffffffc020535a:	6322                	ld	t1,8(sp)
    if (flag)
ffffffffc020535c:	00031b63          	bnez	t1,ffffffffc0205372 <schedule+0x78>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205360:	60e2                	ld	ra,24(sp)
ffffffffc0205362:	6105                	addi	sp,sp,32
ffffffffc0205364:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205366:	4198                	lw	a4,0(a1)
ffffffffc0205368:	4789                	li	a5,2
ffffffffc020536a:	fef710e3          	bne	a4,a5,ffffffffc020534a <schedule+0x50>
ffffffffc020536e:	852e                	mv	a0,a1
ffffffffc0205370:	bfe9                	j	ffffffffc020534a <schedule+0x50>
}
ffffffffc0205372:	60e2                	ld	ra,24(sp)
ffffffffc0205374:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205376:	d88fb06f          	j	ffffffffc02008fe <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020537a:	00096617          	auipc	a2,0x96
ffffffffc020537e:	55660613          	addi	a2,a2,1366 # ffffffffc029b8d0 <proc_list>
ffffffffc0205382:	86b2                	mv	a3,a2
ffffffffc0205384:	b765                	j	ffffffffc020532c <schedule+0x32>
        intr_disable();
ffffffffc0205386:	d7efb0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc020538a:	4305                	li	t1,1
ffffffffc020538c:	bfb5                	j	ffffffffc0205308 <schedule+0xe>

ffffffffc020538e <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020538e:	00096797          	auipc	a5,0x96
ffffffffc0205392:	5ba7b783          	ld	a5,1466(a5) # ffffffffc029b948 <current>
}
ffffffffc0205396:	43c8                	lw	a0,4(a5)
ffffffffc0205398:	8082                	ret

ffffffffc020539a <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020539a:	4501                	li	a0,0
ffffffffc020539c:	8082                	ret

ffffffffc020539e <sys_putc>:
    cputchar(c);
ffffffffc020539e:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02053a0:	1141                	addi	sp,sp,-16
ffffffffc02053a2:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02053a4:	e25fa0ef          	jal	ffffffffc02001c8 <cputchar>
}
ffffffffc02053a8:	60a2                	ld	ra,8(sp)
ffffffffc02053aa:	4501                	li	a0,0
ffffffffc02053ac:	0141                	addi	sp,sp,16
ffffffffc02053ae:	8082                	ret

ffffffffc02053b0 <sys_kill>:
    return do_kill(pid);
ffffffffc02053b0:	4108                	lw	a0,0(a0)
ffffffffc02053b2:	c19ff06f          	j	ffffffffc0204fca <do_kill>

ffffffffc02053b6 <sys_yield>:
    return do_yield();
ffffffffc02053b6:	bcbff06f          	j	ffffffffc0204f80 <do_yield>

ffffffffc02053ba <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02053ba:	6d14                	ld	a3,24(a0)
ffffffffc02053bc:	6910                	ld	a2,16(a0)
ffffffffc02053be:	650c                	ld	a1,8(a0)
ffffffffc02053c0:	6108                	ld	a0,0(a0)
ffffffffc02053c2:	e22ff06f          	j	ffffffffc02049e4 <do_execve>

ffffffffc02053c6 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02053c6:	650c                	ld	a1,8(a0)
ffffffffc02053c8:	4108                	lw	a0,0(a0)
ffffffffc02053ca:	bc7ff06f          	j	ffffffffc0204f90 <do_wait>

ffffffffc02053ce <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02053ce:	00096797          	auipc	a5,0x96
ffffffffc02053d2:	57a7b783          	ld	a5,1402(a5) # ffffffffc029b948 <current>
    return do_fork(0, stack, tf);
ffffffffc02053d6:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02053d8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02053da:	6a0c                	ld	a1,16(a2)
ffffffffc02053dc:	d9ffe06f          	j	ffffffffc020417a <do_fork>

ffffffffc02053e0 <sys_exit>:
    return do_exit(error_code);
ffffffffc02053e0:	4108                	lw	a0,0(a0)
ffffffffc02053e2:	9b8ff06f          	j	ffffffffc020459a <do_exit>

ffffffffc02053e6 <syscall>:

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    struct trapframe *tf = current->tf;
ffffffffc02053e6:	00096697          	auipc	a3,0x96
ffffffffc02053ea:	5626b683          	ld	a3,1378(a3) # ffffffffc029b948 <current>
syscall(void) {
ffffffffc02053ee:	715d                	addi	sp,sp,-80
ffffffffc02053f0:	e0a2                	sd	s0,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc02053f2:	72c0                	ld	s0,160(a3)
syscall(void) {
ffffffffc02053f4:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02053f6:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02053f8:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02053fa:	02d7ec63          	bltu	a5,a3,ffffffffc0205432 <syscall+0x4c>
        if (syscalls[num] != NULL) {
ffffffffc02053fe:	00002797          	auipc	a5,0x2
ffffffffc0205402:	39278793          	addi	a5,a5,914 # ffffffffc0207790 <syscalls>
ffffffffc0205406:	00369613          	slli	a2,a3,0x3
ffffffffc020540a:	97b2                	add	a5,a5,a2
ffffffffc020540c:	639c                	ld	a5,0(a5)
ffffffffc020540e:	c395                	beqz	a5,ffffffffc0205432 <syscall+0x4c>
            arg[0] = tf->gpr.a1;
ffffffffc0205410:	7028                	ld	a0,96(s0)
ffffffffc0205412:	742c                	ld	a1,104(s0)
ffffffffc0205414:	7830                	ld	a2,112(s0)
ffffffffc0205416:	7c34                	ld	a3,120(s0)
ffffffffc0205418:	6c38                	ld	a4,88(s0)
ffffffffc020541a:	f02a                	sd	a0,32(sp)
ffffffffc020541c:	f42e                	sd	a1,40(sp)
ffffffffc020541e:	f832                	sd	a2,48(sp)
ffffffffc0205420:	fc36                	sd	a3,56(sp)
ffffffffc0205422:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205424:	0828                	addi	a0,sp,24
ffffffffc0205426:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205428:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020542a:	e828                	sd	a0,80(s0)
}
ffffffffc020542c:	6406                	ld	s0,64(sp)
ffffffffc020542e:	6161                	addi	sp,sp,80
ffffffffc0205430:	8082                	ret
    print_trapframe(tf);
ffffffffc0205432:	8522                	mv	a0,s0
ffffffffc0205434:	e436                	sd	a3,8(sp)
ffffffffc0205436:	ebefb0ef          	jal	ffffffffc0200af4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020543a:	00096797          	auipc	a5,0x96
ffffffffc020543e:	50e7b783          	ld	a5,1294(a5) # ffffffffc029b948 <current>
ffffffffc0205442:	66a2                	ld	a3,8(sp)
ffffffffc0205444:	00002617          	auipc	a2,0x2
ffffffffc0205448:	12460613          	addi	a2,a2,292 # ffffffffc0207568 <etext+0x1c46>
ffffffffc020544c:	43d8                	lw	a4,4(a5)
ffffffffc020544e:	06200593          	li	a1,98
ffffffffc0205452:	0b478793          	addi	a5,a5,180
ffffffffc0205456:	00002517          	auipc	a0,0x2
ffffffffc020545a:	14250513          	addi	a0,a0,322 # ffffffffc0207598 <etext+0x1c76>
ffffffffc020545e:	fe9fa0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0205462 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205462:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205466:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_exit_out_size+0xffffffff9e365e19>
ffffffffc0205468:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc020546c:	02000513          	li	a0,32
ffffffffc0205470:	9d0d                	subw	a0,a0,a1
}
ffffffffc0205472:	00a7d53b          	srlw	a0,a5,a0
ffffffffc0205476:	8082                	ret

ffffffffc0205478 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205478:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020547a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020547e:	f022                	sd	s0,32(sp)
ffffffffc0205480:	ec26                	sd	s1,24(sp)
ffffffffc0205482:	e84a                	sd	s2,16(sp)
ffffffffc0205484:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205486:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020548a:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc020548c:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205490:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205494:	84aa                	mv	s1,a0
ffffffffc0205496:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc0205498:	03067d63          	bgeu	a2,a6,ffffffffc02054d2 <printnum+0x5a>
ffffffffc020549c:	e44e                	sd	s3,8(sp)
ffffffffc020549e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02054a0:	4785                	li	a5,1
ffffffffc02054a2:	00e7d763          	bge	a5,a4,ffffffffc02054b0 <printnum+0x38>
            putch(padc, putdat);
ffffffffc02054a6:	85ca                	mv	a1,s2
ffffffffc02054a8:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02054aa:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02054ac:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02054ae:	fc65                	bnez	s0,ffffffffc02054a6 <printnum+0x2e>
ffffffffc02054b0:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054b2:	00002797          	auipc	a5,0x2
ffffffffc02054b6:	0fe78793          	addi	a5,a5,254 # ffffffffc02075b0 <etext+0x1c8e>
ffffffffc02054ba:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02054bc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054be:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02054c2:	70a2                	ld	ra,40(sp)
ffffffffc02054c4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054c6:	85ca                	mv	a1,s2
ffffffffc02054c8:	87a6                	mv	a5,s1
}
ffffffffc02054ca:	6942                	ld	s2,16(sp)
ffffffffc02054cc:	64e2                	ld	s1,24(sp)
ffffffffc02054ce:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054d0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02054d2:	03065633          	divu	a2,a2,a6
ffffffffc02054d6:	8722                	mv	a4,s0
ffffffffc02054d8:	fa1ff0ef          	jal	ffffffffc0205478 <printnum>
ffffffffc02054dc:	bfd9                	j	ffffffffc02054b2 <printnum+0x3a>

ffffffffc02054de <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02054de:	7119                	addi	sp,sp,-128
ffffffffc02054e0:	f4a6                	sd	s1,104(sp)
ffffffffc02054e2:	f0ca                	sd	s2,96(sp)
ffffffffc02054e4:	ecce                	sd	s3,88(sp)
ffffffffc02054e6:	e8d2                	sd	s4,80(sp)
ffffffffc02054e8:	e4d6                	sd	s5,72(sp)
ffffffffc02054ea:	e0da                	sd	s6,64(sp)
ffffffffc02054ec:	f862                	sd	s8,48(sp)
ffffffffc02054ee:	fc86                	sd	ra,120(sp)
ffffffffc02054f0:	f8a2                	sd	s0,112(sp)
ffffffffc02054f2:	fc5e                	sd	s7,56(sp)
ffffffffc02054f4:	f466                	sd	s9,40(sp)
ffffffffc02054f6:	f06a                	sd	s10,32(sp)
ffffffffc02054f8:	ec6e                	sd	s11,24(sp)
ffffffffc02054fa:	84aa                	mv	s1,a0
ffffffffc02054fc:	8c32                	mv	s8,a2
ffffffffc02054fe:	8a36                	mv	s4,a3
ffffffffc0205500:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205502:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205506:	05500b13          	li	s6,85
ffffffffc020550a:	00002a97          	auipc	s5,0x2
ffffffffc020550e:	386a8a93          	addi	s5,s5,902 # ffffffffc0207890 <syscalls+0x100>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205512:	000c4503          	lbu	a0,0(s8)
ffffffffc0205516:	001c0413          	addi	s0,s8,1
ffffffffc020551a:	01350a63          	beq	a0,s3,ffffffffc020552e <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020551e:	cd0d                	beqz	a0,ffffffffc0205558 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0205520:	85ca                	mv	a1,s2
ffffffffc0205522:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205524:	00044503          	lbu	a0,0(s0)
ffffffffc0205528:	0405                	addi	s0,s0,1
ffffffffc020552a:	ff351ae3          	bne	a0,s3,ffffffffc020551e <vprintfmt+0x40>
        width = precision = -1;
ffffffffc020552e:	5cfd                	li	s9,-1
ffffffffc0205530:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0205532:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0205536:	4b81                	li	s7,0
ffffffffc0205538:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020553a:	00044683          	lbu	a3,0(s0)
ffffffffc020553e:	00140c13          	addi	s8,s0,1
ffffffffc0205542:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0205546:	0ff5f593          	zext.b	a1,a1
ffffffffc020554a:	02bb6663          	bltu	s6,a1,ffffffffc0205576 <vprintfmt+0x98>
ffffffffc020554e:	058a                	slli	a1,a1,0x2
ffffffffc0205550:	95d6                	add	a1,a1,s5
ffffffffc0205552:	4198                	lw	a4,0(a1)
ffffffffc0205554:	9756                	add	a4,a4,s5
ffffffffc0205556:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205558:	70e6                	ld	ra,120(sp)
ffffffffc020555a:	7446                	ld	s0,112(sp)
ffffffffc020555c:	74a6                	ld	s1,104(sp)
ffffffffc020555e:	7906                	ld	s2,96(sp)
ffffffffc0205560:	69e6                	ld	s3,88(sp)
ffffffffc0205562:	6a46                	ld	s4,80(sp)
ffffffffc0205564:	6aa6                	ld	s5,72(sp)
ffffffffc0205566:	6b06                	ld	s6,64(sp)
ffffffffc0205568:	7be2                	ld	s7,56(sp)
ffffffffc020556a:	7c42                	ld	s8,48(sp)
ffffffffc020556c:	7ca2                	ld	s9,40(sp)
ffffffffc020556e:	7d02                	ld	s10,32(sp)
ffffffffc0205570:	6de2                	ld	s11,24(sp)
ffffffffc0205572:	6109                	addi	sp,sp,128
ffffffffc0205574:	8082                	ret
            putch('%', putdat);
ffffffffc0205576:	85ca                	mv	a1,s2
ffffffffc0205578:	02500513          	li	a0,37
ffffffffc020557c:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020557e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205582:	02500713          	li	a4,37
ffffffffc0205586:	8c22                	mv	s8,s0
ffffffffc0205588:	f8e785e3          	beq	a5,a4,ffffffffc0205512 <vprintfmt+0x34>
ffffffffc020558c:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0205590:	1c7d                	addi	s8,s8,-1
ffffffffc0205592:	fee79de3          	bne	a5,a4,ffffffffc020558c <vprintfmt+0xae>
ffffffffc0205596:	bfb5                	j	ffffffffc0205512 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0205598:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc020559c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc020559e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02055a2:	fd06071b          	addiw	a4,a2,-48
ffffffffc02055a6:	24e56a63          	bltu	a0,a4,ffffffffc02057fa <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc02055aa:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055ac:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc02055ae:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc02055b2:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02055b6:	0197073b          	addw	a4,a4,s9
ffffffffc02055ba:	0017171b          	slliw	a4,a4,0x1
ffffffffc02055be:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc02055c0:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02055c4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02055c6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02055ca:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc02055ce:	feb570e3          	bgeu	a0,a1,ffffffffc02055ae <vprintfmt+0xd0>
            if (width < 0)
ffffffffc02055d2:	f60d54e3          	bgez	s10,ffffffffc020553a <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc02055d6:	8d66                	mv	s10,s9
ffffffffc02055d8:	5cfd                	li	s9,-1
ffffffffc02055da:	b785                	j	ffffffffc020553a <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055dc:	8db6                	mv	s11,a3
ffffffffc02055de:	8462                	mv	s0,s8
ffffffffc02055e0:	bfa9                	j	ffffffffc020553a <vprintfmt+0x5c>
ffffffffc02055e2:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc02055e4:	4b85                	li	s7,1
            goto reswitch;
ffffffffc02055e6:	bf91                	j	ffffffffc020553a <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc02055e8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055ea:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02055ee:	00f74463          	blt	a4,a5,ffffffffc02055f6 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc02055f2:	1a078763          	beqz	a5,ffffffffc02057a0 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc02055f6:	000a3603          	ld	a2,0(s4)
ffffffffc02055fa:	46c1                	li	a3,16
ffffffffc02055fc:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02055fe:	000d879b          	sext.w	a5,s11
ffffffffc0205602:	876a                	mv	a4,s10
ffffffffc0205604:	85ca                	mv	a1,s2
ffffffffc0205606:	8526                	mv	a0,s1
ffffffffc0205608:	e71ff0ef          	jal	ffffffffc0205478 <printnum>
            break;
ffffffffc020560c:	b719                	j	ffffffffc0205512 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020560e:	000a2503          	lw	a0,0(s4)
ffffffffc0205612:	85ca                	mv	a1,s2
ffffffffc0205614:	0a21                	addi	s4,s4,8
ffffffffc0205616:	9482                	jalr	s1
            break;
ffffffffc0205618:	bded                	j	ffffffffc0205512 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020561a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020561c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205620:	00f74463          	blt	a4,a5,ffffffffc0205628 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0205624:	16078963          	beqz	a5,ffffffffc0205796 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0205628:	000a3603          	ld	a2,0(s4)
ffffffffc020562c:	46a9                	li	a3,10
ffffffffc020562e:	8a2e                	mv	s4,a1
ffffffffc0205630:	b7f9                	j	ffffffffc02055fe <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0205632:	85ca                	mv	a1,s2
ffffffffc0205634:	03000513          	li	a0,48
ffffffffc0205638:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc020563a:	85ca                	mv	a1,s2
ffffffffc020563c:	07800513          	li	a0,120
ffffffffc0205640:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205642:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0205646:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205648:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020564a:	bf55                	j	ffffffffc02055fe <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc020564c:	85ca                	mv	a1,s2
ffffffffc020564e:	02500513          	li	a0,37
ffffffffc0205652:	9482                	jalr	s1
            break;
ffffffffc0205654:	bd7d                	j	ffffffffc0205512 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0205656:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020565a:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc020565c:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc020565e:	bf95                	j	ffffffffc02055d2 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0205660:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205662:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205666:	00f74463          	blt	a4,a5,ffffffffc020566e <vprintfmt+0x190>
    else if (lflag) {
ffffffffc020566a:	12078163          	beqz	a5,ffffffffc020578c <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc020566e:	000a3603          	ld	a2,0(s4)
ffffffffc0205672:	46a1                	li	a3,8
ffffffffc0205674:	8a2e                	mv	s4,a1
ffffffffc0205676:	b761                	j	ffffffffc02055fe <vprintfmt+0x120>
            if (width < 0)
ffffffffc0205678:	876a                	mv	a4,s10
ffffffffc020567a:	000d5363          	bgez	s10,ffffffffc0205680 <vprintfmt+0x1a2>
ffffffffc020567e:	4701                	li	a4,0
ffffffffc0205680:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205684:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0205686:	bd55                	j	ffffffffc020553a <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc0205688:	000d841b          	sext.w	s0,s11
ffffffffc020568c:	fd340793          	addi	a5,s0,-45
ffffffffc0205690:	00f037b3          	snez	a5,a5
ffffffffc0205694:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205698:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc020569c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020569e:	008a0793          	addi	a5,s4,8
ffffffffc02056a2:	e43e                	sd	a5,8(sp)
ffffffffc02056a4:	100d8c63          	beqz	s11,ffffffffc02057bc <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02056a8:	12071363          	bnez	a4,ffffffffc02057ce <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056ac:	000dc783          	lbu	a5,0(s11)
ffffffffc02056b0:	0007851b          	sext.w	a0,a5
ffffffffc02056b4:	c78d                	beqz	a5,ffffffffc02056de <vprintfmt+0x200>
ffffffffc02056b6:	0d85                	addi	s11,s11,1
ffffffffc02056b8:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056ba:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056be:	000cc563          	bltz	s9,ffffffffc02056c8 <vprintfmt+0x1ea>
ffffffffc02056c2:	3cfd                	addiw	s9,s9,-1
ffffffffc02056c4:	008c8d63          	beq	s9,s0,ffffffffc02056de <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056c8:	020b9663          	bnez	s7,ffffffffc02056f4 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc02056cc:	85ca                	mv	a1,s2
ffffffffc02056ce:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056d0:	000dc783          	lbu	a5,0(s11)
ffffffffc02056d4:	0d85                	addi	s11,s11,1
ffffffffc02056d6:	3d7d                	addiw	s10,s10,-1
ffffffffc02056d8:	0007851b          	sext.w	a0,a5
ffffffffc02056dc:	f3ed                	bnez	a5,ffffffffc02056be <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc02056de:	01a05963          	blez	s10,ffffffffc02056f0 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc02056e2:	85ca                	mv	a1,s2
ffffffffc02056e4:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc02056e8:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc02056ea:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc02056ec:	fe0d1be3          	bnez	s10,ffffffffc02056e2 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056f0:	6a22                	ld	s4,8(sp)
ffffffffc02056f2:	b505                	j	ffffffffc0205512 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056f4:	3781                	addiw	a5,a5,-32
ffffffffc02056f6:	fcfa7be3          	bgeu	s4,a5,ffffffffc02056cc <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc02056fa:	03f00513          	li	a0,63
ffffffffc02056fe:	85ca                	mv	a1,s2
ffffffffc0205700:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205702:	000dc783          	lbu	a5,0(s11)
ffffffffc0205706:	0d85                	addi	s11,s11,1
ffffffffc0205708:	3d7d                	addiw	s10,s10,-1
ffffffffc020570a:	0007851b          	sext.w	a0,a5
ffffffffc020570e:	dbe1                	beqz	a5,ffffffffc02056de <vprintfmt+0x200>
ffffffffc0205710:	fa0cd9e3          	bgez	s9,ffffffffc02056c2 <vprintfmt+0x1e4>
ffffffffc0205714:	b7c5                	j	ffffffffc02056f4 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0205716:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020571a:	4661                	li	a2,24
            err = va_arg(ap, int);
ffffffffc020571c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020571e:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0205722:	8fb9                	xor	a5,a5,a4
ffffffffc0205724:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205728:	02d64563          	blt	a2,a3,ffffffffc0205752 <vprintfmt+0x274>
ffffffffc020572c:	00002797          	auipc	a5,0x2
ffffffffc0205730:	2bc78793          	addi	a5,a5,700 # ffffffffc02079e8 <error_string>
ffffffffc0205734:	00369713          	slli	a4,a3,0x3
ffffffffc0205738:	97ba                	add	a5,a5,a4
ffffffffc020573a:	639c                	ld	a5,0(a5)
ffffffffc020573c:	cb99                	beqz	a5,ffffffffc0205752 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc020573e:	86be                	mv	a3,a5
ffffffffc0205740:	00000617          	auipc	a2,0x0
ffffffffc0205744:	21060613          	addi	a2,a2,528 # ffffffffc0205950 <etext+0x2e>
ffffffffc0205748:	85ca                	mv	a1,s2
ffffffffc020574a:	8526                	mv	a0,s1
ffffffffc020574c:	0d8000ef          	jal	ffffffffc0205824 <printfmt>
ffffffffc0205750:	b3c9                	j	ffffffffc0205512 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205752:	00002617          	auipc	a2,0x2
ffffffffc0205756:	e7e60613          	addi	a2,a2,-386 # ffffffffc02075d0 <etext+0x1cae>
ffffffffc020575a:	85ca                	mv	a1,s2
ffffffffc020575c:	8526                	mv	a0,s1
ffffffffc020575e:	0c6000ef          	jal	ffffffffc0205824 <printfmt>
ffffffffc0205762:	bb45                	j	ffffffffc0205512 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0205764:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205766:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc020576a:	00f74363          	blt	a4,a5,ffffffffc0205770 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc020576e:	cf81                	beqz	a5,ffffffffc0205786 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc0205770:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205774:	02044b63          	bltz	s0,ffffffffc02057aa <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0205778:	8622                	mv	a2,s0
ffffffffc020577a:	8a5e                	mv	s4,s7
ffffffffc020577c:	46a9                	li	a3,10
ffffffffc020577e:	b541                	j	ffffffffc02055fe <vprintfmt+0x120>
            lflag ++;
ffffffffc0205780:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205782:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0205784:	bb5d                	j	ffffffffc020553a <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0205786:	000a2403          	lw	s0,0(s4)
ffffffffc020578a:	b7ed                	j	ffffffffc0205774 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc020578c:	000a6603          	lwu	a2,0(s4)
ffffffffc0205790:	46a1                	li	a3,8
ffffffffc0205792:	8a2e                	mv	s4,a1
ffffffffc0205794:	b5ad                	j	ffffffffc02055fe <vprintfmt+0x120>
ffffffffc0205796:	000a6603          	lwu	a2,0(s4)
ffffffffc020579a:	46a9                	li	a3,10
ffffffffc020579c:	8a2e                	mv	s4,a1
ffffffffc020579e:	b585                	j	ffffffffc02055fe <vprintfmt+0x120>
ffffffffc02057a0:	000a6603          	lwu	a2,0(s4)
ffffffffc02057a4:	46c1                	li	a3,16
ffffffffc02057a6:	8a2e                	mv	s4,a1
ffffffffc02057a8:	bd99                	j	ffffffffc02055fe <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc02057aa:	85ca                	mv	a1,s2
ffffffffc02057ac:	02d00513          	li	a0,45
ffffffffc02057b0:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc02057b2:	40800633          	neg	a2,s0
ffffffffc02057b6:	8a5e                	mv	s4,s7
ffffffffc02057b8:	46a9                	li	a3,10
ffffffffc02057ba:	b591                	j	ffffffffc02055fe <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc02057bc:	e329                	bnez	a4,ffffffffc02057fe <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057be:	02800793          	li	a5,40
ffffffffc02057c2:	853e                	mv	a0,a5
ffffffffc02057c4:	00002d97          	auipc	s11,0x2
ffffffffc02057c8:	e05d8d93          	addi	s11,s11,-507 # ffffffffc02075c9 <etext+0x1ca7>
ffffffffc02057cc:	b5f5                	j	ffffffffc02056b8 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02057ce:	85e6                	mv	a1,s9
ffffffffc02057d0:	856e                	mv	a0,s11
ffffffffc02057d2:	08a000ef          	jal	ffffffffc020585c <strnlen>
ffffffffc02057d6:	40ad0d3b          	subw	s10,s10,a0
ffffffffc02057da:	01a05863          	blez	s10,ffffffffc02057ea <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc02057de:	85ca                	mv	a1,s2
ffffffffc02057e0:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02057e2:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc02057e4:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02057e6:	fe0d1ce3          	bnez	s10,ffffffffc02057de <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057ea:	000dc783          	lbu	a5,0(s11)
ffffffffc02057ee:	0007851b          	sext.w	a0,a5
ffffffffc02057f2:	ec0792e3          	bnez	a5,ffffffffc02056b6 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02057f6:	6a22                	ld	s4,8(sp)
ffffffffc02057f8:	bb29                	j	ffffffffc0205512 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057fa:	8462                	mv	s0,s8
ffffffffc02057fc:	bbd9                	j	ffffffffc02055d2 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02057fe:	85e6                	mv	a1,s9
ffffffffc0205800:	00002517          	auipc	a0,0x2
ffffffffc0205804:	dc850513          	addi	a0,a0,-568 # ffffffffc02075c8 <etext+0x1ca6>
ffffffffc0205808:	054000ef          	jal	ffffffffc020585c <strnlen>
ffffffffc020580c:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205810:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0205814:	00002d97          	auipc	s11,0x2
ffffffffc0205818:	db4d8d93          	addi	s11,s11,-588 # ffffffffc02075c8 <etext+0x1ca6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020581c:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020581e:	fda040e3          	bgtz	s10,ffffffffc02057de <vprintfmt+0x300>
ffffffffc0205822:	bd51                	j	ffffffffc02056b6 <vprintfmt+0x1d8>

ffffffffc0205824 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205824:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205826:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020582a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020582c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020582e:	ec06                	sd	ra,24(sp)
ffffffffc0205830:	f83a                	sd	a4,48(sp)
ffffffffc0205832:	fc3e                	sd	a5,56(sp)
ffffffffc0205834:	e0c2                	sd	a6,64(sp)
ffffffffc0205836:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205838:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020583a:	ca5ff0ef          	jal	ffffffffc02054de <vprintfmt>
}
ffffffffc020583e:	60e2                	ld	ra,24(sp)
ffffffffc0205840:	6161                	addi	sp,sp,80
ffffffffc0205842:	8082                	ret

ffffffffc0205844 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205844:	00054783          	lbu	a5,0(a0)
ffffffffc0205848:	cb81                	beqz	a5,ffffffffc0205858 <strlen+0x14>
    size_t cnt = 0;
ffffffffc020584a:	4781                	li	a5,0
        cnt ++;
ffffffffc020584c:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020584e:	00f50733          	add	a4,a0,a5
ffffffffc0205852:	00074703          	lbu	a4,0(a4)
ffffffffc0205856:	fb7d                	bnez	a4,ffffffffc020584c <strlen+0x8>
    }
    return cnt;
}
ffffffffc0205858:	853e                	mv	a0,a5
ffffffffc020585a:	8082                	ret

ffffffffc020585c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020585c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020585e:	e589                	bnez	a1,ffffffffc0205868 <strnlen+0xc>
ffffffffc0205860:	a811                	j	ffffffffc0205874 <strnlen+0x18>
        cnt ++;
ffffffffc0205862:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205864:	00f58863          	beq	a1,a5,ffffffffc0205874 <strnlen+0x18>
ffffffffc0205868:	00f50733          	add	a4,a0,a5
ffffffffc020586c:	00074703          	lbu	a4,0(a4)
ffffffffc0205870:	fb6d                	bnez	a4,ffffffffc0205862 <strnlen+0x6>
ffffffffc0205872:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205874:	852e                	mv	a0,a1
ffffffffc0205876:	8082                	ret

ffffffffc0205878 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205878:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020587a:	0005c703          	lbu	a4,0(a1)
ffffffffc020587e:	0585                	addi	a1,a1,1
ffffffffc0205880:	0785                	addi	a5,a5,1
ffffffffc0205882:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205886:	fb75                	bnez	a4,ffffffffc020587a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205888:	8082                	ret

ffffffffc020588a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020588a:	00054783          	lbu	a5,0(a0)
ffffffffc020588e:	e791                	bnez	a5,ffffffffc020589a <strcmp+0x10>
ffffffffc0205890:	a01d                	j	ffffffffc02058b6 <strcmp+0x2c>
ffffffffc0205892:	00054783          	lbu	a5,0(a0)
ffffffffc0205896:	cb99                	beqz	a5,ffffffffc02058ac <strcmp+0x22>
ffffffffc0205898:	0585                	addi	a1,a1,1
ffffffffc020589a:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc020589e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02058a0:	fef709e3          	beq	a4,a5,ffffffffc0205892 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058a4:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02058a8:	9d19                	subw	a0,a0,a4
ffffffffc02058aa:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058ac:	0015c703          	lbu	a4,1(a1)
ffffffffc02058b0:	4501                	li	a0,0
}
ffffffffc02058b2:	9d19                	subw	a0,a0,a4
ffffffffc02058b4:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058b6:	0005c703          	lbu	a4,0(a1)
ffffffffc02058ba:	4501                	li	a0,0
ffffffffc02058bc:	b7f5                	j	ffffffffc02058a8 <strcmp+0x1e>

ffffffffc02058be <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02058be:	ce01                	beqz	a2,ffffffffc02058d6 <strncmp+0x18>
ffffffffc02058c0:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02058c4:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02058c6:	cb91                	beqz	a5,ffffffffc02058da <strncmp+0x1c>
ffffffffc02058c8:	0005c703          	lbu	a4,0(a1)
ffffffffc02058cc:	00f71763          	bne	a4,a5,ffffffffc02058da <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc02058d0:	0505                	addi	a0,a0,1
ffffffffc02058d2:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02058d4:	f675                	bnez	a2,ffffffffc02058c0 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058d6:	4501                	li	a0,0
ffffffffc02058d8:	8082                	ret
ffffffffc02058da:	00054503          	lbu	a0,0(a0)
ffffffffc02058de:	0005c783          	lbu	a5,0(a1)
ffffffffc02058e2:	9d1d                	subw	a0,a0,a5
}
ffffffffc02058e4:	8082                	ret

ffffffffc02058e6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02058e6:	a021                	j	ffffffffc02058ee <strchr+0x8>
        if (*s == c) {
ffffffffc02058e8:	00f58763          	beq	a1,a5,ffffffffc02058f6 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc02058ec:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02058ee:	00054783          	lbu	a5,0(a0)
ffffffffc02058f2:	fbfd                	bnez	a5,ffffffffc02058e8 <strchr+0x2>
    }
    return NULL;
ffffffffc02058f4:	4501                	li	a0,0
}
ffffffffc02058f6:	8082                	ret

ffffffffc02058f8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02058f8:	ca01                	beqz	a2,ffffffffc0205908 <memset+0x10>
ffffffffc02058fa:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02058fc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02058fe:	0785                	addi	a5,a5,1
ffffffffc0205900:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205904:	fef61de3          	bne	a2,a5,ffffffffc02058fe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205908:	8082                	ret

ffffffffc020590a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020590a:	ca19                	beqz	a2,ffffffffc0205920 <memcpy+0x16>
ffffffffc020590c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020590e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205910:	0005c703          	lbu	a4,0(a1)
ffffffffc0205914:	0585                	addi	a1,a1,1
ffffffffc0205916:	0785                	addi	a5,a5,1
ffffffffc0205918:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020591c:	feb61ae3          	bne	a2,a1,ffffffffc0205910 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205920:	8082                	ret
