
# 一、修改qemu指令，直接使用绝对路径
``` Makefile

# ifndef QEMU
# QEMU := qemu-system-riscv64
# endif

QEMU := /home/op_user/qemu-4.1.1/riscv64-softmmu/qemu-system-riscv64
```

# 二、理解三个终端执行调试的逻辑

## 首先，我们关注到使用了两个GDB，带来了困惑，为了理解这两个GDB分工，作用上的不同，询问了大模型
`为什么需要两个gdb,它们各自负责什么` <br>
### 两个 GDB 的具体角色（分工明确，不可替代）
#### 1. GDB 会话 1：主机原生 GDB（x86 架构，终端 2）
调试对象：运行在你的 x86 笔记本上的 QEMU 进程（本质是一个 x86 架构的 C 程序）；
核心作用：
跟踪 QEMU 的源码执行：比如 “QEMU 如何解析 ucore 的访存指令”“如何模拟 TLB 查询”“如何遍历页表完成地址转换”；
控制 QEMU 的运行：单步执行 QEMU 的 C 代码、查看 QEMU 的变量（如 TLB 缓存、页表项）、设置断点过滤目标地址；
为什么必须用 x86 GDB：QEMU 是编译为 x86 架构的程序，只有主机原生 GDB 能解析它的指令、符号表、内存布局，RISC-V GDB 完全不兼容。
#### 2. GDB 会话 2：RISC-V 交叉 GDB（riscv64-unknown-elf-gdb，终端 3）
调试对象：运行在 QEMU 模拟的 RISC-V 硬件上的 ucore 内核（本质是 RISC-V 架构的二进制程序）；
核心作用：
控制 ucore 的执行：让 ucore 停在特定的访存指令（如lw/sw）、查看 ucore 的寄存器（如 SATP、虚拟地址）、确认访存的目标地址；
触发 QEMU 的调试断点：当 ucore 执行访存指令时，QEMU 会处理该指令，此时终端 1 的 QEMU GDB 会命中断点，实现 “ucore 指令→QEMU 模拟” 的联动；<br>

##
根据大模型的回答，大致了解了两个gdb分别的作用，一个是对qemu这个程序进行调试，一个是对ucore内核进行调试

## 接下来，再大致了解完这两个GDB的分工后，对于这三个终端的关系有了一个模糊的认识，继续询问大模型
`相当于是第一个终端用qemu运行ucore让后面两个GDB能够打断点观察，第二个终端监视运行qemu，第三个终端监视ucore？`<br>
###
| 终端序号 | 核心角色                          | 执行的关键操作                          | 核心目的                                                                 |
|----------|-----------------------------------|-----------------------------------------|--------------------------------------------------------------------------|
| 终端1    | QEMU进程的“运行载体”（承载ucore） | 执行 `make debug` 启动调试版QEMU        | 启动QEMU并让它**暂停等待调试**（-S参数），监听1234端口，作为ucore的运行环境 |
| 终端2    | QEMU源码的“调试器”（x86 GDB）     | 1. `pgrep` 找QEMU的PID<br>2. `sudo gdb attach PID` 附加进程<br>3. 设置QEMU源码断点（如TLB/页表函数）<br>4. `continue` 让QEMU恢复运行 | 主动控制/调试QEMU的C代码，观察它如何模拟TLB查询、页表翻译等硬件行为       |
| 终端3    | ucore内核的“调试器”（RISC-V GDB） | 执行 `make gdb` 连接QEMU的1234端口      | 主动控制/调试ucore内核，让ucore停在指定访存指令，**触发终端2的QEMU断点**   |


### 联动流程示例（最核心的“套娃”逻辑）
1. 终端1：`make debug` → QEMU启动，暂停，监听1234；  
2. 终端2：附加QEMU进程 → 设置断点（`b riscv_cpu_get_phys_addr if addr==0x80200000`） → `continue`；  
3. 终端3：`make gdb` 连接 → `b kern_init`（内核入口） → `c` → ucore执行到kern_init的访存指令；  
4. 终端2：QEMU触发断点，暂停在TLB查询函数 → 你单步执行QEMU代码，看它如何把0x80200000翻译成物理地址；  
5. 终端2：`c` 让QEMU继续 → 终端3的ucore继续执行下一条指令。

##
至此，了解了三个终端相互配合的逻辑，让ucore进行访存，再观察qemu，这需要我们能够分别调试这两大部分。


