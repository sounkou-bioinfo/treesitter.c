#include <R.h>
#include <Rinternals.h>

// Forward declaration from tree-sitter-c
const void* tree_sitter_c(void);

// R wrapper
SEXP ffi_language(void) {
  return R_MakeExternalPtr((void*) tree_sitter_c(), R_NilValue, R_NilValue);
}
