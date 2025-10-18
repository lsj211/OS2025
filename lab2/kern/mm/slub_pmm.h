#ifndef __KERN_MM_SLUB_PMM_H__
#define __KERN_MM_SLUB_PMM_H__
#include <pmm.h>
// struct slub_pmm_manager {
//     struct pmm_manager base;
//     void *(*alloc_obj)(size_t size);
//     void (*free_obj)(void *ptr);
// };
extern const struct pmm_manager slub_pmm_manager;
#endif
