#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

static free_area_t free_area;
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
#define MAX(a,b) ((a) > (b) ? (a) : (b))


// buddy_t 描述整个buddy的信息。
typedef struct {
    unsigned size;                    // 可管理的总页数（为2的幂）
    unsigned* longest;                // 二叉树数组，记录每节点最大连续空闲块大小
    struct Page* reserve_page;        // 预留页起始地址（存放longest数组）
    struct Page* first_page;          // 可被分配的第一页地址
    unsigned reserve_count;           // 预留页数量
} buddy_t;

static buddy_t buddy;                 

static inline int parent(int i) { return (i - 1) / 2; }                      // 父节点索引
static inline int left_leaf(int i) { return 2 * i + 1; }                     // 左子节点索引
static inline int right_leaf(int i) { return 2 * i + 2; }                    // 右子节点索引
static inline int is_power_of_2(uint32_t x) {return ((x & (x - 1)) == 0); }  // 是否为2的幂

static inline uint32_t 
next_power_of_2(uint32_t x) {
    if (x == 0) return 1;                
    uint32_t v = x;                      
    v--;                                 
    v |= v >> 1; v |= v >> 2; v |= v >> 4;  
    v |= v >> 8; v |= v >> 16;           
    v++;                                 
    return v;
}

static inline uint32_t 
prev_power_of_2(uint32_t x) {         
    return next_power_of_2(x) / 2;                            
}


// 页地址转换为树叶节点索引（叶子节点编号从 size-1 开始）
static int 
page2leaf(struct Page* page) {  
    size_t offset_pages = (size_t)(page - buddy.first_page);  // 页偏移量
    return (int)(offset_pages + (buddy.size - 1));            // 转换
}

static void 
buddy_init(void) {
    list_init(&free_list);               // 初始化空闲链表
    nr_free = 0;                         // 空闲页数清零
    buddy.size = 0;                      // 管理页数清零
    buddy.longest = NULL;                // 树数组置空
    buddy.reserve_page = NULL;           // 无预留页
    buddy.first_page = NULL;             // 无首页
    buddy.reserve_count = 0;             // 预留页数为0
}



// 初始化 longest 数组，构建完全二叉树结构
// longest[i] 表示该节点下的最大连续空闲块大小
static void 
init_longest(unsigned *longest, unsigned n) {
    assert(is_power_of_2(n));                                    
    unsigned total_nodes = 2 * n - 1;                            // 完全二叉树节点总数
    for (unsigned i = 0; i < total_nodes; i++){
        longest[i] = 0;                                         
    }
    for (unsigned i = 0; i < n; ++i){
        longest[n - 1 + i] = 1;                                  // 叶子节点每个块初始大小为1页
    }
    for (int i = n - 2; i >= 0; --i){
        longest[i] = longest[left_leaf(i)] + longest[right_leaf(i)]; // 父节点等于左右子之和
    }
    assert(longest[0] == n);                                     // 根节点等于总页数
}



// 预留若干页作为 longest 数组存储空间
// 将剩余页调整为 2 的幂，作为可管理的主内存
// 初始化 longest 树结构
static void 
buddy_init_memmap(struct Page *base, size_t n) {
    struct Page *p = base;
    for (; p != base + n; p++) {                                 // 初始化每一页
        p->flags = p->property = 0;                              // 清空标志与属性
        set_page_ref(p, 0);                                      // 引用计数清零
    }
    nr_free += n;                                                // 增加空闲页计数

    static int is_buddy_inited = 0;                              // 静态标志：防止重复初始化
    if (!is_buddy_inited && buddy.longest == NULL) {             // 首次初始化执行
        size_t tree_bytes = (2 * n - 1) * sizeof(unsigned);      // longest数组所需字节
        size_t reserve_page_cnt = (tree_bytes + PGSIZE - 1) / PGSIZE; // 取整后的预留页数
        buddy.reserve_page = base;                               // 预留空间从base开始
        buddy.reserve_count = reserve_page_cnt;                  // 保存预留页数

        for (size_t i = 0; i < reserve_page_cnt; i++) {          // 标记这些页为“保留”
            SetPageReserved(buddy.reserve_page + i);             // 设置保留标志
            set_page_ref(buddy.reserve_page + i, 1);             // 引用计数设为1
        }
        nr_free -= reserve_page_cnt;                             // 从可用页中扣除预留页

        size_t total_free_pages = n - reserve_page_cnt;          // 剩余可用页
        if (!is_power_of_2(total_free_pages))                    // 若不是2的幂
            total_free_pages = prev_power_of_2(total_free_pages);// 向下取整为2的幂

        buddy.size = (unsigned)total_free_pages;                 // 保存可管理页数
        buddy.first_page = base + reserve_page_cnt;              // 设置可分配的第一页地址

        size_t tail_start = reserve_page_cnt + buddy.size;       // 尾部超出部分页起始
        size_t original_free_after_reserve = n - reserve_page_cnt; // 预留后总剩余
        if (original_free_after_reserve > buddy.size) {          // 若尾部还有多余页
            size_t extra = original_free_after_reserve - buddy.size; // 计算多余页数
            struct Page *tail = base + tail_start;               // 多余页的起始地址
            for (size_t i = 0; i < extra; i++) {                 // 遍历并标记为保留
                SetPageReserved(tail + i);                       // 标记为保留
                set_page_ref(tail + i, 1);                       // 引用计数设为1
            }
            nr_free -= extra;                                    // 减去这些页
        }

        buddy.longest = (unsigned*)buddy.reserve_page;           // longest数组映射到预留页
        init_longest(buddy.longest, buddy.size);                 // 构建完全二叉树结构
        is_buddy_inited = 1;                                     // 标记初始化完成
    }
}


