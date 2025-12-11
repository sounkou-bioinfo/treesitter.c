#ifndef TREESITTER_C_OFFSETS_H
#define TREESITTER_C_OFFSETS_H

/*
 * offsets.h
 * Compile-time helpers to compute field offsets and bitfield offsets/sizes.
 *
 * Notes:
 * - These macros use GCC/Clang statement expressions and builtins like
 *   __builtin_ctzll and __builtin_clzll. They are therefore intended for
 *   compilers compatible with these extensions (GCC, Clang). If you need
 *   strict portable C89 behaviour, don't use the bitfield macros.
 * - Place this header in `inst/include/treesitter.c/` so generated sources
 *   can #include "treesitter.c/offsets.h` and downstream packages can
 *   LinkingTo this package to reuse the macros.
 */

#include <stddef.h>
#include <stdint.h>
#include <string.h>

#if !defined(__GNUC__) && !defined(__clang__)
#  if !defined(__MINGW32__) && !defined(__MINGW64__)
#    pragma message("Warning: offsets.h expects GCC/Clang builtins; falling back to portable implementations where possible")
#  endif
#endif

/* Provide CTZ/CLZ helpers: prefer compiler builtins when available (GCC/Clang/Mingw),
 * otherwise fall back to portable loops. */
#if defined(__GNUC__) || defined(__clang__) || defined(__MINGW32__) || defined(__MINGW64__)
#  define CTZLL(x) __builtin_ctzll(x)
#  define CLZLL(x) __builtin_clzll(x)
#else
static inline int CTZLL(uint64_t x) {
    if (x == 0) return 64;
    int i = 0;
    while ((x & 1ULL) == 0ULL) { x >>= 1; ++i; }
    return i;
}

static inline int CLZLL(uint64_t x) {
    if (x == 0) return 64;
    int i = 0;
    uint64_t mask = (uint64_t)1 << 63;
    while ((x & mask) == 0ULL) { mask >>= 1; ++i; }
    return i;
}
#endif

/* Regular offsetof for byte offsets */
#define FIELD_OFFSET(type, field) ((size_t)offsetof(type, field))

/*
 * Simple bitfield offset/size computation for types fitting into 64 bits.
 * bitoffsetof(type, field) -> bit offset from start of object (in bits)
 * bitsizeof(type, field)   -> width of the bitfield in bits
 */
#define BITOFFSET(type, field) \
    ({ union { unsigned long long raw; type typ; } u = {0}; \
       ++u.typ.field; CTZLL(u.raw); })

#define BITSIZE(type, field) \
    ({ union { unsigned long long raw; type typ; } u = {0}; \
       --u.typ.field; 64 - CLZLL(u.raw) - CTZLL(u.raw); })

/*
 * Large-struct bitfield helpers: handle arbitrary-sized objects by scanning
 * the underlying storage words. These are more robust when the containing
 * type is larger than 8 bytes.
 */
#define __BIT_WORD unsigned long long

#define BITOFFSET_LARGE(type, field) \
    ({ typedef __BIT_WORD __pad_t; \
       const size_t __max_words = (sizeof(type) + sizeof(__pad_t) - 1) / sizeof(__pad_t); \
       union { __pad_t raw[__max_words]; type typ; } __u; \
       memset(__u.raw, 0, sizeof __u.raw); \
       ++__u.typ.field; \
       size_t __i = 0; \
       for (; __i < __max_words; ++__i) if (__u.raw[__i] != 0ULL) break; \
       size_t __res; \
       if (__i == __max_words) __res = 0; \
       else __res = (__i * (size_t)(8 * sizeof(__pad_t))) + CTZLL(__u.raw[__i]); \
       __res; })

#define BITSIZE_LARGE(type, field) \
    ({ typedef __BIT_WORD __pad_t; \
       const size_t __max_words = (sizeof(type) + sizeof(__pad_t) - 1) / sizeof(__pad_t); \
       union { __pad_t raw[__max_words]; type typ; } __u; \
       memset(__u.raw, 0, sizeof __u.raw); \
       --__u.typ.field; \
       /* find first non-zero word for start and last non-zero for end */ \
       size_t __start_word = 0, __end_word = 0; \
       for (; __start_word < __max_words; ++__start_word) if (__u.raw[__start_word] != 0ULL) break; \
       for (__end_word = __max_words; __end_word > 0; --__end_word) if (__u.raw[__end_word - 1] != 0ULL) break; \
       size_t __res_bs; \
       if (__start_word >= __max_words || __end_word == 0) __res_bs = 0; \
       else { \
         size_t __start = (__start_word * (size_t)(8 * sizeof(__pad_t))) + CTZLL(__u.raw[__start_word]); \
         size_t __end_last = (__end_word - 1) * (size_t)(8 * sizeof(__pad_t)) + (64 - CLZLL(__u.raw[__end_word - 1])); \
         __res_bs = (__end_last - __start); } __res_bs; })

/*
 * Convenience macro: convert bit offset (bits) and width into a byte offset
 * and bit-in-byte if needed by generated accessors. Use FIELD_OFFSET for
 * pure-byte fields.
 */
#define BIT_TO_BYTE_OFFSET(bit_offset) ((size_t)((bit_offset) / 8))
#define BIT_IN_BYTE(bit_offset) ((unsigned)((bit_offset) % 8))

#endif /* TREESITTER_C_OFFSETS_H */
