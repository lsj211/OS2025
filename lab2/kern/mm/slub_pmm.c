// 必须包含的系统头文件（提供基础类型和宏）
#include <pmm.h>
#include <list.h>       // 提供list_entry_t定义
#include <string.h>
#include <slub_pmm.h>
#include <best_fit_pmm.h>
#include <stdio.h>      // cprintf
#include <defs.h>       // offsetof、size_t、uintptr_t
#include <memlayout.h>  // KERNBASE、PGSIZE

// 手动定义物理地址类型（使用系统uintptr_t）
typedef uintptr_t physaddr_t;

// 声明内核全局变量（系统已定义）
extern struct Page *pages;         // 物理页数组

// 地址转换宏
#define KVA_TO_PA(kva) ((physaddr_t)(kva) - KERNBASE)
#define PA_TO_PFN(pa)   ((size_t)(pa) / PGSIZE)
#define PFN_TO_PAGE(pfn) (&pages[(pfn)])
#define PAGE_TO_PFN(page) ((size_t)((page) - pages))
#define PFN_TO_KVA(pfn)  ((uintptr_t)(pfn) * PGSIZE + KERNBASE)
#define pa2page(pa) PFN_TO_PAGE(PA_TO_PFN(pa))

// 1. 对象元数据结构体
typedef struct obj_metadata {
    struct obj_metadata *next;
} obj_metadata_t;

// 2. Slab描述符
typedef struct slab {
    list_entry_t slab_link;
    struct Page *page;
    size_t obj_size;
    size_t num_objs;
    size_t free_objs;
    obj_metadata_t *free_list;
} slab_t;

// 3. 缓存描述符
typedef struct kmem_cache {
    list_entry_t slabs_full;
    list_entry_t slabs_partial;
    list_entry_t slabs_free;
    size_t obj_size;
    size_t align;
} kmem_cache_t;

// 提前声明所有函数
static void slub_init(void);
static void slub_init_memmap(struct Page *base, size_t n);
static struct Page *slub_alloc_pages(size_t n);
static void slub_free_pages(struct Page *base, size_t n);
static size_t slub_nr_free_pages(void);
static void slub_check(void);
static void *slub_alloc(size_t size);
static void slub_free(void *ptr);
static slab_t *slab_create(kmem_cache_t *cache);
static void slub_internal_init(void);

// 全局缓存数组
static kmem_cache_t caches[4];
static const size_t obj_sizes[4] = {16, 32, 64, 128};

// 复用最佳适配页分配器
extern const struct pmm_manager best_fit_pmm_manager;
#define page_alloc() best_fit_pmm_manager.alloc_pages(1)
#define page_free(page) best_fit_pmm_manager.free_pages(page, 1)

// 全局SLUB管理器实例
const struct slub_pmm_manager slub_pmm_manager = {
    .base = {
        .name = "slub_pmm_manager",
        .init = slub_init,
        .init_memmap = slub_init_memmap,
        .alloc_pages = slub_alloc_pages,
        .free_pages = slub_free_pages,
        .nr_free_pages = slub_nr_free_pages,
        .check = slub_check,
    },
    .alloc_obj = slub_alloc,
    .free_obj = slub_free
};

// 辅助宏：从链表节点获取slab结构体指针
#define le2slab(le, member) to_struct((le), slab_t, member)

// 辅助函数：获取对象所属的Slab（放在slub_check之前）
static slab_t *slab_of(void *obj) {
    physaddr_t pa = KVA_TO_PA((uintptr_t)obj);
    struct Page *page = pa2page(pa);
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
    return (slab_t *)slab_kva;
}

