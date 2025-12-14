## LAB5分支任务：gdb 调试系统调用以及返回

### 1.双 gdb 调试系统调用核心流程

（1）核心目标：通过双重 GDB（调试 ucore 内核 + 调试 QEMU 模拟器）观察：

- 用户态程序触发系统调用（ecall 指令）
- QEMU 如何模拟硬件处理 ecall，完成特权级切换（U 态→S 态）
- 内核处理系统调用后，通过 sret 指令返回用户态
- QEMU 如何模拟 sret 指令的特权级切换逻辑

（2）准备工作：


  理解关键文件和调试逻辑：
  
   - 用户程序：lab5 的用户程序“链接进内核”（如 exit.c），编译后生成 `obj/__user_exit.out`（含符号表）。  
   - 系统调用触发点：`user/libs/syscall.c` 中的 `syscall` 函数，用内联汇编的 `ecall` 指令触发系统调用。  
   - 双重 GDB 分工：  
     * GDB1（终端 B）：调试 ucore 内核 + 用户程序（跟踪 U 态→S 态→U 态代码流程）。  
     * GDB2（终端 C）：调试 QEMU 模拟器（跟踪 QEMU 如何模拟 ecall/sret 指令）。

下面进行具体调试流程：


### 2.终端 A：启动 QEMU，挂起等待 gdb

<!-- - 输入： -->
```sh
make debug
```
<!-- - 输出：QEMU 以 `-s -S` 启动（OpenSBI/ucore 启动信息略），此时挂起等待 gdb 连接。 -->

### 3.终端 C：附加 QEMU，布置 QEMU 侧断点（翻译/执行层）

1. 先找到 QEMU 的 PID 并附加：
   ```
   pgrep -f qemu-system-riscv64   # 查看 PID
   1342
   sudo gdb
   (gdb) attach 1342
   ```
   （显示附加成功，并列出线程，输出较长。）

2. 关闭 SIGPIPE 打断，清理旧断点并设置 ecall/sret 相关断点：
   - 关闭 SIGPIPE 打断。输入：
     ```gdb
     (gdb) handle SIGPIPE nostop noprint
     ```
     输出：
     ```
     Signal        Stop      Print   Pass to program       Description
     SIGPIPE       No        No      Yes          Broken pipe
     ```
   - 清除断点，防止之间的尝试干扰。输入：
     ```gdb
     (gdb) delete
     ```
     <!-- 输出：`Delete all breakpoints? (y or n)`（如无旧断点可略过确认）。 -->
   - 添加trans_ecall断点。输入：
     ```gdb
     (gdb) b trans_ecall
     ```
     输出：
     ```
     Breakpoint 1 at 0x5608ce91f87b: file /home/op_user/qemu-4.1.1/target/riscv/insn_trans/trans_privileged.inc.c, line 24.
     ```
   - 添加trans_sret断点。输入：
     ```gdb
     (gdb) b trans_sret
     ```
     输出：
     ```
     Breakpoint 2 at 0x5608ce91f918: file /home/op_user/qemu-4.1.1/target/riscv/insn_trans/trans_privileged.inc.c, line 46.
     ```
   - 添加helper_sret断点。输入：
     ```gdb
     (gdb) b helper_sret
     ```
     输出：
     ```
     Breakpoint 3 at 0x5608ce922256: file /home/op_user/qemu-4.1.1/target/riscv/op_helper.c, line 76.
     ```
   - 终端C放行。输入：
     ```gdb
     (gdb) c
     ```
     输出：（等待 guest 触发）。
     ```
     Continuing.
     ```

  其中，`trans_ecall`、`trans_sret` 断点观察 TCG 翻译阶段，`helper_sret` 观察 sret 执行阶段。

### 4.终端 B：连接 guest gdb，加载符号，下用户/内核断点

1. 启动 riscv gdb 并加载用户符号：
   ```gdb
   make gdb
   (gdb) add-symbol-file obj/__user_exit.out
   add symbol table from file "obj/__user_exit.out"
   (y or n) y
   Reading symbols from obj/__user_exit.out...
   (gdb) set remotetimeout unlimited
   ```
