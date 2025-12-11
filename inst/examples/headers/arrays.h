#ifndef ARRAYS_H
#define ARRAYS_H
#include <stddef.h>

struct Vec4 {
  double data[4];
};

struct FlexVec {
  size_t n;
  double data[];
};

#endif // ARRAYS_H
