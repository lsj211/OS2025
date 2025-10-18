
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00007297          	auipc	t0,0x7
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0207000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00007297          	auipc	t0,0x7
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0207008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02062b7          	lui	t0,0xc0206
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
ffffffffc020003c:	c0206137          	lui	sp,0xc0206

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d628293          	addi	t0,t0,214 # ffffffffc02000d6 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16 # ffffffffc0205ff0 <bootstack+0x1ff0>
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00002517          	auipc	a0,0x2
ffffffffc0200050:	3f450513          	addi	a0,a0,1012 # ffffffffc0202440 <etext+0x2>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f2000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07c58593          	addi	a1,a1,124 # ffffffffc02000d6 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	3fe50513          	addi	a0,a0,1022 # ffffffffc0202460 <etext+0x22>
ffffffffc020006a:	0de000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	3d058593          	addi	a1,a1,976 # ffffffffc020243e <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	40a50513          	addi	a0,a0,1034 # ffffffffc0202480 <etext+0x42>
ffffffffc020007e:	0ca000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00007597          	auipc	a1,0x7
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0207018 <free_area>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	41650513          	addi	a0,a0,1046 # ffffffffc02024a0 <etext+0x62>
ffffffffc0200092:	0b6000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00007597          	auipc	a1,0x7
ffffffffc020009a:	0e258593          	addi	a1,a1,226 # ffffffffc0207178 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	42250513          	addi	a0,a0,1058 # ffffffffc02024c0 <etext+0x82>
ffffffffc02000a6:	0a2000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00000717          	auipc	a4,0x0
ffffffffc02000ae:	02c70713          	addi	a4,a4,44 # ffffffffc02000d6 <kern_init>
ffffffffc02000b2:	00007797          	auipc	a5,0x7
ffffffffc02000b6:	4c578793          	addi	a5,a5,1221 # ffffffffc0207577 <end+0x3ff>
ffffffffc02000ba:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000bc:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c6:	95be                	add	a1,a1,a5
ffffffffc02000c8:	85a9                	srai	a1,a1,0xa
ffffffffc02000ca:	00002517          	auipc	a0,0x2
ffffffffc02000ce:	41650513          	addi	a0,a0,1046 # ffffffffc02024e0 <etext+0xa2>
}
ffffffffc02000d2:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d4:	a895                	j	ffffffffc0200148 <cprintf>

ffffffffc02000d6 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d6:	00007517          	auipc	a0,0x7
ffffffffc02000da:	f4250513          	addi	a0,a0,-190 # ffffffffc0207018 <free_area>
ffffffffc02000de:	00007617          	auipc	a2,0x7
ffffffffc02000e2:	09a60613          	addi	a2,a2,154 # ffffffffc0207178 <end>
int kern_init(void) {
ffffffffc02000e6:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000e8:	8e09                	sub	a2,a2,a0
ffffffffc02000ea:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ec:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000ee:	33e020ef          	jal	ffffffffc020242c <memset>
    dtb_init();
ffffffffc02000f2:	136000ef          	jal	ffffffffc0200228 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f6:	128000ef          	jal	ffffffffc020021e <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fa:	00004517          	auipc	a0,0x4
ffffffffc02000fe:	ba650513          	addi	a0,a0,-1114 # ffffffffc0203ca0 <etext+0x1862>
ffffffffc0200102:	07a000ef          	jal	ffffffffc020017c <cputs>

    print_kerninfo();
ffffffffc0200106:	f45ff0ef          	jal	ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010a:	6e9000ef          	jal	ffffffffc0200ff2 <pmm_init>

    /* do nothing */
    while (1)
ffffffffc020010e:	a001                	j	ffffffffc020010e <kern_init+0x38>

ffffffffc0200110 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200110:	1101                	addi	sp,sp,-32
ffffffffc0200112:	ec06                	sd	ra,24(sp)
ffffffffc0200114:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc0200116:	10a000ef          	jal	ffffffffc0200220 <cons_putc>
    (*cnt) ++;
ffffffffc020011a:	65a2                	ld	a1,8(sp)
}
ffffffffc020011c:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
ffffffffc020011e:	419c                	lw	a5,0(a1)
ffffffffc0200120:	2785                	addiw	a5,a5,1
ffffffffc0200122:	c19c                	sw	a5,0(a1)
}
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret

ffffffffc0200128 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200128:	1101                	addi	sp,sp,-32
ffffffffc020012a:	862a                	mv	a2,a0
ffffffffc020012c:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020012e:	00000517          	auipc	a0,0x0
ffffffffc0200132:	fe250513          	addi	a0,a0,-30 # ffffffffc0200110 <cputch>
ffffffffc0200136:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200138:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013a:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020013c:	6e1010ef          	jal	ffffffffc020201c <vprintfmt>
    return cnt;
}
ffffffffc0200140:	60e2                	ld	ra,24(sp)
ffffffffc0200142:	4532                	lw	a0,12(sp)
ffffffffc0200144:	6105                	addi	sp,sp,32
ffffffffc0200146:	8082                	ret

ffffffffc0200148 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200148:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014a:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc020014e:	f42e                	sd	a1,40(sp)
ffffffffc0200150:	f832                	sd	a2,48(sp)
ffffffffc0200152:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200154:	862a                	mv	a2,a0
ffffffffc0200156:	004c                	addi	a1,sp,4
ffffffffc0200158:	00000517          	auipc	a0,0x0
ffffffffc020015c:	fb850513          	addi	a0,a0,-72 # ffffffffc0200110 <cputch>
ffffffffc0200160:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc0200162:	ec06                	sd	ra,24(sp)
ffffffffc0200164:	e0ba                	sd	a4,64(sp)
ffffffffc0200166:	e4be                	sd	a5,72(sp)
ffffffffc0200168:	e8c2                	sd	a6,80(sp)
ffffffffc020016a:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc020016c:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc020016e:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	6ad010ef          	jal	ffffffffc020201c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200174:	60e2                	ld	ra,24(sp)
ffffffffc0200176:	4512                	lw	a0,4(sp)
ffffffffc0200178:	6125                	addi	sp,sp,96
ffffffffc020017a:	8082                	ret

ffffffffc020017c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc020017c:	1101                	addi	sp,sp,-32
ffffffffc020017e:	e822                	sd	s0,16(sp)
ffffffffc0200180:	ec06                	sd	ra,24(sp)
ffffffffc0200182:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200184:	00054503          	lbu	a0,0(a0)
ffffffffc0200188:	c51d                	beqz	a0,ffffffffc02001b6 <cputs+0x3a>
ffffffffc020018a:	e426                	sd	s1,8(sp)
ffffffffc020018c:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc020018e:	4481                	li	s1,0
    cons_putc(c);
ffffffffc0200190:	090000ef          	jal	ffffffffc0200220 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200194:	00044503          	lbu	a0,0(s0)
ffffffffc0200198:	0405                	addi	s0,s0,1
ffffffffc020019a:	87a6                	mv	a5,s1
    (*cnt) ++;