2. 下断点：用户态 syscall、内核 trap 入口和返回：
   ```gdb
   (gdb) b user/libs/syscall.c:19
   Breakpoint 1 at 0x8000f4: file user/libs/syscall.c, line 19.
   (gdb) b __alltraps
   Breakpoint 2 at 0xffffffffc0200e6c: file kern/trap/trapentry.S, line 123.
   (gdb) b __trapret
   Breakpoint 3 at 0xffffffffc0200edc: file kern/trap/trapentry.S, line 131.
   (gdb) c
   Continuing.

   Breakpoint 1, syscall (num=num@entry=30)
       at user/libs/syscall.c:19
   19          asm volatile (
   ```
   说明：用户符号加载成功，已停在用户态 syscall 内联汇编。

### 5.单步到 ecall，触发 QEMU 侧 ecall 翻译断点

- 在终端 B，查看当前位置：
    ```gdb
  (gdb) x/7i $pc
  => 0x8000f6 <syscall+34>:
      ld  a1,40(sp)
     0x8000f8 <syscall+36>:
      ld  a2,48(sp)
     0x8000fa <syscall+38>:
      ld  a3,56(sp)
     0x8000fc <syscall+40>:
      ld  a4,64(sp)
     0x8000fe <syscall+42>:
      ld  a5,72(sp)
     0x800100 <syscall+44>:       ecall
     0x800104 <syscall+48>:
      sd  a0,28(sp)
    ```
    然后持续单步si直到ecall前：

    ```
  (gdb) x/7i $pc
  => 0x800100 <syscall+44>:       ecall
     0x800104 <syscall+48>:       sd      a0,28(sp)
     0x800108 <syscall+52>:       lw      a0,28(sp)
     0x80010a <syscall+54>:       addi    sp,sp,144
     0x80010c <syscall+56>:       ret
     0x80010e <sys_exit>:         mv      a1,a0
     0x800110 <sys_exit+2>:       li      a0,1
    ```
  此时参数已正常装入 a1–a5，PC 停在 ecall 前一条。

- 继续si单步执行，终端 C 显示命中了 trans_ecall断点：
    ```gdb
  (gdb) c
  Continuing.
  [Switching to Thread 0x7c1405d7d6c0 (LWP 1045)]

  Thread 2 "qemu-system-ris" hit Breakpoint 1, trans_ecall (ctx=0x7c1405d7c7d0,
  a=0x7c1405d7c6d0)
  at /home/op_user/qemu-4.1.1/target/riscv/insn_trans/trans_privileged.inc.c:24
  24 generate_exception(ctx, RISCV_EXCP_U_ECALL);
    ```
    我们查看此时的截断信息：

    ```
  (gdb) i r sp
  sp             0x7c1405d7c6a0      0x7c1405d7c6a0
    ```
  此时说明TCG 翻译阶段捕获 ecall，生成 U 级异常并退出当前 TB。然后我们在终端C放行。

### 6.进入内核 trap，快进到 sret 前

- 终端C放行之后，终端 B 继续向下执行，命中断点 __alltraps：
  ```gdb
  (gdb) c
  Continuing.

  Breakpoint 2, __alltraps ()
      at kern/trap/trapentry.S:123
  123         SAVE_ALL
  (gdb) i r sp
  sp             0xffffffffc0209ff0       0xffffffffc0209ff0
  (gdb) bt
  #0  __alltraps () at kern/trap/trapentry.S:123
  #1  0xffffffffc02000a2 in kern_init () at kern/init/init.c:42
  #2  0x0000000080000a02 in ?? ()
  ```
  说明此时已切到内核栈。

<!-- - 在 trap 内单步si到trapret： -->

- 查看此时位置：

  ```gdb
  (gdb) x/7i $pc
  => 0xffffffffc0200dc8 <trap>:
      auipc       a4,0xa5
     0xffffffffc0200dcc <trap+4>:
      ld  a4,744(a4)
     0xffffffffc0200dd0 <trap+8>:
      ld  a1,280(a0)
     0xffffffffc0200dd4 <trap+12>:
      beqz        a4,0xffffffffc0200e2c <trap+100>
     0xffffffffc0200dd6 <trap+14>:
      ld  a2,256(a0)
     0xffffffffc0200dda <trap+18>:
      ld  a6,160(a4)
     0xffffffffc0200dde <trap+22>:
      addi        sp,sp,-32

    ```

