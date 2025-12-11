#include <R.h>
#include <Rinternals.h>
#include <stddef.h>
#include <stdint.h>
#include "arrays.h"
#include "bitfields.h"
#include "enum_union.h"
#include "funcs.h"
#include "point.h"
#include "primitives.h"
#include "treesitter.c/RCffi_helper.h"
#include "treesitter.c/offsets.h"
#include <stdlib.h>

static void finalize_treesitter_c_gen(SEXP ext) { void *p = R_ExternalPtrAddr(ext); if (p) free(p); }

SEXP wrap_treesitter_c_gen_add_ints(SEXP s_arg1, SEXP s_arg2) {
  int arg1 = r_to_c_int_na(s_arg1, NULL, NULL);
  int arg2 = r_to_c_int_na(s_arg2, NULL, NULL);
  int __res = add_ints((arg1), (arg2));
  return ScalarInteger(__res);
}


SEXP wrap_treesitter_c_gen_sum_double_array(SEXP s_arg1, SEXP s_arg2) {
  CHECK_SEXP_TYPE(s_arg1, REALSXP); double *arg1 = REAL(s_arg1); size_t arg1_len = (size_t) length(s_arg1);
  int arg2 = r_to_c_int_na(s_arg2, NULL, NULL);
  double __res = sum_double_array((arg1), (arg2));
  return ScalarReal(__res);
}


SEXP make_treesitter_c_gen_Vec4() { struct Vec4 *p = (struct Vec4*) calloc(1, sizeof(struct Vec4)); if (!p) error("alloc failed"); SEXP ext = R_MakeExternalPtr(p, R_NilValue, R_NilValue); R_RegisterCFinalizer(ext, finalize_treesitter_c_gen); return ext; }

SEXP get_treesitter_c_gen_Vec4_field(SEXP ext, SEXP sname) { struct Vec4 *p = (struct Vec4*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));

  error("unknown field"); }

SEXP set_treesitter_c_gen_Vec4_field(SEXP ext, SEXP sname, SEXP raw) { struct Vec4 *p = (struct Vec4*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));

  error("unknown field"); return R_NilValue; }


SEXP make_treesitter_c_gen_FlexVec() { struct FlexVec *p = (struct FlexVec*) calloc(1, sizeof(struct FlexVec)); if (!p) error("alloc failed"); SEXP ext = R_MakeExternalPtr(p, R_NilValue, R_NilValue); R_RegisterCFinalizer(ext, finalize_treesitter_c_gen); return ext; }

SEXP get_treesitter_c_gen_FlexVec_field(SEXP ext, SEXP sname) { struct FlexVec *p = (struct FlexVec*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "n")==0) { size_t sz = sizeof(((struct FlexVec*)0)->n); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct FlexVec, n), sz); UNPROTECT(1); return out; }
  error("unknown field"); }

SEXP set_treesitter_c_gen_FlexVec_field(SEXP ext, SEXP sname, SEXP raw) { struct FlexVec *p = (struct FlexVec*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "n")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_FlexVec_field: raw required"); size_t sz = sizeof(((struct FlexVec*)0)->n); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_FlexVec_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct FlexVec, n), RAW(raw), sz); return R_NilValue; }
  error("unknown field"); return R_NilValue; }

SEXP get_treesitter_c_gen_FlexVec_n(SEXP ext, SEXP raw_unused) { struct FlexVec *p = (struct FlexVec*) r_to_c_ptr_checked(ext, NULL); int tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct FlexVec, n), sizeof(int)); return ScalarInteger(tmp); }
SEXP set_treesitter_c_gen_FlexVec_n(SEXP ext, SEXP val) { struct FlexVec *p = (struct FlexVec*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; int __v = r_to_c_int_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_FlexVec_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct FlexVec, n), &__v, sizeof(int)); return R_NilValue; }


SEXP make_treesitter_c_gen_BF1() { struct BF1 *p = (struct BF1*) calloc(1, sizeof(struct BF1)); if (!p) error("alloc failed"); SEXP ext = R_MakeExternalPtr(p, R_NilValue, R_NilValue); R_RegisterCFinalizer(ext, finalize_treesitter_c_gen); return ext; }

