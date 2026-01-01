// Memory tracking tool for Meteor
// Compile with: clang -shared -o mem_track.dll mem_track.c (Windows)
// Or link directly with the program

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ALLOCS 100000

typedef struct {
    void* ptr;
    size_t size;
    const char* file;
    int line;
    int freed;
} AllocInfo;

static AllocInfo allocs[MAX_ALLOCS];
static int alloc_count = 0;
static size_t total_allocated = 0;
static size_t total_freed = 0;
static int malloc_calls = 0;
static int free_calls = 0;

// Override malloc
void* tracked_malloc(size_t size) {
    void* ptr = malloc(size);
    if (ptr && alloc_count < MAX_ALLOCS) {
        allocs[alloc_count].ptr = ptr;
        allocs[alloc_count].size = size;
        allocs[alloc_count].freed = 0;
        alloc_count++;
        total_allocated += size;
        malloc_calls++;
    }
    return ptr;
}

// Override free
void tracked_free(void* ptr) {
    if (!ptr) return;

    for (int i = alloc_count - 1; i >= 0; i--) {
        if (allocs[i].ptr == ptr && !allocs[i].freed) {
            allocs[i].freed = 1;
            total_freed += allocs[i].size;
            free_calls++;
            free(ptr);
            return;
        }
    }
    // Double free or invalid free
    fprintf(stderr, "[MEM] Warning: free(%p) - not found or double free!\n", ptr);
    free(ptr);
    free_calls++;
}

// Print memory report
void mem_report() {
    printf("\n========== MEMORY REPORT ==========\n");
    printf("malloc calls: %d\n", malloc_calls);
    printf("free calls: %d\n", free_calls);
    printf("Total allocated: %zu bytes\n", total_allocated);
    printf("Total freed: %zu bytes\n", total_freed);
    printf("Leaked: %zu bytes\n", total_allocated - total_freed);

    int leak_count = 0;
    printf("\n--- Leaked allocations (last 20): ---\n");
    for (int i = alloc_count - 1; i >= 0 && leak_count < 20; i--) {
        if (!allocs[i].freed) {
            printf("  Leak: %p, size=%zu\n", allocs[i].ptr, allocs[i].size);
            leak_count++;
        }
    }
    printf("Total leaked allocations: ");
    leak_count = 0;
    for (int i = 0; i < alloc_count; i++) {
        if (!allocs[i].freed) leak_count++;
    }
    printf("%d\n", leak_count);
    printf("====================================\n");
}