接下来我们在 trap 内执行到trapret。向下查找多条指令，直到找到trapret处的pc，为节省过多单步调试步骤，我们直接快进到该pc处：

```
  (gdb) until *0xffffffffc0200ebc
```
此时命中断点__trapret：
```
  Breakpoint 3, __trapret ()
      at kern/trap/trapentry.S:131
  131         RESTORE_ALL
```
<!-- 我们查看此处的截断信息：
```
  (gdb) i r sp
  sp             0xffffffffc0209ed0       0xffffffffc0209ed0
  (gdb) bt
  #0  __trapret () at kern/trap/trapentry.S:131
  #1  0xffffffffc0200ebc in __alltraps ()
      at kern/trap/trapentry.S:126
``` -->

接下来我们执行到sret。此处向下查找多条指令还找不到sret指令，应该是距离sret较远，我们通过反汇编查找sret的pc位置，并直接快进过去：

```gdb
  (gdb) disassemble __trapret  
  ...
  0xffffffffc0200f12 <+86>:    sret
  (gdb) until *0xffffffffc0200f12
```
补充说明：此过程中我们先快进到 __trapret，确认栈已调整到 0xffffffffc0209ed0，验证 RESTORE_ALL 之前栈和寄存器都已经回到预期位置，然后再快进到sret指令，避免出现偏差。

### 7.观测 sret 翻译与执行

<!-- - 终端 C 命中 trans_sret： -->

- 终端B快进到sret并执行后，终端C命中trans_sret：

    ```gdb
  (gdb) c
  Continuing.

  Thread 2 "qemu-system-ris" hit Breakpoint 2, trans_sret (ctx=0x7c1405d7c7d0,
  a=0x7c1405d7c6d0)
  at /home/op_user/qemu-4.1.1/target/riscv/insn_trans/trans_privileged.inc.c:46
  46          tcg_gen_movi_tl(cpu_pc, ctx->base.pc_next);

    ```
    我们查看此时截断处的相关信息：

    ```gdb
  (gdb) i r sp
  sp             0x7c1405d7c6a0      0x7c1405d7c6a0
  (gdb) bt（简略版）
  #0 trans_sret
  #1 decode_insn32
  #2 decode_opc / riscv_tr_translate_insn
  #3 translator_loop
  #4 gen_intermediate_code
  #5 tb_gen_code
  #6 tb_find
  #7 cpu_exec
  #8 tcg_cpu_exec
  #9 qemu_tcg_cpu_thread_fn
  #10 start_thread / clone
    ```
  可见，sret 翻译阶段捕获，链路为译码→TB 生成→TB 运行→线程入口，确认返回路径的 TCG 翻译已被触达。

- 终端 C 继续，命中 helper_sret：

    我们在终端C放行，放行后命中断点 helper_sret：

  ```gdb
  (gdb) c
  Continuing.

  Thread 2 "qemu-system-ris" hit Breakpoint 3, helper_sret (env=0x5608ed6b9040,
  cpu_pc_deb=18446744072637910802)
  at /home/op_user/qemu-4.1.1/target/riscv/op_helper.c:76
  76          if (!(env->priv >= PRV_S)) {
  ```
    我们查看此时截断处的相关信息：

    ```
  (gdb) i r sp
  sp             0x7c1405d7c3d0      0x7c1405d7c3d0
  (gdb) bt（简略版）
  #0 helper_sret
  #1 code_gen_buffer
  #2 cpu_tb_exec
  #3 cpu_loop_exec_tb
  #4 cpu_exec
  #5 tcg_cpu_exec
  #6 qemu_tcg_cpu_thread_fn
  #7 pthread_start / clone
    ```
  可见，helper_sret 执行阶段被捕获，链路为 TB 执行→循环执行→CPU 执行→线程入口，完成特权校验与 mstatus/sepc 恢复，准备切回用户态。


  最后我们在终端C中continue放行，发现终端B和终端C的断点反复触发，这应该是因为我们在终端 B 和终端 C 都设置了持久断点，我们尝试disable掉这些断点，发现终端B中 ucore 已回到用户态，且为sret的下一条指令，说明系统调用完整流程结束。

