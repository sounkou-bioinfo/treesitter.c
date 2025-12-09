#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

// Forward declarations
SEXP treesitter_language(void);
SEXP treesitter_language_abi(void);
// Symbol registration
static const R_CallMethodDef CallEntries[] = {
  {"treesitter_language", (DL_FUNC) &treesitter_language, 0},
  {"treesitter_language_abi", (DL_FUNC) &treesitter_language_abi, 0},
  {NULL, NULL, 0}
};

void R_init_treesitter_c(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