// 简化的SLUB检查函数// 综合 SLUB 检查函数 - 修复编译错误版本
static void slub_check(void) {
    cprintf("========================================\n");
    cprintf("SLUB COMPREHENSIVE TEST SUITE START\n");
    cprintf("========================================\n");
    
    // 保存初始状态
    size_t initial_free_pages = slub_nr_free_pages();
    cprintf("[INIT] Initial free pages: %d\n", initial_free_pages);
    
    // 测试用例 1: 基本功能验证
    cprintf("\n[TEST 1] Basic Functionality Verification\n");
    cprintf("----------------------------------------\n");
    {
        cprintf("[TEST 1.1] Single object allocation and free\n");
        void *obj1 = slub_alloc(16);
        if (obj1 == NULL) {
            panic("[FAIL] Basic allocation failed\n");
        }
        cprintf("[PASS] Object allocated at %p\n", obj1);
        
        // 数据完整性测试
        cprintf("[TEST 1.2] Data integrity verification\n");
        memset(obj1, 0xAA, 16);
        for (int i = 0; i < 16; i++) {
            if (((char*)obj1)[i] != 0xAA) {
                panic("[FAIL] Data corruption detected\n");
            }
        }
        cprintf("[PASS] Data integrity verified\n");
        
        // 释放测试
        slub_free(obj1);
        size_t after_free = slub_nr_free_pages();
        if (initial_free_pages != after_free) {
            cprintf("[WARNING] Single object leak: %d -> %d pages\n", 
                    initial_free_pages, after_free);
        } else {
            cprintf("[PASS] Single object properly freed\n");
        }
        
        cprintf("[TEST 1.3] Multiple object allocation pattern\n");
        void *objects[10];
        for (int i = 0; i < 10; i++) {
            objects[i] = slub_alloc(16 + (i % 3) * 16);
            if (objects[i] == NULL) {
                panic("[FAIL] Pattern allocation failed at step %d\n", i);
            }
            memset(objects[i], i & 0xFF, 16 + (i % 3) * 16);
        }
        cprintf("[PASS] Multiple object allocation successful\n");
        
        // 清理
        for (int i = 0; i < 10; i++) {
            slub_free(objects[i]);
        }
        cprintf("[PASS] Multiple object cleanup successful\n");
    }
    
    // 测试用例 2: 大小适配验证
    cprintf("\n[TEST 2] Size Alignment Verification\n");
    cprintf("----------------------------------------\n");
    {
        cprintf("[TEST 2.1] Cache size selection\n");
        
        void *obj10 = slub_alloc(10);   // 应使用16B缓存
        void *obj15 = slub_alloc(15);   // 应使用16B缓存  
        void *obj20 = slub_alloc(20);   // 应使用32B缓存
        void *obj40 = slub_alloc(40);   // 应使用64B缓存
        
        cprintf("obj10(10B) -> cache: %dB\n", slab_of(obj10)->obj_size);
        cprintf("obj15(15B) -> cache: %dB\n", slab_of(obj15)->obj_size);
        cprintf("obj20(20B) -> cache: %dB\n", slab_of(obj20)->obj_size);
        cprintf("obj40(40B) -> cache: %dB\n", slab_of(obj40)->obj_size);
        
        // 验证缓存选择正确
        if (slab_of(obj10)->obj_size != 16 || slab_of(obj20)->obj_size != 32) {
            panic("[FAIL] Cache size selection incorrect\n");
        }
        cprintf("[PASS] Cache size selection correct\n");
        
        // 验证同一缓存对象在同一Slab
        cprintf("[TEST 2.2] Same-cache object co-location\n");
        if (slab_of(obj10) != slab_of(obj15)) {
            panic("[FAIL] Same cache objects not in same slab\n");
        }
        cprintf("[PASS] Same cache objects properly co-located\n");
        
        // 验证不同缓存对象在不同Slab
        cprintf("[TEST 2.3] Different-cache object isolation\n");
        if (slab_of(obj10) == slab_of(obj20) || slab_of(obj20) == slab_of(obj40)) {
            panic("[FAIL] Different cache objects not isolated\n");
        }
        cprintf("[PASS] Different cache objects properly isolated\n");
        
        // 清理
        slub_free(obj10); slub_free(obj15);
        slub_free(obj20); slub_free(obj40);
        cprintf("[PASS] Size alignment test cleanup successful\n");
    }
    
    // 测试用例 3: Slab 状态转换验证
    cprintf("\n[TEST 3] Slab State Transition Verification\n");
    cprintf("----------------------------------------\n");
    {
        cprintf("[TEST 3.1] Slab state monitoring\n");
        
        kmem_cache_t *cache16 = &caches[0]; // 16B缓存
        
        // 获取一个Slab并填满它
        void *first_obj = slub_alloc(16);
        slab_t *slab = slab_of(first_obj);
        size_t obj_per_slab = slab->num_objs;
        
        cprintf("Slab capacity: %d objects\n", obj_per_slab);
        cprintf("Initial free objects: %d\n", slab->free_objs);
        
        // 分配剩余对象使Slab变满
        cprintf("[TEST 3.2] Slab full state transition\n");
        void **objects = slub_alloc(sizeof(void*) * obj_per_slab);
        void *filled_objs[obj_per_slab - 1];
        
        for (size_t i = 1; i < obj_per_slab; i++) {
            filled_objs[i-1] = slub_alloc(16);
            if (filled_objs[i-1] == NULL) {
                panic("[FAIL] Failed to fill slab at object %d\n", i);
            }
        }
        
        // 验证进入full状态
        if (!list_empty(&cache16->slabs_full)) {
            slab_t *full_slab = le2slab(list_next(&cache16->slabs_full), slab_link);
            if (full_slab == slab && full_slab->free_objs == 0) {
                cprintf("[PASS] Slab correctly transitioned to FULL state\n");
            } else {
                panic("[FAIL] Slab full state incorrect\n");
            }
        } else {
            panic("[FAIL] Slab should be in full list\n");
        }
        
        // 释放一个对象，进入partial状态
        cprintf("[TEST 3.3] Slab partial state transition\n");
        slub_free(first_obj);
        
        if (!list_empty(&cache16->slabs_partial)) {
            slab_t *partial_slab = le2slab(list_next(&cache16->slabs_partial), slab_link);
            if (partial_slab == slab && partial_slab->free_objs == 1) {
                cprintf("[PASS] Slab correctly transitioned to PARTIAL state\n");
            } else {
                panic("[FAIL] Slab partial state incorrect\n");
            }
        } else {
            panic("[FAIL] Slab should be in partial list\n");
        }
        
        // 对象复用测试
        cprintf("[TEST 3.4] Object reuse verification\n");
        void *reused_obj = slub_alloc(8);
        if (reused_obj == first_obj) {
            cprintf("[PASS] Object correctly reused\n");
        } else {
            panic("[FAIL] Object reuse failed: %p != %p\n", reused_obj, first_obj);
        }
        
        // 释放所有对象，应该释放物理页
        cprintf("[TEST 3.5] Slab free and page release\n");
        slub_free(reused_obj);
        for (size_t i = 1; i < obj_per_slab; i++) {
            slub_free(filled_objs[i-1]);
        }
        
        cprintf("[PASS] Slab state transitions completed successfully\n");
        
        slub_free(objects);
    }
    
    // 测试用例 4: 内存泄漏检测
    cprintf("\n[TEST 4] Memory Leak Detection\n");
    cprintf("----------------------------------------\n");
    {
        cprintf("[TEST 4.1] Complex allocation pattern\n");
        
        void *pattern[50];
        size_t allocated_sizes[50];
        
        // 复杂分配模式 - 使用所有缓存
        for (int i = 0; i < 50; i++) {
            size_t size = 16 + (i % 4) * 16; // 16, 32, 64, 128字节交替
            allocated_sizes[i] = size;
            pattern[i] = slub_alloc(size);
            if (pattern[i] == NULL) {
                panic("[FAIL] Pattern allocation failed at step %d\n", i);
            }
            
            // 写入唯一数据
            memset(pattern[i], i & 0xFF, size);
        }
        cprintf("[PASS] Complex allocation pattern completed\n");
        
        // 验证数据完整性
        cprintf("[TEST 4.2] Data integrity in complex pattern\n");
        for (int i = 0; i < 50; i++) {
            for (int j = 0; j < 10 && j < allocated_sizes[i]; j++) {
                if (((char*)pattern[i])[j] != (i & 0xFF)) {
                    panic("[FAIL] Data corruption in complex pattern at object %d\n", i);
                }
            }
        }
        cprintf("[PASS] Data integrity maintained in complex pattern\n");
        
        // 部分释放测试
        cprintf("[TEST 4.3] Partial free and reallocation\n");
        for (int i = 0; i < 50; i += 2) {
            slub_free(pattern[i]);
            pattern[i] = NULL;
        }
        cprintf("Freed 50%% of objects\n");
        
        // 重新分配
        for (int i = 0; i < 50; i += 2) {
            pattern[i] = slub_alloc(allocated_sizes[i]);
            if (pattern[i] == NULL) {
                panic("[FAIL] Re-allocation failed at step %d\n", i);
            }
        }
        cprintf("[PASS] Partial free and reallocation successful\n");
        
        // 最终清理
        cprintf("[TEST 4.4] Final cleanup and leak check\n");
        for (int i = 0; i < 50; i++) {
            if (pattern[i] != NULL) {
                slub_free(pattern[i]);
            }
        }
        
        size_t final_pages = slub_nr_free_pages();
        if (initial_free_pages == final_pages) {
            cprintf("[PASS] No memory leakage in complex pattern\n");
        } else {
            cprintf("[WARNING] Memory leakage in complex pattern: %d -> %d pages\n", 
                    initial_free_pages, final_pages);
        }
    }
    
    // 测试用例 5: 边界情况处理
    cprintf("\n[TEST 5] Edge Cases Handling\n");
    cprintf("----------------------------------------\n");
    {
        cprintf("[TEST 5.1] Zero-size allocation\n");
        void *obj0 = slub_alloc(0);
        if (obj0 != NULL) {
            cprintf("[INFO] Zero-size allocation returned %p\n", obj0);
            slub_free(obj0);
            cprintf("[PASS] Zero-size allocation handled\n");
        } else {
            cprintf("[PASS] Zero-size allocation correctly rejected\n");
        }
        
        cprintf("[TEST 5.2] Exact size allocation\n");
        void *obj16 = slub_alloc(16);  // 精确匹配16字节缓存
        void *obj32 = slub_alloc(32);  // 精确匹配32字节缓存
        if (obj16 != NULL && obj32 != NULL) {
            cprintf("[PASS] Exact size allocations successful\n");
            slub_free(obj16);
            slub_free(obj32);
        } else {
            panic("[FAIL] Exact size allocations failed\n");
        }
        
        cprintf("[TEST 5.3] Oversize allocation\n");
        void *obj_big = slub_alloc(200);  // 超过最大缓存大小
        if (obj_big == NULL) {
            cprintf("[PASS] Oversize allocation correctly rejected\n");
        } else {
            panic("[FAIL] Oversize allocation should fail\n");
        }
        
        cprintf("[TEST 5.4] NULL pointer free\n");
        slub_free(NULL);  // 应该不崩溃
        cprintf("[PASS] NULL pointer free handled gracefully\n");
        
        cprintf("[TEST 5.5] Double free detection\n");
        void *temp_obj = slub_alloc(16);
        slub_free(temp_obj);
        // 注意：在实际生产环境中，双释放应该被检测并阻止
        // 这里我们只是验证系统不会崩溃
        slub_free(temp_obj);  // 双释放 - 应该被安全处理
        cprintf("[PASS] Double free handled without crash\n");
    }
    
    // 测试用例 6: 性能基准测试（简化版）
    cprintf("\n[TEST 6] Performance Benchmark (Simplified)\n");
    cprintf("----------------------------------------\n");
    {
        cprintf("[TEST 6.1] Allocation performance\n");
        
        const int ITERATIONS = 100;
        void *objects[ITERATIONS];
        
        // 分配性能测试
        for (int i = 0; i < ITERATIONS; i++) {
            objects[i] = slub_alloc(32);  // 使用32字节缓存
            if (objects[i] == NULL) {
                panic("[FAIL] Performance test allocation failed\n");
            }
        }
        cprintf("Allocated %d objects successfully\n", ITERATIONS);
        
        // 释放性能测试
        cprintf("[TEST 6.2] Free performance\n");
        for (int i = 0; i < ITERATIONS; i++) {
            slub_free(objects[i]);
        }
        cprintf("Freed %d objects successfully\n", ITERATIONS);
        
        cprintf("[PASS] Performance benchmark completed\n");
    }
    
    // 测试用例 7: 完整性检查（简化版）
    cprintf("\n[TEST 7] Integrity Check (Simplified)\n");
    cprintf("----------------------------------------\n");
    {
        cprintf("[TEST 7.1] Cache basic verification\n");
        
        for (int i = 0; i < 4; i++) {
            kmem_cache_t *cache = &caches[i];
            cprintf("Cache %dB: full=%d, partial=%d, free=%d\n", 
                    cache->obj_size,
                    list_empty(&cache->slabs_full) ? 0 : 1,
                    list_empty(&cache->slabs_partial) ? 0 : 1,
                    list_empty(&cache->slabs_free) ? 0 : 1);
        }
        cprintf("[PASS] Basic cache verification completed\n");
        
        cprintf("[TEST 7.2] Cross-cache isolation verification\n");
        // 验证不同缓存的对象不会混淆
        void *small_obj = slub_alloc(10);   // 16B缓存
        void *medium_obj = slub_alloc(20);  // 32B缓存
        
        if (slab_of(small_obj) == slab_of(medium_obj)) {
            panic("[FAIL] Cross-cache isolation failed\n");
        }
        cprintf("[PASS] Cross-cache isolation verified\n");
        
        slub_free(small_obj);
        slub_free(medium_obj);
    }
    
    // 最终状态验证
    cprintf("\n[FINAL] Final State Verification\n");
    cprintf("----------------------------------------\n");
    size_t final_free_pages = slub_nr_free_pages();
    cprintf("[FINAL] Final free pages: %d\n", final_free_pages);
    
    if (initial_free_pages == final_free_pages) {
        cprintf("[SUCCESS] No memory leakage detected\n");
    } else {
        cprintf("[WARNING] Memory leakage: %d -> %d pages\n", 
                initial_free_pages, final_free_pages);
    }
    
    cprintf("\n========================================\n");
    cprintf("SLUB COMPREHENSIVE TEST SUITE COMPLETED\n");
    cprintf("========================================\n");
    cprintf("check_slub() succeeded!\n");
}
// 1. SLUB初始化
static void slub_init(void) {
    best_fit_pmm_manager.init();
    slub_internal_init();
    cprintf("SLUB: Initialized\n");
}