到此，用户态 ecall → 内核 trap → sret 返回用户态的翻译和执行关键路径均已捕获并解释。


### 8.终端 C 断点对应源码与关键流程解析

- 断点设置：
  ```
  (gdb) handle SIGPIPE nostop noprint
  (gdb) delete                 
  (gdb) b trans_ecall
  Breakpoint 1 at 0x5608ce91f87b: file /home/op_user/qemu-4.1.1/target/riscv/insn_trans/trans_privileged.inc.c, line 24.
  (gdb) b trans_sret
  Breakpoint 2 at 0x5608ce91f918: file /home/op_user/qemu-4.1.1/target/riscv/insn_trans/trans_privileged.inc.c, line 46.
  (gdb) b helper_sret
  Breakpoint 3 at 0x5608ce922256: file /home/op_user/qemu-4.1.1/target/riscv/op_helper.c, line 76.
  ```

- 说明与分析：
    我们设置了翻译/执行链路中的关键断点：
    - `trans_ecall`：TCG 翻译 U/S/M 模 ecall 时调用 `generate_exception` 的入口；
    - `trans_sret`：TCG 翻译 sret，设置下一条 PC 的翻译入口；
    - `helper_sret`：实际执行 sret 的 helper，检查特权级、更新 PC/寄存器；
  <!-- - 后续命中时在终端 C 记录 `i r sp`、回溯后 `c` 放行，与终端 B 的 trap/sret 单步对应。 -->

  设置好断点之后，我们具体点开每个断点处对应的 qemu 源码进行分析。

- 源码与流程：
  - `trans_ecall`（/target/riscv/insn_trans/trans_privileged.inc.c:24）
    ```c++
    static bool trans_ecall(DisasContext *ctx, arg_ecall *a) {
        /* always generates U-level ECALL, fixed in do_interrupt handler */
        generate_exception(ctx, RISCV_EXCP_U_ECALL);
        exit_tb(ctx); /* no chaining */
        ctx->base.is_jmp = DISAS_NORETURN;
        return true;
    }
    ```
    - 译码期调用 `generate_exception` 抛出 U 模 ecall;
    - 并用 `exit_tb`/`DISAS_NORETURN` 终止当前 TB，强制走异常路径（对应 trans_ecall 断点）。

  - `trans_sret`（/target/riscv/insn_trans/trans_privileged.inc.c:46）
    ```c++
    static bool trans_sret(DisasContext *ctx, arg_sret *a) {
        tcg_gen_movi_tl(cpu_pc, ctx->base.pc_next);
        if (has_ext(ctx, RVS)) {
            gen_helper_sret(cpu_pc, cpu_env, cpu_pc);
            exit_tb(ctx); /* no chaining */
            ctx->base.is_jmp = DISAS_NORETURN;
        } else {
            return false;
        }
        return true;
    }
    ```
    - 先写入下一条 PC（`tcg_gen_movi_tl`）;
    - 再生成调用 `helper_sret` 的 TCG 代码；
    - 最后 `exit_tb`/`DISAS_NORETURN` 结束 TB，保证跳入 helper_sret 处理特权切换（对应 trans_sret 断点）。

  - `helper_sret`（/target/riscv/op_helper.c:76）
    ```c++
    target_ulong helper_sret(CPURISCVState *env, target_ulong cpu_pc_deb) {
        if (!(env->priv >= PRV_S)) {
            riscv_raise_exception(env, RISCV_EXCP_ILLEGAL_INST, GETPC());
        }
        target_ulong retpc = env->sepc;
        if (!riscv_has_ext(env, RVC) && (retpc & 0x3)) {
            riscv_raise_exception(env, RISCV_EXCP_INST_ADDR_MIS, GETPC());
        }
        if (env->priv_ver >= PRIV_VERSION_1_10_0 &&
            get_field(env->mstatus, MSTATUS_TSR)) {
            riscv_raise_exception(env, RISCV_EXCP_ILLEGAL_INST, GETPC());
        }

        target_ulong mstatus = env->mstatus;
        target_ulong prev_priv = get_field(mstatus, MSTATUS_SPP);
        mstatus = set_field(mstatus,
            env->priv_ver >= PRIV_VERSION_1_10_0 ?
            MSTATUS_SIE : MSTATUS_UIE << prev_priv,
            get_field(mstatus, MSTATUS_SPIE));
        mstatus = set_field(mstatus, MSTATUS_SPIE, 0);
        mstatus = set_field(mstatus, MSTATUS_SPP, PRV_U);
        riscv_cpu_set_mode(env, prev_priv);
        env->mstatus = mstatus;

        return retpc;
    }
    ```
    - 先做特权/对齐/TSR 校验，不满足则抛异常；
    - `retpc=sepc` 取回返回地址；
    - `set_field` 恢复/清空 SPIE/SIE、清 SPP 为 U；
    - `riscv_cpu_set_mode` 切换特权并写回 mstatus；
    - 返回 retpc 供跳转，完成 S→U（对应 helper_sret 断点）。