SEXP get_treesitter_c_gen_BF1_field(SEXP ext, SEXP sname) { struct BF1 *p = (struct BF1*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "a")==0) { uint64_t v = GET_BITFIELD_AS_UINT64(p, BITOFFSET(struct BF1, a), BITSIZE(struct BF1, a)); return ScalarReal((double)v); }
    if (strcmp(name, "b")==0) { uint64_t v = GET_BITFIELD_AS_UINT64(p, BITOFFSET(struct BF1, b), BITSIZE(struct BF1, b)); return ScalarReal((double)v); }
    if (strcmp(name, "c")==0) { uint64_t v = GET_BITFIELD_AS_UINT64(p, BITOFFSET(struct BF1, c), BITSIZE(struct BF1, c)); return ScalarReal((double)v); }
  error("unknown field"); }

SEXP set_treesitter_c_gen_BF1_field(SEXP ext, SEXP sname, SEXP raw) { struct BF1 *p = (struct BF1*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "a")==0) { int __ok=0; SET_BITFIELD_FROM_SEXP(p, BITOFFSET(struct BF1, a), BITSIZE(struct BF1, a), raw, __ok); if (!__ok) error("set_treesitter_c_gen_BF1_field: conversion failed"); return R_NilValue; }
    if (strcmp(name, "b")==0) { int __ok=0; SET_BITFIELD_FROM_SEXP(p, BITOFFSET(struct BF1, b), BITSIZE(struct BF1, b), raw, __ok); if (!__ok) error("set_treesitter_c_gen_BF1_field: conversion failed"); return R_NilValue; }
    if (strcmp(name, "c")==0) { int __ok=0; SET_BITFIELD_FROM_SEXP(p, BITOFFSET(struct BF1, c), BITSIZE(struct BF1, c), raw, __ok); if (!__ok) error("set_treesitter_c_gen_BF1_field: conversion failed"); return R_NilValue; }
  error("unknown field"); return R_NilValue; }


SEXP make_treesitter_c_gen_NestedAnon() { struct NestedAnon *p = (struct NestedAnon*) calloc(1, sizeof(struct NestedAnon)); if (!p) error("alloc failed"); SEXP ext = R_MakeExternalPtr(p, R_NilValue, R_NilValue); R_RegisterCFinalizer(ext, finalize_treesitter_c_gen); return ext; }

SEXP get_treesitter_c_gen_NestedAnon_field(SEXP ext, SEXP sname) { struct NestedAnon *p = (struct NestedAnon*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "x")==0) { size_t sz = sizeof(((struct NestedAnon*)0)->x); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct NestedAnon, x), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "y")==0) { uint64_t v = GET_BITFIELD_AS_UINT64(p, BITOFFSET(struct NestedAnon, y), BITSIZE(struct NestedAnon, y)); return ScalarReal((double)v); }
    if (strcmp(name, "z")==0) { size_t sz = sizeof(((struct NestedAnon*)0)->z); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct NestedAnon, z), sz); UNPROTECT(1); return out; }
  error("unknown field"); }

SEXP set_treesitter_c_gen_NestedAnon_field(SEXP ext, SEXP sname, SEXP raw) { struct NestedAnon *p = (struct NestedAnon*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "x")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_NestedAnon_field: raw required"); size_t sz = sizeof(((struct NestedAnon*)0)->x); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_NestedAnon_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct NestedAnon, x), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "y")==0) { int __ok=0; SET_BITFIELD_FROM_SEXP(p, BITOFFSET(struct NestedAnon, y), BITSIZE(struct NestedAnon, y), raw, __ok); if (!__ok) error("set_treesitter_c_gen_NestedAnon_field: conversion failed"); return R_NilValue; }
    if (strcmp(name, "z")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_NestedAnon_field: raw required"); size_t sz = sizeof(((struct NestedAnon*)0)->z); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_NestedAnon_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct NestedAnon, z), RAW(raw), sz); return R_NilValue; }
  error("unknown field"); return R_NilValue; }

SEXP get_treesitter_c_gen_NestedAnon_x(SEXP ext, SEXP raw_unused) { struct NestedAnon *p = (struct NestedAnon*) r_to_c_ptr_checked(ext, NULL); int tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct NestedAnon, x), sizeof(int)); return ScalarInteger(tmp); }
SEXP get_treesitter_c_gen_NestedAnon_z(SEXP ext, SEXP raw_unused) { struct NestedAnon *p = (struct NestedAnon*) r_to_c_ptr_checked(ext, NULL); int tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct NestedAnon, z), sizeof(int)); return ScalarInteger(tmp); }
SEXP set_treesitter_c_gen_NestedAnon_x(SEXP ext, SEXP val) { struct NestedAnon *p = (struct NestedAnon*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; int __v = r_to_c_int_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_NestedAnon_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct NestedAnon, x), &__v, sizeof(int)); return R_NilValue; }
SEXP set_treesitter_c_gen_NestedAnon_z(SEXP ext, SEXP val) { struct NestedAnon *p = (struct NestedAnon*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; int __v = r_to_c_int_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_NestedAnon_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct NestedAnon, z), &__v, sizeof(int)); return R_NilValue; }