# 三、开始调试
终端一启动qemu加载ucore，并会暂停
```bash
op_user@LAPTOP-00GLMMBM:~/projects/labcode/lab2$ make debug
+ cc kern/mm/best_fit_pmm.c
+ ld bin/kernel
riscv64-unknown-elf-objcopy bin/kernel --strip-all -O binary bin/ucore.img
```
终端二：
首先得到qemu进程的pid
```bash
op_user@LAPTOP-00GLMMBM:~/projects/labcode/lab2$ pgrep -f qemu-system-riscv64
20862
```
运行系统的gbd，调试x86程序，并链接到qemu进程
```bash
sudo gdb

(gdb) attach 20862
Attaching to process 20862
[New LWP 20864]
[New LWP 20863]
warning: could not find '.gnu_debugaltlink' file for /lib/x86_64-linux-gnu/libglib-2.0.so.0
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
0x00007392ec51ba30 in __GI_ppoll (fds=0x5a7bf61d2ab0, nfds=7, timeout=<optimized out>, sigmask=0x0) at ../sysdeps/unix/sysv/linux/ppoll.c:42
warning: 42     ../sysdeps/unix/sysv/linux/ppoll.c: No such file or directory


# 1. 处理SIGPIPE信号（避免调试被信号中断，必做）
handle SIGPIPE nostop noprint
```
询问大模型查询TLB函数，遍历页表等函数，打上断点
```bash
# 3. 设置核心断点（跟踪TLB查询和页表遍历，必做）
# 断点1：TLB查询函数
(gdb) b accel/tcg/cputlb.c:get_page_addr_code
Breakpoint 1 at 0x55bb9be82352: file /home/op_user/qemu-4.1.1/accel/tcg/cputlb.c, line 1025.
# 断点2：TLB填充
(gdb) b accel/tcg/cputlb.c:tlb_fill
Breakpoint 2 at 0x55bb9be81d15: file /home/op_user/qemu-4.1.1/accel/tcg/cputlb.c, line 871.
# 断点3：页表遍历函数
(gdb) b target/riscv/cpu_helper.c:get_physical_address
Breakpoint 1 at 0x60276cea0e13: file /home/op_user/qemu-4.1.1/target/riscv/cpu_helper.c, line 158.

```

终端三：
使用riscv-gdb连接ucore进行调试
在实验二里，当时通过gdb得到了开启分页后附近的一些代码，开启分页后的第一条指令。
```bash
(gdb) x/5i 0xffffffffc020003c
   0xffffffffc020003c <kern_entry+60>:  lui     sp,0xc0205
   0xffffffffc0200040 <kern_entry+64>:  lui     t0,0xc0200
   0xffffffffc0200044 <kern_entry+68>:  addi    t0,t0,214
   0xffffffffc0200048 <kern_entry+72>:  jr      t0
```
在0x80200038打上断点，开启虚拟环境，单步运行


但是像现在这样打在终端2中打断点，只要每次取指都要卡住，终端三也没法一下子跳到我现在的断点处，非常痛苦。
我决定在没有执行到0xffffffffc020003c前先不要在终端2打上断点。在我要进行观察时进行。
尝试后这样终端三又会将终端2卡住，现在只能依照大模型的方法在终端2设置断点时加入过滤条件，只在特定地址触发。
```bash
b accel/tcg/cputlb.c:get_page_addr_code if addr==0xffffffffc020003c
b accel/tcg/cputlb.c:tlb_fill if addr==0xffffffffc020003c
b target/riscv/cpu_helper.c:get_physical_address if addr==0xffffffffc020003c
```




但是这样仍然会卡住,我不开终端2，直接调试ucore，执行到`0x80200038:  sfence.vma`后再si同样会卡住，说明这不是两个终端之间的冲突。打印此时pc，他应该跳转到高地址但是仍为
0x802003c。这肯定不对，再次询问大模型，GDB调试时不会预加载指令，所以此时我们只能手动将其转至高虚拟地址才能让他正常读取指令
```bash
(gdb) set $pc = 0xffffffffc020003c
```

再次进行调试
```bash
Thread 2 "qemu-system-ris" hit Breakpoint 1, get_page_addr_code (env=0x5af0cb3af040, addr=18446744072637907004) at /home/op_user/qemu-4.1.1/accel/tcg/cputlb.c:1025
1025        uintptr_t mmu_idx = cpu_mmu_index(env, true);
(gdb) b target/riscv/cpu_helper.c:get_physical_address
Breakpoint 3 at 0x5af0a1ebce13: file /home/op_user/qemu-4.1.1/target/riscv/cpu_helper.c, line 158.
(gdb) c
Continuing.

Thread 2 "qemu-system-ris" hit Breakpoint 2, tlb_fill (cpu=0x5af0cb3a6630, addr=18446744072637907004, size=0, access_type=MMU_INST_FETCH, mmu_idx=1, retaddr=0)
    at /home/op_user/qemu-4.1.1/accel/tcg/cputlb.c:871
871         CPUClass *cc = CPU_GET_CLASS(cpu);
(gdb) c
Continuing.

Thread 2 "qemu-system-ris" hit Breakpoint 3, get_physical_address (env=0x5af0cb3af040, physical=0x79b179d7c720, prot=0x79b179d7c714, addr=18446744072637907004, 
    access_type=2, mmu_idx=1) at /home/op_user/qemu-4.1.1/target/riscv/cpu_helper.c:158
158     {
```
这是第一条访问虚拟地址的指令，tlb肯定不会命中，要查页表并填充tlb，断点的触发符合这一逻辑

我们打开accel/tcg/cputlb.c,观察其调用路径。