- 综合分析：
  - 翻译链路：trans_ecall 直接生成异常退出 TB；trans_sret 翻译 sret，调用 helper_sret 完成特权切换并退出 TB。
  - 执行链路：helper_sret 检查特权/对齐/TSR，更新 mstatus 和模式，返回 sepc，完成从 S 态返回 U 态。
  - 断点顺序：先命中 trans_ecall（进入内核），内核 trap 处理，命中 trans_sret → helper_sret（返回路径），实现从 U→S→U 的完整观测。
<!-- - 输入（终端 C 重新设置断点）：
  ```
  (gdb) handle SIGPIPE nostop noprint
  Signal        Stop      Print   Pass to program       Description
  SIGPIPE       No        No      Yes          Broken pipe
  (gdb) delete
  (gdb) b trans_ecall
  Breakpoint 1 at 0x5608ce91f87b: file /home/op_user/qemu-4.1.1/target/riscv/insn_trans/trans_privileged.inc.c, line 24.
  (gdb) b trans_sret
  Breakpoint 2 at 0x5608ce91f918: file /home/op_user/qemu-4.1.1/target/riscv/insn_trans/trans_privileged.inc.c, line 46.
  (gdb) b helper_sret
  Breakpoint 3 at 0x5608ce922256: file /home/op_user/qemu-4.1.1/target/riscv/op_helper.c, line 76.
  ``` -->



### 9.流程梳理与要求覆盖
- 三终端分工：A 启动 QEMU；C attach端口，下 `trans_ecall`/`trans_sret`/`helper_sret`断点；B 连接 stub（先 target remote，再下断点）。
- 关键断点顺序：用户态 `user/libs/syscall.c:19` → ecall 前单步；C 命中 `trans_ecall`；B 命中 `__alltraps` → `trap` → `__trapret`，在 sret 前下断点；C 依次命中 `trans_sret`、`helper_sret`。
- TCG 翻译/执行路径：`trans_ecall` 生成异常、退出 TB；`trans_sret` 生成 sret 翻译，调用 helper；`helper_sret` 检查特权/对齐/TSR，更新 mstatus 和模式，返回 sepc。已观察到翻译与执行两个阶段，满足“ecall 和 sret 的处理”与 “TCG Translation” 的实验要求。
- 返回链路：终端 B 在 sret 处单步，终端 C 先命中 `trans_sret`（翻译）再命中 `helper_sret`（执行），完整覆盖 U→S→U。

### 10.“抓马”细节与心得
- 端口/进程误杀：`target remote` 提示 Kill 时必须选 n，选了y就会三端断开，不得不重新进行三端重启流程，很悲催。
<!-- - 符号缺失：无符号 QEMU 无法用符号或行号断点，只能算基址+偏移；建议固定用带符号的 `/home/wangy1/qemu/build/qemu-system-riscv64`。 -->
- 调试技巧：在翻译/执行断点处记录 `i r sp`；`until`/`finish` 快速跳到 `__trapret`；`b *<sret 地址>` 精准命中返回点。
- 大模型帮助：确认需 `add-symbol-file obj/__user_exit.out` 才能在 B 侧下用户断点；指明 QEMU 源码中的 ecall/sret 处理路径与 TCG 机制。