SEXP make_treesitter_c_gen_Point() { struct Point *p = (struct Point*) calloc(1, sizeof(struct Point)); if (!p) error("alloc failed"); SEXP ext = R_MakeExternalPtr(p, R_NilValue, R_NilValue); R_RegisterCFinalizer(ext, finalize_treesitter_c_gen); return ext; }

SEXP get_treesitter_c_gen_Point_field(SEXP ext, SEXP sname) { struct Point *p = (struct Point*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "x")==0) { size_t sz = sizeof(((struct Point*)0)->x); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Point, x), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "y")==0) { size_t sz = sizeof(((struct Point*)0)->y); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Point, y), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "flags")==0) { uint64_t v = GET_BITFIELD_AS_UINT64(p, BITOFFSET(struct Point, flags), BITSIZE(struct Point, flags)); return ScalarReal((double)v); }
  error("unknown field"); }

SEXP set_treesitter_c_gen_Point_field(SEXP ext, SEXP sname, SEXP raw) { struct Point *p = (struct Point*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "x")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Point_field: raw required"); size_t sz = sizeof(((struct Point*)0)->x); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Point_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Point, x), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "y")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Point_field: raw required"); size_t sz = sizeof(((struct Point*)0)->y); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Point_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Point, y), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "flags")==0) { int __ok=0; SET_BITFIELD_FROM_SEXP(p, BITOFFSET(struct Point, flags), BITSIZE(struct Point, flags), raw, __ok); if (!__ok) error("set_treesitter_c_gen_Point_field: conversion failed"); return R_NilValue; }
  error("unknown field"); return R_NilValue; }

SEXP get_treesitter_c_gen_Point_x(SEXP ext, SEXP raw_unused) { struct Point *p = (struct Point*) r_to_c_ptr_checked(ext, NULL); int tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct Point, x), sizeof(int)); return ScalarInteger(tmp); }
SEXP get_treesitter_c_gen_Point_y(SEXP ext, SEXP raw_unused) { struct Point *p = (struct Point*) r_to_c_ptr_checked(ext, NULL); double tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct Point, y), sizeof(double)); return ScalarReal(tmp); }
SEXP set_treesitter_c_gen_Point_x(SEXP ext, SEXP val) { struct Point *p = (struct Point*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; int __v = r_to_c_int_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_Point_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Point, x), &__v, sizeof(int)); return R_NilValue; }
SEXP set_treesitter_c_gen_Point_y(SEXP ext, SEXP val) { struct Point *p = (struct Point*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; double __v = r_to_c_double_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_Point_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Point, y), &__v, sizeof(double)); return R_NilValue; }


SEXP make_treesitter_c_gen_Prims() { struct Prims *p = (struct Prims*) calloc(1, sizeof(struct Prims)); if (!p) error("alloc failed"); SEXP ext = R_MakeExternalPtr(p, R_NilValue, R_NilValue); R_RegisterCFinalizer(ext, finalize_treesitter_c_gen); return ext; }

