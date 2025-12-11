#include "enum_union.h"

/* Example functions to exercise enum/union types */
Color invert_color(Color c) {
    switch (c) {
        case RED: return BLUE;
        case BLUE: return RED;
        case GREEN: return GREEN;
        default: return RED;
    }
}

U make_union_from_int(int x) {
    U u;
    u.i = x;
    return u;
}
