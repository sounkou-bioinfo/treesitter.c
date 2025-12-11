#ifndef BITFIELDS_H
#define BITFIELDS_H

struct BF1 {
  unsigned int a:5;
  unsigned int b:11;
  unsigned int c:16;
};

struct NestedAnon {
  struct {
    int x;
    unsigned y:4;
  }; // anonymous inner struct
  int z;
};

#endif // BITFIELDS_H