SEXP get_treesitter_c_gen_Prims_field(SEXP ext, SEXP sname) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "c")==0) { size_t sz = sizeof(((struct Prims*)0)->c); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, c), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "sc")==0) { size_t sz = sizeof(((struct Prims*)0)->sc); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, sc), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "uc")==0) { size_t sz = sizeof(((struct Prims*)0)->uc); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, uc), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "s")==0) { size_t sz = sizeof(((struct Prims*)0)->s); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, s), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "us")==0) { size_t sz = sizeof(((struct Prims*)0)->us); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, us), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "i")==0) { size_t sz = sizeof(((struct Prims*)0)->i); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, i), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "ui")==0) { size_t sz = sizeof(((struct Prims*)0)->ui); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, ui), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "ll")==0) { size_t sz = sizeof(((struct Prims*)0)->ll); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, ll), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "ull")==0) { size_t sz = sizeof(((struct Prims*)0)->ull); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, ull), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "f")==0) { size_t sz = sizeof(((struct Prims*)0)->f); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, f), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "d")==0) { size_t sz = sizeof(((struct Prims*)0)->d); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, d), sz); UNPROTECT(1); return out; }
    if (strcmp(name, "b")==0) { size_t sz = sizeof(((struct Prims*)0)->b); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct Prims, b), sz); UNPROTECT(1); return out; }
  error("unknown field"); }

SEXP set_treesitter_c_gen_Prims_field(SEXP ext, SEXP sname, SEXP raw) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));
  if (strcmp(name, "c")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->c); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, c), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "sc")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->sc); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, sc), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "uc")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->uc); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, uc), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "s")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->s); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, s), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "us")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->us); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, us), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "i")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->i); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, i), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "ui")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->ui); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, ui), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "ll")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->ll); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, ll), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "ull")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->ull); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, ull), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "f")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->f); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, f), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "d")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->d); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, d), RAW(raw), sz); return R_NilValue; }
    if (strcmp(name, "b")==0) { if (TYPEOF(raw) != RAWSXP) error("set_treesitter_c_gen_Prims_field: raw required"); size_t sz = sizeof(((struct Prims*)0)->b); if ((size_t) LENGTH(raw) != sz) error("set_treesitter_c_gen_Prims_field: wrong size"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, b), RAW(raw), sz); return R_NilValue; }
  error("unknown field"); return R_NilValue; }

SEXP get_treesitter_c_gen_Prims_c(SEXP ext, SEXP raw_unused) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); int tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct Prims, c), sizeof(int)); return ScalarInteger(tmp); }
SEXP get_treesitter_c_gen_Prims_i(SEXP ext, SEXP raw_unused) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); int tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct Prims, i), sizeof(int)); return ScalarInteger(tmp); }
SEXP get_treesitter_c_gen_Prims_f(SEXP ext, SEXP raw_unused) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); float tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct Prims, f), sizeof(float)); return ScalarReal((double)tmp); }
SEXP get_treesitter_c_gen_Prims_d(SEXP ext, SEXP raw_unused) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); double tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct Prims, d), sizeof(double)); return ScalarReal(tmp); }
SEXP get_treesitter_c_gen_Prims_b(SEXP ext, SEXP raw_unused) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); int tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct Prims, b), sizeof(int)); return ScalarLogical(tmp ? 1 : 0); }
SEXP set_treesitter_c_gen_Prims_c(SEXP ext, SEXP val) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; int __v = r_to_c_int_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_Prims_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, c), &__v, sizeof(int)); return R_NilValue; }
SEXP set_treesitter_c_gen_Prims_i(SEXP ext, SEXP val) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; int __v = r_to_c_int_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_Prims_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, i), &__v, sizeof(int)); return R_NilValue; }
SEXP set_treesitter_c_gen_Prims_f(SEXP ext, SEXP val) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; double __dv = r_to_c_double_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_Prims_field: bad value"); float __v = (float)__dv; write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, f), &__v, sizeof(float)); return R_NilValue; }
SEXP set_treesitter_c_gen_Prims_d(SEXP ext, SEXP val) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; double __v = r_to_c_double_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_Prims_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, d), &__v, sizeof(double)); return R_NilValue; }
SEXP set_treesitter_c_gen_Prims_b(SEXP ext, SEXP val) { struct Prims *p = (struct Prims*) r_to_c_ptr_checked(ext, NULL); int __isna=0, __ok=0; int __v = r_to_c_bool_na(val, &__isna, &__ok); if (!__ok) error("set_treesitter_c_gen_Prims_field: bad value"); write_field_unaligned((char*)p + FIELD_OFFSET(struct Prims, b), &__v, sizeof(int)); return R_NilValue; }