## get_page_addr_code
入口：算 mmu_idx/index，取 entry = tlb_entry(...)。
命中：tlb_hit(entry->addr_code, addr) 为真，跳过填充；检查标志：
addr_code & (TLB_RECHECK|TLB_MMIO) 为真 → 返回 -1，走慢路径（每条指令重查，或按 IO 处理）。
否则用 addr+entry->addend 得到 host/RAM 地址，返回给译码器直接用。<br>

未命中：tlb_hit 为假：
先试 victim TLB VICTIM_TLB_HIT；仍 miss → 调 tlb_fill(...)，它会回调到目标架构的 cc->tlb_fill（RISC‑V 为 riscv_cpu_tlb_fill），后者调用 get_physical_address 走页表，成功后 tlb_set_page 写回软件 TLB。
重新取 index/entry，assert(tlb_hit(...))；然后与命中路径相同：检查 RECHECK/MMIO，或组合 addend 返回。


## get_physical_address查找页表
### 直通返回（未开 MMU/M 态）
```c++
if (mode == PRV_M || satp_mode == MBARE) {
    *physical = addr;                          // 虚拟地址原样当物理地址
    *prot = PAGE_READ | PAGE_WRITE | PAGE_EXEC; // 权限全开
    return TRANSLATE_SUCCESS;                  // 不查页表直接成功
}
```
### 从 satp 决定根和参数
```c++
base   = satp.PPN << PGSHIFT;   // 根页表物理基址
levels = 3; ptidxbits = 9; ptesize = 8; // 三级页表，9 位索引，PTE 8 字节
```
### 虚拟地址合法性检查
```c++
va_bits = PGSHIFT + levels * ptidxbits;
masked_msbs = (addr >> (va_bits - 1)) & mask;
if (masked_msbs != 0 && masked_msbs != mask) return TRANSLATE_FAIL; // VA 未正确符号扩展
```

### 逐级遍历页表（for 循环核心）
```c++
idx      = (addr >> (PGSHIFT + ptshift)) & ((1 << ptidxbits) - 1);
pte_addr = base + idx * ptesize;        // 当前级 PTE 的物理地址
pte      = ldq_phys(cs->as, pte_addr);  // 读出 PTE
```

### 中间节点下钻 / 叶子判定
```c++
if (!(pte & (PTE_R | PTE_W | PTE_X))) {
    base = ppn << PGSHIFT;  // 无 R/W/X：中间节点，更新 base 下钻下一层
    continue;
}
```

### 权限/合法性检查
```c++
if (!(pte & PTE_V)) return TRANSLATE_FAIL;                    // 无效 PTE
if (ppn & ((1ULL << ptshift) - 1)) return TRANSLATE_FAIL;     // PPN 未对齐
if (access_type == MMU_INST_FETCH && !(pte & PTE_X)) return TRANSLATE_FAIL; // 取指无 X 权限
if (access_type == MMU_DATA_STORE && !(pte & PTE_W)) return TRANSLATE_FAIL; // 写无 W 权限
if (access_type == MMU_DATA_LOAD && !((pte & PTE_R) || ((pte & PTE_X) && mxr))) return TRANSLATE_FAIL; // 读无权限
```
### 需要时设置 A/D 位
```c++
updated_pte = pte | PTE_A | (store ? PTE_D : 0); // 首次访问加 A，写或已脏加 D
if (updated_pte != pte) {
    // 若在 RAM 中则 CAS 写回；被其他线程改动则重走；IO/ROM 则失败
}
```
### 命中叶子：拼物理地址、设置 TLB 权限
```c++
vpn = addr >> PGSHIFT;                         // 虚拟页号
*physical = (ppn | (vpn & ((1L << ptshift) - 1))) << PGSHIFT;
// superpage 拼低位 VPN，再左移补回页内偏移，得物理页基址
*prot = 0;                                     // 清权限掩码
if ((pte & PTE_R) || ((pte & PTE_X) && mxr)) *prot |= PAGE_READ;   // R 或 MXR+X → 读
if (pte & PTE_X)                              *prot |= PAGE_EXEC;   // X → 执行
if ((pte & PTE_W) && (store || (pte & PTE_D))) *prot |= PAGE_WRITE; // W 且写/已脏 → 写
return TRANSLATE_SUCCESS;                     // 翻译成功，TLB 可据此填充
```


接下来，我们删除上述断点，重新设置后续指令的断点，观察TLB是否能够命中
```bash
(gdb) b accel/tcg/cputlb.c:get_page_addr_code if addr==0xffffffffc0200044
(gdb) b accel/tcg/cputlb.c:tlb_fill if addr==0xffffffffc0200044
```

但是此断点并未再次触发，询问大模型：<br>
命中是会查 TLB，但命中路径是“内联的”，不会再调用这个 C 函数：

get_page_addr_code 主要在翻译 TB 时用来做取指翻译，或 miss/慢路径时才走。
一旦这一页 miss 过、TLB+TB 填好了，执行期的 TCG 代码直接在生成的 TB 里用内联的 TLB 命中检查，命中就继续，不会再回到 get_page_addr_code 这种 C 辅助函数。所以你的断点不会在同页命中时再触发。