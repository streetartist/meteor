#include <stdio.h>
extern void* mi_malloc(size_t);
extern void mi_free(void*);
int main() {
    void* p = mi_malloc(100);
    printf("allocated: %p\n", p);
    mi_free(p);
    return 0;
}
