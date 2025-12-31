// Custom C library implementation
#include "mylib.h"

EXPORT int add(int a, int b) {
    return a + b;
}

EXPORT int multiply(int a, int b) {
    return a * b;
}

EXPORT double average(double a, double b) {
    return (a + b) / 2.0;
}
