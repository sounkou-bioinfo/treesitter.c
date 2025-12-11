#include "arrays.h"
#include <stddef.h>

/* Example helper: sum elements of a Vec4 */
double vec4_sum(const struct Vec4 *v) {
    if (!v) return 0.0;
    return v->data[0] + v->data[1] + v->data[2] + v->data[3];
}

/* Example helper: initialize a FlexVec's n field (caller allocates storage) */
void flexvec_set_n(struct FlexVec *fv, size_t n) {
    if (!fv) return;
    fv->n = n;
}
