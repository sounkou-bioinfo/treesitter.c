#include <R.h>
#include <Rinternals.h>
#include "tree_sitter/parser.h"
// Forward declaration from tree-sitter-c
const void* tree_sitter_c(void);

// R wrapper
SEXP treesitter_language(void) {
  return R_MakeExternalPtr((void*) tree_sitter_c(), R_NilValue, R_NilValue);
}

// version 
SEXP treesitter_language_abi(void) {
  const TSLanguage *language = (const TSLanguage *) tree_sitter_c();
  // abi_version uint32_t
  return Rf_ScalarInteger(language->abi_version);
}