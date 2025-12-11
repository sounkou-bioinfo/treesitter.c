#include "funcs.h"
#include <stddef.h>

int add_ints(int a, int b) {
    return a + b;
}

double sum_double_array(const double *arr, size_t n) {
    if (!arr) return 0.0;
    double s = 0.0;
    for (size_t i = 0; i < n; ++i) s += arr[i];
    return s;
}