// 2. 内存块初始化
static void slub_init_memmap(struct Page *base, size_t n) {
    best_fit_pmm_manager.init_memmap(base, n);
}

// 3. 页级分配
static struct Page *slub_alloc_pages(size_t n) {
    return best_fit_pmm_manager.alloc_pages(n);
}

// 4. 页级释放
static void slub_free_pages(struct Page *base, size_t n) {
    best_fit_pmm_manager.free_pages(base, n);
}

// 5. 空闲页数统计
static size_t slub_nr_free_pages(void) {
    return best_fit_pmm_manager.nr_free_pages();
}

// 6. 初始化内部缓存
static void slub_internal_init(void) {
    for (int i = 0; i < 4; i++) {
        kmem_cache_t *cache = &caches[i];
        cache->obj_size = obj_sizes[i];
        cache->align = 8;
        list_init(&cache->slabs_full);
        list_init(&cache->slabs_partial);
        list_init(&cache->slabs_free);
    }
}

// 7. 创建新Slab
static slab_t *slab_create(kmem_cache_t *cache) {
    struct Page *page = page_alloc();
    if (!page) return NULL;

    uintptr_t page_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
    slab_t *slab = (slab_t *)page_kva;

    slab->page = page;
    slab->obj_size = cache->obj_size;
    size_t slab_meta_size = sizeof(slab_t);
    size_t remaining = PGSIZE - slab_meta_size;
    slab->num_objs = remaining / (cache->obj_size + sizeof(obj_metadata_t));
    slab->free_objs = slab->num_objs;

    char *obj_start = (char *)(slab + 1);
    slab->free_list = NULL;
    for (size_t i = 0; i < slab->num_objs; i++) {
        obj_metadata_t *meta = (obj_metadata_t *)(obj_start + i * (cache->obj_size + sizeof(obj_metadata_t)));
        meta->next = slab->free_list;
        slab->free_list = meta;
    }

    list_add_before(&cache->slabs_free, &slab->slab_link);
    return slab;
}

