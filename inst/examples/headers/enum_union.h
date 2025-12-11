#ifndef ENUM_UNION_H
#define ENUM_UNION_H

typedef enum { RED = 0, GREEN = 1, BLUE = 2 } Color;

typedef union U {
  int i;
  double d;
} U;

#endif // ENUM_UNION_H