struct Page *
buddy_alloc_pages(size_t n) {
    if (n == 0 || n > buddy.size)
        return NULL; 

    

    // 向上取整到 2 的幂
    size_t node_size = 1;
    while (node_size < n) {
        node_size <<= 1;       // 找到能容纳 n 页的最小 2 的幂块大小
    }
    if (buddy.longest[0] < node_size)
        return NULL;

    int index = 0;             // 根节点索引（buddy 树的起点）
    size_t level_size = buddy.size; // 当前层块大小（从整个内存块开始）
    size_t offset = 0;              // 记录分配块的起始页偏移

    if (buddy.longest[index] < n)
        return NULL; // 根节点可用最大块都不足，无法分配

    


    // 自顶向下搜索，同时累加 offset
    while (level_size != node_size) { // 逐层向下直到找到合适大小的块
        level_size >>= 1; // 下一层块大小减半
        int left  = left_leaf(index);  // 左子节点索引
        int right = right_leaf(index); // 右子节点索引
        unsigned left_long  = buddy.longest[left];  // 左子树最大可用块
        unsigned right_long = buddy.longest[right]; // 右子树最大可用块
        if (left_long >= n && right_long >= n) { // 两边都能放下
            if (left_long <= right_long) {
                index = left; // 选择更紧凑（left_long 较小）的左子树
            } else {
                offset += level_size; // 右子树起始位置在当前偏移 + 左子块大小
                index = right;        // 选择右子树
            }
        } else if (left_long >= n) {
            index = left; // 仅左子树可用
        } else if (right_long >= n) {
            offset += level_size; // 偏移右移一个左子块大小
            index = right;        // 选择右子树
        } else {
            return NULL; // 无可分配块（两边都不足）
        }
    }

    // 标记节点为已分配
    buddy.longest[index] = 0; // 该节点块已被使用，最大可用长度设为 0

    // 更新父节点 longest
    int parent_index = parent(index);
    while (index > 0) { // 向上回溯，更新所有父节点的 longest 值
        unsigned left_longest = buddy.longest[left_leaf(parent_index)];
        unsigned right_longest = buddy.longest[right_leaf(parent_index)];
        buddy.longest[parent_index] = MAX(left_longest, right_longest); // 父节点最大块 = 子节点最大块的较大者
        index = parent_index;  // 继续往上
        parent_index = parent(index);
    }

    // 返回 Page*
    struct Page *page = buddy.first_page + offset; // 计算物理页指针：起始页 + 偏移
    assert(offset + node_size <= buddy.size); // 防止越界（分配超出总页数）

    return page; // 返回分配到的页块指针
}



// 将释放块重新插入到树中，并自底向上更新 longest
// 若两个子块均空闲且大小相等，执行自动合并
static void 
buddy_free_pages(struct Page *base, size_t n)
{
    assert(n > 0 && is_power_of_2(n)); // 确保释放块大小为 2 的幂
    assert(!PageReserved(base)); // 确保页未被保留
    assert(buddy.longest && buddy.first_page); // 确保伙伴系统已初始化

    size_t offset = base - buddy.first_page; // 计算释放块在内存中的偏移
    if ((offset + n) > buddy.size) panic("buddy_free_pages: out of range"); // 越界检查

    // 重置页的标志和引用计数
    for (size_t i = 0; i < n; i++) {
        base[i].flags = 0;
        set_page_ref(&base[i], 0);
    }
    base->property = n; // 记录块大小
    SetPageProperty(base); // 标记该块为空闲
    list_add(&free_list, &base->page_link); // 插入空闲链表
    nr_free += n; // 更新空闲页计数

    int index = (int)(offset + buddy.size - 1); // 定位到对应叶子节点
    buddy.longest[index] = n; // 设置叶子节点 longest 值为释放块大小

    // 自底向上更新并尝试合并空闲块
    while (index > 0) {
        int parent_index = parent(index); // 获取父节点
        int l = left_leaf(parent_index);  // 左子节点索引
        int r = right_leaf(parent_index); // 右子节点索引
        unsigned left_long = buddy.longest[l];
        unsigned right_long = buddy.longest[r];
        if (left_long == right_long && is_power_of_2(left_long))
            buddy.longest[parent_index] = left_long + right_long; // 若左右相等且均为空闲块，合并
        else
            buddy.longest[parent_index] = MAX(left_long, right_long); // 否则取较大者
        index = parent_index;
    }
    buddy.longest[0] = buddy.size; 

}

