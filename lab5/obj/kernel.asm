
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	0000b297          	auipc	t0,0xb
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020b000 <boot_hartid>
ffffffffc020000c:	0000b297          	auipc	t0,0xb
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020b008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c020a2b7          	lui	t0,0xc020a
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c020a137          	lui	sp,0xc020a
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	00097517          	auipc	a0,0x97
ffffffffc020004e:	68e50513          	addi	a0,a0,1678 # ffffffffc02976d8 <buf>
ffffffffc0200052:	0009c617          	auipc	a2,0x9c
ffffffffc0200056:	b2e60613          	addi	a2,a2,-1234 # ffffffffc029bb80 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc0209ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	0a3050ef          	jal	ffffffffc0205904 <memset>
    dtb_init();
ffffffffc0200066:	552000ef          	jal	ffffffffc02005b8 <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	4dc000ef          	jal	ffffffffc0200546 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	8c258593          	addi	a1,a1,-1854 # ffffffffc0205930 <etext+0x2>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	8da50513          	addi	a0,a0,-1830 # ffffffffc0205950 <etext+0x22>
ffffffffc020007e:	116000ef          	jal	ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	1a4000ef          	jal	ffffffffc0200226 <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	74c020ef          	jal	ffffffffc02027d2 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	081000ef          	jal	ffffffffc020090a <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	07f000ef          	jal	ffffffffc020090c <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	351030ef          	jal	ffffffffc0203be2 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	7b9040ef          	jal	ffffffffc020504e <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	45a000ef          	jal	ffffffffc02004f4 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	061000ef          	jal	ffffffffc02008fe <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	14c050ef          	jal	ffffffffc02051ee <cpu_idle>

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
ffffffffc02000ba:	8a250513          	addi	a0,a0,-1886 # ffffffffc0205958 <etext+0x2a>
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
ffffffffc02000ca:	61298993          	addi	s3,s3,1554 # ffffffffc02976d8 <buf>
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
ffffffffc0200144:	59850513          	addi	a0,a0,1432 # ffffffffc02976d8 <buf>
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
ffffffffc0200188:	362050ef          	jal	ffffffffc02054ea <vprintfmt>
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
ffffffffc02001bc:	32e050ef          	jal	ffffffffc02054ea <vprintfmt>
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
ffffffffc020022c:	73850513          	addi	a0,a0,1848 # ffffffffc0205960 <etext+0x32>
{
ffffffffc0200230:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200232:	f63ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200236:	00000597          	auipc	a1,0x0
ffffffffc020023a:	e1458593          	addi	a1,a1,-492 # ffffffffc020004a <kern_init>
ffffffffc020023e:	00005517          	auipc	a0,0x5
ffffffffc0200242:	74250513          	addi	a0,a0,1858 # ffffffffc0205980 <etext+0x52>
ffffffffc0200246:	f4fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020024a:	00005597          	auipc	a1,0x5
ffffffffc020024e:	6e458593          	addi	a1,a1,1764 # ffffffffc020592e <etext>
ffffffffc0200252:	00005517          	auipc	a0,0x5
ffffffffc0200256:	74e50513          	addi	a0,a0,1870 # ffffffffc02059a0 <etext+0x72>
ffffffffc020025a:	f3bff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025e:	00097597          	auipc	a1,0x97
ffffffffc0200262:	47a58593          	addi	a1,a1,1146 # ffffffffc02976d8 <buf>
ffffffffc0200266:	00005517          	auipc	a0,0x5
ffffffffc020026a:	75a50513          	addi	a0,a0,1882 # ffffffffc02059c0 <etext+0x92>
ffffffffc020026e:	f27ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200272:	0009c597          	auipc	a1,0x9c
ffffffffc0200276:	90e58593          	addi	a1,a1,-1778 # ffffffffc029bb80 <end>
ffffffffc020027a:	00005517          	auipc	a0,0x5
ffffffffc020027e:	76650513          	addi	a0,a0,1894 # ffffffffc02059e0 <etext+0xb2>
ffffffffc0200282:	f13ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200286:	00000717          	auipc	a4,0x0
ffffffffc020028a:	dc470713          	addi	a4,a4,-572 # ffffffffc020004a <kern_init>
ffffffffc020028e:	0009c797          	auipc	a5,0x9c
ffffffffc0200292:	cf178793          	addi	a5,a5,-783 # ffffffffc029bf7f <end+0x3ff>
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
ffffffffc02002aa:	75a50513          	addi	a0,a0,1882 # ffffffffc0205a00 <etext+0xd2>
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
ffffffffc02002b8:	77c60613          	addi	a2,a2,1916 # ffffffffc0205a30 <etext+0x102>
ffffffffc02002bc:	04f00593          	li	a1,79
ffffffffc02002c0:	00005517          	auipc	a0,0x5
ffffffffc02002c4:	78850513          	addi	a0,a0,1928 # ffffffffc0205a48 <etext+0x11a>
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
ffffffffc02002da:	3ea40413          	addi	s0,s0,1002 # ffffffffc02076c0 <commands>
ffffffffc02002de:	00007497          	auipc	s1,0x7
ffffffffc02002e2:	42a48493          	addi	s1,s1,1066 # ffffffffc0207708 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e6:	6410                	ld	a2,8(s0)
ffffffffc02002e8:	600c                	ld	a1,0(s0)
ffffffffc02002ea:	00005517          	auipc	a0,0x5
ffffffffc02002ee:	77650513          	addi	a0,a0,1910 # ffffffffc0205a60 <etext+0x132>
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
ffffffffc0200332:	74250513          	addi	a0,a0,1858 # ffffffffc0205a70 <etext+0x142>
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
ffffffffc020034a:	75250513          	addi	a0,a0,1874 # ffffffffc0205a98 <etext+0x16a>
ffffffffc020034e:	e47ff0ef          	jal	ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc0200352:	000a0563          	beqz	s4,ffffffffc020035c <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc0200356:	8552                	mv	a0,s4
ffffffffc0200358:	79c000ef          	jal	ffffffffc0200af4 <print_trapframe>
ffffffffc020035c:	00007a97          	auipc	s5,0x7
ffffffffc0200360:	364a8a93          	addi	s5,s5,868 # ffffffffc02076c0 <commands>
        if (argc == MAXARGS - 1)
ffffffffc0200364:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL)
ffffffffc0200366:	00005517          	auipc	a0,0x5
ffffffffc020036a:	75a50513          	addi	a0,a0,1882 # ffffffffc0205ac0 <etext+0x192>
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
ffffffffc0200388:	33c48493          	addi	s1,s1,828 # ffffffffc02076c0 <commands>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020038c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc020038e:	6582                	ld	a1,0(sp)
ffffffffc0200390:	6088                	ld	a0,0(s1)
ffffffffc0200392:	504050ef          	jal	ffffffffc0205896 <strcmp>
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
ffffffffc02003a8:	74c50513          	addi	a0,a0,1868 # ffffffffc0205af0 <etext+0x1c2>
ffffffffc02003ac:	de9ff0ef          	jal	ffffffffc0200194 <cprintf>
    return 0;
ffffffffc02003b0:	bf5d                	j	ffffffffc0200366 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003b2:	00005517          	auipc	a0,0x5
ffffffffc02003b6:	71650513          	addi	a0,a0,1814 # ffffffffc0205ac8 <etext+0x19a>
ffffffffc02003ba:	538050ef          	jal	ffffffffc02058f2 <strchr>
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
ffffffffc02003f8:	6d450513          	addi	a0,a0,1748 # ffffffffc0205ac8 <etext+0x19a>
ffffffffc02003fc:	4f6050ef          	jal	ffffffffc02058f2 <strchr>
ffffffffc0200400:	d575                	beqz	a0,ffffffffc02003ec <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200402:	00044583          	lbu	a1,0(s0)
ffffffffc0200406:	dda5                	beqz	a1,ffffffffc020037e <kmonitor+0x56>
ffffffffc0200408:	b76d                	j	ffffffffc02003b2 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020040a:	45c1                	li	a1,16
ffffffffc020040c:	00005517          	auipc	a0,0x5
ffffffffc0200410:	6c450513          	addi	a0,a0,1732 # ffffffffc0205ad0 <etext+0x1a2>
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
ffffffffc020044a:	6ba33303          	ld	t1,1722(t1) # ffffffffc029bb00 <is_panic>
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
ffffffffc0200470:	72c50513          	addi	a0,a0,1836 # ffffffffc0205b98 <etext+0x26a>
    is_panic = 1;
ffffffffc0200474:	0009b697          	auipc	a3,0x9b
ffffffffc0200478:	68e6b623          	sd	a4,1676(a3) # ffffffffc029bb00 <is_panic>
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
ffffffffc020048e:	72e50513          	addi	a0,a0,1838 # ffffffffc0205bb8 <etext+0x28a>
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
ffffffffc02004c2:	70250513          	addi	a0,a0,1794 # ffffffffc0205bc0 <etext+0x292>
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
ffffffffc02004e4:	6d850513          	addi	a0,a0,1752 # ffffffffc0205bb8 <etext+0x28a>
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
ffffffffc02004f6:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xe498>
ffffffffc02004fa:	0009b717          	auipc	a4,0x9b
ffffffffc02004fe:	60f73723          	sd	a5,1550(a4) # ffffffffc029bb08 <timebase>
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
ffffffffc020051e:	6c650513          	addi	a0,a0,1734 # ffffffffc0205be0 <etext+0x2b2>
    ticks = 0;
ffffffffc0200522:	0009b797          	auipc	a5,0x9b
ffffffffc0200526:	5e07b723          	sd	zero,1518(a5) # ffffffffc029bb10 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020052a:	b1ad                	j	ffffffffc0200194 <cprintf>

ffffffffc020052c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020052c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200530:	0009b797          	auipc	a5,0x9b
ffffffffc0200534:	5d87b783          	ld	a5,1496(a5) # ffffffffc029bb08 <timebase>
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
ffffffffc02005be:	64650513          	addi	a0,a0,1606 # ffffffffc0205c00 <etext+0x2d2>
void dtb_init(void) {
ffffffffc02005c2:	f406                	sd	ra,40(sp)
ffffffffc02005c4:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc02005c6:	bcfff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005ca:	0000b597          	auipc	a1,0xb
ffffffffc02005ce:	a365b583          	ld	a1,-1482(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc02005d2:	00005517          	auipc	a0,0x5
ffffffffc02005d6:	63e50513          	addi	a0,a0,1598 # ffffffffc0205c10 <etext+0x2e2>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005da:	0000b417          	auipc	s0,0xb
ffffffffc02005de:	a2e40413          	addi	s0,s0,-1490 # ffffffffc020b008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005e2:	bb3ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005e6:	600c                	ld	a1,0(s0)
ffffffffc02005e8:	00005517          	auipc	a0,0x5
ffffffffc02005ec:	63850513          	addi	a0,a0,1592 # ffffffffc0205c20 <etext+0x2f2>
ffffffffc02005f0:	ba5ff0ef          	jal	ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02005f4:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02005f6:	00005517          	auipc	a0,0x5
ffffffffc02005fa:	64250513          	addi	a0,a0,1602 # ffffffffc0205c38 <etext+0x30a>
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
ffffffffc020060e:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe4436d>
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
ffffffffc02006ec:	61850513          	addi	a0,a0,1560 # ffffffffc0205d00 <etext+0x3d2>
ffffffffc02006f0:	aa5ff0ef          	jal	ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006f4:	64e2                	ld	s1,24(sp)
ffffffffc02006f6:	6942                	ld	s2,16(sp)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	64050513          	addi	a0,a0,1600 # ffffffffc0205d38 <etext+0x40a>
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
ffffffffc0200710:	54c50513          	addi	a0,a0,1356 # ffffffffc0205c58 <etext+0x32a>
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
ffffffffc0200752:	0fe050ef          	jal	ffffffffc0205850 <strlen>
ffffffffc0200756:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200758:	4619                	li	a2,6
ffffffffc020075a:	8522                	mv	a0,s0
ffffffffc020075c:	00005597          	auipc	a1,0x5
ffffffffc0200760:	52458593          	addi	a1,a1,1316 # ffffffffc0205c80 <etext+0x352>
ffffffffc0200764:	166050ef          	jal	ffffffffc02058ca <strncmp>
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
ffffffffc020078c:	50058593          	addi	a1,a1,1280 # ffffffffc0205c88 <etext+0x35a>
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
ffffffffc02007be:	0d8050ef          	jal	ffffffffc0205896 <strcmp>
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
ffffffffc02007e2:	4b250513          	addi	a0,a0,1202 # ffffffffc0205c90 <etext+0x362>
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
ffffffffc02008ac:	40850513          	addi	a0,a0,1032 # ffffffffc0205cb0 <etext+0x382>
ffffffffc02008b0:	8e5ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02008b4:	01445613          	srli	a2,s0,0x14
ffffffffc02008b8:	85a2                	mv	a1,s0
ffffffffc02008ba:	00005517          	auipc	a0,0x5
ffffffffc02008be:	40e50513          	addi	a0,a0,1038 # ffffffffc0205cc8 <etext+0x39a>
ffffffffc02008c2:	8d3ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008c6:	009405b3          	add	a1,s0,s1
ffffffffc02008ca:	15fd                	addi	a1,a1,-1
ffffffffc02008cc:	00005517          	auipc	a0,0x5
ffffffffc02008d0:	41c50513          	addi	a0,a0,1052 # ffffffffc0205ce8 <etext+0x3ba>
ffffffffc02008d4:	8c1ff0ef          	jal	ffffffffc0200194 <cprintf>
        memory_base = mem_base;
ffffffffc02008d8:	0009b797          	auipc	a5,0x9b
ffffffffc02008dc:	2497b423          	sd	s1,584(a5) # ffffffffc029bb20 <memory_base>
        memory_size = mem_size;
ffffffffc02008e0:	0009b797          	auipc	a5,0x9b
ffffffffc02008e4:	2287bc23          	sd	s0,568(a5) # ffffffffc029bb18 <memory_size>
ffffffffc02008e8:	b531                	j	ffffffffc02006f4 <dtb_init+0x13c>

ffffffffc02008ea <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008ea:	0009b517          	auipc	a0,0x9b
ffffffffc02008ee:	23653503          	ld	a0,566(a0) # ffffffffc029bb20 <memory_base>
ffffffffc02008f2:	8082                	ret

ffffffffc02008f4 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008f4:	0009b517          	auipc	a0,0x9b
ffffffffc02008f8:	22453503          	ld	a0,548(a0) # ffffffffc029bb18 <memory_size>
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
ffffffffc0200914:	54878793          	addi	a5,a5,1352 # ffffffffc0200e58 <__alltraps>
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
ffffffffc0200932:	42250513          	addi	a0,a0,1058 # ffffffffc0205d50 <etext+0x422>
{
ffffffffc0200936:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200938:	85dff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020093c:	640c                	ld	a1,8(s0)
ffffffffc020093e:	00005517          	auipc	a0,0x5
ffffffffc0200942:	42a50513          	addi	a0,a0,1066 # ffffffffc0205d68 <etext+0x43a>
ffffffffc0200946:	84fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020094a:	680c                	ld	a1,16(s0)
ffffffffc020094c:	00005517          	auipc	a0,0x5
ffffffffc0200950:	43450513          	addi	a0,a0,1076 # ffffffffc0205d80 <etext+0x452>
ffffffffc0200954:	841ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200958:	6c0c                	ld	a1,24(s0)
ffffffffc020095a:	00005517          	auipc	a0,0x5
ffffffffc020095e:	43e50513          	addi	a0,a0,1086 # ffffffffc0205d98 <etext+0x46a>
ffffffffc0200962:	833ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200966:	700c                	ld	a1,32(s0)
ffffffffc0200968:	00005517          	auipc	a0,0x5
ffffffffc020096c:	44850513          	addi	a0,a0,1096 # ffffffffc0205db0 <etext+0x482>
ffffffffc0200970:	825ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200974:	740c                	ld	a1,40(s0)
ffffffffc0200976:	00005517          	auipc	a0,0x5
ffffffffc020097a:	45250513          	addi	a0,a0,1106 # ffffffffc0205dc8 <etext+0x49a>
ffffffffc020097e:	817ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200982:	780c                	ld	a1,48(s0)
ffffffffc0200984:	00005517          	auipc	a0,0x5
ffffffffc0200988:	45c50513          	addi	a0,a0,1116 # ffffffffc0205de0 <etext+0x4b2>
ffffffffc020098c:	809ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200990:	7c0c                	ld	a1,56(s0)
ffffffffc0200992:	00005517          	auipc	a0,0x5
ffffffffc0200996:	46650513          	addi	a0,a0,1126 # ffffffffc0205df8 <etext+0x4ca>
ffffffffc020099a:	ffaff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc020099e:	602c                	ld	a1,64(s0)
ffffffffc02009a0:	00005517          	auipc	a0,0x5
ffffffffc02009a4:	47050513          	addi	a0,a0,1136 # ffffffffc0205e10 <etext+0x4e2>
ffffffffc02009a8:	fecff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009ac:	642c                	ld	a1,72(s0)
ffffffffc02009ae:	00005517          	auipc	a0,0x5
ffffffffc02009b2:	47a50513          	addi	a0,a0,1146 # ffffffffc0205e28 <etext+0x4fa>
ffffffffc02009b6:	fdeff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009ba:	682c                	ld	a1,80(s0)
ffffffffc02009bc:	00005517          	auipc	a0,0x5
ffffffffc02009c0:	48450513          	addi	a0,a0,1156 # ffffffffc0205e40 <etext+0x512>
ffffffffc02009c4:	fd0ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009c8:	6c2c                	ld	a1,88(s0)
ffffffffc02009ca:	00005517          	auipc	a0,0x5
ffffffffc02009ce:	48e50513          	addi	a0,a0,1166 # ffffffffc0205e58 <etext+0x52a>
ffffffffc02009d2:	fc2ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009d6:	702c                	ld	a1,96(s0)
ffffffffc02009d8:	00005517          	auipc	a0,0x5
ffffffffc02009dc:	49850513          	addi	a0,a0,1176 # ffffffffc0205e70 <etext+0x542>
ffffffffc02009e0:	fb4ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02009e4:	742c                	ld	a1,104(s0)
ffffffffc02009e6:	00005517          	auipc	a0,0x5
ffffffffc02009ea:	4a250513          	addi	a0,a0,1186 # ffffffffc0205e88 <etext+0x55a>
ffffffffc02009ee:	fa6ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02009f2:	782c                	ld	a1,112(s0)
ffffffffc02009f4:	00005517          	auipc	a0,0x5
ffffffffc02009f8:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205ea0 <etext+0x572>
ffffffffc02009fc:	f98ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a00:	7c2c                	ld	a1,120(s0)
ffffffffc0200a02:	00005517          	auipc	a0,0x5
ffffffffc0200a06:	4b650513          	addi	a0,a0,1206 # ffffffffc0205eb8 <etext+0x58a>
ffffffffc0200a0a:	f8aff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a0e:	604c                	ld	a1,128(s0)
ffffffffc0200a10:	00005517          	auipc	a0,0x5
ffffffffc0200a14:	4c050513          	addi	a0,a0,1216 # ffffffffc0205ed0 <etext+0x5a2>
ffffffffc0200a18:	f7cff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a1c:	644c                	ld	a1,136(s0)
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	4ca50513          	addi	a0,a0,1226 # ffffffffc0205ee8 <etext+0x5ba>
ffffffffc0200a26:	f6eff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a2a:	684c                	ld	a1,144(s0)
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	4d450513          	addi	a0,a0,1236 # ffffffffc0205f00 <etext+0x5d2>
ffffffffc0200a34:	f60ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a38:	6c4c                	ld	a1,152(s0)
ffffffffc0200a3a:	00005517          	auipc	a0,0x5
ffffffffc0200a3e:	4de50513          	addi	a0,a0,1246 # ffffffffc0205f18 <etext+0x5ea>
ffffffffc0200a42:	f52ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a46:	704c                	ld	a1,160(s0)
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	4e850513          	addi	a0,a0,1256 # ffffffffc0205f30 <etext+0x602>
ffffffffc0200a50:	f44ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a54:	744c                	ld	a1,168(s0)
ffffffffc0200a56:	00005517          	auipc	a0,0x5
ffffffffc0200a5a:	4f250513          	addi	a0,a0,1266 # ffffffffc0205f48 <etext+0x61a>
ffffffffc0200a5e:	f36ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a62:	784c                	ld	a1,176(s0)
ffffffffc0200a64:	00005517          	auipc	a0,0x5
ffffffffc0200a68:	4fc50513          	addi	a0,a0,1276 # ffffffffc0205f60 <etext+0x632>
ffffffffc0200a6c:	f28ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a70:	7c4c                	ld	a1,184(s0)
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	50650513          	addi	a0,a0,1286 # ffffffffc0205f78 <etext+0x64a>
ffffffffc0200a7a:	f1aff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200a7e:	606c                	ld	a1,192(s0)
ffffffffc0200a80:	00005517          	auipc	a0,0x5
ffffffffc0200a84:	51050513          	addi	a0,a0,1296 # ffffffffc0205f90 <etext+0x662>
ffffffffc0200a88:	f0cff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a8c:	646c                	ld	a1,200(s0)
ffffffffc0200a8e:	00005517          	auipc	a0,0x5
ffffffffc0200a92:	51a50513          	addi	a0,a0,1306 # ffffffffc0205fa8 <etext+0x67a>
ffffffffc0200a96:	efeff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a9a:	686c                	ld	a1,208(s0)
ffffffffc0200a9c:	00005517          	auipc	a0,0x5
ffffffffc0200aa0:	52450513          	addi	a0,a0,1316 # ffffffffc0205fc0 <etext+0x692>
ffffffffc0200aa4:	ef0ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200aa8:	6c6c                	ld	a1,216(s0)
ffffffffc0200aaa:	00005517          	auipc	a0,0x5
ffffffffc0200aae:	52e50513          	addi	a0,a0,1326 # ffffffffc0205fd8 <etext+0x6aa>
ffffffffc0200ab2:	ee2ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ab6:	706c                	ld	a1,224(s0)
ffffffffc0200ab8:	00005517          	auipc	a0,0x5
ffffffffc0200abc:	53850513          	addi	a0,a0,1336 # ffffffffc0205ff0 <etext+0x6c2>
ffffffffc0200ac0:	ed4ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200ac4:	746c                	ld	a1,232(s0)
ffffffffc0200ac6:	00005517          	auipc	a0,0x5
ffffffffc0200aca:	54250513          	addi	a0,a0,1346 # ffffffffc0206008 <etext+0x6da>
ffffffffc0200ace:	ec6ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200ad2:	786c                	ld	a1,240(s0)
ffffffffc0200ad4:	00005517          	auipc	a0,0x5
ffffffffc0200ad8:	54c50513          	addi	a0,a0,1356 # ffffffffc0206020 <etext+0x6f2>
ffffffffc0200adc:	eb8ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae0:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200ae2:	6402                	ld	s0,0(sp)
ffffffffc0200ae4:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae6:	00005517          	auipc	a0,0x5
ffffffffc0200aea:	55250513          	addi	a0,a0,1362 # ffffffffc0206038 <etext+0x70a>
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
ffffffffc0200b00:	55450513          	addi	a0,a0,1364 # ffffffffc0206050 <etext+0x722>
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
ffffffffc0200b18:	55450513          	addi	a0,a0,1364 # ffffffffc0206068 <etext+0x73a>
ffffffffc0200b1c:	e78ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b20:	10843583          	ld	a1,264(s0)
ffffffffc0200b24:	00005517          	auipc	a0,0x5
ffffffffc0200b28:	55c50513          	addi	a0,a0,1372 # ffffffffc0206080 <etext+0x752>
ffffffffc0200b2c:	e68ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200b30:	11043583          	ld	a1,272(s0)
ffffffffc0200b34:	00005517          	auipc	a0,0x5
ffffffffc0200b38:	56450513          	addi	a0,a0,1380 # ffffffffc0206098 <etext+0x76a>
ffffffffc0200b3c:	e58ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b40:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b44:	6402                	ld	s0,0(sp)
ffffffffc0200b46:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b48:	00005517          	auipc	a0,0x5
ffffffffc0200b4c:	56050513          	addi	a0,a0,1376 # ffffffffc02060a8 <etext+0x77a>
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
ffffffffc0200b60:	0af76a63          	bltu	a4,a5,ffffffffc0200c14 <interrupt_handler+0xbe>
ffffffffc0200b64:	00007717          	auipc	a4,0x7
ffffffffc0200b68:	ba470713          	addi	a4,a4,-1116 # ffffffffc0207708 <commands+0x48>
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
ffffffffc0200b7a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0206120 <etext+0x7f2>
ffffffffc0200b7e:	e16ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200b82:	00005517          	auipc	a0,0x5
ffffffffc0200b86:	57e50513          	addi	a0,a0,1406 # ffffffffc0206100 <etext+0x7d2>
ffffffffc0200b8a:	e0aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200b8e:	00005517          	auipc	a0,0x5
ffffffffc0200b92:	53250513          	addi	a0,a0,1330 # ffffffffc02060c0 <etext+0x792>
ffffffffc0200b96:	dfeff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b9a:	00005517          	auipc	a0,0x5
ffffffffc0200b9e:	54650513          	addi	a0,a0,1350 # ffffffffc02060e0 <etext+0x7b2>
ffffffffc0200ba2:	df2ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200ba6:	1141                	addi	sp,sp,-16
    case IRQ_S_TIMER:
        // "All bits besides SSIP and USIP in the sip register are
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        cprintf("Supervisor timer interrupt\n");
ffffffffc0200ba8:	00005517          	auipc	a0,0x5
ffffffffc0200bac:	59850513          	addi	a0,a0,1432 # ffffffffc0206140 <etext+0x812>
{
ffffffffc0200bb0:	e406                	sd	ra,8(sp)
        cprintf("Supervisor timer interrupt\n");
ffffffffc0200bb2:	de2ff0ef          	jal	ffffffffc0200194 <cprintf>
        //     ticks=0;
        // }
        // if (num == 10){
        //     sbi_shutdown();
        // } 
        clock_set_next_event();
ffffffffc0200bb6:	977ff0ef          	jal	ffffffffc020052c <clock_set_next_event>
        ticks++;
ffffffffc0200bba:	0009b797          	auipc	a5,0x9b
ffffffffc0200bbe:	f5678793          	addi	a5,a5,-170 # ffffffffc029bb10 <ticks>
ffffffffc0200bc2:	6394                	ld	a3,0(a5)
        if (ticks % TICK_NUM == 0)
ffffffffc0200bc4:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200bc8:	28f70713          	addi	a4,a4,655 # 28f5c28f <_binary_obj___user_exit_out_size+0x28f52087>
        ticks++;
ffffffffc0200bcc:	0685                	addi	a3,a3,1
ffffffffc0200bce:	e394                	sd	a3,0(a5)
        if (ticks % TICK_NUM == 0)
ffffffffc0200bd0:	6390                	ld	a2,0(a5)
ffffffffc0200bd2:	5c28f6b7          	lui	a3,0x5c28f
ffffffffc0200bd6:	1702                	slli	a4,a4,0x20
ffffffffc0200bd8:	5c368693          	addi	a3,a3,1475 # 5c28f5c3 <_binary_obj___user_exit_out_size+0x5c2853bb>
ffffffffc0200bdc:	9736                	add	a4,a4,a3
ffffffffc0200bde:	00265793          	srli	a5,a2,0x2
ffffffffc0200be2:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200be6:	06400713          	li	a4,100
ffffffffc0200bea:	8389                	srli	a5,a5,0x2
ffffffffc0200bec:	02e787b3          	mul	a5,a5,a4
ffffffffc0200bf0:	00f61963          	bne	a2,a5,ffffffffc0200c02 <interrupt_handler+0xac>
        {
            if (current != NULL)
ffffffffc0200bf4:	0009b797          	auipc	a5,0x9b
ffffffffc0200bf8:	f747b783          	ld	a5,-140(a5) # ffffffffc029bb68 <current>
ffffffffc0200bfc:	c399                	beqz	a5,ffffffffc0200c02 <interrupt_handler+0xac>
            {
                current->need_resched = 1;
ffffffffc0200bfe:	4705                	li	a4,1
ffffffffc0200c00:	ef98                	sd	a4,24(a5)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c02:	60a2                	ld	ra,8(sp)
ffffffffc0200c04:	0141                	addi	sp,sp,16
ffffffffc0200c06:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c08:	00005517          	auipc	a0,0x5
ffffffffc0200c0c:	55850513          	addi	a0,a0,1368 # ffffffffc0206160 <etext+0x832>
ffffffffc0200c10:	d84ff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200c14:	b5c5                	j	ffffffffc0200af4 <print_trapframe>

ffffffffc0200c16 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200c16:	11853783          	ld	a5,280(a0)
ffffffffc0200c1a:	473d                	li	a4,15
ffffffffc0200c1c:	18f76c63          	bltu	a4,a5,ffffffffc0200db4 <exception_handler+0x19e>
ffffffffc0200c20:	00007717          	auipc	a4,0x7
ffffffffc0200c24:	b1870713          	addi	a4,a4,-1256 # ffffffffc0207738 <commands+0x78>
ffffffffc0200c28:	078a                	slli	a5,a5,0x2
ffffffffc0200c2a:	97ba                	add	a5,a5,a4
ffffffffc0200c2c:	439c                	lw	a5,0(a5)
{
ffffffffc0200c2e:	1101                	addi	sp,sp,-32
ffffffffc0200c30:	ec06                	sd	ra,24(sp)
    switch (tf->cause)
ffffffffc0200c32:	97ba                	add	a5,a5,a4
ffffffffc0200c34:	86aa                	mv	a3,a0
ffffffffc0200c36:	8782                	jr	a5
ffffffffc0200c38:	e42a                	sd	a0,8(sp)
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200c3a:	00005517          	auipc	a0,0x5
ffffffffc0200c3e:	62e50513          	addi	a0,a0,1582 # ffffffffc0206268 <etext+0x93a>
ffffffffc0200c42:	d52ff0ef          	jal	ffffffffc0200194 <cprintf>
        tf->epc += 4;
ffffffffc0200c46:	66a2                	ld	a3,8(sp)
ffffffffc0200c48:	1086b783          	ld	a5,264(a3)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c4c:	60e2                	ld	ra,24(sp)
        tf->epc += 4;
ffffffffc0200c4e:	0791                	addi	a5,a5,4
ffffffffc0200c50:	10f6b423          	sd	a5,264(a3)
}
ffffffffc0200c54:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200c56:	79c0406f          	j	ffffffffc02053f2 <syscall>
}
ffffffffc0200c5a:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200c5c:	00005517          	auipc	a0,0x5
ffffffffc0200c60:	62c50513          	addi	a0,a0,1580 # ffffffffc0206288 <etext+0x95a>
}
ffffffffc0200c64:	6105                	addi	sp,sp,32
        cprintf("Environment call from H-mode\n");
ffffffffc0200c66:	d2eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c6a:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200c6c:	00005517          	auipc	a0,0x5
ffffffffc0200c70:	63c50513          	addi	a0,a0,1596 # ffffffffc02062a8 <etext+0x97a>
}
ffffffffc0200c74:	6105                	addi	sp,sp,32
        cprintf("Environment call from M-mode\n");
ffffffffc0200c76:	d1eff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200c7a:	e42a                	sd	a0,8(sp)
        cprintf("Instruction page fault\n");
ffffffffc0200c7c:	00005517          	auipc	a0,0x5
ffffffffc0200c80:	64c50513          	addi	a0,a0,1612 # ffffffffc02062c8 <etext+0x99a>
ffffffffc0200c84:	d10ff0ef          	jal	ffffffffc0200194 <cprintf>
        goto pgfault;
ffffffffc0200c88:	66a2                	ld	a3,8(sp)
        if (current == NULL || current->mm == NULL)
ffffffffc0200c8a:	0009b797          	auipc	a5,0x9b
ffffffffc0200c8e:	ede7b783          	ld	a5,-290(a5) # ffffffffc029bb68 <current>
ffffffffc0200c92:	12078263          	beqz	a5,ffffffffc0200db6 <exception_handler+0x1a0>
ffffffffc0200c96:	7788                	ld	a0,40(a5)
ffffffffc0200c98:	10050f63          	beqz	a0,ffffffffc0200db6 <exception_handler+0x1a0>
        if (do_pgfault(current->mm, tf->cause, tf->tval) != 0)
ffffffffc0200c9c:	1106b603          	ld	a2,272(a3)
ffffffffc0200ca0:	1186a583          	lw	a1,280(a3)
ffffffffc0200ca4:	e436                	sd	a3,8(sp)
ffffffffc0200ca6:	357020ef          	jal	ffffffffc02037fc <do_pgfault>
ffffffffc0200caa:	66a2                	ld	a3,8(sp)
ffffffffc0200cac:	0c051863          	bnez	a0,ffffffffc0200d7c <exception_handler+0x166>
}
ffffffffc0200cb0:	60e2                	ld	ra,24(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
ffffffffc0200cb4:	8082                	ret
ffffffffc0200cb6:	e42a                	sd	a0,8(sp)
        cprintf("Load page fault\n");
ffffffffc0200cb8:	00005517          	auipc	a0,0x5
ffffffffc0200cbc:	62850513          	addi	a0,a0,1576 # ffffffffc02062e0 <etext+0x9b2>
ffffffffc0200cc0:	cd4ff0ef          	jal	ffffffffc0200194 <cprintf>
        goto pgfault;
ffffffffc0200cc4:	66a2                	ld	a3,8(sp)
ffffffffc0200cc6:	b7d1                	j	ffffffffc0200c8a <exception_handler+0x74>
ffffffffc0200cc8:	e42a                	sd	a0,8(sp)
        cprintf("Store/AMO page fault\n");
ffffffffc0200cca:	00005517          	auipc	a0,0x5
ffffffffc0200cce:	62e50513          	addi	a0,a0,1582 # ffffffffc02062f8 <etext+0x9ca>
ffffffffc0200cd2:	cc2ff0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0200cd6:	66a2                	ld	a3,8(sp)
ffffffffc0200cd8:	bf4d                	j	ffffffffc0200c8a <exception_handler+0x74>
}
ffffffffc0200cda:	60e2                	ld	ra,24(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200cdc:	00005517          	auipc	a0,0x5
ffffffffc0200ce0:	4a450513          	addi	a0,a0,1188 # ffffffffc0206180 <etext+0x852>
}
ffffffffc0200ce4:	6105                	addi	sp,sp,32
        cprintf("Instruction address misaligned\n");
ffffffffc0200ce6:	caeff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200cea:	60e2                	ld	ra,24(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200cec:	00005517          	auipc	a0,0x5
ffffffffc0200cf0:	4b450513          	addi	a0,a0,1204 # ffffffffc02061a0 <etext+0x872>
}
ffffffffc0200cf4:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200cf6:	c9eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200cfa:	60e2                	ld	ra,24(sp)
        cprintf("Illegal instruction\n");
ffffffffc0200cfc:	00005517          	auipc	a0,0x5
ffffffffc0200d00:	4c450513          	addi	a0,a0,1220 # ffffffffc02061c0 <etext+0x892>
}
ffffffffc0200d04:	6105                	addi	sp,sp,32
        cprintf("Illegal instruction\n");
ffffffffc0200d06:	c8eff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200d0a:	e42a                	sd	a0,8(sp)
        cprintf("Breakpoint\n");
ffffffffc0200d0c:	00005517          	auipc	a0,0x5
ffffffffc0200d10:	4cc50513          	addi	a0,a0,1228 # ffffffffc02061d8 <etext+0x8aa>
ffffffffc0200d14:	c80ff0ef          	jal	ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200d18:	66a2                	ld	a3,8(sp)
ffffffffc0200d1a:	47a9                	li	a5,10
ffffffffc0200d1c:	66d8                	ld	a4,136(a3)
ffffffffc0200d1e:	f8f719e3          	bne	a4,a5,ffffffffc0200cb0 <exception_handler+0x9a>
            tf->epc += 4;
ffffffffc0200d22:	1086b783          	ld	a5,264(a3)
ffffffffc0200d26:	0791                	addi	a5,a5,4
ffffffffc0200d28:	10f6b423          	sd	a5,264(a3)
            syscall();
ffffffffc0200d2c:	6c6040ef          	jal	ffffffffc02053f2 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200d30:	0009b717          	auipc	a4,0x9b
ffffffffc0200d34:	e3873703          	ld	a4,-456(a4) # ffffffffc029bb68 <current>
ffffffffc0200d38:	6522                	ld	a0,8(sp)
}
ffffffffc0200d3a:	60e2                	ld	ra,24(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200d3c:	6b0c                	ld	a1,16(a4)
ffffffffc0200d3e:	6789                	lui	a5,0x2
ffffffffc0200d40:	95be                	add	a1,a1,a5
}
ffffffffc0200d42:	6105                	addi	sp,sp,32
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200d44:	a2cd                	j	ffffffffc0200f26 <kernel_execve_ret>
}
ffffffffc0200d46:	60e2                	ld	ra,24(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200d48:	00005517          	auipc	a0,0x5
ffffffffc0200d4c:	4a050513          	addi	a0,a0,1184 # ffffffffc02061e8 <etext+0x8ba>
}
ffffffffc0200d50:	6105                	addi	sp,sp,32
        cprintf("Load address misaligned\n");
ffffffffc0200d52:	c42ff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200d56:	60e2                	ld	ra,24(sp)
        cprintf("Load access fault\n");
ffffffffc0200d58:	00005517          	auipc	a0,0x5
ffffffffc0200d5c:	4b050513          	addi	a0,a0,1200 # ffffffffc0206208 <etext+0x8da>
}
ffffffffc0200d60:	6105                	addi	sp,sp,32
        cprintf("Load access fault\n");
ffffffffc0200d62:	c32ff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200d66:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200d68:	00005517          	auipc	a0,0x5
ffffffffc0200d6c:	4e850513          	addi	a0,a0,1256 # ffffffffc0206250 <etext+0x922>
}
ffffffffc0200d70:	6105                	addi	sp,sp,32
        cprintf("Store/AMO access fault\n");
ffffffffc0200d72:	c22ff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200d76:	60e2                	ld	ra,24(sp)
ffffffffc0200d78:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200d7a:	bbad                	j	ffffffffc0200af4 <print_trapframe>
            cprintf("unhandled page fault from user, addr: %p\n", tf->tval);
ffffffffc0200d7c:	1106b583          	ld	a1,272(a3)
ffffffffc0200d80:	00005517          	auipc	a0,0x5
ffffffffc0200d84:	5b850513          	addi	a0,a0,1464 # ffffffffc0206338 <etext+0xa0a>
ffffffffc0200d88:	c0cff0ef          	jal	ffffffffc0200194 <cprintf>
            print_trapframe(tf);
ffffffffc0200d8c:	6522                	ld	a0,8(sp)
ffffffffc0200d8e:	d67ff0ef          	jal	ffffffffc0200af4 <print_trapframe>
}
ffffffffc0200d92:	60e2                	ld	ra,24(sp)
            do_exit(-E_KILLED);
ffffffffc0200d94:	555d                	li	a0,-9
}
ffffffffc0200d96:	6105                	addi	sp,sp,32
            do_exit(-E_KILLED);
ffffffffc0200d98:	00f0306f          	j	ffffffffc02045a6 <do_exit>
        panic("AMO address misaligned\n");
ffffffffc0200d9c:	00005617          	auipc	a2,0x5
ffffffffc0200da0:	48460613          	addi	a2,a2,1156 # ffffffffc0206220 <etext+0x8f2>
ffffffffc0200da4:	0c800593          	li	a1,200
ffffffffc0200da8:	00005517          	auipc	a0,0x5
ffffffffc0200dac:	49050513          	addi	a0,a0,1168 # ffffffffc0206238 <etext+0x90a>
ffffffffc0200db0:	e96ff0ef          	jal	ffffffffc0200446 <__panic>
        print_trapframe(tf);
ffffffffc0200db4:	b381                	j	ffffffffc0200af4 <print_trapframe>
            print_trapframe(tf);
ffffffffc0200db6:	8536                	mv	a0,a3
ffffffffc0200db8:	d3dff0ef          	jal	ffffffffc0200af4 <print_trapframe>
            panic("unhandled page fault in kernel.\n");
ffffffffc0200dbc:	00005617          	auipc	a2,0x5
ffffffffc0200dc0:	55460613          	addi	a2,a2,1364 # ffffffffc0206310 <etext+0x9e2>
ffffffffc0200dc4:	0eb00593          	li	a1,235
ffffffffc0200dc8:	00005517          	auipc	a0,0x5
ffffffffc0200dcc:	47050513          	addi	a0,a0,1136 # ffffffffc0206238 <etext+0x90a>
ffffffffc0200dd0:	e76ff0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0200dd4 <trap>:
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200dd4:	0009b717          	auipc	a4,0x9b
ffffffffc0200dd8:	d9473703          	ld	a4,-620(a4) # ffffffffc029bb68 <current>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200ddc:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200de0:	cf21                	beqz	a4,ffffffffc0200e38 <trap+0x64>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200de2:	10053603          	ld	a2,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200de6:	0a073803          	ld	a6,160(a4)
{
ffffffffc0200dea:	1101                	addi	sp,sp,-32
ffffffffc0200dec:	ec06                	sd	ra,24(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200dee:	10067613          	andi	a2,a2,256
        current->tf = tf;
ffffffffc0200df2:	f348                	sd	a0,160(a4)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200df4:	e432                	sd	a2,8(sp)
ffffffffc0200df6:	e042                	sd	a6,0(sp)
ffffffffc0200df8:	0205c763          	bltz	a1,ffffffffc0200e26 <trap+0x52>
        exception_handler(tf);
ffffffffc0200dfc:	e1bff0ef          	jal	ffffffffc0200c16 <exception_handler>
ffffffffc0200e00:	6622                	ld	a2,8(sp)
ffffffffc0200e02:	6802                	ld	a6,0(sp)
ffffffffc0200e04:	0009b697          	auipc	a3,0x9b
ffffffffc0200e08:	d6468693          	addi	a3,a3,-668 # ffffffffc029bb68 <current>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e0c:	6298                	ld	a4,0(a3)
ffffffffc0200e0e:	0b073023          	sd	a6,160(a4)
        if (!in_kernel)
ffffffffc0200e12:	e619                	bnez	a2,ffffffffc0200e20 <trap+0x4c>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e14:	0b072783          	lw	a5,176(a4)
ffffffffc0200e18:	8b85                	andi	a5,a5,1
ffffffffc0200e1a:	e79d                	bnez	a5,ffffffffc0200e48 <trap+0x74>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e1c:	6f1c                	ld	a5,24(a4)
ffffffffc0200e1e:	e38d                	bnez	a5,ffffffffc0200e40 <trap+0x6c>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e20:	60e2                	ld	ra,24(sp)
ffffffffc0200e22:	6105                	addi	sp,sp,32
ffffffffc0200e24:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e26:	d31ff0ef          	jal	ffffffffc0200b56 <interrupt_handler>
ffffffffc0200e2a:	6802                	ld	a6,0(sp)
ffffffffc0200e2c:	6622                	ld	a2,8(sp)
ffffffffc0200e2e:	0009b697          	auipc	a3,0x9b
ffffffffc0200e32:	d3a68693          	addi	a3,a3,-710 # ffffffffc029bb68 <current>
ffffffffc0200e36:	bfd9                	j	ffffffffc0200e0c <trap+0x38>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e38:	0005c363          	bltz	a1,ffffffffc0200e3e <trap+0x6a>
        exception_handler(tf);
ffffffffc0200e3c:	bbe9                	j	ffffffffc0200c16 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200e3e:	bb21                	j	ffffffffc0200b56 <interrupt_handler>
}
ffffffffc0200e40:	60e2                	ld	ra,24(sp)
ffffffffc0200e42:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200e44:	4c20406f          	j	ffffffffc0205306 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e48:	555d                	li	a0,-9
ffffffffc0200e4a:	75c030ef          	jal	ffffffffc02045a6 <do_exit>
            if (current->need_resched)
ffffffffc0200e4e:	0009b717          	auipc	a4,0x9b
ffffffffc0200e52:	d1a73703          	ld	a4,-742(a4) # ffffffffc029bb68 <current>
ffffffffc0200e56:	b7d9                	j	ffffffffc0200e1c <trap+0x48>

ffffffffc0200e58 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200e58:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200e5c:	00011463          	bnez	sp,ffffffffc0200e64 <__alltraps+0xc>
ffffffffc0200e60:	14002173          	csrr	sp,sscratch
ffffffffc0200e64:	712d                	addi	sp,sp,-288
ffffffffc0200e66:	e002                	sd	zero,0(sp)
ffffffffc0200e68:	e406                	sd	ra,8(sp)
ffffffffc0200e6a:	ec0e                	sd	gp,24(sp)
ffffffffc0200e6c:	f012                	sd	tp,32(sp)
ffffffffc0200e6e:	f416                	sd	t0,40(sp)
ffffffffc0200e70:	f81a                	sd	t1,48(sp)
ffffffffc0200e72:	fc1e                	sd	t2,56(sp)
ffffffffc0200e74:	e0a2                	sd	s0,64(sp)
ffffffffc0200e76:	e4a6                	sd	s1,72(sp)
ffffffffc0200e78:	e8aa                	sd	a0,80(sp)
ffffffffc0200e7a:	ecae                	sd	a1,88(sp)
ffffffffc0200e7c:	f0b2                	sd	a2,96(sp)
ffffffffc0200e7e:	f4b6                	sd	a3,104(sp)
ffffffffc0200e80:	f8ba                	sd	a4,112(sp)
ffffffffc0200e82:	fcbe                	sd	a5,120(sp)
ffffffffc0200e84:	e142                	sd	a6,128(sp)
ffffffffc0200e86:	e546                	sd	a7,136(sp)
ffffffffc0200e88:	e94a                	sd	s2,144(sp)
ffffffffc0200e8a:	ed4e                	sd	s3,152(sp)
ffffffffc0200e8c:	f152                	sd	s4,160(sp)
ffffffffc0200e8e:	f556                	sd	s5,168(sp)
ffffffffc0200e90:	f95a                	sd	s6,176(sp)
ffffffffc0200e92:	fd5e                	sd	s7,184(sp)
ffffffffc0200e94:	e1e2                	sd	s8,192(sp)
ffffffffc0200e96:	e5e6                	sd	s9,200(sp)
ffffffffc0200e98:	e9ea                	sd	s10,208(sp)
ffffffffc0200e9a:	edee                	sd	s11,216(sp)
ffffffffc0200e9c:	f1f2                	sd	t3,224(sp)
ffffffffc0200e9e:	f5f6                	sd	t4,232(sp)
ffffffffc0200ea0:	f9fa                	sd	t5,240(sp)
ffffffffc0200ea2:	fdfe                	sd	t6,248(sp)
ffffffffc0200ea4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200ea8:	100024f3          	csrr	s1,sstatus
ffffffffc0200eac:	14102973          	csrr	s2,sepc
ffffffffc0200eb0:	143029f3          	csrr	s3,stval
ffffffffc0200eb4:	14202a73          	csrr	s4,scause
ffffffffc0200eb8:	e822                	sd	s0,16(sp)
ffffffffc0200eba:	e226                	sd	s1,256(sp)
ffffffffc0200ebc:	e64a                	sd	s2,264(sp)
ffffffffc0200ebe:	ea4e                	sd	s3,272(sp)
ffffffffc0200ec0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ec2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ec4:	f11ff0ef          	jal	ffffffffc0200dd4 <trap>

ffffffffc0200ec8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ec8:	6492                	ld	s1,256(sp)
ffffffffc0200eca:	6932                	ld	s2,264(sp)
ffffffffc0200ecc:	1004f413          	andi	s0,s1,256
ffffffffc0200ed0:	e401                	bnez	s0,ffffffffc0200ed8 <__trapret+0x10>
ffffffffc0200ed2:	1200                	addi	s0,sp,288
ffffffffc0200ed4:	14041073          	csrw	sscratch,s0
ffffffffc0200ed8:	10049073          	csrw	sstatus,s1
ffffffffc0200edc:	14191073          	csrw	sepc,s2
ffffffffc0200ee0:	60a2                	ld	ra,8(sp)
ffffffffc0200ee2:	61e2                	ld	gp,24(sp)
ffffffffc0200ee4:	7202                	ld	tp,32(sp)
ffffffffc0200ee6:	72a2                	ld	t0,40(sp)
ffffffffc0200ee8:	7342                	ld	t1,48(sp)
ffffffffc0200eea:	73e2                	ld	t2,56(sp)
ffffffffc0200eec:	6406                	ld	s0,64(sp)
ffffffffc0200eee:	64a6                	ld	s1,72(sp)
ffffffffc0200ef0:	6546                	ld	a0,80(sp)
ffffffffc0200ef2:	65e6                	ld	a1,88(sp)
ffffffffc0200ef4:	7606                	ld	a2,96(sp)
ffffffffc0200ef6:	76a6                	ld	a3,104(sp)
ffffffffc0200ef8:	7746                	ld	a4,112(sp)
ffffffffc0200efa:	77e6                	ld	a5,120(sp)
ffffffffc0200efc:	680a                	ld	a6,128(sp)
ffffffffc0200efe:	68aa                	ld	a7,136(sp)
ffffffffc0200f00:	694a                	ld	s2,144(sp)
ffffffffc0200f02:	69ea                	ld	s3,152(sp)
ffffffffc0200f04:	7a0a                	ld	s4,160(sp)
ffffffffc0200f06:	7aaa                	ld	s5,168(sp)
ffffffffc0200f08:	7b4a                	ld	s6,176(sp)
ffffffffc0200f0a:	7bea                	ld	s7,184(sp)
ffffffffc0200f0c:	6c0e                	ld	s8,192(sp)
ffffffffc0200f0e:	6cae                	ld	s9,200(sp)
ffffffffc0200f10:	6d4e                	ld	s10,208(sp)
ffffffffc0200f12:	6dee                	ld	s11,216(sp)
ffffffffc0200f14:	7e0e                	ld	t3,224(sp)
ffffffffc0200f16:	7eae                	ld	t4,232(sp)
ffffffffc0200f18:	7f4e                	ld	t5,240(sp)
ffffffffc0200f1a:	7fee                	ld	t6,248(sp)
ffffffffc0200f1c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200f1e:	10200073          	sret

ffffffffc0200f22 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f22:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200f24:	b755                	j	ffffffffc0200ec8 <__trapret>

ffffffffc0200f26 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200f26:	ee058593          	addi	a1,a1,-288

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200f2a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200f2e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200f32:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200f36:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200f3a:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200f3e:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200f42:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200f46:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200f4a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200f4c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200f4e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200f50:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200f52:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200f54:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200f56:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200f58:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200f5a:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200f5c:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200f5e:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200f60:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200f62:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200f64:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200f66:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200f68:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200f6a:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200f6c:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200f6e:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200f70:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200f72:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200f74:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200f76:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200f78:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200f7a:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200f7c:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200f7e:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200f80:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200f82:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200f84:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200f86:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200f88:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200f8a:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200f8c:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200f8e:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200f90:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200f92:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200f94:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200f96:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200f98:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200f9a:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200f9c:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200f9e:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200fa0:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200fa2:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200fa4:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200fa6:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200fa8:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200faa:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200fac:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200fae:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200fb0:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200fb2:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200fb4:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200fb6:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200fb8:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200fba:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200fbc:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200fbe:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200fc0:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200fc2:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200fc4:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200fc6:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200fc8:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200fca:	812e                	mv	sp,a1
ffffffffc0200fcc:	bdf5                	j	ffffffffc0200ec8 <__trapret>

ffffffffc0200fce <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200fce:	00097797          	auipc	a5,0x97
ffffffffc0200fd2:	b0a78793          	addi	a5,a5,-1270 # ffffffffc0297ad8 <free_area>
ffffffffc0200fd6:	e79c                	sd	a5,8(a5)
ffffffffc0200fd8:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200fda:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200fde:	8082                	ret

ffffffffc0200fe0 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200fe0:	00097517          	auipc	a0,0x97
ffffffffc0200fe4:	b0856503          	lwu	a0,-1272(a0) # ffffffffc0297ae8 <free_area+0x10>
ffffffffc0200fe8:	8082                	ret

ffffffffc0200fea <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0200fea:	711d                	addi	sp,sp,-96
ffffffffc0200fec:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200fee:	00097917          	auipc	s2,0x97
ffffffffc0200ff2:	aea90913          	addi	s2,s2,-1302 # ffffffffc0297ad8 <free_area>
ffffffffc0200ff6:	00893783          	ld	a5,8(s2)
ffffffffc0200ffa:	ec86                	sd	ra,88(sp)
ffffffffc0200ffc:	e8a2                	sd	s0,80(sp)
ffffffffc0200ffe:	e4a6                	sd	s1,72(sp)
ffffffffc0201000:	fc4e                	sd	s3,56(sp)
ffffffffc0201002:	f852                	sd	s4,48(sp)
ffffffffc0201004:	f456                	sd	s5,40(sp)
ffffffffc0201006:	f05a                	sd	s6,32(sp)
ffffffffc0201008:	ec5e                	sd	s7,24(sp)
ffffffffc020100a:	e862                	sd	s8,16(sp)
ffffffffc020100c:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc020100e:	2f278363          	beq	a5,s2,ffffffffc02012f4 <default_check+0x30a>
    int count = 0, total = 0;
ffffffffc0201012:	4401                	li	s0,0
ffffffffc0201014:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201016:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020101a:	8b09                	andi	a4,a4,2
ffffffffc020101c:	2e070063          	beqz	a4,ffffffffc02012fc <default_check+0x312>
        count++, total += p->property;
ffffffffc0201020:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201024:	679c                	ld	a5,8(a5)
ffffffffc0201026:	2485                	addiw	s1,s1,1
ffffffffc0201028:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020102a:	ff2796e3          	bne	a5,s2,ffffffffc0201016 <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc020102e:	89a2                	mv	s3,s0
ffffffffc0201030:	741000ef          	jal	ffffffffc0201f70 <nr_free_pages>
ffffffffc0201034:	73351463          	bne	a0,s3,ffffffffc020175c <default_check+0x772>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201038:	4505                	li	a0,1
ffffffffc020103a:	6c5000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc020103e:	8a2a                	mv	s4,a0
ffffffffc0201040:	44050e63          	beqz	a0,ffffffffc020149c <default_check+0x4b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201044:	4505                	li	a0,1
ffffffffc0201046:	6b9000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc020104a:	89aa                	mv	s3,a0
ffffffffc020104c:	72050863          	beqz	a0,ffffffffc020177c <default_check+0x792>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201050:	4505                	li	a0,1
ffffffffc0201052:	6ad000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201056:	8aaa                	mv	s5,a0
ffffffffc0201058:	4c050263          	beqz	a0,ffffffffc020151c <default_check+0x532>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020105c:	40a987b3          	sub	a5,s3,a0
ffffffffc0201060:	40aa0733          	sub	a4,s4,a0
ffffffffc0201064:	0017b793          	seqz	a5,a5
ffffffffc0201068:	00173713          	seqz	a4,a4
ffffffffc020106c:	8fd9                	or	a5,a5,a4
ffffffffc020106e:	30079763          	bnez	a5,ffffffffc020137c <default_check+0x392>
ffffffffc0201072:	313a0563          	beq	s4,s3,ffffffffc020137c <default_check+0x392>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201076:	000a2783          	lw	a5,0(s4)
ffffffffc020107a:	2a079163          	bnez	a5,ffffffffc020131c <default_check+0x332>
ffffffffc020107e:	0009a783          	lw	a5,0(s3)
ffffffffc0201082:	28079d63          	bnez	a5,ffffffffc020131c <default_check+0x332>
ffffffffc0201086:	411c                	lw	a5,0(a0)
ffffffffc0201088:	28079a63          	bnez	a5,ffffffffc020131c <default_check+0x332>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc020108c:	0009b797          	auipc	a5,0x9b
ffffffffc0201090:	acc7b783          	ld	a5,-1332(a5) # ffffffffc029bb58 <pages>
ffffffffc0201094:	00007617          	auipc	a2,0x7
ffffffffc0201098:	a3c63603          	ld	a2,-1476(a2) # ffffffffc0207ad0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020109c:	0009b697          	auipc	a3,0x9b
ffffffffc02010a0:	ab46b683          	ld	a3,-1356(a3) # ffffffffc029bb50 <npage>
ffffffffc02010a4:	40fa0733          	sub	a4,s4,a5
ffffffffc02010a8:	8719                	srai	a4,a4,0x6
ffffffffc02010aa:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc02010ac:	0732                	slli	a4,a4,0xc
ffffffffc02010ae:	06b2                	slli	a3,a3,0xc
ffffffffc02010b0:	2ad77663          	bgeu	a4,a3,ffffffffc020135c <default_check+0x372>
    return page - pages + nbase;
ffffffffc02010b4:	40f98733          	sub	a4,s3,a5
ffffffffc02010b8:	8719                	srai	a4,a4,0x6
ffffffffc02010ba:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010bc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010be:	4cd77f63          	bgeu	a4,a3,ffffffffc020159c <default_check+0x5b2>
    return page - pages + nbase;
ffffffffc02010c2:	40f507b3          	sub	a5,a0,a5
ffffffffc02010c6:	8799                	srai	a5,a5,0x6
ffffffffc02010c8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010ca:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02010cc:	32d7f863          	bgeu	a5,a3,ffffffffc02013fc <default_check+0x412>
    assert(alloc_page() == NULL);
ffffffffc02010d0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010d2:	00093c03          	ld	s8,0(s2)
ffffffffc02010d6:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02010da:	00097b17          	auipc	s6,0x97
ffffffffc02010de:	a0eb2b03          	lw	s6,-1522(s6) # ffffffffc0297ae8 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc02010e2:	01293023          	sd	s2,0(s2)
ffffffffc02010e6:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc02010ea:	00097797          	auipc	a5,0x97
ffffffffc02010ee:	9e07af23          	sw	zero,-1538(a5) # ffffffffc0297ae8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02010f2:	60d000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc02010f6:	2e051363          	bnez	a0,ffffffffc02013dc <default_check+0x3f2>
    free_page(p0);
ffffffffc02010fa:	8552                	mv	a0,s4
ffffffffc02010fc:	4585                	li	a1,1
ffffffffc02010fe:	63b000ef          	jal	ffffffffc0201f38 <free_pages>
    free_page(p1);
ffffffffc0201102:	854e                	mv	a0,s3
ffffffffc0201104:	4585                	li	a1,1
ffffffffc0201106:	633000ef          	jal	ffffffffc0201f38 <free_pages>
    free_page(p2);
ffffffffc020110a:	8556                	mv	a0,s5
ffffffffc020110c:	4585                	li	a1,1
ffffffffc020110e:	62b000ef          	jal	ffffffffc0201f38 <free_pages>
    assert(nr_free == 3);
ffffffffc0201112:	00097717          	auipc	a4,0x97
ffffffffc0201116:	9d672703          	lw	a4,-1578(a4) # ffffffffc0297ae8 <free_area+0x10>
ffffffffc020111a:	478d                	li	a5,3
ffffffffc020111c:	2af71063          	bne	a4,a5,ffffffffc02013bc <default_check+0x3d2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201120:	4505                	li	a0,1
ffffffffc0201122:	5dd000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201126:	89aa                	mv	s3,a0
ffffffffc0201128:	26050a63          	beqz	a0,ffffffffc020139c <default_check+0x3b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020112c:	4505                	li	a0,1
ffffffffc020112e:	5d1000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201132:	8aaa                	mv	s5,a0
ffffffffc0201134:	3c050463          	beqz	a0,ffffffffc02014fc <default_check+0x512>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201138:	4505                	li	a0,1
ffffffffc020113a:	5c5000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc020113e:	8a2a                	mv	s4,a0
ffffffffc0201140:	38050e63          	beqz	a0,ffffffffc02014dc <default_check+0x4f2>
    assert(alloc_page() == NULL);
ffffffffc0201144:	4505                	li	a0,1
ffffffffc0201146:	5b9000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc020114a:	36051963          	bnez	a0,ffffffffc02014bc <default_check+0x4d2>
    free_page(p0);
ffffffffc020114e:	4585                	li	a1,1
ffffffffc0201150:	854e                	mv	a0,s3
ffffffffc0201152:	5e7000ef          	jal	ffffffffc0201f38 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201156:	00893783          	ld	a5,8(s2)
ffffffffc020115a:	1f278163          	beq	a5,s2,ffffffffc020133c <default_check+0x352>
    assert((p = alloc_page()) == p0);
ffffffffc020115e:	4505                	li	a0,1
ffffffffc0201160:	59f000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201164:	8caa                	mv	s9,a0
ffffffffc0201166:	30a99b63          	bne	s3,a0,ffffffffc020147c <default_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc020116a:	4505                	li	a0,1
ffffffffc020116c:	593000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201170:	2e051663          	bnez	a0,ffffffffc020145c <default_check+0x472>
    assert(nr_free == 0);
ffffffffc0201174:	00097797          	auipc	a5,0x97
ffffffffc0201178:	9747a783          	lw	a5,-1676(a5) # ffffffffc0297ae8 <free_area+0x10>
ffffffffc020117c:	2c079063          	bnez	a5,ffffffffc020143c <default_check+0x452>
    free_page(p);
ffffffffc0201180:	8566                	mv	a0,s9
ffffffffc0201182:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201184:	01893023          	sd	s8,0(s2)
ffffffffc0201188:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc020118c:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0201190:	5a9000ef          	jal	ffffffffc0201f38 <free_pages>
    free_page(p1);
ffffffffc0201194:	8556                	mv	a0,s5
ffffffffc0201196:	4585                	li	a1,1
ffffffffc0201198:	5a1000ef          	jal	ffffffffc0201f38 <free_pages>
    free_page(p2);
ffffffffc020119c:	8552                	mv	a0,s4
ffffffffc020119e:	4585                	li	a1,1
ffffffffc02011a0:	599000ef          	jal	ffffffffc0201f38 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02011a4:	4515                	li	a0,5
ffffffffc02011a6:	559000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc02011aa:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02011ac:	26050863          	beqz	a0,ffffffffc020141c <default_check+0x432>
ffffffffc02011b0:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc02011b2:	8b89                	andi	a5,a5,2
ffffffffc02011b4:	54079463          	bnez	a5,ffffffffc02016fc <default_check+0x712>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02011b8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02011ba:	00093b83          	ld	s7,0(s2)
ffffffffc02011be:	00893b03          	ld	s6,8(s2)
ffffffffc02011c2:	01293023          	sd	s2,0(s2)
ffffffffc02011c6:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc02011ca:	535000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc02011ce:	50051763          	bnez	a0,ffffffffc02016dc <default_check+0x6f2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02011d2:	08098a13          	addi	s4,s3,128
ffffffffc02011d6:	8552                	mv	a0,s4
ffffffffc02011d8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02011da:	00097c17          	auipc	s8,0x97
ffffffffc02011de:	90ec2c03          	lw	s8,-1778(s8) # ffffffffc0297ae8 <free_area+0x10>
    nr_free = 0;
ffffffffc02011e2:	00097797          	auipc	a5,0x97
ffffffffc02011e6:	9007a323          	sw	zero,-1786(a5) # ffffffffc0297ae8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02011ea:	54f000ef          	jal	ffffffffc0201f38 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02011ee:	4511                	li	a0,4
ffffffffc02011f0:	50f000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc02011f4:	4c051463          	bnez	a0,ffffffffc02016bc <default_check+0x6d2>
ffffffffc02011f8:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011fc:	8b89                	andi	a5,a5,2
ffffffffc02011fe:	48078f63          	beqz	a5,ffffffffc020169c <default_check+0x6b2>
ffffffffc0201202:	0909a503          	lw	a0,144(s3)
ffffffffc0201206:	478d                	li	a5,3
ffffffffc0201208:	48f51a63          	bne	a0,a5,ffffffffc020169c <default_check+0x6b2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020120c:	4f3000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201210:	8aaa                	mv	s5,a0
ffffffffc0201212:	46050563          	beqz	a0,ffffffffc020167c <default_check+0x692>
    assert(alloc_page() == NULL);
ffffffffc0201216:	4505                	li	a0,1
ffffffffc0201218:	4e7000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc020121c:	44051063          	bnez	a0,ffffffffc020165c <default_check+0x672>
    assert(p0 + 2 == p1);
ffffffffc0201220:	415a1e63          	bne	s4,s5,ffffffffc020163c <default_check+0x652>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201224:	4585                	li	a1,1
ffffffffc0201226:	854e                	mv	a0,s3
ffffffffc0201228:	511000ef          	jal	ffffffffc0201f38 <free_pages>
    free_pages(p1, 3);
ffffffffc020122c:	8552                	mv	a0,s4
ffffffffc020122e:	458d                	li	a1,3
ffffffffc0201230:	509000ef          	jal	ffffffffc0201f38 <free_pages>
ffffffffc0201234:	0089b783          	ld	a5,8(s3)
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201238:	8b89                	andi	a5,a5,2
ffffffffc020123a:	3e078163          	beqz	a5,ffffffffc020161c <default_check+0x632>
ffffffffc020123e:	0109aa83          	lw	s5,16(s3)
ffffffffc0201242:	4785                	li	a5,1
ffffffffc0201244:	3cfa9c63          	bne	s5,a5,ffffffffc020161c <default_check+0x632>
ffffffffc0201248:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020124c:	8b89                	andi	a5,a5,2
ffffffffc020124e:	3a078763          	beqz	a5,ffffffffc02015fc <default_check+0x612>
ffffffffc0201252:	010a2703          	lw	a4,16(s4)
ffffffffc0201256:	478d                	li	a5,3
ffffffffc0201258:	3af71263          	bne	a4,a5,ffffffffc02015fc <default_check+0x612>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020125c:	8556                	mv	a0,s5
ffffffffc020125e:	4a1000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201262:	36a99d63          	bne	s3,a0,ffffffffc02015dc <default_check+0x5f2>
    free_page(p0);
ffffffffc0201266:	85d6                	mv	a1,s5
ffffffffc0201268:	4d1000ef          	jal	ffffffffc0201f38 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020126c:	4509                	li	a0,2
ffffffffc020126e:	491000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201272:	34aa1563          	bne	s4,a0,ffffffffc02015bc <default_check+0x5d2>

    free_pages(p0, 2);
ffffffffc0201276:	4589                	li	a1,2
ffffffffc0201278:	4c1000ef          	jal	ffffffffc0201f38 <free_pages>
    free_page(p2);
ffffffffc020127c:	04098513          	addi	a0,s3,64
ffffffffc0201280:	85d6                	mv	a1,s5
ffffffffc0201282:	4b7000ef          	jal	ffffffffc0201f38 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201286:	4515                	li	a0,5
ffffffffc0201288:	477000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc020128c:	89aa                	mv	s3,a0
ffffffffc020128e:	48050763          	beqz	a0,ffffffffc020171c <default_check+0x732>
    assert(alloc_page() == NULL);
ffffffffc0201292:	8556                	mv	a0,s5
ffffffffc0201294:	46b000ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0201298:	2e051263          	bnez	a0,ffffffffc020157c <default_check+0x592>

    assert(nr_free == 0);
ffffffffc020129c:	00097797          	auipc	a5,0x97
ffffffffc02012a0:	84c7a783          	lw	a5,-1972(a5) # ffffffffc0297ae8 <free_area+0x10>
ffffffffc02012a4:	2a079c63          	bnez	a5,ffffffffc020155c <default_check+0x572>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02012a8:	854e                	mv	a0,s3
ffffffffc02012aa:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc02012ac:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc02012b0:	01793023          	sd	s7,0(s2)
ffffffffc02012b4:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc02012b8:	481000ef          	jal	ffffffffc0201f38 <free_pages>
    return listelm->next;
ffffffffc02012bc:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02012c0:	01278963          	beq	a5,s2,ffffffffc02012d2 <default_check+0x2e8>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02012c4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02012c8:	679c                	ld	a5,8(a5)
ffffffffc02012ca:	34fd                	addiw	s1,s1,-1
ffffffffc02012cc:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02012ce:	ff279be3          	bne	a5,s2,ffffffffc02012c4 <default_check+0x2da>
    }
    assert(count == 0);
ffffffffc02012d2:	26049563          	bnez	s1,ffffffffc020153c <default_check+0x552>
    assert(total == 0);
ffffffffc02012d6:	46041363          	bnez	s0,ffffffffc020173c <default_check+0x752>
}
ffffffffc02012da:	60e6                	ld	ra,88(sp)
ffffffffc02012dc:	6446                	ld	s0,80(sp)
ffffffffc02012de:	64a6                	ld	s1,72(sp)
ffffffffc02012e0:	6906                	ld	s2,64(sp)
ffffffffc02012e2:	79e2                	ld	s3,56(sp)
ffffffffc02012e4:	7a42                	ld	s4,48(sp)
ffffffffc02012e6:	7aa2                	ld	s5,40(sp)
ffffffffc02012e8:	7b02                	ld	s6,32(sp)
ffffffffc02012ea:	6be2                	ld	s7,24(sp)
ffffffffc02012ec:	6c42                	ld	s8,16(sp)
ffffffffc02012ee:	6ca2                	ld	s9,8(sp)
ffffffffc02012f0:	6125                	addi	sp,sp,96
ffffffffc02012f2:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc02012f4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02012f6:	4401                	li	s0,0
ffffffffc02012f8:	4481                	li	s1,0
ffffffffc02012fa:	bb1d                	j	ffffffffc0201030 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc02012fc:	00005697          	auipc	a3,0x5
ffffffffc0201300:	06c68693          	addi	a3,a3,108 # ffffffffc0206368 <etext+0xa3a>
ffffffffc0201304:	00005617          	auipc	a2,0x5
ffffffffc0201308:	07460613          	addi	a2,a2,116 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020130c:	11000593          	li	a1,272
ffffffffc0201310:	00005517          	auipc	a0,0x5
ffffffffc0201314:	08050513          	addi	a0,a0,128 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201318:	92eff0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020131c:	00005697          	auipc	a3,0x5
ffffffffc0201320:	13468693          	addi	a3,a3,308 # ffffffffc0206450 <etext+0xb22>
ffffffffc0201324:	00005617          	auipc	a2,0x5
ffffffffc0201328:	05460613          	addi	a2,a2,84 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020132c:	0dc00593          	li	a1,220
ffffffffc0201330:	00005517          	auipc	a0,0x5
ffffffffc0201334:	06050513          	addi	a0,a0,96 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201338:	90eff0ef          	jal	ffffffffc0200446 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020133c:	00005697          	auipc	a3,0x5
ffffffffc0201340:	1dc68693          	addi	a3,a3,476 # ffffffffc0206518 <etext+0xbea>
ffffffffc0201344:	00005617          	auipc	a2,0x5
ffffffffc0201348:	03460613          	addi	a2,a2,52 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020134c:	0f700593          	li	a1,247
ffffffffc0201350:	00005517          	auipc	a0,0x5
ffffffffc0201354:	04050513          	addi	a0,a0,64 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201358:	8eeff0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020135c:	00005697          	auipc	a3,0x5
ffffffffc0201360:	13468693          	addi	a3,a3,308 # ffffffffc0206490 <etext+0xb62>
ffffffffc0201364:	00005617          	auipc	a2,0x5
ffffffffc0201368:	01460613          	addi	a2,a2,20 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020136c:	0de00593          	li	a1,222
ffffffffc0201370:	00005517          	auipc	a0,0x5
ffffffffc0201374:	02050513          	addi	a0,a0,32 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201378:	8ceff0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020137c:	00005697          	auipc	a3,0x5
ffffffffc0201380:	0ac68693          	addi	a3,a3,172 # ffffffffc0206428 <etext+0xafa>
ffffffffc0201384:	00005617          	auipc	a2,0x5
ffffffffc0201388:	ff460613          	addi	a2,a2,-12 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020138c:	0db00593          	li	a1,219
ffffffffc0201390:	00005517          	auipc	a0,0x5
ffffffffc0201394:	00050513          	mv	a0,a0
ffffffffc0201398:	8aeff0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020139c:	00005697          	auipc	a3,0x5
ffffffffc02013a0:	02c68693          	addi	a3,a3,44 # ffffffffc02063c8 <etext+0xa9a>
ffffffffc02013a4:	00005617          	auipc	a2,0x5
ffffffffc02013a8:	fd460613          	addi	a2,a2,-44 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02013ac:	0f000593          	li	a1,240
ffffffffc02013b0:	00005517          	auipc	a0,0x5
ffffffffc02013b4:	fe050513          	addi	a0,a0,-32 # ffffffffc0206390 <etext+0xa62>
ffffffffc02013b8:	88eff0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 3);
ffffffffc02013bc:	00005697          	auipc	a3,0x5
ffffffffc02013c0:	14c68693          	addi	a3,a3,332 # ffffffffc0206508 <etext+0xbda>
ffffffffc02013c4:	00005617          	auipc	a2,0x5
ffffffffc02013c8:	fb460613          	addi	a2,a2,-76 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02013cc:	0ee00593          	li	a1,238
ffffffffc02013d0:	00005517          	auipc	a0,0x5
ffffffffc02013d4:	fc050513          	addi	a0,a0,-64 # ffffffffc0206390 <etext+0xa62>
ffffffffc02013d8:	86eff0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013dc:	00005697          	auipc	a3,0x5
ffffffffc02013e0:	11468693          	addi	a3,a3,276 # ffffffffc02064f0 <etext+0xbc2>
ffffffffc02013e4:	00005617          	auipc	a2,0x5
ffffffffc02013e8:	f9460613          	addi	a2,a2,-108 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02013ec:	0e900593          	li	a1,233
ffffffffc02013f0:	00005517          	auipc	a0,0x5
ffffffffc02013f4:	fa050513          	addi	a0,a0,-96 # ffffffffc0206390 <etext+0xa62>
ffffffffc02013f8:	84eff0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02013fc:	00005697          	auipc	a3,0x5
ffffffffc0201400:	0d468693          	addi	a3,a3,212 # ffffffffc02064d0 <etext+0xba2>
ffffffffc0201404:	00005617          	auipc	a2,0x5
ffffffffc0201408:	f7460613          	addi	a2,a2,-140 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020140c:	0e000593          	li	a1,224
ffffffffc0201410:	00005517          	auipc	a0,0x5
ffffffffc0201414:	f8050513          	addi	a0,a0,-128 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201418:	82eff0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 != NULL);
ffffffffc020141c:	00005697          	auipc	a3,0x5
ffffffffc0201420:	14468693          	addi	a3,a3,324 # ffffffffc0206560 <etext+0xc32>
ffffffffc0201424:	00005617          	auipc	a2,0x5
ffffffffc0201428:	f5460613          	addi	a2,a2,-172 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020142c:	11800593          	li	a1,280
ffffffffc0201430:	00005517          	auipc	a0,0x5
ffffffffc0201434:	f6050513          	addi	a0,a0,-160 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201438:	80eff0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc020143c:	00005697          	auipc	a3,0x5
ffffffffc0201440:	11468693          	addi	a3,a3,276 # ffffffffc0206550 <etext+0xc22>
ffffffffc0201444:	00005617          	auipc	a2,0x5
ffffffffc0201448:	f3460613          	addi	a2,a2,-204 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020144c:	0fd00593          	li	a1,253
ffffffffc0201450:	00005517          	auipc	a0,0x5
ffffffffc0201454:	f4050513          	addi	a0,a0,-192 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201458:	feffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020145c:	00005697          	auipc	a3,0x5
ffffffffc0201460:	09468693          	addi	a3,a3,148 # ffffffffc02064f0 <etext+0xbc2>
ffffffffc0201464:	00005617          	auipc	a2,0x5
ffffffffc0201468:	f1460613          	addi	a2,a2,-236 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020146c:	0fb00593          	li	a1,251
ffffffffc0201470:	00005517          	auipc	a0,0x5
ffffffffc0201474:	f2050513          	addi	a0,a0,-224 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201478:	fcffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020147c:	00005697          	auipc	a3,0x5
ffffffffc0201480:	0b468693          	addi	a3,a3,180 # ffffffffc0206530 <etext+0xc02>
ffffffffc0201484:	00005617          	auipc	a2,0x5
ffffffffc0201488:	ef460613          	addi	a2,a2,-268 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020148c:	0fa00593          	li	a1,250
ffffffffc0201490:	00005517          	auipc	a0,0x5
ffffffffc0201494:	f0050513          	addi	a0,a0,-256 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201498:	faffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020149c:	00005697          	auipc	a3,0x5
ffffffffc02014a0:	f2c68693          	addi	a3,a3,-212 # ffffffffc02063c8 <etext+0xa9a>
ffffffffc02014a4:	00005617          	auipc	a2,0x5
ffffffffc02014a8:	ed460613          	addi	a2,a2,-300 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02014ac:	0d700593          	li	a1,215
ffffffffc02014b0:	00005517          	auipc	a0,0x5
ffffffffc02014b4:	ee050513          	addi	a0,a0,-288 # ffffffffc0206390 <etext+0xa62>
ffffffffc02014b8:	f8ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014bc:	00005697          	auipc	a3,0x5
ffffffffc02014c0:	03468693          	addi	a3,a3,52 # ffffffffc02064f0 <etext+0xbc2>
ffffffffc02014c4:	00005617          	auipc	a2,0x5
ffffffffc02014c8:	eb460613          	addi	a2,a2,-332 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02014cc:	0f400593          	li	a1,244
ffffffffc02014d0:	00005517          	auipc	a0,0x5
ffffffffc02014d4:	ec050513          	addi	a0,a0,-320 # ffffffffc0206390 <etext+0xa62>
ffffffffc02014d8:	f6ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014dc:	00005697          	auipc	a3,0x5
ffffffffc02014e0:	f2c68693          	addi	a3,a3,-212 # ffffffffc0206408 <etext+0xada>
ffffffffc02014e4:	00005617          	auipc	a2,0x5
ffffffffc02014e8:	e9460613          	addi	a2,a2,-364 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02014ec:	0f200593          	li	a1,242
ffffffffc02014f0:	00005517          	auipc	a0,0x5
ffffffffc02014f4:	ea050513          	addi	a0,a0,-352 # ffffffffc0206390 <etext+0xa62>
ffffffffc02014f8:	f4ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014fc:	00005697          	auipc	a3,0x5
ffffffffc0201500:	eec68693          	addi	a3,a3,-276 # ffffffffc02063e8 <etext+0xaba>
ffffffffc0201504:	00005617          	auipc	a2,0x5
ffffffffc0201508:	e7460613          	addi	a2,a2,-396 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020150c:	0f100593          	li	a1,241
ffffffffc0201510:	00005517          	auipc	a0,0x5
ffffffffc0201514:	e8050513          	addi	a0,a0,-384 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201518:	f2ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020151c:	00005697          	auipc	a3,0x5
ffffffffc0201520:	eec68693          	addi	a3,a3,-276 # ffffffffc0206408 <etext+0xada>
ffffffffc0201524:	00005617          	auipc	a2,0x5
ffffffffc0201528:	e5460613          	addi	a2,a2,-428 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020152c:	0d900593          	li	a1,217
ffffffffc0201530:	00005517          	auipc	a0,0x5
ffffffffc0201534:	e6050513          	addi	a0,a0,-416 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201538:	f0ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(count == 0);
ffffffffc020153c:	00005697          	auipc	a3,0x5
ffffffffc0201540:	17468693          	addi	a3,a3,372 # ffffffffc02066b0 <etext+0xd82>
ffffffffc0201544:	00005617          	auipc	a2,0x5
ffffffffc0201548:	e3460613          	addi	a2,a2,-460 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020154c:	14600593          	li	a1,326
ffffffffc0201550:	00005517          	auipc	a0,0x5
ffffffffc0201554:	e4050513          	addi	a0,a0,-448 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201558:	eeffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc020155c:	00005697          	auipc	a3,0x5
ffffffffc0201560:	ff468693          	addi	a3,a3,-12 # ffffffffc0206550 <etext+0xc22>
ffffffffc0201564:	00005617          	auipc	a2,0x5
ffffffffc0201568:	e1460613          	addi	a2,a2,-492 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020156c:	13a00593          	li	a1,314
ffffffffc0201570:	00005517          	auipc	a0,0x5
ffffffffc0201574:	e2050513          	addi	a0,a0,-480 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201578:	ecffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020157c:	00005697          	auipc	a3,0x5
ffffffffc0201580:	f7468693          	addi	a3,a3,-140 # ffffffffc02064f0 <etext+0xbc2>
ffffffffc0201584:	00005617          	auipc	a2,0x5
ffffffffc0201588:	df460613          	addi	a2,a2,-524 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020158c:	13800593          	li	a1,312
ffffffffc0201590:	00005517          	auipc	a0,0x5
ffffffffc0201594:	e0050513          	addi	a0,a0,-512 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201598:	eaffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020159c:	00005697          	auipc	a3,0x5
ffffffffc02015a0:	f1468693          	addi	a3,a3,-236 # ffffffffc02064b0 <etext+0xb82>
ffffffffc02015a4:	00005617          	auipc	a2,0x5
ffffffffc02015a8:	dd460613          	addi	a2,a2,-556 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02015ac:	0df00593          	li	a1,223
ffffffffc02015b0:	00005517          	auipc	a0,0x5
ffffffffc02015b4:	de050513          	addi	a0,a0,-544 # ffffffffc0206390 <etext+0xa62>
ffffffffc02015b8:	e8ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02015bc:	00005697          	auipc	a3,0x5
ffffffffc02015c0:	0b468693          	addi	a3,a3,180 # ffffffffc0206670 <etext+0xd42>
ffffffffc02015c4:	00005617          	auipc	a2,0x5
ffffffffc02015c8:	db460613          	addi	a2,a2,-588 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02015cc:	13200593          	li	a1,306
ffffffffc02015d0:	00005517          	auipc	a0,0x5
ffffffffc02015d4:	dc050513          	addi	a0,a0,-576 # ffffffffc0206390 <etext+0xa62>
ffffffffc02015d8:	e6ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02015dc:	00005697          	auipc	a3,0x5
ffffffffc02015e0:	07468693          	addi	a3,a3,116 # ffffffffc0206650 <etext+0xd22>
ffffffffc02015e4:	00005617          	auipc	a2,0x5
ffffffffc02015e8:	d9460613          	addi	a2,a2,-620 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02015ec:	13000593          	li	a1,304
ffffffffc02015f0:	00005517          	auipc	a0,0x5
ffffffffc02015f4:	da050513          	addi	a0,a0,-608 # ffffffffc0206390 <etext+0xa62>
ffffffffc02015f8:	e4ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02015fc:	00005697          	auipc	a3,0x5
ffffffffc0201600:	02c68693          	addi	a3,a3,44 # ffffffffc0206628 <etext+0xcfa>
ffffffffc0201604:	00005617          	auipc	a2,0x5
ffffffffc0201608:	d7460613          	addi	a2,a2,-652 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020160c:	12e00593          	li	a1,302
ffffffffc0201610:	00005517          	auipc	a0,0x5
ffffffffc0201614:	d8050513          	addi	a0,a0,-640 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201618:	e2ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020161c:	00005697          	auipc	a3,0x5
ffffffffc0201620:	fe468693          	addi	a3,a3,-28 # ffffffffc0206600 <etext+0xcd2>
ffffffffc0201624:	00005617          	auipc	a2,0x5
ffffffffc0201628:	d5460613          	addi	a2,a2,-684 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020162c:	12d00593          	li	a1,301
ffffffffc0201630:	00005517          	auipc	a0,0x5
ffffffffc0201634:	d6050513          	addi	a0,a0,-672 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201638:	e0ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020163c:	00005697          	auipc	a3,0x5
ffffffffc0201640:	fb468693          	addi	a3,a3,-76 # ffffffffc02065f0 <etext+0xcc2>
ffffffffc0201644:	00005617          	auipc	a2,0x5
ffffffffc0201648:	d3460613          	addi	a2,a2,-716 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020164c:	12800593          	li	a1,296
ffffffffc0201650:	00005517          	auipc	a0,0x5
ffffffffc0201654:	d4050513          	addi	a0,a0,-704 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201658:	deffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020165c:	00005697          	auipc	a3,0x5
ffffffffc0201660:	e9468693          	addi	a3,a3,-364 # ffffffffc02064f0 <etext+0xbc2>
ffffffffc0201664:	00005617          	auipc	a2,0x5
ffffffffc0201668:	d1460613          	addi	a2,a2,-748 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020166c:	12700593          	li	a1,295
ffffffffc0201670:	00005517          	auipc	a0,0x5
ffffffffc0201674:	d2050513          	addi	a0,a0,-736 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201678:	dcffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020167c:	00005697          	auipc	a3,0x5
ffffffffc0201680:	f5468693          	addi	a3,a3,-172 # ffffffffc02065d0 <etext+0xca2>
ffffffffc0201684:	00005617          	auipc	a2,0x5
ffffffffc0201688:	cf460613          	addi	a2,a2,-780 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020168c:	12600593          	li	a1,294
ffffffffc0201690:	00005517          	auipc	a0,0x5
ffffffffc0201694:	d0050513          	addi	a0,a0,-768 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201698:	daffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020169c:	00005697          	auipc	a3,0x5
ffffffffc02016a0:	f0468693          	addi	a3,a3,-252 # ffffffffc02065a0 <etext+0xc72>
ffffffffc02016a4:	00005617          	auipc	a2,0x5
ffffffffc02016a8:	cd460613          	addi	a2,a2,-812 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02016ac:	12500593          	li	a1,293
ffffffffc02016b0:	00005517          	auipc	a0,0x5
ffffffffc02016b4:	ce050513          	addi	a0,a0,-800 # ffffffffc0206390 <etext+0xa62>
ffffffffc02016b8:	d8ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02016bc:	00005697          	auipc	a3,0x5
ffffffffc02016c0:	ecc68693          	addi	a3,a3,-308 # ffffffffc0206588 <etext+0xc5a>
ffffffffc02016c4:	00005617          	auipc	a2,0x5
ffffffffc02016c8:	cb460613          	addi	a2,a2,-844 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02016cc:	12400593          	li	a1,292
ffffffffc02016d0:	00005517          	auipc	a0,0x5
ffffffffc02016d4:	cc050513          	addi	a0,a0,-832 # ffffffffc0206390 <etext+0xa62>
ffffffffc02016d8:	d6ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016dc:	00005697          	auipc	a3,0x5
ffffffffc02016e0:	e1468693          	addi	a3,a3,-492 # ffffffffc02064f0 <etext+0xbc2>
ffffffffc02016e4:	00005617          	auipc	a2,0x5
ffffffffc02016e8:	c9460613          	addi	a2,a2,-876 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02016ec:	11e00593          	li	a1,286
ffffffffc02016f0:	00005517          	auipc	a0,0x5
ffffffffc02016f4:	ca050513          	addi	a0,a0,-864 # ffffffffc0206390 <etext+0xa62>
ffffffffc02016f8:	d4ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(!PageProperty(p0));
ffffffffc02016fc:	00005697          	auipc	a3,0x5
ffffffffc0201700:	e7468693          	addi	a3,a3,-396 # ffffffffc0206570 <etext+0xc42>
ffffffffc0201704:	00005617          	auipc	a2,0x5
ffffffffc0201708:	c7460613          	addi	a2,a2,-908 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020170c:	11900593          	li	a1,281
ffffffffc0201710:	00005517          	auipc	a0,0x5
ffffffffc0201714:	c8050513          	addi	a0,a0,-896 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201718:	d2ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020171c:	00005697          	auipc	a3,0x5
ffffffffc0201720:	f7468693          	addi	a3,a3,-140 # ffffffffc0206690 <etext+0xd62>
ffffffffc0201724:	00005617          	auipc	a2,0x5
ffffffffc0201728:	c5460613          	addi	a2,a2,-940 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020172c:	13700593          	li	a1,311
ffffffffc0201730:	00005517          	auipc	a0,0x5
ffffffffc0201734:	c6050513          	addi	a0,a0,-928 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201738:	d0ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(total == 0);
ffffffffc020173c:	00005697          	auipc	a3,0x5
ffffffffc0201740:	f8468693          	addi	a3,a3,-124 # ffffffffc02066c0 <etext+0xd92>
ffffffffc0201744:	00005617          	auipc	a2,0x5
ffffffffc0201748:	c3460613          	addi	a2,a2,-972 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020174c:	14700593          	li	a1,327
ffffffffc0201750:	00005517          	auipc	a0,0x5
ffffffffc0201754:	c4050513          	addi	a0,a0,-960 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201758:	ceffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(total == nr_free_pages());
ffffffffc020175c:	00005697          	auipc	a3,0x5
ffffffffc0201760:	c4c68693          	addi	a3,a3,-948 # ffffffffc02063a8 <etext+0xa7a>
ffffffffc0201764:	00005617          	auipc	a2,0x5
ffffffffc0201768:	c1460613          	addi	a2,a2,-1004 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020176c:	11300593          	li	a1,275
ffffffffc0201770:	00005517          	auipc	a0,0x5
ffffffffc0201774:	c2050513          	addi	a0,a0,-992 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201778:	ccffe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020177c:	00005697          	auipc	a3,0x5
ffffffffc0201780:	c6c68693          	addi	a3,a3,-916 # ffffffffc02063e8 <etext+0xaba>
ffffffffc0201784:	00005617          	auipc	a2,0x5
ffffffffc0201788:	bf460613          	addi	a2,a2,-1036 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020178c:	0d800593          	li	a1,216
ffffffffc0201790:	00005517          	auipc	a0,0x5
ffffffffc0201794:	c0050513          	addi	a0,a0,-1024 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201798:	caffe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020179c <default_free_pages>:
{
ffffffffc020179c:	1141                	addi	sp,sp,-16
ffffffffc020179e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017a0:	14058663          	beqz	a1,ffffffffc02018ec <default_free_pages+0x150>
    for (; p != base + n; p++)
ffffffffc02017a4:	00659713          	slli	a4,a1,0x6
ffffffffc02017a8:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02017ac:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02017ae:	c30d                	beqz	a4,ffffffffc02017d0 <default_free_pages+0x34>
ffffffffc02017b0:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017b2:	8b05                	andi	a4,a4,1
ffffffffc02017b4:	10071c63          	bnez	a4,ffffffffc02018cc <default_free_pages+0x130>
ffffffffc02017b8:	6798                	ld	a4,8(a5)
ffffffffc02017ba:	8b09                	andi	a4,a4,2
ffffffffc02017bc:	10071863          	bnez	a4,ffffffffc02018cc <default_free_pages+0x130>
        p->flags = 0;
ffffffffc02017c0:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02017c4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02017c8:	04078793          	addi	a5,a5,64
ffffffffc02017cc:	fed792e3          	bne	a5,a3,ffffffffc02017b0 <default_free_pages+0x14>
    base->property = n;
ffffffffc02017d0:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02017d2:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017d6:	4789                	li	a5,2
ffffffffc02017d8:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02017dc:	00096717          	auipc	a4,0x96
ffffffffc02017e0:	30c72703          	lw	a4,780(a4) # ffffffffc0297ae8 <free_area+0x10>
ffffffffc02017e4:	00096697          	auipc	a3,0x96
ffffffffc02017e8:	2f468693          	addi	a3,a3,756 # ffffffffc0297ad8 <free_area>
    return list->next == list;
ffffffffc02017ec:	669c                	ld	a5,8(a3)
ffffffffc02017ee:	9f2d                	addw	a4,a4,a1
ffffffffc02017f0:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc02017f2:	0ad78163          	beq	a5,a3,ffffffffc0201894 <default_free_pages+0xf8>
            struct Page *page = le2page(le, page_link);
ffffffffc02017f6:	fe878713          	addi	a4,a5,-24
ffffffffc02017fa:	4581                	li	a1,0
ffffffffc02017fc:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc0201800:	00e56a63          	bltu	a0,a4,ffffffffc0201814 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201804:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201806:	04d70c63          	beq	a4,a3,ffffffffc020185e <default_free_pages+0xc2>
    struct Page *p = base;
ffffffffc020180a:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc020180c:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201810:	fee57ae3          	bgeu	a0,a4,ffffffffc0201804 <default_free_pages+0x68>
ffffffffc0201814:	c199                	beqz	a1,ffffffffc020181a <default_free_pages+0x7e>
ffffffffc0201816:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020181a:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020181c:	e390                	sd	a2,0(a5)
ffffffffc020181e:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc0201820:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201822:	f11c                	sd	a5,32(a0)
    if (le != &free_list)
ffffffffc0201824:	00d70d63          	beq	a4,a3,ffffffffc020183e <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0201828:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020182c:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0201830:	02059813          	slli	a6,a1,0x20
ffffffffc0201834:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201838:	97b2                	add	a5,a5,a2
ffffffffc020183a:	02f50c63          	beq	a0,a5,ffffffffc0201872 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020183e:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0201840:	00d78c63          	beq	a5,a3,ffffffffc0201858 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0201844:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201846:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc020184a:	02061593          	slli	a1,a2,0x20
ffffffffc020184e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201852:	972a                	add	a4,a4,a0
ffffffffc0201854:	04e68c63          	beq	a3,a4,ffffffffc02018ac <default_free_pages+0x110>
}
ffffffffc0201858:	60a2                	ld	ra,8(sp)
ffffffffc020185a:	0141                	addi	sp,sp,16
ffffffffc020185c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020185e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201860:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201862:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201864:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201866:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc0201868:	02d70f63          	beq	a4,a3,ffffffffc02018a6 <default_free_pages+0x10a>
ffffffffc020186c:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020186e:	87ba                	mv	a5,a4
ffffffffc0201870:	bf71                	j	ffffffffc020180c <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201872:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201874:	5875                	li	a6,-3
ffffffffc0201876:	9fad                	addw	a5,a5,a1
ffffffffc0201878:	fef72c23          	sw	a5,-8(a4)
ffffffffc020187c:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201880:	01853803          	ld	a6,24(a0)
ffffffffc0201884:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201886:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201888:	00b83423          	sd	a1,8(a6) # ff0008 <_binary_obj___user_exit_out_size+0xfe5e00>
    return listelm->next;
ffffffffc020188c:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020188e:	0105b023          	sd	a6,0(a1)
ffffffffc0201892:	b77d                	j	ffffffffc0201840 <default_free_pages+0xa4>
}
ffffffffc0201894:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201896:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc020189a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020189c:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc020189e:	e398                	sd	a4,0(a5)
ffffffffc02018a0:	e798                	sd	a4,8(a5)
}
ffffffffc02018a2:	0141                	addi	sp,sp,16
ffffffffc02018a4:	8082                	ret
ffffffffc02018a6:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02018a8:	873e                	mv	a4,a5
ffffffffc02018aa:	bfad                	j	ffffffffc0201824 <default_free_pages+0x88>
            base->property += p->property;
ffffffffc02018ac:	ff87a703          	lw	a4,-8(a5)
ffffffffc02018b0:	56f5                	li	a3,-3
ffffffffc02018b2:	9f31                	addw	a4,a4,a2
ffffffffc02018b4:	c918                	sw	a4,16(a0)
ffffffffc02018b6:	ff078713          	addi	a4,a5,-16
ffffffffc02018ba:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02018be:	6398                	ld	a4,0(a5)
ffffffffc02018c0:	679c                	ld	a5,8(a5)
}
ffffffffc02018c2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02018c4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02018c6:	e398                	sd	a4,0(a5)
ffffffffc02018c8:	0141                	addi	sp,sp,16
ffffffffc02018ca:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02018cc:	00005697          	auipc	a3,0x5
ffffffffc02018d0:	e0c68693          	addi	a3,a3,-500 # ffffffffc02066d8 <etext+0xdaa>
ffffffffc02018d4:	00005617          	auipc	a2,0x5
ffffffffc02018d8:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02018dc:	09400593          	li	a1,148
ffffffffc02018e0:	00005517          	auipc	a0,0x5
ffffffffc02018e4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0206390 <etext+0xa62>
ffffffffc02018e8:	b5ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc02018ec:	00005697          	auipc	a3,0x5
ffffffffc02018f0:	de468693          	addi	a3,a3,-540 # ffffffffc02066d0 <etext+0xda2>
ffffffffc02018f4:	00005617          	auipc	a2,0x5
ffffffffc02018f8:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02018fc:	09000593          	li	a1,144
ffffffffc0201900:	00005517          	auipc	a0,0x5
ffffffffc0201904:	a9050513          	addi	a0,a0,-1392 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201908:	b3ffe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020190c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020190c:	c951                	beqz	a0,ffffffffc02019a0 <default_alloc_pages+0x94>
    if (n > nr_free)
ffffffffc020190e:	00096597          	auipc	a1,0x96
ffffffffc0201912:	1da5a583          	lw	a1,474(a1) # ffffffffc0297ae8 <free_area+0x10>
ffffffffc0201916:	86aa                	mv	a3,a0
ffffffffc0201918:	02059793          	slli	a5,a1,0x20
ffffffffc020191c:	9381                	srli	a5,a5,0x20
ffffffffc020191e:	00a7ef63          	bltu	a5,a0,ffffffffc020193c <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc0201922:	00096617          	auipc	a2,0x96
ffffffffc0201926:	1b660613          	addi	a2,a2,438 # ffffffffc0297ad8 <free_area>
ffffffffc020192a:	87b2                	mv	a5,a2
ffffffffc020192c:	a029                	j	ffffffffc0201936 <default_alloc_pages+0x2a>
        if (p->property >= n)
ffffffffc020192e:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0201932:	00d77763          	bgeu	a4,a3,ffffffffc0201940 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc0201936:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0201938:	fec79be3          	bne	a5,a2,ffffffffc020192e <default_alloc_pages+0x22>
        return NULL;
ffffffffc020193c:	4501                	li	a0,0
}
ffffffffc020193e:	8082                	ret
        if (page->property > n)
ffffffffc0201940:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc0201944:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201948:	6798                	ld	a4,8(a5)
ffffffffc020194a:	02089313          	slli	t1,a7,0x20
ffffffffc020194e:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc0201952:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201956:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc020195a:	fe878513          	addi	a0,a5,-24
        if (page->property > n)
ffffffffc020195e:	0266fa63          	bgeu	a3,t1,ffffffffc0201992 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0201962:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc0201966:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc020196a:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020196c:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201970:	00870313          	addi	t1,a4,8
ffffffffc0201974:	4889                	li	a7,2
ffffffffc0201976:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020197a:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc020197e:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc0201982:	0068b023          	sd	t1,0(a7)
ffffffffc0201986:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc020198a:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc020198e:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc0201992:	9d95                	subw	a1,a1,a3
ffffffffc0201994:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201996:	5775                	li	a4,-3
ffffffffc0201998:	17c1                	addi	a5,a5,-16
ffffffffc020199a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020199e:	8082                	ret
{
ffffffffc02019a0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02019a2:	00005697          	auipc	a3,0x5
ffffffffc02019a6:	d2e68693          	addi	a3,a3,-722 # ffffffffc02066d0 <etext+0xda2>
ffffffffc02019aa:	00005617          	auipc	a2,0x5
ffffffffc02019ae:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02019b2:	06c00593          	li	a1,108
ffffffffc02019b6:	00005517          	auipc	a0,0x5
ffffffffc02019ba:	9da50513          	addi	a0,a0,-1574 # ffffffffc0206390 <etext+0xa62>
{
ffffffffc02019be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02019c0:	a87fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02019c4 <default_init_memmap>:
{
ffffffffc02019c4:	1141                	addi	sp,sp,-16
ffffffffc02019c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02019c8:	c9e1                	beqz	a1,ffffffffc0201a98 <default_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc02019ca:	00659713          	slli	a4,a1,0x6
ffffffffc02019ce:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02019d2:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02019d4:	cf11                	beqz	a4,ffffffffc02019f0 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02019d6:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02019d8:	8b05                	andi	a4,a4,1
ffffffffc02019da:	cf59                	beqz	a4,ffffffffc0201a78 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02019dc:	0007a823          	sw	zero,16(a5)
ffffffffc02019e0:	0007b423          	sd	zero,8(a5)
ffffffffc02019e4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02019e8:	04078793          	addi	a5,a5,64
ffffffffc02019ec:	fed795e3          	bne	a5,a3,ffffffffc02019d6 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02019f0:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019f2:	4789                	li	a5,2
ffffffffc02019f4:	00850713          	addi	a4,a0,8
ffffffffc02019f8:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02019fc:	00096717          	auipc	a4,0x96
ffffffffc0201a00:	0ec72703          	lw	a4,236(a4) # ffffffffc0297ae8 <free_area+0x10>
ffffffffc0201a04:	00096697          	auipc	a3,0x96
ffffffffc0201a08:	0d468693          	addi	a3,a3,212 # ffffffffc0297ad8 <free_area>
    return list->next == list;
ffffffffc0201a0c:	669c                	ld	a5,8(a3)
ffffffffc0201a0e:	9f2d                	addw	a4,a4,a1
ffffffffc0201a10:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc0201a12:	04d78663          	beq	a5,a3,ffffffffc0201a5e <default_init_memmap+0x9a>
            struct Page *page = le2page(le, page_link);
ffffffffc0201a16:	fe878713          	addi	a4,a5,-24
ffffffffc0201a1a:	4581                	li	a1,0
ffffffffc0201a1c:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc0201a20:	00e56a63          	bltu	a0,a4,ffffffffc0201a34 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201a24:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201a26:	02d70263          	beq	a4,a3,ffffffffc0201a4a <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc0201a2a:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201a2c:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201a30:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a24 <default_init_memmap+0x60>
ffffffffc0201a34:	c199                	beqz	a1,ffffffffc0201a3a <default_init_memmap+0x76>
ffffffffc0201a36:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201a3a:	6398                	ld	a4,0(a5)
}
ffffffffc0201a3c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201a3e:	e390                	sd	a2,0(a5)
ffffffffc0201a40:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0201a42:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201a44:	f11c                	sd	a5,32(a0)
ffffffffc0201a46:	0141                	addi	sp,sp,16
ffffffffc0201a48:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201a4a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201a4c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201a4e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201a50:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201a52:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc0201a54:	00d70e63          	beq	a4,a3,ffffffffc0201a70 <default_init_memmap+0xac>
ffffffffc0201a58:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201a5a:	87ba                	mv	a5,a4
ffffffffc0201a5c:	bfc1                	j	ffffffffc0201a2c <default_init_memmap+0x68>
}
ffffffffc0201a5e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201a60:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201a64:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201a66:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201a68:	e398                	sd	a4,0(a5)
ffffffffc0201a6a:	e798                	sd	a4,8(a5)
}
ffffffffc0201a6c:	0141                	addi	sp,sp,16
ffffffffc0201a6e:	8082                	ret
ffffffffc0201a70:	60a2                	ld	ra,8(sp)
ffffffffc0201a72:	e290                	sd	a2,0(a3)
ffffffffc0201a74:	0141                	addi	sp,sp,16
ffffffffc0201a76:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201a78:	00005697          	auipc	a3,0x5
ffffffffc0201a7c:	c8868693          	addi	a3,a3,-888 # ffffffffc0206700 <etext+0xdd2>
ffffffffc0201a80:	00005617          	auipc	a2,0x5
ffffffffc0201a84:	8f860613          	addi	a2,a2,-1800 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0201a88:	04b00593          	li	a1,75
ffffffffc0201a8c:	00005517          	auipc	a0,0x5
ffffffffc0201a90:	90450513          	addi	a0,a0,-1788 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201a94:	9b3fe0ef          	jal	ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc0201a98:	00005697          	auipc	a3,0x5
ffffffffc0201a9c:	c3868693          	addi	a3,a3,-968 # ffffffffc02066d0 <etext+0xda2>
ffffffffc0201aa0:	00005617          	auipc	a2,0x5
ffffffffc0201aa4:	8d860613          	addi	a2,a2,-1832 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0201aa8:	04700593          	li	a1,71
ffffffffc0201aac:	00005517          	auipc	a0,0x5
ffffffffc0201ab0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0206390 <etext+0xa62>
ffffffffc0201ab4:	993fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201ab8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201ab8:	c531                	beqz	a0,ffffffffc0201b04 <slob_free+0x4c>
		return;

	if (size)
ffffffffc0201aba:	e9b9                	bnez	a1,ffffffffc0201b10 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201abc:	100027f3          	csrr	a5,sstatus
ffffffffc0201ac0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201ac2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ac4:	efb1                	bnez	a5,ffffffffc0201b20 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ac6:	00096797          	auipc	a5,0x96
ffffffffc0201aca:	c027b783          	ld	a5,-1022(a5) # ffffffffc02976c8 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ace:	873e                	mv	a4,a5
ffffffffc0201ad0:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ad2:	02a77a63          	bgeu	a4,a0,ffffffffc0201b06 <slob_free+0x4e>
ffffffffc0201ad6:	00f56463          	bltu	a0,a5,ffffffffc0201ade <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ada:	fef76ae3          	bltu	a4,a5,ffffffffc0201ace <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc0201ade:	4110                	lw	a2,0(a0)
ffffffffc0201ae0:	00461693          	slli	a3,a2,0x4
ffffffffc0201ae4:	96aa                	add	a3,a3,a0
ffffffffc0201ae6:	0ad78463          	beq	a5,a3,ffffffffc0201b8e <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201aea:	4310                	lw	a2,0(a4)
ffffffffc0201aec:	e51c                	sd	a5,8(a0)
ffffffffc0201aee:	00461693          	slli	a3,a2,0x4
ffffffffc0201af2:	96ba                	add	a3,a3,a4
ffffffffc0201af4:	08d50163          	beq	a0,a3,ffffffffc0201b76 <slob_free+0xbe>
ffffffffc0201af8:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc0201afa:	00096797          	auipc	a5,0x96
ffffffffc0201afe:	bce7b723          	sd	a4,-1074(a5) # ffffffffc02976c8 <slobfree>
    if (flag)
ffffffffc0201b02:	e9a5                	bnez	a1,ffffffffc0201b72 <slob_free+0xba>
ffffffffc0201b04:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b06:	fcf574e3          	bgeu	a0,a5,ffffffffc0201ace <slob_free+0x16>
ffffffffc0201b0a:	fcf762e3          	bltu	a4,a5,ffffffffc0201ace <slob_free+0x16>
ffffffffc0201b0e:	bfc1                	j	ffffffffc0201ade <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc0201b10:	25bd                	addiw	a1,a1,15
ffffffffc0201b12:	8191                	srli	a1,a1,0x4
ffffffffc0201b14:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b16:	100027f3          	csrr	a5,sstatus
ffffffffc0201b1a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b1c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b1e:	d7c5                	beqz	a5,ffffffffc0201ac6 <slob_free+0xe>
{
ffffffffc0201b20:	1101                	addi	sp,sp,-32
ffffffffc0201b22:	e42a                	sd	a0,8(sp)
ffffffffc0201b24:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201b26:	ddffe0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0201b2a:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b2c:	00096797          	auipc	a5,0x96
ffffffffc0201b30:	b9c7b783          	ld	a5,-1124(a5) # ffffffffc02976c8 <slobfree>
ffffffffc0201b34:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b36:	873e                	mv	a4,a5
ffffffffc0201b38:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b3a:	06a77663          	bgeu	a4,a0,ffffffffc0201ba6 <slob_free+0xee>
ffffffffc0201b3e:	00f56463          	bltu	a0,a5,ffffffffc0201b46 <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b42:	fef76ae3          	bltu	a4,a5,ffffffffc0201b36 <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc0201b46:	4110                	lw	a2,0(a0)
ffffffffc0201b48:	00461693          	slli	a3,a2,0x4
ffffffffc0201b4c:	96aa                	add	a3,a3,a0
ffffffffc0201b4e:	06d78363          	beq	a5,a3,ffffffffc0201bb4 <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc0201b52:	4310                	lw	a2,0(a4)
ffffffffc0201b54:	e51c                	sd	a5,8(a0)
ffffffffc0201b56:	00461693          	slli	a3,a2,0x4
ffffffffc0201b5a:	96ba                	add	a3,a3,a4
ffffffffc0201b5c:	06d50163          	beq	a0,a3,ffffffffc0201bbe <slob_free+0x106>
ffffffffc0201b60:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc0201b62:	00096797          	auipc	a5,0x96
ffffffffc0201b66:	b6e7b323          	sd	a4,-1178(a5) # ffffffffc02976c8 <slobfree>
    if (flag)
ffffffffc0201b6a:	e1a9                	bnez	a1,ffffffffc0201bac <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201b6c:	60e2                	ld	ra,24(sp)
ffffffffc0201b6e:	6105                	addi	sp,sp,32
ffffffffc0201b70:	8082                	ret
        intr_enable();
ffffffffc0201b72:	d8dfe06f          	j	ffffffffc02008fe <intr_enable>
		cur->units += b->units;
ffffffffc0201b76:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201b78:	853e                	mv	a0,a5
ffffffffc0201b7a:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc0201b7c:	00c687bb          	addw	a5,a3,a2
ffffffffc0201b80:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc0201b82:	00096797          	auipc	a5,0x96
ffffffffc0201b86:	b4e7b323          	sd	a4,-1210(a5) # ffffffffc02976c8 <slobfree>
    if (flag)
ffffffffc0201b8a:	ddad                	beqz	a1,ffffffffc0201b04 <slob_free+0x4c>
ffffffffc0201b8c:	b7dd                	j	ffffffffc0201b72 <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc0201b8e:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201b90:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201b92:	9eb1                	addw	a3,a3,a2
ffffffffc0201b94:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc0201b96:	4310                	lw	a2,0(a4)
ffffffffc0201b98:	e51c                	sd	a5,8(a0)
ffffffffc0201b9a:	00461693          	slli	a3,a2,0x4
ffffffffc0201b9e:	96ba                	add	a3,a3,a4
ffffffffc0201ba0:	f4d51ce3          	bne	a0,a3,ffffffffc0201af8 <slob_free+0x40>
ffffffffc0201ba4:	bfc9                	j	ffffffffc0201b76 <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ba6:	f8f56ee3          	bltu	a0,a5,ffffffffc0201b42 <slob_free+0x8a>
ffffffffc0201baa:	b771                	j	ffffffffc0201b36 <slob_free+0x7e>
}
ffffffffc0201bac:	60e2                	ld	ra,24(sp)
ffffffffc0201bae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201bb0:	d4ffe06f          	j	ffffffffc02008fe <intr_enable>
		b->units += cur->next->units;
ffffffffc0201bb4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201bb6:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201bb8:	9eb1                	addw	a3,a3,a2
ffffffffc0201bba:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0201bbc:	bf59                	j	ffffffffc0201b52 <slob_free+0x9a>
		cur->units += b->units;
ffffffffc0201bbe:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201bc0:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc0201bc2:	00c687bb          	addw	a5,a3,a2
ffffffffc0201bc6:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201bc8:	bf61                	j	ffffffffc0201b60 <slob_free+0xa8>

ffffffffc0201bca <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bca:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201bcc:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bce:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201bd2:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201bd4:	32a000ef          	jal	ffffffffc0201efe <alloc_pages>
	if (!page)
ffffffffc0201bd8:	c91d                	beqz	a0,ffffffffc0201c0e <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201bda:	0009a697          	auipc	a3,0x9a
ffffffffc0201bde:	f7e6b683          	ld	a3,-130(a3) # ffffffffc029bb58 <pages>
ffffffffc0201be2:	00006797          	auipc	a5,0x6
ffffffffc0201be6:	eee7b783          	ld	a5,-274(a5) # ffffffffc0207ad0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201bea:	0009a717          	auipc	a4,0x9a
ffffffffc0201bee:	f6673703          	ld	a4,-154(a4) # ffffffffc029bb50 <npage>
    return page - pages + nbase;
ffffffffc0201bf2:	8d15                	sub	a0,a0,a3
ffffffffc0201bf4:	8519                	srai	a0,a0,0x6
ffffffffc0201bf6:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201bf8:	00c51793          	slli	a5,a0,0xc
ffffffffc0201bfc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bfe:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201c00:	00e7fa63          	bgeu	a5,a4,ffffffffc0201c14 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201c04:	0009a797          	auipc	a5,0x9a
ffffffffc0201c08:	f447b783          	ld	a5,-188(a5) # ffffffffc029bb48 <va_pa_offset>
ffffffffc0201c0c:	953e                	add	a0,a0,a5
}
ffffffffc0201c0e:	60a2                	ld	ra,8(sp)
ffffffffc0201c10:	0141                	addi	sp,sp,16
ffffffffc0201c12:	8082                	ret
ffffffffc0201c14:	86aa                	mv	a3,a0
ffffffffc0201c16:	00005617          	auipc	a2,0x5
ffffffffc0201c1a:	b1260613          	addi	a2,a2,-1262 # ffffffffc0206728 <etext+0xdfa>
ffffffffc0201c1e:	07100593          	li	a1,113
ffffffffc0201c22:	00005517          	auipc	a0,0x5
ffffffffc0201c26:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0206750 <etext+0xe22>
ffffffffc0201c2a:	81dfe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201c2e <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201c2e:	7179                	addi	sp,sp,-48
ffffffffc0201c30:	f406                	sd	ra,40(sp)
ffffffffc0201c32:	f022                	sd	s0,32(sp)
ffffffffc0201c34:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201c36:	01050713          	addi	a4,a0,16
ffffffffc0201c3a:	6785                	lui	a5,0x1
ffffffffc0201c3c:	0af77e63          	bgeu	a4,a5,ffffffffc0201cf8 <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201c40:	00f50413          	addi	s0,a0,15
ffffffffc0201c44:	8011                	srli	s0,s0,0x4
ffffffffc0201c46:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c48:	100025f3          	csrr	a1,sstatus
ffffffffc0201c4c:	8989                	andi	a1,a1,2
ffffffffc0201c4e:	edd1                	bnez	a1,ffffffffc0201cea <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201c50:	00096497          	auipc	s1,0x96
ffffffffc0201c54:	a7848493          	addi	s1,s1,-1416 # ffffffffc02976c8 <slobfree>
ffffffffc0201c58:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c5a:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201c5c:	4314                	lw	a3,0(a4)
ffffffffc0201c5e:	0886da63          	bge	a3,s0,ffffffffc0201cf2 <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc0201c62:	00e60a63          	beq	a2,a4,ffffffffc0201c76 <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c66:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201c68:	4394                	lw	a3,0(a5)
ffffffffc0201c6a:	0286d863          	bge	a3,s0,ffffffffc0201c9a <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201c6e:	6090                	ld	a2,0(s1)
ffffffffc0201c70:	873e                	mv	a4,a5
ffffffffc0201c72:	fee61ae3          	bne	a2,a4,ffffffffc0201c66 <slob_alloc.constprop.0+0x38>
    if (flag)
ffffffffc0201c76:	e9b1                	bnez	a1,ffffffffc0201cca <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201c78:	4501                	li	a0,0
ffffffffc0201c7a:	f51ff0ef          	jal	ffffffffc0201bca <__slob_get_free_pages.constprop.0>
ffffffffc0201c7e:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201c80:	c915                	beqz	a0,ffffffffc0201cb4 <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201c82:	6585                	lui	a1,0x1
ffffffffc0201c84:	e35ff0ef          	jal	ffffffffc0201ab8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c88:	100025f3          	csrr	a1,sstatus
ffffffffc0201c8c:	8989                	andi	a1,a1,2
ffffffffc0201c8e:	e98d                	bnez	a1,ffffffffc0201cc0 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201c90:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c92:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201c94:	4394                	lw	a3,0(a5)
ffffffffc0201c96:	fc86cce3          	blt	a3,s0,ffffffffc0201c6e <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201c9a:	04d40563          	beq	s0,a3,ffffffffc0201ce4 <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201c9e:	00441613          	slli	a2,s0,0x4
ffffffffc0201ca2:	963e                	add	a2,a2,a5
ffffffffc0201ca4:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201ca6:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201ca8:	9e81                	subw	a3,a3,s0
ffffffffc0201caa:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201cac:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201cae:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201cb0:	e098                	sd	a4,0(s1)
    if (flag)
ffffffffc0201cb2:	ed99                	bnez	a1,ffffffffc0201cd0 <slob_alloc.constprop.0+0xa2>
}
ffffffffc0201cb4:	70a2                	ld	ra,40(sp)
ffffffffc0201cb6:	7402                	ld	s0,32(sp)
ffffffffc0201cb8:	64e2                	ld	s1,24(sp)
ffffffffc0201cba:	853e                	mv	a0,a5
ffffffffc0201cbc:	6145                	addi	sp,sp,48
ffffffffc0201cbe:	8082                	ret
        intr_disable();
ffffffffc0201cc0:	c45fe0ef          	jal	ffffffffc0200904 <intr_disable>
			cur = slobfree;
ffffffffc0201cc4:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0201cc6:	4585                	li	a1,1
ffffffffc0201cc8:	b7e9                	j	ffffffffc0201c92 <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc0201cca:	c35fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201cce:	b76d                	j	ffffffffc0201c78 <slob_alloc.constprop.0+0x4a>
ffffffffc0201cd0:	e43e                	sd	a5,8(sp)
ffffffffc0201cd2:	c2dfe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201cd6:	67a2                	ld	a5,8(sp)
}
ffffffffc0201cd8:	70a2                	ld	ra,40(sp)
ffffffffc0201cda:	7402                	ld	s0,32(sp)
ffffffffc0201cdc:	64e2                	ld	s1,24(sp)
ffffffffc0201cde:	853e                	mv	a0,a5
ffffffffc0201ce0:	6145                	addi	sp,sp,48
ffffffffc0201ce2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201ce4:	6794                	ld	a3,8(a5)
ffffffffc0201ce6:	e714                	sd	a3,8(a4)
ffffffffc0201ce8:	b7e1                	j	ffffffffc0201cb0 <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc0201cea:	c1bfe0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0201cee:	4585                	li	a1,1
ffffffffc0201cf0:	b785                	j	ffffffffc0201c50 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201cf2:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201cf4:	8732                	mv	a4,a2
ffffffffc0201cf6:	b755                	j	ffffffffc0201c9a <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201cf8:	00005697          	auipc	a3,0x5
ffffffffc0201cfc:	a6868693          	addi	a3,a3,-1432 # ffffffffc0206760 <etext+0xe32>
ffffffffc0201d00:	00004617          	auipc	a2,0x4
ffffffffc0201d04:	67860613          	addi	a2,a2,1656 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0201d08:	06300593          	li	a1,99
ffffffffc0201d0c:	00005517          	auipc	a0,0x5
ffffffffc0201d10:	a7450513          	addi	a0,a0,-1420 # ffffffffc0206780 <etext+0xe52>
ffffffffc0201d14:	f32fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201d18 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201d18:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201d1a:	00005517          	auipc	a0,0x5
ffffffffc0201d1e:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0206798 <etext+0xe6a>
{
ffffffffc0201d22:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201d24:	c70fe0ef          	jal	ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201d28:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d2a:	00005517          	auipc	a0,0x5
ffffffffc0201d2e:	a8650513          	addi	a0,a0,-1402 # ffffffffc02067b0 <etext+0xe82>
}
ffffffffc0201d32:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d34:	c60fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201d38 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201d38:	4501                	li	a0,0
ffffffffc0201d3a:	8082                	ret

ffffffffc0201d3c <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201d3c:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d3e:	6685                	lui	a3,0x1
{
ffffffffc0201d40:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d42:	16bd                	addi	a3,a3,-17 # fef <_binary_obj___user_softint_out_size-0x7c21>
ffffffffc0201d44:	04a6f963          	bgeu	a3,a0,ffffffffc0201d96 <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201d48:	e42a                	sd	a0,8(sp)
ffffffffc0201d4a:	4561                	li	a0,24
ffffffffc0201d4c:	e822                	sd	s0,16(sp)
ffffffffc0201d4e:	ee1ff0ef          	jal	ffffffffc0201c2e <slob_alloc.constprop.0>
ffffffffc0201d52:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201d54:	c541                	beqz	a0,ffffffffc0201ddc <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201d56:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201d58:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201d5a:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201d5c:	00f75763          	bge	a4,a5,ffffffffc0201d6a <kmalloc+0x2e>
ffffffffc0201d60:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201d64:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201d66:	fef74de3          	blt	a4,a5,ffffffffc0201d60 <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201d6a:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201d6c:	e5fff0ef          	jal	ffffffffc0201bca <__slob_get_free_pages.constprop.0>
ffffffffc0201d70:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201d72:	cd31                	beqz	a0,ffffffffc0201dce <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201d74:	100027f3          	csrr	a5,sstatus
ffffffffc0201d78:	8b89                	andi	a5,a5,2
ffffffffc0201d7a:	eb85                	bnez	a5,ffffffffc0201daa <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201d7c:	0009a797          	auipc	a5,0x9a
ffffffffc0201d80:	dac7b783          	ld	a5,-596(a5) # ffffffffc029bb28 <bigblocks>
		bigblocks = bb;
ffffffffc0201d84:	0009a717          	auipc	a4,0x9a
ffffffffc0201d88:	da873223          	sd	s0,-604(a4) # ffffffffc029bb28 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201d8c:	e81c                	sd	a5,16(s0)
    if (flag)
ffffffffc0201d8e:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201d90:	60e2                	ld	ra,24(sp)
ffffffffc0201d92:	6105                	addi	sp,sp,32
ffffffffc0201d94:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201d96:	0541                	addi	a0,a0,16
ffffffffc0201d98:	e97ff0ef          	jal	ffffffffc0201c2e <slob_alloc.constprop.0>
ffffffffc0201d9c:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201d9e:	0541                	addi	a0,a0,16
ffffffffc0201da0:	fbe5                	bnez	a5,ffffffffc0201d90 <kmalloc+0x54>
		return 0;
ffffffffc0201da2:	4501                	li	a0,0
}
ffffffffc0201da4:	60e2                	ld	ra,24(sp)
ffffffffc0201da6:	6105                	addi	sp,sp,32
ffffffffc0201da8:	8082                	ret
        intr_disable();
ffffffffc0201daa:	b5bfe0ef          	jal	ffffffffc0200904 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201dae:	0009a797          	auipc	a5,0x9a
ffffffffc0201db2:	d7a7b783          	ld	a5,-646(a5) # ffffffffc029bb28 <bigblocks>
		bigblocks = bb;
ffffffffc0201db6:	0009a717          	auipc	a4,0x9a
ffffffffc0201dba:	d6873923          	sd	s0,-654(a4) # ffffffffc029bb28 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201dbe:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc0201dc0:	b3ffe0ef          	jal	ffffffffc02008fe <intr_enable>
		return bb->pages;
ffffffffc0201dc4:	6408                	ld	a0,8(s0)
}
ffffffffc0201dc6:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201dc8:	6442                	ld	s0,16(sp)
}
ffffffffc0201dca:	6105                	addi	sp,sp,32
ffffffffc0201dcc:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dce:	8522                	mv	a0,s0
ffffffffc0201dd0:	45e1                	li	a1,24
ffffffffc0201dd2:	ce7ff0ef          	jal	ffffffffc0201ab8 <slob_free>
		return 0;
ffffffffc0201dd6:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dd8:	6442                	ld	s0,16(sp)
ffffffffc0201dda:	b7e9                	j	ffffffffc0201da4 <kmalloc+0x68>
ffffffffc0201ddc:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201dde:	4501                	li	a0,0
ffffffffc0201de0:	b7d1                	j	ffffffffc0201da4 <kmalloc+0x68>

ffffffffc0201de2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201de2:	c571                	beqz	a0,ffffffffc0201eae <kfree+0xcc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201de4:	03451793          	slli	a5,a0,0x34
ffffffffc0201de8:	e3e1                	bnez	a5,ffffffffc0201ea8 <kfree+0xc6>
{
ffffffffc0201dea:	1101                	addi	sp,sp,-32
ffffffffc0201dec:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201dee:	100027f3          	csrr	a5,sstatus
ffffffffc0201df2:	8b89                	andi	a5,a5,2
ffffffffc0201df4:	e7c1                	bnez	a5,ffffffffc0201e7c <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201df6:	0009a797          	auipc	a5,0x9a
ffffffffc0201dfa:	d327b783          	ld	a5,-718(a5) # ffffffffc029bb28 <bigblocks>
    return 0;
ffffffffc0201dfe:	4581                	li	a1,0
ffffffffc0201e00:	cbad                	beqz	a5,ffffffffc0201e72 <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201e02:	0009a617          	auipc	a2,0x9a
ffffffffc0201e06:	d2660613          	addi	a2,a2,-730 # ffffffffc029bb28 <bigblocks>
ffffffffc0201e0a:	a021                	j	ffffffffc0201e12 <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e0c:	01070613          	addi	a2,a4,16
ffffffffc0201e10:	c3a5                	beqz	a5,ffffffffc0201e70 <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201e12:	6794                	ld	a3,8(a5)
ffffffffc0201e14:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201e16:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201e18:	fea69ae3          	bne	a3,a0,ffffffffc0201e0c <kfree+0x2a>
				*last = bb->next;
ffffffffc0201e1c:	e21c                	sd	a5,0(a2)
    if (flag)
ffffffffc0201e1e:	edb5                	bnez	a1,ffffffffc0201e9a <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201e20:	c02007b7          	lui	a5,0xc0200
ffffffffc0201e24:	0af56263          	bltu	a0,a5,ffffffffc0201ec8 <kfree+0xe6>
ffffffffc0201e28:	0009a797          	auipc	a5,0x9a
ffffffffc0201e2c:	d207b783          	ld	a5,-736(a5) # ffffffffc029bb48 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201e30:	0009a697          	auipc	a3,0x9a
ffffffffc0201e34:	d206b683          	ld	a3,-736(a3) # ffffffffc029bb50 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201e38:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201e3a:	00c55793          	srli	a5,a0,0xc
ffffffffc0201e3e:	06d7f963          	bgeu	a5,a3,ffffffffc0201eb0 <kfree+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e42:	00006617          	auipc	a2,0x6
ffffffffc0201e46:	c8e63603          	ld	a2,-882(a2) # ffffffffc0207ad0 <nbase>
ffffffffc0201e4a:	0009a517          	auipc	a0,0x9a
ffffffffc0201e4e:	d0e53503          	ld	a0,-754(a0) # ffffffffc029bb58 <pages>
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201e52:	4314                	lw	a3,0(a4)
ffffffffc0201e54:	8f91                	sub	a5,a5,a2
ffffffffc0201e56:	079a                	slli	a5,a5,0x6
ffffffffc0201e58:	4585                	li	a1,1
ffffffffc0201e5a:	953e                	add	a0,a0,a5
ffffffffc0201e5c:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201e60:	e03a                	sd	a4,0(sp)
ffffffffc0201e62:	0d6000ef          	jal	ffffffffc0201f38 <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e66:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201e68:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e6a:	45e1                	li	a1,24
}
ffffffffc0201e6c:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e6e:	b1a9                	j	ffffffffc0201ab8 <slob_free>
ffffffffc0201e70:	e185                	bnez	a1,ffffffffc0201e90 <kfree+0xae>
}
ffffffffc0201e72:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e74:	1541                	addi	a0,a0,-16
ffffffffc0201e76:	4581                	li	a1,0
}
ffffffffc0201e78:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e7a:	b93d                	j	ffffffffc0201ab8 <slob_free>
        intr_disable();
ffffffffc0201e7c:	e02a                	sd	a0,0(sp)
ffffffffc0201e7e:	a87fe0ef          	jal	ffffffffc0200904 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e82:	0009a797          	auipc	a5,0x9a
ffffffffc0201e86:	ca67b783          	ld	a5,-858(a5) # ffffffffc029bb28 <bigblocks>
ffffffffc0201e8a:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc0201e8c:	4585                	li	a1,1
ffffffffc0201e8e:	fbb5                	bnez	a5,ffffffffc0201e02 <kfree+0x20>
ffffffffc0201e90:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc0201e92:	a6dfe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201e96:	6502                	ld	a0,0(sp)
ffffffffc0201e98:	bfe9                	j	ffffffffc0201e72 <kfree+0x90>
ffffffffc0201e9a:	e42a                	sd	a0,8(sp)
ffffffffc0201e9c:	e03a                	sd	a4,0(sp)
ffffffffc0201e9e:	a61fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201ea2:	6522                	ld	a0,8(sp)
ffffffffc0201ea4:	6702                	ld	a4,0(sp)
ffffffffc0201ea6:	bfad                	j	ffffffffc0201e20 <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ea8:	1541                	addi	a0,a0,-16
ffffffffc0201eaa:	4581                	li	a1,0
ffffffffc0201eac:	b131                	j	ffffffffc0201ab8 <slob_free>
ffffffffc0201eae:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201eb0:	00005617          	auipc	a2,0x5
ffffffffc0201eb4:	94860613          	addi	a2,a2,-1720 # ffffffffc02067f8 <etext+0xeca>
ffffffffc0201eb8:	06900593          	li	a1,105
ffffffffc0201ebc:	00005517          	auipc	a0,0x5
ffffffffc0201ec0:	89450513          	addi	a0,a0,-1900 # ffffffffc0206750 <etext+0xe22>
ffffffffc0201ec4:	d82fe0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201ec8:	86aa                	mv	a3,a0
ffffffffc0201eca:	00005617          	auipc	a2,0x5
ffffffffc0201ece:	90660613          	addi	a2,a2,-1786 # ffffffffc02067d0 <etext+0xea2>
ffffffffc0201ed2:	07700593          	li	a1,119
ffffffffc0201ed6:	00005517          	auipc	a0,0x5
ffffffffc0201eda:	87a50513          	addi	a0,a0,-1926 # ffffffffc0206750 <etext+0xe22>
ffffffffc0201ede:	d68fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201ee2 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201ee2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201ee4:	00005617          	auipc	a2,0x5
ffffffffc0201ee8:	91460613          	addi	a2,a2,-1772 # ffffffffc02067f8 <etext+0xeca>
ffffffffc0201eec:	06900593          	li	a1,105
ffffffffc0201ef0:	00005517          	auipc	a0,0x5
ffffffffc0201ef4:	86050513          	addi	a0,a0,-1952 # ffffffffc0206750 <etext+0xe22>
pa2page(uintptr_t pa)
ffffffffc0201ef8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201efa:	d4cfe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201efe <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201efe:	100027f3          	csrr	a5,sstatus
ffffffffc0201f02:	8b89                	andi	a5,a5,2
ffffffffc0201f04:	e799                	bnez	a5,ffffffffc0201f12 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f06:	0009a797          	auipc	a5,0x9a
ffffffffc0201f0a:	c2a7b783          	ld	a5,-982(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0201f0e:	6f9c                	ld	a5,24(a5)
ffffffffc0201f10:	8782                	jr	a5
{
ffffffffc0201f12:	1101                	addi	sp,sp,-32
ffffffffc0201f14:	ec06                	sd	ra,24(sp)
ffffffffc0201f16:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201f18:	9edfe0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f1c:	0009a797          	auipc	a5,0x9a
ffffffffc0201f20:	c147b783          	ld	a5,-1004(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0201f24:	6522                	ld	a0,8(sp)
ffffffffc0201f26:	6f9c                	ld	a5,24(a5)
ffffffffc0201f28:	9782                	jalr	a5
ffffffffc0201f2a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201f2c:	9d3fe0ef          	jal	ffffffffc02008fe <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201f30:	60e2                	ld	ra,24(sp)
ffffffffc0201f32:	6522                	ld	a0,8(sp)
ffffffffc0201f34:	6105                	addi	sp,sp,32
ffffffffc0201f36:	8082                	ret

ffffffffc0201f38 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f38:	100027f3          	csrr	a5,sstatus
ffffffffc0201f3c:	8b89                	andi	a5,a5,2
ffffffffc0201f3e:	e799                	bnez	a5,ffffffffc0201f4c <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201f40:	0009a797          	auipc	a5,0x9a
ffffffffc0201f44:	bf07b783          	ld	a5,-1040(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0201f48:	739c                	ld	a5,32(a5)
ffffffffc0201f4a:	8782                	jr	a5
{
ffffffffc0201f4c:	1101                	addi	sp,sp,-32
ffffffffc0201f4e:	ec06                	sd	ra,24(sp)
ffffffffc0201f50:	e42e                	sd	a1,8(sp)
ffffffffc0201f52:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201f54:	9b1fe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f58:	0009a797          	auipc	a5,0x9a
ffffffffc0201f5c:	bd87b783          	ld	a5,-1064(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0201f60:	65a2                	ld	a1,8(sp)
ffffffffc0201f62:	6502                	ld	a0,0(sp)
ffffffffc0201f64:	739c                	ld	a5,32(a5)
ffffffffc0201f66:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f68:	60e2                	ld	ra,24(sp)
ffffffffc0201f6a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f6c:	993fe06f          	j	ffffffffc02008fe <intr_enable>

ffffffffc0201f70 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f70:	100027f3          	csrr	a5,sstatus
ffffffffc0201f74:	8b89                	andi	a5,a5,2
ffffffffc0201f76:	e799                	bnez	a5,ffffffffc0201f84 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f78:	0009a797          	auipc	a5,0x9a
ffffffffc0201f7c:	bb87b783          	ld	a5,-1096(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0201f80:	779c                	ld	a5,40(a5)
ffffffffc0201f82:	8782                	jr	a5
{
ffffffffc0201f84:	1101                	addi	sp,sp,-32
ffffffffc0201f86:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201f88:	97dfe0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f8c:	0009a797          	auipc	a5,0x9a
ffffffffc0201f90:	ba47b783          	ld	a5,-1116(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0201f94:	779c                	ld	a5,40(a5)
ffffffffc0201f96:	9782                	jalr	a5
ffffffffc0201f98:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201f9a:	965fe0ef          	jal	ffffffffc02008fe <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f9e:	60e2                	ld	ra,24(sp)
ffffffffc0201fa0:	6522                	ld	a0,8(sp)
ffffffffc0201fa2:	6105                	addi	sp,sp,32
ffffffffc0201fa4:	8082                	ret

ffffffffc0201fa6 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201fa6:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201faa:	1ff7f793          	andi	a5,a5,511
ffffffffc0201fae:	078e                	slli	a5,a5,0x3
ffffffffc0201fb0:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201fb4:	6314                	ld	a3,0(a4)
{
ffffffffc0201fb6:	7139                	addi	sp,sp,-64
ffffffffc0201fb8:	f822                	sd	s0,48(sp)
ffffffffc0201fba:	f426                	sd	s1,40(sp)
ffffffffc0201fbc:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201fbe:	0016f793          	andi	a5,a3,1
{
ffffffffc0201fc2:	842e                	mv	s0,a1
ffffffffc0201fc4:	8832                	mv	a6,a2
ffffffffc0201fc6:	0009a497          	auipc	s1,0x9a
ffffffffc0201fca:	b8a48493          	addi	s1,s1,-1142 # ffffffffc029bb50 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201fce:	ebd1                	bnez	a5,ffffffffc0202062 <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fd0:	16060d63          	beqz	a2,ffffffffc020214a <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fd4:	100027f3          	csrr	a5,sstatus
ffffffffc0201fd8:	8b89                	andi	a5,a5,2
ffffffffc0201fda:	16079e63          	bnez	a5,ffffffffc0202156 <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fde:	0009a797          	auipc	a5,0x9a
ffffffffc0201fe2:	b527b783          	ld	a5,-1198(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0201fe6:	4505                	li	a0,1
ffffffffc0201fe8:	e43a                	sd	a4,8(sp)
ffffffffc0201fea:	6f9c                	ld	a5,24(a5)
ffffffffc0201fec:	e832                	sd	a2,16(sp)
ffffffffc0201fee:	9782                	jalr	a5
ffffffffc0201ff0:	6722                	ld	a4,8(sp)
ffffffffc0201ff2:	6842                	ld	a6,16(sp)
ffffffffc0201ff4:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201ff6:	14078a63          	beqz	a5,ffffffffc020214a <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201ffa:	0009a517          	auipc	a0,0x9a
ffffffffc0201ffe:	b5e53503          	ld	a0,-1186(a0) # ffffffffc029bb58 <pages>
ffffffffc0202002:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202006:	0009a497          	auipc	s1,0x9a
ffffffffc020200a:	b4a48493          	addi	s1,s1,-1206 # ffffffffc029bb50 <npage>
ffffffffc020200e:	40a78533          	sub	a0,a5,a0
ffffffffc0202012:	8519                	srai	a0,a0,0x6
ffffffffc0202014:	9546                	add	a0,a0,a7
ffffffffc0202016:	6090                	ld	a2,0(s1)
ffffffffc0202018:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc020201c:	4585                	li	a1,1
ffffffffc020201e:	82b1                	srli	a3,a3,0xc
ffffffffc0202020:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202022:	0532                	slli	a0,a0,0xc
ffffffffc0202024:	1ac6f763          	bgeu	a3,a2,ffffffffc02021d2 <get_pte+0x22c>
ffffffffc0202028:	0009a697          	auipc	a3,0x9a
ffffffffc020202c:	b206b683          	ld	a3,-1248(a3) # ffffffffc029bb48 <va_pa_offset>
ffffffffc0202030:	6605                	lui	a2,0x1
ffffffffc0202032:	4581                	li	a1,0
ffffffffc0202034:	9536                	add	a0,a0,a3
ffffffffc0202036:	ec42                	sd	a6,24(sp)
ffffffffc0202038:	e83e                	sd	a5,16(sp)
ffffffffc020203a:	e43a                	sd	a4,8(sp)
ffffffffc020203c:	0c9030ef          	jal	ffffffffc0205904 <memset>
    return page - pages + nbase;
ffffffffc0202040:	0009a697          	auipc	a3,0x9a
ffffffffc0202044:	b186b683          	ld	a3,-1256(a3) # ffffffffc029bb58 <pages>
ffffffffc0202048:	67c2                	ld	a5,16(sp)
ffffffffc020204a:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020204e:	6722                	ld	a4,8(sp)
ffffffffc0202050:	40d786b3          	sub	a3,a5,a3
ffffffffc0202054:	8699                	srai	a3,a3,0x6
ffffffffc0202056:	96c6                	add	a3,a3,a7
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202058:	06aa                	slli	a3,a3,0xa
ffffffffc020205a:	6862                	ld	a6,24(sp)
ffffffffc020205c:	0116e693          	ori	a3,a3,17
ffffffffc0202060:	e314                	sd	a3,0(a4)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202062:	c006f693          	andi	a3,a3,-1024
ffffffffc0202066:	6098                	ld	a4,0(s1)
ffffffffc0202068:	068a                	slli	a3,a3,0x2
ffffffffc020206a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020206e:	14e7f663          	bgeu	a5,a4,ffffffffc02021ba <get_pte+0x214>
ffffffffc0202072:	0009a897          	auipc	a7,0x9a
ffffffffc0202076:	ad688893          	addi	a7,a7,-1322 # ffffffffc029bb48 <va_pa_offset>
ffffffffc020207a:	0008b603          	ld	a2,0(a7)
ffffffffc020207e:	01545793          	srli	a5,s0,0x15
ffffffffc0202082:	1ff7f793          	andi	a5,a5,511
ffffffffc0202086:	96b2                	add	a3,a3,a2
ffffffffc0202088:	078e                	slli	a5,a5,0x3
ffffffffc020208a:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc020208c:	6394                	ld	a3,0(a5)
ffffffffc020208e:	0016f613          	andi	a2,a3,1
ffffffffc0202092:	e659                	bnez	a2,ffffffffc0202120 <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202094:	0a080b63          	beqz	a6,ffffffffc020214a <get_pte+0x1a4>
ffffffffc0202098:	10002773          	csrr	a4,sstatus
ffffffffc020209c:	8b09                	andi	a4,a4,2
ffffffffc020209e:	ef71                	bnez	a4,ffffffffc020217a <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc02020a0:	0009a717          	auipc	a4,0x9a
ffffffffc02020a4:	a9073703          	ld	a4,-1392(a4) # ffffffffc029bb30 <pmm_manager>
ffffffffc02020a8:	4505                	li	a0,1
ffffffffc02020aa:	e43e                	sd	a5,8(sp)
ffffffffc02020ac:	6f18                	ld	a4,24(a4)
ffffffffc02020ae:	9702                	jalr	a4
ffffffffc02020b0:	67a2                	ld	a5,8(sp)
ffffffffc02020b2:	872a                	mv	a4,a0
ffffffffc02020b4:	0009a897          	auipc	a7,0x9a
ffffffffc02020b8:	a9488893          	addi	a7,a7,-1388 # ffffffffc029bb48 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02020bc:	c759                	beqz	a4,ffffffffc020214a <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc02020be:	0009a697          	auipc	a3,0x9a
ffffffffc02020c2:	a9a6b683          	ld	a3,-1382(a3) # ffffffffc029bb58 <pages>
ffffffffc02020c6:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020ca:	608c                	ld	a1,0(s1)
ffffffffc02020cc:	40d706b3          	sub	a3,a4,a3
ffffffffc02020d0:	8699                	srai	a3,a3,0x6
ffffffffc02020d2:	96c2                	add	a3,a3,a6
ffffffffc02020d4:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc02020d8:	4505                	li	a0,1
ffffffffc02020da:	8231                	srli	a2,a2,0xc
ffffffffc02020dc:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc02020de:	06b2                	slli	a3,a3,0xc
ffffffffc02020e0:	10b67663          	bgeu	a2,a1,ffffffffc02021ec <get_pte+0x246>
ffffffffc02020e4:	0008b503          	ld	a0,0(a7)
ffffffffc02020e8:	6605                	lui	a2,0x1
ffffffffc02020ea:	4581                	li	a1,0
ffffffffc02020ec:	9536                	add	a0,a0,a3
ffffffffc02020ee:	e83a                	sd	a4,16(sp)
ffffffffc02020f0:	e43e                	sd	a5,8(sp)
ffffffffc02020f2:	013030ef          	jal	ffffffffc0205904 <memset>
    return page - pages + nbase;
ffffffffc02020f6:	0009a697          	auipc	a3,0x9a
ffffffffc02020fa:	a626b683          	ld	a3,-1438(a3) # ffffffffc029bb58 <pages>
ffffffffc02020fe:	6742                	ld	a4,16(sp)
ffffffffc0202100:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202104:	67a2                	ld	a5,8(sp)
ffffffffc0202106:	40d706b3          	sub	a3,a4,a3
ffffffffc020210a:	8699                	srai	a3,a3,0x6
ffffffffc020210c:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020210e:	06aa                	slli	a3,a3,0xa
ffffffffc0202110:	0116e693          	ori	a3,a3,17
ffffffffc0202114:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202116:	6098                	ld	a4,0(s1)
ffffffffc0202118:	0009a897          	auipc	a7,0x9a
ffffffffc020211c:	a3088893          	addi	a7,a7,-1488 # ffffffffc029bb48 <va_pa_offset>
ffffffffc0202120:	c006f693          	andi	a3,a3,-1024
ffffffffc0202124:	068a                	slli	a3,a3,0x2
ffffffffc0202126:	00c6d793          	srli	a5,a3,0xc
ffffffffc020212a:	06e7fc63          	bgeu	a5,a4,ffffffffc02021a2 <get_pte+0x1fc>
ffffffffc020212e:	0008b783          	ld	a5,0(a7)
ffffffffc0202132:	8031                	srli	s0,s0,0xc
ffffffffc0202134:	1ff47413          	andi	s0,s0,511
ffffffffc0202138:	040e                	slli	s0,s0,0x3
ffffffffc020213a:	96be                	add	a3,a3,a5
}
ffffffffc020213c:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020213e:	00868533          	add	a0,a3,s0
}
ffffffffc0202142:	7442                	ld	s0,48(sp)
ffffffffc0202144:	74a2                	ld	s1,40(sp)
ffffffffc0202146:	6121                	addi	sp,sp,64
ffffffffc0202148:	8082                	ret
ffffffffc020214a:	70e2                	ld	ra,56(sp)
ffffffffc020214c:	7442                	ld	s0,48(sp)
ffffffffc020214e:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc0202150:	4501                	li	a0,0
}
ffffffffc0202152:	6121                	addi	sp,sp,64
ffffffffc0202154:	8082                	ret
        intr_disable();
ffffffffc0202156:	e83a                	sd	a4,16(sp)
ffffffffc0202158:	ec32                	sd	a2,24(sp)
ffffffffc020215a:	faafe0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020215e:	0009a797          	auipc	a5,0x9a
ffffffffc0202162:	9d27b783          	ld	a5,-1582(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0202166:	4505                	li	a0,1
ffffffffc0202168:	6f9c                	ld	a5,24(a5)
ffffffffc020216a:	9782                	jalr	a5
ffffffffc020216c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020216e:	f90fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202172:	6862                	ld	a6,24(sp)
ffffffffc0202174:	6742                	ld	a4,16(sp)
ffffffffc0202176:	67a2                	ld	a5,8(sp)
ffffffffc0202178:	bdbd                	j	ffffffffc0201ff6 <get_pte+0x50>
        intr_disable();
ffffffffc020217a:	e83e                	sd	a5,16(sp)
ffffffffc020217c:	f88fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202180:	0009a717          	auipc	a4,0x9a
ffffffffc0202184:	9b073703          	ld	a4,-1616(a4) # ffffffffc029bb30 <pmm_manager>
ffffffffc0202188:	4505                	li	a0,1
ffffffffc020218a:	6f18                	ld	a4,24(a4)
ffffffffc020218c:	9702                	jalr	a4
ffffffffc020218e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202190:	f6efe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202194:	6722                	ld	a4,8(sp)
ffffffffc0202196:	67c2                	ld	a5,16(sp)
ffffffffc0202198:	0009a897          	auipc	a7,0x9a
ffffffffc020219c:	9b088893          	addi	a7,a7,-1616 # ffffffffc029bb48 <va_pa_offset>
ffffffffc02021a0:	bf31                	j	ffffffffc02020bc <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02021a2:	00004617          	auipc	a2,0x4
ffffffffc02021a6:	58660613          	addi	a2,a2,1414 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02021aa:	0fa00593          	li	a1,250
ffffffffc02021ae:	00004517          	auipc	a0,0x4
ffffffffc02021b2:	66a50513          	addi	a0,a0,1642 # ffffffffc0206818 <etext+0xeea>
ffffffffc02021b6:	a90fe0ef          	jal	ffffffffc0200446 <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02021ba:	00004617          	auipc	a2,0x4
ffffffffc02021be:	56e60613          	addi	a2,a2,1390 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02021c2:	0ed00593          	li	a1,237
ffffffffc02021c6:	00004517          	auipc	a0,0x4
ffffffffc02021ca:	65250513          	addi	a0,a0,1618 # ffffffffc0206818 <etext+0xeea>
ffffffffc02021ce:	a78fe0ef          	jal	ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02021d2:	86aa                	mv	a3,a0
ffffffffc02021d4:	00004617          	auipc	a2,0x4
ffffffffc02021d8:	55460613          	addi	a2,a2,1364 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02021dc:	0e900593          	li	a1,233
ffffffffc02021e0:	00004517          	auipc	a0,0x4
ffffffffc02021e4:	63850513          	addi	a0,a0,1592 # ffffffffc0206818 <etext+0xeea>
ffffffffc02021e8:	a5efe0ef          	jal	ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02021ec:	00004617          	auipc	a2,0x4
ffffffffc02021f0:	53c60613          	addi	a2,a2,1340 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02021f4:	0f700593          	li	a1,247
ffffffffc02021f8:	00004517          	auipc	a0,0x4
ffffffffc02021fc:	62050513          	addi	a0,a0,1568 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202200:	a46fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0202204 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202204:	1141                	addi	sp,sp,-16
ffffffffc0202206:	e022                	sd	s0,0(sp)
ffffffffc0202208:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020220a:	4601                	li	a2,0
{
ffffffffc020220c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020220e:	d99ff0ef          	jal	ffffffffc0201fa6 <get_pte>
    if (ptep_store != NULL)
ffffffffc0202212:	c011                	beqz	s0,ffffffffc0202216 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202214:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202216:	c511                	beqz	a0,ffffffffc0202222 <get_page+0x1e>
ffffffffc0202218:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020221a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020221c:	0017f713          	andi	a4,a5,1
ffffffffc0202220:	e709                	bnez	a4,ffffffffc020222a <get_page+0x26>
}
ffffffffc0202222:	60a2                	ld	ra,8(sp)
ffffffffc0202224:	6402                	ld	s0,0(sp)
ffffffffc0202226:	0141                	addi	sp,sp,16
ffffffffc0202228:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc020222a:	0009a717          	auipc	a4,0x9a
ffffffffc020222e:	92673703          	ld	a4,-1754(a4) # ffffffffc029bb50 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202232:	078a                	slli	a5,a5,0x2
ffffffffc0202234:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202236:	00e7ff63          	bgeu	a5,a4,ffffffffc0202254 <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc020223a:	0009a517          	auipc	a0,0x9a
ffffffffc020223e:	91e53503          	ld	a0,-1762(a0) # ffffffffc029bb58 <pages>
ffffffffc0202242:	60a2                	ld	ra,8(sp)
ffffffffc0202244:	6402                	ld	s0,0(sp)
ffffffffc0202246:	079a                	slli	a5,a5,0x6
ffffffffc0202248:	fe000737          	lui	a4,0xfe000
ffffffffc020224c:	97ba                	add	a5,a5,a4
ffffffffc020224e:	953e                	add	a0,a0,a5
ffffffffc0202250:	0141                	addi	sp,sp,16
ffffffffc0202252:	8082                	ret
ffffffffc0202254:	c8fff0ef          	jal	ffffffffc0201ee2 <pa2page.part.0>

ffffffffc0202258 <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202258:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020225a:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020225e:	e486                	sd	ra,72(sp)
ffffffffc0202260:	e0a2                	sd	s0,64(sp)
ffffffffc0202262:	fc26                	sd	s1,56(sp)
ffffffffc0202264:	f84a                	sd	s2,48(sp)
ffffffffc0202266:	f44e                	sd	s3,40(sp)
ffffffffc0202268:	f052                	sd	s4,32(sp)
ffffffffc020226a:	ec56                	sd	s5,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020226c:	03479713          	slli	a4,a5,0x34
ffffffffc0202270:	ef61                	bnez	a4,ffffffffc0202348 <unmap_range+0xf0>
    assert(USER_ACCESS(start, end));
ffffffffc0202272:	00200a37          	lui	s4,0x200
ffffffffc0202276:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc020227a:	0145b733          	sltu	a4,a1,s4
ffffffffc020227e:	0017b793          	seqz	a5,a5
ffffffffc0202282:	8fd9                	or	a5,a5,a4
ffffffffc0202284:	842e                	mv	s0,a1
ffffffffc0202286:	84b2                	mv	s1,a2
ffffffffc0202288:	e3e5                	bnez	a5,ffffffffc0202368 <unmap_range+0x110>
ffffffffc020228a:	4785                	li	a5,1
ffffffffc020228c:	07fe                	slli	a5,a5,0x1f
ffffffffc020228e:	0785                	addi	a5,a5,1
ffffffffc0202290:	892a                	mv	s2,a0
ffffffffc0202292:	6985                	lui	s3,0x1
    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202294:	ffe00ab7          	lui	s5,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc0202298:	0cf67863          	bgeu	a2,a5,ffffffffc0202368 <unmap_range+0x110>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020229c:	4601                	li	a2,0
ffffffffc020229e:	85a2                	mv	a1,s0
ffffffffc02022a0:	854a                	mv	a0,s2
ffffffffc02022a2:	d05ff0ef          	jal	ffffffffc0201fa6 <get_pte>
ffffffffc02022a6:	87aa                	mv	a5,a0
        if (ptep == NULL)
ffffffffc02022a8:	cd31                	beqz	a0,ffffffffc0202304 <unmap_range+0xac>
            continue;
        }
        if (*ptep != 0)
ffffffffc02022aa:	6118                	ld	a4,0(a0)
ffffffffc02022ac:	ef11                	bnez	a4,ffffffffc02022c8 <unmap_range+0x70>
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02022ae:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02022b0:	c019                	beqz	s0,ffffffffc02022b6 <unmap_range+0x5e>
ffffffffc02022b2:	fe9465e3          	bltu	s0,s1,ffffffffc020229c <unmap_range+0x44>
}
ffffffffc02022b6:	60a6                	ld	ra,72(sp)
ffffffffc02022b8:	6406                	ld	s0,64(sp)
ffffffffc02022ba:	74e2                	ld	s1,56(sp)
ffffffffc02022bc:	7942                	ld	s2,48(sp)
ffffffffc02022be:	79a2                	ld	s3,40(sp)
ffffffffc02022c0:	7a02                	ld	s4,32(sp)
ffffffffc02022c2:	6ae2                	ld	s5,24(sp)
ffffffffc02022c4:	6161                	addi	sp,sp,80
ffffffffc02022c6:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc02022c8:	00177693          	andi	a3,a4,1
ffffffffc02022cc:	d2ed                	beqz	a3,ffffffffc02022ae <unmap_range+0x56>
    if (PPN(pa) >= npage)
ffffffffc02022ce:	0009a697          	auipc	a3,0x9a
ffffffffc02022d2:	8826b683          	ld	a3,-1918(a3) # ffffffffc029bb50 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02022d6:	070a                	slli	a4,a4,0x2
ffffffffc02022d8:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02022da:	0ad77763          	bgeu	a4,a3,ffffffffc0202388 <unmap_range+0x130>
    return &pages[PPN(pa) - nbase];
ffffffffc02022de:	0009a517          	auipc	a0,0x9a
ffffffffc02022e2:	87a53503          	ld	a0,-1926(a0) # ffffffffc029bb58 <pages>
ffffffffc02022e6:	071a                	slli	a4,a4,0x6
ffffffffc02022e8:	fe0006b7          	lui	a3,0xfe000
ffffffffc02022ec:	9736                	add	a4,a4,a3
ffffffffc02022ee:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc02022f0:	4118                	lw	a4,0(a0)
ffffffffc02022f2:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd6447f>
ffffffffc02022f4:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02022f6:	cb19                	beqz	a4,ffffffffc020230c <unmap_range+0xb4>
        *ptep = 0;
ffffffffc02022f8:	0007b023          	sd	zero,0(a5)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02022fc:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202300:	944e                	add	s0,s0,s3
ffffffffc0202302:	b77d                	j	ffffffffc02022b0 <unmap_range+0x58>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202304:	9452                	add	s0,s0,s4
ffffffffc0202306:	01547433          	and	s0,s0,s5
            continue;
ffffffffc020230a:	b75d                	j	ffffffffc02022b0 <unmap_range+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020230c:	10002773          	csrr	a4,sstatus
ffffffffc0202310:	8b09                	andi	a4,a4,2
ffffffffc0202312:	eb19                	bnez	a4,ffffffffc0202328 <unmap_range+0xd0>
        pmm_manager->free_pages(base, n);
ffffffffc0202314:	0009a717          	auipc	a4,0x9a
ffffffffc0202318:	81c73703          	ld	a4,-2020(a4) # ffffffffc029bb30 <pmm_manager>
ffffffffc020231c:	4585                	li	a1,1
ffffffffc020231e:	e03e                	sd	a5,0(sp)
ffffffffc0202320:	7318                	ld	a4,32(a4)
ffffffffc0202322:	9702                	jalr	a4
    if (flag)
ffffffffc0202324:	6782                	ld	a5,0(sp)
ffffffffc0202326:	bfc9                	j	ffffffffc02022f8 <unmap_range+0xa0>
        intr_disable();
ffffffffc0202328:	e43e                	sd	a5,8(sp)
ffffffffc020232a:	e02a                	sd	a0,0(sp)
ffffffffc020232c:	dd8fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202330:	0009a717          	auipc	a4,0x9a
ffffffffc0202334:	80073703          	ld	a4,-2048(a4) # ffffffffc029bb30 <pmm_manager>
ffffffffc0202338:	6502                	ld	a0,0(sp)
ffffffffc020233a:	4585                	li	a1,1
ffffffffc020233c:	7318                	ld	a4,32(a4)
ffffffffc020233e:	9702                	jalr	a4
        intr_enable();
ffffffffc0202340:	dbefe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202344:	67a2                	ld	a5,8(sp)
ffffffffc0202346:	bf4d                	j	ffffffffc02022f8 <unmap_range+0xa0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202348:	00004697          	auipc	a3,0x4
ffffffffc020234c:	4e068693          	addi	a3,a3,1248 # ffffffffc0206828 <etext+0xefa>
ffffffffc0202350:	00004617          	auipc	a2,0x4
ffffffffc0202354:	02860613          	addi	a2,a2,40 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202358:	12000593          	li	a1,288
ffffffffc020235c:	00004517          	auipc	a0,0x4
ffffffffc0202360:	4bc50513          	addi	a0,a0,1212 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202364:	8e2fe0ef          	jal	ffffffffc0200446 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202368:	00004697          	auipc	a3,0x4
ffffffffc020236c:	4f068693          	addi	a3,a3,1264 # ffffffffc0206858 <etext+0xf2a>
ffffffffc0202370:	00004617          	auipc	a2,0x4
ffffffffc0202374:	00860613          	addi	a2,a2,8 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202378:	12100593          	li	a1,289
ffffffffc020237c:	00004517          	auipc	a0,0x4
ffffffffc0202380:	49c50513          	addi	a0,a0,1180 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202384:	8c2fe0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0202388:	b5bff0ef          	jal	ffffffffc0201ee2 <pa2page.part.0>

ffffffffc020238c <exit_range>:
{
ffffffffc020238c:	7135                	addi	sp,sp,-160
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020238e:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202392:	ed06                	sd	ra,152(sp)
ffffffffc0202394:	e922                	sd	s0,144(sp)
ffffffffc0202396:	e526                	sd	s1,136(sp)
ffffffffc0202398:	e14a                	sd	s2,128(sp)
ffffffffc020239a:	fcce                	sd	s3,120(sp)
ffffffffc020239c:	f8d2                	sd	s4,112(sp)
ffffffffc020239e:	f4d6                	sd	s5,104(sp)
ffffffffc02023a0:	f0da                	sd	s6,96(sp)
ffffffffc02023a2:	ecde                	sd	s7,88(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023a4:	17d2                	slli	a5,a5,0x34
ffffffffc02023a6:	22079263          	bnez	a5,ffffffffc02025ca <exit_range+0x23e>
    assert(USER_ACCESS(start, end));
ffffffffc02023aa:	00200937          	lui	s2,0x200
ffffffffc02023ae:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc02023b2:	0125b733          	sltu	a4,a1,s2
ffffffffc02023b6:	0017b793          	seqz	a5,a5
ffffffffc02023ba:	8fd9                	or	a5,a5,a4
ffffffffc02023bc:	26079263          	bnez	a5,ffffffffc0202620 <exit_range+0x294>
ffffffffc02023c0:	4785                	li	a5,1
ffffffffc02023c2:	07fe                	slli	a5,a5,0x1f
ffffffffc02023c4:	0785                	addi	a5,a5,1
ffffffffc02023c6:	24f67d63          	bgeu	a2,a5,ffffffffc0202620 <exit_range+0x294>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02023ca:	c00004b7          	lui	s1,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02023ce:	ffe007b7          	lui	a5,0xffe00
ffffffffc02023d2:	8a2a                	mv	s4,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02023d4:	8ced                	and	s1,s1,a1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02023d6:	00f5f833          	and	a6,a1,a5
    if (PPN(pa) >= npage)
ffffffffc02023da:	00099a97          	auipc	s5,0x99
ffffffffc02023de:	776a8a93          	addi	s5,s5,1910 # ffffffffc029bb50 <npage>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02023e2:	400009b7          	lui	s3,0x40000
ffffffffc02023e6:	a809                	j	ffffffffc02023f8 <exit_range+0x6c>
        d1start += PDSIZE;
ffffffffc02023e8:	013487b3          	add	a5,s1,s3
ffffffffc02023ec:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc02023f0:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc02023f2:	c3f1                	beqz	a5,ffffffffc02024b6 <exit_range+0x12a>
ffffffffc02023f4:	0cc7f163          	bgeu	a5,a2,ffffffffc02024b6 <exit_range+0x12a>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02023f8:	01e4d413          	srli	s0,s1,0x1e
ffffffffc02023fc:	1ff47413          	andi	s0,s0,511
ffffffffc0202400:	040e                	slli	s0,s0,0x3
ffffffffc0202402:	9452                	add	s0,s0,s4
ffffffffc0202404:	00043883          	ld	a7,0(s0)
        if (pde1 & PTE_V)
ffffffffc0202408:	0018f793          	andi	a5,a7,1
ffffffffc020240c:	dff1                	beqz	a5,ffffffffc02023e8 <exit_range+0x5c>
ffffffffc020240e:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202412:	088a                	slli	a7,a7,0x2
ffffffffc0202414:	00c8d893          	srli	a7,a7,0xc
    if (PPN(pa) >= npage)
ffffffffc0202418:	20f8f263          	bgeu	a7,a5,ffffffffc020261c <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc020241c:	fff802b7          	lui	t0,0xfff80
ffffffffc0202420:	00588f33          	add	t5,a7,t0
    return page - pages + nbase;
ffffffffc0202424:	000803b7          	lui	t2,0x80
ffffffffc0202428:	007f0733          	add	a4,t5,t2
    return page2ppn(page) << PGSHIFT;
ffffffffc020242c:	00c71e13          	slli	t3,a4,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202430:	0f1a                	slli	t5,t5,0x6
    return KADDR(page2pa(page));
ffffffffc0202432:	1cf77863          	bgeu	a4,a5,ffffffffc0202602 <exit_range+0x276>
ffffffffc0202436:	00099f97          	auipc	t6,0x99
ffffffffc020243a:	712f8f93          	addi	t6,t6,1810 # ffffffffc029bb48 <va_pa_offset>
ffffffffc020243e:	000fb783          	ld	a5,0(t6)
            free_pd0 = 1;
ffffffffc0202442:	4e85                	li	t4,1
ffffffffc0202444:	6b05                	lui	s6,0x1
ffffffffc0202446:	9e3e                	add	t3,t3,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202448:	01348333          	add	t1,s1,s3
                pde0 = pd0[PDX0(d0start)];
ffffffffc020244c:	01585713          	srli	a4,a6,0x15
ffffffffc0202450:	1ff77713          	andi	a4,a4,511
ffffffffc0202454:	070e                	slli	a4,a4,0x3
ffffffffc0202456:	9772                	add	a4,a4,t3
ffffffffc0202458:	631c                	ld	a5,0(a4)
                if (pde0 & PTE_V)
ffffffffc020245a:	0017f693          	andi	a3,a5,1
ffffffffc020245e:	e6bd                	bnez	a3,ffffffffc02024cc <exit_range+0x140>
                    free_pd0 = 0;
ffffffffc0202460:	4e81                	li	t4,0
                d0start += PTSIZE;
ffffffffc0202462:	984a                	add	a6,a6,s2
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202464:	00080863          	beqz	a6,ffffffffc0202474 <exit_range+0xe8>
ffffffffc0202468:	879a                	mv	a5,t1
ffffffffc020246a:	00667363          	bgeu	a2,t1,ffffffffc0202470 <exit_range+0xe4>
ffffffffc020246e:	87b2                	mv	a5,a2
ffffffffc0202470:	fcf86ee3          	bltu	a6,a5,ffffffffc020244c <exit_range+0xc0>
            if (free_pd0)
ffffffffc0202474:	f60e8ae3          	beqz	t4,ffffffffc02023e8 <exit_range+0x5c>
    if (PPN(pa) >= npage)
ffffffffc0202478:	000ab783          	ld	a5,0(s5)
ffffffffc020247c:	1af8f063          	bgeu	a7,a5,ffffffffc020261c <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202480:	00099517          	auipc	a0,0x99
ffffffffc0202484:	6d853503          	ld	a0,1752(a0) # ffffffffc029bb58 <pages>
ffffffffc0202488:	957a                	add	a0,a0,t5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020248a:	100027f3          	csrr	a5,sstatus
ffffffffc020248e:	8b89                	andi	a5,a5,2
ffffffffc0202490:	10079b63          	bnez	a5,ffffffffc02025a6 <exit_range+0x21a>
        pmm_manager->free_pages(base, n);
ffffffffc0202494:	00099797          	auipc	a5,0x99
ffffffffc0202498:	69c7b783          	ld	a5,1692(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc020249c:	4585                	li	a1,1
ffffffffc020249e:	e432                	sd	a2,8(sp)
ffffffffc02024a0:	739c                	ld	a5,32(a5)
ffffffffc02024a2:	9782                	jalr	a5
ffffffffc02024a4:	6622                	ld	a2,8(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc02024a6:	00043023          	sd	zero,0(s0)
        d1start += PDSIZE;
ffffffffc02024aa:	013487b3          	add	a5,s1,s3
ffffffffc02024ae:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc02024b2:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc02024b4:	f3a1                	bnez	a5,ffffffffc02023f4 <exit_range+0x68>
}
ffffffffc02024b6:	60ea                	ld	ra,152(sp)
ffffffffc02024b8:	644a                	ld	s0,144(sp)
ffffffffc02024ba:	64aa                	ld	s1,136(sp)
ffffffffc02024bc:	690a                	ld	s2,128(sp)
ffffffffc02024be:	79e6                	ld	s3,120(sp)
ffffffffc02024c0:	7a46                	ld	s4,112(sp)
ffffffffc02024c2:	7aa6                	ld	s5,104(sp)
ffffffffc02024c4:	7b06                	ld	s6,96(sp)
ffffffffc02024c6:	6be6                	ld	s7,88(sp)
ffffffffc02024c8:	610d                	addi	sp,sp,160
ffffffffc02024ca:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02024cc:	000ab503          	ld	a0,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024d0:	078a                	slli	a5,a5,0x2
ffffffffc02024d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02024d4:	14a7f463          	bgeu	a5,a0,ffffffffc020261c <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc02024d8:	9796                	add	a5,a5,t0
    return page - pages + nbase;
ffffffffc02024da:	00778bb3          	add	s7,a5,t2
    return &pages[PPN(pa) - nbase];
ffffffffc02024de:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024e2:	00cb9693          	slli	a3,s7,0xc
    return KADDR(page2pa(page));
ffffffffc02024e6:	10abf263          	bgeu	s7,a0,ffffffffc02025ea <exit_range+0x25e>
ffffffffc02024ea:	000fb783          	ld	a5,0(t6)
ffffffffc02024ee:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024f0:	01668533          	add	a0,a3,s6
                        if (pt[i] & PTE_V)
ffffffffc02024f4:	629c                	ld	a5,0(a3)
ffffffffc02024f6:	8b85                	andi	a5,a5,1
ffffffffc02024f8:	f7ad                	bnez	a5,ffffffffc0202462 <exit_range+0xd6>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024fa:	06a1                	addi	a3,a3,8
ffffffffc02024fc:	fea69ce3          	bne	a3,a0,ffffffffc02024f4 <exit_range+0x168>
    return &pages[PPN(pa) - nbase];
ffffffffc0202500:	00099517          	auipc	a0,0x99
ffffffffc0202504:	65853503          	ld	a0,1624(a0) # ffffffffc029bb58 <pages>
ffffffffc0202508:	952e                	add	a0,a0,a1
ffffffffc020250a:	100027f3          	csrr	a5,sstatus
ffffffffc020250e:	8b89                	andi	a5,a5,2
ffffffffc0202510:	e3b9                	bnez	a5,ffffffffc0202556 <exit_range+0x1ca>
        pmm_manager->free_pages(base, n);
ffffffffc0202512:	00099797          	auipc	a5,0x99
ffffffffc0202516:	61e7b783          	ld	a5,1566(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc020251a:	4585                	li	a1,1
ffffffffc020251c:	e0b2                	sd	a2,64(sp)
ffffffffc020251e:	739c                	ld	a5,32(a5)
ffffffffc0202520:	fc1a                	sd	t1,56(sp)
ffffffffc0202522:	f846                	sd	a7,48(sp)
ffffffffc0202524:	f47a                	sd	t5,40(sp)
ffffffffc0202526:	f072                	sd	t3,32(sp)
ffffffffc0202528:	ec76                	sd	t4,24(sp)
ffffffffc020252a:	e842                	sd	a6,16(sp)
ffffffffc020252c:	e43a                	sd	a4,8(sp)
ffffffffc020252e:	9782                	jalr	a5
    if (flag)
ffffffffc0202530:	6722                	ld	a4,8(sp)
ffffffffc0202532:	6842                	ld	a6,16(sp)
ffffffffc0202534:	6ee2                	ld	t4,24(sp)
ffffffffc0202536:	7e02                	ld	t3,32(sp)
ffffffffc0202538:	7f22                	ld	t5,40(sp)
ffffffffc020253a:	78c2                	ld	a7,48(sp)
ffffffffc020253c:	7362                	ld	t1,56(sp)
ffffffffc020253e:	6606                	ld	a2,64(sp)
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202540:	fff802b7          	lui	t0,0xfff80
ffffffffc0202544:	000803b7          	lui	t2,0x80
ffffffffc0202548:	00099f97          	auipc	t6,0x99
ffffffffc020254c:	600f8f93          	addi	t6,t6,1536 # ffffffffc029bb48 <va_pa_offset>
ffffffffc0202550:	00073023          	sd	zero,0(a4)
ffffffffc0202554:	b739                	j	ffffffffc0202462 <exit_range+0xd6>
        intr_disable();
ffffffffc0202556:	e4b2                	sd	a2,72(sp)
ffffffffc0202558:	e09a                	sd	t1,64(sp)
ffffffffc020255a:	fc46                	sd	a7,56(sp)
ffffffffc020255c:	f47a                	sd	t5,40(sp)
ffffffffc020255e:	f072                	sd	t3,32(sp)
ffffffffc0202560:	ec76                	sd	t4,24(sp)
ffffffffc0202562:	e842                	sd	a6,16(sp)
ffffffffc0202564:	e43a                	sd	a4,8(sp)
ffffffffc0202566:	f82a                	sd	a0,48(sp)
ffffffffc0202568:	b9cfe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020256c:	00099797          	auipc	a5,0x99
ffffffffc0202570:	5c47b783          	ld	a5,1476(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc0202574:	7542                	ld	a0,48(sp)
ffffffffc0202576:	4585                	li	a1,1
ffffffffc0202578:	739c                	ld	a5,32(a5)
ffffffffc020257a:	9782                	jalr	a5
        intr_enable();
ffffffffc020257c:	b82fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202580:	6722                	ld	a4,8(sp)
ffffffffc0202582:	6626                	ld	a2,72(sp)
ffffffffc0202584:	6306                	ld	t1,64(sp)
ffffffffc0202586:	78e2                	ld	a7,56(sp)
ffffffffc0202588:	7f22                	ld	t5,40(sp)
ffffffffc020258a:	7e02                	ld	t3,32(sp)
ffffffffc020258c:	6ee2                	ld	t4,24(sp)
ffffffffc020258e:	6842                	ld	a6,16(sp)
ffffffffc0202590:	00099f97          	auipc	t6,0x99
ffffffffc0202594:	5b8f8f93          	addi	t6,t6,1464 # ffffffffc029bb48 <va_pa_offset>
ffffffffc0202598:	000803b7          	lui	t2,0x80
ffffffffc020259c:	fff802b7          	lui	t0,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc02025a0:	00073023          	sd	zero,0(a4)
ffffffffc02025a4:	bd7d                	j	ffffffffc0202462 <exit_range+0xd6>
        intr_disable();
ffffffffc02025a6:	e832                	sd	a2,16(sp)
ffffffffc02025a8:	e42a                	sd	a0,8(sp)
ffffffffc02025aa:	b5afe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025ae:	00099797          	auipc	a5,0x99
ffffffffc02025b2:	5827b783          	ld	a5,1410(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc02025b6:	6522                	ld	a0,8(sp)
ffffffffc02025b8:	4585                	li	a1,1
ffffffffc02025ba:	739c                	ld	a5,32(a5)
ffffffffc02025bc:	9782                	jalr	a5
        intr_enable();
ffffffffc02025be:	b40fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02025c2:	6642                	ld	a2,16(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc02025c4:	00043023          	sd	zero,0(s0)
ffffffffc02025c8:	b5cd                	j	ffffffffc02024aa <exit_range+0x11e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02025ca:	00004697          	auipc	a3,0x4
ffffffffc02025ce:	25e68693          	addi	a3,a3,606 # ffffffffc0206828 <etext+0xefa>
ffffffffc02025d2:	00004617          	auipc	a2,0x4
ffffffffc02025d6:	da660613          	addi	a2,a2,-602 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02025da:	13500593          	li	a1,309
ffffffffc02025de:	00004517          	auipc	a0,0x4
ffffffffc02025e2:	23a50513          	addi	a0,a0,570 # ffffffffc0206818 <etext+0xeea>
ffffffffc02025e6:	e61fd0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02025ea:	00004617          	auipc	a2,0x4
ffffffffc02025ee:	13e60613          	addi	a2,a2,318 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02025f2:	07100593          	li	a1,113
ffffffffc02025f6:	00004517          	auipc	a0,0x4
ffffffffc02025fa:	15a50513          	addi	a0,a0,346 # ffffffffc0206750 <etext+0xe22>
ffffffffc02025fe:	e49fd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0202602:	86f2                	mv	a3,t3
ffffffffc0202604:	00004617          	auipc	a2,0x4
ffffffffc0202608:	12460613          	addi	a2,a2,292 # ffffffffc0206728 <etext+0xdfa>
ffffffffc020260c:	07100593          	li	a1,113
ffffffffc0202610:	00004517          	auipc	a0,0x4
ffffffffc0202614:	14050513          	addi	a0,a0,320 # ffffffffc0206750 <etext+0xe22>
ffffffffc0202618:	e2ffd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc020261c:	8c7ff0ef          	jal	ffffffffc0201ee2 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202620:	00004697          	auipc	a3,0x4
ffffffffc0202624:	23868693          	addi	a3,a3,568 # ffffffffc0206858 <etext+0xf2a>
ffffffffc0202628:	00004617          	auipc	a2,0x4
ffffffffc020262c:	d5060613          	addi	a2,a2,-688 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202630:	13600593          	li	a1,310
ffffffffc0202634:	00004517          	auipc	a0,0x4
ffffffffc0202638:	1e450513          	addi	a0,a0,484 # ffffffffc0206818 <etext+0xeea>
ffffffffc020263c:	e0bfd0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0202640 <page_remove>:
{
ffffffffc0202640:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202642:	4601                	li	a2,0
{
ffffffffc0202644:	e822                	sd	s0,16(sp)
ffffffffc0202646:	ec06                	sd	ra,24(sp)
ffffffffc0202648:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020264a:	95dff0ef          	jal	ffffffffc0201fa6 <get_pte>
    if (ptep != NULL)
ffffffffc020264e:	c511                	beqz	a0,ffffffffc020265a <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc0202650:	6118                	ld	a4,0(a0)
ffffffffc0202652:	87aa                	mv	a5,a0
ffffffffc0202654:	00177693          	andi	a3,a4,1
ffffffffc0202658:	e689                	bnez	a3,ffffffffc0202662 <page_remove+0x22>
}
ffffffffc020265a:	60e2                	ld	ra,24(sp)
ffffffffc020265c:	6442                	ld	s0,16(sp)
ffffffffc020265e:	6105                	addi	sp,sp,32
ffffffffc0202660:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202662:	00099697          	auipc	a3,0x99
ffffffffc0202666:	4ee6b683          	ld	a3,1262(a3) # ffffffffc029bb50 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc020266a:	070a                	slli	a4,a4,0x2
ffffffffc020266c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc020266e:	06d77563          	bgeu	a4,a3,ffffffffc02026d8 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202672:	00099517          	auipc	a0,0x99
ffffffffc0202676:	4e653503          	ld	a0,1254(a0) # ffffffffc029bb58 <pages>
ffffffffc020267a:	071a                	slli	a4,a4,0x6
ffffffffc020267c:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202680:	9736                	add	a4,a4,a3
ffffffffc0202682:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202684:	4118                	lw	a4,0(a0)
ffffffffc0202686:	377d                	addiw	a4,a4,-1
ffffffffc0202688:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc020268a:	cb09                	beqz	a4,ffffffffc020269c <page_remove+0x5c>
        *ptep = 0;
ffffffffc020268c:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202690:	12040073          	sfence.vma	s0
}
ffffffffc0202694:	60e2                	ld	ra,24(sp)
ffffffffc0202696:	6442                	ld	s0,16(sp)
ffffffffc0202698:	6105                	addi	sp,sp,32
ffffffffc020269a:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020269c:	10002773          	csrr	a4,sstatus
ffffffffc02026a0:	8b09                	andi	a4,a4,2
ffffffffc02026a2:	eb19                	bnez	a4,ffffffffc02026b8 <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc02026a4:	00099717          	auipc	a4,0x99
ffffffffc02026a8:	48c73703          	ld	a4,1164(a4) # ffffffffc029bb30 <pmm_manager>
ffffffffc02026ac:	4585                	li	a1,1
ffffffffc02026ae:	e03e                	sd	a5,0(sp)
ffffffffc02026b0:	7318                	ld	a4,32(a4)
ffffffffc02026b2:	9702                	jalr	a4
    if (flag)
ffffffffc02026b4:	6782                	ld	a5,0(sp)
ffffffffc02026b6:	bfd9                	j	ffffffffc020268c <page_remove+0x4c>
        intr_disable();
ffffffffc02026b8:	e43e                	sd	a5,8(sp)
ffffffffc02026ba:	e02a                	sd	a0,0(sp)
ffffffffc02026bc:	a48fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc02026c0:	00099717          	auipc	a4,0x99
ffffffffc02026c4:	47073703          	ld	a4,1136(a4) # ffffffffc029bb30 <pmm_manager>
ffffffffc02026c8:	6502                	ld	a0,0(sp)
ffffffffc02026ca:	4585                	li	a1,1
ffffffffc02026cc:	7318                	ld	a4,32(a4)
ffffffffc02026ce:	9702                	jalr	a4
        intr_enable();
ffffffffc02026d0:	a2efe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02026d4:	67a2                	ld	a5,8(sp)
ffffffffc02026d6:	bf5d                	j	ffffffffc020268c <page_remove+0x4c>
ffffffffc02026d8:	80bff0ef          	jal	ffffffffc0201ee2 <pa2page.part.0>

ffffffffc02026dc <page_insert>:
{
ffffffffc02026dc:	7139                	addi	sp,sp,-64
ffffffffc02026de:	f426                	sd	s1,40(sp)
ffffffffc02026e0:	84b2                	mv	s1,a2
ffffffffc02026e2:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026e4:	4605                	li	a2,1
{
ffffffffc02026e6:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026e8:	85a6                	mv	a1,s1
{
ffffffffc02026ea:	fc06                	sd	ra,56(sp)
ffffffffc02026ec:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02026ee:	8b9ff0ef          	jal	ffffffffc0201fa6 <get_pte>
    if (ptep == NULL)
ffffffffc02026f2:	cd61                	beqz	a0,ffffffffc02027ca <page_insert+0xee>
    page->ref += 1;
ffffffffc02026f4:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc02026f6:	611c                	ld	a5,0(a0)
ffffffffc02026f8:	66a2                	ld	a3,8(sp)
ffffffffc02026fa:	0015861b          	addiw	a2,a1,1 # 1001 <_binary_obj___user_softint_out_size-0x7c0f>
ffffffffc02026fe:	c010                	sw	a2,0(s0)
ffffffffc0202700:	0017f613          	andi	a2,a5,1
ffffffffc0202704:	872a                	mv	a4,a0
ffffffffc0202706:	e61d                	bnez	a2,ffffffffc0202734 <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc0202708:	00099617          	auipc	a2,0x99
ffffffffc020270c:	45063603          	ld	a2,1104(a2) # ffffffffc029bb58 <pages>
    return page - pages + nbase;
ffffffffc0202710:	8c11                	sub	s0,s0,a2
ffffffffc0202712:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202714:	200007b7          	lui	a5,0x20000
ffffffffc0202718:	042a                	slli	s0,s0,0xa
ffffffffc020271a:	943e                	add	s0,s0,a5
ffffffffc020271c:	8ec1                	or	a3,a3,s0
ffffffffc020271e:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202722:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202724:	12048073          	sfence.vma	s1
    return 0;
ffffffffc0202728:	4501                	li	a0,0
}
ffffffffc020272a:	70e2                	ld	ra,56(sp)
ffffffffc020272c:	7442                	ld	s0,48(sp)
ffffffffc020272e:	74a2                	ld	s1,40(sp)
ffffffffc0202730:	6121                	addi	sp,sp,64
ffffffffc0202732:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202734:	00099617          	auipc	a2,0x99
ffffffffc0202738:	41c63603          	ld	a2,1052(a2) # ffffffffc029bb50 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc020273c:	078a                	slli	a5,a5,0x2
ffffffffc020273e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202740:	08c7f763          	bgeu	a5,a2,ffffffffc02027ce <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202744:	00099617          	auipc	a2,0x99
ffffffffc0202748:	41463603          	ld	a2,1044(a2) # ffffffffc029bb58 <pages>
ffffffffc020274c:	fe000537          	lui	a0,0xfe000
ffffffffc0202750:	079a                	slli	a5,a5,0x6
ffffffffc0202752:	97aa                	add	a5,a5,a0
ffffffffc0202754:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc0202758:	00a40963          	beq	s0,a0,ffffffffc020276a <page_insert+0x8e>
    page->ref -= 1;
ffffffffc020275c:	411c                	lw	a5,0(a0)
ffffffffc020275e:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_obj___user_exit_out_size+0x1fff5df7>
ffffffffc0202760:	c11c                	sw	a5,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202762:	c791                	beqz	a5,ffffffffc020276e <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202764:	12048073          	sfence.vma	s1
}
ffffffffc0202768:	b765                	j	ffffffffc0202710 <page_insert+0x34>
ffffffffc020276a:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc020276c:	b755                	j	ffffffffc0202710 <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020276e:	100027f3          	csrr	a5,sstatus
ffffffffc0202772:	8b89                	andi	a5,a5,2
ffffffffc0202774:	e39d                	bnez	a5,ffffffffc020279a <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc0202776:	00099797          	auipc	a5,0x99
ffffffffc020277a:	3ba7b783          	ld	a5,954(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc020277e:	4585                	li	a1,1
ffffffffc0202780:	e83a                	sd	a4,16(sp)
ffffffffc0202782:	739c                	ld	a5,32(a5)
ffffffffc0202784:	e436                	sd	a3,8(sp)
ffffffffc0202786:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202788:	00099617          	auipc	a2,0x99
ffffffffc020278c:	3d063603          	ld	a2,976(a2) # ffffffffc029bb58 <pages>
ffffffffc0202790:	66a2                	ld	a3,8(sp)
ffffffffc0202792:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202794:	12048073          	sfence.vma	s1
ffffffffc0202798:	bfa5                	j	ffffffffc0202710 <page_insert+0x34>
        intr_disable();
ffffffffc020279a:	ec3a                	sd	a4,24(sp)
ffffffffc020279c:	e836                	sd	a3,16(sp)
ffffffffc020279e:	e42a                	sd	a0,8(sp)
ffffffffc02027a0:	964fe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02027a4:	00099797          	auipc	a5,0x99
ffffffffc02027a8:	38c7b783          	ld	a5,908(a5) # ffffffffc029bb30 <pmm_manager>
ffffffffc02027ac:	6522                	ld	a0,8(sp)
ffffffffc02027ae:	4585                	li	a1,1
ffffffffc02027b0:	739c                	ld	a5,32(a5)
ffffffffc02027b2:	9782                	jalr	a5
        intr_enable();
ffffffffc02027b4:	94afe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02027b8:	00099617          	auipc	a2,0x99
ffffffffc02027bc:	3a063603          	ld	a2,928(a2) # ffffffffc029bb58 <pages>
ffffffffc02027c0:	6762                	ld	a4,24(sp)
ffffffffc02027c2:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027c4:	12048073          	sfence.vma	s1
ffffffffc02027c8:	b7a1                	j	ffffffffc0202710 <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc02027ca:	5571                	li	a0,-4
ffffffffc02027cc:	bfb9                	j	ffffffffc020272a <page_insert+0x4e>
ffffffffc02027ce:	f14ff0ef          	jal	ffffffffc0201ee2 <pa2page.part.0>

ffffffffc02027d2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02027d2:	00005797          	auipc	a5,0x5
ffffffffc02027d6:	fa678793          	addi	a5,a5,-90 # ffffffffc0207778 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027da:	638c                	ld	a1,0(a5)
{
ffffffffc02027dc:	7159                	addi	sp,sp,-112
ffffffffc02027de:	f486                	sd	ra,104(sp)
ffffffffc02027e0:	e8ca                	sd	s2,80(sp)
ffffffffc02027e2:	e4ce                	sd	s3,72(sp)
ffffffffc02027e4:	f85a                	sd	s6,48(sp)
ffffffffc02027e6:	f0a2                	sd	s0,96(sp)
ffffffffc02027e8:	eca6                	sd	s1,88(sp)
ffffffffc02027ea:	e0d2                	sd	s4,64(sp)
ffffffffc02027ec:	fc56                	sd	s5,56(sp)
ffffffffc02027ee:	f45e                	sd	s7,40(sp)
ffffffffc02027f0:	f062                	sd	s8,32(sp)
ffffffffc02027f2:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02027f4:	00099b17          	auipc	s6,0x99
ffffffffc02027f8:	33cb0b13          	addi	s6,s6,828 # ffffffffc029bb30 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027fc:	00004517          	auipc	a0,0x4
ffffffffc0202800:	07450513          	addi	a0,a0,116 # ffffffffc0206870 <etext+0xf42>
    pmm_manager = &default_pmm_manager;
ffffffffc0202804:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202808:	98dfd0ef          	jal	ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc020280c:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202810:	00099997          	auipc	s3,0x99
ffffffffc0202814:	33898993          	addi	s3,s3,824 # ffffffffc029bb48 <va_pa_offset>
    pmm_manager->init();
ffffffffc0202818:	679c                	ld	a5,8(a5)
ffffffffc020281a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020281c:	57f5                	li	a5,-3
ffffffffc020281e:	07fa                	slli	a5,a5,0x1e
ffffffffc0202820:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202824:	8c6fe0ef          	jal	ffffffffc02008ea <get_memory_base>
ffffffffc0202828:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc020282a:	8cafe0ef          	jal	ffffffffc02008f4 <get_memory_size>
    if (mem_size == 0)
ffffffffc020282e:	70050e63          	beqz	a0,ffffffffc0202f4a <pmm_init+0x778>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202832:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202834:	00004517          	auipc	a0,0x4
ffffffffc0202838:	07450513          	addi	a0,a0,116 # ffffffffc02068a8 <etext+0xf7a>
ffffffffc020283c:	959fd0ef          	jal	ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0202840:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202844:	864a                	mv	a2,s2
ffffffffc0202846:	85a6                	mv	a1,s1
ffffffffc0202848:	fff40693          	addi	a3,s0,-1
ffffffffc020284c:	00004517          	auipc	a0,0x4
ffffffffc0202850:	07450513          	addi	a0,a0,116 # ffffffffc02068c0 <etext+0xf92>
ffffffffc0202854:	941fd0ef          	jal	ffffffffc0200194 <cprintf>
    if (maxpa > KERNTOP)
ffffffffc0202858:	c80007b7          	lui	a5,0xc8000
ffffffffc020285c:	8522                	mv	a0,s0
ffffffffc020285e:	5287ed63          	bltu	a5,s0,ffffffffc0202d98 <pmm_init+0x5c6>
ffffffffc0202862:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202864:	0009a617          	auipc	a2,0x9a
ffffffffc0202868:	31b60613          	addi	a2,a2,795 # ffffffffc029cb7f <end+0xfff>
ffffffffc020286c:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc020286e:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202870:	00099b97          	auipc	s7,0x99
ffffffffc0202874:	2e8b8b93          	addi	s7,s7,744 # ffffffffc029bb58 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202878:	00099497          	auipc	s1,0x99
ffffffffc020287c:	2d848493          	addi	s1,s1,728 # ffffffffc029bb50 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202880:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc0202884:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202886:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020288a:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020288c:	02f50763          	beq	a0,a5,ffffffffc02028ba <pmm_init+0xe8>
ffffffffc0202890:	4701                	li	a4,0
ffffffffc0202892:	4585                	li	a1,1
ffffffffc0202894:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202898:	00671793          	slli	a5,a4,0x6
ffffffffc020289c:	97b2                	add	a5,a5,a2
ffffffffc020289e:	07a1                	addi	a5,a5,8 # 80008 <_binary_obj___user_exit_out_size+0x75e00>
ffffffffc02028a0:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028a4:	6088                	ld	a0,0(s1)
ffffffffc02028a6:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028a8:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028ac:	00d507b3          	add	a5,a0,a3
ffffffffc02028b0:	fef764e3          	bltu	a4,a5,ffffffffc0202898 <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028b4:	079a                	slli	a5,a5,0x6
ffffffffc02028b6:	00f606b3          	add	a3,a2,a5
ffffffffc02028ba:	c02007b7          	lui	a5,0xc0200
ffffffffc02028be:	16f6eee3          	bltu	a3,a5,ffffffffc020323a <pmm_init+0xa68>
ffffffffc02028c2:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02028c6:	77fd                	lui	a5,0xfffff
ffffffffc02028c8:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028ca:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc02028cc:	4e86ed63          	bltu	a3,s0,ffffffffc0202dc6 <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02028d0:	00004517          	auipc	a0,0x4
ffffffffc02028d4:	01850513          	addi	a0,a0,24 # ffffffffc02068e8 <etext+0xfba>
ffffffffc02028d8:	8bdfd0ef          	jal	ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc02028dc:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02028e0:	00099917          	auipc	s2,0x99
ffffffffc02028e4:	26090913          	addi	s2,s2,608 # ffffffffc029bb40 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02028e8:	7b9c                	ld	a5,48(a5)
ffffffffc02028ea:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02028ec:	00004517          	auipc	a0,0x4
ffffffffc02028f0:	01450513          	addi	a0,a0,20 # ffffffffc0206900 <etext+0xfd2>
ffffffffc02028f4:	8a1fd0ef          	jal	ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02028f8:	00007697          	auipc	a3,0x7
ffffffffc02028fc:	70868693          	addi	a3,a3,1800 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202900:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202904:	c02007b7          	lui	a5,0xc0200
ffffffffc0202908:	2af6eee3          	bltu	a3,a5,ffffffffc02033c4 <pmm_init+0xbf2>
ffffffffc020290c:	0009b783          	ld	a5,0(s3)
ffffffffc0202910:	8e9d                	sub	a3,a3,a5
ffffffffc0202912:	00099797          	auipc	a5,0x99
ffffffffc0202916:	22d7b323          	sd	a3,550(a5) # ffffffffc029bb38 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020291a:	100027f3          	csrr	a5,sstatus
ffffffffc020291e:	8b89                	andi	a5,a5,2
ffffffffc0202920:	48079963          	bnez	a5,ffffffffc0202db2 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202924:	000b3783          	ld	a5,0(s6)
ffffffffc0202928:	779c                	ld	a5,40(a5)
ffffffffc020292a:	9782                	jalr	a5
ffffffffc020292c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020292e:	6098                	ld	a4,0(s1)
ffffffffc0202930:	c80007b7          	lui	a5,0xc8000
ffffffffc0202934:	83b1                	srli	a5,a5,0xc
ffffffffc0202936:	66e7e663          	bltu	a5,a4,ffffffffc0202fa2 <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020293a:	00093503          	ld	a0,0(s2)
ffffffffc020293e:	64050263          	beqz	a0,ffffffffc0202f82 <pmm_init+0x7b0>
ffffffffc0202942:	03451793          	slli	a5,a0,0x34
ffffffffc0202946:	62079e63          	bnez	a5,ffffffffc0202f82 <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020294a:	4601                	li	a2,0
ffffffffc020294c:	4581                	li	a1,0
ffffffffc020294e:	8b7ff0ef          	jal	ffffffffc0202204 <get_page>
ffffffffc0202952:	240519e3          	bnez	a0,ffffffffc02033a4 <pmm_init+0xbd2>
ffffffffc0202956:	100027f3          	csrr	a5,sstatus
ffffffffc020295a:	8b89                	andi	a5,a5,2
ffffffffc020295c:	44079063          	bnez	a5,ffffffffc0202d9c <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202960:	000b3783          	ld	a5,0(s6)
ffffffffc0202964:	4505                	li	a0,1
ffffffffc0202966:	6f9c                	ld	a5,24(a5)
ffffffffc0202968:	9782                	jalr	a5
ffffffffc020296a:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc020296c:	00093503          	ld	a0,0(s2)
ffffffffc0202970:	4681                	li	a3,0
ffffffffc0202972:	4601                	li	a2,0
ffffffffc0202974:	85d2                	mv	a1,s4
ffffffffc0202976:	d67ff0ef          	jal	ffffffffc02026dc <page_insert>
ffffffffc020297a:	280511e3          	bnez	a0,ffffffffc02033fc <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc020297e:	00093503          	ld	a0,0(s2)
ffffffffc0202982:	4601                	li	a2,0
ffffffffc0202984:	4581                	li	a1,0
ffffffffc0202986:	e20ff0ef          	jal	ffffffffc0201fa6 <get_pte>
ffffffffc020298a:	240509e3          	beqz	a0,ffffffffc02033dc <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc020298e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202990:	0017f713          	andi	a4,a5,1
ffffffffc0202994:	58070f63          	beqz	a4,ffffffffc0202f32 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202998:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020299a:	078a                	slli	a5,a5,0x2
ffffffffc020299c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020299e:	58e7f863          	bgeu	a5,a4,ffffffffc0202f2e <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02029a2:	000bb683          	ld	a3,0(s7)
ffffffffc02029a6:	079a                	slli	a5,a5,0x6
ffffffffc02029a8:	fe000637          	lui	a2,0xfe000
ffffffffc02029ac:	97b2                	add	a5,a5,a2
ffffffffc02029ae:	97b6                	add	a5,a5,a3
ffffffffc02029b0:	14fa1ae3          	bne	s4,a5,ffffffffc0203304 <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc02029b4:	000a2683          	lw	a3,0(s4) # 200000 <_binary_obj___user_exit_out_size+0x1f5df8>
ffffffffc02029b8:	4785                	li	a5,1
ffffffffc02029ba:	12f695e3          	bne	a3,a5,ffffffffc02032e4 <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02029be:	00093503          	ld	a0,0(s2)
ffffffffc02029c2:	77fd                	lui	a5,0xfffff
ffffffffc02029c4:	6114                	ld	a3,0(a0)
ffffffffc02029c6:	068a                	slli	a3,a3,0x2
ffffffffc02029c8:	8efd                	and	a3,a3,a5
ffffffffc02029ca:	00c6d613          	srli	a2,a3,0xc
ffffffffc02029ce:	0ee67fe3          	bgeu	a2,a4,ffffffffc02032cc <pmm_init+0xafa>
ffffffffc02029d2:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029d6:	96e2                	add	a3,a3,s8
ffffffffc02029d8:	0006ba83          	ld	s5,0(a3)
ffffffffc02029dc:	0a8a                	slli	s5,s5,0x2
ffffffffc02029de:	00fafab3          	and	s5,s5,a5
ffffffffc02029e2:	00cad793          	srli	a5,s5,0xc
ffffffffc02029e6:	0ce7f6e3          	bgeu	a5,a4,ffffffffc02032b2 <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029ea:	4601                	li	a2,0
ffffffffc02029ec:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029ee:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029f0:	db6ff0ef          	jal	ffffffffc0201fa6 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029f4:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02029f6:	05851ee3          	bne	a0,s8,ffffffffc0203252 <pmm_init+0xa80>
ffffffffc02029fa:	100027f3          	csrr	a5,sstatus
ffffffffc02029fe:	8b89                	andi	a5,a5,2
ffffffffc0202a00:	3e079b63          	bnez	a5,ffffffffc0202df6 <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a04:	000b3783          	ld	a5,0(s6)
ffffffffc0202a08:	4505                	li	a0,1
ffffffffc0202a0a:	6f9c                	ld	a5,24(a5)
ffffffffc0202a0c:	9782                	jalr	a5
ffffffffc0202a0e:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202a10:	00093503          	ld	a0,0(s2)
ffffffffc0202a14:	46d1                	li	a3,20
ffffffffc0202a16:	6605                	lui	a2,0x1
ffffffffc0202a18:	85e2                	mv	a1,s8
ffffffffc0202a1a:	cc3ff0ef          	jal	ffffffffc02026dc <page_insert>
ffffffffc0202a1e:	06051ae3          	bnez	a0,ffffffffc0203292 <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a22:	00093503          	ld	a0,0(s2)
ffffffffc0202a26:	4601                	li	a2,0
ffffffffc0202a28:	6585                	lui	a1,0x1
ffffffffc0202a2a:	d7cff0ef          	jal	ffffffffc0201fa6 <get_pte>
ffffffffc0202a2e:	040502e3          	beqz	a0,ffffffffc0203272 <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc0202a32:	611c                	ld	a5,0(a0)
ffffffffc0202a34:	0107f713          	andi	a4,a5,16
ffffffffc0202a38:	7e070163          	beqz	a4,ffffffffc020321a <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc0202a3c:	8b91                	andi	a5,a5,4
ffffffffc0202a3e:	7a078e63          	beqz	a5,ffffffffc02031fa <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202a42:	00093503          	ld	a0,0(s2)
ffffffffc0202a46:	611c                	ld	a5,0(a0)
ffffffffc0202a48:	8bc1                	andi	a5,a5,16
ffffffffc0202a4a:	78078863          	beqz	a5,ffffffffc02031da <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc0202a4e:	000c2703          	lw	a4,0(s8)
ffffffffc0202a52:	4785                	li	a5,1
ffffffffc0202a54:	76f71363          	bne	a4,a5,ffffffffc02031ba <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202a58:	4681                	li	a3,0
ffffffffc0202a5a:	6605                	lui	a2,0x1
ffffffffc0202a5c:	85d2                	mv	a1,s4
ffffffffc0202a5e:	c7fff0ef          	jal	ffffffffc02026dc <page_insert>
ffffffffc0202a62:	72051c63          	bnez	a0,ffffffffc020319a <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc0202a66:	000a2703          	lw	a4,0(s4)
ffffffffc0202a6a:	4789                	li	a5,2
ffffffffc0202a6c:	70f71763          	bne	a4,a5,ffffffffc020317a <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc0202a70:	000c2783          	lw	a5,0(s8)
ffffffffc0202a74:	6e079363          	bnez	a5,ffffffffc020315a <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a78:	00093503          	ld	a0,0(s2)
ffffffffc0202a7c:	4601                	li	a2,0
ffffffffc0202a7e:	6585                	lui	a1,0x1
ffffffffc0202a80:	d26ff0ef          	jal	ffffffffc0201fa6 <get_pte>
ffffffffc0202a84:	6a050b63          	beqz	a0,ffffffffc020313a <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a88:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202a8a:	00177793          	andi	a5,a4,1
ffffffffc0202a8e:	4a078263          	beqz	a5,ffffffffc0202f32 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202a92:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a94:	00271793          	slli	a5,a4,0x2
ffffffffc0202a98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a9a:	48d7fa63          	bgeu	a5,a3,ffffffffc0202f2e <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a9e:	000bb683          	ld	a3,0(s7)
ffffffffc0202aa2:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202aa6:	97d6                	add	a5,a5,s5
ffffffffc0202aa8:	079a                	slli	a5,a5,0x6
ffffffffc0202aaa:	97b6                	add	a5,a5,a3
ffffffffc0202aac:	66fa1763          	bne	s4,a5,ffffffffc020311a <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ab0:	8b41                	andi	a4,a4,16
ffffffffc0202ab2:	64071463          	bnez	a4,ffffffffc02030fa <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202ab6:	00093503          	ld	a0,0(s2)
ffffffffc0202aba:	4581                	li	a1,0
ffffffffc0202abc:	b85ff0ef          	jal	ffffffffc0202640 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202ac0:	000a2c83          	lw	s9,0(s4)
ffffffffc0202ac4:	4785                	li	a5,1
ffffffffc0202ac6:	60fc9a63          	bne	s9,a5,ffffffffc02030da <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0202aca:	000c2783          	lw	a5,0(s8)
ffffffffc0202ace:	5e079663          	bnez	a5,ffffffffc02030ba <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202ad2:	00093503          	ld	a0,0(s2)
ffffffffc0202ad6:	6585                	lui	a1,0x1
ffffffffc0202ad8:	b69ff0ef          	jal	ffffffffc0202640 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202adc:	000a2783          	lw	a5,0(s4)
ffffffffc0202ae0:	52079d63          	bnez	a5,ffffffffc020301a <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc0202ae4:	000c2783          	lw	a5,0(s8)
ffffffffc0202ae8:	50079963          	bnez	a5,ffffffffc0202ffa <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202aec:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202af0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202af2:	000a3783          	ld	a5,0(s4)
ffffffffc0202af6:	078a                	slli	a5,a5,0x2
ffffffffc0202af8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202afa:	42e7fa63          	bgeu	a5,a4,ffffffffc0202f2e <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202afe:	000bb503          	ld	a0,0(s7)
ffffffffc0202b02:	97d6                	add	a5,a5,s5
ffffffffc0202b04:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202b06:	00f506b3          	add	a3,a0,a5
ffffffffc0202b0a:	4294                	lw	a3,0(a3)
ffffffffc0202b0c:	4d969763          	bne	a3,s9,ffffffffc0202fda <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc0202b10:	8799                	srai	a5,a5,0x6
ffffffffc0202b12:	00080637          	lui	a2,0x80
ffffffffc0202b16:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b18:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202b1c:	4ae7f363          	bgeu	a5,a4,ffffffffc0202fc2 <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202b20:	0009b783          	ld	a5,0(s3)
ffffffffc0202b24:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b26:	639c                	ld	a5,0(a5)
ffffffffc0202b28:	078a                	slli	a5,a5,0x2
ffffffffc0202b2a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b2c:	40e7f163          	bgeu	a5,a4,ffffffffc0202f2e <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b30:	8f91                	sub	a5,a5,a2
ffffffffc0202b32:	079a                	slli	a5,a5,0x6
ffffffffc0202b34:	953e                	add	a0,a0,a5
ffffffffc0202b36:	100027f3          	csrr	a5,sstatus
ffffffffc0202b3a:	8b89                	andi	a5,a5,2
ffffffffc0202b3c:	30079863          	bnez	a5,ffffffffc0202e4c <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc0202b40:	000b3783          	ld	a5,0(s6)
ffffffffc0202b44:	4585                	li	a1,1
ffffffffc0202b46:	739c                	ld	a5,32(a5)
ffffffffc0202b48:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b4a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202b4e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b50:	078a                	slli	a5,a5,0x2
ffffffffc0202b52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b54:	3ce7fd63          	bgeu	a5,a4,ffffffffc0202f2e <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b58:	000bb503          	ld	a0,0(s7)
ffffffffc0202b5c:	fe000737          	lui	a4,0xfe000
ffffffffc0202b60:	079a                	slli	a5,a5,0x6
ffffffffc0202b62:	97ba                	add	a5,a5,a4
ffffffffc0202b64:	953e                	add	a0,a0,a5
ffffffffc0202b66:	100027f3          	csrr	a5,sstatus
ffffffffc0202b6a:	8b89                	andi	a5,a5,2
ffffffffc0202b6c:	2c079463          	bnez	a5,ffffffffc0202e34 <pmm_init+0x662>
ffffffffc0202b70:	000b3783          	ld	a5,0(s6)
ffffffffc0202b74:	4585                	li	a1,1
ffffffffc0202b76:	739c                	ld	a5,32(a5)
ffffffffc0202b78:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202b7a:	00093783          	ld	a5,0(s2)
ffffffffc0202b7e:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd63480>
    asm volatile("sfence.vma");
ffffffffc0202b82:	12000073          	sfence.vma
ffffffffc0202b86:	100027f3          	csrr	a5,sstatus
ffffffffc0202b8a:	8b89                	andi	a5,a5,2
ffffffffc0202b8c:	28079a63          	bnez	a5,ffffffffc0202e20 <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b90:	000b3783          	ld	a5,0(s6)
ffffffffc0202b94:	779c                	ld	a5,40(a5)
ffffffffc0202b96:	9782                	jalr	a5
ffffffffc0202b98:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202b9a:	4d441063          	bne	s0,s4,ffffffffc020305a <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202b9e:	00004517          	auipc	a0,0x4
ffffffffc0202ba2:	0b250513          	addi	a0,a0,178 # ffffffffc0206c50 <etext+0x1322>
ffffffffc0202ba6:	deefd0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0202baa:	100027f3          	csrr	a5,sstatus
ffffffffc0202bae:	8b89                	andi	a5,a5,2
ffffffffc0202bb0:	24079e63          	bnez	a5,ffffffffc0202e0c <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bb4:	000b3783          	ld	a5,0(s6)
ffffffffc0202bb8:	779c                	ld	a5,40(a5)
ffffffffc0202bba:	9782                	jalr	a5
ffffffffc0202bbc:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bbe:	609c                	ld	a5,0(s1)
ffffffffc0202bc0:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bc4:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bc6:	00c79713          	slli	a4,a5,0xc
ffffffffc0202bca:	6a85                	lui	s5,0x1
ffffffffc0202bcc:	02e47c63          	bgeu	s0,a4,ffffffffc0202c04 <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202bd0:	00c45713          	srli	a4,s0,0xc
ffffffffc0202bd4:	30f77063          	bgeu	a4,a5,ffffffffc0202ed4 <pmm_init+0x702>
ffffffffc0202bd8:	0009b583          	ld	a1,0(s3)
ffffffffc0202bdc:	00093503          	ld	a0,0(s2)
ffffffffc0202be0:	4601                	li	a2,0
ffffffffc0202be2:	95a2                	add	a1,a1,s0
ffffffffc0202be4:	bc2ff0ef          	jal	ffffffffc0201fa6 <get_pte>
ffffffffc0202be8:	32050363          	beqz	a0,ffffffffc0202f0e <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bec:	611c                	ld	a5,0(a0)
ffffffffc0202bee:	078a                	slli	a5,a5,0x2
ffffffffc0202bf0:	0147f7b3          	and	a5,a5,s4
ffffffffc0202bf4:	2e879d63          	bne	a5,s0,ffffffffc0202eee <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bf8:	609c                	ld	a5,0(s1)
ffffffffc0202bfa:	9456                	add	s0,s0,s5
ffffffffc0202bfc:	00c79713          	slli	a4,a5,0xc
ffffffffc0202c00:	fce468e3          	bltu	s0,a4,ffffffffc0202bd0 <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202c04:	00093783          	ld	a5,0(s2)
ffffffffc0202c08:	639c                	ld	a5,0(a5)
ffffffffc0202c0a:	42079863          	bnez	a5,ffffffffc020303a <pmm_init+0x868>
ffffffffc0202c0e:	100027f3          	csrr	a5,sstatus
ffffffffc0202c12:	8b89                	andi	a5,a5,2
ffffffffc0202c14:	24079863          	bnez	a5,ffffffffc0202e64 <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c18:	000b3783          	ld	a5,0(s6)
ffffffffc0202c1c:	4505                	li	a0,1
ffffffffc0202c1e:	6f9c                	ld	a5,24(a5)
ffffffffc0202c20:	9782                	jalr	a5
ffffffffc0202c22:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c24:	00093503          	ld	a0,0(s2)
ffffffffc0202c28:	4699                	li	a3,6
ffffffffc0202c2a:	10000613          	li	a2,256
ffffffffc0202c2e:	85a2                	mv	a1,s0
ffffffffc0202c30:	aadff0ef          	jal	ffffffffc02026dc <page_insert>
ffffffffc0202c34:	46051363          	bnez	a0,ffffffffc020309a <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc0202c38:	4018                	lw	a4,0(s0)
ffffffffc0202c3a:	4785                	li	a5,1
ffffffffc0202c3c:	42f71f63          	bne	a4,a5,ffffffffc020307a <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202c40:	00093503          	ld	a0,0(s2)
ffffffffc0202c44:	6605                	lui	a2,0x1
ffffffffc0202c46:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x7b10>
ffffffffc0202c4a:	4699                	li	a3,6
ffffffffc0202c4c:	85a2                	mv	a1,s0
ffffffffc0202c4e:	a8fff0ef          	jal	ffffffffc02026dc <page_insert>
ffffffffc0202c52:	72051963          	bnez	a0,ffffffffc0203384 <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0202c56:	4018                	lw	a4,0(s0)
ffffffffc0202c58:	4789                	li	a5,2
ffffffffc0202c5a:	70f71563          	bne	a4,a5,ffffffffc0203364 <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202c5e:	00004597          	auipc	a1,0x4
ffffffffc0202c62:	13a58593          	addi	a1,a1,314 # ffffffffc0206d98 <etext+0x146a>
ffffffffc0202c66:	10000513          	li	a0,256
ffffffffc0202c6a:	41b020ef          	jal	ffffffffc0205884 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202c6e:	6585                	lui	a1,0x1
ffffffffc0202c70:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x7b10>
ffffffffc0202c74:	10000513          	li	a0,256
ffffffffc0202c78:	41f020ef          	jal	ffffffffc0205896 <strcmp>
ffffffffc0202c7c:	6c051463          	bnez	a0,ffffffffc0203344 <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0202c80:	000bb683          	ld	a3,0(s7)
ffffffffc0202c84:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202c88:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202c8a:	40d406b3          	sub	a3,s0,a3
ffffffffc0202c8e:	8699                	srai	a3,a3,0x6
ffffffffc0202c90:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202c92:	00c69793          	slli	a5,a3,0xc
ffffffffc0202c96:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c98:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202c9a:	32e7f463          	bgeu	a5,a4,ffffffffc0202fc2 <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c9e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ca2:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ca6:	97b6                	add	a5,a5,a3
ffffffffc0202ca8:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_exit_out_size+0x75ef8>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202cac:	3a5020ef          	jal	ffffffffc0205850 <strlen>
ffffffffc0202cb0:	66051a63          	bnez	a0,ffffffffc0203324 <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202cb4:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202cb8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cba:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd63480>
ffffffffc0202cbe:	078a                	slli	a5,a5,0x2
ffffffffc0202cc0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cc2:	26e7f663          	bgeu	a5,a4,ffffffffc0202f2e <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cc6:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202cca:	2ee7fc63          	bgeu	a5,a4,ffffffffc0202fc2 <pmm_init+0x7f0>
ffffffffc0202cce:	0009b783          	ld	a5,0(s3)
ffffffffc0202cd2:	00f689b3          	add	s3,a3,a5
ffffffffc0202cd6:	100027f3          	csrr	a5,sstatus
ffffffffc0202cda:	8b89                	andi	a5,a5,2
ffffffffc0202cdc:	1e079163          	bnez	a5,ffffffffc0202ebe <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc0202ce0:	000b3783          	ld	a5,0(s6)
ffffffffc0202ce4:	8522                	mv	a0,s0
ffffffffc0202ce6:	4585                	li	a1,1
ffffffffc0202ce8:	739c                	ld	a5,32(a5)
ffffffffc0202cea:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cec:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc0202cf0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cf2:	078a                	slli	a5,a5,0x2
ffffffffc0202cf4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cf6:	22e7fc63          	bgeu	a5,a4,ffffffffc0202f2e <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cfa:	000bb503          	ld	a0,0(s7)
ffffffffc0202cfe:	fe000737          	lui	a4,0xfe000
ffffffffc0202d02:	079a                	slli	a5,a5,0x6
ffffffffc0202d04:	97ba                	add	a5,a5,a4
ffffffffc0202d06:	953e                	add	a0,a0,a5
ffffffffc0202d08:	100027f3          	csrr	a5,sstatus
ffffffffc0202d0c:	8b89                	andi	a5,a5,2
ffffffffc0202d0e:	18079c63          	bnez	a5,ffffffffc0202ea6 <pmm_init+0x6d4>
ffffffffc0202d12:	000b3783          	ld	a5,0(s6)
ffffffffc0202d16:	4585                	li	a1,1
ffffffffc0202d18:	739c                	ld	a5,32(a5)
ffffffffc0202d1a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d1c:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202d20:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d22:	078a                	slli	a5,a5,0x2
ffffffffc0202d24:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d26:	20e7f463          	bgeu	a5,a4,ffffffffc0202f2e <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d2a:	000bb503          	ld	a0,0(s7)
ffffffffc0202d2e:	fe000737          	lui	a4,0xfe000
ffffffffc0202d32:	079a                	slli	a5,a5,0x6
ffffffffc0202d34:	97ba                	add	a5,a5,a4
ffffffffc0202d36:	953e                	add	a0,a0,a5
ffffffffc0202d38:	100027f3          	csrr	a5,sstatus
ffffffffc0202d3c:	8b89                	andi	a5,a5,2
ffffffffc0202d3e:	14079863          	bnez	a5,ffffffffc0202e8e <pmm_init+0x6bc>
ffffffffc0202d42:	000b3783          	ld	a5,0(s6)
ffffffffc0202d46:	4585                	li	a1,1
ffffffffc0202d48:	739c                	ld	a5,32(a5)
ffffffffc0202d4a:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202d4c:	00093783          	ld	a5,0(s2)
ffffffffc0202d50:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202d54:	12000073          	sfence.vma
ffffffffc0202d58:	100027f3          	csrr	a5,sstatus
ffffffffc0202d5c:	8b89                	andi	a5,a5,2
ffffffffc0202d5e:	10079e63          	bnez	a5,ffffffffc0202e7a <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d62:	000b3783          	ld	a5,0(s6)
ffffffffc0202d66:	779c                	ld	a5,40(a5)
ffffffffc0202d68:	9782                	jalr	a5
ffffffffc0202d6a:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202d6c:	1e8c1b63          	bne	s8,s0,ffffffffc0202f62 <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202d70:	00004517          	auipc	a0,0x4
ffffffffc0202d74:	0a050513          	addi	a0,a0,160 # ffffffffc0206e10 <etext+0x14e2>
ffffffffc0202d78:	c1cfd0ef          	jal	ffffffffc0200194 <cprintf>
}
ffffffffc0202d7c:	7406                	ld	s0,96(sp)
ffffffffc0202d7e:	70a6                	ld	ra,104(sp)
ffffffffc0202d80:	64e6                	ld	s1,88(sp)
ffffffffc0202d82:	6946                	ld	s2,80(sp)
ffffffffc0202d84:	69a6                	ld	s3,72(sp)
ffffffffc0202d86:	6a06                	ld	s4,64(sp)
ffffffffc0202d88:	7ae2                	ld	s5,56(sp)
ffffffffc0202d8a:	7b42                	ld	s6,48(sp)
ffffffffc0202d8c:	7ba2                	ld	s7,40(sp)
ffffffffc0202d8e:	7c02                	ld	s8,32(sp)
ffffffffc0202d90:	6ce2                	ld	s9,24(sp)
ffffffffc0202d92:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202d94:	f85fe06f          	j	ffffffffc0201d18 <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0202d98:	853e                	mv	a0,a5
ffffffffc0202d9a:	b4e1                	j	ffffffffc0202862 <pmm_init+0x90>
        intr_disable();
ffffffffc0202d9c:	b69fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202da0:	000b3783          	ld	a5,0(s6)
ffffffffc0202da4:	4505                	li	a0,1
ffffffffc0202da6:	6f9c                	ld	a5,24(a5)
ffffffffc0202da8:	9782                	jalr	a5
ffffffffc0202daa:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202dac:	b53fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202db0:	be75                	j	ffffffffc020296c <pmm_init+0x19a>
        intr_disable();
ffffffffc0202db2:	b53fd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202db6:	000b3783          	ld	a5,0(s6)
ffffffffc0202dba:	779c                	ld	a5,40(a5)
ffffffffc0202dbc:	9782                	jalr	a5
ffffffffc0202dbe:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202dc0:	b3ffd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202dc4:	b6ad                	j	ffffffffc020292e <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202dc6:	6705                	lui	a4,0x1
ffffffffc0202dc8:	177d                	addi	a4,a4,-1 # fff <_binary_obj___user_softint_out_size-0x7c11>
ffffffffc0202dca:	96ba                	add	a3,a3,a4
ffffffffc0202dcc:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202dce:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202dd2:	14a77e63          	bgeu	a4,a0,ffffffffc0202f2e <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc0202dd6:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202dda:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202ddc:	071a                	slli	a4,a4,0x6
ffffffffc0202dde:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202de2:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202de4:	6a9c                	ld	a5,16(a3)
ffffffffc0202de6:	00c45593          	srli	a1,s0,0xc
ffffffffc0202dea:	00e60533          	add	a0,a2,a4
ffffffffc0202dee:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202df0:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202df4:	bcf1                	j	ffffffffc02028d0 <pmm_init+0xfe>
        intr_disable();
ffffffffc0202df6:	b0ffd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202dfa:	000b3783          	ld	a5,0(s6)
ffffffffc0202dfe:	4505                	li	a0,1
ffffffffc0202e00:	6f9c                	ld	a5,24(a5)
ffffffffc0202e02:	9782                	jalr	a5
ffffffffc0202e04:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e06:	af9fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e0a:	b119                	j	ffffffffc0202a10 <pmm_init+0x23e>
        intr_disable();
ffffffffc0202e0c:	af9fd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e10:	000b3783          	ld	a5,0(s6)
ffffffffc0202e14:	779c                	ld	a5,40(a5)
ffffffffc0202e16:	9782                	jalr	a5
ffffffffc0202e18:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e1a:	ae5fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e1e:	b345                	j	ffffffffc0202bbe <pmm_init+0x3ec>
        intr_disable();
ffffffffc0202e20:	ae5fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202e24:	000b3783          	ld	a5,0(s6)
ffffffffc0202e28:	779c                	ld	a5,40(a5)
ffffffffc0202e2a:	9782                	jalr	a5
ffffffffc0202e2c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e2e:	ad1fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e32:	b3a5                	j	ffffffffc0202b9a <pmm_init+0x3c8>
ffffffffc0202e34:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e36:	acffd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e3a:	000b3783          	ld	a5,0(s6)
ffffffffc0202e3e:	6522                	ld	a0,8(sp)
ffffffffc0202e40:	4585                	li	a1,1
ffffffffc0202e42:	739c                	ld	a5,32(a5)
ffffffffc0202e44:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e46:	ab9fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e4a:	bb05                	j	ffffffffc0202b7a <pmm_init+0x3a8>
ffffffffc0202e4c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e4e:	ab7fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202e52:	000b3783          	ld	a5,0(s6)
ffffffffc0202e56:	6522                	ld	a0,8(sp)
ffffffffc0202e58:	4585                	li	a1,1
ffffffffc0202e5a:	739c                	ld	a5,32(a5)
ffffffffc0202e5c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e5e:	aa1fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e62:	b1e5                	j	ffffffffc0202b4a <pmm_init+0x378>
        intr_disable();
ffffffffc0202e64:	aa1fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e68:	000b3783          	ld	a5,0(s6)
ffffffffc0202e6c:	4505                	li	a0,1
ffffffffc0202e6e:	6f9c                	ld	a5,24(a5)
ffffffffc0202e70:	9782                	jalr	a5
ffffffffc0202e72:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e74:	a8bfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e78:	b375                	j	ffffffffc0202c24 <pmm_init+0x452>
        intr_disable();
ffffffffc0202e7a:	a8bfd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e7e:	000b3783          	ld	a5,0(s6)
ffffffffc0202e82:	779c                	ld	a5,40(a5)
ffffffffc0202e84:	9782                	jalr	a5
ffffffffc0202e86:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e88:	a77fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e8c:	b5c5                	j	ffffffffc0202d6c <pmm_init+0x59a>
ffffffffc0202e8e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e90:	a75fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e94:	000b3783          	ld	a5,0(s6)
ffffffffc0202e98:	6522                	ld	a0,8(sp)
ffffffffc0202e9a:	4585                	li	a1,1
ffffffffc0202e9c:	739c                	ld	a5,32(a5)
ffffffffc0202e9e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ea0:	a5ffd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202ea4:	b565                	j	ffffffffc0202d4c <pmm_init+0x57a>
ffffffffc0202ea6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ea8:	a5dfd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202eac:	000b3783          	ld	a5,0(s6)
ffffffffc0202eb0:	6522                	ld	a0,8(sp)
ffffffffc0202eb2:	4585                	li	a1,1
ffffffffc0202eb4:	739c                	ld	a5,32(a5)
ffffffffc0202eb6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202eb8:	a47fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202ebc:	b585                	j	ffffffffc0202d1c <pmm_init+0x54a>
        intr_disable();
ffffffffc0202ebe:	a47fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202ec2:	000b3783          	ld	a5,0(s6)
ffffffffc0202ec6:	8522                	mv	a0,s0
ffffffffc0202ec8:	4585                	li	a1,1
ffffffffc0202eca:	739c                	ld	a5,32(a5)
ffffffffc0202ecc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ece:	a31fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202ed2:	bd29                	j	ffffffffc0202cec <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202ed4:	86a2                	mv	a3,s0
ffffffffc0202ed6:	00004617          	auipc	a2,0x4
ffffffffc0202eda:	85260613          	addi	a2,a2,-1966 # ffffffffc0206728 <etext+0xdfa>
ffffffffc0202ede:	26000593          	li	a1,608
ffffffffc0202ee2:	00004517          	auipc	a0,0x4
ffffffffc0202ee6:	93650513          	addi	a0,a0,-1738 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202eea:	d5cfd0ef          	jal	ffffffffc0200446 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202eee:	00004697          	auipc	a3,0x4
ffffffffc0202ef2:	dc268693          	addi	a3,a3,-574 # ffffffffc0206cb0 <etext+0x1382>
ffffffffc0202ef6:	00003617          	auipc	a2,0x3
ffffffffc0202efa:	48260613          	addi	a2,a2,1154 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202efe:	26100593          	li	a1,609
ffffffffc0202f02:	00004517          	auipc	a0,0x4
ffffffffc0202f06:	91650513          	addi	a0,a0,-1770 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202f0a:	d3cfd0ef          	jal	ffffffffc0200446 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f0e:	00004697          	auipc	a3,0x4
ffffffffc0202f12:	d6268693          	addi	a3,a3,-670 # ffffffffc0206c70 <etext+0x1342>
ffffffffc0202f16:	00003617          	auipc	a2,0x3
ffffffffc0202f1a:	46260613          	addi	a2,a2,1122 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202f1e:	26000593          	li	a1,608
ffffffffc0202f22:	00004517          	auipc	a0,0x4
ffffffffc0202f26:	8f650513          	addi	a0,a0,-1802 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202f2a:	d1cfd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0202f2e:	fb5fe0ef          	jal	ffffffffc0201ee2 <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc0202f32:	00004617          	auipc	a2,0x4
ffffffffc0202f36:	ade60613          	addi	a2,a2,-1314 # ffffffffc0206a10 <etext+0x10e2>
ffffffffc0202f3a:	07f00593          	li	a1,127
ffffffffc0202f3e:	00004517          	auipc	a0,0x4
ffffffffc0202f42:	81250513          	addi	a0,a0,-2030 # ffffffffc0206750 <etext+0xe22>
ffffffffc0202f46:	d00fd0ef          	jal	ffffffffc0200446 <__panic>
        panic("DTB memory info not available");
ffffffffc0202f4a:	00004617          	auipc	a2,0x4
ffffffffc0202f4e:	93e60613          	addi	a2,a2,-1730 # ffffffffc0206888 <etext+0xf5a>
ffffffffc0202f52:	06500593          	li	a1,101
ffffffffc0202f56:	00004517          	auipc	a0,0x4
ffffffffc0202f5a:	8c250513          	addi	a0,a0,-1854 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202f5e:	ce8fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202f62:	00004697          	auipc	a3,0x4
ffffffffc0202f66:	cc668693          	addi	a3,a3,-826 # ffffffffc0206c28 <etext+0x12fa>
ffffffffc0202f6a:	00003617          	auipc	a2,0x3
ffffffffc0202f6e:	40e60613          	addi	a2,a2,1038 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202f72:	27b00593          	li	a1,635
ffffffffc0202f76:	00004517          	auipc	a0,0x4
ffffffffc0202f7a:	8a250513          	addi	a0,a0,-1886 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202f7e:	cc8fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202f82:	00004697          	auipc	a3,0x4
ffffffffc0202f86:	9be68693          	addi	a3,a3,-1602 # ffffffffc0206940 <etext+0x1012>
ffffffffc0202f8a:	00003617          	auipc	a2,0x3
ffffffffc0202f8e:	3ee60613          	addi	a2,a2,1006 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202f92:	22200593          	li	a1,546
ffffffffc0202f96:	00004517          	auipc	a0,0x4
ffffffffc0202f9a:	88250513          	addi	a0,a0,-1918 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202f9e:	ca8fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202fa2:	00004697          	auipc	a3,0x4
ffffffffc0202fa6:	97e68693          	addi	a3,a3,-1666 # ffffffffc0206920 <etext+0xff2>
ffffffffc0202faa:	00003617          	auipc	a2,0x3
ffffffffc0202fae:	3ce60613          	addi	a2,a2,974 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202fb2:	22100593          	li	a1,545
ffffffffc0202fb6:	00004517          	auipc	a0,0x4
ffffffffc0202fba:	86250513          	addi	a0,a0,-1950 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202fbe:	c88fd0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202fc2:	00003617          	auipc	a2,0x3
ffffffffc0202fc6:	76660613          	addi	a2,a2,1894 # ffffffffc0206728 <etext+0xdfa>
ffffffffc0202fca:	07100593          	li	a1,113
ffffffffc0202fce:	00003517          	auipc	a0,0x3
ffffffffc0202fd2:	78250513          	addi	a0,a0,1922 # ffffffffc0206750 <etext+0xe22>
ffffffffc0202fd6:	c70fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202fda:	00004697          	auipc	a3,0x4
ffffffffc0202fde:	c1e68693          	addi	a3,a3,-994 # ffffffffc0206bf8 <etext+0x12ca>
ffffffffc0202fe2:	00003617          	auipc	a2,0x3
ffffffffc0202fe6:	39660613          	addi	a2,a2,918 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0202fea:	24900593          	li	a1,585
ffffffffc0202fee:	00004517          	auipc	a0,0x4
ffffffffc0202ff2:	82a50513          	addi	a0,a0,-2006 # ffffffffc0206818 <etext+0xeea>
ffffffffc0202ff6:	c50fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202ffa:	00004697          	auipc	a3,0x4
ffffffffc0202ffe:	bb668693          	addi	a3,a3,-1098 # ffffffffc0206bb0 <etext+0x1282>
ffffffffc0203002:	00003617          	auipc	a2,0x3
ffffffffc0203006:	37660613          	addi	a2,a2,886 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020300a:	24700593          	li	a1,583
ffffffffc020300e:	00004517          	auipc	a0,0x4
ffffffffc0203012:	80a50513          	addi	a0,a0,-2038 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203016:	c30fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020301a:	00004697          	auipc	a3,0x4
ffffffffc020301e:	bc668693          	addi	a3,a3,-1082 # ffffffffc0206be0 <etext+0x12b2>
ffffffffc0203022:	00003617          	auipc	a2,0x3
ffffffffc0203026:	35660613          	addi	a2,a2,854 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020302a:	24600593          	li	a1,582
ffffffffc020302e:	00003517          	auipc	a0,0x3
ffffffffc0203032:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203036:	c10fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc020303a:	00004697          	auipc	a3,0x4
ffffffffc020303e:	c8e68693          	addi	a3,a3,-882 # ffffffffc0206cc8 <etext+0x139a>
ffffffffc0203042:	00003617          	auipc	a2,0x3
ffffffffc0203046:	33660613          	addi	a2,a2,822 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020304a:	26400593          	li	a1,612
ffffffffc020304e:	00003517          	auipc	a0,0x3
ffffffffc0203052:	7ca50513          	addi	a0,a0,1994 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203056:	bf0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020305a:	00004697          	auipc	a3,0x4
ffffffffc020305e:	bce68693          	addi	a3,a3,-1074 # ffffffffc0206c28 <etext+0x12fa>
ffffffffc0203062:	00003617          	auipc	a2,0x3
ffffffffc0203066:	31660613          	addi	a2,a2,790 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020306a:	25100593          	li	a1,593
ffffffffc020306e:	00003517          	auipc	a0,0x3
ffffffffc0203072:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203076:	bd0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020307a:	00004697          	auipc	a3,0x4
ffffffffc020307e:	ca668693          	addi	a3,a3,-858 # ffffffffc0206d20 <etext+0x13f2>
ffffffffc0203082:	00003617          	auipc	a2,0x3
ffffffffc0203086:	2f660613          	addi	a2,a2,758 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020308a:	26900593          	li	a1,617
ffffffffc020308e:	00003517          	auipc	a0,0x3
ffffffffc0203092:	78a50513          	addi	a0,a0,1930 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203096:	bb0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020309a:	00004697          	auipc	a3,0x4
ffffffffc020309e:	c4668693          	addi	a3,a3,-954 # ffffffffc0206ce0 <etext+0x13b2>
ffffffffc02030a2:	00003617          	auipc	a2,0x3
ffffffffc02030a6:	2d660613          	addi	a2,a2,726 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02030aa:	26800593          	li	a1,616
ffffffffc02030ae:	00003517          	auipc	a0,0x3
ffffffffc02030b2:	76a50513          	addi	a0,a0,1898 # ffffffffc0206818 <etext+0xeea>
ffffffffc02030b6:	b90fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030ba:	00004697          	auipc	a3,0x4
ffffffffc02030be:	af668693          	addi	a3,a3,-1290 # ffffffffc0206bb0 <etext+0x1282>
ffffffffc02030c2:	00003617          	auipc	a2,0x3
ffffffffc02030c6:	2b660613          	addi	a2,a2,694 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02030ca:	24300593          	li	a1,579
ffffffffc02030ce:	00003517          	auipc	a0,0x3
ffffffffc02030d2:	74a50513          	addi	a0,a0,1866 # ffffffffc0206818 <etext+0xeea>
ffffffffc02030d6:	b70fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02030da:	00004697          	auipc	a3,0x4
ffffffffc02030de:	97668693          	addi	a3,a3,-1674 # ffffffffc0206a50 <etext+0x1122>
ffffffffc02030e2:	00003617          	auipc	a2,0x3
ffffffffc02030e6:	29660613          	addi	a2,a2,662 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02030ea:	24200593          	li	a1,578
ffffffffc02030ee:	00003517          	auipc	a0,0x3
ffffffffc02030f2:	72a50513          	addi	a0,a0,1834 # ffffffffc0206818 <etext+0xeea>
ffffffffc02030f6:	b50fd0ef          	jal	ffffffffc0200446 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02030fa:	00004697          	auipc	a3,0x4
ffffffffc02030fe:	ace68693          	addi	a3,a3,-1330 # ffffffffc0206bc8 <etext+0x129a>
ffffffffc0203102:	00003617          	auipc	a2,0x3
ffffffffc0203106:	27660613          	addi	a2,a2,630 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020310a:	23f00593          	li	a1,575
ffffffffc020310e:	00003517          	auipc	a0,0x3
ffffffffc0203112:	70a50513          	addi	a0,a0,1802 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203116:	b30fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020311a:	00004697          	auipc	a3,0x4
ffffffffc020311e:	91e68693          	addi	a3,a3,-1762 # ffffffffc0206a38 <etext+0x110a>
ffffffffc0203122:	00003617          	auipc	a2,0x3
ffffffffc0203126:	25660613          	addi	a2,a2,598 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020312a:	23e00593          	li	a1,574
ffffffffc020312e:	00003517          	auipc	a0,0x3
ffffffffc0203132:	6ea50513          	addi	a0,a0,1770 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203136:	b10fd0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020313a:	00004697          	auipc	a3,0x4
ffffffffc020313e:	99e68693          	addi	a3,a3,-1634 # ffffffffc0206ad8 <etext+0x11aa>
ffffffffc0203142:	00003617          	auipc	a2,0x3
ffffffffc0203146:	23660613          	addi	a2,a2,566 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020314a:	23d00593          	li	a1,573
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	6ca50513          	addi	a0,a0,1738 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203156:	af0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020315a:	00004697          	auipc	a3,0x4
ffffffffc020315e:	a5668693          	addi	a3,a3,-1450 # ffffffffc0206bb0 <etext+0x1282>
ffffffffc0203162:	00003617          	auipc	a2,0x3
ffffffffc0203166:	21660613          	addi	a2,a2,534 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020316a:	23c00593          	li	a1,572
ffffffffc020316e:	00003517          	auipc	a0,0x3
ffffffffc0203172:	6aa50513          	addi	a0,a0,1706 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203176:	ad0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020317a:	00004697          	auipc	a3,0x4
ffffffffc020317e:	a1e68693          	addi	a3,a3,-1506 # ffffffffc0206b98 <etext+0x126a>
ffffffffc0203182:	00003617          	auipc	a2,0x3
ffffffffc0203186:	1f660613          	addi	a2,a2,502 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020318a:	23b00593          	li	a1,571
ffffffffc020318e:	00003517          	auipc	a0,0x3
ffffffffc0203192:	68a50513          	addi	a0,a0,1674 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203196:	ab0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc020319a:	00004697          	auipc	a3,0x4
ffffffffc020319e:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0206b68 <etext+0x123a>
ffffffffc02031a2:	00003617          	auipc	a2,0x3
ffffffffc02031a6:	1d660613          	addi	a2,a2,470 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02031aa:	23a00593          	li	a1,570
ffffffffc02031ae:	00003517          	auipc	a0,0x3
ffffffffc02031b2:	66a50513          	addi	a0,a0,1642 # ffffffffc0206818 <etext+0xeea>
ffffffffc02031b6:	a90fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02031ba:	00004697          	auipc	a3,0x4
ffffffffc02031be:	99668693          	addi	a3,a3,-1642 # ffffffffc0206b50 <etext+0x1222>
ffffffffc02031c2:	00003617          	auipc	a2,0x3
ffffffffc02031c6:	1b660613          	addi	a2,a2,438 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02031ca:	23800593          	li	a1,568
ffffffffc02031ce:	00003517          	auipc	a0,0x3
ffffffffc02031d2:	64a50513          	addi	a0,a0,1610 # ffffffffc0206818 <etext+0xeea>
ffffffffc02031d6:	a70fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02031da:	00004697          	auipc	a3,0x4
ffffffffc02031de:	95668693          	addi	a3,a3,-1706 # ffffffffc0206b30 <etext+0x1202>
ffffffffc02031e2:	00003617          	auipc	a2,0x3
ffffffffc02031e6:	19660613          	addi	a2,a2,406 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02031ea:	23700593          	li	a1,567
ffffffffc02031ee:	00003517          	auipc	a0,0x3
ffffffffc02031f2:	62a50513          	addi	a0,a0,1578 # ffffffffc0206818 <etext+0xeea>
ffffffffc02031f6:	a50fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02031fa:	00004697          	auipc	a3,0x4
ffffffffc02031fe:	92668693          	addi	a3,a3,-1754 # ffffffffc0206b20 <etext+0x11f2>
ffffffffc0203202:	00003617          	auipc	a2,0x3
ffffffffc0203206:	17660613          	addi	a2,a2,374 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020320a:	23600593          	li	a1,566
ffffffffc020320e:	00003517          	auipc	a0,0x3
ffffffffc0203212:	60a50513          	addi	a0,a0,1546 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203216:	a30fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020321a:	00004697          	auipc	a3,0x4
ffffffffc020321e:	8f668693          	addi	a3,a3,-1802 # ffffffffc0206b10 <etext+0x11e2>
ffffffffc0203222:	00003617          	auipc	a2,0x3
ffffffffc0203226:	15660613          	addi	a2,a2,342 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020322a:	23500593          	li	a1,565
ffffffffc020322e:	00003517          	auipc	a0,0x3
ffffffffc0203232:	5ea50513          	addi	a0,a0,1514 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203236:	a10fd0ef          	jal	ffffffffc0200446 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020323a:	00003617          	auipc	a2,0x3
ffffffffc020323e:	59660613          	addi	a2,a2,1430 # ffffffffc02067d0 <etext+0xea2>
ffffffffc0203242:	08100593          	li	a1,129
ffffffffc0203246:	00003517          	auipc	a0,0x3
ffffffffc020324a:	5d250513          	addi	a0,a0,1490 # ffffffffc0206818 <etext+0xeea>
ffffffffc020324e:	9f8fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203252:	00004697          	auipc	a3,0x4
ffffffffc0203256:	81668693          	addi	a3,a3,-2026 # ffffffffc0206a68 <etext+0x113a>
ffffffffc020325a:	00003617          	auipc	a2,0x3
ffffffffc020325e:	11e60613          	addi	a2,a2,286 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203262:	23000593          	li	a1,560
ffffffffc0203266:	00003517          	auipc	a0,0x3
ffffffffc020326a:	5b250513          	addi	a0,a0,1458 # ffffffffc0206818 <etext+0xeea>
ffffffffc020326e:	9d8fd0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203272:	00004697          	auipc	a3,0x4
ffffffffc0203276:	86668693          	addi	a3,a3,-1946 # ffffffffc0206ad8 <etext+0x11aa>
ffffffffc020327a:	00003617          	auipc	a2,0x3
ffffffffc020327e:	0fe60613          	addi	a2,a2,254 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203282:	23400593          	li	a1,564
ffffffffc0203286:	00003517          	auipc	a0,0x3
ffffffffc020328a:	59250513          	addi	a0,a0,1426 # ffffffffc0206818 <etext+0xeea>
ffffffffc020328e:	9b8fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203292:	00004697          	auipc	a3,0x4
ffffffffc0203296:	80668693          	addi	a3,a3,-2042 # ffffffffc0206a98 <etext+0x116a>
ffffffffc020329a:	00003617          	auipc	a2,0x3
ffffffffc020329e:	0de60613          	addi	a2,a2,222 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02032a2:	23300593          	li	a1,563
ffffffffc02032a6:	00003517          	auipc	a0,0x3
ffffffffc02032aa:	57250513          	addi	a0,a0,1394 # ffffffffc0206818 <etext+0xeea>
ffffffffc02032ae:	998fd0ef          	jal	ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032b2:	86d6                	mv	a3,s5
ffffffffc02032b4:	00003617          	auipc	a2,0x3
ffffffffc02032b8:	47460613          	addi	a2,a2,1140 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02032bc:	22f00593          	li	a1,559
ffffffffc02032c0:	00003517          	auipc	a0,0x3
ffffffffc02032c4:	55850513          	addi	a0,a0,1368 # ffffffffc0206818 <etext+0xeea>
ffffffffc02032c8:	97efd0ef          	jal	ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02032cc:	00003617          	auipc	a2,0x3
ffffffffc02032d0:	45c60613          	addi	a2,a2,1116 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02032d4:	22e00593          	li	a1,558
ffffffffc02032d8:	00003517          	auipc	a0,0x3
ffffffffc02032dc:	54050513          	addi	a0,a0,1344 # ffffffffc0206818 <etext+0xeea>
ffffffffc02032e0:	966fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02032e4:	00003697          	auipc	a3,0x3
ffffffffc02032e8:	76c68693          	addi	a3,a3,1900 # ffffffffc0206a50 <etext+0x1122>
ffffffffc02032ec:	00003617          	auipc	a2,0x3
ffffffffc02032f0:	08c60613          	addi	a2,a2,140 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02032f4:	22c00593          	li	a1,556
ffffffffc02032f8:	00003517          	auipc	a0,0x3
ffffffffc02032fc:	52050513          	addi	a0,a0,1312 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203300:	946fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203304:	00003697          	auipc	a3,0x3
ffffffffc0203308:	73468693          	addi	a3,a3,1844 # ffffffffc0206a38 <etext+0x110a>
ffffffffc020330c:	00003617          	auipc	a2,0x3
ffffffffc0203310:	06c60613          	addi	a2,a2,108 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203314:	22b00593          	li	a1,555
ffffffffc0203318:	00003517          	auipc	a0,0x3
ffffffffc020331c:	50050513          	addi	a0,a0,1280 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203320:	926fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203324:	00004697          	auipc	a3,0x4
ffffffffc0203328:	ac468693          	addi	a3,a3,-1340 # ffffffffc0206de8 <etext+0x14ba>
ffffffffc020332c:	00003617          	auipc	a2,0x3
ffffffffc0203330:	04c60613          	addi	a2,a2,76 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203334:	27200593          	li	a1,626
ffffffffc0203338:	00003517          	auipc	a0,0x3
ffffffffc020333c:	4e050513          	addi	a0,a0,1248 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203340:	906fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203344:	00004697          	auipc	a3,0x4
ffffffffc0203348:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0206db0 <etext+0x1482>
ffffffffc020334c:	00003617          	auipc	a2,0x3
ffffffffc0203350:	02c60613          	addi	a2,a2,44 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203354:	26f00593          	li	a1,623
ffffffffc0203358:	00003517          	auipc	a0,0x3
ffffffffc020335c:	4c050513          	addi	a0,a0,1216 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203360:	8e6fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203364:	00004697          	auipc	a3,0x4
ffffffffc0203368:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0206d80 <etext+0x1452>
ffffffffc020336c:	00003617          	auipc	a2,0x3
ffffffffc0203370:	00c60613          	addi	a2,a2,12 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203374:	26b00593          	li	a1,619
ffffffffc0203378:	00003517          	auipc	a0,0x3
ffffffffc020337c:	4a050513          	addi	a0,a0,1184 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203380:	8c6fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203384:	00004697          	auipc	a3,0x4
ffffffffc0203388:	9b468693          	addi	a3,a3,-1612 # ffffffffc0206d38 <etext+0x140a>
ffffffffc020338c:	00003617          	auipc	a2,0x3
ffffffffc0203390:	fec60613          	addi	a2,a2,-20 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203394:	26a00593          	li	a1,618
ffffffffc0203398:	00003517          	auipc	a0,0x3
ffffffffc020339c:	48050513          	addi	a0,a0,1152 # ffffffffc0206818 <etext+0xeea>
ffffffffc02033a0:	8a6fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02033a4:	00003697          	auipc	a3,0x3
ffffffffc02033a8:	5dc68693          	addi	a3,a3,1500 # ffffffffc0206980 <etext+0x1052>
ffffffffc02033ac:	00003617          	auipc	a2,0x3
ffffffffc02033b0:	fcc60613          	addi	a2,a2,-52 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02033b4:	22300593          	li	a1,547
ffffffffc02033b8:	00003517          	auipc	a0,0x3
ffffffffc02033bc:	46050513          	addi	a0,a0,1120 # ffffffffc0206818 <etext+0xeea>
ffffffffc02033c0:	886fd0ef          	jal	ffffffffc0200446 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02033c4:	00003617          	auipc	a2,0x3
ffffffffc02033c8:	40c60613          	addi	a2,a2,1036 # ffffffffc02067d0 <etext+0xea2>
ffffffffc02033cc:	0c900593          	li	a1,201
ffffffffc02033d0:	00003517          	auipc	a0,0x3
ffffffffc02033d4:	44850513          	addi	a0,a0,1096 # ffffffffc0206818 <etext+0xeea>
ffffffffc02033d8:	86efd0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02033dc:	00003697          	auipc	a3,0x3
ffffffffc02033e0:	60468693          	addi	a3,a3,1540 # ffffffffc02069e0 <etext+0x10b2>
ffffffffc02033e4:	00003617          	auipc	a2,0x3
ffffffffc02033e8:	f9460613          	addi	a2,a2,-108 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02033ec:	22a00593          	li	a1,554
ffffffffc02033f0:	00003517          	auipc	a0,0x3
ffffffffc02033f4:	42850513          	addi	a0,a0,1064 # ffffffffc0206818 <etext+0xeea>
ffffffffc02033f8:	84efd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02033fc:	00003697          	auipc	a3,0x3
ffffffffc0203400:	5b468693          	addi	a3,a3,1460 # ffffffffc02069b0 <etext+0x1082>
ffffffffc0203404:	00003617          	auipc	a2,0x3
ffffffffc0203408:	f7460613          	addi	a2,a2,-140 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020340c:	22700593          	li	a1,551
ffffffffc0203410:	00003517          	auipc	a0,0x3
ffffffffc0203414:	40850513          	addi	a0,a0,1032 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203418:	82efd0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020341c <copy_range>:
{
ffffffffc020341c:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020341e:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203422:	f486                	sd	ra,104(sp)
ffffffffc0203424:	f0a2                	sd	s0,96(sp)
ffffffffc0203426:	eca6                	sd	s1,88(sp)
ffffffffc0203428:	e8ca                	sd	s2,80(sp)
ffffffffc020342a:	e4ce                	sd	s3,72(sp)
ffffffffc020342c:	e0d2                	sd	s4,64(sp)
ffffffffc020342e:	fc56                	sd	s5,56(sp)
ffffffffc0203430:	f85a                	sd	s6,48(sp)
ffffffffc0203432:	f45e                	sd	s7,40(sp)
ffffffffc0203434:	f062                	sd	s8,32(sp)
ffffffffc0203436:	ec66                	sd	s9,24(sp)
ffffffffc0203438:	e86a                	sd	s10,16(sp)
ffffffffc020343a:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020343c:	03479713          	slli	a4,a5,0x34
ffffffffc0203440:	24071563          	bnez	a4,ffffffffc020368a <copy_range+0x26e>
    assert(USER_ACCESS(start, end));
ffffffffc0203444:	002007b7          	lui	a5,0x200
ffffffffc0203448:	00d63733          	sltu	a4,a2,a3
ffffffffc020344c:	00f637b3          	sltu	a5,a2,a5
ffffffffc0203450:	00173713          	seqz	a4,a4
ffffffffc0203454:	8fd9                	or	a5,a5,a4
ffffffffc0203456:	8432                	mv	s0,a2
ffffffffc0203458:	8936                	mv	s2,a3
ffffffffc020345a:	20079863          	bnez	a5,ffffffffc020366a <copy_range+0x24e>
ffffffffc020345e:	4785                	li	a5,1
ffffffffc0203460:	07fe                	slli	a5,a5,0x1f
ffffffffc0203462:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_exit_out_size+0x1f5df9>
ffffffffc0203464:	20f6f363          	bgeu	a3,a5,ffffffffc020366a <copy_range+0x24e>
ffffffffc0203468:	5b7d                	li	s6,-1
ffffffffc020346a:	8c2a                	mv	s8,a0
ffffffffc020346c:	8a2e                	mv	s4,a1
ffffffffc020346e:	6a85                	lui	s5,0x1
ffffffffc0203470:	00cb5b13          	srli	s6,s6,0xc
    if (PPN(pa) >= npage)
ffffffffc0203474:	00098d17          	auipc	s10,0x98
ffffffffc0203478:	6dcd0d13          	addi	s10,s10,1756 # ffffffffc029bb50 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020347c:	00098c97          	auipc	s9,0x98
ffffffffc0203480:	6dcc8c93          	addi	s9,s9,1756 # ffffffffc029bb58 <pages>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203484:	4601                	li	a2,0
ffffffffc0203486:	85a2                	mv	a1,s0
ffffffffc0203488:	8552                	mv	a0,s4
ffffffffc020348a:	b1dfe0ef          	jal	ffffffffc0201fa6 <get_pte>
ffffffffc020348e:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203490:	c96d                	beqz	a0,ffffffffc0203582 <copy_range+0x166>
        if (*ptep & PTE_V)
ffffffffc0203492:	611c                	ld	a5,0(a0)
ffffffffc0203494:	8b85                	andi	a5,a5,1
ffffffffc0203496:	e78d                	bnez	a5,ffffffffc02034c0 <copy_range+0xa4>
        start += PGSIZE;
ffffffffc0203498:	9456                	add	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020349a:	c019                	beqz	s0,ffffffffc02034a0 <copy_range+0x84>
ffffffffc020349c:	ff2464e3          	bltu	s0,s2,ffffffffc0203484 <copy_range+0x68>
    return 0;
ffffffffc02034a0:	4501                	li	a0,0
}
ffffffffc02034a2:	70a6                	ld	ra,104(sp)
ffffffffc02034a4:	7406                	ld	s0,96(sp)
ffffffffc02034a6:	64e6                	ld	s1,88(sp)
ffffffffc02034a8:	6946                	ld	s2,80(sp)
ffffffffc02034aa:	69a6                	ld	s3,72(sp)
ffffffffc02034ac:	6a06                	ld	s4,64(sp)
ffffffffc02034ae:	7ae2                	ld	s5,56(sp)
ffffffffc02034b0:	7b42                	ld	s6,48(sp)
ffffffffc02034b2:	7ba2                	ld	s7,40(sp)
ffffffffc02034b4:	7c02                	ld	s8,32(sp)
ffffffffc02034b6:	6ce2                	ld	s9,24(sp)
ffffffffc02034b8:	6d42                	ld	s10,16(sp)
ffffffffc02034ba:	6da2                	ld	s11,8(sp)
ffffffffc02034bc:	6165                	addi	sp,sp,112
ffffffffc02034be:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc02034c0:	4605                	li	a2,1
ffffffffc02034c2:	85a2                	mv	a1,s0
ffffffffc02034c4:	8562                	mv	a0,s8
ffffffffc02034c6:	ae1fe0ef          	jal	ffffffffc0201fa6 <get_pte>
ffffffffc02034ca:	c955                	beqz	a0,ffffffffc020357e <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02034cc:	0004b983          	ld	s3,0(s1)
    if (!(pte & PTE_V))
ffffffffc02034d0:	0019f793          	andi	a5,s3,1
ffffffffc02034d4:	16078263          	beqz	a5,ffffffffc0203638 <copy_range+0x21c>
    if (PPN(pa) >= npage)
ffffffffc02034d8:	000d3783          	ld	a5,0(s10)
    return pa2page(PTE_ADDR(pte));
ffffffffc02034dc:	00299713          	slli	a4,s3,0x2
ffffffffc02034e0:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02034e2:	12f77f63          	bgeu	a4,a5,ffffffffc0203620 <copy_range+0x204>
    return &pages[PPN(pa) - nbase];
ffffffffc02034e6:	000cb783          	ld	a5,0(s9)
ffffffffc02034ea:	fff806b7          	lui	a3,0xfff80
ffffffffc02034ee:	9736                	add	a4,a4,a3
ffffffffc02034f0:	071a                	slli	a4,a4,0x6
ffffffffc02034f2:	00e78db3          	add	s11,a5,a4
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02034f6:	10002773          	csrr	a4,sstatus
ffffffffc02034fa:	8b09                	andi	a4,a4,2
ffffffffc02034fc:	eb51                	bnez	a4,ffffffffc0203590 <copy_range+0x174>
        page = pmm_manager->alloc_pages(n);
ffffffffc02034fe:	00098b97          	auipc	s7,0x98
ffffffffc0203502:	632b8b93          	addi	s7,s7,1586 # ffffffffc029bb30 <pmm_manager>
ffffffffc0203506:	000bb703          	ld	a4,0(s7)
ffffffffc020350a:	4505                	li	a0,1
ffffffffc020350c:	6f18                	ld	a4,24(a4)
ffffffffc020350e:	9702                	jalr	a4
ffffffffc0203510:	84aa                	mv	s1,a0
            assert(page != NULL);
ffffffffc0203512:	0e0d8763          	beqz	s11,ffffffffc0203600 <copy_range+0x1e4>
            assert(npage != NULL);
ffffffffc0203516:	c4e9                	beqz	s1,ffffffffc02035e0 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc0203518:	000cb503          	ld	a0,0(s9)
ffffffffc020351c:	000806b7          	lui	a3,0x80
    return KADDR(page2pa(page));
ffffffffc0203520:	000d3703          	ld	a4,0(s10)
    return page - pages + nbase;
ffffffffc0203524:	40ad85b3          	sub	a1,s11,a0
ffffffffc0203528:	8599                	srai	a1,a1,0x6
ffffffffc020352a:	95b6                	add	a1,a1,a3
    return KADDR(page2pa(page));
ffffffffc020352c:	0165f7b3          	and	a5,a1,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203530:	05b2                	slli	a1,a1,0xc
    return KADDR(page2pa(page));
ffffffffc0203532:	10e7ff63          	bgeu	a5,a4,ffffffffc0203650 <copy_range+0x234>
    return page - pages + nbase;
ffffffffc0203536:	40a48533          	sub	a0,s1,a0
ffffffffc020353a:	8519                	srai	a0,a0,0x6
ffffffffc020353c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020353e:	016577b3          	and	a5,a0,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203542:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0203544:	08e7f163          	bgeu	a5,a4,ffffffffc02035c6 <copy_range+0x1aa>
ffffffffc0203548:	00098797          	auipc	a5,0x98
ffffffffc020354c:	6007b783          	ld	a5,1536(a5) # ffffffffc029bb48 <va_pa_offset>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE); 
ffffffffc0203550:	6605                	lui	a2,0x1
ffffffffc0203552:	95be                	add	a1,a1,a5
ffffffffc0203554:	953e                	add	a0,a0,a5
ffffffffc0203556:	3c0020ef          	jal	ffffffffc0205916 <memcpy>
            ret = page_insert(to, npage, start, perm); 
ffffffffc020355a:	01f9f693          	andi	a3,s3,31
ffffffffc020355e:	8622                	mv	a2,s0
ffffffffc0203560:	85a6                	mv	a1,s1
ffffffffc0203562:	8562                	mv	a0,s8
ffffffffc0203564:	978ff0ef          	jal	ffffffffc02026dc <page_insert>
            if (ret != 0)                              
ffffffffc0203568:	d905                	beqz	a0,ffffffffc0203498 <copy_range+0x7c>
ffffffffc020356a:	100027f3          	csrr	a5,sstatus
ffffffffc020356e:	8b89                	andi	a5,a5,2
ffffffffc0203570:	ef9d                	bnez	a5,ffffffffc02035ae <copy_range+0x192>
        pmm_manager->free_pages(base, n);
ffffffffc0203572:	000bb783          	ld	a5,0(s7)
ffffffffc0203576:	8526                	mv	a0,s1
ffffffffc0203578:	4585                	li	a1,1
ffffffffc020357a:	739c                	ld	a5,32(a5)
ffffffffc020357c:	9782                	jalr	a5
                return -E_NO_MEM;
ffffffffc020357e:	5571                	li	a0,-4
ffffffffc0203580:	b70d                	j	ffffffffc02034a2 <copy_range+0x86>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203582:	002007b7          	lui	a5,0x200
ffffffffc0203586:	97a2                	add	a5,a5,s0
ffffffffc0203588:	ffe00437          	lui	s0,0xffe00
ffffffffc020358c:	8c7d                	and	s0,s0,a5
            continue;
ffffffffc020358e:	b731                	j	ffffffffc020349a <copy_range+0x7e>
        intr_disable();
ffffffffc0203590:	b74fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203594:	00098b97          	auipc	s7,0x98
ffffffffc0203598:	59cb8b93          	addi	s7,s7,1436 # ffffffffc029bb30 <pmm_manager>
ffffffffc020359c:	000bb703          	ld	a4,0(s7)
ffffffffc02035a0:	4505                	li	a0,1
ffffffffc02035a2:	6f18                	ld	a4,24(a4)
ffffffffc02035a4:	9702                	jalr	a4
ffffffffc02035a6:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc02035a8:	b56fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02035ac:	b79d                	j	ffffffffc0203512 <copy_range+0xf6>
        intr_disable();
ffffffffc02035ae:	b56fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02035b2:	000bb783          	ld	a5,0(s7)
ffffffffc02035b6:	8526                	mv	a0,s1
ffffffffc02035b8:	4585                	li	a1,1
ffffffffc02035ba:	739c                	ld	a5,32(a5)
ffffffffc02035bc:	9782                	jalr	a5
        intr_enable();
ffffffffc02035be:	b40fd0ef          	jal	ffffffffc02008fe <intr_enable>
                return -E_NO_MEM;
ffffffffc02035c2:	5571                	li	a0,-4
ffffffffc02035c4:	bdf9                	j	ffffffffc02034a2 <copy_range+0x86>
ffffffffc02035c6:	86aa                	mv	a3,a0
ffffffffc02035c8:	00003617          	auipc	a2,0x3
ffffffffc02035cc:	16060613          	addi	a2,a2,352 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02035d0:	07100593          	li	a1,113
ffffffffc02035d4:	00003517          	auipc	a0,0x3
ffffffffc02035d8:	17c50513          	addi	a0,a0,380 # ffffffffc0206750 <etext+0xe22>
ffffffffc02035dc:	e6bfc0ef          	jal	ffffffffc0200446 <__panic>
            assert(npage != NULL);
ffffffffc02035e0:	00004697          	auipc	a3,0x4
ffffffffc02035e4:	86068693          	addi	a3,a3,-1952 # ffffffffc0206e40 <etext+0x1512>
ffffffffc02035e8:	00003617          	auipc	a2,0x3
ffffffffc02035ec:	d9060613          	addi	a2,a2,-624 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02035f0:	19500593          	li	a1,405
ffffffffc02035f4:	00003517          	auipc	a0,0x3
ffffffffc02035f8:	22450513          	addi	a0,a0,548 # ffffffffc0206818 <etext+0xeea>
ffffffffc02035fc:	e4bfc0ef          	jal	ffffffffc0200446 <__panic>
            assert(page != NULL);
ffffffffc0203600:	00004697          	auipc	a3,0x4
ffffffffc0203604:	83068693          	addi	a3,a3,-2000 # ffffffffc0206e30 <etext+0x1502>
ffffffffc0203608:	00003617          	auipc	a2,0x3
ffffffffc020360c:	d7060613          	addi	a2,a2,-656 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203610:	19400593          	li	a1,404
ffffffffc0203614:	00003517          	auipc	a0,0x3
ffffffffc0203618:	20450513          	addi	a0,a0,516 # ffffffffc0206818 <etext+0xeea>
ffffffffc020361c:	e2bfc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203620:	00003617          	auipc	a2,0x3
ffffffffc0203624:	1d860613          	addi	a2,a2,472 # ffffffffc02067f8 <etext+0xeca>
ffffffffc0203628:	06900593          	li	a1,105
ffffffffc020362c:	00003517          	auipc	a0,0x3
ffffffffc0203630:	12450513          	addi	a0,a0,292 # ffffffffc0206750 <etext+0xe22>
ffffffffc0203634:	e13fc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203638:	00003617          	auipc	a2,0x3
ffffffffc020363c:	3d860613          	addi	a2,a2,984 # ffffffffc0206a10 <etext+0x10e2>
ffffffffc0203640:	07f00593          	li	a1,127
ffffffffc0203644:	00003517          	auipc	a0,0x3
ffffffffc0203648:	10c50513          	addi	a0,a0,268 # ffffffffc0206750 <etext+0xe22>
ffffffffc020364c:	dfbfc0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203650:	86ae                	mv	a3,a1
ffffffffc0203652:	00003617          	auipc	a2,0x3
ffffffffc0203656:	0d660613          	addi	a2,a2,214 # ffffffffc0206728 <etext+0xdfa>
ffffffffc020365a:	07100593          	li	a1,113
ffffffffc020365e:	00003517          	auipc	a0,0x3
ffffffffc0203662:	0f250513          	addi	a0,a0,242 # ffffffffc0206750 <etext+0xe22>
ffffffffc0203666:	de1fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020366a:	00003697          	auipc	a3,0x3
ffffffffc020366e:	1ee68693          	addi	a3,a3,494 # ffffffffc0206858 <etext+0xf2a>
ffffffffc0203672:	00003617          	auipc	a2,0x3
ffffffffc0203676:	d0660613          	addi	a2,a2,-762 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020367a:	17c00593          	li	a1,380
ffffffffc020367e:	00003517          	auipc	a0,0x3
ffffffffc0203682:	19a50513          	addi	a0,a0,410 # ffffffffc0206818 <etext+0xeea>
ffffffffc0203686:	dc1fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020368a:	00003697          	auipc	a3,0x3
ffffffffc020368e:	19e68693          	addi	a3,a3,414 # ffffffffc0206828 <etext+0xefa>
ffffffffc0203692:	00003617          	auipc	a2,0x3
ffffffffc0203696:	ce660613          	addi	a2,a2,-794 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020369a:	17b00593          	li	a1,379
ffffffffc020369e:	00003517          	auipc	a0,0x3
ffffffffc02036a2:	17a50513          	addi	a0,a0,378 # ffffffffc0206818 <etext+0xeea>
ffffffffc02036a6:	da1fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02036aa <pgdir_alloc_page>:
{
ffffffffc02036aa:	7139                	addi	sp,sp,-64
ffffffffc02036ac:	f426                	sd	s1,40(sp)
ffffffffc02036ae:	f04a                	sd	s2,32(sp)
ffffffffc02036b0:	ec4e                	sd	s3,24(sp)
ffffffffc02036b2:	fc06                	sd	ra,56(sp)
ffffffffc02036b4:	f822                	sd	s0,48(sp)
ffffffffc02036b6:	892a                	mv	s2,a0
ffffffffc02036b8:	84ae                	mv	s1,a1
ffffffffc02036ba:	89b2                	mv	s3,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02036bc:	100027f3          	csrr	a5,sstatus
ffffffffc02036c0:	8b89                	andi	a5,a5,2
ffffffffc02036c2:	ebb5                	bnez	a5,ffffffffc0203736 <pgdir_alloc_page+0x8c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02036c4:	00098417          	auipc	s0,0x98
ffffffffc02036c8:	46c40413          	addi	s0,s0,1132 # ffffffffc029bb30 <pmm_manager>
ffffffffc02036cc:	601c                	ld	a5,0(s0)
ffffffffc02036ce:	4505                	li	a0,1
ffffffffc02036d0:	6f9c                	ld	a5,24(a5)
ffffffffc02036d2:	9782                	jalr	a5
ffffffffc02036d4:	85aa                	mv	a1,a0
    if (page != NULL)
ffffffffc02036d6:	c5b9                	beqz	a1,ffffffffc0203724 <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc02036d8:	86ce                	mv	a3,s3
ffffffffc02036da:	854a                	mv	a0,s2
ffffffffc02036dc:	8626                	mv	a2,s1
ffffffffc02036de:	e42e                	sd	a1,8(sp)
ffffffffc02036e0:	ffdfe0ef          	jal	ffffffffc02026dc <page_insert>
ffffffffc02036e4:	65a2                	ld	a1,8(sp)
ffffffffc02036e6:	e515                	bnez	a0,ffffffffc0203712 <pgdir_alloc_page+0x68>
        assert(page_ref(page) == 1);
ffffffffc02036e8:	4198                	lw	a4,0(a1)
        page->pra_vaddr = la;
ffffffffc02036ea:	fd84                	sd	s1,56(a1)
        assert(page_ref(page) == 1);
ffffffffc02036ec:	4785                	li	a5,1
ffffffffc02036ee:	02f70c63          	beq	a4,a5,ffffffffc0203726 <pgdir_alloc_page+0x7c>
ffffffffc02036f2:	00003697          	auipc	a3,0x3
ffffffffc02036f6:	75e68693          	addi	a3,a3,1886 # ffffffffc0206e50 <etext+0x1522>
ffffffffc02036fa:	00003617          	auipc	a2,0x3
ffffffffc02036fe:	c7e60613          	addi	a2,a2,-898 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203702:	20800593          	li	a1,520
ffffffffc0203706:	00003517          	auipc	a0,0x3
ffffffffc020370a:	11250513          	addi	a0,a0,274 # ffffffffc0206818 <etext+0xeea>
ffffffffc020370e:	d39fc0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0203712:	100027f3          	csrr	a5,sstatus
ffffffffc0203716:	8b89                	andi	a5,a5,2
ffffffffc0203718:	ef95                	bnez	a5,ffffffffc0203754 <pgdir_alloc_page+0xaa>
        pmm_manager->free_pages(base, n);
ffffffffc020371a:	601c                	ld	a5,0(s0)
ffffffffc020371c:	852e                	mv	a0,a1
ffffffffc020371e:	4585                	li	a1,1
ffffffffc0203720:	739c                	ld	a5,32(a5)
ffffffffc0203722:	9782                	jalr	a5
            return NULL;
ffffffffc0203724:	4581                	li	a1,0
}
ffffffffc0203726:	70e2                	ld	ra,56(sp)
ffffffffc0203728:	7442                	ld	s0,48(sp)
ffffffffc020372a:	74a2                	ld	s1,40(sp)
ffffffffc020372c:	7902                	ld	s2,32(sp)
ffffffffc020372e:	69e2                	ld	s3,24(sp)
ffffffffc0203730:	852e                	mv	a0,a1
ffffffffc0203732:	6121                	addi	sp,sp,64
ffffffffc0203734:	8082                	ret
        intr_disable();
ffffffffc0203736:	9cefd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020373a:	00098417          	auipc	s0,0x98
ffffffffc020373e:	3f640413          	addi	s0,s0,1014 # ffffffffc029bb30 <pmm_manager>
ffffffffc0203742:	601c                	ld	a5,0(s0)
ffffffffc0203744:	4505                	li	a0,1
ffffffffc0203746:	6f9c                	ld	a5,24(a5)
ffffffffc0203748:	9782                	jalr	a5
ffffffffc020374a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020374c:	9b2fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203750:	65a2                	ld	a1,8(sp)
ffffffffc0203752:	b751                	j	ffffffffc02036d6 <pgdir_alloc_page+0x2c>
        intr_disable();
ffffffffc0203754:	9b0fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203758:	601c                	ld	a5,0(s0)
ffffffffc020375a:	6522                	ld	a0,8(sp)
ffffffffc020375c:	4585                	li	a1,1
ffffffffc020375e:	739c                	ld	a5,32(a5)
ffffffffc0203760:	9782                	jalr	a5
        intr_enable();
ffffffffc0203762:	99cfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203766:	bf7d                	j	ffffffffc0203724 <pgdir_alloc_page+0x7a>

ffffffffc0203768 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203768:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020376a:	00003697          	auipc	a3,0x3
ffffffffc020376e:	6fe68693          	addi	a3,a3,1790 # ffffffffc0206e68 <etext+0x153a>
ffffffffc0203772:	00003617          	auipc	a2,0x3
ffffffffc0203776:	c0660613          	addi	a2,a2,-1018 # ffffffffc0206378 <etext+0xa4a>
ffffffffc020377a:	0a500593          	li	a1,165
ffffffffc020377e:	00003517          	auipc	a0,0x3
ffffffffc0203782:	70a50513          	addi	a0,a0,1802 # ffffffffc0206e88 <etext+0x155a>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203786:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203788:	cbffc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020378c <mm_create>:
{
ffffffffc020378c:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020378e:	04000513          	li	a0,64
{
ffffffffc0203792:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203794:	da8fe0ef          	jal	ffffffffc0201d3c <kmalloc>
    if (mm != NULL)
ffffffffc0203798:	cd19                	beqz	a0,ffffffffc02037b6 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc020379a:	e508                	sd	a0,8(a0)
ffffffffc020379c:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020379e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037a2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037a6:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02037aa:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc02037ae:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc02037b2:	02053c23          	sd	zero,56(a0)
}
ffffffffc02037b6:	60a2                	ld	ra,8(sp)
ffffffffc02037b8:	0141                	addi	sp,sp,16
ffffffffc02037ba:	8082                	ret

ffffffffc02037bc <find_vma>:
    if (mm != NULL)
ffffffffc02037bc:	c505                	beqz	a0,ffffffffc02037e4 <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc02037be:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02037c0:	c781                	beqz	a5,ffffffffc02037c8 <find_vma+0xc>
ffffffffc02037c2:	6798                	ld	a4,8(a5)
ffffffffc02037c4:	02e5f363          	bgeu	a1,a4,ffffffffc02037ea <find_vma+0x2e>
    return listelm->next;
ffffffffc02037c8:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc02037ca:	00f50d63          	beq	a0,a5,ffffffffc02037e4 <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc02037ce:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f5de0>
ffffffffc02037d2:	00e5e663          	bltu	a1,a4,ffffffffc02037de <find_vma+0x22>
ffffffffc02037d6:	ff07b703          	ld	a4,-16(a5)
ffffffffc02037da:	00e5ee63          	bltu	a1,a4,ffffffffc02037f6 <find_vma+0x3a>
ffffffffc02037de:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc02037e0:	fef517e3          	bne	a0,a5,ffffffffc02037ce <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc02037e4:	4781                	li	a5,0
}
ffffffffc02037e6:	853e                	mv	a0,a5
ffffffffc02037e8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02037ea:	6b98                	ld	a4,16(a5)
ffffffffc02037ec:	fce5fee3          	bgeu	a1,a4,ffffffffc02037c8 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02037f0:	e91c                	sd	a5,16(a0)
}
ffffffffc02037f2:	853e                	mv	a0,a5
ffffffffc02037f4:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02037f6:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc02037f8:	e91c                	sd	a5,16(a0)
ffffffffc02037fa:	bfe5                	j	ffffffffc02037f2 <find_vma+0x36>

ffffffffc02037fc <do_pgfault>:
    if (mm == NULL)
ffffffffc02037fc:	c961                	beqz	a0,ffffffffc02038cc <do_pgfault+0xd0>
{
ffffffffc02037fe:	7179                	addi	sp,sp,-48
    uintptr_t la = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203800:	77fd                	lui	a5,0xfffff
{
ffffffffc0203802:	f022                	sd	s0,32(sp)
    uintptr_t la = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203804:	00f67433          	and	s0,a2,a5
    struct vma_struct *vma = find_vma(mm, la);
ffffffffc0203808:	85a2                	mv	a1,s0
{
ffffffffc020380a:	ec26                	sd	s1,24(sp)
ffffffffc020380c:	f406                	sd	ra,40(sp)
ffffffffc020380e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, la);
ffffffffc0203810:	fadff0ef          	jal	ffffffffc02037bc <find_vma>
    if (vma == NULL || la < vma->vm_start)
ffffffffc0203814:	c55d                	beqz	a0,ffffffffc02038c2 <do_pgfault+0xc6>
ffffffffc0203816:	651c                	ld	a5,8(a0)
ffffffffc0203818:	0af46563          	bltu	s0,a5,ffffffffc02038c2 <do_pgfault+0xc6>
    if (vma->vm_flags & VM_READ)
ffffffffc020381c:	4d1c                	lw	a5,24(a0)
ffffffffc020381e:	e84a                	sd	s2,16(sp)
        perm |= PTE_R;
ffffffffc0203820:	494d                	li	s2,19
    if (vma->vm_flags & VM_READ)
ffffffffc0203822:	0017f713          	andi	a4,a5,1
ffffffffc0203826:	cb15                	beqz	a4,ffffffffc020385a <do_pgfault+0x5e>
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203828:	0027f713          	andi	a4,a5,2
ffffffffc020382c:	c311                	beqz	a4,ffffffffc0203830 <do_pgfault+0x34>
        perm |= (PTE_W | PTE_R);
ffffffffc020382e:	495d                	li	s2,23
    if (vma->vm_flags & VM_EXEC)
ffffffffc0203830:	8b91                	andi	a5,a5,4
ffffffffc0203832:	e38d                	bnez	a5,ffffffffc0203854 <do_pgfault+0x58>
    pte_t *ptep = get_pte(mm->pgdir, la, 1);
ffffffffc0203834:	6c88                	ld	a0,24(s1)
ffffffffc0203836:	4605                	li	a2,1
ffffffffc0203838:	85a2                	mv	a1,s0
ffffffffc020383a:	f6cfe0ef          	jal	ffffffffc0201fa6 <get_pte>
    if (ptep == NULL)
ffffffffc020383e:	c541                	beqz	a0,ffffffffc02038c6 <do_pgfault+0xca>
    if (*ptep & PTE_V)
ffffffffc0203840:	611c                	ld	a5,0(a0)
        return 0;
ffffffffc0203842:	4501                	li	a0,0
    if (*ptep & PTE_V)
ffffffffc0203844:	8b85                	andi	a5,a5,1
ffffffffc0203846:	cf99                	beqz	a5,ffffffffc0203864 <do_pgfault+0x68>
ffffffffc0203848:	6942                	ld	s2,16(sp)
}
ffffffffc020384a:	70a2                	ld	ra,40(sp)
ffffffffc020384c:	7402                	ld	s0,32(sp)
ffffffffc020384e:	64e2                	ld	s1,24(sp)
ffffffffc0203850:	6145                	addi	sp,sp,48
ffffffffc0203852:	8082                	ret
        perm |= PTE_X;
ffffffffc0203854:	00896913          	ori	s2,s2,8
ffffffffc0203858:	bff1                	j	ffffffffc0203834 <do_pgfault+0x38>
    if (vma->vm_flags & VM_WRITE)
ffffffffc020385a:	0027f713          	andi	a4,a5,2
    uint32_t perm = PTE_U | PTE_V;
ffffffffc020385e:	4945                	li	s2,17
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203860:	db61                	beqz	a4,ffffffffc0203830 <do_pgfault+0x34>
ffffffffc0203862:	b7f1                	j	ffffffffc020382e <do_pgfault+0x32>
    struct Page *page = alloc_page();
ffffffffc0203864:	4505                	li	a0,1
ffffffffc0203866:	e98fe0ef          	jal	ffffffffc0201efe <alloc_pages>
    if (page == NULL)
ffffffffc020386a:	cd31                	beqz	a0,ffffffffc02038c6 <do_pgfault+0xca>
    return page - pages + nbase;
ffffffffc020386c:	00098697          	auipc	a3,0x98
ffffffffc0203870:	2ec6b683          	ld	a3,748(a3) # ffffffffc029bb58 <pages>
ffffffffc0203874:	00004717          	auipc	a4,0x4
ffffffffc0203878:	25c73703          	ld	a4,604(a4) # ffffffffc0207ad0 <nbase>
    return KADDR(page2pa(page));
ffffffffc020387c:	00098617          	auipc	a2,0x98
ffffffffc0203880:	2d463603          	ld	a2,724(a2) # ffffffffc029bb50 <npage>
    return page - pages + nbase;
ffffffffc0203884:	40d506b3          	sub	a3,a0,a3
ffffffffc0203888:	8699                	srai	a3,a3,0x6
ffffffffc020388a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020388c:	00c69713          	slli	a4,a3,0xc
ffffffffc0203890:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203892:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203894:	02c77e63          	bgeu	a4,a2,ffffffffc02038d0 <do_pgfault+0xd4>
ffffffffc0203898:	e42a                	sd	a0,8(sp)
ffffffffc020389a:	00098517          	auipc	a0,0x98
ffffffffc020389e:	2ae53503          	ld	a0,686(a0) # ffffffffc029bb48 <va_pa_offset>
    memset(page2kva(page), 0, PGSIZE);
ffffffffc02038a2:	6605                	lui	a2,0x1
ffffffffc02038a4:	4581                	li	a1,0
ffffffffc02038a6:	9536                	add	a0,a0,a3
ffffffffc02038a8:	05c020ef          	jal	ffffffffc0205904 <memset>
    return page_insert(mm->pgdir, page, la, perm);
ffffffffc02038ac:	8622                	mv	a2,s0
}
ffffffffc02038ae:	7402                	ld	s0,32(sp)
    return page_insert(mm->pgdir, page, la, perm);
ffffffffc02038b0:	65a2                	ld	a1,8(sp)
ffffffffc02038b2:	6c88                	ld	a0,24(s1)
}
ffffffffc02038b4:	70a2                	ld	ra,40(sp)
ffffffffc02038b6:	64e2                	ld	s1,24(sp)
    return page_insert(mm->pgdir, page, la, perm);
ffffffffc02038b8:	86ca                	mv	a3,s2
ffffffffc02038ba:	6942                	ld	s2,16(sp)
}
ffffffffc02038bc:	6145                	addi	sp,sp,48
    return page_insert(mm->pgdir, page, la, perm);
ffffffffc02038be:	e1ffe06f          	j	ffffffffc02026dc <page_insert>
        return ret;
ffffffffc02038c2:	5575                	li	a0,-3
ffffffffc02038c4:	b759                	j	ffffffffc020384a <do_pgfault+0x4e>
ffffffffc02038c6:	6942                	ld	s2,16(sp)
        return -E_NO_MEM;
ffffffffc02038c8:	5571                	li	a0,-4
ffffffffc02038ca:	b741                	j	ffffffffc020384a <do_pgfault+0x4e>
        return ret;
ffffffffc02038cc:	5575                	li	a0,-3
}
ffffffffc02038ce:	8082                	ret
ffffffffc02038d0:	00003617          	auipc	a2,0x3
ffffffffc02038d4:	e5860613          	addi	a2,a2,-424 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02038d8:	07100593          	li	a1,113
ffffffffc02038dc:	00003517          	auipc	a0,0x3
ffffffffc02038e0:	e7450513          	addi	a0,a0,-396 # ffffffffc0206750 <etext+0xe22>
ffffffffc02038e4:	b63fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02038e8 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038e8:	6590                	ld	a2,8(a1)
ffffffffc02038ea:	0105b803          	ld	a6,16(a1)
{
ffffffffc02038ee:	1141                	addi	sp,sp,-16
ffffffffc02038f0:	e406                	sd	ra,8(sp)
ffffffffc02038f2:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038f4:	01066763          	bltu	a2,a6,ffffffffc0203902 <insert_vma_struct+0x1a>
ffffffffc02038f8:	a8b9                	j	ffffffffc0203956 <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02038fa:	fe87b703          	ld	a4,-24(a5) # ffffffffffffefe8 <end+0x3fd63468>
ffffffffc02038fe:	04e66763          	bltu	a2,a4,ffffffffc020394c <insert_vma_struct+0x64>
ffffffffc0203902:	86be                	mv	a3,a5
ffffffffc0203904:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0203906:	fef51ae3          	bne	a0,a5,ffffffffc02038fa <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020390a:	02a68463          	beq	a3,a0,ffffffffc0203932 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020390e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203912:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203916:	08e8f063          	bgeu	a7,a4,ffffffffc0203996 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020391a:	04e66e63          	bltu	a2,a4,ffffffffc0203976 <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc020391e:	00f50a63          	beq	a0,a5,ffffffffc0203932 <insert_vma_struct+0x4a>
ffffffffc0203922:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203926:	05076863          	bltu	a4,a6,ffffffffc0203976 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020392a:	ff07b603          	ld	a2,-16(a5)
ffffffffc020392e:	02c77263          	bgeu	a4,a2,ffffffffc0203952 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203932:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203934:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203936:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020393a:	e390                	sd	a2,0(a5)
ffffffffc020393c:	e690                	sd	a2,8(a3)
}
ffffffffc020393e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203940:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203942:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203944:	2705                	addiw	a4,a4,1
ffffffffc0203946:	d118                	sw	a4,32(a0)
}
ffffffffc0203948:	0141                	addi	sp,sp,16
ffffffffc020394a:	8082                	ret
    if (le_prev != list)
ffffffffc020394c:	fca691e3          	bne	a3,a0,ffffffffc020390e <insert_vma_struct+0x26>
ffffffffc0203950:	bfd9                	j	ffffffffc0203926 <insert_vma_struct+0x3e>
ffffffffc0203952:	e17ff0ef          	jal	ffffffffc0203768 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203956:	00003697          	auipc	a3,0x3
ffffffffc020395a:	54268693          	addi	a3,a3,1346 # ffffffffc0206e98 <etext+0x156a>
ffffffffc020395e:	00003617          	auipc	a2,0x3
ffffffffc0203962:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203966:	0ab00593          	li	a1,171
ffffffffc020396a:	00003517          	auipc	a0,0x3
ffffffffc020396e:	51e50513          	addi	a0,a0,1310 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203972:	ad5fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203976:	00003697          	auipc	a3,0x3
ffffffffc020397a:	56268693          	addi	a3,a3,1378 # ffffffffc0206ed8 <etext+0x15aa>
ffffffffc020397e:	00003617          	auipc	a2,0x3
ffffffffc0203982:	9fa60613          	addi	a2,a2,-1542 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203986:	0a400593          	li	a1,164
ffffffffc020398a:	00003517          	auipc	a0,0x3
ffffffffc020398e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203992:	ab5fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203996:	00003697          	auipc	a3,0x3
ffffffffc020399a:	52268693          	addi	a3,a3,1314 # ffffffffc0206eb8 <etext+0x158a>
ffffffffc020399e:	00003617          	auipc	a2,0x3
ffffffffc02039a2:	9da60613          	addi	a2,a2,-1574 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02039a6:	0a300593          	li	a1,163
ffffffffc02039aa:	00003517          	auipc	a0,0x3
ffffffffc02039ae:	4de50513          	addi	a0,a0,1246 # ffffffffc0206e88 <etext+0x155a>
ffffffffc02039b2:	a95fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02039b6 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc02039b6:	591c                	lw	a5,48(a0)
{
ffffffffc02039b8:	1141                	addi	sp,sp,-16
ffffffffc02039ba:	e406                	sd	ra,8(sp)
ffffffffc02039bc:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02039be:	e78d                	bnez	a5,ffffffffc02039e8 <mm_destroy+0x32>
ffffffffc02039c0:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02039c2:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc02039c4:	00a40c63          	beq	s0,a0,ffffffffc02039dc <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02039c8:	6118                	ld	a4,0(a0)
ffffffffc02039ca:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc02039cc:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02039ce:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02039d0:	e398                	sd	a4,0(a5)
ffffffffc02039d2:	c10fe0ef          	jal	ffffffffc0201de2 <kfree>
    return listelm->next;
ffffffffc02039d6:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02039d8:	fea418e3          	bne	s0,a0,ffffffffc02039c8 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc02039dc:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02039de:	6402                	ld	s0,0(sp)
ffffffffc02039e0:	60a2                	ld	ra,8(sp)
ffffffffc02039e2:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02039e4:	bfefe06f          	j	ffffffffc0201de2 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02039e8:	00003697          	auipc	a3,0x3
ffffffffc02039ec:	51068693          	addi	a3,a3,1296 # ffffffffc0206ef8 <etext+0x15ca>
ffffffffc02039f0:	00003617          	auipc	a2,0x3
ffffffffc02039f4:	98860613          	addi	a2,a2,-1656 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02039f8:	0cf00593          	li	a1,207
ffffffffc02039fc:	00003517          	auipc	a0,0x3
ffffffffc0203a00:	48c50513          	addi	a0,a0,1164 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203a04:	a43fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203a08 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203a08:	6785                	lui	a5,0x1
ffffffffc0203a0a:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7c11>
ffffffffc0203a0c:	963e                	add	a2,a2,a5
    if (!USER_ACCESS(start, end))
ffffffffc0203a0e:	4785                	li	a5,1
{
ffffffffc0203a10:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203a12:	962e                	add	a2,a2,a1
ffffffffc0203a14:	787d                	lui	a6,0xfffff
    if (!USER_ACCESS(start, end))
ffffffffc0203a16:	07fe                	slli	a5,a5,0x1f
{
ffffffffc0203a18:	f822                	sd	s0,48(sp)
ffffffffc0203a1a:	f426                	sd	s1,40(sp)
ffffffffc0203a1c:	01067433          	and	s0,a2,a6
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203a20:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc0203a24:	0785                	addi	a5,a5,1
ffffffffc0203a26:	0084b633          	sltu	a2,s1,s0
ffffffffc0203a2a:	00f437b3          	sltu	a5,s0,a5
ffffffffc0203a2e:	00163613          	seqz	a2,a2
ffffffffc0203a32:	0017b793          	seqz	a5,a5
{
ffffffffc0203a36:	fc06                	sd	ra,56(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0203a38:	8fd1                	or	a5,a5,a2
ffffffffc0203a3a:	ebbd                	bnez	a5,ffffffffc0203ab0 <mm_map+0xa8>
ffffffffc0203a3c:	002007b7          	lui	a5,0x200
ffffffffc0203a40:	06f4e863          	bltu	s1,a5,ffffffffc0203ab0 <mm_map+0xa8>
ffffffffc0203a44:	f04a                	sd	s2,32(sp)
ffffffffc0203a46:	ec4e                	sd	s3,24(sp)
ffffffffc0203a48:	e852                	sd	s4,16(sp)
ffffffffc0203a4a:	892a                	mv	s2,a0
ffffffffc0203a4c:	89ba                	mv	s3,a4
ffffffffc0203a4e:	8a36                	mv	s4,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203a50:	c135                	beqz	a0,ffffffffc0203ab4 <mm_map+0xac>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203a52:	85a6                	mv	a1,s1
ffffffffc0203a54:	d69ff0ef          	jal	ffffffffc02037bc <find_vma>
ffffffffc0203a58:	c501                	beqz	a0,ffffffffc0203a60 <mm_map+0x58>
ffffffffc0203a5a:	651c                	ld	a5,8(a0)
ffffffffc0203a5c:	0487e763          	bltu	a5,s0,ffffffffc0203aaa <mm_map+0xa2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a60:	03000513          	li	a0,48
ffffffffc0203a64:	ad8fe0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0203a68:	85aa                	mv	a1,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0203a6a:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0203a6c:	c59d                	beqz	a1,ffffffffc0203a9a <mm_map+0x92>
        vma->vm_start = vm_start;
ffffffffc0203a6e:	e584                	sd	s1,8(a1)
        vma->vm_end = vm_end;
ffffffffc0203a70:	e980                	sd	s0,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203a72:	0145ac23          	sw	s4,24(a1)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0203a76:	854a                	mv	a0,s2
ffffffffc0203a78:	e42e                	sd	a1,8(sp)
ffffffffc0203a7a:	e6fff0ef          	jal	ffffffffc02038e8 <insert_vma_struct>
    if (vma_store != NULL)
ffffffffc0203a7e:	65a2                	ld	a1,8(sp)
ffffffffc0203a80:	00098463          	beqz	s3,ffffffffc0203a88 <mm_map+0x80>
    {
        *vma_store = vma;
ffffffffc0203a84:	00b9b023          	sd	a1,0(s3)
ffffffffc0203a88:	7902                	ld	s2,32(sp)
ffffffffc0203a8a:	69e2                	ld	s3,24(sp)
ffffffffc0203a8c:	6a42                	ld	s4,16(sp)
    }
    ret = 0;
ffffffffc0203a8e:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc0203a90:	70e2                	ld	ra,56(sp)
ffffffffc0203a92:	7442                	ld	s0,48(sp)
ffffffffc0203a94:	74a2                	ld	s1,40(sp)
ffffffffc0203a96:	6121                	addi	sp,sp,64
ffffffffc0203a98:	8082                	ret
ffffffffc0203a9a:	70e2                	ld	ra,56(sp)
ffffffffc0203a9c:	7442                	ld	s0,48(sp)
ffffffffc0203a9e:	7902                	ld	s2,32(sp)
ffffffffc0203aa0:	69e2                	ld	s3,24(sp)
ffffffffc0203aa2:	6a42                	ld	s4,16(sp)
ffffffffc0203aa4:	74a2                	ld	s1,40(sp)
ffffffffc0203aa6:	6121                	addi	sp,sp,64
ffffffffc0203aa8:	8082                	ret
ffffffffc0203aaa:	7902                	ld	s2,32(sp)
ffffffffc0203aac:	69e2                	ld	s3,24(sp)
ffffffffc0203aae:	6a42                	ld	s4,16(sp)
        return -E_INVAL;
ffffffffc0203ab0:	5575                	li	a0,-3
ffffffffc0203ab2:	bff9                	j	ffffffffc0203a90 <mm_map+0x88>
    assert(mm != NULL);
ffffffffc0203ab4:	00003697          	auipc	a3,0x3
ffffffffc0203ab8:	45c68693          	addi	a3,a3,1116 # ffffffffc0206f10 <etext+0x15e2>
ffffffffc0203abc:	00003617          	auipc	a2,0x3
ffffffffc0203ac0:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203ac4:	0e400593          	li	a1,228
ffffffffc0203ac8:	00003517          	auipc	a0,0x3
ffffffffc0203acc:	3c050513          	addi	a0,a0,960 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203ad0:	977fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203ad4 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203ad4:	7139                	addi	sp,sp,-64
ffffffffc0203ad6:	fc06                	sd	ra,56(sp)
ffffffffc0203ad8:	f822                	sd	s0,48(sp)
ffffffffc0203ada:	f426                	sd	s1,40(sp)
ffffffffc0203adc:	f04a                	sd	s2,32(sp)
ffffffffc0203ade:	ec4e                	sd	s3,24(sp)
ffffffffc0203ae0:	e852                	sd	s4,16(sp)
ffffffffc0203ae2:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203ae4:	c525                	beqz	a0,ffffffffc0203b4c <dup_mmap+0x78>
ffffffffc0203ae6:	892a                	mv	s2,a0
ffffffffc0203ae8:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203aea:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203aec:	c1a5                	beqz	a1,ffffffffc0203b4c <dup_mmap+0x78>
    return listelm->prev;
ffffffffc0203aee:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203af0:	04848c63          	beq	s1,s0,ffffffffc0203b48 <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203af4:	03000513          	li	a0,48
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203af8:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203afc:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203b00:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b04:	a38fe0ef          	jal	ffffffffc0201d3c <kmalloc>
    if (vma != NULL)
ffffffffc0203b08:	c515                	beqz	a0,ffffffffc0203b34 <dup_mmap+0x60>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203b0a:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0203b0c:	01553423          	sd	s5,8(a0)
ffffffffc0203b10:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b14:	01352c23          	sw	s3,24(a0)
        insert_vma_struct(to, nvma);
ffffffffc0203b18:	854a                	mv	a0,s2
ffffffffc0203b1a:	dcfff0ef          	jal	ffffffffc02038e8 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203b1e:	ff043683          	ld	a3,-16(s0)
ffffffffc0203b22:	fe843603          	ld	a2,-24(s0)
ffffffffc0203b26:	6c8c                	ld	a1,24(s1)
ffffffffc0203b28:	01893503          	ld	a0,24(s2)
ffffffffc0203b2c:	4701                	li	a4,0
ffffffffc0203b2e:	8efff0ef          	jal	ffffffffc020341c <copy_range>
ffffffffc0203b32:	dd55                	beqz	a0,ffffffffc0203aee <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0203b34:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203b36:	70e2                	ld	ra,56(sp)
ffffffffc0203b38:	7442                	ld	s0,48(sp)
ffffffffc0203b3a:	74a2                	ld	s1,40(sp)
ffffffffc0203b3c:	7902                	ld	s2,32(sp)
ffffffffc0203b3e:	69e2                	ld	s3,24(sp)
ffffffffc0203b40:	6a42                	ld	s4,16(sp)
ffffffffc0203b42:	6aa2                	ld	s5,8(sp)
ffffffffc0203b44:	6121                	addi	sp,sp,64
ffffffffc0203b46:	8082                	ret
    return 0;
ffffffffc0203b48:	4501                	li	a0,0
ffffffffc0203b4a:	b7f5                	j	ffffffffc0203b36 <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc0203b4c:	00003697          	auipc	a3,0x3
ffffffffc0203b50:	3d468693          	addi	a3,a3,980 # ffffffffc0206f20 <etext+0x15f2>
ffffffffc0203b54:	00003617          	auipc	a2,0x3
ffffffffc0203b58:	82460613          	addi	a2,a2,-2012 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203b5c:	10000593          	li	a1,256
ffffffffc0203b60:	00003517          	auipc	a0,0x3
ffffffffc0203b64:	32850513          	addi	a0,a0,808 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203b68:	8dffc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203b6c <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203b6c:	1101                	addi	sp,sp,-32
ffffffffc0203b6e:	ec06                	sd	ra,24(sp)
ffffffffc0203b70:	e822                	sd	s0,16(sp)
ffffffffc0203b72:	e426                	sd	s1,8(sp)
ffffffffc0203b74:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203b76:	c531                	beqz	a0,ffffffffc0203bc2 <exit_mmap+0x56>
ffffffffc0203b78:	591c                	lw	a5,48(a0)
ffffffffc0203b7a:	84aa                	mv	s1,a0
ffffffffc0203b7c:	e3b9                	bnez	a5,ffffffffc0203bc2 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203b7e:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203b80:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203b84:	02850663          	beq	a0,s0,ffffffffc0203bb0 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203b88:	ff043603          	ld	a2,-16(s0)
ffffffffc0203b8c:	fe843583          	ld	a1,-24(s0)
ffffffffc0203b90:	854a                	mv	a0,s2
ffffffffc0203b92:	ec6fe0ef          	jal	ffffffffc0202258 <unmap_range>
ffffffffc0203b96:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203b98:	fe8498e3          	bne	s1,s0,ffffffffc0203b88 <exit_mmap+0x1c>
ffffffffc0203b9c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203b9e:	00848c63          	beq	s1,s0,ffffffffc0203bb6 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203ba2:	ff043603          	ld	a2,-16(s0)
ffffffffc0203ba6:	fe843583          	ld	a1,-24(s0)
ffffffffc0203baa:	854a                	mv	a0,s2
ffffffffc0203bac:	fe0fe0ef          	jal	ffffffffc020238c <exit_range>
ffffffffc0203bb0:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203bb2:	fe8498e3          	bne	s1,s0,ffffffffc0203ba2 <exit_mmap+0x36>
    }
}
ffffffffc0203bb6:	60e2                	ld	ra,24(sp)
ffffffffc0203bb8:	6442                	ld	s0,16(sp)
ffffffffc0203bba:	64a2                	ld	s1,8(sp)
ffffffffc0203bbc:	6902                	ld	s2,0(sp)
ffffffffc0203bbe:	6105                	addi	sp,sp,32
ffffffffc0203bc0:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203bc2:	00003697          	auipc	a3,0x3
ffffffffc0203bc6:	37e68693          	addi	a3,a3,894 # ffffffffc0206f40 <etext+0x1612>
ffffffffc0203bca:	00002617          	auipc	a2,0x2
ffffffffc0203bce:	7ae60613          	addi	a2,a2,1966 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203bd2:	11900593          	li	a1,281
ffffffffc0203bd6:	00003517          	auipc	a0,0x3
ffffffffc0203bda:	2b250513          	addi	a0,a0,690 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203bde:	869fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203be2 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203be2:	7179                	addi	sp,sp,-48
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203be4:	04000513          	li	a0,64
{
ffffffffc0203be8:	f406                	sd	ra,40(sp)
ffffffffc0203bea:	f022                	sd	s0,32(sp)
ffffffffc0203bec:	ec26                	sd	s1,24(sp)
ffffffffc0203bee:	e84a                	sd	s2,16(sp)
ffffffffc0203bf0:	e44e                	sd	s3,8(sp)
ffffffffc0203bf2:	e052                	sd	s4,0(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203bf4:	948fe0ef          	jal	ffffffffc0201d3c <kmalloc>
    if (mm != NULL)
ffffffffc0203bf8:	16050c63          	beqz	a0,ffffffffc0203d70 <vmm_init+0x18e>
ffffffffc0203bfc:	842a                	mv	s0,a0
    elm->prev = elm->next = elm;
ffffffffc0203bfe:	e508                	sd	a0,8(a0)
ffffffffc0203c00:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203c02:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203c06:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203c0a:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203c0e:	02053423          	sd	zero,40(a0)
ffffffffc0203c12:	02052823          	sw	zero,48(a0)
ffffffffc0203c16:	02053c23          	sd	zero,56(a0)
ffffffffc0203c1a:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c1e:	03000513          	li	a0,48
ffffffffc0203c22:	91afe0ef          	jal	ffffffffc0201d3c <kmalloc>
    if (vma != NULL)
ffffffffc0203c26:	12050563          	beqz	a0,ffffffffc0203d50 <vmm_init+0x16e>
        vma->vm_end = vm_end;
ffffffffc0203c2a:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203c2e:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203c30:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203c34:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203c36:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0203c38:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc0203c3a:	8522                	mv	a0,s0
ffffffffc0203c3c:	cadff0ef          	jal	ffffffffc02038e8 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203c40:	fcf9                	bnez	s1,ffffffffc0203c1e <vmm_init+0x3c>
ffffffffc0203c42:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c46:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c4a:	03000513          	li	a0,48
ffffffffc0203c4e:	8eefe0ef          	jal	ffffffffc0201d3c <kmalloc>
    if (vma != NULL)
ffffffffc0203c52:	12050f63          	beqz	a0,ffffffffc0203d90 <vmm_init+0x1ae>
        vma->vm_end = vm_end;
ffffffffc0203c56:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203c5a:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203c5c:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203c60:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203c62:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c64:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc0203c66:	8522                	mv	a0,s0
ffffffffc0203c68:	c81ff0ef          	jal	ffffffffc02038e8 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203c6c:	fd249fe3          	bne	s1,s2,ffffffffc0203c4a <vmm_init+0x68>
    return listelm->next;
ffffffffc0203c70:	641c                	ld	a5,8(s0)
ffffffffc0203c72:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203c74:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203c78:	1ef40c63          	beq	s0,a5,ffffffffc0203e70 <vmm_init+0x28e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c7c:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f5de0>
ffffffffc0203c80:	ffe70693          	addi	a3,a4,-2
ffffffffc0203c84:	12d61663          	bne	a2,a3,ffffffffc0203db0 <vmm_init+0x1ce>
ffffffffc0203c88:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203c8c:	12e69263          	bne	a3,a4,ffffffffc0203db0 <vmm_init+0x1ce>
    for (i = 1; i <= step2; i++)
ffffffffc0203c90:	0715                	addi	a4,a4,5
ffffffffc0203c92:	679c                	ld	a5,8(a5)
ffffffffc0203c94:	feb712e3          	bne	a4,a1,ffffffffc0203c78 <vmm_init+0x96>
ffffffffc0203c98:	491d                	li	s2,7
ffffffffc0203c9a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203c9c:	85a6                	mv	a1,s1
ffffffffc0203c9e:	8522                	mv	a0,s0
ffffffffc0203ca0:	b1dff0ef          	jal	ffffffffc02037bc <find_vma>
ffffffffc0203ca4:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203ca6:	20050563          	beqz	a0,ffffffffc0203eb0 <vmm_init+0x2ce>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203caa:	00148593          	addi	a1,s1,1
ffffffffc0203cae:	8522                	mv	a0,s0
ffffffffc0203cb0:	b0dff0ef          	jal	ffffffffc02037bc <find_vma>
ffffffffc0203cb4:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203cb6:	1c050d63          	beqz	a0,ffffffffc0203e90 <vmm_init+0x2ae>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203cba:	85ca                	mv	a1,s2
ffffffffc0203cbc:	8522                	mv	a0,s0
ffffffffc0203cbe:	affff0ef          	jal	ffffffffc02037bc <find_vma>
        assert(vma3 == NULL);
ffffffffc0203cc2:	18051763          	bnez	a0,ffffffffc0203e50 <vmm_init+0x26e>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203cc6:	00348593          	addi	a1,s1,3
ffffffffc0203cca:	8522                	mv	a0,s0
ffffffffc0203ccc:	af1ff0ef          	jal	ffffffffc02037bc <find_vma>
        assert(vma4 == NULL);
ffffffffc0203cd0:	16051063          	bnez	a0,ffffffffc0203e30 <vmm_init+0x24e>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203cd4:	00448593          	addi	a1,s1,4
ffffffffc0203cd8:	8522                	mv	a0,s0
ffffffffc0203cda:	ae3ff0ef          	jal	ffffffffc02037bc <find_vma>
        assert(vma5 == NULL);
ffffffffc0203cde:	12051963          	bnez	a0,ffffffffc0203e10 <vmm_init+0x22e>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203ce2:	008a3783          	ld	a5,8(s4)
ffffffffc0203ce6:	10979563          	bne	a5,s1,ffffffffc0203df0 <vmm_init+0x20e>
ffffffffc0203cea:	010a3783          	ld	a5,16(s4)
ffffffffc0203cee:	11279163          	bne	a5,s2,ffffffffc0203df0 <vmm_init+0x20e>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203cf2:	0089b783          	ld	a5,8(s3)
ffffffffc0203cf6:	0c979d63          	bne	a5,s1,ffffffffc0203dd0 <vmm_init+0x1ee>
ffffffffc0203cfa:	0109b783          	ld	a5,16(s3)
ffffffffc0203cfe:	0d279963          	bne	a5,s2,ffffffffc0203dd0 <vmm_init+0x1ee>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203d02:	0495                	addi	s1,s1,5
ffffffffc0203d04:	1f900793          	li	a5,505
ffffffffc0203d08:	0915                	addi	s2,s2,5
ffffffffc0203d0a:	f8f499e3          	bne	s1,a5,ffffffffc0203c9c <vmm_init+0xba>
ffffffffc0203d0e:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203d10:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203d12:	85a6                	mv	a1,s1
ffffffffc0203d14:	8522                	mv	a0,s0
ffffffffc0203d16:	aa7ff0ef          	jal	ffffffffc02037bc <find_vma>
        if (vma_below_5 != NULL)
ffffffffc0203d1a:	1a051b63          	bnez	a0,ffffffffc0203ed0 <vmm_init+0x2ee>
    for (i = 4; i >= 0; i--)
ffffffffc0203d1e:	14fd                	addi	s1,s1,-1
ffffffffc0203d20:	ff2499e3          	bne	s1,s2,ffffffffc0203d12 <vmm_init+0x130>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc0203d24:	8522                	mv	a0,s0
ffffffffc0203d26:	c91ff0ef          	jal	ffffffffc02039b6 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203d2a:	00003517          	auipc	a0,0x3
ffffffffc0203d2e:	38650513          	addi	a0,a0,902 # ffffffffc02070b0 <etext+0x1782>
ffffffffc0203d32:	c62fc0ef          	jal	ffffffffc0200194 <cprintf>
}
ffffffffc0203d36:	7402                	ld	s0,32(sp)
ffffffffc0203d38:	70a2                	ld	ra,40(sp)
ffffffffc0203d3a:	64e2                	ld	s1,24(sp)
ffffffffc0203d3c:	6942                	ld	s2,16(sp)
ffffffffc0203d3e:	69a2                	ld	s3,8(sp)
ffffffffc0203d40:	6a02                	ld	s4,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d42:	00003517          	auipc	a0,0x3
ffffffffc0203d46:	38e50513          	addi	a0,a0,910 # ffffffffc02070d0 <etext+0x17a2>
}
ffffffffc0203d4a:	6145                	addi	sp,sp,48
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d4c:	c48fc06f          	j	ffffffffc0200194 <cprintf>
        assert(vma != NULL);
ffffffffc0203d50:	00003697          	auipc	a3,0x3
ffffffffc0203d54:	21068693          	addi	a3,a3,528 # ffffffffc0206f60 <etext+0x1632>
ffffffffc0203d58:	00002617          	auipc	a2,0x2
ffffffffc0203d5c:	62060613          	addi	a2,a2,1568 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203d60:	15d00593          	li	a1,349
ffffffffc0203d64:	00003517          	auipc	a0,0x3
ffffffffc0203d68:	12450513          	addi	a0,a0,292 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203d6c:	edafc0ef          	jal	ffffffffc0200446 <__panic>
    assert(mm != NULL);
ffffffffc0203d70:	00003697          	auipc	a3,0x3
ffffffffc0203d74:	1a068693          	addi	a3,a3,416 # ffffffffc0206f10 <etext+0x15e2>
ffffffffc0203d78:	00002617          	auipc	a2,0x2
ffffffffc0203d7c:	60060613          	addi	a2,a2,1536 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203d80:	15500593          	li	a1,341
ffffffffc0203d84:	00003517          	auipc	a0,0x3
ffffffffc0203d88:	10450513          	addi	a0,a0,260 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203d8c:	ebafc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma != NULL);
ffffffffc0203d90:	00003697          	auipc	a3,0x3
ffffffffc0203d94:	1d068693          	addi	a3,a3,464 # ffffffffc0206f60 <etext+0x1632>
ffffffffc0203d98:	00002617          	auipc	a2,0x2
ffffffffc0203d9c:	5e060613          	addi	a2,a2,1504 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203da0:	16400593          	li	a1,356
ffffffffc0203da4:	00003517          	auipc	a0,0x3
ffffffffc0203da8:	0e450513          	addi	a0,a0,228 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203dac:	e9afc0ef          	jal	ffffffffc0200446 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203db0:	00003697          	auipc	a3,0x3
ffffffffc0203db4:	1d868693          	addi	a3,a3,472 # ffffffffc0206f88 <etext+0x165a>
ffffffffc0203db8:	00002617          	auipc	a2,0x2
ffffffffc0203dbc:	5c060613          	addi	a2,a2,1472 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203dc0:	16e00593          	li	a1,366
ffffffffc0203dc4:	00003517          	auipc	a0,0x3
ffffffffc0203dc8:	0c450513          	addi	a0,a0,196 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203dcc:	e7afc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203dd0:	00003697          	auipc	a3,0x3
ffffffffc0203dd4:	27068693          	addi	a3,a3,624 # ffffffffc0207040 <etext+0x1712>
ffffffffc0203dd8:	00002617          	auipc	a2,0x2
ffffffffc0203ddc:	5a060613          	addi	a2,a2,1440 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203de0:	18000593          	li	a1,384
ffffffffc0203de4:	00003517          	auipc	a0,0x3
ffffffffc0203de8:	0a450513          	addi	a0,a0,164 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203dec:	e5afc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203df0:	00003697          	auipc	a3,0x3
ffffffffc0203df4:	22068693          	addi	a3,a3,544 # ffffffffc0207010 <etext+0x16e2>
ffffffffc0203df8:	00002617          	auipc	a2,0x2
ffffffffc0203dfc:	58060613          	addi	a2,a2,1408 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203e00:	17f00593          	li	a1,383
ffffffffc0203e04:	00003517          	auipc	a0,0x3
ffffffffc0203e08:	08450513          	addi	a0,a0,132 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203e0c:	e3afc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma5 == NULL);
ffffffffc0203e10:	00003697          	auipc	a3,0x3
ffffffffc0203e14:	1f068693          	addi	a3,a3,496 # ffffffffc0207000 <etext+0x16d2>
ffffffffc0203e18:	00002617          	auipc	a2,0x2
ffffffffc0203e1c:	56060613          	addi	a2,a2,1376 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203e20:	17d00593          	li	a1,381
ffffffffc0203e24:	00003517          	auipc	a0,0x3
ffffffffc0203e28:	06450513          	addi	a0,a0,100 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203e2c:	e1afc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma4 == NULL);
ffffffffc0203e30:	00003697          	auipc	a3,0x3
ffffffffc0203e34:	1c068693          	addi	a3,a3,448 # ffffffffc0206ff0 <etext+0x16c2>
ffffffffc0203e38:	00002617          	auipc	a2,0x2
ffffffffc0203e3c:	54060613          	addi	a2,a2,1344 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203e40:	17b00593          	li	a1,379
ffffffffc0203e44:	00003517          	auipc	a0,0x3
ffffffffc0203e48:	04450513          	addi	a0,a0,68 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203e4c:	dfafc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma3 == NULL);
ffffffffc0203e50:	00003697          	auipc	a3,0x3
ffffffffc0203e54:	19068693          	addi	a3,a3,400 # ffffffffc0206fe0 <etext+0x16b2>
ffffffffc0203e58:	00002617          	auipc	a2,0x2
ffffffffc0203e5c:	52060613          	addi	a2,a2,1312 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203e60:	17900593          	li	a1,377
ffffffffc0203e64:	00003517          	auipc	a0,0x3
ffffffffc0203e68:	02450513          	addi	a0,a0,36 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203e6c:	ddafc0ef          	jal	ffffffffc0200446 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203e70:	00003697          	auipc	a3,0x3
ffffffffc0203e74:	10068693          	addi	a3,a3,256 # ffffffffc0206f70 <etext+0x1642>
ffffffffc0203e78:	00002617          	auipc	a2,0x2
ffffffffc0203e7c:	50060613          	addi	a2,a2,1280 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203e80:	16c00593          	li	a1,364
ffffffffc0203e84:	00003517          	auipc	a0,0x3
ffffffffc0203e88:	00450513          	addi	a0,a0,4 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203e8c:	dbafc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma2 != NULL);
ffffffffc0203e90:	00003697          	auipc	a3,0x3
ffffffffc0203e94:	14068693          	addi	a3,a3,320 # ffffffffc0206fd0 <etext+0x16a2>
ffffffffc0203e98:	00002617          	auipc	a2,0x2
ffffffffc0203e9c:	4e060613          	addi	a2,a2,1248 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203ea0:	17700593          	li	a1,375
ffffffffc0203ea4:	00003517          	auipc	a0,0x3
ffffffffc0203ea8:	fe450513          	addi	a0,a0,-28 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203eac:	d9afc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma1 != NULL);
ffffffffc0203eb0:	00003697          	auipc	a3,0x3
ffffffffc0203eb4:	11068693          	addi	a3,a3,272 # ffffffffc0206fc0 <etext+0x1692>
ffffffffc0203eb8:	00002617          	auipc	a2,0x2
ffffffffc0203ebc:	4c060613          	addi	a2,a2,1216 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203ec0:	17500593          	li	a1,373
ffffffffc0203ec4:	00003517          	auipc	a0,0x3
ffffffffc0203ec8:	fc450513          	addi	a0,a0,-60 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203ecc:	d7afc0ef          	jal	ffffffffc0200446 <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203ed0:	6914                	ld	a3,16(a0)
ffffffffc0203ed2:	6510                	ld	a2,8(a0)
ffffffffc0203ed4:	0004859b          	sext.w	a1,s1
ffffffffc0203ed8:	00003517          	auipc	a0,0x3
ffffffffc0203edc:	19850513          	addi	a0,a0,408 # ffffffffc0207070 <etext+0x1742>
ffffffffc0203ee0:	ab4fc0ef          	jal	ffffffffc0200194 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203ee4:	00003697          	auipc	a3,0x3
ffffffffc0203ee8:	1b468693          	addi	a3,a3,436 # ffffffffc0207098 <etext+0x176a>
ffffffffc0203eec:	00002617          	auipc	a2,0x2
ffffffffc0203ef0:	48c60613          	addi	a2,a2,1164 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0203ef4:	18a00593          	li	a1,394
ffffffffc0203ef8:	00003517          	auipc	a0,0x3
ffffffffc0203efc:	f9050513          	addi	a0,a0,-112 # ffffffffc0206e88 <etext+0x155a>
ffffffffc0203f00:	d46fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203f04 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203f04:	7179                	addi	sp,sp,-48
ffffffffc0203f06:	f022                	sd	s0,32(sp)
ffffffffc0203f08:	f406                	sd	ra,40(sp)
ffffffffc0203f0a:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203f0c:	c52d                	beqz	a0,ffffffffc0203f76 <user_mem_check+0x72>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203f0e:	002007b7          	lui	a5,0x200
ffffffffc0203f12:	04f5ed63          	bltu	a1,a5,ffffffffc0203f6c <user_mem_check+0x68>
ffffffffc0203f16:	ec26                	sd	s1,24(sp)
ffffffffc0203f18:	00c584b3          	add	s1,a1,a2
ffffffffc0203f1c:	0695ff63          	bgeu	a1,s1,ffffffffc0203f9a <user_mem_check+0x96>
ffffffffc0203f20:	4785                	li	a5,1
ffffffffc0203f22:	07fe                	slli	a5,a5,0x1f
ffffffffc0203f24:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_exit_out_size+0x1f5df9>
ffffffffc0203f26:	06f4fa63          	bgeu	s1,a5,ffffffffc0203f9a <user_mem_check+0x96>
ffffffffc0203f2a:	e84a                	sd	s2,16(sp)
ffffffffc0203f2c:	e44e                	sd	s3,8(sp)
ffffffffc0203f2e:	8936                	mv	s2,a3
ffffffffc0203f30:	89aa                	mv	s3,a0
ffffffffc0203f32:	a829                	j	ffffffffc0203f4c <user_mem_check+0x48>
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203f34:	6685                	lui	a3,0x1
ffffffffc0203f36:	9736                	add	a4,a4,a3
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203f38:	0027f693          	andi	a3,a5,2
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203f3c:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203f3e:	c685                	beqz	a3,ffffffffc0203f66 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203f40:	c399                	beqz	a5,ffffffffc0203f46 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203f42:	02e46263          	bltu	s0,a4,ffffffffc0203f66 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203f46:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203f48:	04947b63          	bgeu	s0,s1,ffffffffc0203f9e <user_mem_check+0x9a>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203f4c:	85a2                	mv	a1,s0
ffffffffc0203f4e:	854e                	mv	a0,s3
ffffffffc0203f50:	86dff0ef          	jal	ffffffffc02037bc <find_vma>
ffffffffc0203f54:	c909                	beqz	a0,ffffffffc0203f66 <user_mem_check+0x62>
ffffffffc0203f56:	6518                	ld	a4,8(a0)
ffffffffc0203f58:	00e46763          	bltu	s0,a4,ffffffffc0203f66 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203f5c:	4d1c                	lw	a5,24(a0)
ffffffffc0203f5e:	fc091be3          	bnez	s2,ffffffffc0203f34 <user_mem_check+0x30>
ffffffffc0203f62:	8b85                	andi	a5,a5,1
ffffffffc0203f64:	f3ed                	bnez	a5,ffffffffc0203f46 <user_mem_check+0x42>
ffffffffc0203f66:	64e2                	ld	s1,24(sp)
ffffffffc0203f68:	6942                	ld	s2,16(sp)
ffffffffc0203f6a:	69a2                	ld	s3,8(sp)
            return 0;
ffffffffc0203f6c:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203f6e:	70a2                	ld	ra,40(sp)
ffffffffc0203f70:	7402                	ld	s0,32(sp)
ffffffffc0203f72:	6145                	addi	sp,sp,48
ffffffffc0203f74:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203f76:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f7a:	fef5eae3          	bltu	a1,a5,ffffffffc0203f6e <user_mem_check+0x6a>
ffffffffc0203f7e:	c80007b7          	lui	a5,0xc8000
ffffffffc0203f82:	962e                	add	a2,a2,a1
ffffffffc0203f84:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d64481>
ffffffffc0203f86:	00c5b433          	sltu	s0,a1,a2
ffffffffc0203f8a:	00f63633          	sltu	a2,a2,a5
ffffffffc0203f8e:	70a2                	ld	ra,40(sp)
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203f90:	00867533          	and	a0,a2,s0
ffffffffc0203f94:	7402                	ld	s0,32(sp)
ffffffffc0203f96:	6145                	addi	sp,sp,48
ffffffffc0203f98:	8082                	ret
ffffffffc0203f9a:	64e2                	ld	s1,24(sp)
ffffffffc0203f9c:	bfc1                	j	ffffffffc0203f6c <user_mem_check+0x68>
ffffffffc0203f9e:	64e2                	ld	s1,24(sp)
ffffffffc0203fa0:	6942                	ld	s2,16(sp)
ffffffffc0203fa2:	69a2                	ld	s3,8(sp)
        return 1;
ffffffffc0203fa4:	4505                	li	a0,1
ffffffffc0203fa6:	b7e1                	j	ffffffffc0203f6e <user_mem_check+0x6a>

ffffffffc0203fa8 <kernel_thread_entry>:
ffffffffc0203fa8:	8526                	mv	a0,s1
ffffffffc0203faa:	9402                	jalr	s0
ffffffffc0203fac:	5fa000ef          	jal	ffffffffc02045a6 <do_exit>

ffffffffc0203fb0 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203fb0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fb2:	10800513          	li	a0,264
{
ffffffffc0203fb6:	e022                	sd	s0,0(sp)
ffffffffc0203fb8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fba:	d83fd0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0203fbe:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203fc0:	cd21                	beqz	a0,ffffffffc0204018 <alloc_proc+0x68>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->state = PROC_UNINIT;
ffffffffc0203fc2:	57fd                	li	a5,-1
ffffffffc0203fc4:	1782                	slli	a5,a5,0x20
ffffffffc0203fc6:	e11c                	sd	a5,0(a0)
        
        // 初始化进程ID为无效值
        proc->pid = -1;
        
        // 初始化运行次数为0
        proc->runs = 0;
ffffffffc0203fc8:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0203fcc:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0203fd0:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0203fd4:	02053023          	sd	zero,32(a0)
        
        // 初始化内存管理结构为NULL
        proc->mm = NULL;
ffffffffc0203fd8:	02053423          	sd	zero,40(a0)
        
        // 初始化上下文结构（全部置0）
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203fdc:	07000613          	li	a2,112
ffffffffc0203fe0:	4581                	li	a1,0
ffffffffc0203fe2:	03050513          	addi	a0,a0,48
ffffffffc0203fe6:	11f010ef          	jal	ffffffffc0205904 <memset>
        
        // 初始化陷阱帧指针为NULL
        proc->tf = NULL;
        
        // 初始化页目录表基址
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fea:	00098797          	auipc	a5,0x98
ffffffffc0203fee:	b4e7b783          	ld	a5,-1202(a5) # ffffffffc029bb38 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc0203ff2:	0a043023          	sd	zero,160(s0)
        
        // 初始化进程标志为0
        proc->flags = 0;
ffffffffc0203ff6:	0a042823          	sw	zero,176(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203ffa:	f45c                	sd	a5,168(s0)
        
        // 初始化进程名称为空字符串
        memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0203ffc:	0b440513          	addi	a0,s0,180
ffffffffc0204000:	4641                	li	a2,16
ffffffffc0204002:	4581                	li	a1,0
ffffffffc0204004:	101010ef          	jal	ffffffffc0205904 <memset>

        proc->exit_code = 0;
ffffffffc0204008:	0e043423          	sd	zero,232(s0)
        proc->wait_state = 0;
        proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc020400c:	0e043823          	sd	zero,240(s0)
ffffffffc0204010:	0e043c23          	sd	zero,248(s0)
ffffffffc0204014:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0204018:	60a2                	ld	ra,8(sp)
ffffffffc020401a:	8522                	mv	a0,s0
ffffffffc020401c:	6402                	ld	s0,0(sp)
ffffffffc020401e:	0141                	addi	sp,sp,16
ffffffffc0204020:	8082                	ret

ffffffffc0204022 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204022:	00098797          	auipc	a5,0x98
ffffffffc0204026:	b467b783          	ld	a5,-1210(a5) # ffffffffc029bb68 <current>
ffffffffc020402a:	73c8                	ld	a0,160(a5)
ffffffffc020402c:	ef7fc06f          	j	ffffffffc0200f22 <forkrets>

ffffffffc0204030 <user_main>:
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc0204030:	00098797          	auipc	a5,0x98
ffffffffc0204034:	b387b783          	ld	a5,-1224(a5) # ffffffffc029bb68 <current>
{
ffffffffc0204038:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc020403a:	00003617          	auipc	a2,0x3
ffffffffc020403e:	0ae60613          	addi	a2,a2,174 # ffffffffc02070e8 <etext+0x17ba>
ffffffffc0204042:	43cc                	lw	a1,4(a5)
ffffffffc0204044:	00003517          	auipc	a0,0x3
ffffffffc0204048:	0ac50513          	addi	a0,a0,172 # ffffffffc02070f0 <etext+0x17c2>
{
ffffffffc020404c:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc020404e:	946fc0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0204052:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204056:	1b678793          	addi	a5,a5,438 # a208 <_binary_obj___user_exit_out_size>
ffffffffc020405a:	e43e                	sd	a5,8(sp)
kernel_execve(const char *name, unsigned char *binary, size_t size)
ffffffffc020405c:	00003517          	auipc	a0,0x3
ffffffffc0204060:	08c50513          	addi	a0,a0,140 # ffffffffc02070e8 <etext+0x17ba>
ffffffffc0204064:	00023797          	auipc	a5,0x23
ffffffffc0204068:	4e478793          	addi	a5,a5,1252 # ffffffffc0227548 <_binary_obj___user_exit_out_start>
ffffffffc020406c:	f03e                	sd	a5,32(sp)
ffffffffc020406e:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204070:	e802                	sd	zero,16(sp)
ffffffffc0204072:	7de010ef          	jal	ffffffffc0205850 <strlen>
ffffffffc0204076:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204078:	4511                	li	a0,4
ffffffffc020407a:	55a2                	lw	a1,40(sp)
ffffffffc020407c:	4662                	lw	a2,24(sp)
ffffffffc020407e:	5682                	lw	a3,32(sp)
ffffffffc0204080:	4722                	lw	a4,8(sp)
ffffffffc0204082:	48a9                	li	a7,10
ffffffffc0204084:	9002                	ebreak
ffffffffc0204086:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204088:	65c2                	ld	a1,16(sp)
ffffffffc020408a:	00003517          	auipc	a0,0x3
ffffffffc020408e:	08e50513          	addi	a0,a0,142 # ffffffffc0207118 <etext+0x17ea>
ffffffffc0204092:	902fc0ef          	jal	ffffffffc0200194 <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204096:	00003617          	auipc	a2,0x3
ffffffffc020409a:	09260613          	addi	a2,a2,146 # ffffffffc0207128 <etext+0x17fa>
ffffffffc020409e:	3d400593          	li	a1,980
ffffffffc02040a2:	00003517          	auipc	a0,0x3
ffffffffc02040a6:	0a650513          	addi	a0,a0,166 # ffffffffc0207148 <etext+0x181a>
ffffffffc02040aa:	b9cfc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02040ae <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc02040ae:	6d14                	ld	a3,24(a0)
{
ffffffffc02040b0:	1141                	addi	sp,sp,-16
ffffffffc02040b2:	e406                	sd	ra,8(sp)
ffffffffc02040b4:	c02007b7          	lui	a5,0xc0200
ffffffffc02040b8:	02f6ee63          	bltu	a3,a5,ffffffffc02040f4 <put_pgdir+0x46>
ffffffffc02040bc:	00098717          	auipc	a4,0x98
ffffffffc02040c0:	a8c73703          	ld	a4,-1396(a4) # ffffffffc029bb48 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc02040c4:	00098797          	auipc	a5,0x98
ffffffffc02040c8:	a8c7b783          	ld	a5,-1396(a5) # ffffffffc029bb50 <npage>
    return pa2page(PADDR(kva));
ffffffffc02040cc:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02040ce:	82b1                	srli	a3,a3,0xc
ffffffffc02040d0:	02f6fe63          	bgeu	a3,a5,ffffffffc020410c <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02040d4:	00004797          	auipc	a5,0x4
ffffffffc02040d8:	9fc7b783          	ld	a5,-1540(a5) # ffffffffc0207ad0 <nbase>
ffffffffc02040dc:	00098517          	auipc	a0,0x98
ffffffffc02040e0:	a7c53503          	ld	a0,-1412(a0) # ffffffffc029bb58 <pages>
}
ffffffffc02040e4:	60a2                	ld	ra,8(sp)
ffffffffc02040e6:	8e9d                	sub	a3,a3,a5
ffffffffc02040e8:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02040ea:	4585                	li	a1,1
ffffffffc02040ec:	9536                	add	a0,a0,a3
}
ffffffffc02040ee:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02040f0:	e49fd06f          	j	ffffffffc0201f38 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02040f4:	00002617          	auipc	a2,0x2
ffffffffc02040f8:	6dc60613          	addi	a2,a2,1756 # ffffffffc02067d0 <etext+0xea2>
ffffffffc02040fc:	07700593          	li	a1,119
ffffffffc0204100:	00002517          	auipc	a0,0x2
ffffffffc0204104:	65050513          	addi	a0,a0,1616 # ffffffffc0206750 <etext+0xe22>
ffffffffc0204108:	b3efc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020410c:	00002617          	auipc	a2,0x2
ffffffffc0204110:	6ec60613          	addi	a2,a2,1772 # ffffffffc02067f8 <etext+0xeca>
ffffffffc0204114:	06900593          	li	a1,105
ffffffffc0204118:	00002517          	auipc	a0,0x2
ffffffffc020411c:	63850513          	addi	a0,a0,1592 # ffffffffc0206750 <etext+0xe22>
ffffffffc0204120:	b26fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204124 <proc_run>:
    if (proc != current)
ffffffffc0204124:	00098697          	auipc	a3,0x98
ffffffffc0204128:	a446b683          	ld	a3,-1468(a3) # ffffffffc029bb68 <current>
ffffffffc020412c:	04a68463          	beq	a3,a0,ffffffffc0204174 <proc_run+0x50>
{
ffffffffc0204130:	1101                	addi	sp,sp,-32
ffffffffc0204132:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204134:	100027f3          	csrr	a5,sstatus
ffffffffc0204138:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020413a:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020413c:	ef8d                	bnez	a5,ffffffffc0204176 <proc_run+0x52>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc020413e:	755c                	ld	a5,168(a0)
ffffffffc0204140:	577d                	li	a4,-1
ffffffffc0204142:	177e                	slli	a4,a4,0x3f
ffffffffc0204144:	83b1                	srli	a5,a5,0xc
ffffffffc0204146:	e032                	sd	a2,0(sp)
        current = proc;
ffffffffc0204148:	00098597          	auipc	a1,0x98
ffffffffc020414c:	a2a5b023          	sd	a0,-1504(a1) # ffffffffc029bb68 <current>
ffffffffc0204150:	8fd9                	or	a5,a5,a4
ffffffffc0204152:	18079073          	csrw	satp,a5
        switch_to(&prev->context, &proc->context);
ffffffffc0204156:	03050593          	addi	a1,a0,48
ffffffffc020415a:	03068513          	addi	a0,a3,48
ffffffffc020415e:	0aa010ef          	jal	ffffffffc0205208 <switch_to>
    if (flag)
ffffffffc0204162:	6602                	ld	a2,0(sp)
ffffffffc0204164:	e601                	bnez	a2,ffffffffc020416c <proc_run+0x48>
}
ffffffffc0204166:	60e2                	ld	ra,24(sp)
ffffffffc0204168:	6105                	addi	sp,sp,32
ffffffffc020416a:	8082                	ret
ffffffffc020416c:	60e2                	ld	ra,24(sp)
ffffffffc020416e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204170:	f8efc06f          	j	ffffffffc02008fe <intr_enable>
ffffffffc0204174:	8082                	ret
ffffffffc0204176:	e42a                	sd	a0,8(sp)
ffffffffc0204178:	e036                	sd	a3,0(sp)
        intr_disable();
ffffffffc020417a:	f8afc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc020417e:	6522                	ld	a0,8(sp)
ffffffffc0204180:	6682                	ld	a3,0(sp)
ffffffffc0204182:	4605                	li	a2,1
ffffffffc0204184:	bf6d                	j	ffffffffc020413e <proc_run+0x1a>

ffffffffc0204186 <do_fork>:
    if (nr_process >= MAX_PROCESS)
ffffffffc0204186:	00098797          	auipc	a5,0x98
ffffffffc020418a:	9da7a783          	lw	a5,-1574(a5) # ffffffffc029bb60 <nr_process>
{
ffffffffc020418e:	7119                	addi	sp,sp,-128
ffffffffc0204190:	ecce                	sd	s3,88(sp)
ffffffffc0204192:	fc86                	sd	ra,120(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204194:	6985                	lui	s3,0x1
ffffffffc0204196:	3537d163          	bge	a5,s3,ffffffffc02044d8 <do_fork+0x352>
ffffffffc020419a:	f8a2                	sd	s0,112(sp)
ffffffffc020419c:	f4a6                	sd	s1,104(sp)
ffffffffc020419e:	f0ca                	sd	s2,96(sp)
ffffffffc02041a0:	ec6e                	sd	s11,24(sp)
ffffffffc02041a2:	892e                	mv	s2,a1
ffffffffc02041a4:	84b2                	mv	s1,a2
ffffffffc02041a6:	8daa                	mv	s11,a0
    if ((proc = alloc_proc()) == NULL) {
ffffffffc02041a8:	e09ff0ef          	jal	ffffffffc0203fb0 <alloc_proc>
ffffffffc02041ac:	842a                	mv	s0,a0
ffffffffc02041ae:	30050163          	beqz	a0,ffffffffc02044b0 <do_fork+0x32a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02041b2:	4509                	li	a0,2
ffffffffc02041b4:	d4bfd0ef          	jal	ffffffffc0201efe <alloc_pages>
    if (page != NULL)
ffffffffc02041b8:	2e050963          	beqz	a0,ffffffffc02044aa <do_fork+0x324>
ffffffffc02041bc:	e8d2                	sd	s4,80(sp)
    return page - pages + nbase;
ffffffffc02041be:	00098a17          	auipc	s4,0x98
ffffffffc02041c2:	99aa0a13          	addi	s4,s4,-1638 # ffffffffc029bb58 <pages>
ffffffffc02041c6:	000a3783          	ld	a5,0(s4)
ffffffffc02041ca:	e4d6                	sd	s5,72(sp)
ffffffffc02041cc:	00004a97          	auipc	s5,0x4
ffffffffc02041d0:	904a8a93          	addi	s5,s5,-1788 # ffffffffc0207ad0 <nbase>
ffffffffc02041d4:	000ab703          	ld	a4,0(s5)
ffffffffc02041d8:	40f506b3          	sub	a3,a0,a5
ffffffffc02041dc:	e0da                	sd	s6,64(sp)
    return KADDR(page2pa(page));
ffffffffc02041de:	00098b17          	auipc	s6,0x98
ffffffffc02041e2:	972b0b13          	addi	s6,s6,-1678 # ffffffffc029bb50 <npage>
ffffffffc02041e6:	f06a                	sd	s10,32(sp)
    return page - pages + nbase;
ffffffffc02041e8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02041ea:	5d7d                	li	s10,-1
ffffffffc02041ec:	000b3783          	ld	a5,0(s6)
    return page - pages + nbase;
ffffffffc02041f0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02041f2:	00cd5d13          	srli	s10,s10,0xc
ffffffffc02041f6:	01a6f633          	and	a2,a3,s10
ffffffffc02041fa:	fc5e                	sd	s7,56(sp)
ffffffffc02041fc:	f862                	sd	s8,48(sp)
ffffffffc02041fe:	f466                	sd	s9,40(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0204200:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204202:	2ef67963          	bgeu	a2,a5,ffffffffc02044f4 <do_fork+0x36e>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204206:	00098c17          	auipc	s8,0x98
ffffffffc020420a:	962c0c13          	addi	s8,s8,-1694 # ffffffffc029bb68 <current>
ffffffffc020420e:	000c3803          	ld	a6,0(s8)
ffffffffc0204212:	00098b97          	auipc	s7,0x98
ffffffffc0204216:	936b8b93          	addi	s7,s7,-1738 # ffffffffc029bb48 <va_pa_offset>
ffffffffc020421a:	000bb783          	ld	a5,0(s7)
ffffffffc020421e:	02883c83          	ld	s9,40(a6) # fffffffffffff028 <end+0x3fd634a8>
ffffffffc0204222:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204224:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0204226:	020c8a63          	beqz	s9,ffffffffc020425a <do_fork+0xd4>
    if (clone_flags & CLONE_VM)
ffffffffc020422a:	100df793          	andi	a5,s11,256
ffffffffc020422e:	1a078063          	beqz	a5,ffffffffc02043ce <do_fork+0x248>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204232:	030ca703          	lw	a4,48(s9)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204236:	018cb783          	ld	a5,24(s9)
ffffffffc020423a:	c02006b7          	lui	a3,0xc0200
ffffffffc020423e:	2705                	addiw	a4,a4,1
ffffffffc0204240:	02eca823          	sw	a4,48(s9)
    proc->mm = mm;
ffffffffc0204244:	03943423          	sd	s9,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204248:	2cd7ee63          	bltu	a5,a3,ffffffffc0204524 <do_fork+0x39e>
ffffffffc020424c:	000bb703          	ld	a4,0(s7)
    current->wait_state = 0;
ffffffffc0204250:	000c3803          	ld	a6,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204254:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204256:	8f99                	sub	a5,a5,a4
ffffffffc0204258:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020425a:	6789                	lui	a5,0x2
ffffffffc020425c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6d30>
ffffffffc0204260:	96be                	add	a3,a3,a5
ffffffffc0204262:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204264:	87b6                	mv	a5,a3
ffffffffc0204266:	12048713          	addi	a4,s1,288
ffffffffc020426a:	6890                	ld	a2,16(s1)
ffffffffc020426c:	6088                	ld	a0,0(s1)
ffffffffc020426e:	648c                	ld	a1,8(s1)
ffffffffc0204270:	eb90                	sd	a2,16(a5)
ffffffffc0204272:	e388                	sd	a0,0(a5)
ffffffffc0204274:	e78c                	sd	a1,8(a5)
ffffffffc0204276:	6c90                	ld	a2,24(s1)
ffffffffc0204278:	02048493          	addi	s1,s1,32
ffffffffc020427c:	02078793          	addi	a5,a5,32
ffffffffc0204280:	fec7bc23          	sd	a2,-8(a5)
ffffffffc0204284:	fee493e3          	bne	s1,a4,ffffffffc020426a <do_fork+0xe4>
    proc->tf->gpr.a0 = 0;
ffffffffc0204288:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020428c:	22090863          	beqz	s2,ffffffffc02044bc <do_fork+0x336>
    if (++last_pid >= MAX_PID)
ffffffffc0204290:	00093597          	auipc	a1,0x93
ffffffffc0204294:	4445a583          	lw	a1,1092(a1) # ffffffffc02976d4 <last_pid.1>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204298:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020429c:	00000797          	auipc	a5,0x0
ffffffffc02042a0:	d8678793          	addi	a5,a5,-634 # ffffffffc0204022 <forkret>
    if (++last_pid >= MAX_PID)
ffffffffc02042a4:	2585                	addiw	a1,a1,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02042a6:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02042a8:	fc14                	sd	a3,56(s0)
    if (++last_pid >= MAX_PID)
ffffffffc02042aa:	00093717          	auipc	a4,0x93
ffffffffc02042ae:	42b72523          	sw	a1,1066(a4) # ffffffffc02976d4 <last_pid.1>
ffffffffc02042b2:	6789                	lui	a5,0x2
ffffffffc02042b4:	20f5d663          	bge	a1,a5,ffffffffc02044c0 <do_fork+0x33a>
    if (last_pid >= next_safe)
ffffffffc02042b8:	00093797          	auipc	a5,0x93
ffffffffc02042bc:	4187a783          	lw	a5,1048(a5) # ffffffffc02976d0 <next_safe.0>
ffffffffc02042c0:	00098497          	auipc	s1,0x98
ffffffffc02042c4:	83048493          	addi	s1,s1,-2000 # ffffffffc029baf0 <proc_list>
ffffffffc02042c8:	06f5c563          	blt	a1,a5,ffffffffc0204332 <do_fork+0x1ac>
ffffffffc02042cc:	00098497          	auipc	s1,0x98
ffffffffc02042d0:	82448493          	addi	s1,s1,-2012 # ffffffffc029baf0 <proc_list>
ffffffffc02042d4:	0084b303          	ld	t1,8(s1)
        next_safe = MAX_PID;
ffffffffc02042d8:	6789                	lui	a5,0x2
ffffffffc02042da:	00093717          	auipc	a4,0x93
ffffffffc02042de:	3ef72b23          	sw	a5,1014(a4) # ffffffffc02976d0 <next_safe.0>
ffffffffc02042e2:	86ae                	mv	a3,a1
ffffffffc02042e4:	4501                	li	a0,0
        while ((le = list_next(le)) != list)
ffffffffc02042e6:	04930063          	beq	t1,s1,ffffffffc0204326 <do_fork+0x1a0>
ffffffffc02042ea:	88aa                	mv	a7,a0
ffffffffc02042ec:	879a                	mv	a5,t1
ffffffffc02042ee:	6609                	lui	a2,0x2
ffffffffc02042f0:	a811                	j	ffffffffc0204304 <do_fork+0x17e>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042f2:	00e6d663          	bge	a3,a4,ffffffffc02042fe <do_fork+0x178>
ffffffffc02042f6:	00c75463          	bge	a4,a2,ffffffffc02042fe <do_fork+0x178>
                next_safe = proc->pid;
ffffffffc02042fa:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042fc:	4885                	li	a7,1
ffffffffc02042fe:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204300:	00978d63          	beq	a5,s1,ffffffffc020431a <do_fork+0x194>
            if (proc->pid == last_pid)
ffffffffc0204304:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x6cd4>
ffffffffc0204308:	fed715e3          	bne	a4,a3,ffffffffc02042f2 <do_fork+0x16c>
                if (++last_pid >= next_safe)
ffffffffc020430c:	2685                	addiw	a3,a3,1
ffffffffc020430e:	1ac6df63          	bge	a3,a2,ffffffffc02044cc <do_fork+0x346>
ffffffffc0204312:	679c                	ld	a5,8(a5)
ffffffffc0204314:	4505                	li	a0,1
        while ((le = list_next(le)) != list)
ffffffffc0204316:	fe9797e3          	bne	a5,s1,ffffffffc0204304 <do_fork+0x17e>
ffffffffc020431a:	00088663          	beqz	a7,ffffffffc0204326 <do_fork+0x1a0>
ffffffffc020431e:	00093797          	auipc	a5,0x93
ffffffffc0204322:	3ac7a923          	sw	a2,946(a5) # ffffffffc02976d0 <next_safe.0>
ffffffffc0204326:	c511                	beqz	a0,ffffffffc0204332 <do_fork+0x1ac>
ffffffffc0204328:	00093797          	auipc	a5,0x93
ffffffffc020432c:	3ad7a623          	sw	a3,940(a5) # ffffffffc02976d4 <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204330:	85b6                	mv	a1,a3
    proc->pid = get_pid();
ffffffffc0204332:	c04c                	sw	a1,4(s0)
    current->wait_state = 0;
ffffffffc0204334:	0e082623          	sw	zero,236(a6)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204338:	4048                	lw	a0,4(s0)
    proc->parent = current;
ffffffffc020433a:	03043023          	sd	a6,32(s0)
    proc->wait_state = 0;
ffffffffc020433e:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204342:	10043023          	sd	zero,256(s0)
ffffffffc0204346:	0e043c23          	sd	zero,248(s0)
ffffffffc020434a:	0e043823          	sd	zero,240(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020434e:	45a9                	li	a1,10
ffffffffc0204350:	11e010ef          	jal	ffffffffc020546e <hash32>
ffffffffc0204354:	02051793          	slli	a5,a0,0x20
ffffffffc0204358:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020435c:	00093797          	auipc	a5,0x93
ffffffffc0204360:	79478793          	addi	a5,a5,1940 # ffffffffc0297af0 <hash_list>
ffffffffc0204364:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204366:	6518                	ld	a4,8(a0)
ffffffffc0204368:	0d840793          	addi	a5,s0,216
ffffffffc020436c:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc020436e:	e31c                	sd	a5,0(a4)
ffffffffc0204370:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204372:	f078                	sd	a4,224(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204374:	0c840793          	addi	a5,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204378:	7018                	ld	a4,32(s0)
    elm->prev = prev;
ffffffffc020437a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020437c:	e21c                	sd	a5,0(a2)
    proc->yptr = NULL;
ffffffffc020437e:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204382:	7b74                	ld	a3,240(a4)
ffffffffc0204384:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc0204386:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204388:	e464                	sd	s1,200(s0)
ffffffffc020438a:	10d43023          	sd	a3,256(s0)
ffffffffc020438e:	c299                	beqz	a3,ffffffffc0204394 <do_fork+0x20e>
        proc->optr->yptr = proc;
ffffffffc0204390:	fee0                	sd	s0,248(a3)
    proc->parent->cptr = proc;
ffffffffc0204392:	7018                	ld	a4,32(s0)
    nr_process++;
ffffffffc0204394:	00097797          	auipc	a5,0x97
ffffffffc0204398:	7cc7a783          	lw	a5,1996(a5) # ffffffffc029bb60 <nr_process>
    proc->parent->cptr = proc;
ffffffffc020439c:	fb60                	sd	s0,240(a4)
    wakeup_proc(proc);
ffffffffc020439e:	8522                	mv	a0,s0
    nr_process++;
ffffffffc02043a0:	2785                	addiw	a5,a5,1
ffffffffc02043a2:	00097717          	auipc	a4,0x97
ffffffffc02043a6:	7af72f23          	sw	a5,1982(a4) # ffffffffc029bb60 <nr_process>
    wakeup_proc(proc);
ffffffffc02043aa:	6c9000ef          	jal	ffffffffc0205272 <wakeup_proc>
    ret = proc->pid;
ffffffffc02043ae:	4048                	lw	a0,4(s0)
ffffffffc02043b0:	74a6                	ld	s1,104(sp)
ffffffffc02043b2:	7446                	ld	s0,112(sp)
ffffffffc02043b4:	7906                	ld	s2,96(sp)
ffffffffc02043b6:	6a46                	ld	s4,80(sp)
ffffffffc02043b8:	6aa6                	ld	s5,72(sp)
ffffffffc02043ba:	6b06                	ld	s6,64(sp)
ffffffffc02043bc:	7be2                	ld	s7,56(sp)
ffffffffc02043be:	7c42                	ld	s8,48(sp)
ffffffffc02043c0:	7ca2                	ld	s9,40(sp)
ffffffffc02043c2:	7d02                	ld	s10,32(sp)
ffffffffc02043c4:	6de2                	ld	s11,24(sp)
}
ffffffffc02043c6:	70e6                	ld	ra,120(sp)
ffffffffc02043c8:	69e6                	ld	s3,88(sp)
ffffffffc02043ca:	6109                	addi	sp,sp,128
ffffffffc02043cc:	8082                	ret
    if ((mm = mm_create()) == NULL)
ffffffffc02043ce:	e43a                	sd	a4,8(sp)
ffffffffc02043d0:	bbcff0ef          	jal	ffffffffc020378c <mm_create>
ffffffffc02043d4:	8daa                	mv	s11,a0
ffffffffc02043d6:	c959                	beqz	a0,ffffffffc020446c <do_fork+0x2e6>
    if ((page = alloc_page()) == NULL)
ffffffffc02043d8:	4505                	li	a0,1
ffffffffc02043da:	b25fd0ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc02043de:	c541                	beqz	a0,ffffffffc0204466 <do_fork+0x2e0>
    return page - pages + nbase;
ffffffffc02043e0:	000a3683          	ld	a3,0(s4)
ffffffffc02043e4:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc02043e6:	000b3783          	ld	a5,0(s6)
    return page - pages + nbase;
ffffffffc02043ea:	40d506b3          	sub	a3,a0,a3
ffffffffc02043ee:	8699                	srai	a3,a3,0x6
ffffffffc02043f0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02043f2:	01a6fd33          	and	s10,a3,s10
    return page2ppn(page) << PGSHIFT;
ffffffffc02043f6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043f8:	0efd7e63          	bgeu	s10,a5,ffffffffc02044f4 <do_fork+0x36e>
ffffffffc02043fc:	000bb783          	ld	a5,0(s7)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204400:	00097597          	auipc	a1,0x97
ffffffffc0204404:	7405b583          	ld	a1,1856(a1) # ffffffffc029bb40 <boot_pgdir_va>
ffffffffc0204408:	864e                	mv	a2,s3
ffffffffc020440a:	00f689b3          	add	s3,a3,a5
ffffffffc020440e:	854e                	mv	a0,s3
ffffffffc0204410:	506010ef          	jal	ffffffffc0205916 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204414:	038c8d13          	addi	s10,s9,56
    mm->pgdir = pgdir;
ffffffffc0204418:	013dbc23          	sd	s3,24(s11)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020441c:	4785                	li	a5,1
ffffffffc020441e:	40fd37af          	amoor.d	a5,a5,(s10)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204422:	03f79713          	slli	a4,a5,0x3f
ffffffffc0204426:	03f75793          	srli	a5,a4,0x3f
ffffffffc020442a:	4985                	li	s3,1
ffffffffc020442c:	cb91                	beqz	a5,ffffffffc0204440 <do_fork+0x2ba>
    {
        schedule();
ffffffffc020442e:	6d9000ef          	jal	ffffffffc0205306 <schedule>
ffffffffc0204432:	413d37af          	amoor.d	a5,s3,(s10)
    while (!try_lock(lock))
ffffffffc0204436:	03f79713          	slli	a4,a5,0x3f
ffffffffc020443a:	03f75793          	srli	a5,a4,0x3f
ffffffffc020443e:	fbe5                	bnez	a5,ffffffffc020442e <do_fork+0x2a8>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204440:	85e6                	mv	a1,s9
ffffffffc0204442:	856e                	mv	a0,s11
ffffffffc0204444:	e90ff0ef          	jal	ffffffffc0203ad4 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204448:	57f9                	li	a5,-2
ffffffffc020444a:	60fd37af          	amoand.d	a5,a5,(s10)
ffffffffc020444e:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204450:	0e078763          	beqz	a5,ffffffffc020453e <do_fork+0x3b8>
    if ((mm = mm_create()) == NULL)
ffffffffc0204454:	8cee                	mv	s9,s11
    if (ret != 0)
ffffffffc0204456:	dc050ee3          	beqz	a0,ffffffffc0204232 <do_fork+0xac>
    exit_mmap(mm);
ffffffffc020445a:	856e                	mv	a0,s11
ffffffffc020445c:	f10ff0ef          	jal	ffffffffc0203b6c <exit_mmap>
    put_pgdir(mm);
ffffffffc0204460:	856e                	mv	a0,s11
ffffffffc0204462:	c4dff0ef          	jal	ffffffffc02040ae <put_pgdir>
    mm_destroy(mm);
ffffffffc0204466:	856e                	mv	a0,s11
ffffffffc0204468:	d4eff0ef          	jal	ffffffffc02039b6 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020446c:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020446e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204472:	08f6ed63          	bltu	a3,a5,ffffffffc020450c <do_fork+0x386>
ffffffffc0204476:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage)
ffffffffc020447a:	000b3703          	ld	a4,0(s6)
    return pa2page(PADDR(kva));
ffffffffc020447e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204482:	83b1                	srli	a5,a5,0xc
ffffffffc0204484:	04e7fc63          	bgeu	a5,a4,ffffffffc02044dc <do_fork+0x356>
    return &pages[PPN(pa) - nbase];
ffffffffc0204488:	000ab703          	ld	a4,0(s5)
ffffffffc020448c:	000a3503          	ld	a0,0(s4)
ffffffffc0204490:	4589                	li	a1,2
ffffffffc0204492:	8f99                	sub	a5,a5,a4
ffffffffc0204494:	079a                	slli	a5,a5,0x6
ffffffffc0204496:	953e                	add	a0,a0,a5
ffffffffc0204498:	aa1fd0ef          	jal	ffffffffc0201f38 <free_pages>
}
ffffffffc020449c:	6a46                	ld	s4,80(sp)
ffffffffc020449e:	6aa6                	ld	s5,72(sp)
ffffffffc02044a0:	6b06                	ld	s6,64(sp)
ffffffffc02044a2:	7be2                	ld	s7,56(sp)
ffffffffc02044a4:	7c42                	ld	s8,48(sp)
ffffffffc02044a6:	7ca2                	ld	s9,40(sp)
ffffffffc02044a8:	7d02                	ld	s10,32(sp)
    kfree(proc);
ffffffffc02044aa:	8522                	mv	a0,s0
ffffffffc02044ac:	937fd0ef          	jal	ffffffffc0201de2 <kfree>
    goto fork_out;
ffffffffc02044b0:	7446                	ld	s0,112(sp)
ffffffffc02044b2:	74a6                	ld	s1,104(sp)
ffffffffc02044b4:	7906                	ld	s2,96(sp)
ffffffffc02044b6:	6de2                	ld	s11,24(sp)
    ret = -E_NO_MEM;
ffffffffc02044b8:	5571                	li	a0,-4
    return ret;
ffffffffc02044ba:	b731                	j	ffffffffc02043c6 <do_fork+0x240>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044bc:	8936                	mv	s2,a3
ffffffffc02044be:	bbc9                	j	ffffffffc0204290 <do_fork+0x10a>
        last_pid = 1;
ffffffffc02044c0:	4585                	li	a1,1
ffffffffc02044c2:	00093797          	auipc	a5,0x93
ffffffffc02044c6:	20b7a923          	sw	a1,530(a5) # ffffffffc02976d4 <last_pid.1>
        goto inside;
ffffffffc02044ca:	b509                	j	ffffffffc02042cc <do_fork+0x146>
                    if (last_pid >= MAX_PID)
ffffffffc02044cc:	6789                	lui	a5,0x2
ffffffffc02044ce:	00f6c363          	blt	a3,a5,ffffffffc02044d4 <do_fork+0x34e>
                        last_pid = 1;
ffffffffc02044d2:	4685                	li	a3,1
                    goto repeat;
ffffffffc02044d4:	4505                	li	a0,1
ffffffffc02044d6:	bd01                	j	ffffffffc02042e6 <do_fork+0x160>
    int ret = -E_NO_FREE_PROC;
ffffffffc02044d8:	556d                	li	a0,-5
ffffffffc02044da:	b5f5                	j	ffffffffc02043c6 <do_fork+0x240>
        panic("pa2page called with invalid pa");
ffffffffc02044dc:	00002617          	auipc	a2,0x2
ffffffffc02044e0:	31c60613          	addi	a2,a2,796 # ffffffffc02067f8 <etext+0xeca>
ffffffffc02044e4:	06900593          	li	a1,105
ffffffffc02044e8:	00002517          	auipc	a0,0x2
ffffffffc02044ec:	26850513          	addi	a0,a0,616 # ffffffffc0206750 <etext+0xe22>
ffffffffc02044f0:	f57fb0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02044f4:	00002617          	auipc	a2,0x2
ffffffffc02044f8:	23460613          	addi	a2,a2,564 # ffffffffc0206728 <etext+0xdfa>
ffffffffc02044fc:	07100593          	li	a1,113
ffffffffc0204500:	00002517          	auipc	a0,0x2
ffffffffc0204504:	25050513          	addi	a0,a0,592 # ffffffffc0206750 <etext+0xe22>
ffffffffc0204508:	f3ffb0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020450c:	00002617          	auipc	a2,0x2
ffffffffc0204510:	2c460613          	addi	a2,a2,708 # ffffffffc02067d0 <etext+0xea2>
ffffffffc0204514:	07700593          	li	a1,119
ffffffffc0204518:	00002517          	auipc	a0,0x2
ffffffffc020451c:	23850513          	addi	a0,a0,568 # ffffffffc0206750 <etext+0xe22>
ffffffffc0204520:	f27fb0ef          	jal	ffffffffc0200446 <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204524:	86be                	mv	a3,a5
ffffffffc0204526:	00002617          	auipc	a2,0x2
ffffffffc020452a:	2aa60613          	addi	a2,a2,682 # ffffffffc02067d0 <etext+0xea2>
ffffffffc020452e:	1a200593          	li	a1,418
ffffffffc0204532:	00003517          	auipc	a0,0x3
ffffffffc0204536:	c1650513          	addi	a0,a0,-1002 # ffffffffc0207148 <etext+0x181a>
ffffffffc020453a:	f0dfb0ef          	jal	ffffffffc0200446 <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc020453e:	00003617          	auipc	a2,0x3
ffffffffc0204542:	c2260613          	addi	a2,a2,-990 # ffffffffc0207160 <etext+0x1832>
ffffffffc0204546:	03f00593          	li	a1,63
ffffffffc020454a:	00003517          	auipc	a0,0x3
ffffffffc020454e:	c2650513          	addi	a0,a0,-986 # ffffffffc0207170 <etext+0x1842>
ffffffffc0204552:	ef5fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204556 <kernel_thread>:
{
ffffffffc0204556:	7129                	addi	sp,sp,-320
ffffffffc0204558:	fa22                	sd	s0,304(sp)
ffffffffc020455a:	f626                	sd	s1,296(sp)
ffffffffc020455c:	f24a                	sd	s2,288(sp)
ffffffffc020455e:	842a                	mv	s0,a0
ffffffffc0204560:	84ae                	mv	s1,a1
ffffffffc0204562:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204564:	850a                	mv	a0,sp
ffffffffc0204566:	12000613          	li	a2,288
ffffffffc020456a:	4581                	li	a1,0
{
ffffffffc020456c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020456e:	396010ef          	jal	ffffffffc0205904 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204572:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204574:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204576:	100027f3          	csrr	a5,sstatus
ffffffffc020457a:	edd7f793          	andi	a5,a5,-291
ffffffffc020457e:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204582:	860a                	mv	a2,sp
ffffffffc0204584:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204588:	00000717          	auipc	a4,0x0
ffffffffc020458c:	a2070713          	addi	a4,a4,-1504 # ffffffffc0203fa8 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204590:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204592:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204594:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204596:	bf1ff0ef          	jal	ffffffffc0204186 <do_fork>
}
ffffffffc020459a:	70f2                	ld	ra,312(sp)
ffffffffc020459c:	7452                	ld	s0,304(sp)
ffffffffc020459e:	74b2                	ld	s1,296(sp)
ffffffffc02045a0:	7912                	ld	s2,288(sp)
ffffffffc02045a2:	6131                	addi	sp,sp,320
ffffffffc02045a4:	8082                	ret

ffffffffc02045a6 <do_exit>:
{
ffffffffc02045a6:	7179                	addi	sp,sp,-48
ffffffffc02045a8:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02045aa:	00097417          	auipc	s0,0x97
ffffffffc02045ae:	5be40413          	addi	s0,s0,1470 # ffffffffc029bb68 <current>
ffffffffc02045b2:	601c                	ld	a5,0(s0)
ffffffffc02045b4:	00097717          	auipc	a4,0x97
ffffffffc02045b8:	5c473703          	ld	a4,1476(a4) # ffffffffc029bb78 <idleproc>
{
ffffffffc02045bc:	f406                	sd	ra,40(sp)
ffffffffc02045be:	ec26                	sd	s1,24(sp)
    if (current == idleproc)
ffffffffc02045c0:	0ce78b63          	beq	a5,a4,ffffffffc0204696 <do_exit+0xf0>
    if (current == initproc)
ffffffffc02045c4:	00097497          	auipc	s1,0x97
ffffffffc02045c8:	5ac48493          	addi	s1,s1,1452 # ffffffffc029bb70 <initproc>
ffffffffc02045cc:	6098                	ld	a4,0(s1)
ffffffffc02045ce:	e84a                	sd	s2,16(sp)
ffffffffc02045d0:	0ee78a63          	beq	a5,a4,ffffffffc02046c4 <do_exit+0x11e>
ffffffffc02045d4:	892a                	mv	s2,a0
    struct mm_struct *mm = current->mm;
ffffffffc02045d6:	7788                	ld	a0,40(a5)
    if (mm != NULL)
ffffffffc02045d8:	c115                	beqz	a0,ffffffffc02045fc <do_exit+0x56>
ffffffffc02045da:	00097797          	auipc	a5,0x97
ffffffffc02045de:	55e7b783          	ld	a5,1374(a5) # ffffffffc029bb38 <boot_pgdir_pa>
ffffffffc02045e2:	577d                	li	a4,-1
ffffffffc02045e4:	177e                	slli	a4,a4,0x3f
ffffffffc02045e6:	83b1                	srli	a5,a5,0xc
ffffffffc02045e8:	8fd9                	or	a5,a5,a4
ffffffffc02045ea:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02045ee:	591c                	lw	a5,48(a0)
ffffffffc02045f0:	37fd                	addiw	a5,a5,-1
ffffffffc02045f2:	d91c                	sw	a5,48(a0)
        if (mm_count_dec(mm) == 0)
ffffffffc02045f4:	cfd5                	beqz	a5,ffffffffc02046b0 <do_exit+0x10a>
        current->mm = NULL;
ffffffffc02045f6:	601c                	ld	a5,0(s0)
ffffffffc02045f8:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02045fc:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc02045fe:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204602:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204604:	100027f3          	csrr	a5,sstatus
ffffffffc0204608:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020460a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020460c:	ebe1                	bnez	a5,ffffffffc02046dc <do_exit+0x136>
        proc = current->parent;
ffffffffc020460e:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204610:	800007b7          	lui	a5,0x80000
ffffffffc0204614:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5df9>
        proc = current->parent;
ffffffffc0204616:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204618:	0ec52703          	lw	a4,236(a0)
ffffffffc020461c:	0cf70463          	beq	a4,a5,ffffffffc02046e4 <do_exit+0x13e>
        while (current->cptr != NULL)
ffffffffc0204620:	6018                	ld	a4,0(s0)
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204622:	800005b7          	lui	a1,0x80000
ffffffffc0204626:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5df9>
        while (current->cptr != NULL)
ffffffffc0204628:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020462a:	460d                	li	a2,3
        while (current->cptr != NULL)
ffffffffc020462c:	e789                	bnez	a5,ffffffffc0204636 <do_exit+0x90>
ffffffffc020462e:	a83d                	j	ffffffffc020466c <do_exit+0xc6>
ffffffffc0204630:	6018                	ld	a4,0(s0)
ffffffffc0204632:	7b7c                	ld	a5,240(a4)
ffffffffc0204634:	cf85                	beqz	a5,ffffffffc020466c <do_exit+0xc6>
            current->cptr = proc->optr;
ffffffffc0204636:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020463a:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020463c:	fb74                	sd	a3,240(a4)
            proc->yptr = NULL;
ffffffffc020463e:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204642:	7978                	ld	a4,240(a0)
ffffffffc0204644:	10e7b023          	sd	a4,256(a5)
ffffffffc0204648:	c311                	beqz	a4,ffffffffc020464c <do_exit+0xa6>
                initproc->cptr->yptr = proc;
ffffffffc020464a:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020464c:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020464e:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204650:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204652:	fcc71fe3          	bne	a4,a2,ffffffffc0204630 <do_exit+0x8a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204656:	0ec52783          	lw	a5,236(a0)
ffffffffc020465a:	fcb79be3          	bne	a5,a1,ffffffffc0204630 <do_exit+0x8a>
                    wakeup_proc(initproc);
ffffffffc020465e:	415000ef          	jal	ffffffffc0205272 <wakeup_proc>
ffffffffc0204662:	800005b7          	lui	a1,0x80000
ffffffffc0204666:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5df9>
ffffffffc0204668:	460d                	li	a2,3
ffffffffc020466a:	b7d9                	j	ffffffffc0204630 <do_exit+0x8a>
    if (flag)
ffffffffc020466c:	02091263          	bnez	s2,ffffffffc0204690 <do_exit+0xea>
    schedule();
ffffffffc0204670:	497000ef          	jal	ffffffffc0205306 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204674:	601c                	ld	a5,0(s0)
ffffffffc0204676:	00003617          	auipc	a2,0x3
ffffffffc020467a:	b3260613          	addi	a2,a2,-1230 # ffffffffc02071a8 <etext+0x187a>
ffffffffc020467e:	25800593          	li	a1,600
ffffffffc0204682:	43d4                	lw	a3,4(a5)
ffffffffc0204684:	00003517          	auipc	a0,0x3
ffffffffc0204688:	ac450513          	addi	a0,a0,-1340 # ffffffffc0207148 <etext+0x181a>
ffffffffc020468c:	dbbfb0ef          	jal	ffffffffc0200446 <__panic>
        intr_enable();
ffffffffc0204690:	a6efc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0204694:	bff1                	j	ffffffffc0204670 <do_exit+0xca>
        panic("idleproc exit.\n");
ffffffffc0204696:	00003617          	auipc	a2,0x3
ffffffffc020469a:	af260613          	addi	a2,a2,-1294 # ffffffffc0207188 <etext+0x185a>
ffffffffc020469e:	22400593          	li	a1,548
ffffffffc02046a2:	00003517          	auipc	a0,0x3
ffffffffc02046a6:	aa650513          	addi	a0,a0,-1370 # ffffffffc0207148 <etext+0x181a>
ffffffffc02046aa:	e84a                	sd	s2,16(sp)
ffffffffc02046ac:	d9bfb0ef          	jal	ffffffffc0200446 <__panic>
            exit_mmap(mm);
ffffffffc02046b0:	e42a                	sd	a0,8(sp)
ffffffffc02046b2:	cbaff0ef          	jal	ffffffffc0203b6c <exit_mmap>
            put_pgdir(mm);
ffffffffc02046b6:	6522                	ld	a0,8(sp)
ffffffffc02046b8:	9f7ff0ef          	jal	ffffffffc02040ae <put_pgdir>
            mm_destroy(mm);
ffffffffc02046bc:	6522                	ld	a0,8(sp)
ffffffffc02046be:	af8ff0ef          	jal	ffffffffc02039b6 <mm_destroy>
ffffffffc02046c2:	bf15                	j	ffffffffc02045f6 <do_exit+0x50>
        panic("initproc exit.\n");
ffffffffc02046c4:	00003617          	auipc	a2,0x3
ffffffffc02046c8:	ad460613          	addi	a2,a2,-1324 # ffffffffc0207198 <etext+0x186a>
ffffffffc02046cc:	22800593          	li	a1,552
ffffffffc02046d0:	00003517          	auipc	a0,0x3
ffffffffc02046d4:	a7850513          	addi	a0,a0,-1416 # ffffffffc0207148 <etext+0x181a>
ffffffffc02046d8:	d6ffb0ef          	jal	ffffffffc0200446 <__panic>
        intr_disable();
ffffffffc02046dc:	a28fc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc02046e0:	4905                	li	s2,1
ffffffffc02046e2:	b735                	j	ffffffffc020460e <do_exit+0x68>
            wakeup_proc(proc);
ffffffffc02046e4:	38f000ef          	jal	ffffffffc0205272 <wakeup_proc>
ffffffffc02046e8:	bf25                	j	ffffffffc0204620 <do_exit+0x7a>

ffffffffc02046ea <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc02046ea:	7179                	addi	sp,sp,-48
ffffffffc02046ec:	ec26                	sd	s1,24(sp)
ffffffffc02046ee:	e84a                	sd	s2,16(sp)
ffffffffc02046f0:	e44e                	sd	s3,8(sp)
ffffffffc02046f2:	f406                	sd	ra,40(sp)
ffffffffc02046f4:	f022                	sd	s0,32(sp)
ffffffffc02046f6:	84aa                	mv	s1,a0
ffffffffc02046f8:	892e                	mv	s2,a1
ffffffffc02046fa:	00097997          	auipc	s3,0x97
ffffffffc02046fe:	46e98993          	addi	s3,s3,1134 # ffffffffc029bb68 <current>
    if (pid != 0)
ffffffffc0204702:	cd19                	beqz	a0,ffffffffc0204720 <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204704:	6789                	lui	a5,0x2
ffffffffc0204706:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6c12>
ffffffffc0204708:	fff5071b          	addiw	a4,a0,-1
ffffffffc020470c:	12e7f563          	bgeu	a5,a4,ffffffffc0204836 <do_wait.part.0+0x14c>
}
ffffffffc0204710:	70a2                	ld	ra,40(sp)
ffffffffc0204712:	7402                	ld	s0,32(sp)
ffffffffc0204714:	64e2                	ld	s1,24(sp)
ffffffffc0204716:	6942                	ld	s2,16(sp)
ffffffffc0204718:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc020471a:	5579                	li	a0,-2
}
ffffffffc020471c:	6145                	addi	sp,sp,48
ffffffffc020471e:	8082                	ret
        proc = current->cptr;
ffffffffc0204720:	0009b703          	ld	a4,0(s3)
ffffffffc0204724:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204726:	d46d                	beqz	s0,ffffffffc0204710 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204728:	468d                	li	a3,3
ffffffffc020472a:	a021                	j	ffffffffc0204732 <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr)
ffffffffc020472c:	10043403          	ld	s0,256(s0)
ffffffffc0204730:	c075                	beqz	s0,ffffffffc0204814 <do_wait.part.0+0x12a>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204732:	401c                	lw	a5,0(s0)
ffffffffc0204734:	fed79ce3          	bne	a5,a3,ffffffffc020472c <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc)
ffffffffc0204738:	00097797          	auipc	a5,0x97
ffffffffc020473c:	4407b783          	ld	a5,1088(a5) # ffffffffc029bb78 <idleproc>
ffffffffc0204740:	14878263          	beq	a5,s0,ffffffffc0204884 <do_wait.part.0+0x19a>
ffffffffc0204744:	00097797          	auipc	a5,0x97
ffffffffc0204748:	42c7b783          	ld	a5,1068(a5) # ffffffffc029bb70 <initproc>
ffffffffc020474c:	12f40c63          	beq	s0,a5,ffffffffc0204884 <do_wait.part.0+0x19a>
    if (code_store != NULL)
ffffffffc0204750:	00090663          	beqz	s2,ffffffffc020475c <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc0204754:	0e842783          	lw	a5,232(s0)
ffffffffc0204758:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020475c:	100027f3          	csrr	a5,sstatus
ffffffffc0204760:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204762:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204764:	10079963          	bnez	a5,ffffffffc0204876 <do_wait.part.0+0x18c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204768:	6c74                	ld	a3,216(s0)
ffffffffc020476a:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL)
ffffffffc020476c:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc0204770:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204772:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204774:	6474                	ld	a3,200(s0)
ffffffffc0204776:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc0204778:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020477a:	e314                	sd	a3,0(a4)
ffffffffc020477c:	c789                	beqz	a5,ffffffffc0204786 <do_wait.part.0+0x9c>
        proc->optr->yptr = proc->yptr;
ffffffffc020477e:	7c78                	ld	a4,248(s0)
ffffffffc0204780:	fff8                	sd	a4,248(a5)
        proc->yptr->optr = proc->optr;
ffffffffc0204782:	10043783          	ld	a5,256(s0)
    if (proc->yptr != NULL)
ffffffffc0204786:	7c78                	ld	a4,248(s0)
ffffffffc0204788:	c36d                	beqz	a4,ffffffffc020486a <do_wait.part.0+0x180>
        proc->yptr->optr = proc->optr;
ffffffffc020478a:	10f73023          	sd	a5,256(a4)
    nr_process--;
ffffffffc020478e:	00097797          	auipc	a5,0x97
ffffffffc0204792:	3d27a783          	lw	a5,978(a5) # ffffffffc029bb60 <nr_process>
ffffffffc0204796:	37fd                	addiw	a5,a5,-1
ffffffffc0204798:	00097717          	auipc	a4,0x97
ffffffffc020479c:	3cf72423          	sw	a5,968(a4) # ffffffffc029bb60 <nr_process>
    if (flag)
ffffffffc02047a0:	e271                	bnez	a2,ffffffffc0204864 <do_wait.part.0+0x17a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02047a2:	6814                	ld	a3,16(s0)
ffffffffc02047a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02047a8:	10f6e663          	bltu	a3,a5,ffffffffc02048b4 <do_wait.part.0+0x1ca>
ffffffffc02047ac:	00097717          	auipc	a4,0x97
ffffffffc02047b0:	39c73703          	ld	a4,924(a4) # ffffffffc029bb48 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc02047b4:	00097797          	auipc	a5,0x97
ffffffffc02047b8:	39c7b783          	ld	a5,924(a5) # ffffffffc029bb50 <npage>
    return pa2page(PADDR(kva));
ffffffffc02047bc:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02047be:	82b1                	srli	a3,a3,0xc
ffffffffc02047c0:	0cf6fe63          	bgeu	a3,a5,ffffffffc020489c <do_wait.part.0+0x1b2>
    return &pages[PPN(pa) - nbase];
ffffffffc02047c4:	00003797          	auipc	a5,0x3
ffffffffc02047c8:	30c7b783          	ld	a5,780(a5) # ffffffffc0207ad0 <nbase>
ffffffffc02047cc:	00097517          	auipc	a0,0x97
ffffffffc02047d0:	38c53503          	ld	a0,908(a0) # ffffffffc029bb58 <pages>
ffffffffc02047d4:	4589                	li	a1,2
ffffffffc02047d6:	8e9d                	sub	a3,a3,a5
ffffffffc02047d8:	069a                	slli	a3,a3,0x6
ffffffffc02047da:	9536                	add	a0,a0,a3
ffffffffc02047dc:	f5cfd0ef          	jal	ffffffffc0201f38 <free_pages>
    kfree(proc);
ffffffffc02047e0:	8522                	mv	a0,s0
ffffffffc02047e2:	e00fd0ef          	jal	ffffffffc0201de2 <kfree>
}
ffffffffc02047e6:	70a2                	ld	ra,40(sp)
ffffffffc02047e8:	7402                	ld	s0,32(sp)
ffffffffc02047ea:	64e2                	ld	s1,24(sp)
ffffffffc02047ec:	6942                	ld	s2,16(sp)
ffffffffc02047ee:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc02047f0:	4501                	li	a0,0
}
ffffffffc02047f2:	6145                	addi	sp,sp,48
ffffffffc02047f4:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc02047f6:	00097997          	auipc	s3,0x97
ffffffffc02047fa:	37298993          	addi	s3,s3,882 # ffffffffc029bb68 <current>
ffffffffc02047fe:	0009b703          	ld	a4,0(s3)
ffffffffc0204802:	f487b683          	ld	a3,-184(a5)
ffffffffc0204806:	f0e695e3          	bne	a3,a4,ffffffffc0204710 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020480a:	f287a603          	lw	a2,-216(a5)
ffffffffc020480e:	468d                	li	a3,3
ffffffffc0204810:	06d60063          	beq	a2,a3,ffffffffc0204870 <do_wait.part.0+0x186>
        current->wait_state = WT_CHILD;
ffffffffc0204814:	800007b7          	lui	a5,0x80000
ffffffffc0204818:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5df9>
        current->state = PROC_SLEEPING;
ffffffffc020481a:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc020481c:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc0204820:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc0204822:	2e5000ef          	jal	ffffffffc0205306 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0204826:	0009b783          	ld	a5,0(s3)
ffffffffc020482a:	0b07a783          	lw	a5,176(a5)
ffffffffc020482e:	8b85                	andi	a5,a5,1
ffffffffc0204830:	e7b9                	bnez	a5,ffffffffc020487e <do_wait.part.0+0x194>
    if (pid != 0)
ffffffffc0204832:	ee0487e3          	beqz	s1,ffffffffc0204720 <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204836:	45a9                	li	a1,10
ffffffffc0204838:	8526                	mv	a0,s1
ffffffffc020483a:	435000ef          	jal	ffffffffc020546e <hash32>
ffffffffc020483e:	02051793          	slli	a5,a0,0x20
ffffffffc0204842:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204846:	00093797          	auipc	a5,0x93
ffffffffc020484a:	2aa78793          	addi	a5,a5,682 # ffffffffc0297af0 <hash_list>
ffffffffc020484e:	953e                	add	a0,a0,a5
ffffffffc0204850:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204852:	a029                	j	ffffffffc020485c <do_wait.part.0+0x172>
            if (proc->pid == pid)
ffffffffc0204854:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204858:	f8970fe3          	beq	a4,s1,ffffffffc02047f6 <do_wait.part.0+0x10c>
    return listelm->next;
ffffffffc020485c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020485e:	fef51be3          	bne	a0,a5,ffffffffc0204854 <do_wait.part.0+0x16a>
ffffffffc0204862:	b57d                	j	ffffffffc0204710 <do_wait.part.0+0x26>
        intr_enable();
ffffffffc0204864:	89afc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0204868:	bf2d                	j	ffffffffc02047a2 <do_wait.part.0+0xb8>
        proc->parent->cptr = proc->optr;
ffffffffc020486a:	7018                	ld	a4,32(s0)
ffffffffc020486c:	fb7c                	sd	a5,240(a4)
ffffffffc020486e:	b705                	j	ffffffffc020478e <do_wait.part.0+0xa4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204870:	f2878413          	addi	s0,a5,-216
ffffffffc0204874:	b5d1                	j	ffffffffc0204738 <do_wait.part.0+0x4e>
        intr_disable();
ffffffffc0204876:	88efc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc020487a:	4605                	li	a2,1
ffffffffc020487c:	b5f5                	j	ffffffffc0204768 <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc020487e:	555d                	li	a0,-9
ffffffffc0204880:	d27ff0ef          	jal	ffffffffc02045a6 <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc0204884:	00003617          	auipc	a2,0x3
ffffffffc0204888:	94460613          	addi	a2,a2,-1724 # ffffffffc02071c8 <etext+0x189a>
ffffffffc020488c:	37c00593          	li	a1,892
ffffffffc0204890:	00003517          	auipc	a0,0x3
ffffffffc0204894:	8b850513          	addi	a0,a0,-1864 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204898:	baffb0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020489c:	00002617          	auipc	a2,0x2
ffffffffc02048a0:	f5c60613          	addi	a2,a2,-164 # ffffffffc02067f8 <etext+0xeca>
ffffffffc02048a4:	06900593          	li	a1,105
ffffffffc02048a8:	00002517          	auipc	a0,0x2
ffffffffc02048ac:	ea850513          	addi	a0,a0,-344 # ffffffffc0206750 <etext+0xe22>
ffffffffc02048b0:	b97fb0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02048b4:	00002617          	auipc	a2,0x2
ffffffffc02048b8:	f1c60613          	addi	a2,a2,-228 # ffffffffc02067d0 <etext+0xea2>
ffffffffc02048bc:	07700593          	li	a1,119
ffffffffc02048c0:	00002517          	auipc	a0,0x2
ffffffffc02048c4:	e9050513          	addi	a0,a0,-368 # ffffffffc0206750 <etext+0xe22>
ffffffffc02048c8:	b7ffb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02048cc <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02048cc:	1141                	addi	sp,sp,-16
ffffffffc02048ce:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02048d0:	ea0fd0ef          	jal	ffffffffc0201f70 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02048d4:	c64fd0ef          	jal	ffffffffc0201d38 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02048d8:	4601                	li	a2,0
ffffffffc02048da:	4581                	li	a1,0
ffffffffc02048dc:	fffff517          	auipc	a0,0xfffff
ffffffffc02048e0:	75450513          	addi	a0,a0,1876 # ffffffffc0204030 <user_main>
ffffffffc02048e4:	c73ff0ef          	jal	ffffffffc0204556 <kernel_thread>
    if (pid <= 0)
ffffffffc02048e8:	00a04563          	bgtz	a0,ffffffffc02048f2 <init_main+0x26>
ffffffffc02048ec:	a071                	j	ffffffffc0204978 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc02048ee:	219000ef          	jal	ffffffffc0205306 <schedule>
    if (code_store != NULL)
ffffffffc02048f2:	4581                	li	a1,0
ffffffffc02048f4:	4501                	li	a0,0
ffffffffc02048f6:	df5ff0ef          	jal	ffffffffc02046ea <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc02048fa:	d975                	beqz	a0,ffffffffc02048ee <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02048fc:	00003517          	auipc	a0,0x3
ffffffffc0204900:	90c50513          	addi	a0,a0,-1780 # ffffffffc0207208 <etext+0x18da>
ffffffffc0204904:	891fb0ef          	jal	ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204908:	00097797          	auipc	a5,0x97
ffffffffc020490c:	2687b783          	ld	a5,616(a5) # ffffffffc029bb70 <initproc>
ffffffffc0204910:	7bf8                	ld	a4,240(a5)
ffffffffc0204912:	e339                	bnez	a4,ffffffffc0204958 <init_main+0x8c>
ffffffffc0204914:	7ff8                	ld	a4,248(a5)
ffffffffc0204916:	e329                	bnez	a4,ffffffffc0204958 <init_main+0x8c>
ffffffffc0204918:	1007b703          	ld	a4,256(a5)
ffffffffc020491c:	ef15                	bnez	a4,ffffffffc0204958 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc020491e:	00097697          	auipc	a3,0x97
ffffffffc0204922:	2426a683          	lw	a3,578(a3) # ffffffffc029bb60 <nr_process>
ffffffffc0204926:	4709                	li	a4,2
ffffffffc0204928:	0ae69463          	bne	a3,a4,ffffffffc02049d0 <init_main+0x104>
ffffffffc020492c:	00097697          	auipc	a3,0x97
ffffffffc0204930:	1c468693          	addi	a3,a3,452 # ffffffffc029baf0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204934:	6698                	ld	a4,8(a3)
ffffffffc0204936:	0c878793          	addi	a5,a5,200
ffffffffc020493a:	06f71b63          	bne	a4,a5,ffffffffc02049b0 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020493e:	629c                	ld	a5,0(a3)
ffffffffc0204940:	04f71863          	bne	a4,a5,ffffffffc0204990 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204944:	00003517          	auipc	a0,0x3
ffffffffc0204948:	9ac50513          	addi	a0,a0,-1620 # ffffffffc02072f0 <etext+0x19c2>
ffffffffc020494c:	849fb0ef          	jal	ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0204950:	60a2                	ld	ra,8(sp)
ffffffffc0204952:	4501                	li	a0,0
ffffffffc0204954:	0141                	addi	sp,sp,16
ffffffffc0204956:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204958:	00003697          	auipc	a3,0x3
ffffffffc020495c:	8d868693          	addi	a3,a3,-1832 # ffffffffc0207230 <etext+0x1902>
ffffffffc0204960:	00002617          	auipc	a2,0x2
ffffffffc0204964:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0204968:	3ea00593          	li	a1,1002
ffffffffc020496c:	00002517          	auipc	a0,0x2
ffffffffc0204970:	7dc50513          	addi	a0,a0,2012 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204974:	ad3fb0ef          	jal	ffffffffc0200446 <__panic>
        panic("create user_main failed.\n");
ffffffffc0204978:	00003617          	auipc	a2,0x3
ffffffffc020497c:	87060613          	addi	a2,a2,-1936 # ffffffffc02071e8 <etext+0x18ba>
ffffffffc0204980:	3e100593          	li	a1,993
ffffffffc0204984:	00002517          	auipc	a0,0x2
ffffffffc0204988:	7c450513          	addi	a0,a0,1988 # ffffffffc0207148 <etext+0x181a>
ffffffffc020498c:	abbfb0ef          	jal	ffffffffc0200446 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204990:	00003697          	auipc	a3,0x3
ffffffffc0204994:	93068693          	addi	a3,a3,-1744 # ffffffffc02072c0 <etext+0x1992>
ffffffffc0204998:	00002617          	auipc	a2,0x2
ffffffffc020499c:	9e060613          	addi	a2,a2,-1568 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02049a0:	3ed00593          	li	a1,1005
ffffffffc02049a4:	00002517          	auipc	a0,0x2
ffffffffc02049a8:	7a450513          	addi	a0,a0,1956 # ffffffffc0207148 <etext+0x181a>
ffffffffc02049ac:	a9bfb0ef          	jal	ffffffffc0200446 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02049b0:	00003697          	auipc	a3,0x3
ffffffffc02049b4:	8e068693          	addi	a3,a3,-1824 # ffffffffc0207290 <etext+0x1962>
ffffffffc02049b8:	00002617          	auipc	a2,0x2
ffffffffc02049bc:	9c060613          	addi	a2,a2,-1600 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02049c0:	3ec00593          	li	a1,1004
ffffffffc02049c4:	00002517          	auipc	a0,0x2
ffffffffc02049c8:	78450513          	addi	a0,a0,1924 # ffffffffc0207148 <etext+0x181a>
ffffffffc02049cc:	a7bfb0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_process == 2);
ffffffffc02049d0:	00003697          	auipc	a3,0x3
ffffffffc02049d4:	8b068693          	addi	a3,a3,-1872 # ffffffffc0207280 <etext+0x1952>
ffffffffc02049d8:	00002617          	auipc	a2,0x2
ffffffffc02049dc:	9a060613          	addi	a2,a2,-1632 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02049e0:	3eb00593          	li	a1,1003
ffffffffc02049e4:	00002517          	auipc	a0,0x2
ffffffffc02049e8:	76450513          	addi	a0,a0,1892 # ffffffffc0207148 <etext+0x181a>
ffffffffc02049ec:	a5bfb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02049f0 <do_execve>:
{
ffffffffc02049f0:	7171                	addi	sp,sp,-176
ffffffffc02049f2:	e8ea                	sd	s10,80(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02049f4:	00097d17          	auipc	s10,0x97
ffffffffc02049f8:	174d0d13          	addi	s10,s10,372 # ffffffffc029bb68 <current>
ffffffffc02049fc:	000d3783          	ld	a5,0(s10)
{
ffffffffc0204a00:	e94a                	sd	s2,144(sp)
ffffffffc0204a02:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204a04:	0287b903          	ld	s2,40(a5)
{
ffffffffc0204a08:	84ae                	mv	s1,a1
ffffffffc0204a0a:	e54e                	sd	s3,136(sp)
ffffffffc0204a0c:	ec32                	sd	a2,24(sp)
ffffffffc0204a0e:	89aa                	mv	s3,a0
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a10:	85aa                	mv	a1,a0
ffffffffc0204a12:	8626                	mv	a2,s1
ffffffffc0204a14:	854a                	mv	a0,s2
ffffffffc0204a16:	4681                	li	a3,0
{
ffffffffc0204a18:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a1a:	ceaff0ef          	jal	ffffffffc0203f04 <user_mem_check>
ffffffffc0204a1e:	46050f63          	beqz	a0,ffffffffc0204e9c <do_execve+0x4ac>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204a22:	4641                	li	a2,16
ffffffffc0204a24:	1808                	addi	a0,sp,48
ffffffffc0204a26:	4581                	li	a1,0
ffffffffc0204a28:	6dd000ef          	jal	ffffffffc0205904 <memset>
    if (len > PROC_NAME_LEN)
ffffffffc0204a2c:	47bd                	li	a5,15
ffffffffc0204a2e:	8626                	mv	a2,s1
ffffffffc0204a30:	0e97ef63          	bltu	a5,s1,ffffffffc0204b2e <do_execve+0x13e>
    memcpy(local_name, name, len);
ffffffffc0204a34:	85ce                	mv	a1,s3
ffffffffc0204a36:	1808                	addi	a0,sp,48
ffffffffc0204a38:	6df000ef          	jal	ffffffffc0205916 <memcpy>
    if (mm != NULL)
ffffffffc0204a3c:	10090063          	beqz	s2,ffffffffc0204b3c <do_execve+0x14c>
        cputs("mm != NULL");
ffffffffc0204a40:	00002517          	auipc	a0,0x2
ffffffffc0204a44:	4d050513          	addi	a0,a0,1232 # ffffffffc0206f10 <etext+0x15e2>
ffffffffc0204a48:	f82fb0ef          	jal	ffffffffc02001ca <cputs>
ffffffffc0204a4c:	00097797          	auipc	a5,0x97
ffffffffc0204a50:	0ec7b783          	ld	a5,236(a5) # ffffffffc029bb38 <boot_pgdir_pa>
ffffffffc0204a54:	577d                	li	a4,-1
ffffffffc0204a56:	177e                	slli	a4,a4,0x3f
ffffffffc0204a58:	83b1                	srli	a5,a5,0xc
ffffffffc0204a5a:	8fd9                	or	a5,a5,a4
ffffffffc0204a5c:	18079073          	csrw	satp,a5
ffffffffc0204a60:	03092783          	lw	a5,48(s2)
ffffffffc0204a64:	37fd                	addiw	a5,a5,-1
ffffffffc0204a66:	02f92823          	sw	a5,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0204a6a:	30078563          	beqz	a5,ffffffffc0204d74 <do_execve+0x384>
        current->mm = NULL;
ffffffffc0204a6e:	000d3783          	ld	a5,0(s10)
ffffffffc0204a72:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204a76:	d17fe0ef          	jal	ffffffffc020378c <mm_create>
ffffffffc0204a7a:	892a                	mv	s2,a0
ffffffffc0204a7c:	22050063          	beqz	a0,ffffffffc0204c9c <do_execve+0x2ac>
    if ((page = alloc_page()) == NULL)
ffffffffc0204a80:	4505                	li	a0,1
ffffffffc0204a82:	c7cfd0ef          	jal	ffffffffc0201efe <alloc_pages>
ffffffffc0204a86:	42050063          	beqz	a0,ffffffffc0204ea6 <do_execve+0x4b6>
    return page - pages + nbase;
ffffffffc0204a8a:	f0e2                	sd	s8,96(sp)
ffffffffc0204a8c:	00097c17          	auipc	s8,0x97
ffffffffc0204a90:	0ccc0c13          	addi	s8,s8,204 # ffffffffc029bb58 <pages>
ffffffffc0204a94:	000c3783          	ld	a5,0(s8)
ffffffffc0204a98:	f4de                	sd	s7,104(sp)
ffffffffc0204a9a:	00003b97          	auipc	s7,0x3
ffffffffc0204a9e:	036bbb83          	ld	s7,54(s7) # ffffffffc0207ad0 <nbase>
ffffffffc0204aa2:	40f506b3          	sub	a3,a0,a5
ffffffffc0204aa6:	ece6                	sd	s9,88(sp)
    return KADDR(page2pa(page));
ffffffffc0204aa8:	00097c97          	auipc	s9,0x97
ffffffffc0204aac:	0a8c8c93          	addi	s9,s9,168 # ffffffffc029bb50 <npage>
ffffffffc0204ab0:	f8da                	sd	s6,112(sp)
    return page - pages + nbase;
ffffffffc0204ab2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204ab4:	5b7d                	li	s6,-1
ffffffffc0204ab6:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0204aba:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204abc:	00cb5713          	srli	a4,s6,0xc
ffffffffc0204ac0:	e83a                	sd	a4,16(sp)
ffffffffc0204ac2:	fcd6                	sd	s5,120(sp)
ffffffffc0204ac4:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ac6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ac8:	40f77263          	bgeu	a4,a5,ffffffffc0204ecc <do_execve+0x4dc>
ffffffffc0204acc:	00097a97          	auipc	s5,0x97
ffffffffc0204ad0:	07ca8a93          	addi	s5,s5,124 # ffffffffc029bb48 <va_pa_offset>
ffffffffc0204ad4:	000ab783          	ld	a5,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204ad8:	00097597          	auipc	a1,0x97
ffffffffc0204adc:	0685b583          	ld	a1,104(a1) # ffffffffc029bb40 <boot_pgdir_va>
ffffffffc0204ae0:	6605                	lui	a2,0x1
ffffffffc0204ae2:	00f684b3          	add	s1,a3,a5
ffffffffc0204ae6:	8526                	mv	a0,s1
ffffffffc0204ae8:	62f000ef          	jal	ffffffffc0205916 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204aec:	66e2                	ld	a3,24(sp)
ffffffffc0204aee:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204af2:	00993c23          	sd	s1,24(s2)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204af6:	4298                	lw	a4,0(a3)
ffffffffc0204af8:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464ba377>
ffffffffc0204afc:	06f70863          	beq	a4,a5,ffffffffc0204b6c <do_execve+0x17c>
        ret = -E_INVAL_ELF;
ffffffffc0204b00:	54e1                	li	s1,-8
    put_pgdir(mm);
ffffffffc0204b02:	854a                	mv	a0,s2
ffffffffc0204b04:	daaff0ef          	jal	ffffffffc02040ae <put_pgdir>
ffffffffc0204b08:	7ae6                	ld	s5,120(sp)
ffffffffc0204b0a:	7b46                	ld	s6,112(sp)
ffffffffc0204b0c:	7ba6                	ld	s7,104(sp)
ffffffffc0204b0e:	7c06                	ld	s8,96(sp)
ffffffffc0204b10:	6ce6                	ld	s9,88(sp)
    mm_destroy(mm);
ffffffffc0204b12:	854a                	mv	a0,s2
ffffffffc0204b14:	ea3fe0ef          	jal	ffffffffc02039b6 <mm_destroy>
    do_exit(ret);
ffffffffc0204b18:	8526                	mv	a0,s1
ffffffffc0204b1a:	f122                	sd	s0,160(sp)
ffffffffc0204b1c:	e152                	sd	s4,128(sp)
ffffffffc0204b1e:	fcd6                	sd	s5,120(sp)
ffffffffc0204b20:	f8da                	sd	s6,112(sp)
ffffffffc0204b22:	f4de                	sd	s7,104(sp)
ffffffffc0204b24:	f0e2                	sd	s8,96(sp)
ffffffffc0204b26:	ece6                	sd	s9,88(sp)
ffffffffc0204b28:	e4ee                	sd	s11,72(sp)
ffffffffc0204b2a:	a7dff0ef          	jal	ffffffffc02045a6 <do_exit>
    if (len > PROC_NAME_LEN)
ffffffffc0204b2e:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc0204b30:	85ce                	mv	a1,s3
ffffffffc0204b32:	1808                	addi	a0,sp,48
ffffffffc0204b34:	5e3000ef          	jal	ffffffffc0205916 <memcpy>
    if (mm != NULL)
ffffffffc0204b38:	f00914e3          	bnez	s2,ffffffffc0204a40 <do_execve+0x50>
    if (current->mm != NULL)
ffffffffc0204b3c:	000d3783          	ld	a5,0(s10)
ffffffffc0204b40:	779c                	ld	a5,40(a5)
ffffffffc0204b42:	db95                	beqz	a5,ffffffffc0204a76 <do_execve+0x86>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204b44:	00002617          	auipc	a2,0x2
ffffffffc0204b48:	7cc60613          	addi	a2,a2,1996 # ffffffffc0207310 <etext+0x19e2>
ffffffffc0204b4c:	26400593          	li	a1,612
ffffffffc0204b50:	00002517          	auipc	a0,0x2
ffffffffc0204b54:	5f850513          	addi	a0,a0,1528 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204b58:	f122                	sd	s0,160(sp)
ffffffffc0204b5a:	e152                	sd	s4,128(sp)
ffffffffc0204b5c:	fcd6                	sd	s5,120(sp)
ffffffffc0204b5e:	f8da                	sd	s6,112(sp)
ffffffffc0204b60:	f4de                	sd	s7,104(sp)
ffffffffc0204b62:	f0e2                	sd	s8,96(sp)
ffffffffc0204b64:	ece6                	sd	s9,88(sp)
ffffffffc0204b66:	e4ee                	sd	s11,72(sp)
ffffffffc0204b68:	8dffb0ef          	jal	ffffffffc0200446 <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b6c:	0386d703          	lhu	a4,56(a3)
ffffffffc0204b70:	e152                	sd	s4,128(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b72:	0206ba03          	ld	s4,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b76:	00371793          	slli	a5,a4,0x3
ffffffffc0204b7a:	8f99                	sub	a5,a5,a4
ffffffffc0204b7c:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b7e:	9a36                	add	s4,s4,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b80:	97d2                	add	a5,a5,s4
ffffffffc0204b82:	f122                	sd	s0,160(sp)
ffffffffc0204b84:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204b86:	00fa7e63          	bgeu	s4,a5,ffffffffc0204ba2 <do_execve+0x1b2>
ffffffffc0204b8a:	e4ee                	sd	s11,72(sp)
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204b8c:	000a2783          	lw	a5,0(s4)
ffffffffc0204b90:	4705                	li	a4,1
ffffffffc0204b92:	10e78763          	beq	a5,a4,ffffffffc0204ca0 <do_execve+0x2b0>
    for (; ph < ph_end; ph++)
ffffffffc0204b96:	77a2                	ld	a5,40(sp)
ffffffffc0204b98:	038a0a13          	addi	s4,s4,56
ffffffffc0204b9c:	fefa68e3          	bltu	s4,a5,ffffffffc0204b8c <do_execve+0x19c>
ffffffffc0204ba0:	6da6                	ld	s11,72(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204ba2:	4701                	li	a4,0
ffffffffc0204ba4:	46ad                	li	a3,11
ffffffffc0204ba6:	00100637          	lui	a2,0x100
ffffffffc0204baa:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204bae:	854a                	mv	a0,s2
ffffffffc0204bb0:	e59fe0ef          	jal	ffffffffc0203a08 <mm_map>
ffffffffc0204bb4:	84aa                	mv	s1,a0
ffffffffc0204bb6:	1a051963          	bnez	a0,ffffffffc0204d68 <do_execve+0x378>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204bba:	01893503          	ld	a0,24(s2)
ffffffffc0204bbe:	467d                	li	a2,31
ffffffffc0204bc0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204bc4:	ae7fe0ef          	jal	ffffffffc02036aa <pgdir_alloc_page>
ffffffffc0204bc8:	3a050163          	beqz	a0,ffffffffc0204f6a <do_execve+0x57a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bcc:	01893503          	ld	a0,24(s2)
ffffffffc0204bd0:	467d                	li	a2,31
ffffffffc0204bd2:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204bd6:	ad5fe0ef          	jal	ffffffffc02036aa <pgdir_alloc_page>
ffffffffc0204bda:	36050763          	beqz	a0,ffffffffc0204f48 <do_execve+0x558>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bde:	01893503          	ld	a0,24(s2)
ffffffffc0204be2:	467d                	li	a2,31
ffffffffc0204be4:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204be8:	ac3fe0ef          	jal	ffffffffc02036aa <pgdir_alloc_page>
ffffffffc0204bec:	32050d63          	beqz	a0,ffffffffc0204f26 <do_execve+0x536>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bf0:	01893503          	ld	a0,24(s2)
ffffffffc0204bf4:	467d                	li	a2,31
ffffffffc0204bf6:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204bfa:	ab1fe0ef          	jal	ffffffffc02036aa <pgdir_alloc_page>
ffffffffc0204bfe:	30050363          	beqz	a0,ffffffffc0204f04 <do_execve+0x514>
    mm->mm_count += 1;
ffffffffc0204c02:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0204c06:	000d3603          	ld	a2,0(s10)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204c0a:	01893683          	ld	a3,24(s2)
ffffffffc0204c0e:	2785                	addiw	a5,a5,1
ffffffffc0204c10:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0204c14:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5e20>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204c18:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c1c:	2cf6e763          	bltu	a3,a5,ffffffffc0204eea <do_execve+0x4fa>
ffffffffc0204c20:	000ab783          	ld	a5,0(s5)
ffffffffc0204c24:	577d                	li	a4,-1
ffffffffc0204c26:	177e                	slli	a4,a4,0x3f
ffffffffc0204c28:	8e9d                	sub	a3,a3,a5
ffffffffc0204c2a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204c2e:	f654                	sd	a3,168(a2)
ffffffffc0204c30:	8fd9                	or	a5,a5,a4
ffffffffc0204c32:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204c36:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c38:	4581                	li	a1,0
ffffffffc0204c3a:	12000613          	li	a2,288
ffffffffc0204c3e:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204c40:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c44:	4c1000ef          	jal	ffffffffc0205904 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204c48:	67e2                	ld	a5,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c4a:	000d3983          	ld	s3,0(s10)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204c4e:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;
ffffffffc0204c52:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204c54:	4785                	li	a5,1
ffffffffc0204c56:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204c58:	02096913          	ori	s2,s2,32
    tf->epc = elf->e_entry;
ffffffffc0204c5c:	10e43423          	sd	a4,264(s0)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204c60:	e81c                	sd	a5,16(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204c62:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c66:	4641                	li	a2,16
ffffffffc0204c68:	4581                	li	a1,0
ffffffffc0204c6a:	0b498513          	addi	a0,s3,180
ffffffffc0204c6e:	497000ef          	jal	ffffffffc0205904 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204c72:	180c                	addi	a1,sp,48
ffffffffc0204c74:	0b498513          	addi	a0,s3,180
ffffffffc0204c78:	463d                	li	a2,15
ffffffffc0204c7a:	49d000ef          	jal	ffffffffc0205916 <memcpy>
ffffffffc0204c7e:	740a                	ld	s0,160(sp)
ffffffffc0204c80:	6a0a                	ld	s4,128(sp)
ffffffffc0204c82:	7ae6                	ld	s5,120(sp)
ffffffffc0204c84:	7b46                	ld	s6,112(sp)
ffffffffc0204c86:	7ba6                	ld	s7,104(sp)
ffffffffc0204c88:	7c06                	ld	s8,96(sp)
ffffffffc0204c8a:	6ce6                	ld	s9,88(sp)
}
ffffffffc0204c8c:	70aa                	ld	ra,168(sp)
ffffffffc0204c8e:	694a                	ld	s2,144(sp)
ffffffffc0204c90:	69aa                	ld	s3,136(sp)
ffffffffc0204c92:	6d46                	ld	s10,80(sp)
ffffffffc0204c94:	8526                	mv	a0,s1
ffffffffc0204c96:	64ea                	ld	s1,152(sp)
ffffffffc0204c98:	614d                	addi	sp,sp,176
ffffffffc0204c9a:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0204c9c:	54f1                	li	s1,-4
ffffffffc0204c9e:	bdad                	j	ffffffffc0204b18 <do_execve+0x128>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204ca0:	028a3603          	ld	a2,40(s4)
ffffffffc0204ca4:	020a3783          	ld	a5,32(s4)
ffffffffc0204ca8:	20f66363          	bltu	a2,a5,ffffffffc0204eae <do_execve+0x4be>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204cac:	004a2783          	lw	a5,4(s4)
ffffffffc0204cb0:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204cb4:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204cb8:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204cba:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204cbc:	c6f1                	beqz	a3,ffffffffc0204d88 <do_execve+0x398>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204cbe:	1c079763          	bnez	a5,ffffffffc0204e8c <do_execve+0x49c>
            perm |= (PTE_W | PTE_R);
ffffffffc0204cc2:	47dd                	li	a5,23
            vm_flags |= VM_WRITE;
ffffffffc0204cc4:	00276693          	ori	a3,a4,2
            perm |= (PTE_W | PTE_R);
ffffffffc0204cc8:	e43e                	sd	a5,8(sp)
        if (vm_flags & VM_EXEC)
ffffffffc0204cca:	c709                	beqz	a4,ffffffffc0204cd4 <do_execve+0x2e4>
            perm |= PTE_X;
ffffffffc0204ccc:	67a2                	ld	a5,8(sp)
ffffffffc0204cce:	0087e793          	ori	a5,a5,8
ffffffffc0204cd2:	e43e                	sd	a5,8(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204cd4:	010a3583          	ld	a1,16(s4)
ffffffffc0204cd8:	4701                	li	a4,0
ffffffffc0204cda:	854a                	mv	a0,s2
ffffffffc0204cdc:	d2dfe0ef          	jal	ffffffffc0203a08 <mm_map>
ffffffffc0204ce0:	84aa                	mv	s1,a0
ffffffffc0204ce2:	1c051463          	bnez	a0,ffffffffc0204eaa <do_execve+0x4ba>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204ce6:	010a3b03          	ld	s6,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204cea:	020a3483          	ld	s1,32(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204cee:	77fd                	lui	a5,0xfffff
ffffffffc0204cf0:	00fb75b3          	and	a1,s6,a5
        end = ph->p_va + ph->p_filesz;
ffffffffc0204cf4:	94da                	add	s1,s1,s6
        while (start < end)
ffffffffc0204cf6:	1a9b7563          	bgeu	s6,s1,ffffffffc0204ea0 <do_execve+0x4b0>
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204cfa:	008a3983          	ld	s3,8(s4)
ffffffffc0204cfe:	67e2                	ld	a5,24(sp)
ffffffffc0204d00:	99be                	add	s3,s3,a5
ffffffffc0204d02:	a881                	j	ffffffffc0204d52 <do_execve+0x362>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d04:	6785                	lui	a5,0x1
ffffffffc0204d06:	00f58db3          	add	s11,a1,a5
                size -= la - end;
ffffffffc0204d0a:	41648633          	sub	a2,s1,s6
            if (end < la)
ffffffffc0204d0e:	01b4e463          	bltu	s1,s11,ffffffffc0204d16 <do_execve+0x326>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d12:	416d8633          	sub	a2,s11,s6
    return page - pages + nbase;
ffffffffc0204d16:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204d1a:	67c2                	ld	a5,16(sp)
ffffffffc0204d1c:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc0204d20:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d24:	8699                	srai	a3,a3,0x6
ffffffffc0204d26:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204d28:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d2c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d2e:	18a87363          	bgeu	a6,a0,ffffffffc0204eb4 <do_execve+0x4c4>
ffffffffc0204d32:	000ab503          	ld	a0,0(s5)
ffffffffc0204d36:	40bb05b3          	sub	a1,s6,a1
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204d3a:	e032                	sd	a2,0(sp)
ffffffffc0204d3c:	9536                	add	a0,a0,a3
ffffffffc0204d3e:	952e                	add	a0,a0,a1
ffffffffc0204d40:	85ce                	mv	a1,s3
ffffffffc0204d42:	3d5000ef          	jal	ffffffffc0205916 <memcpy>
            start += size, from += size;
ffffffffc0204d46:	6602                	ld	a2,0(sp)
ffffffffc0204d48:	9b32                	add	s6,s6,a2
ffffffffc0204d4a:	99b2                	add	s3,s3,a2
        while (start < end)
ffffffffc0204d4c:	049b7563          	bgeu	s6,s1,ffffffffc0204d96 <do_execve+0x3a6>
ffffffffc0204d50:	85ee                	mv	a1,s11
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204d52:	01893503          	ld	a0,24(s2)
ffffffffc0204d56:	6622                	ld	a2,8(sp)
ffffffffc0204d58:	e02e                	sd	a1,0(sp)
ffffffffc0204d5a:	951fe0ef          	jal	ffffffffc02036aa <pgdir_alloc_page>
ffffffffc0204d5e:	6582                	ld	a1,0(sp)
ffffffffc0204d60:	842a                	mv	s0,a0
ffffffffc0204d62:	f14d                	bnez	a0,ffffffffc0204d04 <do_execve+0x314>
ffffffffc0204d64:	6da6                	ld	s11,72(sp)
        ret = -E_NO_MEM;
ffffffffc0204d66:	54f1                	li	s1,-4
    exit_mmap(mm);
ffffffffc0204d68:	854a                	mv	a0,s2
ffffffffc0204d6a:	e03fe0ef          	jal	ffffffffc0203b6c <exit_mmap>
ffffffffc0204d6e:	740a                	ld	s0,160(sp)
ffffffffc0204d70:	6a0a                	ld	s4,128(sp)
ffffffffc0204d72:	bb41                	j	ffffffffc0204b02 <do_execve+0x112>
            exit_mmap(mm);
ffffffffc0204d74:	854a                	mv	a0,s2
ffffffffc0204d76:	df7fe0ef          	jal	ffffffffc0203b6c <exit_mmap>
            put_pgdir(mm);
ffffffffc0204d7a:	854a                	mv	a0,s2
ffffffffc0204d7c:	b32ff0ef          	jal	ffffffffc02040ae <put_pgdir>
            mm_destroy(mm);
ffffffffc0204d80:	854a                	mv	a0,s2
ffffffffc0204d82:	c35fe0ef          	jal	ffffffffc02039b6 <mm_destroy>
ffffffffc0204d86:	b1e5                	j	ffffffffc0204a6e <do_execve+0x7e>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204d88:	0e078e63          	beqz	a5,ffffffffc0204e84 <do_execve+0x494>
            perm |= PTE_R;
ffffffffc0204d8c:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc0204d8e:	00176693          	ori	a3,a4,1
            perm |= PTE_R;
ffffffffc0204d92:	e43e                	sd	a5,8(sp)
ffffffffc0204d94:	bf1d                	j	ffffffffc0204cca <do_execve+0x2da>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204d96:	010a3483          	ld	s1,16(s4)
ffffffffc0204d9a:	028a3683          	ld	a3,40(s4)
ffffffffc0204d9e:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc0204da0:	07bb7c63          	bgeu	s6,s11,ffffffffc0204e18 <do_execve+0x428>
            if (start == end)
ffffffffc0204da4:	df6489e3          	beq	s1,s6,ffffffffc0204b96 <do_execve+0x1a6>
                size -= la - end;
ffffffffc0204da8:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204dac:	0fb4f563          	bgeu	s1,s11,ffffffffc0204e96 <do_execve+0x4a6>
    return page - pages + nbase;
ffffffffc0204db0:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204db4:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0204db8:	40d406b3          	sub	a3,s0,a3
ffffffffc0204dbc:	8699                	srai	a3,a3,0x6
ffffffffc0204dbe:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204dc0:	00c69593          	slli	a1,a3,0xc
ffffffffc0204dc4:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204dc6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204dc8:	0ec5f663          	bgeu	a1,a2,ffffffffc0204eb4 <do_execve+0x4c4>
ffffffffc0204dcc:	000ab603          	ld	a2,0(s5)
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204dd0:	6505                	lui	a0,0x1
ffffffffc0204dd2:	955a                	add	a0,a0,s6
ffffffffc0204dd4:	96b2                	add	a3,a3,a2
ffffffffc0204dd6:	41b50533          	sub	a0,a0,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204dda:	9536                	add	a0,a0,a3
ffffffffc0204ddc:	864e                	mv	a2,s3
ffffffffc0204dde:	4581                	li	a1,0
ffffffffc0204de0:	325000ef          	jal	ffffffffc0205904 <memset>
            start += size;
ffffffffc0204de4:	9b4e                	add	s6,s6,s3
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204de6:	01b4b6b3          	sltu	a3,s1,s11
ffffffffc0204dea:	01b4f463          	bgeu	s1,s11,ffffffffc0204df2 <do_execve+0x402>
ffffffffc0204dee:	db6484e3          	beq	s1,s6,ffffffffc0204b96 <do_execve+0x1a6>
ffffffffc0204df2:	e299                	bnez	a3,ffffffffc0204df8 <do_execve+0x408>
ffffffffc0204df4:	03bb0263          	beq	s6,s11,ffffffffc0204e18 <do_execve+0x428>
ffffffffc0204df8:	00002697          	auipc	a3,0x2
ffffffffc0204dfc:	54068693          	addi	a3,a3,1344 # ffffffffc0207338 <etext+0x1a0a>
ffffffffc0204e00:	00001617          	auipc	a2,0x1
ffffffffc0204e04:	57860613          	addi	a2,a2,1400 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0204e08:	2cd00593          	li	a1,717
ffffffffc0204e0c:	00002517          	auipc	a0,0x2
ffffffffc0204e10:	33c50513          	addi	a0,a0,828 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204e14:	e32fb0ef          	jal	ffffffffc0200446 <__panic>
        while (start < end)
ffffffffc0204e18:	d69b7fe3          	bgeu	s6,s1,ffffffffc0204b96 <do_execve+0x1a6>
ffffffffc0204e1c:	56fd                	li	a3,-1
ffffffffc0204e1e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204e22:	f03e                	sd	a5,32(sp)
ffffffffc0204e24:	a0b9                	j	ffffffffc0204e72 <do_execve+0x482>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e26:	6785                	lui	a5,0x1
ffffffffc0204e28:	00fd8833          	add	a6,s11,a5
                size -= la - end;
ffffffffc0204e2c:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204e30:	0104e463          	bltu	s1,a6,ffffffffc0204e38 <do_execve+0x448>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e34:	416809b3          	sub	s3,a6,s6
    return page - pages + nbase;
ffffffffc0204e38:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204e3c:	7782                	ld	a5,32(sp)
ffffffffc0204e3e:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0204e42:	40d406b3          	sub	a3,s0,a3
ffffffffc0204e46:	8699                	srai	a3,a3,0x6
ffffffffc0204e48:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204e4a:	00f6f533          	and	a0,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e4e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e50:	06b57263          	bgeu	a0,a1,ffffffffc0204eb4 <do_execve+0x4c4>
ffffffffc0204e54:	000ab583          	ld	a1,0(s5)
ffffffffc0204e58:	41bb0533          	sub	a0,s6,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e5c:	864e                	mv	a2,s3
ffffffffc0204e5e:	96ae                	add	a3,a3,a1
ffffffffc0204e60:	9536                	add	a0,a0,a3
ffffffffc0204e62:	4581                	li	a1,0
            start += size;
ffffffffc0204e64:	9b4e                	add	s6,s6,s3
ffffffffc0204e66:	e042                	sd	a6,0(sp)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e68:	29d000ef          	jal	ffffffffc0205904 <memset>
        while (start < end)
ffffffffc0204e6c:	d29b75e3          	bgeu	s6,s1,ffffffffc0204b96 <do_execve+0x1a6>
ffffffffc0204e70:	6d82                	ld	s11,0(sp)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204e72:	01893503          	ld	a0,24(s2)
ffffffffc0204e76:	6622                	ld	a2,8(sp)
ffffffffc0204e78:	85ee                	mv	a1,s11
ffffffffc0204e7a:	831fe0ef          	jal	ffffffffc02036aa <pgdir_alloc_page>
ffffffffc0204e7e:	842a                	mv	s0,a0
ffffffffc0204e80:	f15d                	bnez	a0,ffffffffc0204e26 <do_execve+0x436>
ffffffffc0204e82:	b5cd                	j	ffffffffc0204d64 <do_execve+0x374>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e84:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e86:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e88:	e43e                	sd	a5,8(sp)
ffffffffc0204e8a:	b581                	j	ffffffffc0204cca <do_execve+0x2da>
            perm |= (PTE_W | PTE_R);
ffffffffc0204e8c:	47dd                	li	a5,23
            vm_flags |= VM_READ;
ffffffffc0204e8e:	00376693          	ori	a3,a4,3
            perm |= (PTE_W | PTE_R);
ffffffffc0204e92:	e43e                	sd	a5,8(sp)
ffffffffc0204e94:	bd1d                	j	ffffffffc0204cca <do_execve+0x2da>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204e96:	416d89b3          	sub	s3,s11,s6
ffffffffc0204e9a:	bf19                	j	ffffffffc0204db0 <do_execve+0x3c0>
        return -E_INVAL;
ffffffffc0204e9c:	54f5                	li	s1,-3
ffffffffc0204e9e:	b3fd                	j	ffffffffc0204c8c <do_execve+0x29c>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204ea0:	8dae                	mv	s11,a1
        while (start < end)
ffffffffc0204ea2:	84da                	mv	s1,s6
ffffffffc0204ea4:	bddd                	j	ffffffffc0204d9a <do_execve+0x3aa>
    int ret = -E_NO_MEM;
ffffffffc0204ea6:	54f1                	li	s1,-4
ffffffffc0204ea8:	b1ad                	j	ffffffffc0204b12 <do_execve+0x122>
ffffffffc0204eaa:	6da6                	ld	s11,72(sp)
ffffffffc0204eac:	bd75                	j	ffffffffc0204d68 <do_execve+0x378>
            ret = -E_INVAL_ELF;
ffffffffc0204eae:	6da6                	ld	s11,72(sp)
ffffffffc0204eb0:	54e1                	li	s1,-8
ffffffffc0204eb2:	bd5d                	j	ffffffffc0204d68 <do_execve+0x378>
ffffffffc0204eb4:	00002617          	auipc	a2,0x2
ffffffffc0204eb8:	87460613          	addi	a2,a2,-1932 # ffffffffc0206728 <etext+0xdfa>
ffffffffc0204ebc:	07100593          	li	a1,113
ffffffffc0204ec0:	00002517          	auipc	a0,0x2
ffffffffc0204ec4:	89050513          	addi	a0,a0,-1904 # ffffffffc0206750 <etext+0xe22>
ffffffffc0204ec8:	d7efb0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0204ecc:	00002617          	auipc	a2,0x2
ffffffffc0204ed0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206728 <etext+0xdfa>
ffffffffc0204ed4:	07100593          	li	a1,113
ffffffffc0204ed8:	00002517          	auipc	a0,0x2
ffffffffc0204edc:	87850513          	addi	a0,a0,-1928 # ffffffffc0206750 <etext+0xe22>
ffffffffc0204ee0:	f122                	sd	s0,160(sp)
ffffffffc0204ee2:	e152                	sd	s4,128(sp)
ffffffffc0204ee4:	e4ee                	sd	s11,72(sp)
ffffffffc0204ee6:	d60fb0ef          	jal	ffffffffc0200446 <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204eea:	00002617          	auipc	a2,0x2
ffffffffc0204eee:	8e660613          	addi	a2,a2,-1818 # ffffffffc02067d0 <etext+0xea2>
ffffffffc0204ef2:	2ec00593          	li	a1,748
ffffffffc0204ef6:	00002517          	auipc	a0,0x2
ffffffffc0204efa:	25250513          	addi	a0,a0,594 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204efe:	e4ee                	sd	s11,72(sp)
ffffffffc0204f00:	d46fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f04:	00002697          	auipc	a3,0x2
ffffffffc0204f08:	54c68693          	addi	a3,a3,1356 # ffffffffc0207450 <etext+0x1b22>
ffffffffc0204f0c:	00001617          	auipc	a2,0x1
ffffffffc0204f10:	46c60613          	addi	a2,a2,1132 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0204f14:	2e700593          	li	a1,743
ffffffffc0204f18:	00002517          	auipc	a0,0x2
ffffffffc0204f1c:	23050513          	addi	a0,a0,560 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204f20:	e4ee                	sd	s11,72(sp)
ffffffffc0204f22:	d24fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f26:	00002697          	auipc	a3,0x2
ffffffffc0204f2a:	4e268693          	addi	a3,a3,1250 # ffffffffc0207408 <etext+0x1ada>
ffffffffc0204f2e:	00001617          	auipc	a2,0x1
ffffffffc0204f32:	44a60613          	addi	a2,a2,1098 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0204f36:	2e600593          	li	a1,742
ffffffffc0204f3a:	00002517          	auipc	a0,0x2
ffffffffc0204f3e:	20e50513          	addi	a0,a0,526 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204f42:	e4ee                	sd	s11,72(sp)
ffffffffc0204f44:	d02fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f48:	00002697          	auipc	a3,0x2
ffffffffc0204f4c:	47868693          	addi	a3,a3,1144 # ffffffffc02073c0 <etext+0x1a92>
ffffffffc0204f50:	00001617          	auipc	a2,0x1
ffffffffc0204f54:	42860613          	addi	a2,a2,1064 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0204f58:	2e500593          	li	a1,741
ffffffffc0204f5c:	00002517          	auipc	a0,0x2
ffffffffc0204f60:	1ec50513          	addi	a0,a0,492 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204f64:	e4ee                	sd	s11,72(sp)
ffffffffc0204f66:	ce0fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204f6a:	00002697          	auipc	a3,0x2
ffffffffc0204f6e:	40e68693          	addi	a3,a3,1038 # ffffffffc0207378 <etext+0x1a4a>
ffffffffc0204f72:	00001617          	auipc	a2,0x1
ffffffffc0204f76:	40660613          	addi	a2,a2,1030 # ffffffffc0206378 <etext+0xa4a>
ffffffffc0204f7a:	2e400593          	li	a1,740
ffffffffc0204f7e:	00002517          	auipc	a0,0x2
ffffffffc0204f82:	1ca50513          	addi	a0,a0,458 # ffffffffc0207148 <etext+0x181a>
ffffffffc0204f86:	e4ee                	sd	s11,72(sp)
ffffffffc0204f88:	cbefb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204f8c <do_yield>:
    current->need_resched = 1;
ffffffffc0204f8c:	00097797          	auipc	a5,0x97
ffffffffc0204f90:	bdc7b783          	ld	a5,-1060(a5) # ffffffffc029bb68 <current>
ffffffffc0204f94:	4705                	li	a4,1
}
ffffffffc0204f96:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0204f98:	ef98                	sd	a4,24(a5)
}
ffffffffc0204f9a:	8082                	ret

ffffffffc0204f9c <do_wait>:
    if (code_store != NULL)
ffffffffc0204f9c:	c59d                	beqz	a1,ffffffffc0204fca <do_wait+0x2e>
{
ffffffffc0204f9e:	1101                	addi	sp,sp,-32
ffffffffc0204fa0:	e02a                	sd	a0,0(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204fa2:	00097517          	auipc	a0,0x97
ffffffffc0204fa6:	bc653503          	ld	a0,-1082(a0) # ffffffffc029bb68 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204faa:	4685                	li	a3,1
ffffffffc0204fac:	4611                	li	a2,4
ffffffffc0204fae:	7508                	ld	a0,40(a0)
{
ffffffffc0204fb0:	ec06                	sd	ra,24(sp)
ffffffffc0204fb2:	e42e                	sd	a1,8(sp)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204fb4:	f51fe0ef          	jal	ffffffffc0203f04 <user_mem_check>
ffffffffc0204fb8:	6702                	ld	a4,0(sp)
ffffffffc0204fba:	67a2                	ld	a5,8(sp)
ffffffffc0204fbc:	c909                	beqz	a0,ffffffffc0204fce <do_wait+0x32>
}
ffffffffc0204fbe:	60e2                	ld	ra,24(sp)
ffffffffc0204fc0:	85be                	mv	a1,a5
ffffffffc0204fc2:	853a                	mv	a0,a4
ffffffffc0204fc4:	6105                	addi	sp,sp,32
ffffffffc0204fc6:	f24ff06f          	j	ffffffffc02046ea <do_wait.part.0>
ffffffffc0204fca:	f20ff06f          	j	ffffffffc02046ea <do_wait.part.0>
ffffffffc0204fce:	60e2                	ld	ra,24(sp)
ffffffffc0204fd0:	5575                	li	a0,-3
ffffffffc0204fd2:	6105                	addi	sp,sp,32
ffffffffc0204fd4:	8082                	ret

ffffffffc0204fd6 <do_kill>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0204fd6:	6789                	lui	a5,0x2
ffffffffc0204fd8:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204fdc:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6c12>
ffffffffc0204fde:	06e7e463          	bltu	a5,a4,ffffffffc0205046 <do_kill+0x70>
{
ffffffffc0204fe2:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fe4:	45a9                	li	a1,10
{
ffffffffc0204fe6:	ec06                	sd	ra,24(sp)
ffffffffc0204fe8:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fea:	484000ef          	jal	ffffffffc020546e <hash32>
ffffffffc0204fee:	02051793          	slli	a5,a0,0x20
ffffffffc0204ff2:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204ff6:	00093797          	auipc	a5,0x93
ffffffffc0204ffa:	afa78793          	addi	a5,a5,-1286 # ffffffffc0297af0 <hash_list>
ffffffffc0204ffe:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc0205000:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205002:	8536                	mv	a0,a3
        while ((le = list_next(le)) != list)
ffffffffc0205004:	a029                	j	ffffffffc020500e <do_kill+0x38>
            if (proc->pid == pid)
ffffffffc0205006:	f2c52703          	lw	a4,-212(a0)
ffffffffc020500a:	00c70963          	beq	a4,a2,ffffffffc020501c <do_kill+0x46>
ffffffffc020500e:	6508                	ld	a0,8(a0)
        while ((le = list_next(le)) != list)
ffffffffc0205010:	fea69be3          	bne	a3,a0,ffffffffc0205006 <do_kill+0x30>
}
ffffffffc0205014:	60e2                	ld	ra,24(sp)
    return -E_INVAL;
ffffffffc0205016:	5575                	li	a0,-3
}
ffffffffc0205018:	6105                	addi	sp,sp,32
ffffffffc020501a:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc020501c:	fd852703          	lw	a4,-40(a0)
ffffffffc0205020:	00177693          	andi	a3,a4,1
ffffffffc0205024:	e29d                	bnez	a3,ffffffffc020504a <do_kill+0x74>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205026:	4954                	lw	a3,20(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205028:	00176713          	ori	a4,a4,1
ffffffffc020502c:	fce52c23          	sw	a4,-40(a0)
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205030:	0006c663          	bltz	a3,ffffffffc020503c <do_kill+0x66>
            return 0;
ffffffffc0205034:	4501                	li	a0,0
}
ffffffffc0205036:	60e2                	ld	ra,24(sp)
ffffffffc0205038:	6105                	addi	sp,sp,32
ffffffffc020503a:	8082                	ret
                wakeup_proc(proc);
ffffffffc020503c:	f2850513          	addi	a0,a0,-216
ffffffffc0205040:	232000ef          	jal	ffffffffc0205272 <wakeup_proc>
ffffffffc0205044:	bfc5                	j	ffffffffc0205034 <do_kill+0x5e>
    return -E_INVAL;
ffffffffc0205046:	5575                	li	a0,-3
}
ffffffffc0205048:	8082                	ret
        return -E_KILLED;
ffffffffc020504a:	555d                	li	a0,-9
ffffffffc020504c:	b7ed                	j	ffffffffc0205036 <do_kill+0x60>

ffffffffc020504e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc020504e:	1101                	addi	sp,sp,-32
ffffffffc0205050:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205052:	00097797          	auipc	a5,0x97
ffffffffc0205056:	a9e78793          	addi	a5,a5,-1378 # ffffffffc029baf0 <proc_list>
ffffffffc020505a:	ec06                	sd	ra,24(sp)
ffffffffc020505c:	e822                	sd	s0,16(sp)
ffffffffc020505e:	e04a                	sd	s2,0(sp)
ffffffffc0205060:	00093497          	auipc	s1,0x93
ffffffffc0205064:	a9048493          	addi	s1,s1,-1392 # ffffffffc0297af0 <hash_list>
ffffffffc0205068:	e79c                	sd	a5,8(a5)
ffffffffc020506a:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc020506c:	00097717          	auipc	a4,0x97
ffffffffc0205070:	a8470713          	addi	a4,a4,-1404 # ffffffffc029baf0 <proc_list>
ffffffffc0205074:	87a6                	mv	a5,s1
ffffffffc0205076:	e79c                	sd	a5,8(a5)
ffffffffc0205078:	e39c                	sd	a5,0(a5)
ffffffffc020507a:	07c1                	addi	a5,a5,16
ffffffffc020507c:	fee79de3          	bne	a5,a4,ffffffffc0205076 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0205080:	f31fe0ef          	jal	ffffffffc0203fb0 <alloc_proc>
ffffffffc0205084:	00097917          	auipc	s2,0x97
ffffffffc0205088:	af490913          	addi	s2,s2,-1292 # ffffffffc029bb78 <idleproc>
ffffffffc020508c:	00a93023          	sd	a0,0(s2)
ffffffffc0205090:	10050363          	beqz	a0,ffffffffc0205196 <proc_init+0x148>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205094:	4789                	li	a5,2
ffffffffc0205096:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205098:	00003797          	auipc	a5,0x3
ffffffffc020509c:	f6878793          	addi	a5,a5,-152 # ffffffffc0208000 <bootstack>
ffffffffc02050a0:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050a2:	0b450413          	addi	s0,a0,180
    idleproc->need_resched = 1;
ffffffffc02050a6:	4785                	li	a5,1
ffffffffc02050a8:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050aa:	4641                	li	a2,16
ffffffffc02050ac:	8522                	mv	a0,s0
ffffffffc02050ae:	4581                	li	a1,0
ffffffffc02050b0:	055000ef          	jal	ffffffffc0205904 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050b4:	8522                	mv	a0,s0
ffffffffc02050b6:	463d                	li	a2,15
ffffffffc02050b8:	00002597          	auipc	a1,0x2
ffffffffc02050bc:	3f858593          	addi	a1,a1,1016 # ffffffffc02074b0 <etext+0x1b82>
ffffffffc02050c0:	057000ef          	jal	ffffffffc0205916 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc02050c4:	00097797          	auipc	a5,0x97
ffffffffc02050c8:	a9c7a783          	lw	a5,-1380(a5) # ffffffffc029bb60 <nr_process>

    current = idleproc;
ffffffffc02050cc:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02050d0:	4601                	li	a2,0
    nr_process++;
ffffffffc02050d2:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02050d4:	4581                	li	a1,0
ffffffffc02050d6:	fffff517          	auipc	a0,0xfffff
ffffffffc02050da:	7f650513          	addi	a0,a0,2038 # ffffffffc02048cc <init_main>
    current = idleproc;
ffffffffc02050de:	00097697          	auipc	a3,0x97
ffffffffc02050e2:	a8e6b523          	sd	a4,-1398(a3) # ffffffffc029bb68 <current>
    nr_process++;
ffffffffc02050e6:	00097717          	auipc	a4,0x97
ffffffffc02050ea:	a6f72d23          	sw	a5,-1414(a4) # ffffffffc029bb60 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02050ee:	c68ff0ef          	jal	ffffffffc0204556 <kernel_thread>
ffffffffc02050f2:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc02050f4:	08a05563          	blez	a0,ffffffffc020517e <proc_init+0x130>
    if (0 < pid && pid < MAX_PID)
ffffffffc02050f8:	6789                	lui	a5,0x2
ffffffffc02050fa:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6c12>
ffffffffc02050fc:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205100:	02e7e463          	bltu	a5,a4,ffffffffc0205128 <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205104:	45a9                	li	a1,10
ffffffffc0205106:	368000ef          	jal	ffffffffc020546e <hash32>
ffffffffc020510a:	02051713          	slli	a4,a0,0x20
ffffffffc020510e:	01c75793          	srli	a5,a4,0x1c
ffffffffc0205112:	00f486b3          	add	a3,s1,a5
ffffffffc0205116:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205118:	a029                	j	ffffffffc0205122 <proc_init+0xd4>
            if (proc->pid == pid)
ffffffffc020511a:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020511e:	04870d63          	beq	a4,s0,ffffffffc0205178 <proc_init+0x12a>
    return listelm->next;
ffffffffc0205122:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205124:	fef69be3          	bne	a3,a5,ffffffffc020511a <proc_init+0xcc>
    return NULL;
ffffffffc0205128:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020512a:	0b478413          	addi	s0,a5,180
ffffffffc020512e:	4641                	li	a2,16
ffffffffc0205130:	4581                	li	a1,0
ffffffffc0205132:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205134:	00097717          	auipc	a4,0x97
ffffffffc0205138:	a2f73e23          	sd	a5,-1476(a4) # ffffffffc029bb70 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020513c:	7c8000ef          	jal	ffffffffc0205904 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205140:	8522                	mv	a0,s0
ffffffffc0205142:	463d                	li	a2,15
ffffffffc0205144:	00002597          	auipc	a1,0x2
ffffffffc0205148:	39458593          	addi	a1,a1,916 # ffffffffc02074d8 <etext+0x1baa>
ffffffffc020514c:	7ca000ef          	jal	ffffffffc0205916 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205150:	00093783          	ld	a5,0(s2)
ffffffffc0205154:	cfad                	beqz	a5,ffffffffc02051ce <proc_init+0x180>
ffffffffc0205156:	43dc                	lw	a5,4(a5)
ffffffffc0205158:	ebbd                	bnez	a5,ffffffffc02051ce <proc_init+0x180>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020515a:	00097797          	auipc	a5,0x97
ffffffffc020515e:	a167b783          	ld	a5,-1514(a5) # ffffffffc029bb70 <initproc>
ffffffffc0205162:	c7b1                	beqz	a5,ffffffffc02051ae <proc_init+0x160>
ffffffffc0205164:	43d8                	lw	a4,4(a5)
ffffffffc0205166:	4785                	li	a5,1
ffffffffc0205168:	04f71363          	bne	a4,a5,ffffffffc02051ae <proc_init+0x160>
}
ffffffffc020516c:	60e2                	ld	ra,24(sp)
ffffffffc020516e:	6442                	ld	s0,16(sp)
ffffffffc0205170:	64a2                	ld	s1,8(sp)
ffffffffc0205172:	6902                	ld	s2,0(sp)
ffffffffc0205174:	6105                	addi	sp,sp,32
ffffffffc0205176:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205178:	f2878793          	addi	a5,a5,-216
ffffffffc020517c:	b77d                	j	ffffffffc020512a <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc020517e:	00002617          	auipc	a2,0x2
ffffffffc0205182:	33a60613          	addi	a2,a2,826 # ffffffffc02074b8 <etext+0x1b8a>
ffffffffc0205186:	41000593          	li	a1,1040
ffffffffc020518a:	00002517          	auipc	a0,0x2
ffffffffc020518e:	fbe50513          	addi	a0,a0,-66 # ffffffffc0207148 <etext+0x181a>
ffffffffc0205192:	ab4fb0ef          	jal	ffffffffc0200446 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205196:	00002617          	auipc	a2,0x2
ffffffffc020519a:	30260613          	addi	a2,a2,770 # ffffffffc0207498 <etext+0x1b6a>
ffffffffc020519e:	40100593          	li	a1,1025
ffffffffc02051a2:	00002517          	auipc	a0,0x2
ffffffffc02051a6:	fa650513          	addi	a0,a0,-90 # ffffffffc0207148 <etext+0x181a>
ffffffffc02051aa:	a9cfb0ef          	jal	ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02051ae:	00002697          	auipc	a3,0x2
ffffffffc02051b2:	35a68693          	addi	a3,a3,858 # ffffffffc0207508 <etext+0x1bda>
ffffffffc02051b6:	00001617          	auipc	a2,0x1
ffffffffc02051ba:	1c260613          	addi	a2,a2,450 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02051be:	41700593          	li	a1,1047
ffffffffc02051c2:	00002517          	auipc	a0,0x2
ffffffffc02051c6:	f8650513          	addi	a0,a0,-122 # ffffffffc0207148 <etext+0x181a>
ffffffffc02051ca:	a7cfb0ef          	jal	ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02051ce:	00002697          	auipc	a3,0x2
ffffffffc02051d2:	31268693          	addi	a3,a3,786 # ffffffffc02074e0 <etext+0x1bb2>
ffffffffc02051d6:	00001617          	auipc	a2,0x1
ffffffffc02051da:	1a260613          	addi	a2,a2,418 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02051de:	41600593          	li	a1,1046
ffffffffc02051e2:	00002517          	auipc	a0,0x2
ffffffffc02051e6:	f6650513          	addi	a0,a0,-154 # ffffffffc0207148 <etext+0x181a>
ffffffffc02051ea:	a5cfb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02051ee <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc02051ee:	1141                	addi	sp,sp,-16
ffffffffc02051f0:	e022                	sd	s0,0(sp)
ffffffffc02051f2:	e406                	sd	ra,8(sp)
ffffffffc02051f4:	00097417          	auipc	s0,0x97
ffffffffc02051f8:	97440413          	addi	s0,s0,-1676 # ffffffffc029bb68 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc02051fc:	6018                	ld	a4,0(s0)
ffffffffc02051fe:	6f1c                	ld	a5,24(a4)
ffffffffc0205200:	dffd                	beqz	a5,ffffffffc02051fe <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205202:	104000ef          	jal	ffffffffc0205306 <schedule>
ffffffffc0205206:	bfdd                	j	ffffffffc02051fc <cpu_idle+0xe>

ffffffffc0205208 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205208:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020520c:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205210:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205212:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205214:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205218:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020521c:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205220:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205224:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205228:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc020522c:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205230:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205234:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205238:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc020523c:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205240:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205244:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205246:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205248:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc020524c:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205250:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205254:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205258:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc020525c:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205260:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205264:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205268:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc020526c:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205270:	8082                	ret

ffffffffc0205272 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205272:	4118                	lw	a4,0(a0)
{
ffffffffc0205274:	1101                	addi	sp,sp,-32
ffffffffc0205276:	ec06                	sd	ra,24(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205278:	478d                	li	a5,3
ffffffffc020527a:	06f70763          	beq	a4,a5,ffffffffc02052e8 <wakeup_proc+0x76>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020527e:	100027f3          	csrr	a5,sstatus
ffffffffc0205282:	8b89                	andi	a5,a5,2
ffffffffc0205284:	eb91                	bnez	a5,ffffffffc0205298 <wakeup_proc+0x26>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205286:	4789                	li	a5,2
ffffffffc0205288:	02f70763          	beq	a4,a5,ffffffffc02052b6 <wakeup_proc+0x44>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020528c:	60e2                	ld	ra,24(sp)
            proc->state = PROC_RUNNABLE;
ffffffffc020528e:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205290:	0e052623          	sw	zero,236(a0)
}
ffffffffc0205294:	6105                	addi	sp,sp,32
ffffffffc0205296:	8082                	ret
        intr_disable();
ffffffffc0205298:	e42a                	sd	a0,8(sp)
ffffffffc020529a:	e6afb0ef          	jal	ffffffffc0200904 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc020529e:	6522                	ld	a0,8(sp)
ffffffffc02052a0:	4789                	li	a5,2
ffffffffc02052a2:	4118                	lw	a4,0(a0)
ffffffffc02052a4:	02f70663          	beq	a4,a5,ffffffffc02052d0 <wakeup_proc+0x5e>
            proc->state = PROC_RUNNABLE;
ffffffffc02052a8:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc02052aa:	0e052623          	sw	zero,236(a0)
}
ffffffffc02052ae:	60e2                	ld	ra,24(sp)
ffffffffc02052b0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02052b2:	e4cfb06f          	j	ffffffffc02008fe <intr_enable>
ffffffffc02052b6:	60e2                	ld	ra,24(sp)
            warn("wakeup runnable process.\n");
ffffffffc02052b8:	00002617          	auipc	a2,0x2
ffffffffc02052bc:	2b060613          	addi	a2,a2,688 # ffffffffc0207568 <etext+0x1c3a>
ffffffffc02052c0:	45d1                	li	a1,20
ffffffffc02052c2:	00002517          	auipc	a0,0x2
ffffffffc02052c6:	28e50513          	addi	a0,a0,654 # ffffffffc0207550 <etext+0x1c22>
}
ffffffffc02052ca:	6105                	addi	sp,sp,32
            warn("wakeup runnable process.\n");
ffffffffc02052cc:	9e4fb06f          	j	ffffffffc02004b0 <__warn>
ffffffffc02052d0:	00002617          	auipc	a2,0x2
ffffffffc02052d4:	29860613          	addi	a2,a2,664 # ffffffffc0207568 <etext+0x1c3a>
ffffffffc02052d8:	45d1                	li	a1,20
ffffffffc02052da:	00002517          	auipc	a0,0x2
ffffffffc02052de:	27650513          	addi	a0,a0,630 # ffffffffc0207550 <etext+0x1c22>
ffffffffc02052e2:	9cefb0ef          	jal	ffffffffc02004b0 <__warn>
    if (flag)
ffffffffc02052e6:	b7e1                	j	ffffffffc02052ae <wakeup_proc+0x3c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02052e8:	00002697          	auipc	a3,0x2
ffffffffc02052ec:	24868693          	addi	a3,a3,584 # ffffffffc0207530 <etext+0x1c02>
ffffffffc02052f0:	00001617          	auipc	a2,0x1
ffffffffc02052f4:	08860613          	addi	a2,a2,136 # ffffffffc0206378 <etext+0xa4a>
ffffffffc02052f8:	45a5                	li	a1,9
ffffffffc02052fa:	00002517          	auipc	a0,0x2
ffffffffc02052fe:	25650513          	addi	a0,a0,598 # ffffffffc0207550 <etext+0x1c22>
ffffffffc0205302:	944fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0205306 <schedule>:

void schedule(void)
{
ffffffffc0205306:	1101                	addi	sp,sp,-32
ffffffffc0205308:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020530a:	100027f3          	csrr	a5,sstatus
ffffffffc020530e:	8b89                	andi	a5,a5,2
ffffffffc0205310:	4301                	li	t1,0
ffffffffc0205312:	e3c1                	bnez	a5,ffffffffc0205392 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205314:	00097897          	auipc	a7,0x97
ffffffffc0205318:	8548b883          	ld	a7,-1964(a7) # ffffffffc029bb68 <current>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020531c:	00097517          	auipc	a0,0x97
ffffffffc0205320:	85c53503          	ld	a0,-1956(a0) # ffffffffc029bb78 <idleproc>
        current->need_resched = 0;
ffffffffc0205324:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205328:	04a88f63          	beq	a7,a0,ffffffffc0205386 <schedule+0x80>
ffffffffc020532c:	0c888693          	addi	a3,a7,200
ffffffffc0205330:	00096617          	auipc	a2,0x96
ffffffffc0205334:	7c060613          	addi	a2,a2,1984 # ffffffffc029baf0 <proc_list>
        le = last;
ffffffffc0205338:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020533a:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc020533c:	4809                	li	a6,2
ffffffffc020533e:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc0205340:	00c78863          	beq	a5,a2,ffffffffc0205350 <schedule+0x4a>
                if (next->state == PROC_RUNNABLE)
ffffffffc0205344:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205348:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc020534c:	03070363          	beq	a4,a6,ffffffffc0205372 <schedule+0x6c>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc0205350:	fef697e3          	bne	a3,a5,ffffffffc020533e <schedule+0x38>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205354:	ed99                	bnez	a1,ffffffffc0205372 <schedule+0x6c>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205356:	451c                	lw	a5,8(a0)
ffffffffc0205358:	2785                	addiw	a5,a5,1
ffffffffc020535a:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc020535c:	00a88663          	beq	a7,a0,ffffffffc0205368 <schedule+0x62>
ffffffffc0205360:	e41a                	sd	t1,8(sp)
        {
            proc_run(next);
ffffffffc0205362:	dc3fe0ef          	jal	ffffffffc0204124 <proc_run>
ffffffffc0205366:	6322                	ld	t1,8(sp)
    if (flag)
ffffffffc0205368:	00031b63          	bnez	t1,ffffffffc020537e <schedule+0x78>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020536c:	60e2                	ld	ra,24(sp)
ffffffffc020536e:	6105                	addi	sp,sp,32
ffffffffc0205370:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205372:	4198                	lw	a4,0(a1)
ffffffffc0205374:	4789                	li	a5,2
ffffffffc0205376:	fef710e3          	bne	a4,a5,ffffffffc0205356 <schedule+0x50>
ffffffffc020537a:	852e                	mv	a0,a1
ffffffffc020537c:	bfe9                	j	ffffffffc0205356 <schedule+0x50>
}
ffffffffc020537e:	60e2                	ld	ra,24(sp)
ffffffffc0205380:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205382:	d7cfb06f          	j	ffffffffc02008fe <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205386:	00096617          	auipc	a2,0x96
ffffffffc020538a:	76a60613          	addi	a2,a2,1898 # ffffffffc029baf0 <proc_list>
ffffffffc020538e:	86b2                	mv	a3,a2
ffffffffc0205390:	b765                	j	ffffffffc0205338 <schedule+0x32>
        intr_disable();
ffffffffc0205392:	d72fb0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0205396:	4305                	li	t1,1
ffffffffc0205398:	bfb5                	j	ffffffffc0205314 <schedule+0xe>

ffffffffc020539a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020539a:	00096797          	auipc	a5,0x96
ffffffffc020539e:	7ce7b783          	ld	a5,1998(a5) # ffffffffc029bb68 <current>
}
ffffffffc02053a2:	43c8                	lw	a0,4(a5)
ffffffffc02053a4:	8082                	ret

ffffffffc02053a6 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02053a6:	4501                	li	a0,0
ffffffffc02053a8:	8082                	ret

ffffffffc02053aa <sys_putc>:
    cputchar(c);
ffffffffc02053aa:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02053ac:	1141                	addi	sp,sp,-16
ffffffffc02053ae:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02053b0:	e19fa0ef          	jal	ffffffffc02001c8 <cputchar>
}
ffffffffc02053b4:	60a2                	ld	ra,8(sp)
ffffffffc02053b6:	4501                	li	a0,0
ffffffffc02053b8:	0141                	addi	sp,sp,16
ffffffffc02053ba:	8082                	ret

ffffffffc02053bc <sys_kill>:
    return do_kill(pid);
ffffffffc02053bc:	4108                	lw	a0,0(a0)
ffffffffc02053be:	c19ff06f          	j	ffffffffc0204fd6 <do_kill>

ffffffffc02053c2 <sys_yield>:
    return do_yield();
ffffffffc02053c2:	bcbff06f          	j	ffffffffc0204f8c <do_yield>

ffffffffc02053c6 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02053c6:	6d14                	ld	a3,24(a0)
ffffffffc02053c8:	6910                	ld	a2,16(a0)
ffffffffc02053ca:	650c                	ld	a1,8(a0)
ffffffffc02053cc:	6108                	ld	a0,0(a0)
ffffffffc02053ce:	e22ff06f          	j	ffffffffc02049f0 <do_execve>

ffffffffc02053d2 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02053d2:	650c                	ld	a1,8(a0)
ffffffffc02053d4:	4108                	lw	a0,0(a0)
ffffffffc02053d6:	bc7ff06f          	j	ffffffffc0204f9c <do_wait>

ffffffffc02053da <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02053da:	00096797          	auipc	a5,0x96
ffffffffc02053de:	78e7b783          	ld	a5,1934(a5) # ffffffffc029bb68 <current>
    return do_fork(0, stack, tf);
ffffffffc02053e2:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02053e4:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02053e6:	6a0c                	ld	a1,16(a2)
ffffffffc02053e8:	d9ffe06f          	j	ffffffffc0204186 <do_fork>

ffffffffc02053ec <sys_exit>:
    return do_exit(error_code);
ffffffffc02053ec:	4108                	lw	a0,0(a0)
ffffffffc02053ee:	9b8ff06f          	j	ffffffffc02045a6 <do_exit>

ffffffffc02053f2 <syscall>:

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    struct trapframe *tf = current->tf;
ffffffffc02053f2:	00096697          	auipc	a3,0x96
ffffffffc02053f6:	7766b683          	ld	a3,1910(a3) # ffffffffc029bb68 <current>
syscall(void) {
ffffffffc02053fa:	715d                	addi	sp,sp,-80
ffffffffc02053fc:	e0a2                	sd	s0,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc02053fe:	72c0                	ld	s0,160(a3)
syscall(void) {
ffffffffc0205400:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205402:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205404:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205406:	02d7ec63          	bltu	a5,a3,ffffffffc020543e <syscall+0x4c>
        if (syscalls[num] != NULL) {
ffffffffc020540a:	00002797          	auipc	a5,0x2
ffffffffc020540e:	3a678793          	addi	a5,a5,934 # ffffffffc02077b0 <syscalls>
ffffffffc0205412:	00369613          	slli	a2,a3,0x3
ffffffffc0205416:	97b2                	add	a5,a5,a2
ffffffffc0205418:	639c                	ld	a5,0(a5)
ffffffffc020541a:	c395                	beqz	a5,ffffffffc020543e <syscall+0x4c>
            arg[0] = tf->gpr.a1;
ffffffffc020541c:	7028                	ld	a0,96(s0)
ffffffffc020541e:	742c                	ld	a1,104(s0)
ffffffffc0205420:	7830                	ld	a2,112(s0)
ffffffffc0205422:	7c34                	ld	a3,120(s0)
ffffffffc0205424:	6c38                	ld	a4,88(s0)
ffffffffc0205426:	f02a                	sd	a0,32(sp)
ffffffffc0205428:	f42e                	sd	a1,40(sp)
ffffffffc020542a:	f832                	sd	a2,48(sp)
ffffffffc020542c:	fc36                	sd	a3,56(sp)
ffffffffc020542e:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205430:	0828                	addi	a0,sp,24
ffffffffc0205432:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205434:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205436:	e828                	sd	a0,80(s0)
}
ffffffffc0205438:	6406                	ld	s0,64(sp)
ffffffffc020543a:	6161                	addi	sp,sp,80
ffffffffc020543c:	8082                	ret
    print_trapframe(tf);
ffffffffc020543e:	8522                	mv	a0,s0
ffffffffc0205440:	e436                	sd	a3,8(sp)
ffffffffc0205442:	eb2fb0ef          	jal	ffffffffc0200af4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205446:	00096797          	auipc	a5,0x96
ffffffffc020544a:	7227b783          	ld	a5,1826(a5) # ffffffffc029bb68 <current>
ffffffffc020544e:	66a2                	ld	a3,8(sp)
ffffffffc0205450:	00002617          	auipc	a2,0x2
ffffffffc0205454:	13860613          	addi	a2,a2,312 # ffffffffc0207588 <etext+0x1c5a>
ffffffffc0205458:	43d8                	lw	a4,4(a5)
ffffffffc020545a:	06200593          	li	a1,98
ffffffffc020545e:	0b478793          	addi	a5,a5,180
ffffffffc0205462:	00002517          	auipc	a0,0x2
ffffffffc0205466:	15650513          	addi	a0,a0,342 # ffffffffc02075b8 <etext+0x1c8a>
ffffffffc020546a:	fddfa0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020546e <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020546e:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205472:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_exit_out_size+0xffffffff9e365df9>
ffffffffc0205474:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205478:	02000513          	li	a0,32
ffffffffc020547c:	9d0d                	subw	a0,a0,a1
}
ffffffffc020547e:	00a7d53b          	srlw	a0,a5,a0
ffffffffc0205482:	8082                	ret

ffffffffc0205484 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205484:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205486:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020548a:	f022                	sd	s0,32(sp)
ffffffffc020548c:	ec26                	sd	s1,24(sp)
ffffffffc020548e:	e84a                	sd	s2,16(sp)
ffffffffc0205490:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205492:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205496:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205498:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020549c:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054a0:	84aa                	mv	s1,a0
ffffffffc02054a2:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc02054a4:	03067d63          	bgeu	a2,a6,ffffffffc02054de <printnum+0x5a>
ffffffffc02054a8:	e44e                	sd	s3,8(sp)
ffffffffc02054aa:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02054ac:	4785                	li	a5,1
ffffffffc02054ae:	00e7d763          	bge	a5,a4,ffffffffc02054bc <printnum+0x38>
            putch(padc, putdat);
ffffffffc02054b2:	85ca                	mv	a1,s2
ffffffffc02054b4:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02054b6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02054b8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02054ba:	fc65                	bnez	s0,ffffffffc02054b2 <printnum+0x2e>
ffffffffc02054bc:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054be:	00002797          	auipc	a5,0x2
ffffffffc02054c2:	11278793          	addi	a5,a5,274 # ffffffffc02075d0 <etext+0x1ca2>
ffffffffc02054c6:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02054c8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054ca:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02054ce:	70a2                	ld	ra,40(sp)
ffffffffc02054d0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054d2:	85ca                	mv	a1,s2
ffffffffc02054d4:	87a6                	mv	a5,s1
}
ffffffffc02054d6:	6942                	ld	s2,16(sp)
ffffffffc02054d8:	64e2                	ld	s1,24(sp)
ffffffffc02054da:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054dc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02054de:	03065633          	divu	a2,a2,a6
ffffffffc02054e2:	8722                	mv	a4,s0
ffffffffc02054e4:	fa1ff0ef          	jal	ffffffffc0205484 <printnum>
ffffffffc02054e8:	bfd9                	j	ffffffffc02054be <printnum+0x3a>

ffffffffc02054ea <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02054ea:	7119                	addi	sp,sp,-128
ffffffffc02054ec:	f4a6                	sd	s1,104(sp)
ffffffffc02054ee:	f0ca                	sd	s2,96(sp)
ffffffffc02054f0:	ecce                	sd	s3,88(sp)
ffffffffc02054f2:	e8d2                	sd	s4,80(sp)
ffffffffc02054f4:	e4d6                	sd	s5,72(sp)
ffffffffc02054f6:	e0da                	sd	s6,64(sp)
ffffffffc02054f8:	f862                	sd	s8,48(sp)
ffffffffc02054fa:	fc86                	sd	ra,120(sp)
ffffffffc02054fc:	f8a2                	sd	s0,112(sp)
ffffffffc02054fe:	fc5e                	sd	s7,56(sp)
ffffffffc0205500:	f466                	sd	s9,40(sp)
ffffffffc0205502:	f06a                	sd	s10,32(sp)
ffffffffc0205504:	ec6e                	sd	s11,24(sp)
ffffffffc0205506:	84aa                	mv	s1,a0
ffffffffc0205508:	8c32                	mv	s8,a2
ffffffffc020550a:	8a36                	mv	s4,a3
ffffffffc020550c:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020550e:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205512:	05500b13          	li	s6,85
ffffffffc0205516:	00002a97          	auipc	s5,0x2
ffffffffc020551a:	39aa8a93          	addi	s5,s5,922 # ffffffffc02078b0 <syscalls+0x100>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020551e:	000c4503          	lbu	a0,0(s8)
ffffffffc0205522:	001c0413          	addi	s0,s8,1
ffffffffc0205526:	01350a63          	beq	a0,s3,ffffffffc020553a <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020552a:	cd0d                	beqz	a0,ffffffffc0205564 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc020552c:	85ca                	mv	a1,s2
ffffffffc020552e:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205530:	00044503          	lbu	a0,0(s0)
ffffffffc0205534:	0405                	addi	s0,s0,1
ffffffffc0205536:	ff351ae3          	bne	a0,s3,ffffffffc020552a <vprintfmt+0x40>
        width = precision = -1;
ffffffffc020553a:	5cfd                	li	s9,-1
ffffffffc020553c:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc020553e:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0205542:	4b81                	li	s7,0
ffffffffc0205544:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205546:	00044683          	lbu	a3,0(s0)
ffffffffc020554a:	00140c13          	addi	s8,s0,1
ffffffffc020554e:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0205552:	0ff5f593          	zext.b	a1,a1
ffffffffc0205556:	02bb6663          	bltu	s6,a1,ffffffffc0205582 <vprintfmt+0x98>
ffffffffc020555a:	058a                	slli	a1,a1,0x2
ffffffffc020555c:	95d6                	add	a1,a1,s5
ffffffffc020555e:	4198                	lw	a4,0(a1)
ffffffffc0205560:	9756                	add	a4,a4,s5
ffffffffc0205562:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205564:	70e6                	ld	ra,120(sp)
ffffffffc0205566:	7446                	ld	s0,112(sp)
ffffffffc0205568:	74a6                	ld	s1,104(sp)
ffffffffc020556a:	7906                	ld	s2,96(sp)
ffffffffc020556c:	69e6                	ld	s3,88(sp)
ffffffffc020556e:	6a46                	ld	s4,80(sp)
ffffffffc0205570:	6aa6                	ld	s5,72(sp)
ffffffffc0205572:	6b06                	ld	s6,64(sp)
ffffffffc0205574:	7be2                	ld	s7,56(sp)
ffffffffc0205576:	7c42                	ld	s8,48(sp)
ffffffffc0205578:	7ca2                	ld	s9,40(sp)
ffffffffc020557a:	7d02                	ld	s10,32(sp)
ffffffffc020557c:	6de2                	ld	s11,24(sp)
ffffffffc020557e:	6109                	addi	sp,sp,128
ffffffffc0205580:	8082                	ret
            putch('%', putdat);
ffffffffc0205582:	85ca                	mv	a1,s2
ffffffffc0205584:	02500513          	li	a0,37
ffffffffc0205588:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020558a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020558e:	02500713          	li	a4,37
ffffffffc0205592:	8c22                	mv	s8,s0
ffffffffc0205594:	f8e785e3          	beq	a5,a4,ffffffffc020551e <vprintfmt+0x34>
ffffffffc0205598:	ffec4783          	lbu	a5,-2(s8)
ffffffffc020559c:	1c7d                	addi	s8,s8,-1
ffffffffc020559e:	fee79de3          	bne	a5,a4,ffffffffc0205598 <vprintfmt+0xae>
ffffffffc02055a2:	bfb5                	j	ffffffffc020551e <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02055a4:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02055a8:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc02055aa:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02055ae:	fd06071b          	addiw	a4,a2,-48
ffffffffc02055b2:	24e56a63          	bltu	a0,a4,ffffffffc0205806 <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc02055b6:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055b8:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc02055ba:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc02055be:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02055c2:	0197073b          	addw	a4,a4,s9
ffffffffc02055c6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02055ca:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc02055cc:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02055d0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02055d2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02055d6:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc02055da:	feb570e3          	bgeu	a0,a1,ffffffffc02055ba <vprintfmt+0xd0>
            if (width < 0)
ffffffffc02055de:	f60d54e3          	bgez	s10,ffffffffc0205546 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc02055e2:	8d66                	mv	s10,s9
ffffffffc02055e4:	5cfd                	li	s9,-1
ffffffffc02055e6:	b785                	j	ffffffffc0205546 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055e8:	8db6                	mv	s11,a3
ffffffffc02055ea:	8462                	mv	s0,s8
ffffffffc02055ec:	bfa9                	j	ffffffffc0205546 <vprintfmt+0x5c>
ffffffffc02055ee:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc02055f0:	4b85                	li	s7,1
            goto reswitch;
ffffffffc02055f2:	bf91                	j	ffffffffc0205546 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc02055f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055f6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02055fa:	00f74463          	blt	a4,a5,ffffffffc0205602 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc02055fe:	1a078763          	beqz	a5,ffffffffc02057ac <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0205602:	000a3603          	ld	a2,0(s4)
ffffffffc0205606:	46c1                	li	a3,16
ffffffffc0205608:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020560a:	000d879b          	sext.w	a5,s11
ffffffffc020560e:	876a                	mv	a4,s10
ffffffffc0205610:	85ca                	mv	a1,s2
ffffffffc0205612:	8526                	mv	a0,s1
ffffffffc0205614:	e71ff0ef          	jal	ffffffffc0205484 <printnum>
            break;
ffffffffc0205618:	b719                	j	ffffffffc020551e <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020561a:	000a2503          	lw	a0,0(s4)
ffffffffc020561e:	85ca                	mv	a1,s2
ffffffffc0205620:	0a21                	addi	s4,s4,8
ffffffffc0205622:	9482                	jalr	s1
            break;
ffffffffc0205624:	bded                	j	ffffffffc020551e <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0205626:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205628:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020562c:	00f74463          	blt	a4,a5,ffffffffc0205634 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0205630:	16078963          	beqz	a5,ffffffffc02057a2 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0205634:	000a3603          	ld	a2,0(s4)
ffffffffc0205638:	46a9                	li	a3,10
ffffffffc020563a:	8a2e                	mv	s4,a1
ffffffffc020563c:	b7f9                	j	ffffffffc020560a <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc020563e:	85ca                	mv	a1,s2
ffffffffc0205640:	03000513          	li	a0,48
ffffffffc0205644:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc0205646:	85ca                	mv	a1,s2
ffffffffc0205648:	07800513          	li	a0,120
ffffffffc020564c:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020564e:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0205652:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205654:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205656:	bf55                	j	ffffffffc020560a <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc0205658:	85ca                	mv	a1,s2
ffffffffc020565a:	02500513          	li	a0,37
ffffffffc020565e:	9482                	jalr	s1
            break;
ffffffffc0205660:	bd7d                	j	ffffffffc020551e <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0205662:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205666:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0205668:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc020566a:	bf95                	j	ffffffffc02055de <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc020566c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020566e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205672:	00f74463          	blt	a4,a5,ffffffffc020567a <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0205676:	12078163          	beqz	a5,ffffffffc0205798 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc020567a:	000a3603          	ld	a2,0(s4)
ffffffffc020567e:	46a1                	li	a3,8
ffffffffc0205680:	8a2e                	mv	s4,a1
ffffffffc0205682:	b761                	j	ffffffffc020560a <vprintfmt+0x120>
            if (width < 0)
ffffffffc0205684:	876a                	mv	a4,s10
ffffffffc0205686:	000d5363          	bgez	s10,ffffffffc020568c <vprintfmt+0x1a2>
ffffffffc020568a:	4701                	li	a4,0
ffffffffc020568c:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205690:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0205692:	bd55                	j	ffffffffc0205546 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc0205694:	000d841b          	sext.w	s0,s11
ffffffffc0205698:	fd340793          	addi	a5,s0,-45
ffffffffc020569c:	00f037b3          	snez	a5,a5
ffffffffc02056a0:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056a4:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc02056a8:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056aa:	008a0793          	addi	a5,s4,8
ffffffffc02056ae:	e43e                	sd	a5,8(sp)
ffffffffc02056b0:	100d8c63          	beqz	s11,ffffffffc02057c8 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02056b4:	12071363          	bnez	a4,ffffffffc02057da <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056b8:	000dc783          	lbu	a5,0(s11)
ffffffffc02056bc:	0007851b          	sext.w	a0,a5
ffffffffc02056c0:	c78d                	beqz	a5,ffffffffc02056ea <vprintfmt+0x200>
ffffffffc02056c2:	0d85                	addi	s11,s11,1
ffffffffc02056c4:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056c6:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056ca:	000cc563          	bltz	s9,ffffffffc02056d4 <vprintfmt+0x1ea>
ffffffffc02056ce:	3cfd                	addiw	s9,s9,-1
ffffffffc02056d0:	008c8d63          	beq	s9,s0,ffffffffc02056ea <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056d4:	020b9663          	bnez	s7,ffffffffc0205700 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc02056d8:	85ca                	mv	a1,s2
ffffffffc02056da:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056dc:	000dc783          	lbu	a5,0(s11)
ffffffffc02056e0:	0d85                	addi	s11,s11,1
ffffffffc02056e2:	3d7d                	addiw	s10,s10,-1
ffffffffc02056e4:	0007851b          	sext.w	a0,a5
ffffffffc02056e8:	f3ed                	bnez	a5,ffffffffc02056ca <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc02056ea:	01a05963          	blez	s10,ffffffffc02056fc <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc02056ee:	85ca                	mv	a1,s2
ffffffffc02056f0:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc02056f4:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc02056f6:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc02056f8:	fe0d1be3          	bnez	s10,ffffffffc02056ee <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056fc:	6a22                	ld	s4,8(sp)
ffffffffc02056fe:	b505                	j	ffffffffc020551e <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205700:	3781                	addiw	a5,a5,-32
ffffffffc0205702:	fcfa7be3          	bgeu	s4,a5,ffffffffc02056d8 <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0205706:	03f00513          	li	a0,63
ffffffffc020570a:	85ca                	mv	a1,s2
ffffffffc020570c:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020570e:	000dc783          	lbu	a5,0(s11)
ffffffffc0205712:	0d85                	addi	s11,s11,1
ffffffffc0205714:	3d7d                	addiw	s10,s10,-1
ffffffffc0205716:	0007851b          	sext.w	a0,a5
ffffffffc020571a:	dbe1                	beqz	a5,ffffffffc02056ea <vprintfmt+0x200>
ffffffffc020571c:	fa0cd9e3          	bgez	s9,ffffffffc02056ce <vprintfmt+0x1e4>
ffffffffc0205720:	b7c5                	j	ffffffffc0205700 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0205722:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205726:	4661                	li	a2,24
            err = va_arg(ap, int);
ffffffffc0205728:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020572a:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020572e:	8fb9                	xor	a5,a5,a4
ffffffffc0205730:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205734:	02d64563          	blt	a2,a3,ffffffffc020575e <vprintfmt+0x274>
ffffffffc0205738:	00002797          	auipc	a5,0x2
ffffffffc020573c:	2d078793          	addi	a5,a5,720 # ffffffffc0207a08 <error_string>
ffffffffc0205740:	00369713          	slli	a4,a3,0x3
ffffffffc0205744:	97ba                	add	a5,a5,a4
ffffffffc0205746:	639c                	ld	a5,0(a5)
ffffffffc0205748:	cb99                	beqz	a5,ffffffffc020575e <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc020574a:	86be                	mv	a3,a5
ffffffffc020574c:	00000617          	auipc	a2,0x0
ffffffffc0205750:	20c60613          	addi	a2,a2,524 # ffffffffc0205958 <etext+0x2a>
ffffffffc0205754:	85ca                	mv	a1,s2
ffffffffc0205756:	8526                	mv	a0,s1
ffffffffc0205758:	0d8000ef          	jal	ffffffffc0205830 <printfmt>
ffffffffc020575c:	b3c9                	j	ffffffffc020551e <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020575e:	00002617          	auipc	a2,0x2
ffffffffc0205762:	e9260613          	addi	a2,a2,-366 # ffffffffc02075f0 <etext+0x1cc2>
ffffffffc0205766:	85ca                	mv	a1,s2
ffffffffc0205768:	8526                	mv	a0,s1
ffffffffc020576a:	0c6000ef          	jal	ffffffffc0205830 <printfmt>
ffffffffc020576e:	bb45                	j	ffffffffc020551e <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0205770:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205772:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0205776:	00f74363          	blt	a4,a5,ffffffffc020577c <vprintfmt+0x292>
    else if (lflag) {
ffffffffc020577a:	cf81                	beqz	a5,ffffffffc0205792 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc020577c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205780:	02044b63          	bltz	s0,ffffffffc02057b6 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0205784:	8622                	mv	a2,s0
ffffffffc0205786:	8a5e                	mv	s4,s7
ffffffffc0205788:	46a9                	li	a3,10
ffffffffc020578a:	b541                	j	ffffffffc020560a <vprintfmt+0x120>
            lflag ++;
ffffffffc020578c:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020578e:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0205790:	bb5d                	j	ffffffffc0205546 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0205792:	000a2403          	lw	s0,0(s4)
ffffffffc0205796:	b7ed                	j	ffffffffc0205780 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc0205798:	000a6603          	lwu	a2,0(s4)
ffffffffc020579c:	46a1                	li	a3,8
ffffffffc020579e:	8a2e                	mv	s4,a1
ffffffffc02057a0:	b5ad                	j	ffffffffc020560a <vprintfmt+0x120>
ffffffffc02057a2:	000a6603          	lwu	a2,0(s4)
ffffffffc02057a6:	46a9                	li	a3,10
ffffffffc02057a8:	8a2e                	mv	s4,a1
ffffffffc02057aa:	b585                	j	ffffffffc020560a <vprintfmt+0x120>
ffffffffc02057ac:	000a6603          	lwu	a2,0(s4)
ffffffffc02057b0:	46c1                	li	a3,16
ffffffffc02057b2:	8a2e                	mv	s4,a1
ffffffffc02057b4:	bd99                	j	ffffffffc020560a <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc02057b6:	85ca                	mv	a1,s2
ffffffffc02057b8:	02d00513          	li	a0,45
ffffffffc02057bc:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc02057be:	40800633          	neg	a2,s0
ffffffffc02057c2:	8a5e                	mv	s4,s7
ffffffffc02057c4:	46a9                	li	a3,10
ffffffffc02057c6:	b591                	j	ffffffffc020560a <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc02057c8:	e329                	bnez	a4,ffffffffc020580a <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057ca:	02800793          	li	a5,40
ffffffffc02057ce:	853e                	mv	a0,a5
ffffffffc02057d0:	00002d97          	auipc	s11,0x2
ffffffffc02057d4:	e19d8d93          	addi	s11,s11,-487 # ffffffffc02075e9 <etext+0x1cbb>
ffffffffc02057d8:	b5f5                	j	ffffffffc02056c4 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02057da:	85e6                	mv	a1,s9
ffffffffc02057dc:	856e                	mv	a0,s11
ffffffffc02057de:	08a000ef          	jal	ffffffffc0205868 <strnlen>
ffffffffc02057e2:	40ad0d3b          	subw	s10,s10,a0
ffffffffc02057e6:	01a05863          	blez	s10,ffffffffc02057f6 <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc02057ea:	85ca                	mv	a1,s2
ffffffffc02057ec:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02057ee:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc02057f0:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02057f2:	fe0d1ce3          	bnez	s10,ffffffffc02057ea <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057f6:	000dc783          	lbu	a5,0(s11)
ffffffffc02057fa:	0007851b          	sext.w	a0,a5
ffffffffc02057fe:	ec0792e3          	bnez	a5,ffffffffc02056c2 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205802:	6a22                	ld	s4,8(sp)
ffffffffc0205804:	bb29                	j	ffffffffc020551e <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205806:	8462                	mv	s0,s8
ffffffffc0205808:	bbd9                	j	ffffffffc02055de <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020580a:	85e6                	mv	a1,s9
ffffffffc020580c:	00002517          	auipc	a0,0x2
ffffffffc0205810:	ddc50513          	addi	a0,a0,-548 # ffffffffc02075e8 <etext+0x1cba>
ffffffffc0205814:	054000ef          	jal	ffffffffc0205868 <strnlen>
ffffffffc0205818:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020581c:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0205820:	00002d97          	auipc	s11,0x2
ffffffffc0205824:	dc8d8d93          	addi	s11,s11,-568 # ffffffffc02075e8 <etext+0x1cba>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205828:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020582a:	fda040e3          	bgtz	s10,ffffffffc02057ea <vprintfmt+0x300>
ffffffffc020582e:	bd51                	j	ffffffffc02056c2 <vprintfmt+0x1d8>

ffffffffc0205830 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205830:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205832:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205836:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205838:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020583a:	ec06                	sd	ra,24(sp)
ffffffffc020583c:	f83a                	sd	a4,48(sp)
ffffffffc020583e:	fc3e                	sd	a5,56(sp)
ffffffffc0205840:	e0c2                	sd	a6,64(sp)
ffffffffc0205842:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205844:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205846:	ca5ff0ef          	jal	ffffffffc02054ea <vprintfmt>
}
ffffffffc020584a:	60e2                	ld	ra,24(sp)
ffffffffc020584c:	6161                	addi	sp,sp,80
ffffffffc020584e:	8082                	ret

ffffffffc0205850 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205850:	00054783          	lbu	a5,0(a0)
ffffffffc0205854:	cb81                	beqz	a5,ffffffffc0205864 <strlen+0x14>
    size_t cnt = 0;
ffffffffc0205856:	4781                	li	a5,0
        cnt ++;
ffffffffc0205858:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020585a:	00f50733          	add	a4,a0,a5
ffffffffc020585e:	00074703          	lbu	a4,0(a4)
ffffffffc0205862:	fb7d                	bnez	a4,ffffffffc0205858 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0205864:	853e                	mv	a0,a5
ffffffffc0205866:	8082                	ret

ffffffffc0205868 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205868:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020586a:	e589                	bnez	a1,ffffffffc0205874 <strnlen+0xc>
ffffffffc020586c:	a811                	j	ffffffffc0205880 <strnlen+0x18>
        cnt ++;
ffffffffc020586e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205870:	00f58863          	beq	a1,a5,ffffffffc0205880 <strnlen+0x18>
ffffffffc0205874:	00f50733          	add	a4,a0,a5
ffffffffc0205878:	00074703          	lbu	a4,0(a4)
ffffffffc020587c:	fb6d                	bnez	a4,ffffffffc020586e <strnlen+0x6>
ffffffffc020587e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205880:	852e                	mv	a0,a1
ffffffffc0205882:	8082                	ret

ffffffffc0205884 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205884:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205886:	0005c703          	lbu	a4,0(a1)
ffffffffc020588a:	0585                	addi	a1,a1,1
ffffffffc020588c:	0785                	addi	a5,a5,1
ffffffffc020588e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205892:	fb75                	bnez	a4,ffffffffc0205886 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205894:	8082                	ret

ffffffffc0205896 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205896:	00054783          	lbu	a5,0(a0)
ffffffffc020589a:	e791                	bnez	a5,ffffffffc02058a6 <strcmp+0x10>
ffffffffc020589c:	a01d                	j	ffffffffc02058c2 <strcmp+0x2c>
ffffffffc020589e:	00054783          	lbu	a5,0(a0)
ffffffffc02058a2:	cb99                	beqz	a5,ffffffffc02058b8 <strcmp+0x22>
ffffffffc02058a4:	0585                	addi	a1,a1,1
ffffffffc02058a6:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02058aa:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02058ac:	fef709e3          	beq	a4,a5,ffffffffc020589e <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058b0:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02058b4:	9d19                	subw	a0,a0,a4
ffffffffc02058b6:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058b8:	0015c703          	lbu	a4,1(a1)
ffffffffc02058bc:	4501                	li	a0,0
}
ffffffffc02058be:	9d19                	subw	a0,a0,a4
ffffffffc02058c0:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058c2:	0005c703          	lbu	a4,0(a1)
ffffffffc02058c6:	4501                	li	a0,0
ffffffffc02058c8:	b7f5                	j	ffffffffc02058b4 <strcmp+0x1e>

ffffffffc02058ca <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02058ca:	ce01                	beqz	a2,ffffffffc02058e2 <strncmp+0x18>
ffffffffc02058cc:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02058d0:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02058d2:	cb91                	beqz	a5,ffffffffc02058e6 <strncmp+0x1c>
ffffffffc02058d4:	0005c703          	lbu	a4,0(a1)
ffffffffc02058d8:	00f71763          	bne	a4,a5,ffffffffc02058e6 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc02058dc:	0505                	addi	a0,a0,1
ffffffffc02058de:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02058e0:	f675                	bnez	a2,ffffffffc02058cc <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058e2:	4501                	li	a0,0
ffffffffc02058e4:	8082                	ret
ffffffffc02058e6:	00054503          	lbu	a0,0(a0)
ffffffffc02058ea:	0005c783          	lbu	a5,0(a1)
ffffffffc02058ee:	9d1d                	subw	a0,a0,a5
}
ffffffffc02058f0:	8082                	ret

ffffffffc02058f2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02058f2:	a021                	j	ffffffffc02058fa <strchr+0x8>
        if (*s == c) {
ffffffffc02058f4:	00f58763          	beq	a1,a5,ffffffffc0205902 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc02058f8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02058fa:	00054783          	lbu	a5,0(a0)
ffffffffc02058fe:	fbfd                	bnez	a5,ffffffffc02058f4 <strchr+0x2>
    }
    return NULL;
ffffffffc0205900:	4501                	li	a0,0
}
ffffffffc0205902:	8082                	ret

ffffffffc0205904 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205904:	ca01                	beqz	a2,ffffffffc0205914 <memset+0x10>
ffffffffc0205906:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205908:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020590a:	0785                	addi	a5,a5,1
ffffffffc020590c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205910:	fef61de3          	bne	a2,a5,ffffffffc020590a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205914:	8082                	ret

ffffffffc0205916 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205916:	ca19                	beqz	a2,ffffffffc020592c <memcpy+0x16>
ffffffffc0205918:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020591a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020591c:	0005c703          	lbu	a4,0(a1)
ffffffffc0205920:	0585                	addi	a1,a1,1
ffffffffc0205922:	0785                	addi	a5,a5,1
ffffffffc0205924:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205928:	feb61ae3          	bne	a2,a1,ffffffffc020591c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020592c:	8082                	ret
