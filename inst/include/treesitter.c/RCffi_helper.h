#ifndef TREESITTER_C_RCFFI_HELPER_H
#define TREESITTER_C_RCFFI_HELPER_H

/*
 * RCffi_helper.h
 * Helper conversions and safe casting utilities for generated bindings.
 * - NA-aware extraction of scalar SEXPs
 * - Range/NaN checks when casting from floating to integer types (C99 semantics)
 * - Simple helpers for external pointer checks
 *
 * Place this header under `inst/include/treesitter.c/` so generated C files can
 * `#include "treesitter.c/RCffi_helper.h"` and consumers can `LinkingTo` this
 * package to reuse helpers.
 */

#include <R.h>
#include <Rinternals.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <limits.h>
#include <math.h>

#ifdef __cplusplus
extern "C" {
#endif

/* --- sanity macros --- */
#define CHECK_SEXP_TYPE(s, type) \
  do { if (TYPEOF(s) != type) error("Expected %s, got %s", #type, type2char(TYPEOF(s))); } while(0)

#define CHECK_SCALAR(s) \
  do { if (length(s) != 1) error("Expected scalar (length 1)"); } while(0)

/* --- NA-aware extraction helpers ---
 * Each function returns the C value; an optional out_is_na (int*) may be passed
 * to receive 1 when the value was NA/NaN, 0 otherwise. When out_ok (int*) is
 * provided, it is set to 1 on success or 0 on invalid conversion (overflow,
 * unexpected type, etc.). If out_ok is NULL, functions call error() on type/len
 * mismatches (consistent with other macros above).
 */

static inline int r_to_c_int_na(SEXP s, int *out_is_na, int *out_ok) {
  CHECK_SEXP_TYPE(s, INTSXP);
  CHECK_SCALAR(s);
  int v = INTEGER(s)[0];
  if (v == NA_INTEGER) {
    if (out_is_na) *out_is_na = 1;
    if (out_ok) *out_ok = 0;
    return 0;
  }
  if (out_is_na) *out_is_na = 0;
  if (out_ok) *out_ok = 1;
  return v;
}

static inline double r_to_c_double_na(SEXP s, int *out_is_na, int *out_ok) {
  CHECK_SEXP_TYPE(s, REALSXP);
  CHECK_SCALAR(s);
  double v = REAL(s)[0];
  if (R_IsNA(v) || R_IsNaN(v)) {
    if (out_is_na) *out_is_na = 1;
    if (out_ok) *out_ok = 0;
    return 0.0;
  }
  if (out_is_na) *out_is_na = 0;
  if (out_ok) *out_ok = 1;
  return v;
}

static inline int r_to_c_bool_na(SEXP s, int *out_is_na, int *out_ok) {
  CHECK_SEXP_TYPE(s, LGLSXP);
  CHECK_SCALAR(s);
  int v = LOGICAL(s)[0];
  if (v == NA_LOGICAL) {
    if (out_is_na) *out_is_na = 1;
    if (out_ok) *out_ok = 0;
    return 0;
  }
  if (out_is_na) *out_is_na = 0;
  if (out_ok) *out_ok = 1;
  return v ? 1 : 0;
}

static inline const char * r_to_c_string_na(SEXP s, int *out_is_na, int *out_ok) {
  CHECK_SEXP_TYPE(s, STRSXP);
  CHECK_SCALAR(s);
  SEXP elt = STRING_ELT(s, 0);
  if (elt == NA_STRING) {
    if (out_is_na) *out_is_na = 1;
    if (out_ok) *out_ok = 0;
    return NULL;
  }
  if (out_is_na) *out_is_na = 0;
  if (out_ok) *out_ok = 1;
  return CHAR(elt);
}

/* External pointer check */
static inline void * r_to_c_ptr_checked(SEXP s, int *out_ok) {
  if (TYPEOF(s) != EXTPTRSXP) {
    if (out_ok) *out_ok = 0;
    error("Expected external pointer");
    return NULL;
  }
  if (out_ok) *out_ok = 1;
  return R_ExternalPtrAddr(s);
}

/* --- C99 semantics and safe casts ---
 * Casting from double to integer types follows C semantics (truncation toward
 * zero) — this is what a plain (int)d does — but we provide helpers that
 * additionally check for NaN/Inf and overflow and report success via out_ok.
 */

static inline int double_to_int_checked(double v, int *out_ok) {
  if (R_IsNA(v) || R_IsNaN(v) || isinf(v)) { if (out_ok) *out_ok = 0; return NA_INTEGER; }
  if (v < (double)INT_MIN || v > (double)INT_MAX) { if (out_ok) *out_ok = 0; return (int)v; }
  if (out_ok) *out_ok = 1;
  return (int)v; /* trunc toward zero per C99 */
}

static inline int64_t double_to_int64_checked(double v, int *out_ok) {
  if (R_IsNA(v) || R_IsNaN(v) || isinf(v)) { if (out_ok) *out_ok = 0; return (int64_t)0; }
  /* note: double can exactly represent integers up to 2^53; beyond that
     conversions are lossy but we still perform range check against int64 limits */
  if (v < (double)INT64_MIN || v > (double)INT64_MAX) { if (out_ok) *out_ok = 0; return (int64_t)v; }
  if (out_ok) *out_ok = 1;
  return (int64_t)v;
}

static inline uint64_t double_to_uint64_checked(double v, int *out_ok) {
  if (R_IsNA(v) || R_IsNaN(v) || isinf(v)) { if (out_ok) *out_ok = 0; return (uint64_t)0; }
  if (v < 0.0 || v > (double)UINT64_MAX) { if (out_ok) *out_ok = 0; return (uint64_t)v; }
  if (out_ok) *out_ok = 1;
  return (uint64_t)v;
}

/* --- unaligned-safe read/write helpers --- */
static inline void read_field_unaligned(void *out, const void *src, size_t n) {
  memcpy(out, src, n);
}

static inline void write_field_unaligned(void *dst, const void *src, size_t n) {
  memcpy(dst, src, n);
}

/* --- bitfield read/write helpers --- */
static inline uint64_t read_bits_from_object(const void *obj, size_t bit_offset, unsigned width) {
  if (width == 0) return 0ULL;
  size_t byte_off = bit_offset / 8;
  unsigned bit_in_byte = (unsigned)(bit_offset % 8);
  const unsigned char *b = (const unsigned char*)obj + byte_off;
  unsigned needed_bits = bit_in_byte + width;
  unsigned needed_bytes = (needed_bits + 7) / 8;
  if (needed_bytes > sizeof(uint64_t)) needed_bytes = sizeof(uint64_t);
  uint64_t word = 0ULL;
  for (unsigned i = 0; i < needed_bytes; ++i) word |= ((uint64_t)b[i]) << (8 * i);
  word >>= bit_in_byte;
  if (width >= 64) return word;
  uint64_t mask = (width == 64) ? ~0ULL : ((1ULL << width) - 1ULL);
  return word & mask;
}

static inline void write_bits_to_object(void *obj, size_t bit_offset, unsigned width, uint64_t value) {
  if (width == 0) return;
  size_t byte_off = bit_offset / 8;
  unsigned bit_in_byte = (unsigned)(bit_offset % 8);
  unsigned needed_bits = bit_in_byte + width;
  unsigned needed_bytes = (needed_bits + 7) / 8;
  if (needed_bytes > sizeof(uint64_t)) needed_bytes = sizeof(uint64_t);
  unsigned char *b = (unsigned char*)obj + byte_off;
  uint64_t cur = 0ULL;
  for (unsigned i = 0; i < needed_bytes; ++i) cur |= ((uint64_t)b[i]) << (8 * i);
  uint64_t mask = (width == 64) ? ~0ULL : (((1ULL << width) - 1ULL) << bit_in_byte);
  uint64_t vshift = (value & ((width == 64) ? ~0ULL : ((1ULL << width) - 1ULL))) << bit_in_byte;
  cur = (cur & ~mask) | vshift;
  for (unsigned i = 0; i < needed_bytes; ++i) b[i] = (unsigned char)((cur >> (8 * i)) & 0xFFULL);
}

/* Macro: set a bitfield from a SEXP, producing out_ok (int) indicating success */
#define SET_BITFIELD_FROM_SEXP(obj, bitoff, width, sexp, out_ok) \
  do { \
    int __is_na = 0; int __ok_conv = 0; \
    int64_t __v = sexp_to_int64_checked((sexp), &__is_na, &__ok_conv); \
    if (!__ok_conv) { (out_ok) = 0; break; } \
    if ((width) < 64) { uint64_t __max = ((1ULL << (width)) - 1ULL); if ((uint64_t)__v > __max) { (out_ok) = 0; break; } } \
    write_bits_to_object((obj), (bitoff), (unsigned)(width), (uint64_t)__v); \
    (out_ok) = 1; \
  } while(0)

#define GET_BITFIELD_AS_UINT64(obj, bitoff, width) read_bits_from_object((const void*)(obj), (bitoff), (unsigned)(width))

/* Convert SEXP -> C integer types with NA and overflow checks built-in */
static inline int64_t sexp_to_int64_checked(SEXP s, int *out_is_na, int *out_ok) {
  if (TYPEOF(s) == INTSXP) {
    int isna = 0; int ok = 0; int v = r_to_c_int_na(s, &isna, &ok);
    if (out_is_na) *out_is_na = isna;
    if (!ok) { if (out_ok) *out_ok = 0; return 0; }
    if (out_ok) *out_ok = 1;
    return (int64_t)v;
  } else if (TYPEOF(s) == REALSXP) {
    double d; int ok_d = 0; d = r_to_c_double_na(s, out_is_na, &ok_d);
    if (!ok_d) { if (out_ok) *out_ok = 0; return 0; }
    int ok_conv = 0; int64_t r = double_to_int64_checked(d, &ok_conv);
    if (out_ok) *out_ok = ok_conv;
    return r;
  } else {
    error("Cannot coerce SEXP to int64: unexpected type %s", type2char(TYPEOF(s)));
    if (out_ok) *out_ok = 0;
    return 0;
  }
}

/* Minimal helper to produce NA-valued R scalars */
#define C_TO_R_INT_NA() ScalarInteger(NA_INTEGER)
#define C_TO_R_DOUBLE_NA() ScalarReal(NA_REAL)
#define C_TO_R_BOOL_NA() ScalarLogical(NA_LOGICAL)
#define C_TO_R_STRING_NA() NA_STRING

#ifdef __cplusplus
}
#endif

#endif /* TREESITTER_C_RCFFI_HELPER_H */