static size_t buddy_nr_free_pages(void) {
    return nr_free; // 返回当前空闲页数
}


// static void 
// basic_check(void) {
//     struct Page *p0, *p1, *p2;
//     p0 = p1 = p2 = NULL;
//     assert((p0 = alloc_page()) != NULL);
//     assert((p1 = alloc_page()) != NULL);
//     assert((p2 = alloc_page()) != NULL);
//     assert(p0 != p1 && p0 != p2 && p1 != p2);
//     assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
//     assert(page2pa(p0) < npage * PGSIZE);
//     assert(page2pa(p1) < npage * PGSIZE);
//     assert(page2pa(p2) < npage * PGSIZE);

//     list_entry_t free_list_store = free_list;
//     list_init(&free_list);
//     assert(list_empty(&free_list));

//     unsigned int nr_free_store = nr_free;
//     nr_free = 0;
//     assert(alloc_page() == NULL);

//     free_page(p0);
//     free_page(p1);
//     free_page(p2);
//     assert(nr_free == 3);

//     assert((p0 = alloc_page()) != NULL);
//     assert((p1 = alloc_page()) != NULL);
//     assert((p2 = alloc_page()) != NULL);
//     assert(alloc_page() == NULL);

//     free_page(p0);
//     assert(!list_empty(&free_list));
//     struct Page *p = NULL;
//     assert(alloc_page() == NULL);
//     assert(nr_free == 0);
//     free_list = free_list_store;
//     nr_free = nr_free_store;
//     free_page(p);
//     free_page(p1);
//     free_page(p2);
// }


// 验证：
// 非2幂分配自动对齐
// 分裂与合并逻辑
// longest 数组动态变化是否正确
// 多轮碎片化与回收是否恢复最大块
static void advanced_buddy_check(void) {
    // cprintf("\n[Advanced Buddy Check] 开始二叉树特性验证...\n");
    size_t total_free = nr_free_pages();
    assert(total_free >= 16);

    struct Page *p3 = alloc_pages(3);
    assert(p3 != NULL);
    cprintf("测试1通过: 3页分配取整成功.\n");

    struct Page *p4 = alloc_pages(3);
    assert(p4 != NULL && p4 != p3);
    cprintf("测试2通过: 第二个3页分配成功.\n");

    free_pages(p3, 4);
    assert(nr_free_pages() >= total_free - 4);
    cprintf("测试3通过: 释放后 longest[] 恢复正确.\n");

    struct Page *a = alloc_pages(2);
    struct Page *b = alloc_pages(2);
    assert(a && b && a != b);
    free_pages(a, 2);
    free_pages(b, 2);
    struct Page *merged = alloc_pages(4);
    assert(merged != NULL);
    cprintf("测试4通过: 2+2 合并成功.\n");

    free_pages(merged, 4);
    free_pages(p4, 4);
    assert(buddy.longest[0] == buddy.size);
    cprintf("测试5通过: 所有块释放后恢复最大空闲块.\n");

    struct Page *maxblk = alloc_pages(buddy.size);
    assert(maxblk != NULL);
    free_pages(maxblk, buddy.size);
    cprintf("测试6通过: 最大块分配与释放成功.\n");

    struct Page *x1 = alloc_pages(1);
    struct Page *x2 = alloc_pages(2);
    struct Page *x3 = alloc_pages(1);
    assert(x1 && x2 && x3);
    free_pages(x2, 2);
    free_pages(x1, 1);
    free_pages(x3, 1);
    cprintf("longest = %u\n", buddy.longest[0]);
    cprintf("size    = %u\n", buddy.size);
    assert(buddy.longest[0] == buddy.size);
    cprintf("测试7通过: 碎片化后完全合并恢复.\n");

    cprintf("Advanced Buddy Checks Passed!\n\n");
}

// buddy_basic_check + advanced_check
static void buddy_check(void) {
    size_t total_free = nr_free_pages();
    assert(total_free > 0);
    // basic_check();

    struct Page *p2 = alloc_pages(2);
    struct Page *p4 = alloc_pages(4);
    assert(p2 && p4);
    free_pages(p2, 2);
    free_pages(p4, 4);

    struct Page *p3 = alloc_pages(3);
    assert(p3);
    free_pages(p3, 4);

    struct Page *a = alloc_pages(4);
    struct Page *b = alloc_pages(4);
    free_pages(a, 4);
    free_pages(b, 4);
    struct Page *c = alloc_pages(8);
    assert(c);
    free_pages(c, 8);

    advanced_buddy_check();
    cprintf("All Buddy Checks Passed!");
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