static const R_CallMethodDef callMethods[] = {
  {"add_ints", (DL_FUNC) &wrap_treesitter_c_gen_add_ints, 2},
  {"sum_double_array", (DL_FUNC) &wrap_treesitter_c_gen_sum_double_array, 2},
  {"make_Vec4", (DL_FUNC) &make_treesitter_c_gen_Vec4, 0},
  {"get_Vec4_field", (DL_FUNC) &get_treesitter_c_gen_Vec4_field, 2},
  {"set_Vec4_field", (DL_FUNC) &set_treesitter_c_gen_Vec4_field, 3},
  {"make_FlexVec", (DL_FUNC) &make_treesitter_c_gen_FlexVec, 0},
  {"get_FlexVec_field", (DL_FUNC) &get_treesitter_c_gen_FlexVec_field, 2},
  {"set_FlexVec_field", (DL_FUNC) &set_treesitter_c_gen_FlexVec_field, 3},
  {"get_FlexVec_n", (DL_FUNC) &get_treesitter_c_gen_FlexVec_n, 1},
  {"set_FlexVec_n", (DL_FUNC) &set_treesitter_c_gen_FlexVec_n, 2},
  {"make_BF1", (DL_FUNC) &make_treesitter_c_gen_BF1, 0},
  {"get_BF1_field", (DL_FUNC) &get_treesitter_c_gen_BF1_field, 2},
  {"set_BF1_field", (DL_FUNC) &set_treesitter_c_gen_BF1_field, 3},
  {"make_NestedAnon", (DL_FUNC) &make_treesitter_c_gen_NestedAnon, 0},
  {"get_NestedAnon_field", (DL_FUNC) &get_treesitter_c_gen_NestedAnon_field, 2},
  {"set_NestedAnon_field", (DL_FUNC) &set_treesitter_c_gen_NestedAnon_field, 3},
  {"get_NestedAnon_x", (DL_FUNC) &get_treesitter_c_gen_NestedAnon_x, 1},
  {"set_NestedAnon_x", (DL_FUNC) &set_treesitter_c_gen_NestedAnon_x, 2},
  {"get_NestedAnon_z", (DL_FUNC) &get_treesitter_c_gen_NestedAnon_z, 1},
  {"set_NestedAnon_z", (DL_FUNC) &set_treesitter_c_gen_NestedAnon_z, 2},
  {"make_Point", (DL_FUNC) &make_treesitter_c_gen_Point, 0},
  {"get_Point_field", (DL_FUNC) &get_treesitter_c_gen_Point_field, 2},
  {"set_Point_field", (DL_FUNC) &set_treesitter_c_gen_Point_field, 3},
  {"get_Point_x", (DL_FUNC) &get_treesitter_c_gen_Point_x, 1},
  {"set_Point_x", (DL_FUNC) &set_treesitter_c_gen_Point_x, 2},
  {"get_Point_y", (DL_FUNC) &get_treesitter_c_gen_Point_y, 1},
  {"set_Point_y", (DL_FUNC) &set_treesitter_c_gen_Point_y, 2},
  {"make_Prims", (DL_FUNC) &make_treesitter_c_gen_Prims, 0},
  {"get_Prims_field", (DL_FUNC) &get_treesitter_c_gen_Prims_field, 2},
  {"set_Prims_field", (DL_FUNC) &set_treesitter_c_gen_Prims_field, 3},
  {"get_Prims_c", (DL_FUNC) &get_treesitter_c_gen_Prims_c, 1},
  {"set_Prims_c", (DL_FUNC) &set_treesitter_c_gen_Prims_c, 2},
  {"get_Prims_i", (DL_FUNC) &get_treesitter_c_gen_Prims_i, 1},
  {"set_Prims_i", (DL_FUNC) &set_treesitter_c_gen_Prims_i, 2},
  {"get_Prims_f", (DL_FUNC) &get_treesitter_c_gen_Prims_f, 1},
  {"set_Prims_f", (DL_FUNC) &set_treesitter_c_gen_Prims_f, 2},
  {"get_Prims_d", (DL_FUNC) &get_treesitter_c_gen_Prims_d, 1},
  {"set_Prims_d", (DL_FUNC) &set_treesitter_c_gen_Prims_d, 2},
  {"get_Prims_b", (DL_FUNC) &get_treesitter_c_gen_Prims_b, 1},
  {"set_Prims_b", (DL_FUNC) &set_treesitter_c_gen_Prims_b, 2},
  {NULL, NULL, 0}
};
void R_init_treesitter_c_gen(DllInfo *dll) {
  R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(dll, TRUE);
  R_forceSymbols(dll, TRUE);
}