ffffffffc020019c:	2485                	addiw	s1,s1,1
    while ((c = *str ++) != '\0') {
ffffffffc020019e:	f96d                	bnez	a0,ffffffffc0200190 <cputs+0x14>
    cons_putc(c);
ffffffffc02001a0:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc02001a2:	0027841b          	addiw	s0,a5,2
ffffffffc02001a6:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001a8:	078000ef          	jal	ffffffffc0200220 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001ac:	60e2                	ld	ra,24(sp)
ffffffffc02001ae:	8522                	mv	a0,s0
ffffffffc02001b0:	6442                	ld	s0,16(sp)
ffffffffc02001b2:	6105                	addi	sp,sp,32
ffffffffc02001b4:	8082                	ret
    cons_putc(c);
ffffffffc02001b6:	4529                	li	a0,10
ffffffffc02001b8:	068000ef          	jal	ffffffffc0200220 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001bc:	4405                	li	s0,1
}
ffffffffc02001be:	60e2                	ld	ra,24(sp)
ffffffffc02001c0:	8522                	mv	a0,s0
ffffffffc02001c2:	6442                	ld	s0,16(sp)
ffffffffc02001c4:	6105                	addi	sp,sp,32
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c8:	00007317          	auipc	t1,0x7
ffffffffc02001cc:	f6832303          	lw	t1,-152(t1) # ffffffffc0207130 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d0:	715d                	addi	sp,sp,-80
ffffffffc02001d2:	ec06                	sd	ra,24(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	00030363          	beqz	t1,ffffffffc02001e4 <__panic+0x1c>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x1a>
    is_panic = 1;
ffffffffc02001e4:	4705                	li	a4,1
    va_start(ap, fmt);
ffffffffc02001e6:	103c                	addi	a5,sp,40
ffffffffc02001e8:	e822                	sd	s0,16(sp)
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	862e                	mv	a2,a1
ffffffffc02001ee:	85aa                	mv	a1,a0
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f0:	00002517          	auipc	a0,0x2
ffffffffc02001f4:	32050513          	addi	a0,a0,800 # ffffffffc0202510 <etext+0xd2>
    is_panic = 1;
ffffffffc02001f8:	00007697          	auipc	a3,0x7
ffffffffc02001fc:	f2e6ac23          	sw	a4,-200(a3) # ffffffffc0207130 <is_panic>
    va_start(ap, fmt);
ffffffffc0200200:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200202:	f47ff0ef          	jal	ffffffffc0200148 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200206:	65a2                	ld	a1,8(sp)
ffffffffc0200208:	8522                	mv	a0,s0
ffffffffc020020a:	f1fff0ef          	jal	ffffffffc0200128 <vcprintf>
    cprintf("\n");
ffffffffc020020e:	00002517          	auipc	a0,0x2
ffffffffc0200212:	32250513          	addi	a0,a0,802 # ffffffffc0202530 <etext+0xf2>
ffffffffc0200216:	f33ff0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc020021a:	6442                	ld	s0,16(sp)
ffffffffc020021c:	b7d9                	j	ffffffffc02001e2 <__panic+0x1a>

ffffffffc020021e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020021e:	8082                	ret

ffffffffc0200220 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200220:	0ff57513          	zext.b	a0,a0
ffffffffc0200224:	15e0206f          	j	ffffffffc0202382 <sbi_console_putchar>

ffffffffc0200228 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200228:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc020022a:	00002517          	auipc	a0,0x2
ffffffffc020022e:	30e50513          	addi	a0,a0,782 # ffffffffc0202538 <etext+0xfa>
void dtb_init(void) {
ffffffffc0200232:	f406                	sd	ra,40(sp)
ffffffffc0200234:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc0200236:	f13ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020023a:	00007597          	auipc	a1,0x7
ffffffffc020023e:	dc65b583          	ld	a1,-570(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc0200242:	00002517          	auipc	a0,0x2
ffffffffc0200246:	30650513          	addi	a0,a0,774 # ffffffffc0202548 <etext+0x10a>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020024a:	00007417          	auipc	s0,0x7
ffffffffc020024e:	dbe40413          	addi	s0,s0,-578 # ffffffffc0207008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200252:	ef7ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200256:	600c                	ld	a1,0(s0)
ffffffffc0200258:	00002517          	auipc	a0,0x2
ffffffffc020025c:	30050513          	addi	a0,a0,768 # ffffffffc0202558 <etext+0x11a>
ffffffffc0200260:	ee9ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200264:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200266:	00002517          	auipc	a0,0x2
ffffffffc020026a:	30a50513          	addi	a0,a0,778 # ffffffffc0202570 <etext+0x132>
    if (boot_dtb == 0) {
ffffffffc020026e:	10070163          	beqz	a4,ffffffffc0200370 <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200272:	57f5                	li	a5,-3
ffffffffc0200274:	07fa                	slli	a5,a5,0x1e
ffffffffc0200276:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200278:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc020027a:	d00e06b7          	lui	a3,0xd00e0
ffffffffc020027e:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfed8d75>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200282:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200286:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020028a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028e:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200292:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200296:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200298:	8e49                	or	a2,a2,a0
ffffffffc020029a:	0ff7f793          	zext.b	a5,a5
ffffffffc020029e:	8dd1                	or	a1,a1,a2
ffffffffc02002a0:	07a2                	slli	a5,a5,0x8
ffffffffc02002a2:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a4:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc02002a8:	0cd59863          	bne	a1,a3,ffffffffc0200378 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002ac:	4710                	lw	a2,8(a4)
ffffffffc02002ae:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02002b0:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002b2:	0086541b          	srliw	s0,a2,0x8
ffffffffc02002b6:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ba:	01865e1b          	srliw	t3,a2,0x18
ffffffffc02002be:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002c2:	0186151b          	slliw	a0,a2,0x18
ffffffffc02002c6:	0186959b          	slliw	a1,a3,0x18
ffffffffc02002ca:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ce:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002d2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d6:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02002da:	01c56533          	or	a0,a0,t3
ffffffffc02002de:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e2:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e6:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ea:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ee:	0ff6f693          	zext.b	a3,a3
ffffffffc02002f2:	8c49                	or	s0,s0,a0
ffffffffc02002f4:	0622                	slli	a2,a2,0x8
ffffffffc02002f6:	8fcd                	or	a5,a5,a1
ffffffffc02002f8:	06a2                	slli	a3,a3,0x8
ffffffffc02002fa:	8c51                	or	s0,s0,a2
ffffffffc02002fc:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02002fe:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200300:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200302:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200304:	9381                	srli	a5,a5,0x20
ffffffffc0200306:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200308:	4301                	li	t1,0
        switch (token) {
ffffffffc020030a:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020030c:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020030e:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc0200312:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200314:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200316:	0087579b          	srliw	a5,a4,0x8
ffffffffc020031a:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020031e:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200322:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200326:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020032a:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020032e:	8ed1                	or	a3,a3,a2
ffffffffc0200330:	0ff77713          	zext.b	a4,a4
ffffffffc0200334:	8fd5                	or	a5,a5,a3
ffffffffc0200336:	0722                	slli	a4,a4,0x8
ffffffffc0200338:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc020033a:	05178763          	beq	a5,a7,ffffffffc0200388 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020033e:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc0200340:	00f8e963          	bltu	a7,a5,ffffffffc0200352 <dtb_init+0x12a>
ffffffffc0200344:	07c78d63          	beq	a5,t3,ffffffffc02003be <dtb_init+0x196>
ffffffffc0200348:	4709                	li	a4,2
ffffffffc020034a:	00e79763          	bne	a5,a4,ffffffffc0200358 <dtb_init+0x130>
ffffffffc020034e:	4301                	li	t1,0
ffffffffc0200350:	b7d1                	j	ffffffffc0200314 <dtb_init+0xec>
ffffffffc0200352:	4711                	li	a4,4
ffffffffc0200354:	fce780e3          	beq	a5,a4,ffffffffc0200314 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200358:	00002517          	auipc	a0,0x2
ffffffffc020035c:	2e050513          	addi	a0,a0,736 # ffffffffc0202638 <etext+0x1fa>
ffffffffc0200360:	de9ff0ef          	jal	ffffffffc0200148 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200364:	64e2                	ld	s1,24(sp)
ffffffffc0200366:	6942                	ld	s2,16(sp)
ffffffffc0200368:	00002517          	auipc	a0,0x2
ffffffffc020036c:	30850513          	addi	a0,a0,776 # ffffffffc0202670 <etext+0x232>
}
ffffffffc0200370:	7402                	ld	s0,32(sp)
ffffffffc0200372:	70a2                	ld	ra,40(sp)
ffffffffc0200374:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200376:	bbc9                	j	ffffffffc0200148 <cprintf>
}
ffffffffc0200378:	7402                	ld	s0,32(sp)
ffffffffc020037a:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020037c:	00002517          	auipc	a0,0x2
ffffffffc0200380:	21450513          	addi	a0,a0,532 # ffffffffc0202590 <etext+0x152>
}
ffffffffc0200384:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200386:	b3c9                	j	ffffffffc0200148 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200388:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020038a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020038e:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200392:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200396:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020039a:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020039e:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02003a2:	8ed1                	or	a3,a3,a2
ffffffffc02003a4:	0ff77713          	zext.b	a4,a4
ffffffffc02003a8:	8fd5                	or	a5,a5,a3
ffffffffc02003aa:	0722                	slli	a4,a4,0x8
ffffffffc02003ac:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02003ae:	04031463          	bnez	t1,ffffffffc02003f6 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02003b2:	1782                	slli	a5,a5,0x20
ffffffffc02003b4:	9381                	srli	a5,a5,0x20
ffffffffc02003b6:	043d                	addi	s0,s0,15
ffffffffc02003b8:	943e                	add	s0,s0,a5
ffffffffc02003ba:	9871                	andi	s0,s0,-4
                break;
ffffffffc02003bc:	bfa1                	j	ffffffffc0200314 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc02003be:	8522                	mv	a0,s0
ffffffffc02003c0:	e01a                	sd	t1,0(sp)
ffffffffc02003c2:	7db010ef          	jal	ffffffffc020239c <strlen>
ffffffffc02003c6:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003c8:	4619                	li	a2,6
ffffffffc02003ca:	8522                	mv	a0,s0
ffffffffc02003cc:	00002597          	auipc	a1,0x2
ffffffffc02003d0:	1ec58593          	addi	a1,a1,492 # ffffffffc02025b8 <etext+0x17a>
ffffffffc02003d4:	030020ef          	jal	ffffffffc0202404 <strncmp>
ffffffffc02003d8:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003da:	0411                	addi	s0,s0,4
ffffffffc02003dc:	0004879b          	sext.w	a5,s1
ffffffffc02003e0:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e2:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003e6:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	00a36333          	or	t1,t1,a0
                break;
ffffffffc02003ec:	00ff0837          	lui	a6,0xff0
ffffffffc02003f0:	488d                	li	a7,3
ffffffffc02003f2:	4e05                	li	t3,1
ffffffffc02003f4:	b705                	j	ffffffffc0200314 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02003f6:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02003f8:	00002597          	auipc	a1,0x2
ffffffffc02003fc:	1c858593          	addi	a1,a1,456 # ffffffffc02025c0 <etext+0x182>
ffffffffc0200400:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200402:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200406:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020040a:	0187169b          	slliw	a3,a4,0x18
ffffffffc020040e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200412:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200416:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041a:	8ed1                	or	a3,a3,a2
ffffffffc020041c:	0ff77713          	zext.b	a4,a4
ffffffffc0200420:	0722                	slli	a4,a4,0x8
ffffffffc0200422:	8d55                	or	a0,a0,a3
ffffffffc0200424:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200426:	1502                	slli	a0,a0,0x20
ffffffffc0200428:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020042a:	954a                	add	a0,a0,s2
ffffffffc020042c:	e01a                	sd	t1,0(sp)
ffffffffc020042e:	7a3010ef          	jal	ffffffffc02023d0 <strcmp>
ffffffffc0200432:	67a2                	ld	a5,8(sp)
ffffffffc0200434:	473d                	li	a4,15
ffffffffc0200436:	6302                	ld	t1,0(sp)
ffffffffc0200438:	00ff0837          	lui	a6,0xff0
ffffffffc020043c:	488d                	li	a7,3
ffffffffc020043e:	4e05                	li	t3,1
ffffffffc0200440:	f6f779e3          	bgeu	a4,a5,ffffffffc02003b2 <dtb_init+0x18a>
ffffffffc0200444:	f53d                	bnez	a0,ffffffffc02003b2 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200446:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020044a:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020044e:	00002517          	auipc	a0,0x2
ffffffffc0200452:	17a50513          	addi	a0,a0,378 # ffffffffc02025c8 <etext+0x18a>
           fdt32_to_cpu(x >> 32);
ffffffffc0200456:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020045a:	0087d31b          	srliw	t1,a5,0x8
ffffffffc020045e:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200462:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200466:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020046a:	0187959b          	slliw	a1,a5,0x18
ffffffffc020046e:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200472:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200476:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020047a:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020047e:	01037333          	and	t1,t1,a6
ffffffffc0200482:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200486:	01e5e5b3          	or	a1,a1,t5
ffffffffc020048a:	0ff7f793          	zext.b	a5,a5
ffffffffc020048e:	01de6e33          	or	t3,t3,t4
ffffffffc0200492:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200496:	01067633          	and	a2,a2,a6
ffffffffc020049a:	0086d31b          	srliw	t1,a3,0x8
ffffffffc020049e:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a2:	07a2                	slli	a5,a5,0x8
ffffffffc02004a4:	0108d89b          	srliw	a7,a7,0x10
ffffffffc02004a8:	0186df1b          	srliw	t5,a3,0x18
ffffffffc02004ac:	01875e9b          	srliw	t4,a4,0x18
ffffffffc02004b0:	8ddd                	or	a1,a1,a5
ffffffffc02004b2:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b6:	0186979b          	slliw	a5,a3,0x18
ffffffffc02004ba:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004be:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c2:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c6:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ca:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ce:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004d2:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d6:	08a2                	slli	a7,a7,0x8
ffffffffc02004d8:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004dc:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004e0:	0ff6f693          	zext.b	a3,a3
ffffffffc02004e4:	01de6833          	or	a6,t3,t4
ffffffffc02004e8:	0ff77713          	zext.b	a4,a4
ffffffffc02004ec:	01166633          	or	a2,a2,a7
ffffffffc02004f0:	0067e7b3          	or	a5,a5,t1
ffffffffc02004f4:	06a2                	slli	a3,a3,0x8
ffffffffc02004f6:	01046433          	or	s0,s0,a6
ffffffffc02004fa:	0722                	slli	a4,a4,0x8
ffffffffc02004fc:	8fd5                	or	a5,a5,a3
ffffffffc02004fe:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc0200500:	1582                	slli	a1,a1,0x20
ffffffffc0200502:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200504:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200506:	9201                	srli	a2,a2,0x20
ffffffffc0200508:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020050a:	1402                	slli	s0,s0,0x20
ffffffffc020050c:	00b7e4b3          	or	s1,a5,a1
ffffffffc0200510:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200512:	c37ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200516:	85a6                	mv	a1,s1
ffffffffc0200518:	00002517          	auipc	a0,0x2
ffffffffc020051c:	0d050513          	addi	a0,a0,208 # ffffffffc02025e8 <etext+0x1aa>
ffffffffc0200520:	c29ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200524:	01445613          	srli	a2,s0,0x14
ffffffffc0200528:	85a2                	mv	a1,s0
ffffffffc020052a:	00002517          	auipc	a0,0x2
ffffffffc020052e:	0d650513          	addi	a0,a0,214 # ffffffffc0202600 <etext+0x1c2>
ffffffffc0200532:	c17ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200536:	009405b3          	add	a1,s0,s1
ffffffffc020053a:	15fd                	addi	a1,a1,-1
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	0e450513          	addi	a0,a0,228 # ffffffffc0202620 <etext+0x1e2>
ffffffffc0200544:	c05ff0ef          	jal	ffffffffc0200148 <cprintf>
        memory_base = mem_base;
ffffffffc0200548:	00007797          	auipc	a5,0x7
ffffffffc020054c:	be97bc23          	sd	s1,-1032(a5) # ffffffffc0207140 <memory_base>
        memory_size = mem_size;
ffffffffc0200550:	00007797          	auipc	a5,0x7
ffffffffc0200554:	be87b423          	sd	s0,-1048(a5) # ffffffffc0207138 <memory_size>
ffffffffc0200558:	b531                	j	ffffffffc0200364 <dtb_init+0x13c>

ffffffffc020055a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020055a:	00007517          	auipc	a0,0x7
ffffffffc020055e:	be653503          	ld	a0,-1050(a0) # ffffffffc0207140 <memory_base>
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc0200564:	00007517          	auipc	a0,0x7
ffffffffc0200568:	bd453503          	ld	a0,-1068(a0) # ffffffffc0207138 <memory_size>
ffffffffc020056c:	8082                	ret

ffffffffc020056e <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020056e:	00007797          	auipc	a5,0x7
ffffffffc0200572:	aaa78793          	addi	a5,a5,-1366 # ffffffffc0207018 <free_area>
ffffffffc0200576:	e79c                	sd	a5,8(a5)
ffffffffc0200578:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020057a:	0007a823          	sw	zero,16(a5)
}
ffffffffc020057e:	8082                	ret

ffffffffc0200580 <best_fit_nr_free_pages>:


static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200580:	00007517          	auipc	a0,0x7
ffffffffc0200584:	aa856503          	lwu	a0,-1368(a0) # ffffffffc0207028 <free_area+0x10>
ffffffffc0200588:	8082                	ret

ffffffffc020058a <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020058a:	c145                	beqz	a0,ffffffffc020062a <best_fit_alloc_pages+0xa0>
    if (n > nr_free) {
ffffffffc020058c:	00007817          	auipc	a6,0x7
ffffffffc0200590:	a9c82803          	lw	a6,-1380(a6) # ffffffffc0207028 <free_area+0x10>
ffffffffc0200594:	86aa                	mv	a3,a0
ffffffffc0200596:	00007617          	auipc	a2,0x7
ffffffffc020059a:	a8260613          	addi	a2,a2,-1406 # ffffffffc0207018 <free_area>
ffffffffc020059e:	02081793          	slli	a5,a6,0x20
ffffffffc02005a2:	9381                	srli	a5,a5,0x20
ffffffffc02005a4:	08a7e163          	bltu	a5,a0,ffffffffc0200626 <best_fit_alloc_pages+0x9c>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02005a8:	661c                	ld	a5,8(a2)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02005aa:	06c78e63          	beq	a5,a2,ffffffffc0200626 <best_fit_alloc_pages+0x9c>
    size_t min_size = nr_free + 1;
ffffffffc02005ae:	0018059b          	addiw	a1,a6,1
ffffffffc02005b2:	1582                	slli	a1,a1,0x20
ffffffffc02005b4:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc02005b6:	4501                	li	a0,0
        if (p->property >= n && p->property < min_size) {
ffffffffc02005b8:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02005bc:	00d76763          	bltu	a4,a3,ffffffffc02005ca <best_fit_alloc_pages+0x40>
ffffffffc02005c0:	00b77563          	bgeu	a4,a1,ffffffffc02005ca <best_fit_alloc_pages+0x40>
            min_size = p->property; // 更新最小块大小
ffffffffc02005c4:	85ba                	mv	a1,a4
        struct Page *p = le2page(le, page_link);
ffffffffc02005c6:	fe878513          	addi	a0,a5,-24
ffffffffc02005ca:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02005cc:	fec796e3          	bne	a5,a2,ffffffffc02005b8 <best_fit_alloc_pages+0x2e>
    if (page != NULL) {
ffffffffc02005d0:	cd21                	beqz	a0,ffffffffc0200628 <best_fit_alloc_pages+0x9e>
        if (page->property > n) {
ffffffffc02005d2:	01052883          	lw	a7,16(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc02005d6:	6d18                	ld	a4,24(a0)
    __list_del(listelm->prev, listelm->next);
ffffffffc02005d8:	710c                	ld	a1,32(a0)
ffffffffc02005da:	02089793          	slli	a5,a7,0x20
ffffffffc02005de:	9381                	srli	a5,a5,0x20
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02005e0:	e70c                	sd	a1,8(a4)
    next->prev = prev;
ffffffffc02005e2:	e198                	sd	a4,0(a1)
ffffffffc02005e4:	02f6f963          	bgeu	a3,a5,ffffffffc0200616 <best_fit_alloc_pages+0x8c>
            struct Page *p = page + n;  // 剩余块的首页
ffffffffc02005e8:	00269793          	slli	a5,a3,0x2
ffffffffc02005ec:	97b6                	add	a5,a5,a3
ffffffffc02005ee:	078e                	slli	a5,a5,0x3
ffffffffc02005f0:	97aa                	add	a5,a5,a0
            SetPageProperty(p);         // 标记为空闲块首页
ffffffffc02005f2:	0087b303          	ld	t1,8(a5)
            p->property = page->property - n;
ffffffffc02005f6:	40d888bb          	subw	a7,a7,a3
ffffffffc02005fa:	0117a823          	sw	a7,16(a5)
            SetPageProperty(p);         // 标记为空闲块首页
ffffffffc02005fe:	00236893          	ori	a7,t1,2
ffffffffc0200602:	0117b423          	sd	a7,8(a5)
            list_add(prev, &(p->page_link)); // 插入到原块的前一个位置
ffffffffc0200606:	01878893          	addi	a7,a5,24
    prev->next = next->prev = elm;
ffffffffc020060a:	0115b023          	sd	a7,0(a1)
ffffffffc020060e:	01173423          	sd	a7,8(a4)
    elm->next = next;
ffffffffc0200612:	f38c                	sd	a1,32(a5)
    elm->prev = prev;
ffffffffc0200614:	ef98                	sd	a4,24(a5)
        ClearPageProperty(page);       // 清除当前块的空闲标记
ffffffffc0200616:	651c                	ld	a5,8(a0)
        nr_free -= n;                  // 总空闲页减少
ffffffffc0200618:	40d8083b          	subw	a6,a6,a3
ffffffffc020061c:	01062823          	sw	a6,16(a2)
        ClearPageProperty(page);       // 清除当前块的空闲标记
ffffffffc0200620:	9bf5                	andi	a5,a5,-3
ffffffffc0200622:	e51c                	sd	a5,8(a0)
ffffffffc0200624:	8082                	ret
        return NULL;
ffffffffc0200626:	4501                	li	a0,0
}
ffffffffc0200628:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc020062a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020062c:	00002697          	auipc	a3,0x2
ffffffffc0200630:	05c68693          	addi	a3,a3,92 # ffffffffc0202688 <etext+0x24a>
ffffffffc0200634:	00002617          	auipc	a2,0x2
ffffffffc0200638:	05c60613          	addi	a2,a2,92 # ffffffffc0202690 <etext+0x252>
ffffffffc020063c:	07500593          	li	a1,117
ffffffffc0200640:	00002517          	auipc	a0,0x2
ffffffffc0200644:	06850513          	addi	a0,a0,104 # ffffffffc02026a8 <etext+0x26a>
best_fit_alloc_pages(size_t n) {
ffffffffc0200648:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020064a:	b7fff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc020064e <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc020064e:	711d                	addi	sp,sp,-96
ffffffffc0200650:	e0ca                	sd	s2,64(sp)
    return listelm->next;
ffffffffc0200652:	00007917          	auipc	s2,0x7
ffffffffc0200656:	9c690913          	addi	s2,s2,-1594 # ffffffffc0207018 <free_area>
ffffffffc020065a:	00893783          	ld	a5,8(s2)
ffffffffc020065e:	ec86                	sd	ra,88(sp)
ffffffffc0200660:	e8a2                	sd	s0,80(sp)
ffffffffc0200662:	e4a6                	sd	s1,72(sp)
ffffffffc0200664:	fc4e                	sd	s3,56(sp)
ffffffffc0200666:	f852                	sd	s4,48(sp)
ffffffffc0200668:	f456                	sd	s5,40(sp)
ffffffffc020066a:	f05a                	sd	s6,32(sp)
ffffffffc020066c:	ec5e                	sd	s7,24(sp)
ffffffffc020066e:	e862                	sd	s8,16(sp)
ffffffffc0200670:	e466                	sd	s9,8(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200672:	2b278f63          	beq	a5,s2,ffffffffc0200930 <best_fit_check+0x2e2>
    int count = 0, total = 0;
ffffffffc0200676:	4401                	li	s0,0
ffffffffc0200678:	4481                	li	s1,0
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020067a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020067e:	8b09                	andi	a4,a4,2
ffffffffc0200680:	2a070c63          	beqz	a4,ffffffffc0200938 <best_fit_check+0x2ea>
        count ++, total += p->property;
ffffffffc0200684:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200688:	679c                	ld	a5,8(a5)
ffffffffc020068a:	2485                	addiw	s1,s1,1
ffffffffc020068c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020068e:	ff2796e3          	bne	a5,s2,ffffffffc020067a <best_fit_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200692:	89a2                	mv	s3,s0
ffffffffc0200694:	153000ef          	jal	ffffffffc0200fe6 <nr_free_pages>
ffffffffc0200698:	39351063          	bne	a0,s3,ffffffffc0200a18 <best_fit_check+0x3ca>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020069c:	4505                	li	a0,1
ffffffffc020069e:	131000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02006a2:	8aaa                	mv	s5,a0
ffffffffc02006a4:	3a050a63          	beqz	a0,ffffffffc0200a58 <best_fit_check+0x40a>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02006a8:	4505                	li	a0,1
ffffffffc02006aa:	125000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02006ae:	89aa                	mv	s3,a0
ffffffffc02006b0:	38050463          	beqz	a0,ffffffffc0200a38 <best_fit_check+0x3ea>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02006b4:	4505                	li	a0,1
ffffffffc02006b6:	119000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02006ba:	8a2a                	mv	s4,a0
ffffffffc02006bc:	30050e63          	beqz	a0,ffffffffc02009d8 <best_fit_check+0x38a>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02006c0:	40aa87b3          	sub	a5,s5,a0
ffffffffc02006c4:	40a98733          	sub	a4,s3,a0
ffffffffc02006c8:	0017b793          	seqz	a5,a5
ffffffffc02006cc:	00173713          	seqz	a4,a4
ffffffffc02006d0:	8fd9                	or	a5,a5,a4
ffffffffc02006d2:	2e079363          	bnez	a5,ffffffffc02009b8 <best_fit_check+0x36a>
ffffffffc02006d6:	2f3a8163          	beq	s5,s3,ffffffffc02009b8 <best_fit_check+0x36a>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02006da:	000aa783          	lw	a5,0(s5)
ffffffffc02006de:	26079d63          	bnez	a5,ffffffffc0200958 <best_fit_check+0x30a>
ffffffffc02006e2:	0009a783          	lw	a5,0(s3)
ffffffffc02006e6:	26079963          	bnez	a5,ffffffffc0200958 <best_fit_check+0x30a>
ffffffffc02006ea:	411c                	lw	a5,0(a0)
ffffffffc02006ec:	26079663          	bnez	a5,ffffffffc0200958 <best_fit_check+0x30a>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02006f0:	00007797          	auipc	a5,0x7
ffffffffc02006f4:	a807b783          	ld	a5,-1408(a5) # ffffffffc0207170 <pages>
ffffffffc02006f8:	ccccd737          	lui	a4,0xccccd
ffffffffc02006fc:	ccd70713          	addi	a4,a4,-819 # ffffffffcccccccd <end+0xcac5b55>
ffffffffc0200700:	02071693          	slli	a3,a4,0x20
ffffffffc0200704:	96ba                	add	a3,a3,a4
ffffffffc0200706:	40fa8733          	sub	a4,s5,a5
ffffffffc020070a:	870d                	srai	a4,a4,0x3
ffffffffc020070c:	02d70733          	mul	a4,a4,a3
ffffffffc0200710:	00003517          	auipc	a0,0x3
ffffffffc0200714:	7d053503          	ld	a0,2000(a0) # ffffffffc0203ee0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200718:	00007697          	auipc	a3,0x7
ffffffffc020071c:	a506b683          	ld	a3,-1456(a3) # ffffffffc0207168 <npage>
ffffffffc0200720:	06b2                	slli	a3,a3,0xc
ffffffffc0200722:	972a                	add	a4,a4,a0

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200724:	0732                	slli	a4,a4,0xc
ffffffffc0200726:	26d77963          	bgeu	a4,a3,ffffffffc0200998 <best_fit_check+0x34a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020072a:	ccccd5b7          	lui	a1,0xccccd
ffffffffc020072e:	ccd58593          	addi	a1,a1,-819 # ffffffffcccccccd <end+0xcac5b55>
ffffffffc0200732:	02059613          	slli	a2,a1,0x20
ffffffffc0200736:	40f98733          	sub	a4,s3,a5
ffffffffc020073a:	962e                	add	a2,a2,a1
ffffffffc020073c:	870d                	srai	a4,a4,0x3
ffffffffc020073e:	02c70733          	mul	a4,a4,a2
ffffffffc0200742:	972a                	add	a4,a4,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200744:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200746:	40d77963          	bgeu	a4,a3,ffffffffc0200b58 <best_fit_check+0x50a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020074a:	40fa07b3          	sub	a5,s4,a5
ffffffffc020074e:	878d                	srai	a5,a5,0x3
ffffffffc0200750:	02c787b3          	mul	a5,a5,a2
ffffffffc0200754:	97aa                	add	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200756:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200758:	3ed7f063          	bgeu	a5,a3,ffffffffc0200b38 <best_fit_check+0x4ea>
    assert(alloc_page() == NULL);
ffffffffc020075c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020075e:	00093c03          	ld	s8,0(s2)
ffffffffc0200762:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200766:	00007b17          	auipc	s6,0x7
ffffffffc020076a:	8c2b2b03          	lw	s6,-1854(s6) # ffffffffc0207028 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc020076e:	01293023          	sd	s2,0(s2)
ffffffffc0200772:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0200776:	00007797          	auipc	a5,0x7
ffffffffc020077a:	8a07a923          	sw	zero,-1870(a5) # ffffffffc0207028 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020077e:	051000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc0200782:	38051b63          	bnez	a0,ffffffffc0200b18 <best_fit_check+0x4ca>
    free_page(p0);
ffffffffc0200786:	8556                	mv	a0,s5
ffffffffc0200788:	4585                	li	a1,1
ffffffffc020078a:	051000ef          	jal	ffffffffc0200fda <free_pages>
    free_page(p1);
ffffffffc020078e:	854e                	mv	a0,s3
ffffffffc0200790:	4585                	li	a1,1
ffffffffc0200792:	049000ef          	jal	ffffffffc0200fda <free_pages>
    free_page(p2);
ffffffffc0200796:	8552                	mv	a0,s4
ffffffffc0200798:	4585                	li	a1,1
ffffffffc020079a:	041000ef          	jal	ffffffffc0200fda <free_pages>
    assert(nr_free == 3);
ffffffffc020079e:	00007717          	auipc	a4,0x7
ffffffffc02007a2:	88a72703          	lw	a4,-1910(a4) # ffffffffc0207028 <free_area+0x10>
ffffffffc02007a6:	478d                	li	a5,3
ffffffffc02007a8:	34f71863          	bne	a4,a5,ffffffffc0200af8 <best_fit_check+0x4aa>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02007ac:	4505                	li	a0,1
ffffffffc02007ae:	021000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02007b2:	89aa                	mv	s3,a0
ffffffffc02007b4:	32050263          	beqz	a0,ffffffffc0200ad8 <best_fit_check+0x48a>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02007b8:	4505                	li	a0,1
ffffffffc02007ba:	015000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02007be:	8aaa                	mv	s5,a0
ffffffffc02007c0:	2e050c63          	beqz	a0,ffffffffc0200ab8 <best_fit_check+0x46a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02007c4:	4505                	li	a0,1
ffffffffc02007c6:	009000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02007ca:	8a2a                	mv	s4,a0
ffffffffc02007cc:	2c050663          	beqz	a0,ffffffffc0200a98 <best_fit_check+0x44a>
    assert(alloc_page() == NULL);
ffffffffc02007d0:	4505                	li	a0,1
ffffffffc02007d2:	7fc000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02007d6:	2a051163          	bnez	a0,ffffffffc0200a78 <best_fit_check+0x42a>
    free_page(p0);
ffffffffc02007da:	4585                	li	a1,1
ffffffffc02007dc:	854e                	mv	a0,s3
ffffffffc02007de:	7fc000ef          	jal	ffffffffc0200fda <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02007e2:	00893783          	ld	a5,8(s2)
ffffffffc02007e6:	19278963          	beq	a5,s2,ffffffffc0200978 <best_fit_check+0x32a>
    assert((p = alloc_page()) == p0);
ffffffffc02007ea:	4505                	li	a0,1
ffffffffc02007ec:	7e2000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02007f0:	8caa                	mv	s9,a0
ffffffffc02007f2:	54a99363          	bne	s3,a0,ffffffffc0200d38 <best_fit_check+0x6ea>
    assert(alloc_page() == NULL);
ffffffffc02007f6:	4505                	li	a0,1
ffffffffc02007f8:	7d6000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02007fc:	50051e63          	bnez	a0,ffffffffc0200d18 <best_fit_check+0x6ca>
    assert(nr_free == 0);
ffffffffc0200800:	00007797          	auipc	a5,0x7
ffffffffc0200804:	8287a783          	lw	a5,-2008(a5) # ffffffffc0207028 <free_area+0x10>
ffffffffc0200808:	4e079863          	bnez	a5,ffffffffc0200cf8 <best_fit_check+0x6aa>
    free_page(p);
ffffffffc020080c:	8566                	mv	a0,s9
ffffffffc020080e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200810:	01893023          	sd	s8,0(s2)
ffffffffc0200814:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0200818:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc020081c:	7be000ef          	jal	ffffffffc0200fda <free_pages>
    free_page(p1);
ffffffffc0200820:	8556                	mv	a0,s5
ffffffffc0200822:	4585                	li	a1,1
ffffffffc0200824:	7b6000ef          	jal	ffffffffc0200fda <free_pages>
    free_page(p2);
ffffffffc0200828:	8552                	mv	a0,s4
ffffffffc020082a:	4585                	li	a1,1
ffffffffc020082c:	7ae000ef          	jal	ffffffffc0200fda <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200830:	4515                	li	a0,5
ffffffffc0200832:	79c000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc0200836:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200838:	4a050063          	beqz	a0,ffffffffc0200cd8 <best_fit_check+0x68a>
    assert(!PageProperty(p0));
ffffffffc020083c:	651c                	ld	a5,8(a0)
ffffffffc020083e:	8b89                	andi	a5,a5,2
ffffffffc0200840:	46079c63          	bnez	a5,ffffffffc0200cb8 <best_fit_check+0x66a>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200844:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200846:	00093b83          	ld	s7,0(s2)
ffffffffc020084a:	00893b03          	ld	s6,8(s2)
ffffffffc020084e:	01293023          	sd	s2,0(s2)
ffffffffc0200852:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0200856:	778000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc020085a:	42051f63          	bnez	a0,ffffffffc0200c98 <best_fit_check+0x64a>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc020085e:	4589                	li	a1,2
ffffffffc0200860:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200864:	00006c17          	auipc	s8,0x6
ffffffffc0200868:	7c4c2c03          	lw	s8,1988(s8) # ffffffffc0207028 <free_area+0x10>
    free_pages(p0 + 4, 1);
ffffffffc020086c:	0a098a93          	addi	s5,s3,160
    nr_free = 0;
ffffffffc0200870:	00006797          	auipc	a5,0x6
ffffffffc0200874:	7a07ac23          	sw	zero,1976(a5) # ffffffffc0207028 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200878:	762000ef          	jal	ffffffffc0200fda <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc020087c:	8556                	mv	a0,s5
ffffffffc020087e:	4585                	li	a1,1
ffffffffc0200880:	75a000ef          	jal	ffffffffc0200fda <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200884:	4511                	li	a0,4
ffffffffc0200886:	748000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc020088a:	3e051763          	bnez	a0,ffffffffc0200c78 <best_fit_check+0x62a>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc020088e:	0309b783          	ld	a5,48(s3)
ffffffffc0200892:	8b89                	andi	a5,a5,2
ffffffffc0200894:	3c078263          	beqz	a5,ffffffffc0200c58 <best_fit_check+0x60a>
ffffffffc0200898:	0389ac83          	lw	s9,56(s3)
ffffffffc020089c:	4789                	li	a5,2
ffffffffc020089e:	3afc9d63          	bne	s9,a5,ffffffffc0200c58 <best_fit_check+0x60a>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc02008a2:	4505                	li	a0,1
ffffffffc02008a4:	72a000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02008a8:	8a2a                	mv	s4,a0
ffffffffc02008aa:	38050763          	beqz	a0,ffffffffc0200c38 <best_fit_check+0x5ea>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc02008ae:	8566                	mv	a0,s9
ffffffffc02008b0:	71e000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02008b4:	36050263          	beqz	a0,ffffffffc0200c18 <best_fit_check+0x5ca>
    assert(p0 + 4 == p1);
ffffffffc02008b8:	354a9063          	bne	s5,s4,ffffffffc0200bf8 <best_fit_check+0x5aa>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc02008bc:	854e                	mv	a0,s3
ffffffffc02008be:	4595                	li	a1,5
ffffffffc02008c0:	71a000ef          	jal	ffffffffc0200fda <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02008c4:	4515                	li	a0,5
ffffffffc02008c6:	708000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02008ca:	89aa                	mv	s3,a0
ffffffffc02008cc:	30050663          	beqz	a0,ffffffffc0200bd8 <best_fit_check+0x58a>
    assert(alloc_page() == NULL);
ffffffffc02008d0:	4505                	li	a0,1
ffffffffc02008d2:	6fc000ef          	jal	ffffffffc0200fce <alloc_pages>
ffffffffc02008d6:	2e051163          	bnez	a0,ffffffffc0200bb8 <best_fit_check+0x56a>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc02008da:	00006797          	auipc	a5,0x6
ffffffffc02008de:	74e7a783          	lw	a5,1870(a5) # ffffffffc0207028 <free_area+0x10>
ffffffffc02008e2:	2a079b63          	bnez	a5,ffffffffc0200b98 <best_fit_check+0x54a>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02008e6:	854e                	mv	a0,s3
ffffffffc02008e8:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc02008ea:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc02008ee:	01793023          	sd	s7,0(s2)
ffffffffc02008f2:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc02008f6:	6e4000ef          	jal	ffffffffc0200fda <free_pages>
    return listelm->next;
ffffffffc02008fa:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008fe:	01278963          	beq	a5,s2,ffffffffc0200910 <best_fit_check+0x2c2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200902:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200906:	679c                	ld	a5,8(a5)
ffffffffc0200908:	34fd                	addiw	s1,s1,-1
ffffffffc020090a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020090c:	ff279be3          	bne	a5,s2,ffffffffc0200902 <best_fit_check+0x2b4>
    }
    assert(count == 0);
ffffffffc0200910:	26049463          	bnez	s1,ffffffffc0200b78 <best_fit_check+0x52a>
    assert(total == 0);
ffffffffc0200914:	e075                	bnez	s0,ffffffffc02009f8 <best_fit_check+0x3aa>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200916:	60e6                	ld	ra,88(sp)
ffffffffc0200918:	6446                	ld	s0,80(sp)
ffffffffc020091a:	64a6                	ld	s1,72(sp)
ffffffffc020091c:	6906                	ld	s2,64(sp)
ffffffffc020091e:	79e2                	ld	s3,56(sp)
ffffffffc0200920:	7a42                	ld	s4,48(sp)
ffffffffc0200922:	7aa2                	ld	s5,40(sp)
ffffffffc0200924:	7b02                	ld	s6,32(sp)
ffffffffc0200926:	6be2                	ld	s7,24(sp)
ffffffffc0200928:	6c42                	ld	s8,16(sp)
ffffffffc020092a:	6ca2                	ld	s9,8(sp)
ffffffffc020092c:	6125                	addi	sp,sp,96
ffffffffc020092e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200930:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200932:	4401                	li	s0,0
ffffffffc0200934:	4481                	li	s1,0
ffffffffc0200936:	bbb9                	j	ffffffffc0200694 <best_fit_check+0x46>
        assert(PageProperty(p));
ffffffffc0200938:	00002697          	auipc	a3,0x2
ffffffffc020093c:	d8868693          	addi	a3,a3,-632 # ffffffffc02026c0 <etext+0x282>
ffffffffc0200940:	00002617          	auipc	a2,0x2
ffffffffc0200944:	d5060613          	addi	a2,a2,-688 # ffffffffc0202690 <etext+0x252>
ffffffffc0200948:	12200593          	li	a1,290
ffffffffc020094c:	00002517          	auipc	a0,0x2
ffffffffc0200950:	d5c50513          	addi	a0,a0,-676 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200954:	875ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200958:	00002697          	auipc	a3,0x2
ffffffffc020095c:	e2068693          	addi	a3,a3,-480 # ffffffffc0202778 <etext+0x33a>
ffffffffc0200960:	00002617          	auipc	a2,0x2
ffffffffc0200964:	d3060613          	addi	a2,a2,-720 # ffffffffc0202690 <etext+0x252>
ffffffffc0200968:	0ef00593          	li	a1,239
ffffffffc020096c:	00002517          	auipc	a0,0x2
ffffffffc0200970:	d3c50513          	addi	a0,a0,-708 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200974:	855ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200978:	00002697          	auipc	a3,0x2
ffffffffc020097c:	ec868693          	addi	a3,a3,-312 # ffffffffc0202840 <etext+0x402>
ffffffffc0200980:	00002617          	auipc	a2,0x2
ffffffffc0200984:	d1060613          	addi	a2,a2,-752 # ffffffffc0202690 <etext+0x252>
ffffffffc0200988:	10a00593          	li	a1,266
ffffffffc020098c:	00002517          	auipc	a0,0x2
ffffffffc0200990:	d1c50513          	addi	a0,a0,-740 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200994:	835ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200998:	00002697          	auipc	a3,0x2
ffffffffc020099c:	e2068693          	addi	a3,a3,-480 # ffffffffc02027b8 <etext+0x37a>
ffffffffc02009a0:	00002617          	auipc	a2,0x2
ffffffffc02009a4:	cf060613          	addi	a2,a2,-784 # ffffffffc0202690 <etext+0x252>
ffffffffc02009a8:	0f100593          	li	a1,241
ffffffffc02009ac:	00002517          	auipc	a0,0x2
ffffffffc02009b0:	cfc50513          	addi	a0,a0,-772 # ffffffffc02026a8 <etext+0x26a>
ffffffffc02009b4:	815ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02009b8:	00002697          	auipc	a3,0x2
ffffffffc02009bc:	d9868693          	addi	a3,a3,-616 # ffffffffc0202750 <etext+0x312>
ffffffffc02009c0:	00002617          	auipc	a2,0x2
ffffffffc02009c4:	cd060613          	addi	a2,a2,-816 # ffffffffc0202690 <etext+0x252>
ffffffffc02009c8:	0ee00593          	li	a1,238
ffffffffc02009cc:	00002517          	auipc	a0,0x2
ffffffffc02009d0:	cdc50513          	addi	a0,a0,-804 # ffffffffc02026a8 <etext+0x26a>
ffffffffc02009d4:	ff4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009d8:	00002697          	auipc	a3,0x2
ffffffffc02009dc:	d5868693          	addi	a3,a3,-680 # ffffffffc0202730 <etext+0x2f2>
ffffffffc02009e0:	00002617          	auipc	a2,0x2
ffffffffc02009e4:	cb060613          	addi	a2,a2,-848 # ffffffffc0202690 <etext+0x252>
ffffffffc02009e8:	0ec00593          	li	a1,236
ffffffffc02009ec:	00002517          	auipc	a0,0x2
ffffffffc02009f0:	cbc50513          	addi	a0,a0,-836 # ffffffffc02026a8 <etext+0x26a>
ffffffffc02009f4:	fd4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(total == 0);
ffffffffc02009f8:	00002697          	auipc	a3,0x2
ffffffffc02009fc:	f7868693          	addi	a3,a3,-136 # ffffffffc0202970 <etext+0x532>
ffffffffc0200a00:	00002617          	auipc	a2,0x2
ffffffffc0200a04:	c9060613          	addi	a2,a2,-880 # ffffffffc0202690 <etext+0x252>
ffffffffc0200a08:	16400593          	li	a1,356
ffffffffc0200a0c:	00002517          	auipc	a0,0x2
ffffffffc0200a10:	c9c50513          	addi	a0,a0,-868 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200a14:	fb4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200a18:	00002697          	auipc	a3,0x2
ffffffffc0200a1c:	cb868693          	addi	a3,a3,-840 # ffffffffc02026d0 <etext+0x292>
ffffffffc0200a20:	00002617          	auipc	a2,0x2
ffffffffc0200a24:	c7060613          	addi	a2,a2,-912 # ffffffffc0202690 <etext+0x252>
ffffffffc0200a28:	12500593          	li	a1,293
ffffffffc0200a2c:	00002517          	auipc	a0,0x2
ffffffffc0200a30:	c7c50513          	addi	a0,a0,-900 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200a34:	f94ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a38:	00002697          	auipc	a3,0x2
ffffffffc0200a3c:	cd868693          	addi	a3,a3,-808 # ffffffffc0202710 <etext+0x2d2>
ffffffffc0200a40:	00002617          	auipc	a2,0x2
ffffffffc0200a44:	c5060613          	addi	a2,a2,-944 # ffffffffc0202690 <etext+0x252>
ffffffffc0200a48:	0eb00593          	li	a1,235
ffffffffc0200a4c:	00002517          	auipc	a0,0x2
ffffffffc0200a50:	c5c50513          	addi	a0,a0,-932 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200a54:	f74ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a58:	00002697          	auipc	a3,0x2
ffffffffc0200a5c:	c9868693          	addi	a3,a3,-872 # ffffffffc02026f0 <etext+0x2b2>
ffffffffc0200a60:	00002617          	auipc	a2,0x2
ffffffffc0200a64:	c3060613          	addi	a2,a2,-976 # ffffffffc0202690 <etext+0x252>
ffffffffc0200a68:	0ea00593          	li	a1,234
ffffffffc0200a6c:	00002517          	auipc	a0,0x2
ffffffffc0200a70:	c3c50513          	addi	a0,a0,-964 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200a74:	f54ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200a78:	00002697          	auipc	a3,0x2
ffffffffc0200a7c:	da068693          	addi	a3,a3,-608 # ffffffffc0202818 <etext+0x3da>
ffffffffc0200a80:	00002617          	auipc	a2,0x2
ffffffffc0200a84:	c1060613          	addi	a2,a2,-1008 # ffffffffc0202690 <etext+0x252>
ffffffffc0200a88:	10700593          	li	a1,263
ffffffffc0200a8c:	00002517          	auipc	a0,0x2
ffffffffc0200a90:	c1c50513          	addi	a0,a0,-996 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200a94:	f34ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a98:	00002697          	auipc	a3,0x2
ffffffffc0200a9c:	c9868693          	addi	a3,a3,-872 # ffffffffc0202730 <etext+0x2f2>
ffffffffc0200aa0:	00002617          	auipc	a2,0x2
ffffffffc0200aa4:	bf060613          	addi	a2,a2,-1040 # ffffffffc0202690 <etext+0x252>
ffffffffc0200aa8:	10500593          	li	a1,261
ffffffffc0200aac:	00002517          	auipc	a0,0x2
ffffffffc0200ab0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200ab4:	f14ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ab8:	00002697          	auipc	a3,0x2
ffffffffc0200abc:	c5868693          	addi	a3,a3,-936 # ffffffffc0202710 <etext+0x2d2>
ffffffffc0200ac0:	00002617          	auipc	a2,0x2
ffffffffc0200ac4:	bd060613          	addi	a2,a2,-1072 # ffffffffc0202690 <etext+0x252>
ffffffffc0200ac8:	10400593          	li	a1,260
ffffffffc0200acc:	00002517          	auipc	a0,0x2
ffffffffc0200ad0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200ad4:	ef4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ad8:	00002697          	auipc	a3,0x2
ffffffffc0200adc:	c1868693          	addi	a3,a3,-1000 # ffffffffc02026f0 <etext+0x2b2>
ffffffffc0200ae0:	00002617          	auipc	a2,0x2
ffffffffc0200ae4:	bb060613          	addi	a2,a2,-1104 # ffffffffc0202690 <etext+0x252>
ffffffffc0200ae8:	10300593          	li	a1,259
ffffffffc0200aec:	00002517          	auipc	a0,0x2
ffffffffc0200af0:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200af4:	ed4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(nr_free == 3);
ffffffffc0200af8:	00002697          	auipc	a3,0x2
ffffffffc0200afc:	d3868693          	addi	a3,a3,-712 # ffffffffc0202830 <etext+0x3f2>
ffffffffc0200b00:	00002617          	auipc	a2,0x2
ffffffffc0200b04:	b9060613          	addi	a2,a2,-1136 # ffffffffc0202690 <etext+0x252>
ffffffffc0200b08:	10100593          	li	a1,257
ffffffffc0200b0c:	00002517          	auipc	a0,0x2
ffffffffc0200b10:	b9c50513          	addi	a0,a0,-1124 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200b14:	eb4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200b18:	00002697          	auipc	a3,0x2
ffffffffc0200b1c:	d0068693          	addi	a3,a3,-768 # ffffffffc0202818 <etext+0x3da>
ffffffffc0200b20:	00002617          	auipc	a2,0x2
ffffffffc0200b24:	b7060613          	addi	a2,a2,-1168 # ffffffffc0202690 <etext+0x252>
ffffffffc0200b28:	0fc00593          	li	a1,252
ffffffffc0200b2c:	00002517          	auipc	a0,0x2
ffffffffc0200b30:	b7c50513          	addi	a0,a0,-1156 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200b34:	e94ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200b38:	00002697          	auipc	a3,0x2
ffffffffc0200b3c:	cc068693          	addi	a3,a3,-832 # ffffffffc02027f8 <etext+0x3ba>
ffffffffc0200b40:	00002617          	auipc	a2,0x2
ffffffffc0200b44:	b5060613          	addi	a2,a2,-1200 # ffffffffc0202690 <etext+0x252>
ffffffffc0200b48:	0f300593          	li	a1,243
ffffffffc0200b4c:	00002517          	auipc	a0,0x2
ffffffffc0200b50:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200b54:	e74ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b58:	00002697          	auipc	a3,0x2
ffffffffc0200b5c:	c8068693          	addi	a3,a3,-896 # ffffffffc02027d8 <etext+0x39a>
ffffffffc0200b60:	00002617          	auipc	a2,0x2
ffffffffc0200b64:	b3060613          	addi	a2,a2,-1232 # ffffffffc0202690 <etext+0x252>
ffffffffc0200b68:	0f200593          	li	a1,242
ffffffffc0200b6c:	00002517          	auipc	a0,0x2
ffffffffc0200b70:	b3c50513          	addi	a0,a0,-1220 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200b74:	e54ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(count == 0);
ffffffffc0200b78:	00002697          	auipc	a3,0x2
ffffffffc0200b7c:	de868693          	addi	a3,a3,-536 # ffffffffc0202960 <etext+0x522>
ffffffffc0200b80:	00002617          	auipc	a2,0x2
ffffffffc0200b84:	b1060613          	addi	a2,a2,-1264 # ffffffffc0202690 <etext+0x252>
ffffffffc0200b88:	16300593          	li	a1,355
ffffffffc0200b8c:	00002517          	auipc	a0,0x2
ffffffffc0200b90:	b1c50513          	addi	a0,a0,-1252 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200b94:	e34ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0200b98:	00002697          	auipc	a3,0x2
ffffffffc0200b9c:	ce068693          	addi	a3,a3,-800 # ffffffffc0202878 <etext+0x43a>
ffffffffc0200ba0:	00002617          	auipc	a2,0x2
ffffffffc0200ba4:	af060613          	addi	a2,a2,-1296 # ffffffffc0202690 <etext+0x252>
ffffffffc0200ba8:	15800593          	li	a1,344
ffffffffc0200bac:	00002517          	auipc	a0,0x2
ffffffffc0200bb0:	afc50513          	addi	a0,a0,-1284 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200bb4:	e14ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200bb8:	00002697          	auipc	a3,0x2
ffffffffc0200bbc:	c6068693          	addi	a3,a3,-928 # ffffffffc0202818 <etext+0x3da>
ffffffffc0200bc0:	00002617          	auipc	a2,0x2
ffffffffc0200bc4:	ad060613          	addi	a2,a2,-1328 # ffffffffc0202690 <etext+0x252>
ffffffffc0200bc8:	15200593          	li	a1,338
ffffffffc0200bcc:	00002517          	auipc	a0,0x2
ffffffffc0200bd0:	adc50513          	addi	a0,a0,-1316 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200bd4:	df4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200bd8:	00002697          	auipc	a3,0x2
ffffffffc0200bdc:	d6868693          	addi	a3,a3,-664 # ffffffffc0202940 <etext+0x502>
ffffffffc0200be0:	00002617          	auipc	a2,0x2
ffffffffc0200be4:	ab060613          	addi	a2,a2,-1360 # ffffffffc0202690 <etext+0x252>
ffffffffc0200be8:	15100593          	li	a1,337
ffffffffc0200bec:	00002517          	auipc	a0,0x2
ffffffffc0200bf0:	abc50513          	addi	a0,a0,-1348 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200bf4:	dd4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200bf8:	00002697          	auipc	a3,0x2
ffffffffc0200bfc:	d3868693          	addi	a3,a3,-712 # ffffffffc0202930 <etext+0x4f2>
ffffffffc0200c00:	00002617          	auipc	a2,0x2
ffffffffc0200c04:	a9060613          	addi	a2,a2,-1392 # ffffffffc0202690 <etext+0x252>
ffffffffc0200c08:	14900593          	li	a1,329
ffffffffc0200c0c:	00002517          	auipc	a0,0x2
ffffffffc0200c10:	a9c50513          	addi	a0,a0,-1380 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200c14:	db4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200c18:	00002697          	auipc	a3,0x2
ffffffffc0200c1c:	d0068693          	addi	a3,a3,-768 # ffffffffc0202918 <etext+0x4da>
ffffffffc0200c20:	00002617          	auipc	a2,0x2
ffffffffc0200c24:	a7060613          	addi	a2,a2,-1424 # ffffffffc0202690 <etext+0x252>
ffffffffc0200c28:	14800593          	li	a1,328
ffffffffc0200c2c:	00002517          	auipc	a0,0x2
ffffffffc0200c30:	a7c50513          	addi	a0,a0,-1412 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200c34:	d94ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200c38:	00002697          	auipc	a3,0x2
ffffffffc0200c3c:	cc068693          	addi	a3,a3,-832 # ffffffffc02028f8 <etext+0x4ba>
ffffffffc0200c40:	00002617          	auipc	a2,0x2
ffffffffc0200c44:	a5060613          	addi	a2,a2,-1456 # ffffffffc0202690 <etext+0x252>
ffffffffc0200c48:	14700593          	li	a1,327
ffffffffc0200c4c:	00002517          	auipc	a0,0x2
ffffffffc0200c50:	a5c50513          	addi	a0,a0,-1444 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200c54:	d74ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200c58:	00002697          	auipc	a3,0x2
ffffffffc0200c5c:	c7068693          	addi	a3,a3,-912 # ffffffffc02028c8 <etext+0x48a>
ffffffffc0200c60:	00002617          	auipc	a2,0x2
ffffffffc0200c64:	a3060613          	addi	a2,a2,-1488 # ffffffffc0202690 <etext+0x252>
ffffffffc0200c68:	14500593          	li	a1,325
ffffffffc0200c6c:	00002517          	auipc	a0,0x2
ffffffffc0200c70:	a3c50513          	addi	a0,a0,-1476 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200c74:	d54ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200c78:	00002697          	auipc	a3,0x2
ffffffffc0200c7c:	c3868693          	addi	a3,a3,-968 # ffffffffc02028b0 <etext+0x472>
ffffffffc0200c80:	00002617          	auipc	a2,0x2
ffffffffc0200c84:	a1060613          	addi	a2,a2,-1520 # ffffffffc0202690 <etext+0x252>
ffffffffc0200c88:	14400593          	li	a1,324
ffffffffc0200c8c:	00002517          	auipc	a0,0x2
ffffffffc0200c90:	a1c50513          	addi	a0,a0,-1508 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200c94:	d34ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c98:	00002697          	auipc	a3,0x2
ffffffffc0200c9c:	b8068693          	addi	a3,a3,-1152 # ffffffffc0202818 <etext+0x3da>
ffffffffc0200ca0:	00002617          	auipc	a2,0x2
ffffffffc0200ca4:	9f060613          	addi	a2,a2,-1552 # ffffffffc0202690 <etext+0x252>
ffffffffc0200ca8:	13800593          	li	a1,312
ffffffffc0200cac:	00002517          	auipc	a0,0x2
ffffffffc0200cb0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200cb4:	d14ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(!PageProperty(p0));
ffffffffc0200cb8:	00002697          	auipc	a3,0x2
ffffffffc0200cbc:	be068693          	addi	a3,a3,-1056 # ffffffffc0202898 <etext+0x45a>
ffffffffc0200cc0:	00002617          	auipc	a2,0x2
ffffffffc0200cc4:	9d060613          	addi	a2,a2,-1584 # ffffffffc0202690 <etext+0x252>
ffffffffc0200cc8:	12f00593          	li	a1,303
ffffffffc0200ccc:	00002517          	auipc	a0,0x2
ffffffffc0200cd0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200cd4:	cf4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p0 != NULL);
ffffffffc0200cd8:	00002697          	auipc	a3,0x2
ffffffffc0200cdc:	bb068693          	addi	a3,a3,-1104 # ffffffffc0202888 <etext+0x44a>
ffffffffc0200ce0:	00002617          	auipc	a2,0x2
ffffffffc0200ce4:	9b060613          	addi	a2,a2,-1616 # ffffffffc0202690 <etext+0x252>
ffffffffc0200ce8:	12e00593          	li	a1,302
ffffffffc0200cec:	00002517          	auipc	a0,0x2
ffffffffc0200cf0:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200cf4:	cd4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0200cf8:	00002697          	auipc	a3,0x2
ffffffffc0200cfc:	b8068693          	addi	a3,a3,-1152 # ffffffffc0202878 <etext+0x43a>
ffffffffc0200d00:	00002617          	auipc	a2,0x2
ffffffffc0200d04:	99060613          	addi	a2,a2,-1648 # ffffffffc0202690 <etext+0x252>
ffffffffc0200d08:	11000593          	li	a1,272
ffffffffc0200d0c:	00002517          	auipc	a0,0x2
ffffffffc0200d10:	99c50513          	addi	a0,a0,-1636 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200d14:	cb4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d18:	00002697          	auipc	a3,0x2
ffffffffc0200d1c:	b0068693          	addi	a3,a3,-1280 # ffffffffc0202818 <etext+0x3da>
ffffffffc0200d20:	00002617          	auipc	a2,0x2
ffffffffc0200d24:	97060613          	addi	a2,a2,-1680 # ffffffffc0202690 <etext+0x252>
ffffffffc0200d28:	10e00593          	li	a1,270
ffffffffc0200d2c:	00002517          	auipc	a0,0x2
ffffffffc0200d30:	97c50513          	addi	a0,a0,-1668 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200d34:	c94ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200d38:	00002697          	auipc	a3,0x2
ffffffffc0200d3c:	b2068693          	addi	a3,a3,-1248 # ffffffffc0202858 <etext+0x41a>
ffffffffc0200d40:	00002617          	auipc	a2,0x2
ffffffffc0200d44:	95060613          	addi	a2,a2,-1712 # ffffffffc0202690 <etext+0x252>
ffffffffc0200d48:	10d00593          	li	a1,269
ffffffffc0200d4c:	00002517          	auipc	a0,0x2
ffffffffc0200d50:	95c50513          	addi	a0,a0,-1700 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200d54:	c74ff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200d58 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200d58:	1141                	addi	sp,sp,-16
ffffffffc0200d5a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200d5c:	14058e63          	beqz	a1,ffffffffc0200eb8 <best_fit_free_pages+0x160>
    for (; p != base + n; p ++) {
ffffffffc0200d60:	00259713          	slli	a4,a1,0x2
ffffffffc0200d64:	972e                	add	a4,a4,a1
ffffffffc0200d66:	070e                	slli	a4,a4,0x3
ffffffffc0200d68:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0200d6c:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0200d6e:	cf09                	beqz	a4,ffffffffc0200d88 <best_fit_free_pages+0x30>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200d70:	6798                	ld	a4,8(a5)
ffffffffc0200d72:	8b0d                	andi	a4,a4,3
ffffffffc0200d74:	12071263          	bnez	a4,ffffffffc0200e98 <best_fit_free_pages+0x140>
        p->flags = 0;
ffffffffc0200d78:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d7c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200d80:	02878793          	addi	a5,a5,40
ffffffffc0200d84:	fed796e3          	bne	a5,a3,ffffffffc0200d70 <best_fit_free_pages+0x18>
    SetPageProperty(base);            // 标记为空闲块首页
ffffffffc0200d88:	00853883          	ld	a7,8(a0)
    nr_free += n;                     // 总空闲页增加
ffffffffc0200d8c:	00006717          	auipc	a4,0x6
ffffffffc0200d90:	29c72703          	lw	a4,668(a4) # ffffffffc0207028 <free_area+0x10>
ffffffffc0200d94:	00006697          	auipc	a3,0x6
ffffffffc0200d98:	28468693          	addi	a3,a3,644 # ffffffffc0207018 <free_area>
    return list->next == list;
ffffffffc0200d9c:	669c                	ld	a5,8(a3)
    SetPageProperty(base);            // 标记为空闲块首页
ffffffffc0200d9e:	0028e613          	ori	a2,a7,2
    base->property = n;               // 块首页记录块大小
ffffffffc0200da2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);            // 标记为空闲块首页
ffffffffc0200da4:	e510                	sd	a2,8(a0)
    nr_free += n;                     // 总空闲页增加
ffffffffc0200da6:	9f2d                	addw	a4,a4,a1
ffffffffc0200da8:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200daa:	0ad78763          	beq	a5,a3,ffffffffc0200e58 <best_fit_free_pages+0x100>
            struct Page* page = le2page(le, page_link);
ffffffffc0200dae:	fe878713          	addi	a4,a5,-24
ffffffffc0200db2:	4801                	li	a6,0
ffffffffc0200db4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0200db8:	00e56a63          	bltu	a0,a4,ffffffffc0200dcc <best_fit_free_pages+0x74>
    return listelm->next;
ffffffffc0200dbc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200dbe:	06d70563          	beq	a4,a3,ffffffffc0200e28 <best_fit_free_pages+0xd0>
    struct Page *p = base;
ffffffffc0200dc2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200dc4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200dc8:	fee57ae3          	bgeu	a0,a4,ffffffffc0200dbc <best_fit_free_pages+0x64>
ffffffffc0200dcc:	00080463          	beqz	a6,ffffffffc0200dd4 <best_fit_free_pages+0x7c>
ffffffffc0200dd0:	0066b023          	sd	t1,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200dd4:	0007b803          	ld	a6,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200dd8:	e390                	sd	a2,0(a5)
ffffffffc0200dda:	00c83423          	sd	a2,8(a6)
    elm->prev = prev;
ffffffffc0200dde:	01053c23          	sd	a6,24(a0)
    elm->next = next;
ffffffffc0200de2:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc0200de4:	02d80063          	beq	a6,a3,ffffffffc0200e04 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0200de8:	ff882e03          	lw	t3,-8(a6)
        p = le2page(le, page_link);
ffffffffc0200dec:	fe880313          	addi	t1,a6,-24
        if (p + p->property == base) {
ffffffffc0200df0:	020e1613          	slli	a2,t3,0x20
ffffffffc0200df4:	9201                	srli	a2,a2,0x20
ffffffffc0200df6:	00261713          	slli	a4,a2,0x2
ffffffffc0200dfa:	9732                	add	a4,a4,a2
ffffffffc0200dfc:	070e                	slli	a4,a4,0x3
ffffffffc0200dfe:	971a                	add	a4,a4,t1
ffffffffc0200e00:	02e50e63          	beq	a0,a4,ffffffffc0200e3c <best_fit_free_pages+0xe4>
    if (le != &free_list) {
ffffffffc0200e04:	00d78f63          	beq	a5,a3,ffffffffc0200e22 <best_fit_free_pages+0xca>
        if (base + base->property == p) {
ffffffffc0200e08:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0200e0a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0200e0e:	02059613          	slli	a2,a1,0x20
ffffffffc0200e12:	9201                	srli	a2,a2,0x20
ffffffffc0200e14:	00261713          	slli	a4,a2,0x2
ffffffffc0200e18:	9732                	add	a4,a4,a2
ffffffffc0200e1a:	070e                	slli	a4,a4,0x3
ffffffffc0200e1c:	972a                	add	a4,a4,a0
ffffffffc0200e1e:	04e68a63          	beq	a3,a4,ffffffffc0200e72 <best_fit_free_pages+0x11a>
}
ffffffffc0200e22:	60a2                	ld	ra,8(sp)
ffffffffc0200e24:	0141                	addi	sp,sp,16
ffffffffc0200e26:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200e28:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200e2a:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200e2c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200e2e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0200e30:	8332                	mv	t1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200e32:	02d70c63          	beq	a4,a3,ffffffffc0200e6a <best_fit_free_pages+0x112>
ffffffffc0200e36:	4805                	li	a6,1
    struct Page *p = base;
ffffffffc0200e38:	87ba                	mv	a5,a4
ffffffffc0200e3a:	b769                	j	ffffffffc0200dc4 <best_fit_free_pages+0x6c>
            p->property += base->property; // 合并：前块大小 += 当前块大小
ffffffffc0200e3c:	01c585bb          	addw	a1,a1,t3
ffffffffc0200e40:	feb82c23          	sw	a1,-8(a6)
            ClearPageProperty(base);       // 清除当前块的空闲标记（不再是块首）
ffffffffc0200e44:	ffd8f893          	andi	a7,a7,-3
ffffffffc0200e48:	01153423          	sd	a7,8(a0)
    prev->next = next;
ffffffffc0200e4c:	00f83423          	sd	a5,8(a6)
    next->prev = prev;
ffffffffc0200e50:	0107b023          	sd	a6,0(a5)
            base = p;                      // 更新base为合并后的块首页，便于后续合并后块
ffffffffc0200e54:	851a                	mv	a0,t1
ffffffffc0200e56:	b77d                	j	ffffffffc0200e04 <best_fit_free_pages+0xac>
}
ffffffffc0200e58:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0200e5a:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0200e5e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200e60:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0200e62:	e398                	sd	a4,0(a5)
ffffffffc0200e64:	e798                	sd	a4,8(a5)
}
ffffffffc0200e66:	0141                	addi	sp,sp,16
ffffffffc0200e68:	8082                	ret
    return listelm->prev;
ffffffffc0200e6a:	883e                	mv	a6,a5
ffffffffc0200e6c:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e6e:	87b6                	mv	a5,a3
ffffffffc0200e70:	bf95                	j	ffffffffc0200de4 <best_fit_free_pages+0x8c>
            base->property += p->property;
ffffffffc0200e72:	ff87a683          	lw	a3,-8(a5)
            ClearPageProperty(p);
ffffffffc0200e76:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e7a:	0007b803          	ld	a6,0(a5)
ffffffffc0200e7e:	6790                	ld	a2,8(a5)
            base->property += p->property;
ffffffffc0200e80:	9ead                	addw	a3,a3,a1
ffffffffc0200e82:	c914                	sw	a3,16(a0)
            ClearPageProperty(p);
ffffffffc0200e84:	9b75                	andi	a4,a4,-3
ffffffffc0200e86:	fee7b823          	sd	a4,-16(a5)
}
ffffffffc0200e8a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0200e8c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0200e90:	01063023          	sd	a6,0(a2)
ffffffffc0200e94:	0141                	addi	sp,sp,16
ffffffffc0200e96:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200e98:	00002697          	auipc	a3,0x2
ffffffffc0200e9c:	ae868693          	addi	a3,a3,-1304 # ffffffffc0202980 <etext+0x542>
ffffffffc0200ea0:	00001617          	auipc	a2,0x1
ffffffffc0200ea4:	7f060613          	addi	a2,a2,2032 # ffffffffc0202690 <etext+0x252>
ffffffffc0200ea8:	0a500593          	li	a1,165
ffffffffc0200eac:	00001517          	auipc	a0,0x1
ffffffffc0200eb0:	7fc50513          	addi	a0,a0,2044 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200eb4:	b14ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0200eb8:	00001697          	auipc	a3,0x1
ffffffffc0200ebc:	7d068693          	addi	a3,a3,2000 # ffffffffc0202688 <etext+0x24a>
ffffffffc0200ec0:	00001617          	auipc	a2,0x1
ffffffffc0200ec4:	7d060613          	addi	a2,a2,2000 # ffffffffc0202690 <etext+0x252>
ffffffffc0200ec8:	0a200593          	li	a1,162
ffffffffc0200ecc:	00001517          	auipc	a0,0x1
ffffffffc0200ed0:	7dc50513          	addi	a0,a0,2012 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200ed4:	af4ff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200ed8 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0200ed8:	1141                	addi	sp,sp,-16
ffffffffc0200eda:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200edc:	c9e9                	beqz	a1,ffffffffc0200fae <best_fit_init_memmap+0xd6>
    for (; p != base + n; p ++) {
ffffffffc0200ede:	00259713          	slli	a4,a1,0x2
ffffffffc0200ee2:	972e                	add	a4,a4,a1
ffffffffc0200ee4:	070e                	slli	a4,a4,0x3
ffffffffc0200ee6:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0200eea:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0200eec:	cf11                	beqz	a4,ffffffffc0200f08 <best_fit_init_memmap+0x30>
        assert(PageReserved(p));
ffffffffc0200eee:	6798                	ld	a4,8(a5)
ffffffffc0200ef0:	8b05                	andi	a4,a4,1
ffffffffc0200ef2:	cf51                	beqz	a4,ffffffffc0200f8e <best_fit_init_memmap+0xb6>
        p->flags = 0;       // 清除所有标志（如PG_reserved）
ffffffffc0200ef4:	0007b423          	sd	zero,8(a5)
        p->property = 0;    // 非块首页，property设为0
ffffffffc0200ef8:	0007a823          	sw	zero,16(a5)
ffffffffc0200efc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200f00:	02878793          	addi	a5,a5,40
ffffffffc0200f04:	fed795e3          	bne	a5,a3,ffffffffc0200eee <best_fit_init_memmap+0x16>
    SetPageProperty(base);
ffffffffc0200f08:	6510                	ld	a2,8(a0)
    nr_free += n;
ffffffffc0200f0a:	00006717          	auipc	a4,0x6
ffffffffc0200f0e:	11e72703          	lw	a4,286(a4) # ffffffffc0207028 <free_area+0x10>
ffffffffc0200f12:	00006697          	auipc	a3,0x6
ffffffffc0200f16:	10668693          	addi	a3,a3,262 # ffffffffc0207018 <free_area>
    return list->next == list;
ffffffffc0200f1a:	669c                	ld	a5,8(a3)
    SetPageProperty(base);
ffffffffc0200f1c:	00266613          	ori	a2,a2,2
    base->property = n;
ffffffffc0200f20:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200f22:	e510                	sd	a2,8(a0)
    nr_free += n;
ffffffffc0200f24:	9f2d                	addw	a4,a4,a1
ffffffffc0200f26:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200f28:	04d78663          	beq	a5,a3,ffffffffc0200f74 <best_fit_init_memmap+0x9c>
            struct Page* page = le2page(le, page_link);
ffffffffc0200f2c:	fe878713          	addi	a4,a5,-24
ffffffffc0200f30:	4581                	li	a1,0
ffffffffc0200f32:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0200f36:	00e56a63          	bltu	a0,a4,ffffffffc0200f4a <best_fit_init_memmap+0x72>
    return listelm->next;
ffffffffc0200f3a:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) {
ffffffffc0200f3c:	02d70263          	beq	a4,a3,ffffffffc0200f60 <best_fit_init_memmap+0x88>
    struct Page *p = base;
ffffffffc0200f40:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200f42:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200f46:	fee57ae3          	bgeu	a0,a4,ffffffffc0200f3a <best_fit_init_memmap+0x62>
ffffffffc0200f4a:	c199                	beqz	a1,ffffffffc0200f50 <best_fit_init_memmap+0x78>
ffffffffc0200f4c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200f50:	6398                	ld	a4,0(a5)
}
ffffffffc0200f52:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200f54:	e390                	sd	a2,0(a5)
ffffffffc0200f56:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0200f58:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0200f5a:	f11c                	sd	a5,32(a0)
ffffffffc0200f5c:	0141                	addi	sp,sp,16
ffffffffc0200f5e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200f60:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200f62:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200f64:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200f66:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0200f68:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200f6a:	00d70e63          	beq	a4,a3,ffffffffc0200f86 <best_fit_init_memmap+0xae>
ffffffffc0200f6e:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0200f70:	87ba                	mv	a5,a4
ffffffffc0200f72:	bfc1                	j	ffffffffc0200f42 <best_fit_init_memmap+0x6a>
}
ffffffffc0200f74:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0200f76:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0200f7a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200f7c:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0200f7e:	e398                	sd	a4,0(a5)
ffffffffc0200f80:	e798                	sd	a4,8(a5)
}
ffffffffc0200f82:	0141                	addi	sp,sp,16
ffffffffc0200f84:	8082                	ret
ffffffffc0200f86:	60a2                	ld	ra,8(sp)
ffffffffc0200f88:	e290                	sd	a2,0(a3)
ffffffffc0200f8a:	0141                	addi	sp,sp,16
ffffffffc0200f8c:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200f8e:	00002697          	auipc	a3,0x2
ffffffffc0200f92:	a1a68693          	addi	a3,a3,-1510 # ffffffffc02029a8 <etext+0x56a>
ffffffffc0200f96:	00001617          	auipc	a2,0x1
ffffffffc0200f9a:	6fa60613          	addi	a2,a2,1786 # ffffffffc0202690 <etext+0x252>
ffffffffc0200f9e:	04a00593          	li	a1,74
ffffffffc0200fa2:	00001517          	auipc	a0,0x1
ffffffffc0200fa6:	70650513          	addi	a0,a0,1798 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200faa:	a1eff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0200fae:	00001697          	auipc	a3,0x1
ffffffffc0200fb2:	6da68693          	addi	a3,a3,1754 # ffffffffc0202688 <etext+0x24a>
ffffffffc0200fb6:	00001617          	auipc	a2,0x1
ffffffffc0200fba:	6da60613          	addi	a2,a2,1754 # ffffffffc0202690 <etext+0x252>
ffffffffc0200fbe:	04700593          	li	a1,71
ffffffffc0200fc2:	00001517          	auipc	a0,0x1
ffffffffc0200fc6:	6e650513          	addi	a0,a0,1766 # ffffffffc02026a8 <etext+0x26a>
ffffffffc0200fca:	9feff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200fce <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc0200fce:	00006797          	auipc	a5,0x6
ffffffffc0200fd2:	17a7b783          	ld	a5,378(a5) # ffffffffc0207148 <pmm_manager>
ffffffffc0200fd6:	6f9c                	ld	a5,24(a5)
ffffffffc0200fd8:	8782                	jr	a5

ffffffffc0200fda <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc0200fda:	00006797          	auipc	a5,0x6
ffffffffc0200fde:	16e7b783          	ld	a5,366(a5) # ffffffffc0207148 <pmm_manager>
ffffffffc0200fe2:	739c                	ld	a5,32(a5)
ffffffffc0200fe4:	8782                	jr	a5

ffffffffc0200fe6 <nr_free_pages>:
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
ffffffffc0200fe6:	00006797          	auipc	a5,0x6
ffffffffc0200fea:	1627b783          	ld	a5,354(a5) # ffffffffc0207148 <pmm_manager>
ffffffffc0200fee:	779c                	ld	a5,40(a5)
ffffffffc0200ff0:	8782                	jr	a5

ffffffffc0200ff2 <pmm_init>:
    pmm_manager = &slub_pmm_manager;
ffffffffc0200ff2:	00003797          	auipc	a5,0x3
ffffffffc0200ff6:	d0678793          	addi	a5,a5,-762 # ffffffffc0203cf8 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ffa:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200ffc:	7139                	addi	sp,sp,-64
ffffffffc0200ffe:	fc06                	sd	ra,56(sp)
ffffffffc0201000:	f822                	sd	s0,48(sp)
ffffffffc0201002:	f426                	sd	s1,40(sp)
ffffffffc0201004:	ec4e                	sd	s3,24(sp)
ffffffffc0201006:	f04a                	sd	s2,32(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0201008:	00006417          	auipc	s0,0x6
ffffffffc020100c:	14040413          	addi	s0,s0,320 # ffffffffc0207148 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201010:	00002517          	auipc	a0,0x2
ffffffffc0201014:	9c050513          	addi	a0,a0,-1600 # ffffffffc02029d0 <etext+0x592>
    pmm_manager = &slub_pmm_manager;
ffffffffc0201018:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020101a:	92eff0ef          	jal	ffffffffc0200148 <cprintf>
    pmm_manager->init();
ffffffffc020101e:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201020:	00006497          	auipc	s1,0x6
ffffffffc0201024:	14048493          	addi	s1,s1,320 # ffffffffc0207160 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201028:	679c                	ld	a5,8(a5)
ffffffffc020102a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020102c:	57f5                	li	a5,-3
ffffffffc020102e:	07fa                	slli	a5,a5,0x1e
ffffffffc0201030:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0201032:	d28ff0ef          	jal	ffffffffc020055a <get_memory_base>
ffffffffc0201036:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0201038:	d2cff0ef          	jal	ffffffffc0200564 <get_memory_size>
    if (mem_size == 0) {
ffffffffc020103c:	14050c63          	beqz	a0,ffffffffc0201194 <pmm_init+0x1a2>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0201040:	00a98933          	add	s2,s3,a0
ffffffffc0201044:	e42a                	sd	a0,8(sp)
    cprintf("physcial memory map:\n");
ffffffffc0201046:	00002517          	auipc	a0,0x2
ffffffffc020104a:	9d250513          	addi	a0,a0,-1582 # ffffffffc0202a18 <etext+0x5da>
ffffffffc020104e:	8faff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201052:	65a2                	ld	a1,8(sp)
ffffffffc0201054:	864e                	mv	a2,s3
ffffffffc0201056:	fff90693          	addi	a3,s2,-1
ffffffffc020105a:	00002517          	auipc	a0,0x2
ffffffffc020105e:	9d650513          	addi	a0,a0,-1578 # ffffffffc0202a30 <etext+0x5f2>
ffffffffc0201062:	8e6ff0ef          	jal	ffffffffc0200148 <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc0201066:	c80007b7          	lui	a5,0xc8000
ffffffffc020106a:	85ca                	mv	a1,s2
ffffffffc020106c:	0d27e263          	bltu	a5,s2,ffffffffc0201130 <pmm_init+0x13e>
ffffffffc0201070:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201072:	00007697          	auipc	a3,0x7
ffffffffc0201076:	10568693          	addi	a3,a3,261 # ffffffffc0208177 <end+0xfff>
ffffffffc020107a:	8efd                	and	a3,a3,a5
    npage = maxpa / PGSIZE;
ffffffffc020107c:	81b1                	srli	a1,a1,0xc
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020107e:	fff80837          	lui	a6,0xfff80
    npage = maxpa / PGSIZE;
ffffffffc0201082:	00006797          	auipc	a5,0x6
ffffffffc0201086:	0eb7b323          	sd	a1,230(a5) # ffffffffc0207168 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020108a:	00006797          	auipc	a5,0x6
ffffffffc020108e:	0ed7b323          	sd	a3,230(a5) # ffffffffc0207170 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201092:	982e                	add	a6,a6,a1
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201094:	88b6                	mv	a7,a3
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201096:	02080963          	beqz	a6,ffffffffc02010c8 <pmm_init+0xd6>
ffffffffc020109a:	00259613          	slli	a2,a1,0x2
ffffffffc020109e:	962e                	add	a2,a2,a1
ffffffffc02010a0:	fec007b7          	lui	a5,0xfec00
ffffffffc02010a4:	97b6                	add	a5,a5,a3
ffffffffc02010a6:	060e                	slli	a2,a2,0x3
ffffffffc02010a8:	963e                	add	a2,a2,a5
ffffffffc02010aa:	87b6                	mv	a5,a3
        SetPageReserved(pages + i);
ffffffffc02010ac:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010ae:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f8eb0>
        SetPageReserved(pages + i);
ffffffffc02010b2:	00176713          	ori	a4,a4,1
ffffffffc02010b6:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010ba:	fec799e3          	bne	a5,a2,ffffffffc02010ac <pmm_init+0xba>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010be:	00281793          	slli	a5,a6,0x2
ffffffffc02010c2:	97c2                	add	a5,a5,a6
ffffffffc02010c4:	078e                	slli	a5,a5,0x3
ffffffffc02010c6:	96be                	add	a3,a3,a5
ffffffffc02010c8:	c02007b7          	lui	a5,0xc0200
ffffffffc02010cc:	0af6e863          	bltu	a3,a5,ffffffffc020117c <pmm_init+0x18a>
ffffffffc02010d0:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02010d2:	77fd                	lui	a5,0xfffff
ffffffffc02010d4:	00f97933          	and	s2,s2,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010d8:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02010da:	0526ed63          	bltu	a3,s2,ffffffffc0201134 <pmm_init+0x142>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02010de:	601c                	ld	a5,0(s0)
ffffffffc02010e0:	7b9c                	ld	a5,48(a5)
ffffffffc02010e2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02010e4:	00002517          	auipc	a0,0x2
ffffffffc02010e8:	9d450513          	addi	a0,a0,-1580 # ffffffffc0202ab8 <etext+0x67a>
ffffffffc02010ec:	85cff0ef          	jal	ffffffffc0200148 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02010f0:	00005597          	auipc	a1,0x5
ffffffffc02010f4:	f1058593          	addi	a1,a1,-240 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc02010f8:	00006797          	auipc	a5,0x6
ffffffffc02010fc:	06b7b023          	sd	a1,96(a5) # ffffffffc0207158 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201100:	c02007b7          	lui	a5,0xc0200
ffffffffc0201104:	0af5e463          	bltu	a1,a5,ffffffffc02011ac <pmm_init+0x1ba>
ffffffffc0201108:	609c                	ld	a5,0(s1)
}
ffffffffc020110a:	7442                	ld	s0,48(sp)
ffffffffc020110c:	70e2                	ld	ra,56(sp)
ffffffffc020110e:	74a2                	ld	s1,40(sp)
ffffffffc0201110:	7902                	ld	s2,32(sp)
ffffffffc0201112:	69e2                	ld	s3,24(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201114:	40f586b3          	sub	a3,a1,a5
ffffffffc0201118:	00006797          	auipc	a5,0x6
ffffffffc020111c:	02d7bc23          	sd	a3,56(a5) # ffffffffc0207150 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201120:	00002517          	auipc	a0,0x2
ffffffffc0201124:	9b850513          	addi	a0,a0,-1608 # ffffffffc0202ad8 <etext+0x69a>
ffffffffc0201128:	8636                	mv	a2,a3
}
ffffffffc020112a:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020112c:	81cff06f          	j	ffffffffc0200148 <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc0201130:	85be                	mv	a1,a5
ffffffffc0201132:	bf3d                	j	ffffffffc0201070 <pmm_init+0x7e>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201134:	6705                	lui	a4,0x1
ffffffffc0201136:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0201138:	96ba                	add	a3,a3,a4
ffffffffc020113a:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020113c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201140:	02b7f263          	bgeu	a5,a1,ffffffffc0201164 <pmm_init+0x172>
    pmm_manager->init_memmap(base, n);
ffffffffc0201144:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201146:	fff80637          	lui	a2,0xfff80
ffffffffc020114a:	97b2                	add	a5,a5,a2
ffffffffc020114c:	00279513          	slli	a0,a5,0x2
ffffffffc0201150:	953e                	add	a0,a0,a5
ffffffffc0201152:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201154:	40d90933          	sub	s2,s2,a3
ffffffffc0201158:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020115a:	00c95593          	srli	a1,s2,0xc
ffffffffc020115e:	9546                	add	a0,a0,a7
ffffffffc0201160:	9782                	jalr	a5
}
ffffffffc0201162:	bfb5                	j	ffffffffc02010de <pmm_init+0xec>
        panic("pa2page called with invalid pa");
ffffffffc0201164:	00002617          	auipc	a2,0x2
ffffffffc0201168:	92460613          	addi	a2,a2,-1756 # ffffffffc0202a88 <etext+0x64a>
ffffffffc020116c:	06a00593          	li	a1,106
ffffffffc0201170:	00002517          	auipc	a0,0x2
ffffffffc0201174:	93850513          	addi	a0,a0,-1736 # ffffffffc0202aa8 <etext+0x66a>
ffffffffc0201178:	850ff0ef          	jal	ffffffffc02001c8 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020117c:	00002617          	auipc	a2,0x2
ffffffffc0201180:	8e460613          	addi	a2,a2,-1820 # ffffffffc0202a60 <etext+0x622>
ffffffffc0201184:	06300593          	li	a1,99
ffffffffc0201188:	00002517          	auipc	a0,0x2
ffffffffc020118c:	88050513          	addi	a0,a0,-1920 # ffffffffc0202a08 <etext+0x5ca>
ffffffffc0201190:	838ff0ef          	jal	ffffffffc02001c8 <__panic>
        panic("DTB memory info not available");
ffffffffc0201194:	00002617          	auipc	a2,0x2
ffffffffc0201198:	85460613          	addi	a2,a2,-1964 # ffffffffc02029e8 <etext+0x5aa>
ffffffffc020119c:	04b00593          	li	a1,75
ffffffffc02011a0:	00002517          	auipc	a0,0x2
ffffffffc02011a4:	86850513          	addi	a0,a0,-1944 # ffffffffc0202a08 <etext+0x5ca>
ffffffffc02011a8:	820ff0ef          	jal	ffffffffc02001c8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02011ac:	86ae                	mv	a3,a1
ffffffffc02011ae:	00002617          	auipc	a2,0x2
ffffffffc02011b2:	8b260613          	addi	a2,a2,-1870 # ffffffffc0202a60 <etext+0x622>
ffffffffc02011b6:	07e00593          	li	a1,126
ffffffffc02011ba:	00002517          	auipc	a0,0x2
ffffffffc02011be:	84e50513          	addi	a0,a0,-1970 # ffffffffc0202a08 <etext+0x5ca>
ffffffffc02011c2:	806ff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc02011c6 <slub_init_memmap>:
    cprintf("SLUB: Initialized\n");
}

// 2. 内存块初始化
static void slub_init_memmap(struct Page *base, size_t n) {
    best_fit_pmm_manager.init_memmap(base, n);
ffffffffc02011c6:	00003797          	auipc	a5,0x3
ffffffffc02011ca:	b0a7b783          	ld	a5,-1270(a5) # ffffffffc0203cd0 <best_fit_pmm_manager+0x10>
ffffffffc02011ce:	8782                	jr	a5

ffffffffc02011d0 <slub_alloc_pages>:
}

// 3. 页级分配
static struct Page *slub_alloc_pages(size_t n) {
    return best_fit_pmm_manager.alloc_pages(n);
ffffffffc02011d0:	00003797          	auipc	a5,0x3
ffffffffc02011d4:	b087b783          	ld	a5,-1272(a5) # ffffffffc0203cd8 <best_fit_pmm_manager+0x18>
ffffffffc02011d8:	8782                	jr	a5

ffffffffc02011da <slub_free_pages>:
}

// 4. 页级释放
static void slub_free_pages(struct Page *base, size_t n) {
    best_fit_pmm_manager.free_pages(base, n);
ffffffffc02011da:	00003797          	auipc	a5,0x3
ffffffffc02011de:	b067b783          	ld	a5,-1274(a5) # ffffffffc0203ce0 <best_fit_pmm_manager+0x20>
ffffffffc02011e2:	8782                	jr	a5

ffffffffc02011e4 <slub_nr_free_pages>:
}

// 5. 空闲页数统计
static size_t slub_nr_free_pages(void) {
    return best_fit_pmm_manager.nr_free_pages();
ffffffffc02011e4:	00003797          	auipc	a5,0x3
ffffffffc02011e8:	b047b783          	ld	a5,-1276(a5) # ffffffffc0203ce8 <best_fit_pmm_manager+0x28>
ffffffffc02011ec:	8782                	jr	a5

ffffffffc02011ee <slub_alloc>:

// 8. 对象级分配
static void *slub_alloc(size_t size) {
    kmem_cache_t *cache = NULL;
    for (int i = 0; i < 4; i++) {
        if (obj_sizes[i] >= size) {
ffffffffc02011ee:	47c1                	li	a5,16
ffffffffc02011f0:	02a7f063          	bgeu	a5,a0,ffffffffc0201210 <slub_alloc+0x22>
ffffffffc02011f4:	02000793          	li	a5,32
ffffffffc02011f8:	08a7fa63          	bgeu	a5,a0,ffffffffc020128c <slub_alloc+0x9e>
ffffffffc02011fc:	04000793          	li	a5,64
ffffffffc0201200:	18a7f163          	bgeu	a5,a0,ffffffffc0201382 <slub_alloc+0x194>
ffffffffc0201204:	08000793          	li	a5,128
ffffffffc0201208:	18a7fb63          	bgeu	a5,a0,ffffffffc020139e <slub_alloc+0x1b0>
            cache = &caches[i];
            break;
        }
    }
    if (!cache) return NULL;
ffffffffc020120c:	4501                	li	a0,0
        list_del_init(&slab->slab_link);
        list_add_before(&cache->slabs_full, &slab->slab_link);
    }

    return (void *)(meta + 1);
}
ffffffffc020120e:	8082                	ret
        if (obj_sizes[i] >= size) {
ffffffffc0201210:	00006697          	auipc	a3,0x6
ffffffffc0201214:	e2068693          	addi	a3,a3,-480 # ffffffffc0207030 <caches>
ffffffffc0201218:	8636                	mv	a2,a3
ffffffffc020121a:	4501                	li	a0,0
    for (int i = 0; i < 4; i++) {
ffffffffc020121c:	4801                	li	a6,0
    return list->next == list;
ffffffffc020121e:	6e18                	ld	a4,24(a2)
static void *slub_alloc(size_t size) {
ffffffffc0201220:	7139                	addi	sp,sp,-64
ffffffffc0201222:	fc06                	sd	ra,56(sp)
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc0201224:	97b6                	add	a5,a5,a3
ffffffffc0201226:	02f70963          	beq	a4,a5,ffffffffc0201258 <slub_alloc+0x6a>
    obj_metadata_t *meta = slab->free_list;
ffffffffc020122a:	7b08                	ld	a0,48(a4)
    slab->free_objs--;
ffffffffc020122c:	7714                	ld	a3,40(a4)
    slab->free_list = meta->next;
ffffffffc020122e:	00053803          	ld	a6,0(a0)
ffffffffc0201232:	16fd                	addi	a3,a3,-1
ffffffffc0201234:	03073823          	sd	a6,48(a4)
    slab->free_objs--;
ffffffffc0201238:	f714                	sd	a3,40(a4)
    if (slab->free_objs == 0) {
ffffffffc020123a:	ea99                	bnez	a3,ffffffffc0201250 <slub_alloc+0x62>
    __list_del(listelm->prev, listelm->next);
ffffffffc020123c:	6314                	ld	a3,0(a4)
ffffffffc020123e:	671c                	ld	a5,8(a4)
    prev->next = next;
ffffffffc0201240:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201242:	e394                	sd	a3,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0201244:	e318                	sd	a4,0(a4)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201246:	621c                	ld	a5,0(a2)
    prev->next = next->prev = elm;
ffffffffc0201248:	e218                	sd	a4,0(a2)
ffffffffc020124a:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc020124c:	e31c                	sd	a5,0(a4)
    elm->next = next;
ffffffffc020124e:	e710                	sd	a2,8(a4)
}
ffffffffc0201250:	70e2                	ld	ra,56(sp)
    return (void *)(meta + 1);
ffffffffc0201252:	0521                	addi	a0,a0,8
}
ffffffffc0201254:	6121                	addi	sp,sp,64
ffffffffc0201256:	8082                	ret
    return list->next == list;
ffffffffc0201258:	760c                	ld	a1,40(a2)
    } else if (!list_empty(&cache->slabs_free)) {
ffffffffc020125a:	02050793          	addi	a5,a0,32
ffffffffc020125e:	97b6                	add	a5,a5,a3
ffffffffc0201260:	04f58463          	beq	a1,a5,ffffffffc02012a8 <slub_alloc+0xba>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201264:	0005b803          	ld	a6,0(a1)
ffffffffc0201268:	659c                	ld	a5,8(a1)
    obj_metadata_t *meta = slab->free_list;
ffffffffc020126a:	7988                	ld	a0,48(a1)
    slab->free_objs--;
ffffffffc020126c:	7594                	ld	a3,40(a1)
    prev->next = next;
ffffffffc020126e:	00f83423          	sd	a5,8(a6) # fffffffffff80008 <end+0x3fd78e90>
    next->prev = prev;
ffffffffc0201272:	0107b023          	sd	a6,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0201276:	e18c                	sd	a1,0(a1)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201278:	6a1c                	ld	a5,16(a2)
    prev->next = next->prev = elm;
ffffffffc020127a:	ea0c                	sd	a1,16(a2)
    slab->free_list = meta->next;
ffffffffc020127c:	00053803          	ld	a6,0(a0)
ffffffffc0201280:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0201282:	e598                	sd	a4,8(a1)
    elm->prev = prev;
ffffffffc0201284:	e19c                	sd	a5,0(a1)
ffffffffc0201286:	16fd                	addi	a3,a3,-1
        slab = le2slab(list_next(&cache->slabs_free), slab_link);
ffffffffc0201288:	872e                	mv	a4,a1
}
ffffffffc020128a:	b76d                	j	ffffffffc0201234 <slub_alloc+0x46>
        if (obj_sizes[i] >= size) {
ffffffffc020128c:	00006617          	auipc	a2,0x6
ffffffffc0201290:	de460613          	addi	a2,a2,-540 # ffffffffc0207070 <caches+0x40>
ffffffffc0201294:	05000793          	li	a5,80
ffffffffc0201298:	04000513          	li	a0,64
    for (int i = 0; i < 4; i++) {
ffffffffc020129c:	4805                	li	a6,1
ffffffffc020129e:	00006697          	auipc	a3,0x6
ffffffffc02012a2:	d9268693          	addi	a3,a3,-622 # ffffffffc0207030 <caches>
ffffffffc02012a6:	bfa5                	j	ffffffffc020121e <slub_alloc+0x30>
    struct Page *page = page_alloc();
ffffffffc02012a8:	00003797          	auipc	a5,0x3
ffffffffc02012ac:	a307b783          	ld	a5,-1488(a5) # ffffffffc0203cd8 <best_fit_pmm_manager+0x18>
ffffffffc02012b0:	4505                	li	a0,1
ffffffffc02012b2:	f436                	sd	a3,40(sp)
ffffffffc02012b4:	f032                	sd	a2,32(sp)
ffffffffc02012b6:	ec42                	sd	a6,24(sp)
ffffffffc02012b8:	e82e                	sd	a1,16(sp)
ffffffffc02012ba:	e43a                	sd	a4,8(sp)
ffffffffc02012bc:	9782                	jalr	a5
    if (!page) return NULL;
ffffffffc02012be:	cd55                	beqz	a0,ffffffffc020137a <slub_alloc+0x18c>
    slab->obj_size = cache->obj_size;
ffffffffc02012c0:	6862                	ld	a6,24(sp)
ffffffffc02012c2:	76a2                	ld	a3,40(sp)
    slab->num_objs = remaining / (cache->obj_size + sizeof(obj_metadata_t));
ffffffffc02012c4:	6885                	lui	a7,0x1
    slab->obj_size = cache->obj_size;
ffffffffc02012c6:	081a                	slli	a6,a6,0x6
ffffffffc02012c8:	96c2                	add	a3,a3,a6
ffffffffc02012ca:	0306be83          	ld	t4,48(a3)
    slab->num_objs = remaining / (cache->obj_size + sizeof(obj_metadata_t));
ffffffffc02012ce:	fc888893          	addi	a7,a7,-56 # fc8 <kern_entry-0xffffffffc01ff038>
    uintptr_t page_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02012d2:	00006817          	auipc	a6,0x6
ffffffffc02012d6:	e9e83803          	ld	a6,-354(a6) # ffffffffc0207170 <pages>
    slab->num_objs = remaining / (cache->obj_size + sizeof(obj_metadata_t));
ffffffffc02012da:	008e8793          	addi	a5,t4,8
ffffffffc02012de:	02f8d6b3          	divu	a3,a7,a5
    uintptr_t page_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02012e2:	ccccd337          	lui	t1,0xccccd
ffffffffc02012e6:	ccd30313          	addi	t1,t1,-819 # ffffffffcccccccd <end+0xcac5b55>
ffffffffc02012ea:	02031e13          	slli	t3,t1,0x20
ffffffffc02012ee:	41050833          	sub	a6,a0,a6
ffffffffc02012f2:	9372                	add	t1,t1,t3
ffffffffc02012f4:	40385813          	srai	a6,a6,0x3
    for (size_t i = 0; i < slab->num_objs; i++) {
ffffffffc02012f8:	6722                	ld	a4,8(sp)
ffffffffc02012fa:	65c2                	ld	a1,16(sp)
ffffffffc02012fc:	7602                	ld	a2,32(sp)
    uintptr_t page_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02012fe:	02680833          	mul	a6,a6,t1
ffffffffc0201302:	c0200337          	lui	t1,0xc0200
ffffffffc0201306:	00c81e13          	slli	t3,a6,0xc
ffffffffc020130a:	9e1a                	add	t3,t3,t1
    slab->page = page;
ffffffffc020130c:	00ae3823          	sd	a0,16(t3)
    slab->obj_size = cache->obj_size;
ffffffffc0201310:	01de3c23          	sd	t4,24(t3)
    slab->free_list = NULL;
ffffffffc0201314:	020e3823          	sd	zero,48(t3)
    slab->num_objs = remaining / (cache->obj_size + sizeof(obj_metadata_t));
ffffffffc0201318:	02de3023          	sd	a3,32(t3)
    slab->free_objs = slab->num_objs;
ffffffffc020131c:	02de3423          	sd	a3,40(t3)
    for (size_t i = 0; i < slab->num_objs; i++) {
ffffffffc0201320:	08f8ed63          	bltu	a7,a5,ffffffffc02013ba <slub_alloc+0x1cc>
ffffffffc0201324:	00c81513          	slli	a0,a6,0xc
ffffffffc0201328:	c0200837          	lui	a6,0xc0200
ffffffffc020132c:	03880813          	addi	a6,a6,56 # ffffffffc0200038 <kern_entry+0x38>
ffffffffc0201330:	9542                	add	a0,a0,a6
ffffffffc0201332:	4301                	li	t1,0
ffffffffc0201334:	4881                	li	a7,0
        meta->next = slab->free_list;
ffffffffc0201336:	00653023          	sd	t1,0(a0)
    for (size_t i = 0; i < slab->num_objs; i++) {
ffffffffc020133a:	0885                	addi	a7,a7,1
ffffffffc020133c:	881a                	mv	a6,t1
        obj_metadata_t *meta = (obj_metadata_t *)(obj_start + i * (cache->obj_size + sizeof(obj_metadata_t)));
ffffffffc020133e:	832a                	mv	t1,a0
    for (size_t i = 0; i < slab->num_objs; i++) {
ffffffffc0201340:	953e                	add	a0,a0,a5
ffffffffc0201342:	fed8eae3          	bltu	a7,a3,ffffffffc0201336 <slub_alloc+0x148>
ffffffffc0201346:	16fd                	addi	a3,a3,-1
ffffffffc0201348:	02f68533          	mul	a0,a3,a5
ffffffffc020134c:	03850513          	addi	a0,a0,56
ffffffffc0201350:	9572                	add	a0,a0,t3
ffffffffc0201352:	02ae3823          	sd	a0,48(t3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201356:	721c                	ld	a5,32(a2)
    prev->next = next->prev = elm;
ffffffffc0201358:	03c63023          	sd	t3,32(a2)
    prev->next = next;
ffffffffc020135c:	e78c                	sd	a1,8(a5)
    next->prev = prev;
ffffffffc020135e:	e19c                	sd	a5,0(a1)
    elm->prev = elm->next = elm;
ffffffffc0201360:	01ce3023          	sd	t3,0(t3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201364:	6a1c                	ld	a5,16(a2)
    prev->next = next->prev = elm;
ffffffffc0201366:	01c63823          	sd	t3,16(a2)
ffffffffc020136a:	01c7b423          	sd	t3,8(a5)
    elm->next = next;
ffffffffc020136e:	00ee3423          	sd	a4,8(t3)
    elm->prev = prev;
ffffffffc0201372:	00fe3023          	sd	a5,0(t3)
        slab = slab_create(cache);
ffffffffc0201376:	8772                	mv	a4,t3
}
ffffffffc0201378:	bd75                	j	ffffffffc0201234 <slub_alloc+0x46>
}
ffffffffc020137a:	70e2                	ld	ra,56(sp)
    if (!cache) return NULL;
ffffffffc020137c:	4501                	li	a0,0
}
ffffffffc020137e:	6121                	addi	sp,sp,64
ffffffffc0201380:	8082                	ret
        if (obj_sizes[i] >= size) {
ffffffffc0201382:	00006617          	auipc	a2,0x6
ffffffffc0201386:	d2e60613          	addi	a2,a2,-722 # ffffffffc02070b0 <caches+0x80>
ffffffffc020138a:	09000793          	li	a5,144
ffffffffc020138e:	08000513          	li	a0,128
    for (int i = 0; i < 4; i++) {
ffffffffc0201392:	4809                	li	a6,2
ffffffffc0201394:	00006697          	auipc	a3,0x6
ffffffffc0201398:	c9c68693          	addi	a3,a3,-868 # ffffffffc0207030 <caches>
ffffffffc020139c:	b549                	j	ffffffffc020121e <slub_alloc+0x30>
        if (obj_sizes[i] >= size) {
ffffffffc020139e:	00006617          	auipc	a2,0x6
ffffffffc02013a2:	d5260613          	addi	a2,a2,-686 # ffffffffc02070f0 <caches+0xc0>
ffffffffc02013a6:	0d000793          	li	a5,208
ffffffffc02013aa:	0c000513          	li	a0,192
    for (int i = 0; i < 4; i++) {
ffffffffc02013ae:	480d                	li	a6,3
ffffffffc02013b0:	00006697          	auipc	a3,0x6
ffffffffc02013b4:	c8068693          	addi	a3,a3,-896 # ffffffffc0207030 <caches>
ffffffffc02013b8:	b59d                	j	ffffffffc020121e <slub_alloc+0x30>
    slab->free_list = meta->next;
ffffffffc02013ba:	00003803          	ld	a6,0(zero) # 0 <kern_entry-0xffffffffc0200000>
ffffffffc02013be:	16fd                	addi	a3,a3,-1
ffffffffc02013c0:	4501                	li	a0,0
ffffffffc02013c2:	bf51                	j	ffffffffc0201356 <slub_alloc+0x168>

ffffffffc02013c4 <slub_free>:

//// 修改 slub_free 函数，在Slab完全空闲时释放页面
static void slub_free(void *ptr) {
    if (!ptr) return;
ffffffffc02013c4:	c52d                	beqz	a0,ffffffffc020142e <slub_free+0x6a>

    obj_metadata_t *meta = (obj_metadata_t *)ptr - 1;
    uintptr_t ptr_kva = (uintptr_t)ptr;
    physaddr_t ptr_pa = KVA_TO_PA(ptr_kva);
ffffffffc02013c6:	3fe007b7          	lui	a5,0x3fe00
ffffffffc02013ca:	97aa                	add	a5,a5,a0
    struct Page *page = pa2page(ptr_pa);
ffffffffc02013cc:	83b1                	srli	a5,a5,0xc
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02013ce:	ccccd737          	lui	a4,0xccccd
ffffffffc02013d2:	ccd70713          	addi	a4,a4,-819 # ffffffffcccccccd <end+0xcac5b55>
    struct Page *page = pa2page(ptr_pa);
ffffffffc02013d6:	00279693          	slli	a3,a5,0x2
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02013da:	96be                	add	a3,a3,a5
ffffffffc02013dc:	02071793          	slli	a5,a4,0x20
ffffffffc02013e0:	97ba                	add	a5,a5,a4
ffffffffc02013e2:	02f686b3          	mul	a3,a3,a5
ffffffffc02013e6:	c0200637          	lui	a2,0xc0200
ffffffffc02013ea:	00006897          	auipc	a7,0x6
ffffffffc02013ee:	c4688893          	addi	a7,a7,-954 # ffffffffc0207030 <caches>
ffffffffc02013f2:	87c6                	mv	a5,a7
    slab_t *slab = (slab_t *)slab_kva;

    kmem_cache_t *cache = NULL;
    for (int i = 0; i < 4; i++) {
ffffffffc02013f4:	4701                	li	a4,0
ffffffffc02013f6:	4811                	li	a6,4
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02013f8:	06b2                	slli	a3,a3,0xc
ffffffffc02013fa:	96b2                	add	a3,a3,a2
        if (caches[i].obj_size == slab->obj_size) {
ffffffffc02013fc:	6e8c                	ld	a1,24(a3)
ffffffffc02013fe:	7b90                	ld	a2,48(a5)
    for (int i = 0; i < 4; i++) {
ffffffffc0201400:	04078793          	addi	a5,a5,64 # 3fe00040 <kern_entry-0xffffffff803fffc0>
        if (caches[i].obj_size == slab->obj_size) {
ffffffffc0201404:	00b60663          	beq	a2,a1,ffffffffc0201410 <slub_free+0x4c>
    for (int i = 0; i < 4; i++) {
ffffffffc0201408:	2705                	addiw	a4,a4,1
ffffffffc020140a:	ff071ae3          	bne	a4,a6,ffffffffc02013fe <slub_free+0x3a>
ffffffffc020140e:	8082                	ret
            break;
        }
    }
    if (!cache) return;

    meta->next = slab->free_list;
ffffffffc0201410:	7a8c                	ld	a1,48(a3)
    slab->free_list = meta;
    slab->free_objs++;
ffffffffc0201412:	769c                	ld	a5,40(a3)
    obj_metadata_t *meta = (obj_metadata_t *)ptr - 1;
ffffffffc0201414:	ff850613          	addi	a2,a0,-8
    meta->next = slab->free_list;
ffffffffc0201418:	feb53c23          	sd	a1,-8(a0)
    slab->free_objs++;
ffffffffc020141c:	0785                	addi	a5,a5,1
    slab->free_list = meta;
ffffffffc020141e:	fa90                	sd	a2,48(a3)
    slab->free_objs++;
ffffffffc0201420:	f69c                	sd	a5,40(a3)

    if (slab->free_objs == 1) {
ffffffffc0201422:	4585                	li	a1,1
ffffffffc0201424:	00b78663          	beq	a5,a1,ffffffffc0201430 <slub_free+0x6c>
        // 从满/空链表移到部分满链表
        list_del_init(&slab->slab_link);
        list_add_before(&cache->slabs_partial, &slab->slab_link);
    } else if (slab->free_objs == slab->num_objs) {
ffffffffc0201428:	7298                	ld	a4,32(a3)
ffffffffc020142a:	02e78463          	beq	a5,a4,ffffffffc0201452 <slub_free+0x8e>
        // Slab完全空闲，释放物理页面
        list_del_init(&slab->slab_link);
        page_free(slab->page);  // 关键：释放物理页面
    }
}
ffffffffc020142e:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc0201430:	628c                	ld	a1,0(a3)
ffffffffc0201432:	669c                	ld	a5,8(a3)
ffffffffc0201434:	071a                	slli	a4,a4,0x6
            cache = &caches[i];
ffffffffc0201436:	00e88633          	add	a2,a7,a4
    prev->next = next;
ffffffffc020143a:	e59c                	sd	a5,8(a1)
    next->prev = prev;
ffffffffc020143c:	e38c                	sd	a1,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020143e:	e294                	sd	a3,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201440:	6a1c                	ld	a5,16(a2)
        list_add_before(&cache->slabs_partial, &slab->slab_link);
ffffffffc0201442:	0741                	addi	a4,a4,16
    prev->next = next->prev = elm;
ffffffffc0201444:	ea14                	sd	a3,16(a2)
ffffffffc0201446:	e794                	sd	a3,8(a5)
ffffffffc0201448:	98ba                	add	a7,a7,a4
    elm->next = next;
ffffffffc020144a:	0116b423          	sd	a7,8(a3)
    elm->prev = prev;
ffffffffc020144e:	e29c                	sd	a5,0(a3)
}
ffffffffc0201450:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc0201452:	6298                	ld	a4,0(a3)
ffffffffc0201454:	669c                	ld	a5,8(a3)
        page_free(slab->page);  // 关键：释放物理页面
ffffffffc0201456:	6a88                	ld	a0,16(a3)
ffffffffc0201458:	00003617          	auipc	a2,0x3
ffffffffc020145c:	88863603          	ld	a2,-1912(a2) # ffffffffc0203ce0 <best_fit_pmm_manager+0x20>
    prev->next = next;
ffffffffc0201460:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201462:	e398                	sd	a4,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0201464:	e694                	sd	a3,8(a3)
ffffffffc0201466:	e294                	sd	a3,0(a3)
ffffffffc0201468:	8602                	jr	a2

ffffffffc020146a <slub_init>:
    best_fit_pmm_manager.init();
ffffffffc020146a:	00003797          	auipc	a5,0x3
ffffffffc020146e:	85e7b783          	ld	a5,-1954(a5) # ffffffffc0203cc8 <best_fit_pmm_manager+0x8>
static void slub_init(void) {
ffffffffc0201472:	1141                	addi	sp,sp,-16
ffffffffc0201474:	e406                	sd	ra,8(sp)
    best_fit_pmm_manager.init();
ffffffffc0201476:	9782                	jalr	a5
    for (int i = 0; i < 4; i++) {
ffffffffc0201478:	00003717          	auipc	a4,0x3
ffffffffc020147c:	8b870713          	addi	a4,a4,-1864 # ffffffffc0203d30 <obj_sizes>
ffffffffc0201480:	00006797          	auipc	a5,0x6
ffffffffc0201484:	bb078793          	addi	a5,a5,-1104 # ffffffffc0207030 <caches>
ffffffffc0201488:	00006817          	auipc	a6,0x6
ffffffffc020148c:	ca880813          	addi	a6,a6,-856 # ffffffffc0207130 <is_panic>
        cache->align = 8;
ffffffffc0201490:	4521                	li	a0,8
        cache->obj_size = obj_sizes[i];
ffffffffc0201492:	630c                	ld	a1,0(a4)
        list_init(&cache->slabs_partial);
ffffffffc0201494:	01078613          	addi	a2,a5,16
        list_init(&cache->slabs_free);
ffffffffc0201498:	02078693          	addi	a3,a5,32
        cache->align = 8;
ffffffffc020149c:	ff88                	sd	a0,56(a5)
ffffffffc020149e:	e79c                	sd	a5,8(a5)
ffffffffc02014a0:	e39c                	sd	a5,0(a5)
        cache->obj_size = obj_sizes[i];
ffffffffc02014a2:	fb8c                	sd	a1,48(a5)
ffffffffc02014a4:	ef90                	sd	a2,24(a5)
ffffffffc02014a6:	eb90                	sd	a2,16(a5)
ffffffffc02014a8:	f794                	sd	a3,40(a5)
ffffffffc02014aa:	f394                	sd	a3,32(a5)
    for (int i = 0; i < 4; i++) {
ffffffffc02014ac:	04078793          	addi	a5,a5,64
ffffffffc02014b0:	0721                	addi	a4,a4,8
ffffffffc02014b2:	ff0790e3          	bne	a5,a6,ffffffffc0201492 <slub_init+0x28>
}
ffffffffc02014b6:	60a2                	ld	ra,8(sp)
    cprintf("SLUB: Initialized\n");
ffffffffc02014b8:	00001517          	auipc	a0,0x1
ffffffffc02014bc:	66050513          	addi	a0,a0,1632 # ffffffffc0202b18 <etext+0x6da>
}
ffffffffc02014c0:	0141                	addi	sp,sp,16
    cprintf("SLUB: Initialized\n");
ffffffffc02014c2:	c87fe06f          	j	ffffffffc0200148 <cprintf>

ffffffffc02014c6 <slub_check>:
static void slub_check(void) {
ffffffffc02014c6:	c5010113          	addi	sp,sp,-944
ffffffffc02014ca:	3a113423          	sd	ra,936(sp)
ffffffffc02014ce:	3a813023          	sd	s0,928(sp)
ffffffffc02014d2:	37513c23          	sd	s5,888(sp)
ffffffffc02014d6:	1f00                	addi	s0,sp,944
ffffffffc02014d8:	37613823          	sd	s6,880(sp)
ffffffffc02014dc:	38913c23          	sd	s1,920(sp)
ffffffffc02014e0:	39213823          	sd	s2,912(sp)
ffffffffc02014e4:	39313423          	sd	s3,904(sp)
ffffffffc02014e8:	39413023          	sd	s4,896(sp)
ffffffffc02014ec:	37713423          	sd	s7,872(sp)
ffffffffc02014f0:	37813023          	sd	s8,864(sp)
ffffffffc02014f4:	35913c23          	sd	s9,856(sp)
ffffffffc02014f8:	35a13823          	sd	s10,848(sp)
ffffffffc02014fc:	35b13423          	sd	s11,840(sp)
    cprintf("========================================\n");
ffffffffc0201500:	00001517          	auipc	a0,0x1
ffffffffc0201504:	63050513          	addi	a0,a0,1584 # ffffffffc0202b30 <etext+0x6f2>
ffffffffc0201508:	c41fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("SLUB COMPREHENSIVE TEST SUITE START\n");
ffffffffc020150c:	00001517          	auipc	a0,0x1
ffffffffc0201510:	65450513          	addi	a0,a0,1620 # ffffffffc0202b60 <etext+0x722>
ffffffffc0201514:	c35fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("========================================\n");
ffffffffc0201518:	00001517          	auipc	a0,0x1
ffffffffc020151c:	61850513          	addi	a0,a0,1560 # ffffffffc0202b30 <etext+0x6f2>
ffffffffc0201520:	c29fe0ef          	jal	ffffffffc0200148 <cprintf>
    return best_fit_pmm_manager.nr_free_pages();
ffffffffc0201524:	00002b17          	auipc	s6,0x2
ffffffffc0201528:	7c4b3b03          	ld	s6,1988(s6) # ffffffffc0203ce8 <best_fit_pmm_manager+0x28>
ffffffffc020152c:	9b02                	jalr	s6
    cprintf("[INIT] Initial free pages: %d\n", initial_free_pages);
ffffffffc020152e:	85aa                	mv	a1,a0
    return best_fit_pmm_manager.nr_free_pages();
ffffffffc0201530:	8aaa                	mv	s5,a0
    cprintf("[INIT] Initial free pages: %d\n", initial_free_pages);
ffffffffc0201532:	00001517          	auipc	a0,0x1
ffffffffc0201536:	65650513          	addi	a0,a0,1622 # ffffffffc0202b88 <etext+0x74a>
ffffffffc020153a:	c0ffe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("\n[TEST 1] Basic Functionality Verification\n");
ffffffffc020153e:	00001517          	auipc	a0,0x1
ffffffffc0201542:	66a50513          	addi	a0,a0,1642 # ffffffffc0202ba8 <etext+0x76a>
ffffffffc0201546:	c03fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("----------------------------------------\n");
ffffffffc020154a:	00001517          	auipc	a0,0x1
ffffffffc020154e:	68e50513          	addi	a0,a0,1678 # ffffffffc0202bd8 <etext+0x79a>
ffffffffc0201552:	bf7fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 1.1] Single object allocation and free\n");
ffffffffc0201556:	00001517          	auipc	a0,0x1
ffffffffc020155a:	6b250513          	addi	a0,a0,1714 # ffffffffc0202c08 <etext+0x7ca>
ffffffffc020155e:	bebfe0ef          	jal	ffffffffc0200148 <cprintf>
        void *obj1 = slub_alloc(16);
ffffffffc0201562:	4541                	li	a0,16
ffffffffc0201564:	c8bff0ef          	jal	ffffffffc02011ee <slub_alloc>
        if (obj1 == NULL) {
ffffffffc0201568:	120505e3          	beqz	a0,ffffffffc0201e92 <slub_check+0x9cc>
ffffffffc020156c:	84aa                	mv	s1,a0
        cprintf("[PASS] Object allocated at %p\n", obj1);
ffffffffc020156e:	85aa                	mv	a1,a0
ffffffffc0201570:	00001517          	auipc	a0,0x1
ffffffffc0201574:	70050513          	addi	a0,a0,1792 # ffffffffc0202c70 <etext+0x832>
ffffffffc0201578:	bd1fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 1.2] Data integrity verification\n");
ffffffffc020157c:	00001517          	auipc	a0,0x1
ffffffffc0201580:	71450513          	addi	a0,a0,1812 # ffffffffc0202c90 <etext+0x852>
ffffffffc0201584:	bc5fe0ef          	jal	ffffffffc0200148 <cprintf>
        memset(obj1, 0xAA, 16);
ffffffffc0201588:	4641                	li	a2,16
ffffffffc020158a:	8526                	mv	a0,s1
ffffffffc020158c:	0aa00593          	li	a1,170
ffffffffc0201590:	69d000ef          	jal	ffffffffc020242c <memset>
        for (int i = 0; i < 16; i++) {
ffffffffc0201594:	87a6                	mv	a5,s1
ffffffffc0201596:	01048613          	addi	a2,s1,16
            if (((char*)obj1)[i] != 0xAA) {
ffffffffc020159a:	0aa00693          	li	a3,170
ffffffffc020159e:	0007c703          	lbu	a4,0(a5)
ffffffffc02015a2:	1ed71ee3          	bne	a4,a3,ffffffffc0201f9e <slub_check+0xad8>
        for (int i = 0; i < 16; i++) {
ffffffffc02015a6:	0785                	addi	a5,a5,1
ffffffffc02015a8:	fec79be3          	bne	a5,a2,ffffffffc020159e <slub_check+0xd8>
        cprintf("[PASS] Data integrity verified\n");
ffffffffc02015ac:	00001517          	auipc	a0,0x1
ffffffffc02015b0:	73450513          	addi	a0,a0,1844 # ffffffffc0202ce0 <etext+0x8a2>
ffffffffc02015b4:	b95fe0ef          	jal	ffffffffc0200148 <cprintf>
        slub_free(obj1);
ffffffffc02015b8:	8526                	mv	a0,s1
ffffffffc02015ba:	e0bff0ef          	jal	ffffffffc02013c4 <slub_free>
    return best_fit_pmm_manager.nr_free_pages();
ffffffffc02015be:	9b02                	jalr	s6
        if (initial_free_pages != after_free) {
ffffffffc02015c0:	7f550463          	beq	a0,s5,ffffffffc0201da8 <slub_check+0x8e2>
            cprintf("[WARNING] Single object leak: %d -> %d pages\n", 
ffffffffc02015c4:	862a                	mv	a2,a0
ffffffffc02015c6:	85d6                	mv	a1,s5
ffffffffc02015c8:	00001517          	auipc	a0,0x1
ffffffffc02015cc:	73850513          	addi	a0,a0,1848 # ffffffffc0202d00 <etext+0x8c2>
ffffffffc02015d0:	b79fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 1.3] Multiple object allocation pattern\n");
ffffffffc02015d4:	00001517          	auipc	a0,0x1
ffffffffc02015d8:	78450513          	addi	a0,a0,1924 # ffffffffc0202d58 <etext+0x91a>
ffffffffc02015dc:	e0040913          	addi	s2,s0,-512
            objects[i] = slub_alloc(16 + (i % 3) * 16);
ffffffffc02015e0:	55555a37          	lui	s4,0x55555
        cprintf("[TEST 1.3] Multiple object allocation pattern\n");
ffffffffc02015e4:	b65fe0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc02015e8:	89ca                	mv	s3,s2
            objects[i] = slub_alloc(16 + (i % 3) * 16);
ffffffffc02015ea:	556a0a13          	addi	s4,s4,1366 # 55555556 <kern_entry-0xffffffff6acaaaaa>
        for (int i = 0; i < 10; i++) {
ffffffffc02015ee:	4c01                	li	s8,0
ffffffffc02015f0:	4ba9                	li	s7,10
            objects[i] = slub_alloc(16 + (i % 3) * 16);
ffffffffc02015f2:	034c07b3          	mul	a5,s8,s4
ffffffffc02015f6:	41fc571b          	sraiw	a4,s8,0x1f
ffffffffc02015fa:	9381                	srli	a5,a5,0x20
ffffffffc02015fc:	9f99                	subw	a5,a5,a4
ffffffffc02015fe:	0017949b          	slliw	s1,a5,0x1
ffffffffc0201602:	9cbd                	addw	s1,s1,a5
ffffffffc0201604:	409c04bb          	subw	s1,s8,s1
ffffffffc0201608:	0492                	slli	s1,s1,0x4
ffffffffc020160a:	24c1                	addiw	s1,s1,16
ffffffffc020160c:	8526                	mv	a0,s1
ffffffffc020160e:	be1ff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201612:	00a9b023          	sd	a0,0(s3)
            if (objects[i] == NULL) {
ffffffffc0201616:	020509e3          	beqz	a0,ffffffffc0201e48 <slub_check+0x982>
            memset(objects[i], i & 0xFF, 16 + (i % 3) * 16);
ffffffffc020161a:	0ffc7593          	zext.b	a1,s8
ffffffffc020161e:	8626                	mv	a2,s1
        for (int i = 0; i < 10; i++) {
ffffffffc0201620:	2c05                	addiw	s8,s8,1
            memset(objects[i], i & 0xFF, 16 + (i % 3) * 16);
ffffffffc0201622:	60b000ef          	jal	ffffffffc020242c <memset>
        for (int i = 0; i < 10; i++) {
ffffffffc0201626:	09a1                	addi	s3,s3,8
ffffffffc0201628:	fd7c15e3          	bne	s8,s7,ffffffffc02015f2 <slub_check+0x12c>
        cprintf("[PASS] Multiple object allocation successful\n");
ffffffffc020162c:	00001517          	auipc	a0,0x1
ffffffffc0201630:	78c50513          	addi	a0,a0,1932 # ffffffffc0202db8 <etext+0x97a>
ffffffffc0201634:	b15fe0ef          	jal	ffffffffc0200148 <cprintf>
        for (int i = 0; i < 10; i++) {
ffffffffc0201638:	e5040493          	addi	s1,s0,-432
            slub_free(objects[i]);
ffffffffc020163c:	00093503          	ld	a0,0(s2)
        for (int i = 0; i < 10; i++) {
ffffffffc0201640:	0921                	addi	s2,s2,8
            slub_free(objects[i]);
ffffffffc0201642:	d83ff0ef          	jal	ffffffffc02013c4 <slub_free>
        for (int i = 0; i < 10; i++) {
ffffffffc0201646:	fe991be3          	bne	s2,s1,ffffffffc020163c <slub_check+0x176>
        cprintf("[PASS] Multiple object cleanup successful\n");
ffffffffc020164a:	00001517          	auipc	a0,0x1
ffffffffc020164e:	79e50513          	addi	a0,a0,1950 # ffffffffc0202de8 <etext+0x9aa>
ffffffffc0201652:	af7fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("\n[TEST 2] Size Alignment Verification\n");
ffffffffc0201656:	00001517          	auipc	a0,0x1
ffffffffc020165a:	7c250513          	addi	a0,a0,1986 # ffffffffc0202e18 <etext+0x9da>
ffffffffc020165e:	aebfe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("----------------------------------------\n");
ffffffffc0201662:	00001517          	auipc	a0,0x1
ffffffffc0201666:	57650513          	addi	a0,a0,1398 # ffffffffc0202bd8 <etext+0x79a>
ffffffffc020166a:	adffe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 2.1] Cache size selection\n");
ffffffffc020166e:	00001517          	auipc	a0,0x1
ffffffffc0201672:	7d250513          	addi	a0,a0,2002 # ffffffffc0202e40 <etext+0xa02>
ffffffffc0201676:	ad3fe0ef          	jal	ffffffffc0200148 <cprintf>
        void *obj10 = slub_alloc(10);   // 应使用16B缓存
ffffffffc020167a:	4529                	li	a0,10
ffffffffc020167c:	b73ff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201680:	8daa                	mv	s11,a0
        void *obj15 = slub_alloc(15);   // 应使用16B缓存  
ffffffffc0201682:	453d                	li	a0,15
ffffffffc0201684:	b6bff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201688:	84aa                	mv	s1,a0
ffffffffc020168a:	c6a43423          	sd	a0,-920(s0)
        void *obj20 = slub_alloc(20);   // 应使用32B缓存
ffffffffc020168e:	4551                	li	a0,20
ffffffffc0201690:	b5fff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201694:	8baa                	mv	s7,a0
ffffffffc0201696:	c6a43023          	sd	a0,-928(s0)
        void *obj40 = slub_alloc(40);   // 应使用64B缓存
ffffffffc020169a:	02800513          	li	a0,40
ffffffffc020169e:	b51ff0ef          	jal	ffffffffc02011ee <slub_alloc>
    physaddr_t pa = KVA_TO_PA((uintptr_t)obj);
ffffffffc02016a2:	3fe00937          	lui	s2,0x3fe00
ffffffffc02016a6:	012d86b3          	add	a3,s11,s2
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02016aa:	ccccd7b7          	lui	a5,0xccccd
    struct Page *page = pa2page(pa);
ffffffffc02016ae:	82b1                	srli	a3,a3,0xc
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02016b0:	ccd78793          	addi	a5,a5,-819 # ffffffffcccccccd <end+0xcac5b55>
    struct Page *page = pa2page(pa);
ffffffffc02016b4:	00269713          	slli	a4,a3,0x2
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02016b8:	02079a13          	slli	s4,a5,0x20
ffffffffc02016bc:	9a3e                	add	s4,s4,a5
ffffffffc02016be:	9736                	add	a4,a4,a3
ffffffffc02016c0:	03470733          	mul	a4,a4,s4
ffffffffc02016c4:	fffc09b7          	lui	s3,0xfffc0
ffffffffc02016c8:	20098993          	addi	s3,s3,512 # fffffffffffc0200 <end+0x3fdb9088>
        void *obj40 = slub_alloc(40);   // 应使用64B缓存
ffffffffc02016cc:	8caa                	mv	s9,a0
ffffffffc02016ce:	c4a43c23          	sd	a0,-936(s0)
        cprintf("obj10(10B) -> cache: %dB\n", slab_of(obj10)->obj_size);
ffffffffc02016d2:	00001517          	auipc	a0,0x1
ffffffffc02016d6:	79650513          	addi	a0,a0,1942 # ffffffffc0202e68 <etext+0xa2a>
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02016da:	974e                	add	a4,a4,s3
ffffffffc02016dc:	00c71d13          	slli	s10,a4,0xc
        cprintf("obj10(10B) -> cache: %dB\n", slab_of(obj10)->obj_size);
ffffffffc02016e0:	018d3583          	ld	a1,24(s10)
ffffffffc02016e4:	a65fe0ef          	jal	ffffffffc0200148 <cprintf>
    physaddr_t pa = KVA_TO_PA((uintptr_t)obj);
ffffffffc02016e8:	012487b3          	add	a5,s1,s2
    struct Page *page = pa2page(pa);
ffffffffc02016ec:	83b1                	srli	a5,a5,0xc
ffffffffc02016ee:	00279493          	slli	s1,a5,0x2
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc02016f2:	94be                	add	s1,s1,a5
ffffffffc02016f4:	034484b3          	mul	s1,s1,s4
        cprintf("obj15(15B) -> cache: %dB\n", slab_of(obj15)->obj_size);
ffffffffc02016f8:	00001517          	auipc	a0,0x1
ffffffffc02016fc:	79050513          	addi	a0,a0,1936 # ffffffffc0202e88 <etext+0xa4a>
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201700:	94ce                	add	s1,s1,s3
ffffffffc0201702:	04b2                	slli	s1,s1,0xc
        cprintf("obj15(15B) -> cache: %dB\n", slab_of(obj15)->obj_size);
ffffffffc0201704:	6c8c                	ld	a1,24(s1)
ffffffffc0201706:	a43fe0ef          	jal	ffffffffc0200148 <cprintf>
    physaddr_t pa = KVA_TO_PA((uintptr_t)obj);
ffffffffc020170a:	012b86b3          	add	a3,s7,s2
    struct Page *page = pa2page(pa);
ffffffffc020170e:	82b1                	srli	a3,a3,0xc
ffffffffc0201710:	00269793          	slli	a5,a3,0x2
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201714:	97b6                	add	a5,a5,a3
ffffffffc0201716:	034787b3          	mul	a5,a5,s4
        cprintf("obj20(20B) -> cache: %dB\n", slab_of(obj20)->obj_size);
ffffffffc020171a:	00001517          	auipc	a0,0x1
ffffffffc020171e:	78e50513          	addi	a0,a0,1934 # ffffffffc0202ea8 <etext+0xa6a>
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201722:	97ce                	add	a5,a5,s3
ffffffffc0201724:	00c79c13          	slli	s8,a5,0xc
        cprintf("obj20(20B) -> cache: %dB\n", slab_of(obj20)->obj_size);
ffffffffc0201728:	018c3583          	ld	a1,24(s8)
ffffffffc020172c:	a1dfe0ef          	jal	ffffffffc0200148 <cprintf>
    physaddr_t pa = KVA_TO_PA((uintptr_t)obj);
ffffffffc0201730:	012c8633          	add	a2,s9,s2
    struct Page *page = pa2page(pa);
ffffffffc0201734:	8231                	srli	a2,a2,0xc
ffffffffc0201736:	00261693          	slli	a3,a2,0x2
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc020173a:	96b2                	add	a3,a3,a2
ffffffffc020173c:	034686b3          	mul	a3,a3,s4
        cprintf("obj40(40B) -> cache: %dB\n", slab_of(obj40)->obj_size);
ffffffffc0201740:	00001517          	auipc	a0,0x1
ffffffffc0201744:	78850513          	addi	a0,a0,1928 # ffffffffc0202ec8 <etext+0xa8a>
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201748:	96ce                	add	a3,a3,s3
ffffffffc020174a:	00c69c93          	slli	s9,a3,0xc
        cprintf("obj40(40B) -> cache: %dB\n", slab_of(obj40)->obj_size);
ffffffffc020174e:	018cb583          	ld	a1,24(s9)
ffffffffc0201752:	9f7fe0ef          	jal	ffffffffc0200148 <cprintf>
        if (slab_of(obj10)->obj_size != 16 || slab_of(obj20)->obj_size != 32) {
ffffffffc0201756:	018d3b83          	ld	s7,24(s10)
ffffffffc020175a:	46c1                	li	a3,16
ffffffffc020175c:	70db9f63          	bne	s7,a3,ffffffffc0201e7a <slub_check+0x9b4>
ffffffffc0201760:	018c3603          	ld	a2,24(s8)
ffffffffc0201764:	02000693          	li	a3,32
ffffffffc0201768:	70d61963          	bne	a2,a3,ffffffffc0201e7a <slub_check+0x9b4>
        cprintf("[PASS] Cache size selection correct\n");
ffffffffc020176c:	00001517          	auipc	a0,0x1
ffffffffc0201770:	7a450513          	addi	a0,a0,1956 # ffffffffc0202f10 <etext+0xad2>
ffffffffc0201774:	9d5fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 2.2] Same-cache object co-location\n");
ffffffffc0201778:	00001517          	auipc	a0,0x1
ffffffffc020177c:	7c050513          	addi	a0,a0,1984 # ffffffffc0202f38 <etext+0xafa>
ffffffffc0201780:	9c9fe0ef          	jal	ffffffffc0200148 <cprintf>
        if (slab_of(obj10) != slab_of(obj15)) {
ffffffffc0201784:	01a491e3          	bne	s1,s10,ffffffffc0201f86 <slub_check+0xac0>
        cprintf("[PASS] Same cache objects properly co-located\n");
ffffffffc0201788:	00002517          	auipc	a0,0x2
ffffffffc020178c:	81050513          	addi	a0,a0,-2032 # ffffffffc0202f98 <etext+0xb5a>
ffffffffc0201790:	9b9fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 2.3] Different-cache object isolation\n");
ffffffffc0201794:	00002517          	auipc	a0,0x2
ffffffffc0201798:	83450513          	addi	a0,a0,-1996 # ffffffffc0202fc8 <etext+0xb8a>
ffffffffc020179c:	9adfe0ef          	jal	ffffffffc0200148 <cprintf>
        if (slab_of(obj10) == slab_of(obj20) || slab_of(obj20) == slab_of(obj40)) {
ffffffffc02017a0:	7c9c0763          	beq	s8,s1,ffffffffc0201f6e <slub_check+0xaa8>
ffffffffc02017a4:	7d8c8563          	beq	s9,s8,ffffffffc0201f6e <slub_check+0xaa8>
        cprintf("[PASS] Different cache objects properly isolated\n");
ffffffffc02017a8:	00002517          	auipc	a0,0x2
ffffffffc02017ac:	88050513          	addi	a0,a0,-1920 # ffffffffc0203028 <etext+0xbea>
ffffffffc02017b0:	999fe0ef          	jal	ffffffffc0200148 <cprintf>
        slub_free(obj10); slub_free(obj15);
ffffffffc02017b4:	856e                	mv	a0,s11
ffffffffc02017b6:	c0fff0ef          	jal	ffffffffc02013c4 <slub_free>
ffffffffc02017ba:	c6843503          	ld	a0,-920(s0)
    {
ffffffffc02017be:	8c0a                	mv	s8,sp
        for (size_t i = 1; i < obj_per_slab; i++) {
ffffffffc02017c0:	4485                	li	s1,1
        slub_free(obj10); slub_free(obj15);
ffffffffc02017c2:	c03ff0ef          	jal	ffffffffc02013c4 <slub_free>
        slub_free(obj20); slub_free(obj40);
ffffffffc02017c6:	c6043503          	ld	a0,-928(s0)
ffffffffc02017ca:	bfbff0ef          	jal	ffffffffc02013c4 <slub_free>
ffffffffc02017ce:	c5843503          	ld	a0,-936(s0)
ffffffffc02017d2:	bf3ff0ef          	jal	ffffffffc02013c4 <slub_free>
        cprintf("[PASS] Size alignment test cleanup successful\n");
ffffffffc02017d6:	00002517          	auipc	a0,0x2
ffffffffc02017da:	88a50513          	addi	a0,a0,-1910 # ffffffffc0203060 <etext+0xc22>
ffffffffc02017de:	96bfe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("\n[TEST 3] Slab State Transition Verification\n");
ffffffffc02017e2:	00002517          	auipc	a0,0x2
ffffffffc02017e6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0203090 <etext+0xc52>
ffffffffc02017ea:	95ffe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("----------------------------------------\n");
ffffffffc02017ee:	00001517          	auipc	a0,0x1
ffffffffc02017f2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0202bd8 <etext+0x79a>
ffffffffc02017f6:	953fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 3.1] Slab state monitoring\n");
ffffffffc02017fa:	00002517          	auipc	a0,0x2
ffffffffc02017fe:	8c650513          	addi	a0,a0,-1850 # ffffffffc02030c0 <etext+0xc82>
ffffffffc0201802:	947fe0ef          	jal	ffffffffc0200148 <cprintf>
        void *first_obj = slub_alloc(16);
ffffffffc0201806:	855e                	mv	a0,s7
ffffffffc0201808:	9e7ff0ef          	jal	ffffffffc02011ee <slub_alloc>
    physaddr_t pa = KVA_TO_PA((uintptr_t)obj);
ffffffffc020180c:	012507b3          	add	a5,a0,s2
    struct Page *page = pa2page(pa);
ffffffffc0201810:	83b1                	srli	a5,a5,0xc
ffffffffc0201812:	00279d13          	slli	s10,a5,0x2
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201816:	9d3e                	add	s10,s10,a5
ffffffffc0201818:	034d0d33          	mul	s10,s10,s4
        void *first_obj = slub_alloc(16);
ffffffffc020181c:	8baa                	mv	s7,a0
        cprintf("Slab capacity: %d objects\n", obj_per_slab);
ffffffffc020181e:	00002517          	auipc	a0,0x2
ffffffffc0201822:	8ca50513          	addi	a0,a0,-1846 # ffffffffc02030e8 <etext+0xcaa>
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201826:	9d4e                	add	s10,s10,s3
ffffffffc0201828:	0d32                	slli	s10,s10,0xc
        size_t obj_per_slab = slab->num_objs;
ffffffffc020182a:	020d3983          	ld	s3,32(s10)
        cprintf("Slab capacity: %d objects\n", obj_per_slab);
ffffffffc020182e:	85ce                	mv	a1,s3
ffffffffc0201830:	919fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("Initial free objects: %d\n", slab->free_objs);
ffffffffc0201834:	028d3583          	ld	a1,40(s10)
ffffffffc0201838:	00002517          	auipc	a0,0x2
ffffffffc020183c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0203108 <etext+0xcca>
ffffffffc0201840:	909fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 3.2] Slab full state transition\n");
ffffffffc0201844:	00002517          	auipc	a0,0x2
ffffffffc0201848:	8e450513          	addi	a0,a0,-1820 # ffffffffc0203128 <etext+0xcea>
ffffffffc020184c:	8fdfe0ef          	jal	ffffffffc0200148 <cprintf>
        void **objects = slub_alloc(sizeof(void*) * obj_per_slab);
ffffffffc0201850:	00399513          	slli	a0,s3,0x3
ffffffffc0201854:	99bff0ef          	jal	ffffffffc02011ee <slub_alloc>
        void *filled_objs[obj_per_slab - 1];
ffffffffc0201858:	00399713          	slli	a4,s3,0x3
ffffffffc020185c:	00475793          	srli	a5,a4,0x4
ffffffffc0201860:	0792                	slli	a5,a5,0x4
ffffffffc0201862:	40f10133          	sub	sp,sp,a5
        void **objects = slub_alloc(sizeof(void*) * obj_per_slab);
ffffffffc0201866:	8caa                	mv	s9,a0
        void *filled_objs[obj_per_slab - 1];
ffffffffc0201868:	8a0a                	mv	s4,sp
        for (size_t i = 1; i < obj_per_slab; i++) {
ffffffffc020186a:	890a                	mv	s2,sp
ffffffffc020186c:	0134fd63          	bgeu	s1,s3,ffffffffc0201886 <slub_check+0x3c0>
            filled_objs[i-1] = slub_alloc(16);
ffffffffc0201870:	4541                	li	a0,16
ffffffffc0201872:	97dff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201876:	00a93023          	sd	a0,0(s2) # 3fe00000 <kern_entry-0xffffffff80400000>
            if (filled_objs[i-1] == NULL) {
ffffffffc020187a:	6c050d63          	beqz	a0,ffffffffc0201f54 <slub_check+0xa8e>
        for (size_t i = 1; i < obj_per_slab; i++) {
ffffffffc020187e:	0485                	addi	s1,s1,1
ffffffffc0201880:	0921                	addi	s2,s2,8
ffffffffc0201882:	fe9997e3          	bne	s3,s1,ffffffffc0201870 <slub_check+0x3aa>
    return list->next == list;
ffffffffc0201886:	00005497          	auipc	s1,0x5
ffffffffc020188a:	7aa48493          	addi	s1,s1,1962 # ffffffffc0207030 <caches>
ffffffffc020188e:	649c                	ld	a5,8(s1)
        if (!list_empty(&cache16->slabs_full)) {
ffffffffc0201890:	6a978663          	beq	a5,s1,ffffffffc0201f3c <slub_check+0xa76>
            if (full_slab == slab && full_slab->free_objs == 0) {
ffffffffc0201894:	69a79863          	bne	a5,s10,ffffffffc0201f24 <slub_check+0xa5e>
ffffffffc0201898:	028d3783          	ld	a5,40(s10)
ffffffffc020189c:	68079463          	bnez	a5,ffffffffc0201f24 <slub_check+0xa5e>
                cprintf("[PASS] Slab correctly transitioned to FULL state\n");
ffffffffc02018a0:	00002517          	auipc	a0,0x2
ffffffffc02018a4:	8e050513          	addi	a0,a0,-1824 # ffffffffc0203180 <etext+0xd42>
ffffffffc02018a8:	8a1fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 3.3] Slab partial state transition\n");
ffffffffc02018ac:	00002517          	auipc	a0,0x2
ffffffffc02018b0:	90c50513          	addi	a0,a0,-1780 # ffffffffc02031b8 <etext+0xd7a>
ffffffffc02018b4:	895fe0ef          	jal	ffffffffc0200148 <cprintf>
        slub_free(first_obj);
ffffffffc02018b8:	855e                	mv	a0,s7
ffffffffc02018ba:	b0bff0ef          	jal	ffffffffc02013c4 <slub_free>
ffffffffc02018be:	6c9c                	ld	a5,24(s1)
        if (!list_empty(&cache16->slabs_partial)) {
ffffffffc02018c0:	00005717          	auipc	a4,0x5
ffffffffc02018c4:	78070713          	addi	a4,a4,1920 # ffffffffc0207040 <caches+0x10>
ffffffffc02018c8:	64e78263          	beq	a5,a4,ffffffffc0201f0c <slub_check+0xa46>
            if (partial_slab == slab && partial_slab->free_objs == 1) {
ffffffffc02018cc:	63a79463          	bne	a5,s10,ffffffffc0201ef4 <slub_check+0xa2e>
ffffffffc02018d0:	028d3903          	ld	s2,40(s10)
ffffffffc02018d4:	4785                	li	a5,1
ffffffffc02018d6:	60f91f63          	bne	s2,a5,ffffffffc0201ef4 <slub_check+0xa2e>
                cprintf("[PASS] Slab correctly transitioned to PARTIAL state\n");
ffffffffc02018da:	00002517          	auipc	a0,0x2
ffffffffc02018de:	95e50513          	addi	a0,a0,-1698 # ffffffffc0203238 <etext+0xdfa>
ffffffffc02018e2:	867fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 3.4] Object reuse verification\n");
ffffffffc02018e6:	00002517          	auipc	a0,0x2
ffffffffc02018ea:	98a50513          	addi	a0,a0,-1654 # ffffffffc0203270 <etext+0xe32>
ffffffffc02018ee:	85bfe0ef          	jal	ffffffffc0200148 <cprintf>
        void *reused_obj = slub_alloc(8);
ffffffffc02018f2:	4521                	li	a0,8
ffffffffc02018f4:	8fbff0ef          	jal	ffffffffc02011ee <slub_alloc>
        if (reused_obj == first_obj) {
ffffffffc02018f8:	52ab9a63          	bne	s7,a0,ffffffffc0201e2c <slub_check+0x966>
            cprintf("[PASS] Object correctly reused\n");
ffffffffc02018fc:	00002517          	auipc	a0,0x2
ffffffffc0201900:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02032e8 <etext+0xeaa>
ffffffffc0201904:	845fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 3.5] Slab free and page release\n");
ffffffffc0201908:	00002517          	auipc	a0,0x2
ffffffffc020190c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0203308 <etext+0xeca>
ffffffffc0201910:	839fe0ef          	jal	ffffffffc0200148 <cprintf>
        slub_free(reused_obj);
ffffffffc0201914:	855e                	mv	a0,s7
ffffffffc0201916:	aafff0ef          	jal	ffffffffc02013c4 <slub_free>
        for (size_t i = 1; i < obj_per_slab; i++) {
ffffffffc020191a:	01397a63          	bgeu	s2,s3,ffffffffc020192e <slub_check+0x468>
            slub_free(filled_objs[i-1]);
ffffffffc020191e:	000a3503          	ld	a0,0(s4)
        for (size_t i = 1; i < obj_per_slab; i++) {
ffffffffc0201922:	0905                	addi	s2,s2,1
ffffffffc0201924:	0a21                	addi	s4,s4,8
            slub_free(filled_objs[i-1]);
ffffffffc0201926:	a9fff0ef          	jal	ffffffffc02013c4 <slub_free>
        for (size_t i = 1; i < obj_per_slab; i++) {
ffffffffc020192a:	ff299ae3          	bne	s3,s2,ffffffffc020191e <slub_check+0x458>
        cprintf("[PASS] Slab state transitions completed successfully\n");
ffffffffc020192e:	00002517          	auipc	a0,0x2
ffffffffc0201932:	a0250513          	addi	a0,a0,-1534 # ffffffffc0203330 <etext+0xef2>
ffffffffc0201936:	813fe0ef          	jal	ffffffffc0200148 <cprintf>
        slub_free(objects);
ffffffffc020193a:	8566                	mv	a0,s9
ffffffffc020193c:	a89ff0ef          	jal	ffffffffc02013c4 <slub_free>
    cprintf("\n[TEST 4] Memory Leak Detection\n");
ffffffffc0201940:	00002517          	auipc	a0,0x2
ffffffffc0201944:	a2850513          	addi	a0,a0,-1496 # ffffffffc0203368 <etext+0xf2a>
ffffffffc0201948:	8162                	mv	sp,s8
ffffffffc020194a:	ffefe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("----------------------------------------\n");
ffffffffc020194e:	00001517          	auipc	a0,0x1
ffffffffc0201952:	28a50513          	addi	a0,a0,650 # ffffffffc0202bd8 <etext+0x79a>
ffffffffc0201956:	ff2fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 4.1] Complex allocation pattern\n");
ffffffffc020195a:	00002517          	auipc	a0,0x2
ffffffffc020195e:	a3650513          	addi	a0,a0,-1482 # ffffffffc0203390 <etext+0xf52>
ffffffffc0201962:	c7040493          	addi	s1,s0,-912
ffffffffc0201966:	e0040913          	addi	s2,s0,-512
ffffffffc020196a:	fdefe0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc020196e:	8c26                	mv	s8,s1
ffffffffc0201970:	8bca                	mv	s7,s2
        for (int i = 0; i < 50; i++) {
ffffffffc0201972:	4a01                	li	s4,0
ffffffffc0201974:	03200c93          	li	s9,50
            size_t size = 16 + (i % 4) * 16; // 16, 32, 64, 128字节交替
ffffffffc0201978:	003a7993          	andi	s3,s4,3
ffffffffc020197c:	0992                	slli	s3,s3,0x4
ffffffffc020197e:	09c1                	addi	s3,s3,16
            pattern[i] = slub_alloc(size);
ffffffffc0201980:	854e                	mv	a0,s3
            allocated_sizes[i] = size;
ffffffffc0201982:	013bb023          	sd	s3,0(s7)
            pattern[i] = slub_alloc(size);
ffffffffc0201986:	869ff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc020198a:	00ac3023          	sd	a0,0(s8)
            if (pattern[i] == NULL) {
ffffffffc020198e:	48050263          	beqz	a0,ffffffffc0201e12 <slub_check+0x94c>
            memset(pattern[i], i & 0xFF, size);
ffffffffc0201992:	0ffa7593          	zext.b	a1,s4
ffffffffc0201996:	864e                	mv	a2,s3
        for (int i = 0; i < 50; i++) {
ffffffffc0201998:	2a05                	addiw	s4,s4,1
            memset(pattern[i], i & 0xFF, size);
ffffffffc020199a:	293000ef          	jal	ffffffffc020242c <memset>
        for (int i = 0; i < 50; i++) {
ffffffffc020199e:	0ba1                	addi	s7,s7,8
ffffffffc02019a0:	0c21                	addi	s8,s8,8
ffffffffc02019a2:	fd9a1be3          	bne	s4,s9,ffffffffc0201978 <slub_check+0x4b2>
        cprintf("[PASS] Complex allocation pattern completed\n");
ffffffffc02019a6:	00002517          	auipc	a0,0x2
ffffffffc02019aa:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02033e0 <etext+0xfa2>
ffffffffc02019ae:	f9afe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 4.2] Data integrity in complex pattern\n");
ffffffffc02019b2:	00002517          	auipc	a0,0x2
ffffffffc02019b6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0203410 <etext+0xfd2>
ffffffffc02019ba:	f8efe0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc02019be:	8626                	mv	a2,s1
ffffffffc02019c0:	e0040813          	addi	a6,s0,-512
        for (int i = 0; i < 50; i++) {
ffffffffc02019c4:	4681                	li	a3,0
            for (int j = 0; j < 10 && j < allocated_sizes[i]; j++) {
ffffffffc02019c6:	4529                	li	a0,10
        for (int i = 0; i < 50; i++) {
ffffffffc02019c8:	03200893          	li	a7,50
            for (int j = 0; j < 10 && j < allocated_sizes[i]; j++) {
ffffffffc02019cc:	00083583          	ld	a1,0(a6)
ffffffffc02019d0:	4781                	li	a5,0
ffffffffc02019d2:	00f58b63          	beq	a1,a5,ffffffffc02019e8 <slub_check+0x522>
                if (((char*)pattern[i])[j] != (i & 0xFF)) {
ffffffffc02019d6:	6218                	ld	a4,0(a2)
ffffffffc02019d8:	973e                	add	a4,a4,a5
ffffffffc02019da:	00074703          	lbu	a4,0(a4)
ffffffffc02019de:	40d71263          	bne	a4,a3,ffffffffc0201de2 <slub_check+0x91c>
            for (int j = 0; j < 10 && j < allocated_sizes[i]; j++) {
ffffffffc02019e2:	0785                	addi	a5,a5,1
ffffffffc02019e4:	fea797e3          	bne	a5,a0,ffffffffc02019d2 <slub_check+0x50c>
        for (int i = 0; i < 50; i++) {
ffffffffc02019e8:	2685                	addiw	a3,a3,1
ffffffffc02019ea:	0821                	addi	a6,a6,8
ffffffffc02019ec:	0621                	addi	a2,a2,8
ffffffffc02019ee:	fd169fe3          	bne	a3,a7,ffffffffc02019cc <slub_check+0x506>
        cprintf("[PASS] Data integrity maintained in complex pattern\n");
ffffffffc02019f2:	00002517          	auipc	a0,0x2
ffffffffc02019f6:	a8650513          	addi	a0,a0,-1402 # ffffffffc0203478 <etext+0x103a>
ffffffffc02019fa:	f4efe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 4.3] Partial free and reallocation\n");
ffffffffc02019fe:	00002517          	auipc	a0,0x2
ffffffffc0201a02:	ab250513          	addi	a0,a0,-1358 # ffffffffc02034b0 <etext+0x1072>
ffffffffc0201a06:	f42fe0ef          	jal	ffffffffc0200148 <cprintf>
        for (int i = 0; i < 50; i += 2) {
ffffffffc0201a0a:	19048a13          	addi	s4,s1,400
        cprintf("[TEST 4.3] Partial free and reallocation\n");
ffffffffc0201a0e:	89a6                	mv	s3,s1
            slub_free(pattern[i]);
ffffffffc0201a10:	0009b503          	ld	a0,0(s3)
        for (int i = 0; i < 50; i += 2) {
ffffffffc0201a14:	09c1                	addi	s3,s3,16
            slub_free(pattern[i]);
ffffffffc0201a16:	9afff0ef          	jal	ffffffffc02013c4 <slub_free>
            pattern[i] = NULL;
ffffffffc0201a1a:	fe09b823          	sd	zero,-16(s3)
        for (int i = 0; i < 50; i += 2) {
ffffffffc0201a1e:	ff4999e3          	bne	s3,s4,ffffffffc0201a10 <slub_check+0x54a>
        cprintf("Freed 50%% of objects\n");
ffffffffc0201a22:	00002517          	auipc	a0,0x2
ffffffffc0201a26:	abe50513          	addi	a0,a0,-1346 # ffffffffc02034e0 <etext+0x10a2>
ffffffffc0201a2a:	f1efe0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc0201a2e:	8ba6                	mv	s7,s1
        for (int i = 0; i < 50; i += 2) {
ffffffffc0201a30:	4981                	li	s3,0
ffffffffc0201a32:	03200c13          	li	s8,50
            pattern[i] = slub_alloc(allocated_sizes[i]);
ffffffffc0201a36:	00093503          	ld	a0,0(s2)
ffffffffc0201a3a:	fb4ff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201a3e:	00abb023          	sd	a0,0(s7)
            if (pattern[i] == NULL) {
ffffffffc0201a42:	48050063          	beqz	a0,ffffffffc0201ec2 <slub_check+0x9fc>
        for (int i = 0; i < 50; i += 2) {
ffffffffc0201a46:	2989                	addiw	s3,s3,2
ffffffffc0201a48:	0941                	addi	s2,s2,16
ffffffffc0201a4a:	0bc1                	addi	s7,s7,16
ffffffffc0201a4c:	ff8995e3          	bne	s3,s8,ffffffffc0201a36 <slub_check+0x570>
        cprintf("[PASS] Partial free and reallocation successful\n");
ffffffffc0201a50:	00002517          	auipc	a0,0x2
ffffffffc0201a54:	ad050513          	addi	a0,a0,-1328 # ffffffffc0203520 <etext+0x10e2>
ffffffffc0201a58:	ef0fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 4.4] Final cleanup and leak check\n");
ffffffffc0201a5c:	00002517          	auipc	a0,0x2
ffffffffc0201a60:	afc50513          	addi	a0,a0,-1284 # ffffffffc0203558 <etext+0x111a>
ffffffffc0201a64:	ee4fe0ef          	jal	ffffffffc0200148 <cprintf>
            if (pattern[i] != NULL) {
ffffffffc0201a68:	6088                	ld	a0,0(s1)
ffffffffc0201a6a:	c119                	beqz	a0,ffffffffc0201a70 <slub_check+0x5aa>
                slub_free(pattern[i]);
ffffffffc0201a6c:	959ff0ef          	jal	ffffffffc02013c4 <slub_free>
        for (int i = 0; i < 50; i++) {
ffffffffc0201a70:	04a1                	addi	s1,s1,8
ffffffffc0201a72:	ff449be3          	bne	s1,s4,ffffffffc0201a68 <slub_check+0x5a2>
    return best_fit_pmm_manager.nr_free_pages();
ffffffffc0201a76:	9b02                	jalr	s6
        if (initial_free_pages == final_pages) {
ffffffffc0201a78:	34aa8763          	beq	s5,a0,ffffffffc0201dc6 <slub_check+0x900>
            cprintf("[WARNING] Memory leakage in complex pattern: %d -> %d pages\n", 
ffffffffc0201a7c:	862a                	mv	a2,a0
ffffffffc0201a7e:	85d6                	mv	a1,s5
ffffffffc0201a80:	00002517          	auipc	a0,0x2
ffffffffc0201a84:	b3850513          	addi	a0,a0,-1224 # ffffffffc02035b8 <etext+0x117a>
ffffffffc0201a88:	ec0fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("\n[TEST 5] Edge Cases Handling\n");
ffffffffc0201a8c:	00002517          	auipc	a0,0x2
ffffffffc0201a90:	b6c50513          	addi	a0,a0,-1172 # ffffffffc02035f8 <etext+0x11ba>
ffffffffc0201a94:	eb4fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("----------------------------------------\n");
ffffffffc0201a98:	00001517          	auipc	a0,0x1
ffffffffc0201a9c:	14050513          	addi	a0,a0,320 # ffffffffc0202bd8 <etext+0x79a>
ffffffffc0201aa0:	ea8fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 5.1] Zero-size allocation\n");
ffffffffc0201aa4:	00002517          	auipc	a0,0x2
ffffffffc0201aa8:	b7450513          	addi	a0,a0,-1164 # ffffffffc0203618 <etext+0x11da>
ffffffffc0201aac:	e9cfe0ef          	jal	ffffffffc0200148 <cprintf>
        void *obj0 = slub_alloc(0);
ffffffffc0201ab0:	4501                	li	a0,0
ffffffffc0201ab2:	f3cff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201ab6:	84aa                	mv	s1,a0
        if (obj0 != NULL) {
ffffffffc0201ab8:	30050e63          	beqz	a0,ffffffffc0201dd4 <slub_check+0x90e>
            cprintf("[INFO] Zero-size allocation returned %p\n", obj0);
ffffffffc0201abc:	85aa                	mv	a1,a0
ffffffffc0201abe:	00002517          	auipc	a0,0x2
ffffffffc0201ac2:	b8250513          	addi	a0,a0,-1150 # ffffffffc0203640 <etext+0x1202>
ffffffffc0201ac6:	e82fe0ef          	jal	ffffffffc0200148 <cprintf>
            slub_free(obj0);
ffffffffc0201aca:	8526                	mv	a0,s1
ffffffffc0201acc:	8f9ff0ef          	jal	ffffffffc02013c4 <slub_free>
            cprintf("[PASS] Zero-size allocation handled\n");
ffffffffc0201ad0:	00002517          	auipc	a0,0x2
ffffffffc0201ad4:	ba050513          	addi	a0,a0,-1120 # ffffffffc0203670 <etext+0x1232>
ffffffffc0201ad8:	e70fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 5.2] Exact size allocation\n");
ffffffffc0201adc:	00002517          	auipc	a0,0x2
ffffffffc0201ae0:	bec50513          	addi	a0,a0,-1044 # ffffffffc02036c8 <etext+0x128a>
ffffffffc0201ae4:	e64fe0ef          	jal	ffffffffc0200148 <cprintf>
        void *obj16 = slub_alloc(16);  // 精确匹配16字节缓存
ffffffffc0201ae8:	4541                	li	a0,16
ffffffffc0201aea:	f04ff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201aee:	892a                	mv	s2,a0
        void *obj32 = slub_alloc(32);  // 精确匹配32字节缓存
ffffffffc0201af0:	02000513          	li	a0,32
ffffffffc0201af4:	efaff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201af8:	84aa                	mv	s1,a0
        if (obj16 != NULL && obj32 != NULL) {
ffffffffc0201afa:	3e090163          	beqz	s2,ffffffffc0201edc <slub_check+0xa16>
ffffffffc0201afe:	3c050f63          	beqz	a0,ffffffffc0201edc <slub_check+0xa16>
            cprintf("[PASS] Exact size allocations successful\n");
ffffffffc0201b02:	00002517          	auipc	a0,0x2
ffffffffc0201b06:	bee50513          	addi	a0,a0,-1042 # ffffffffc02036f0 <etext+0x12b2>
ffffffffc0201b0a:	e3efe0ef          	jal	ffffffffc0200148 <cprintf>
            slub_free(obj16);
ffffffffc0201b0e:	854a                	mv	a0,s2
ffffffffc0201b10:	8b5ff0ef          	jal	ffffffffc02013c4 <slub_free>
            slub_free(obj32);
ffffffffc0201b14:	8526                	mv	a0,s1
ffffffffc0201b16:	8afff0ef          	jal	ffffffffc02013c4 <slub_free>
        cprintf("[TEST 5.3] Oversize allocation\n");
ffffffffc0201b1a:	00002517          	auipc	a0,0x2
ffffffffc0201b1e:	c0650513          	addi	a0,a0,-1018 # ffffffffc0203720 <etext+0x12e2>
ffffffffc0201b22:	e26fe0ef          	jal	ffffffffc0200148 <cprintf>
        void *obj_big = slub_alloc(200);  // 超过最大缓存大小
ffffffffc0201b26:	0c800513          	li	a0,200
ffffffffc0201b2a:	ec4ff0ef          	jal	ffffffffc02011ee <slub_alloc>
        if (obj_big == NULL) {
ffffffffc0201b2e:	32051a63          	bnez	a0,ffffffffc0201e62 <slub_check+0x99c>
            cprintf("[PASS] Oversize allocation correctly rejected\n");
ffffffffc0201b32:	00002517          	auipc	a0,0x2
ffffffffc0201b36:	c3650513          	addi	a0,a0,-970 # ffffffffc0203768 <etext+0x132a>
ffffffffc0201b3a:	e0efe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 5.4] NULL pointer free\n");
ffffffffc0201b3e:	00002517          	auipc	a0,0x2
ffffffffc0201b42:	c5a50513          	addi	a0,a0,-934 # ffffffffc0203798 <etext+0x135a>
ffffffffc0201b46:	e02fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[PASS] NULL pointer free handled gracefully\n");
ffffffffc0201b4a:	00002517          	auipc	a0,0x2
ffffffffc0201b4e:	c6e50513          	addi	a0,a0,-914 # ffffffffc02037b8 <etext+0x137a>
ffffffffc0201b52:	df6fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 5.5] Double free detection\n");
ffffffffc0201b56:	00002517          	auipc	a0,0x2
ffffffffc0201b5a:	c9250513          	addi	a0,a0,-878 # ffffffffc02037e8 <etext+0x13aa>
ffffffffc0201b5e:	deafe0ef          	jal	ffffffffc0200148 <cprintf>
        void *temp_obj = slub_alloc(16);
ffffffffc0201b62:	4541                	li	a0,16
ffffffffc0201b64:	e8aff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201b68:	84aa                	mv	s1,a0
        slub_free(temp_obj);
ffffffffc0201b6a:	85bff0ef          	jal	ffffffffc02013c4 <slub_free>
        slub_free(temp_obj);  // 双释放 - 应该被安全处理
ffffffffc0201b6e:	8526                	mv	a0,s1
ffffffffc0201b70:	855ff0ef          	jal	ffffffffc02013c4 <slub_free>
        cprintf("[PASS] Double free handled without crash\n");
ffffffffc0201b74:	00002517          	auipc	a0,0x2
ffffffffc0201b78:	c9c50513          	addi	a0,a0,-868 # ffffffffc0203810 <etext+0x13d2>
ffffffffc0201b7c:	dccfe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("\n[TEST 6] Performance Benchmark (Simplified)\n");
ffffffffc0201b80:	00002517          	auipc	a0,0x2
ffffffffc0201b84:	cc050513          	addi	a0,a0,-832 # ffffffffc0203840 <etext+0x1402>
ffffffffc0201b88:	dc0fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("----------------------------------------\n");
ffffffffc0201b8c:	00001517          	auipc	a0,0x1
ffffffffc0201b90:	04c50513          	addi	a0,a0,76 # ffffffffc0202bd8 <etext+0x79a>
ffffffffc0201b94:	db4fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 6.1] Allocation performance\n");
ffffffffc0201b98:	00002517          	auipc	a0,0x2
ffffffffc0201b9c:	cd850513          	addi	a0,a0,-808 # ffffffffc0203870 <etext+0x1432>
    {
ffffffffc0201ba0:	8a0a                	mv	s4,sp
        cprintf("[TEST 6.1] Allocation performance\n");
ffffffffc0201ba2:	da6fe0ef          	jal	ffffffffc0200148 <cprintf>
        void *objects[ITERATIONS];
ffffffffc0201ba6:	ce010113          	addi	sp,sp,-800
ffffffffc0201baa:	848a                	mv	s1,sp
        for (int i = 0; i < ITERATIONS; i++) {
ffffffffc0201bac:	89d2                	mv	s3,s4
        void *objects[ITERATIONS];
ffffffffc0201bae:	890a                	mv	s2,sp
            objects[i] = slub_alloc(32);  // 使用32字节缓存
ffffffffc0201bb0:	02000513          	li	a0,32
ffffffffc0201bb4:	e3aff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201bb8:	00a93023          	sd	a0,0(s2)
            if (objects[i] == NULL) {
ffffffffc0201bbc:	22050f63          	beqz	a0,ffffffffc0201dfa <slub_check+0x934>
        for (int i = 0; i < ITERATIONS; i++) {
ffffffffc0201bc0:	0921                	addi	s2,s2,8
ffffffffc0201bc2:	ff3917e3          	bne	s2,s3,ffffffffc0201bb0 <slub_check+0x6ea>
        cprintf("Allocated %d objects successfully\n", ITERATIONS);
ffffffffc0201bc6:	06400593          	li	a1,100
ffffffffc0201bca:	00002517          	auipc	a0,0x2
ffffffffc0201bce:	d2650513          	addi	a0,a0,-730 # ffffffffc02038f0 <etext+0x14b2>
ffffffffc0201bd2:	d76fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 6.2] Free performance\n");
ffffffffc0201bd6:	00002517          	auipc	a0,0x2
ffffffffc0201bda:	d4250513          	addi	a0,a0,-702 # ffffffffc0203918 <etext+0x14da>
ffffffffc0201bde:	d6afe0ef          	jal	ffffffffc0200148 <cprintf>
            slub_free(objects[i]);
ffffffffc0201be2:	6088                	ld	a0,0(s1)
        for (int i = 0; i < ITERATIONS; i++) {
ffffffffc0201be4:	04a1                	addi	s1,s1,8
            slub_free(objects[i]);
ffffffffc0201be6:	fdeff0ef          	jal	ffffffffc02013c4 <slub_free>
        for (int i = 0; i < ITERATIONS; i++) {
ffffffffc0201bea:	ff349ce3          	bne	s1,s3,ffffffffc0201be2 <slub_check+0x71c>
        cprintf("Freed %d objects successfully\n", ITERATIONS);
ffffffffc0201bee:	06400593          	li	a1,100
ffffffffc0201bf2:	00002517          	auipc	a0,0x2
ffffffffc0201bf6:	d4650513          	addi	a0,a0,-698 # ffffffffc0203938 <etext+0x14fa>
ffffffffc0201bfa:	d4efe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[PASS] Performance benchmark completed\n");
ffffffffc0201bfe:	00002517          	auipc	a0,0x2
ffffffffc0201c02:	d5a50513          	addi	a0,a0,-678 # ffffffffc0203958 <etext+0x151a>
ffffffffc0201c06:	d42fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("\n[TEST 7] Integrity Check (Simplified)\n");
ffffffffc0201c0a:	00002517          	auipc	a0,0x2
ffffffffc0201c0e:	d7650513          	addi	a0,a0,-650 # ffffffffc0203980 <etext+0x1542>
ffffffffc0201c12:	8152                	mv	sp,s4
ffffffffc0201c14:	d34fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("----------------------------------------\n");
ffffffffc0201c18:	00001517          	auipc	a0,0x1
ffffffffc0201c1c:	fc050513          	addi	a0,a0,-64 # ffffffffc0202bd8 <etext+0x79a>
ffffffffc0201c20:	d28fe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 7.1] Cache basic verification\n");
ffffffffc0201c24:	00002517          	auipc	a0,0x2
ffffffffc0201c28:	d8450513          	addi	a0,a0,-636 # ffffffffc02039a8 <etext+0x156a>
ffffffffc0201c2c:	d1cfe0ef          	jal	ffffffffc0200148 <cprintf>
        for (int i = 0; i < 4; i++) {
ffffffffc0201c30:	00005497          	auipc	s1,0x5
ffffffffc0201c34:	40048493          	addi	s1,s1,1024 # ffffffffc0207030 <caches>
ffffffffc0201c38:	00005917          	auipc	s2,0x5
ffffffffc0201c3c:	4f890913          	addi	s2,s2,1272 # ffffffffc0207130 <is_panic>
            cprintf("Cache %dB: full=%d, partial=%d, free=%d\n", 
ffffffffc0201c40:	7498                	ld	a4,40(s1)
ffffffffc0201c42:	6c94                	ld	a3,24(s1)
ffffffffc0201c44:	6490                	ld	a2,8(s1)
ffffffffc0201c46:	02048793          	addi	a5,s1,32
ffffffffc0201c4a:	788c                	ld	a1,48(s1)
ffffffffc0201c4c:	8f1d                	sub	a4,a4,a5
ffffffffc0201c4e:	01048793          	addi	a5,s1,16
ffffffffc0201c52:	8e9d                	sub	a3,a3,a5
ffffffffc0201c54:	8e05                	sub	a2,a2,s1
ffffffffc0201c56:	00e03733          	snez	a4,a4
ffffffffc0201c5a:	00d036b3          	snez	a3,a3
ffffffffc0201c5e:	00c03633          	snez	a2,a2
ffffffffc0201c62:	00002517          	auipc	a0,0x2
ffffffffc0201c66:	d6e50513          	addi	a0,a0,-658 # ffffffffc02039d0 <etext+0x1592>
        for (int i = 0; i < 4; i++) {
ffffffffc0201c6a:	04048493          	addi	s1,s1,64
            cprintf("Cache %dB: full=%d, partial=%d, free=%d\n", 
ffffffffc0201c6e:	cdafe0ef          	jal	ffffffffc0200148 <cprintf>
        for (int i = 0; i < 4; i++) {
ffffffffc0201c72:	fc9917e3          	bne	s2,s1,ffffffffc0201c40 <slub_check+0x77a>
        cprintf("[PASS] Basic cache verification completed\n");
ffffffffc0201c76:	00002517          	auipc	a0,0x2
ffffffffc0201c7a:	d8a50513          	addi	a0,a0,-630 # ffffffffc0203a00 <etext+0x15c2>
ffffffffc0201c7e:	ccafe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("[TEST 7.2] Cross-cache isolation verification\n");
ffffffffc0201c82:	00002517          	auipc	a0,0x2
ffffffffc0201c86:	dae50513          	addi	a0,a0,-594 # ffffffffc0203a30 <etext+0x15f2>
ffffffffc0201c8a:	cbefe0ef          	jal	ffffffffc0200148 <cprintf>
        void *small_obj = slub_alloc(10);   // 16B缓存
ffffffffc0201c8e:	4529                	li	a0,10
ffffffffc0201c90:	d5eff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201c94:	84aa                	mv	s1,a0
        void *medium_obj = slub_alloc(20);  // 32B缓存
ffffffffc0201c96:	4551                	li	a0,20
ffffffffc0201c98:	d56ff0ef          	jal	ffffffffc02011ee <slub_alloc>
ffffffffc0201c9c:	892a                	mv	s2,a0
    physaddr_t pa = KVA_TO_PA((uintptr_t)obj);
ffffffffc0201c9e:	3fe007b7          	lui	a5,0x3fe00
ffffffffc0201ca2:	00f48533          	add	a0,s1,a5
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201ca6:	ccccd5b7          	lui	a1,0xccccd
    physaddr_t pa = KVA_TO_PA((uintptr_t)obj);
ffffffffc0201caa:	97ca                	add	a5,a5,s2
    struct Page *page = pa2page(pa);
ffffffffc0201cac:	00c7d693          	srli	a3,a5,0xc
ffffffffc0201cb0:	8131                	srli	a0,a0,0xc
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201cb2:	ccd58593          	addi	a1,a1,-819 # ffffffffcccccccd <end+0xcac5b55>
    struct Page *page = pa2page(pa);
ffffffffc0201cb6:	00269713          	slli	a4,a3,0x2
ffffffffc0201cba:	00251793          	slli	a5,a0,0x2
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
ffffffffc0201cbe:	02059613          	slli	a2,a1,0x20
ffffffffc0201cc2:	962e                	add	a2,a2,a1
ffffffffc0201cc4:	9736                	add	a4,a4,a3
ffffffffc0201cc6:	97aa                	add	a5,a5,a0
ffffffffc0201cc8:	02c787b3          	mul	a5,a5,a2
ffffffffc0201ccc:	fffc06b7          	lui	a3,0xfffc0
ffffffffc0201cd0:	20068693          	addi	a3,a3,512 # fffffffffffc0200 <end+0x3fdb9088>
ffffffffc0201cd4:	02c70733          	mul	a4,a4,a2
ffffffffc0201cd8:	97b6                	add	a5,a5,a3
ffffffffc0201cda:	07b2                	slli	a5,a5,0xc
ffffffffc0201cdc:	9736                	add	a4,a4,a3
ffffffffc0201cde:	0732                	slli	a4,a4,0xc
        if (slab_of(small_obj) == slab_of(medium_obj)) {
ffffffffc0201ce0:	1cf70563          	beq	a4,a5,ffffffffc0201eaa <slub_check+0x9e4>
        cprintf("[PASS] Cross-cache isolation verified\n");
ffffffffc0201ce4:	00002517          	auipc	a0,0x2
ffffffffc0201ce8:	da450513          	addi	a0,a0,-604 # ffffffffc0203a88 <etext+0x164a>
ffffffffc0201cec:	c5cfe0ef          	jal	ffffffffc0200148 <cprintf>
        slub_free(small_obj);
ffffffffc0201cf0:	8526                	mv	a0,s1
ffffffffc0201cf2:	ed2ff0ef          	jal	ffffffffc02013c4 <slub_free>
        slub_free(medium_obj);
ffffffffc0201cf6:	854a                	mv	a0,s2
ffffffffc0201cf8:	eccff0ef          	jal	ffffffffc02013c4 <slub_free>
    cprintf("\n[FINAL] Final State Verification\n");
ffffffffc0201cfc:	00002517          	auipc	a0,0x2
ffffffffc0201d00:	db450513          	addi	a0,a0,-588 # ffffffffc0203ab0 <etext+0x1672>
ffffffffc0201d04:	c44fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("----------------------------------------\n");
ffffffffc0201d08:	00001517          	auipc	a0,0x1
ffffffffc0201d0c:	ed050513          	addi	a0,a0,-304 # ffffffffc0202bd8 <etext+0x79a>
ffffffffc0201d10:	c38fe0ef          	jal	ffffffffc0200148 <cprintf>
    return best_fit_pmm_manager.nr_free_pages();
ffffffffc0201d14:	9b02                	jalr	s6
ffffffffc0201d16:	84aa                	mv	s1,a0
    cprintf("[FINAL] Final free pages: %d\n", final_free_pages);
ffffffffc0201d18:	85aa                	mv	a1,a0
ffffffffc0201d1a:	00002517          	auipc	a0,0x2
ffffffffc0201d1e:	dbe50513          	addi	a0,a0,-578 # ffffffffc0203ad8 <etext+0x169a>
ffffffffc0201d22:	c26fe0ef          	jal	ffffffffc0200148 <cprintf>
    if (initial_free_pages == final_free_pages) {
ffffffffc0201d26:	089a8963          	beq	s5,s1,ffffffffc0201db8 <slub_check+0x8f2>
        cprintf("[WARNING] Memory leakage: %d -> %d pages\n", 
ffffffffc0201d2a:	8626                	mv	a2,s1
ffffffffc0201d2c:	85d6                	mv	a1,s5
ffffffffc0201d2e:	00002517          	auipc	a0,0x2
ffffffffc0201d32:	df250513          	addi	a0,a0,-526 # ffffffffc0203b20 <etext+0x16e2>
ffffffffc0201d36:	c12fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("\n========================================\n");
ffffffffc0201d3a:	00002517          	auipc	a0,0x2
ffffffffc0201d3e:	e1650513          	addi	a0,a0,-490 # ffffffffc0203b50 <etext+0x1712>
ffffffffc0201d42:	c06fe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("SLUB COMPREHENSIVE TEST SUITE COMPLETED\n");
ffffffffc0201d46:	00002517          	auipc	a0,0x2
ffffffffc0201d4a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0203b80 <etext+0x1742>
ffffffffc0201d4e:	bfafe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("========================================\n");
ffffffffc0201d52:	00001517          	auipc	a0,0x1
ffffffffc0201d56:	dde50513          	addi	a0,a0,-546 # ffffffffc0202b30 <etext+0x6f2>
ffffffffc0201d5a:	beefe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("check_slub() succeeded!\n");
ffffffffc0201d5e:	00002517          	auipc	a0,0x2
ffffffffc0201d62:	e5250513          	addi	a0,a0,-430 # ffffffffc0203bb0 <etext+0x1772>
ffffffffc0201d66:	be2fe0ef          	jal	ffffffffc0200148 <cprintf>
}
ffffffffc0201d6a:	c5040113          	addi	sp,s0,-944
ffffffffc0201d6e:	3a813083          	ld	ra,936(sp)
ffffffffc0201d72:	3a013403          	ld	s0,928(sp)
ffffffffc0201d76:	39813483          	ld	s1,920(sp)
ffffffffc0201d7a:	39013903          	ld	s2,912(sp)
ffffffffc0201d7e:	38813983          	ld	s3,904(sp)
ffffffffc0201d82:	38013a03          	ld	s4,896(sp)
ffffffffc0201d86:	37813a83          	ld	s5,888(sp)
ffffffffc0201d8a:	37013b03          	ld	s6,880(sp)
ffffffffc0201d8e:	36813b83          	ld	s7,872(sp)
ffffffffc0201d92:	36013c03          	ld	s8,864(sp)
ffffffffc0201d96:	35813c83          	ld	s9,856(sp)
ffffffffc0201d9a:	35013d03          	ld	s10,848(sp)
ffffffffc0201d9e:	34813d83          	ld	s11,840(sp)
ffffffffc0201da2:	3b010113          	addi	sp,sp,944
ffffffffc0201da6:	8082                	ret
            cprintf("[PASS] Single object properly freed\n");
ffffffffc0201da8:	00001517          	auipc	a0,0x1
ffffffffc0201dac:	f8850513          	addi	a0,a0,-120 # ffffffffc0202d30 <etext+0x8f2>
ffffffffc0201db0:	b98fe0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc0201db4:	821ff06f          	j	ffffffffc02015d4 <slub_check+0x10e>
        cprintf("[SUCCESS] No memory leakage detected\n");
ffffffffc0201db8:	00002517          	auipc	a0,0x2
ffffffffc0201dbc:	d4050513          	addi	a0,a0,-704 # ffffffffc0203af8 <etext+0x16ba>
ffffffffc0201dc0:	b88fe0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc0201dc4:	bf9d                	j	ffffffffc0201d3a <slub_check+0x874>
            cprintf("[PASS] No memory leakage in complex pattern\n");
ffffffffc0201dc6:	00001517          	auipc	a0,0x1
ffffffffc0201dca:	7c250513          	addi	a0,a0,1986 # ffffffffc0203588 <etext+0x114a>
ffffffffc0201dce:	b7afe0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc0201dd2:	b96d                	j	ffffffffc0201a8c <slub_check+0x5c6>
            cprintf("[PASS] Zero-size allocation correctly rejected\n");
ffffffffc0201dd4:	00002517          	auipc	a0,0x2
ffffffffc0201dd8:	8c450513          	addi	a0,a0,-1852 # ffffffffc0203698 <etext+0x125a>
ffffffffc0201ddc:	b6cfe0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc0201de0:	b9f5                	j	ffffffffc0201adc <slub_check+0x616>
                    panic("[FAIL] Data corruption in complex pattern at object %d\n", i);
ffffffffc0201de2:	00001617          	auipc	a2,0x1
ffffffffc0201de6:	65e60613          	addi	a2,a2,1630 # ffffffffc0203440 <etext+0x1002>
ffffffffc0201dea:	12900593          	li	a1,297
ffffffffc0201dee:	00001517          	auipc	a0,0x1
ffffffffc0201df2:	e6a50513          	addi	a0,a0,-406 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201df6:	bd2fe0ef          	jal	ffffffffc02001c8 <__panic>
                panic("[FAIL] Performance test allocation failed\n");
ffffffffc0201dfa:	00002617          	auipc	a2,0x2
ffffffffc0201dfe:	ac660613          	addi	a2,a2,-1338 # ffffffffc02038c0 <etext+0x1482>
ffffffffc0201e02:	18c00593          	li	a1,396
ffffffffc0201e06:	00001517          	auipc	a0,0x1
ffffffffc0201e0a:	e5250513          	addi	a0,a0,-430 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201e0e:	bbafe0ef          	jal	ffffffffc02001c8 <__panic>
                panic("[FAIL] Pattern allocation failed at step %d\n", i);
ffffffffc0201e12:	86d2                	mv	a3,s4
ffffffffc0201e14:	00001617          	auipc	a2,0x1
ffffffffc0201e18:	f7460613          	addi	a2,a2,-140 # ffffffffc0202d88 <etext+0x94a>
ffffffffc0201e1c:	11c00593          	li	a1,284
ffffffffc0201e20:	00001517          	auipc	a0,0x1
ffffffffc0201e24:	e3850513          	addi	a0,a0,-456 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201e28:	ba0fe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Object reuse failed: %p != %p\n", reused_obj, first_obj);
ffffffffc0201e2c:	86aa                	mv	a3,a0
ffffffffc0201e2e:	875e                	mv	a4,s7
ffffffffc0201e30:	00001617          	auipc	a2,0x1
ffffffffc0201e34:	58860613          	addi	a2,a2,1416 # ffffffffc02033b8 <etext+0xf7a>
ffffffffc0201e38:	0fe00593          	li	a1,254
ffffffffc0201e3c:	00001517          	auipc	a0,0x1
ffffffffc0201e40:	e1c50513          	addi	a0,a0,-484 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201e44:	b84fe0ef          	jal	ffffffffc02001c8 <__panic>
                panic("[FAIL] Pattern allocation failed at step %d\n", i);
ffffffffc0201e48:	86e2                	mv	a3,s8
ffffffffc0201e4a:	00001617          	auipc	a2,0x1
ffffffffc0201e4e:	f3e60613          	addi	a2,a2,-194 # ffffffffc0202d88 <etext+0x94a>
ffffffffc0201e52:	08a00593          	li	a1,138
ffffffffc0201e56:	00001517          	auipc	a0,0x1
ffffffffc0201e5a:	e0250513          	addi	a0,a0,-510 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201e5e:	b6afe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Oversize allocation should fail\n");
ffffffffc0201e62:	00002617          	auipc	a2,0x2
ffffffffc0201e66:	a3660613          	addi	a2,a2,-1482 # ffffffffc0203898 <etext+0x145a>
ffffffffc0201e6a:	16f00593          	li	a1,367
ffffffffc0201e6e:	00001517          	auipc	a0,0x1
ffffffffc0201e72:	dea50513          	addi	a0,a0,-534 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201e76:	b52fe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Cache size selection incorrect\n");
ffffffffc0201e7a:	00001617          	auipc	a2,0x1
ffffffffc0201e7e:	06e60613          	addi	a2,a2,110 # ffffffffc0202ee8 <etext+0xaaa>
ffffffffc0201e82:	0a900593          	li	a1,169
ffffffffc0201e86:	00001517          	auipc	a0,0x1
ffffffffc0201e8a:	dd250513          	addi	a0,a0,-558 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201e8e:	b3afe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Basic allocation failed\n");
ffffffffc0201e92:	00001617          	auipc	a2,0x1
ffffffffc0201e96:	da660613          	addi	a2,a2,-602 # ffffffffc0202c38 <etext+0x7fa>
ffffffffc0201e9a:	06d00593          	li	a1,109
ffffffffc0201e9e:	00001517          	auipc	a0,0x1
ffffffffc0201ea2:	dba50513          	addi	a0,a0,-582 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201ea6:	b22fe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Cross-cache isolation failed\n");
ffffffffc0201eaa:	00002617          	auipc	a2,0x2
ffffffffc0201eae:	bb660613          	addi	a2,a2,-1098 # ffffffffc0203a60 <etext+0x1622>
ffffffffc0201eb2:	1b100593          	li	a1,433
ffffffffc0201eb6:	00001517          	auipc	a0,0x1
ffffffffc0201eba:	da250513          	addi	a0,a0,-606 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201ebe:	b0afe0ef          	jal	ffffffffc02001c8 <__panic>
                panic("[FAIL] Re-allocation failed at step %d\n", i);
ffffffffc0201ec2:	86ce                	mv	a3,s3
ffffffffc0201ec4:	00001617          	auipc	a2,0x1
ffffffffc0201ec8:	63460613          	addi	a2,a2,1588 # ffffffffc02034f8 <etext+0x10ba>
ffffffffc0201ecc:	13b00593          	li	a1,315
ffffffffc0201ed0:	00001517          	auipc	a0,0x1
ffffffffc0201ed4:	d8850513          	addi	a0,a0,-632 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201ed8:	af0fe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Exact size allocations failed\n");
ffffffffc0201edc:	00002617          	auipc	a2,0x2
ffffffffc0201ee0:	86460613          	addi	a2,a2,-1948 # ffffffffc0203740 <etext+0x1302>
ffffffffc0201ee4:	16700593          	li	a1,359
ffffffffc0201ee8:	00001517          	auipc	a0,0x1
ffffffffc0201eec:	d7050513          	addi	a0,a0,-656 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201ef0:	ad8fe0ef          	jal	ffffffffc02001c8 <__panic>
                panic("[FAIL] Slab partial state incorrect\n");
ffffffffc0201ef4:	00001617          	auipc	a2,0x1
ffffffffc0201ef8:	3a460613          	addi	a2,a2,932 # ffffffffc0203298 <etext+0xe5a>
ffffffffc0201efc:	0f200593          	li	a1,242
ffffffffc0201f00:	00001517          	auipc	a0,0x1
ffffffffc0201f04:	d5850513          	addi	a0,a0,-680 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201f08:	ac0fe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Slab should be in partial list\n");
ffffffffc0201f0c:	00001617          	auipc	a2,0x1
ffffffffc0201f10:	3b460613          	addi	a2,a2,948 # ffffffffc02032c0 <etext+0xe82>
ffffffffc0201f14:	0f500593          	li	a1,245
ffffffffc0201f18:	00001517          	auipc	a0,0x1
ffffffffc0201f1c:	d4050513          	addi	a0,a0,-704 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201f20:	aa8fe0ef          	jal	ffffffffc02001c8 <__panic>
                panic("[FAIL] Slab full state incorrect\n");
ffffffffc0201f24:	00001617          	auipc	a2,0x1
ffffffffc0201f28:	2c460613          	addi	a2,a2,708 # ffffffffc02031e8 <etext+0xdaa>
ffffffffc0201f2c:	0e300593          	li	a1,227
ffffffffc0201f30:	00001517          	auipc	a0,0x1
ffffffffc0201f34:	d2850513          	addi	a0,a0,-728 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201f38:	a90fe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Slab should be in full list\n");
ffffffffc0201f3c:	00001617          	auipc	a2,0x1
ffffffffc0201f40:	2d460613          	addi	a2,a2,724 # ffffffffc0203210 <etext+0xdd2>
ffffffffc0201f44:	0e600593          	li	a1,230
ffffffffc0201f48:	00001517          	auipc	a0,0x1
ffffffffc0201f4c:	d1050513          	addi	a0,a0,-752 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201f50:	a78fe0ef          	jal	ffffffffc02001c8 <__panic>
                panic("[FAIL] Failed to fill slab at object %d\n", i);
ffffffffc0201f54:	86a6                	mv	a3,s1
ffffffffc0201f56:	00001617          	auipc	a2,0x1
ffffffffc0201f5a:	1fa60613          	addi	a2,a2,506 # ffffffffc0203150 <etext+0xd12>
ffffffffc0201f5e:	0d900593          	li	a1,217
ffffffffc0201f62:	00001517          	auipc	a0,0x1
ffffffffc0201f66:	cf650513          	addi	a0,a0,-778 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201f6a:	a5efe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Different cache objects not isolated\n");
ffffffffc0201f6e:	00001617          	auipc	a2,0x1
ffffffffc0201f72:	08a60613          	addi	a2,a2,138 # ffffffffc0202ff8 <etext+0xbba>
ffffffffc0201f76:	0b700593          	li	a1,183
ffffffffc0201f7a:	00001517          	auipc	a0,0x1
ffffffffc0201f7e:	cde50513          	addi	a0,a0,-802 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201f82:	a46fe0ef          	jal	ffffffffc02001c8 <__panic>
            panic("[FAIL] Same cache objects not in same slab\n");
ffffffffc0201f86:	00001617          	auipc	a2,0x1
ffffffffc0201f8a:	fe260613          	addi	a2,a2,-30 # ffffffffc0202f68 <etext+0xb2a>
ffffffffc0201f8e:	0b000593          	li	a1,176
ffffffffc0201f92:	00001517          	auipc	a0,0x1
ffffffffc0201f96:	cc650513          	addi	a0,a0,-826 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201f9a:	a2efe0ef          	jal	ffffffffc02001c8 <__panic>
                panic("[FAIL] Data corruption detected\n");
ffffffffc0201f9e:	00001617          	auipc	a2,0x1
ffffffffc0201fa2:	d1a60613          	addi	a2,a2,-742 # ffffffffc0202cb8 <etext+0x87a>
ffffffffc0201fa6:	07600593          	li	a1,118
ffffffffc0201faa:	00001517          	auipc	a0,0x1
ffffffffc0201fae:	cae50513          	addi	a0,a0,-850 # ffffffffc0202c58 <etext+0x81a>
ffffffffc0201fb2:	a16fe0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0201fb6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201fb6:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201fb8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201fbc:	f022                	sd	s0,32(sp)
ffffffffc0201fbe:	ec26                	sd	s1,24(sp)
ffffffffc0201fc0:	e84a                	sd	s2,16(sp)
ffffffffc0201fc2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201fc4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201fc8:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201fca:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201fce:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201fd2:	84aa                	mv	s1,a0
ffffffffc0201fd4:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc0201fd6:	03067d63          	bgeu	a2,a6,ffffffffc0202010 <printnum+0x5a>
ffffffffc0201fda:	e44e                	sd	s3,8(sp)
ffffffffc0201fdc:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201fde:	4785                	li	a5,1
ffffffffc0201fe0:	00e7d763          	bge	a5,a4,ffffffffc0201fee <printnum+0x38>
            putch(padc, putdat);
ffffffffc0201fe4:	85ca                	mv	a1,s2
ffffffffc0201fe6:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0201fe8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201fea:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201fec:	fc65                	bnez	s0,ffffffffc0201fe4 <printnum+0x2e>
ffffffffc0201fee:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ff0:	00002797          	auipc	a5,0x2
ffffffffc0201ff4:	bf878793          	addi	a5,a5,-1032 # ffffffffc0203be8 <etext+0x17aa>
ffffffffc0201ff8:	97d2                	add	a5,a5,s4
}
ffffffffc0201ffa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ffc:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0202000:	70a2                	ld	ra,40(sp)
ffffffffc0202002:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0202004:	85ca                	mv	a1,s2
ffffffffc0202006:	87a6                	mv	a5,s1
}
ffffffffc0202008:	6942                	ld	s2,16(sp)
ffffffffc020200a:	64e2                	ld	s1,24(sp)
ffffffffc020200c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020200e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0202010:	03065633          	divu	a2,a2,a6
ffffffffc0202014:	8722                	mv	a4,s0
ffffffffc0202016:	fa1ff0ef          	jal	ffffffffc0201fb6 <printnum>
ffffffffc020201a:	bfd9                	j	ffffffffc0201ff0 <printnum+0x3a>

ffffffffc020201c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020201c:	7119                	addi	sp,sp,-128
ffffffffc020201e:	f4a6                	sd	s1,104(sp)
ffffffffc0202020:	f0ca                	sd	s2,96(sp)
ffffffffc0202022:	ecce                	sd	s3,88(sp)
ffffffffc0202024:	e8d2                	sd	s4,80(sp)
ffffffffc0202026:	e4d6                	sd	s5,72(sp)
ffffffffc0202028:	e0da                	sd	s6,64(sp)
ffffffffc020202a:	f862                	sd	s8,48(sp)
ffffffffc020202c:	fc86                	sd	ra,120(sp)
ffffffffc020202e:	f8a2                	sd	s0,112(sp)
ffffffffc0202030:	fc5e                	sd	s7,56(sp)
ffffffffc0202032:	f466                	sd	s9,40(sp)
ffffffffc0202034:	f06a                	sd	s10,32(sp)
ffffffffc0202036:	ec6e                	sd	s11,24(sp)
ffffffffc0202038:	84aa                	mv	s1,a0
ffffffffc020203a:	8c32                	mv	s8,a2
ffffffffc020203c:	8a36                	mv	s4,a3
ffffffffc020203e:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0202040:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0202044:	05500b13          	li	s6,85
ffffffffc0202048:	00002a97          	auipc	s5,0x2
ffffffffc020204c:	d08a8a93          	addi	s5,s5,-760 # ffffffffc0203d50 <obj_sizes+0x20>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0202050:	000c4503          	lbu	a0,0(s8)
ffffffffc0202054:	001c0413          	addi	s0,s8,1
ffffffffc0202058:	01350a63          	beq	a0,s3,ffffffffc020206c <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020205c:	cd0d                	beqz	a0,ffffffffc0202096 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc020205e:	85ca                	mv	a1,s2
ffffffffc0202060:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0202062:	00044503          	lbu	a0,0(s0)
ffffffffc0202066:	0405                	addi	s0,s0,1
ffffffffc0202068:	ff351ae3          	bne	a0,s3,ffffffffc020205c <vprintfmt+0x40>
        width = precision = -1;
ffffffffc020206c:	5cfd                	li	s9,-1
ffffffffc020206e:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0202070:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0202074:	4b81                	li	s7,0
ffffffffc0202076:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0202078:	00044683          	lbu	a3,0(s0)
ffffffffc020207c:	00140c13          	addi	s8,s0,1
ffffffffc0202080:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0202084:	0ff5f593          	zext.b	a1,a1
ffffffffc0202088:	02bb6663          	bltu	s6,a1,ffffffffc02020b4 <vprintfmt+0x98>
ffffffffc020208c:	058a                	slli	a1,a1,0x2
ffffffffc020208e:	95d6                	add	a1,a1,s5
ffffffffc0202090:	4198                	lw	a4,0(a1)
ffffffffc0202092:	9756                	add	a4,a4,s5
ffffffffc0202094:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0202096:	70e6                	ld	ra,120(sp)
ffffffffc0202098:	7446                	ld	s0,112(sp)
ffffffffc020209a:	74a6                	ld	s1,104(sp)
ffffffffc020209c:	7906                	ld	s2,96(sp)
ffffffffc020209e:	69e6                	ld	s3,88(sp)
ffffffffc02020a0:	6a46                	ld	s4,80(sp)
ffffffffc02020a2:	6aa6                	ld	s5,72(sp)
ffffffffc02020a4:	6b06                	ld	s6,64(sp)
ffffffffc02020a6:	7be2                	ld	s7,56(sp)
ffffffffc02020a8:	7c42                	ld	s8,48(sp)
ffffffffc02020aa:	7ca2                	ld	s9,40(sp)
ffffffffc02020ac:	7d02                	ld	s10,32(sp)
ffffffffc02020ae:	6de2                	ld	s11,24(sp)
ffffffffc02020b0:	6109                	addi	sp,sp,128
ffffffffc02020b2:	8082                	ret
            putch('%', putdat);
ffffffffc02020b4:	85ca                	mv	a1,s2
ffffffffc02020b6:	02500513          	li	a0,37
ffffffffc02020ba:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02020bc:	fff44783          	lbu	a5,-1(s0)
ffffffffc02020c0:	02500713          	li	a4,37
ffffffffc02020c4:	8c22                	mv	s8,s0
ffffffffc02020c6:	f8e785e3          	beq	a5,a4,ffffffffc0202050 <vprintfmt+0x34>
ffffffffc02020ca:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02020ce:	1c7d                	addi	s8,s8,-1
ffffffffc02020d0:	fee79de3          	bne	a5,a4,ffffffffc02020ca <vprintfmt+0xae>
ffffffffc02020d4:	bfb5                	j	ffffffffc0202050 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02020d6:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02020da:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc02020dc:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02020e0:	fd06071b          	addiw	a4,a2,-48
ffffffffc02020e4:	24e56a63          	bltu	a0,a4,ffffffffc0202338 <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc02020e8:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02020ea:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc02020ec:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc02020f0:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02020f4:	0197073b          	addw	a4,a4,s9
ffffffffc02020f8:	0017171b          	slliw	a4,a4,0x1
ffffffffc02020fc:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc02020fe:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0202102:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0202104:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0202108:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc020210c:	feb570e3          	bgeu	a0,a1,ffffffffc02020ec <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0202110:	f60d54e3          	bgez	s10,ffffffffc0202078 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0202114:	8d66                	mv	s10,s9
ffffffffc0202116:	5cfd                	li	s9,-1
ffffffffc0202118:	b785                	j	ffffffffc0202078 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020211a:	8db6                	mv	s11,a3
ffffffffc020211c:	8462                	mv	s0,s8
ffffffffc020211e:	bfa9                	j	ffffffffc0202078 <vprintfmt+0x5c>
ffffffffc0202120:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0202122:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0202124:	bf91                	j	ffffffffc0202078 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0202126:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0202128:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020212c:	00f74463          	blt	a4,a5,ffffffffc0202134 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0202130:	1a078763          	beqz	a5,ffffffffc02022de <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0202134:	000a3603          	ld	a2,0(s4)
ffffffffc0202138:	46c1                	li	a3,16
ffffffffc020213a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020213c:	000d879b          	sext.w	a5,s11
ffffffffc0202140:	876a                	mv	a4,s10
ffffffffc0202142:	85ca                	mv	a1,s2
ffffffffc0202144:	8526                	mv	a0,s1
ffffffffc0202146:	e71ff0ef          	jal	ffffffffc0201fb6 <printnum>
            break;
ffffffffc020214a:	b719                	j	ffffffffc0202050 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020214c:	000a2503          	lw	a0,0(s4)
ffffffffc0202150:	85ca                	mv	a1,s2
ffffffffc0202152:	0a21                	addi	s4,s4,8
ffffffffc0202154:	9482                	jalr	s1
            break;
ffffffffc0202156:	bded                	j	ffffffffc0202050 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0202158:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020215a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020215e:	00f74463          	blt	a4,a5,ffffffffc0202166 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0202162:	16078963          	beqz	a5,ffffffffc02022d4 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0202166:	000a3603          	ld	a2,0(s4)
ffffffffc020216a:	46a9                	li	a3,10
ffffffffc020216c:	8a2e                	mv	s4,a1
ffffffffc020216e:	b7f9                	j	ffffffffc020213c <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0202170:	85ca                	mv	a1,s2
ffffffffc0202172:	03000513          	li	a0,48
ffffffffc0202176:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc0202178:	85ca                	mv	a1,s2
ffffffffc020217a:	07800513          	li	a0,120
ffffffffc020217e:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0202180:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0202184:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0202186:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0202188:	bf55                	j	ffffffffc020213c <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc020218a:	85ca                	mv	a1,s2
ffffffffc020218c:	02500513          	li	a0,37
ffffffffc0202190:	9482                	jalr	s1
            break;
ffffffffc0202192:	bd7d                	j	ffffffffc0202050 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0202194:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0202198:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc020219a:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc020219c:	bf95                	j	ffffffffc0202110 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc020219e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02021a0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02021a4:	00f74463          	blt	a4,a5,ffffffffc02021ac <vprintfmt+0x190>
    else if (lflag) {
ffffffffc02021a8:	12078163          	beqz	a5,ffffffffc02022ca <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc02021ac:	000a3603          	ld	a2,0(s4)
ffffffffc02021b0:	46a1                	li	a3,8
ffffffffc02021b2:	8a2e                	mv	s4,a1
ffffffffc02021b4:	b761                	j	ffffffffc020213c <vprintfmt+0x120>
            if (width < 0)
ffffffffc02021b6:	876a                	mv	a4,s10
ffffffffc02021b8:	000d5363          	bgez	s10,ffffffffc02021be <vprintfmt+0x1a2>
ffffffffc02021bc:	4701                	li	a4,0
ffffffffc02021be:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02021c2:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02021c4:	bd55                	j	ffffffffc0202078 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc02021c6:	000d841b          	sext.w	s0,s11
ffffffffc02021ca:	fd340793          	addi	a5,s0,-45
ffffffffc02021ce:	00f037b3          	snez	a5,a5
ffffffffc02021d2:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02021d6:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc02021da:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02021dc:	008a0793          	addi	a5,s4,8
ffffffffc02021e0:	e43e                	sd	a5,8(sp)
ffffffffc02021e2:	100d8c63          	beqz	s11,ffffffffc02022fa <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02021e6:	12071363          	bnez	a4,ffffffffc020230c <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02021ea:	000dc783          	lbu	a5,0(s11)
ffffffffc02021ee:	0007851b          	sext.w	a0,a5
ffffffffc02021f2:	c78d                	beqz	a5,ffffffffc020221c <vprintfmt+0x200>
ffffffffc02021f4:	0d85                	addi	s11,s11,1
ffffffffc02021f6:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02021f8:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02021fc:	000cc563          	bltz	s9,ffffffffc0202206 <vprintfmt+0x1ea>
ffffffffc0202200:	3cfd                	addiw	s9,s9,-1
ffffffffc0202202:	008c8d63          	beq	s9,s0,ffffffffc020221c <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0202206:	020b9663          	bnez	s7,ffffffffc0202232 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc020220a:	85ca                	mv	a1,s2
ffffffffc020220c:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020220e:	000dc783          	lbu	a5,0(s11)
ffffffffc0202212:	0d85                	addi	s11,s11,1
ffffffffc0202214:	3d7d                	addiw	s10,s10,-1
ffffffffc0202216:	0007851b          	sext.w	a0,a5
ffffffffc020221a:	f3ed                	bnez	a5,ffffffffc02021fc <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc020221c:	01a05963          	blez	s10,ffffffffc020222e <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0202220:	85ca                	mv	a1,s2
ffffffffc0202222:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0202226:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0202228:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc020222a:	fe0d1be3          	bnez	s10,ffffffffc0202220 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020222e:	6a22                	ld	s4,8(sp)
ffffffffc0202230:	b505                	j	ffffffffc0202050 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0202232:	3781                	addiw	a5,a5,-32
ffffffffc0202234:	fcfa7be3          	bgeu	s4,a5,ffffffffc020220a <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0202238:	03f00513          	li	a0,63
ffffffffc020223c:	85ca                	mv	a1,s2
ffffffffc020223e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0202240:	000dc783          	lbu	a5,0(s11)
ffffffffc0202244:	0d85                	addi	s11,s11,1
ffffffffc0202246:	3d7d                	addiw	s10,s10,-1
ffffffffc0202248:	0007851b          	sext.w	a0,a5
ffffffffc020224c:	dbe1                	beqz	a5,ffffffffc020221c <vprintfmt+0x200>
ffffffffc020224e:	fa0cd9e3          	bgez	s9,ffffffffc0202200 <vprintfmt+0x1e4>
ffffffffc0202252:	b7c5                	j	ffffffffc0202232 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0202254:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0202258:	4619                	li	a2,6
            err = va_arg(ap, int);
ffffffffc020225a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020225c:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0202260:	8fb9                	xor	a5,a5,a4
ffffffffc0202262:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0202266:	02d64563          	blt	a2,a3,ffffffffc0202290 <vprintfmt+0x274>
ffffffffc020226a:	00002797          	auipc	a5,0x2
ffffffffc020226e:	c3e78793          	addi	a5,a5,-962 # ffffffffc0203ea8 <error_string>
ffffffffc0202272:	00369713          	slli	a4,a3,0x3
ffffffffc0202276:	97ba                	add	a5,a5,a4
ffffffffc0202278:	639c                	ld	a5,0(a5)
ffffffffc020227a:	cb99                	beqz	a5,ffffffffc0202290 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc020227c:	86be                	mv	a3,a5
ffffffffc020227e:	00002617          	auipc	a2,0x2
ffffffffc0202282:	99a60613          	addi	a2,a2,-1638 # ffffffffc0203c18 <etext+0x17da>
ffffffffc0202286:	85ca                	mv	a1,s2
ffffffffc0202288:	8526                	mv	a0,s1
ffffffffc020228a:	0d8000ef          	jal	ffffffffc0202362 <printfmt>
ffffffffc020228e:	b3c9                	j	ffffffffc0202050 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0202290:	00002617          	auipc	a2,0x2
ffffffffc0202294:	97860613          	addi	a2,a2,-1672 # ffffffffc0203c08 <etext+0x17ca>
ffffffffc0202298:	85ca                	mv	a1,s2
ffffffffc020229a:	8526                	mv	a0,s1
ffffffffc020229c:	0c6000ef          	jal	ffffffffc0202362 <printfmt>
ffffffffc02022a0:	bb45                	j	ffffffffc0202050 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02022a2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02022a4:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02022a8:	00f74363          	blt	a4,a5,ffffffffc02022ae <vprintfmt+0x292>
    else if (lflag) {
ffffffffc02022ac:	cf81                	beqz	a5,ffffffffc02022c4 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc02022ae:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02022b2:	02044b63          	bltz	s0,ffffffffc02022e8 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc02022b6:	8622                	mv	a2,s0
ffffffffc02022b8:	8a5e                	mv	s4,s7
ffffffffc02022ba:	46a9                	li	a3,10
ffffffffc02022bc:	b541                	j	ffffffffc020213c <vprintfmt+0x120>
            lflag ++;
ffffffffc02022be:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02022c0:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02022c2:	bb5d                	j	ffffffffc0202078 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc02022c4:	000a2403          	lw	s0,0(s4)
ffffffffc02022c8:	b7ed                	j	ffffffffc02022b2 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc02022ca:	000a6603          	lwu	a2,0(s4)
ffffffffc02022ce:	46a1                	li	a3,8
ffffffffc02022d0:	8a2e                	mv	s4,a1
ffffffffc02022d2:	b5ad                	j	ffffffffc020213c <vprintfmt+0x120>
ffffffffc02022d4:	000a6603          	lwu	a2,0(s4)
ffffffffc02022d8:	46a9                	li	a3,10
ffffffffc02022da:	8a2e                	mv	s4,a1
ffffffffc02022dc:	b585                	j	ffffffffc020213c <vprintfmt+0x120>
ffffffffc02022de:	000a6603          	lwu	a2,0(s4)
ffffffffc02022e2:	46c1                	li	a3,16
ffffffffc02022e4:	8a2e                	mv	s4,a1
ffffffffc02022e6:	bd99                	j	ffffffffc020213c <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc02022e8:	85ca                	mv	a1,s2
ffffffffc02022ea:	02d00513          	li	a0,45
ffffffffc02022ee:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc02022f0:	40800633          	neg	a2,s0
ffffffffc02022f4:	8a5e                	mv	s4,s7
ffffffffc02022f6:	46a9                	li	a3,10
ffffffffc02022f8:	b591                	j	ffffffffc020213c <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc02022fa:	e329                	bnez	a4,ffffffffc020233c <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02022fc:	02800793          	li	a5,40
ffffffffc0202300:	853e                	mv	a0,a5
ffffffffc0202302:	00002d97          	auipc	s11,0x2
ffffffffc0202306:	8ffd8d93          	addi	s11,s11,-1793 # ffffffffc0203c01 <etext+0x17c3>
ffffffffc020230a:	b5f5                	j	ffffffffc02021f6 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020230c:	85e6                	mv	a1,s9
ffffffffc020230e:	856e                	mv	a0,s11
ffffffffc0202310:	0a4000ef          	jal	ffffffffc02023b4 <strnlen>
ffffffffc0202314:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0202318:	01a05863          	blez	s10,ffffffffc0202328 <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc020231c:	85ca                	mv	a1,s2
ffffffffc020231e:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0202320:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0202322:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0202324:	fe0d1ce3          	bnez	s10,ffffffffc020231c <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0202328:	000dc783          	lbu	a5,0(s11)
ffffffffc020232c:	0007851b          	sext.w	a0,a5
ffffffffc0202330:	ec0792e3          	bnez	a5,ffffffffc02021f4 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0202334:	6a22                	ld	s4,8(sp)
ffffffffc0202336:	bb29                	j	ffffffffc0202050 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0202338:	8462                	mv	s0,s8
ffffffffc020233a:	bbd9                	j	ffffffffc0202110 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020233c:	85e6                	mv	a1,s9
ffffffffc020233e:	00002517          	auipc	a0,0x2
ffffffffc0202342:	8c250513          	addi	a0,a0,-1854 # ffffffffc0203c00 <etext+0x17c2>
ffffffffc0202346:	06e000ef          	jal	ffffffffc02023b4 <strnlen>
ffffffffc020234a:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020234e:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0202352:	00002d97          	auipc	s11,0x2
ffffffffc0202356:	8aed8d93          	addi	s11,s11,-1874 # ffffffffc0203c00 <etext+0x17c2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020235a:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020235c:	fda040e3          	bgtz	s10,ffffffffc020231c <vprintfmt+0x300>
ffffffffc0202360:	bd51                	j	ffffffffc02021f4 <vprintfmt+0x1d8>

ffffffffc0202362 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0202362:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0202364:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0202368:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020236a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020236c:	ec06                	sd	ra,24(sp)
ffffffffc020236e:	f83a                	sd	a4,48(sp)
ffffffffc0202370:	fc3e                	sd	a5,56(sp)
ffffffffc0202372:	e0c2                	sd	a6,64(sp)
ffffffffc0202374:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0202376:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0202378:	ca5ff0ef          	jal	ffffffffc020201c <vprintfmt>
}
ffffffffc020237c:	60e2                	ld	ra,24(sp)
ffffffffc020237e:	6161                	addi	sp,sp,80
ffffffffc0202380:	8082                	ret

ffffffffc0202382 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0202382:	00005717          	auipc	a4,0x5
ffffffffc0202386:	c8e73703          	ld	a4,-882(a4) # ffffffffc0207010 <SBI_CONSOLE_PUTCHAR>
ffffffffc020238a:	4781                	li	a5,0
ffffffffc020238c:	88ba                	mv	a7,a4
ffffffffc020238e:	852a                	mv	a0,a0
ffffffffc0202390:	85be                	mv	a1,a5
ffffffffc0202392:	863e                	mv	a2,a5
ffffffffc0202394:	00000073          	ecall
ffffffffc0202398:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020239a:	8082                	ret

ffffffffc020239c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020239c:	00054783          	lbu	a5,0(a0)
ffffffffc02023a0:	cb81                	beqz	a5,ffffffffc02023b0 <strlen+0x14>
    size_t cnt = 0;
ffffffffc02023a2:	4781                	li	a5,0
        cnt ++;
ffffffffc02023a4:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02023a6:	00f50733          	add	a4,a0,a5
ffffffffc02023aa:	00074703          	lbu	a4,0(a4)
ffffffffc02023ae:	fb7d                	bnez	a4,ffffffffc02023a4 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02023b0:	853e                	mv	a0,a5
ffffffffc02023b2:	8082                	ret

ffffffffc02023b4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02023b4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02023b6:	e589                	bnez	a1,ffffffffc02023c0 <strnlen+0xc>
ffffffffc02023b8:	a811                	j	ffffffffc02023cc <strnlen+0x18>
        cnt ++;
ffffffffc02023ba:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02023bc:	00f58863          	beq	a1,a5,ffffffffc02023cc <strnlen+0x18>
ffffffffc02023c0:	00f50733          	add	a4,a0,a5
ffffffffc02023c4:	00074703          	lbu	a4,0(a4)
ffffffffc02023c8:	fb6d                	bnez	a4,ffffffffc02023ba <strnlen+0x6>
ffffffffc02023ca:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02023cc:	852e                	mv	a0,a1
ffffffffc02023ce:	8082                	ret

ffffffffc02023d0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02023d0:	00054783          	lbu	a5,0(a0)
ffffffffc02023d4:	e791                	bnez	a5,ffffffffc02023e0 <strcmp+0x10>
ffffffffc02023d6:	a01d                	j	ffffffffc02023fc <strcmp+0x2c>
ffffffffc02023d8:	00054783          	lbu	a5,0(a0)
ffffffffc02023dc:	cb99                	beqz	a5,ffffffffc02023f2 <strcmp+0x22>
ffffffffc02023de:	0585                	addi	a1,a1,1
ffffffffc02023e0:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02023e4:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02023e6:	fef709e3          	beq	a4,a5,ffffffffc02023d8 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02023ea:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02023ee:	9d19                	subw	a0,a0,a4
ffffffffc02023f0:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02023f2:	0015c703          	lbu	a4,1(a1)
ffffffffc02023f6:	4501                	li	a0,0
}
ffffffffc02023f8:	9d19                	subw	a0,a0,a4
ffffffffc02023fa:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02023fc:	0005c703          	lbu	a4,0(a1)
ffffffffc0202400:	4501                	li	a0,0
ffffffffc0202402:	b7f5                	j	ffffffffc02023ee <strcmp+0x1e>

ffffffffc0202404 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0202404:	ce01                	beqz	a2,ffffffffc020241c <strncmp+0x18>
ffffffffc0202406:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020240a:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020240c:	cb91                	beqz	a5,ffffffffc0202420 <strncmp+0x1c>
ffffffffc020240e:	0005c703          	lbu	a4,0(a1)
ffffffffc0202412:	00f71763          	bne	a4,a5,ffffffffc0202420 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0202416:	0505                	addi	a0,a0,1
ffffffffc0202418:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020241a:	f675                	bnez	a2,ffffffffc0202406 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020241c:	4501                	li	a0,0
ffffffffc020241e:	8082                	ret
ffffffffc0202420:	00054503          	lbu	a0,0(a0)
ffffffffc0202424:	0005c783          	lbu	a5,0(a1)
ffffffffc0202428:	9d1d                	subw	a0,a0,a5
}
ffffffffc020242a:	8082                	ret

ffffffffc020242c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020242c:	ca01                	beqz	a2,ffffffffc020243c <memset+0x10>
ffffffffc020242e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0202430:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0202432:	0785                	addi	a5,a5,1
ffffffffc0202434:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0202438:	fef61de3          	bne	a2,a5,ffffffffc0202432 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020243c:	8082                	ret