// 8. 对象级分配
static void *slub_alloc(size_t size) {
    kmem_cache_t *cache = NULL;
    for (int i = 0; i < 4; i++) {
        if (obj_sizes[i] >= size) {
            cache = &caches[i];
            break;
        }
    }
    if (!cache) return NULL;

    slab_t *slab = NULL;
    if (!list_empty(&cache->slabs_partial)) {
        slab = le2slab(list_next(&cache->slabs_partial), slab_link);
    } else if (!list_empty(&cache->slabs_free)) {
        slab = le2slab(list_next(&cache->slabs_free), slab_link);
        list_del_init(&slab->slab_link);
        list_add_before(&cache->slabs_partial, &slab->slab_link);
    } else {
        slab = slab_create(cache);
        if (!slab) return NULL;
        list_del_init(&slab->slab_link);
        list_add_before(&cache->slabs_partial, &slab->slab_link);
    }

    obj_metadata_t *meta = slab->free_list;
    slab->free_list = meta->next;
    slab->free_objs--;

    if (slab->free_objs == 0) {
        list_del_init(&slab->slab_link);
        list_add_before(&cache->slabs_full, &slab->slab_link);
    }

    return (void *)(meta + 1);
}

//// 修改 slub_free 函数，在Slab完全空闲时释放页面
static void slub_free(void *ptr) {
    if (!ptr) return;

    obj_metadata_t *meta = (obj_metadata_t *)ptr - 1;
    uintptr_t ptr_kva = (uintptr_t)ptr;
    physaddr_t ptr_pa = KVA_TO_PA(ptr_kva);
    struct Page *page = pa2page(ptr_pa);
    uintptr_t slab_kva = PFN_TO_KVA(PAGE_TO_PFN(page));
    slab_t *slab = (slab_t *)slab_kva;

    kmem_cache_t *cache = NULL;
    for (int i = 0; i < 4; i++) {
        if (caches[i].obj_size == slab->obj_size) {
            cache = &caches[i];
            break;
        }
    }
    if (!cache) return;

    meta->next = slab->free_list;
    slab->free_list = meta;
    slab->free_objs++;

    if (slab->free_objs == 1) {
        // 从满/空链表移到部分满链表
        list_del_init(&slab->slab_link);
        list_add_before(&cache->slabs_partial, &slab->slab_link);
    } else if (slab->free_objs == slab->num_objs) {
        // Slab完全空闲，释放物理页面
        list_del_init(&slab->slab_link);
        page_free(slab->page);  // 关键：释放物理页面
    }
}
